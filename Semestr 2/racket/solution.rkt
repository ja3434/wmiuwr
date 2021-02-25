#lang racket

(provide heapsort) (require "leftist.rkt")

(define (heapsort xs)
  (define (create-heap xs res)
    (if (null? xs)
        res
        (create-heap (cdr xs) (heap-insert (cons (car xs) (car xs)) res))))
  (define (heap-to-list h)
    (if (heap-empty? h)
        null
        (cons (elem-val (heap-min h)) (heap-to-list (heap-pop h)))))
  (heap-to-list (create-heap xs empty-heap)))