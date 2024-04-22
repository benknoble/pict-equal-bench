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

(for ([class '("cpu" "real" "gc")])
  (save-pict
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
    #:x-min (case class
              [("gc") -0.5]
              [else -3])
    #:x-max (case class
              [("gc") 0.5]
              [else 10])
    #:title (format "Normal distributions of time for ~a" class))
    (format "~a-normal.svg" class)))
