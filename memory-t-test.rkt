#lang racket

(require threading
         data-frame
         sawzall
         t-test)

(define m
  (~> "memory.csv" df-read/csv
      (create [memory (memory) (/ memory (expt 2 20))])))

(apply
 welch-t-test
 (~> m
     (split-with "bench")
     (map (λ (df)
            (~> df
                (slice ["memory"])
                (df-select "memory")))
          _)))
