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

(define m
  (~> "memory.csv" df-read/csv
      (create [memory (memory) (/ memory (expt 2 20))])))

(define dist
  (~> m
      (group-with "bench")
      (aggregate [memory-μ (memory) (v-μ memory)]
                 [memory-σ (memory) (v-σ memory)])))

(plot:plot-pen-color-map 'set1)
(plot:plot-brush-color-map 'pastel1)

(save-pict
 (plot:plot-pict
  (for/list ([type '("bytes" "record-dc")]
             [i (in-naturals)])
    (define only-type (~> dist
                          (where (bench) (equal? bench type))))
    (define μ (df-ref only-type 0 "memory-μ"))
    (define σ (df-ref only-type 0 "memory-σ"))
    (plot:function (distribution-pdf (normal-dist μ σ))
                   #:color i
                   #:label (format "~a: N(~a,~a)" type μ σ)))
  #:x-min -1
  #:x-max 2
  #:legend-anchor 'outside-top-left
  #:title (format "Normal distributions of memory (MiB)"))
 "memory-normal.svg")
