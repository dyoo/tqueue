#lang racket/base


(require "tqueue.rkt"
         rackunit
         rackunit/text-ui)

(provide test-topological-queue)


(define test-topological-queue
  (test-suite
   "test-topological-queue.ss"
   (test-case
    "c depends on b, b depends on a"
    (let ([tqueue (new-tqueue)])
      (tqueue-add! tqueue 'a '())
      (check-eq? (tqueue-get tqueue) 'a)
      (tqueue-add! tqueue 'b '(a))
      (check-false (tqueue-try-get tqueue))
      (tqueue-add! tqueue 'c '(b))
      (check-false (tqueue-try-get tqueue))
      (tqueue-satisfy! tqueue 'a)
      
      (check-eq? (tqueue-try-get tqueue) 'b)
      (tqueue-satisfy! tqueue 'b)
      (check-eq? (tqueue-try-get tqueue) 'c)))

   (test-case
    "ensure it's depending on eq rather than equal"
    (let ([tqueue (new-tqueue)])
      (tqueue-add! tqueue "a" (list "b"))
      (tqueue-satisfy! tqueue (string-copy "b"))
      (check-eq? (tqueue-try-get tqueue) #f)))

   (test-case
    "ensure it's depending on eq rather than equal"
    (let ([tqueue (new-tqueue)]
          [a (string-copy "a")]
          [b (string-copy "b")])
      (tqueue-add! tqueue a (list b))
      (tqueue-satisfy! tqueue b)
      (check-eq? (tqueue-try-get tqueue) a)))

   (test-case
    "ensure it's depending on eq rather than equal"
    (let ([tqueue (new-tqueue)]
          [a (string-copy "a")]
          [b (string-copy "b")])
      (tqueue-add! tqueue a (list b))
      (tqueue-satisfy! tqueue (string-copy b))
      (check-eq? (tqueue-try-get tqueue) #f)))
   
   
   (test-case
    "'b' depends on 'a' and 'c'"
    (let ([tqueue (new-tqueue)])
      (tqueue-add! tqueue 'a '())
      (tqueue-add! tqueue 'c '())
      (tqueue-add! tqueue 'b '(a c))
      
      (check-eq? (tqueue-get tqueue) 'a)
      (check-eq? (tqueue-get tqueue) 'c)
      (check-false (tqueue-try-get tqueue))
      (tqueue-satisfy! tqueue 'a)
      (check-false (tqueue-try-get tqueue))
      (tqueue-satisfy! tqueue 'c)
      (check-eq? (tqueue-get tqueue) 'b)))
   
   
   (test-case
    "'b' depends on 'a' and 'c' again"
    (let ([tqueue (new-tqueue)])
      (tqueue-satisfy! tqueue 'a)
      (tqueue-satisfy! tqueue 'c)
      (tqueue-add! tqueue 'b '(a c))
      (check-eq? (tqueue-get tqueue) 'b)))))

(define (test)
  (run-tests test-topological-queue))

(test)