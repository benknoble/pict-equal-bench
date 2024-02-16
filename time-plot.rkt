#lang racket

(require (only-in racket/gui)
         pict
         threading
         graphite
         data-frame
         sawzall)

(~> "time.csv" df-read/csv
    (pivot-longer ["cpu" "real" "gc"] #:names-to "place" #:values-to "time")
    (graph #:data _
           #:mapping (aes #:x "bench" #:y "time" #:facet "place")
           #:title "Time Spent Comparing Picts by Transformers"
           #:facet-wrap 3
           #:y-label "Time (ms)"
           #:x-label "Transformer"
           (boxplot #:show-outliers? #t))
    #;show-pict
    (save-pict "time.svg"))
