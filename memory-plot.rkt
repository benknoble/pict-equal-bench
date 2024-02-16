#lang racket

(require (only-in racket/gui)
         pict
         threading
         graphite
         data-frame
         sawzall)

(~> "memory.csv" df-read/csv
    (create [memory (memory) (/ memory (expt 2 20))])
    (graph #:data _
           #:mapping (aes #:x "bench" #:y "memory")
           #:title "Memory Use by Pict Transformers for Comparison"
           #:y-label "Memory Use (MiB)"
           #:x-label "Transformer"
           (boxplot #:show-outliers? #t))
    #;show-pict
    (save-pict "memory.svg"))
