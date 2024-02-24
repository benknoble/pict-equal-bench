#lang racket

(require (only-in racket/gui)
         pict
         threading
         graphite
         data-frame
         sawzall)

(~> "memory.csv" df-read/csv
    (create [memory (memory) (/ memory (expt 2 10))])
    (graph #:data _
           #:mapping (aes #:x "bench" #:y "memory")
           #:title "Memory Use by Pict Transformers for Comparison"
           #:y-label "Memory Use (KiB)"
           #:x-label "Transformer"
           (boxplot #:show-outliers? #f))
    #;show-pict
    (save-pict "memory2.svg"))
