#lang racket/base

(require pict
         racket/draw
         racket/class
         racket/match
         rackunit
         frosthaven-manager/elements
         (rename-in frosthaven-manager/testfiles/aoes/ring1
                    [aoe test1])
         (rename-in frosthaven-manager/testfiles/aoes/drag-down
                    [aoe test2])
         (rename-in frosthaven-manager/testfiles/aoes/speartip
                    [aoe test3])
         (rename-in frosthaven-manager/testfiles/aoes/unbreakable-wall
                    [aoe test4]))

(define (pequal-bytes? p q)
  (equal? (pict->argb-pixels p)
          (pict->argb-pixels q)))

(define (pict->recorded-datum p)
  (let ([dc (new record-dc%)])
    (draw-pict p dc 0 0)
    (send dc get-recorded-datum)))

(define (pequal-dc? p q)
  (equal? (pict->recorded-datum p)
          (pict->recorded-datum q)))

(define checks
  (append
   (list
    (list (test1) (test1) #t)
    (list (test2) (test2) #t)
    (list (test3) (test3) #t)
    (list (test4) (test4) #t)
    (list (test1) (test4) #f)
    (list (test2) (test3) #f))
   (for*/list ([element1 (list fire ice earth air light dark)]
               [element2 (list fire ice earth air light dark)]
               [procedure1 (list element-pics-infused
                                 element-pics-waning
                                 element-pics-unfused
                                 element-pics-consume)]
               [procedure2 (list element-pics-infused
                                 element-pics-waning
                                 element-pics-unfused
                                 element-pics-consume)])
     (list (procedure1 (element1))
           (procedure2 (element2))
           (and (equal? procedure1 procedure2)
                (equal? element1 element2))))))

(define (run-time-bench n pequal?)
  (for ([_i (in-range n)])
    (for ([check (in-list checks)])
      (match-define (list p q expected) check)
      (check-equal? (time (pequal? p q)) expected))))

(define (run-memory-bench n constructor)
  (for ([_i (in-range n)])
    (collect-garbage)
    (collect-garbage)
    (collect-garbage)
    (collect-garbage)
    (define old (current-memory-use))
    (for ([check (in-list checks)])
      (match-define (list p q _expected) check)
      (constructor p)
      (constructor q))
    (define new (current-memory-use))
    (println (- new old))))

(module+ main
  (require racket/cmdline)
  (define constructor (make-parameter #f))
  (define comparator (make-parameter #f))
  (define bench (make-parameter #f))
  (define n (make-parameter 10))
  (define arg (make-parameter #f))
  (command-line
   #:once-any
   [("--bytes") "Benchmark using bytes"
                (constructor pict->argb-pixels)
                (comparator pequal-bytes?)]
   [("--record-dc") "Benchmark using record-dc%"
                (constructor pict->recorded-datum)
                (comparator pequal-dc?)]
   #:once-any
   [("--time") "Benchmark timing"
               (bench run-time-bench)
               (arg comparator)]
   [("--memory") "Benchmark memory"
                 (bench run-memory-bench)
                 (arg constructor)]
   #:once-each
   [("-n") N "Number of iterations [10]" (n (string->number N))]
   #:args ()
   (unless (and (bench) (n) (arg) ((arg)))
     (raise-user-error "Missing arguments"))
   ((bench) (n) ((arg)))))
