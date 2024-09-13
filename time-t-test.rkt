#lang racket

(require threading
         data-frame
         sawzall
         t-test)

(define t (df-read/csv "time.csv"))

(for/list ([column '("cpu" "real" "gc")])
  (list column
        (apply
         welch-t-test
         (~> t
             (slice (all-in (list "bench" column)))
             (split-with "bench")
             (map (λ (df)
                    (~> df
                        (slice column)
                        (df-select column)))
                  _)))))
