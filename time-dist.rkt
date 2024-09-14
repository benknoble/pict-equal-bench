#lang racket

(require (only-in racket/gui)
         pict
         threading
         graphite
         data-frame
         sawzall
         math/statistics
         math/distributions
         (prefix-in plot:
                    (combine-in
                     plot
                     plot/utils)))

(define (v-μ xs)
  (exact->inexact (mean (vector->list xs))))

(define (v-σ xs)
  (stddev (vector->list xs)))

(define t-short (df-read/csv "time.csv"))

(define dist
  (~> t-short
      (group-with "bench")
      (aggregate [cpu-μ (cpu) (v-μ cpu)]
                 [cpu-σ (cpu) (v-σ cpu)]
                 [real-μ (real) (v-μ real)]
                 [real-σ (real) (v-σ real)]
                 [gc-μ (gc) (v-μ gc)]
                 [gc-σ (gc) (v-σ gc)])))

(plot:plot-pen-color-map 'set1)
(plot:plot-brush-color-map 'pastel1)

(define compute-interval?
  (let ([intervals #f])
    (command-line
     #:once-each
     ["--intervals" "Compute and plot confidence intervals" (set! intervals #t)]
     #:args ()
     intervals)))

(for ([class '("cpu" "real" "gc")])
  (save-pict
   (cond
     [compute-interval?
      (apply
       hc-append
       (for/list ([type '("bytes" "record-dc")])
         (define only-type (~> dist
                               (where (bench) (equal? bench type))))
         (define μ (df-ref only-type 0 (~a class "-μ")))
         (define σ (df-ref only-type 0 (~a class "-σ")))
         (define n (df-row-count (~> t-short
                                     (where (bench) (equal? bench type)))))
         (define range
           (list
            (- μ (* 1.96 (/ σ n)))
            (+ μ (* 1.96 (/ σ n)))))
         (println (list* class type range))
         (plot:plot-pict
          #:legend-anchor 'outside-top-left
          #:title (format "Normal distributions of time for ~a" class)
          #:x-min (* (match class
                       ["gc" 0.9]
                       [_ 0.99])
                     (first range))
          #:x-max (* (match class
                       ["gc" 1.1]
                       [_ 1.01])
                     (second range))
          (cons
           (plot:function (distribution-pdf (normal-dist μ σ))
                          #:label (format "N(~a,~a)" μ σ))
           (map (λ (x)
                  (plot:vrule x #:label (~a x)))
                range)))))]
     [else
      (plot:plot-pict
       (for/list ([type '("bytes" "record-dc")]
                  [i (in-naturals)])
         (define only-type (~> dist
                               (where (bench) (equal? bench type))))
         (define μ (df-ref only-type 0 (~a class "-μ")))
         (define σ (df-ref only-type 0 (~a class "-σ")))
         (plot:function (distribution-pdf (normal-dist μ σ))
                        #:color i
                        #:label (format "~a: N(~a,~a)" type μ σ)))
       #:x-min (match class
                 ["gc" -0.5]
                 [_ -3])
       #:x-max (match class
                 ["gc" 0.5]
                 [_ 10])
       #:legend-anchor 'outside-top-left
       #:title (format "Normal distributions of time for ~a" class))])
   (if compute-interval?
       (format "~a-interval.svg" class)
       (format "~a-normal.svg" class))))
