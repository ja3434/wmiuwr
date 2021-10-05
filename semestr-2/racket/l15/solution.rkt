#lang racket

(provide philosopher)

;; Do debugu

(define (run-concurrent . thunks)
  (define threads (map thread thunks))
  (for-each thread-wait threads))

(define (random-sleep)
  (sleep (/ (random) 100)))

(define (with-random-sleep proc)
  (lambda args
    (random-sleep)
    (apply proc args)))

(define (make-serializer)
  (define sem (make-semaphore 1))
  (lambda (proc)
    (lambda args
      (semaphore-wait sem)
      (define ret (apply proc args))
      (semaphore-post sem)
      ret)))

(define (make-table)
  (define forks (map (lambda (x) (make-semaphore 1)) '(0 1 2 3 4)))
  (define (get-fork i)
    (list-ref forks i))
  (define (pick-fork i)
    (random-sleep)
    (semaphore-wait (get-fork i)))
  (define (put-fork i)
    (random-sleep)
    (semaphore-post (get-fork i)))
  (define (dispatch m)
    (cond [(eq? m 'pick-fork) pick-fork]
          [(eq? m 'put-fork) put-fork]
          [else (error "Unknown request -- MAKE-TABLE" m)]))
  dispatch)

;(define dining-table (make-table))

;(define (repeat proc n)
;  (if (> n 0)
;      (begin
;        (proc)
;        (repeat proc (- n 1)))
;      #f))
;
;(define (hungry nr x)
;  (lambda () (repeat (lambda () (philosopher dining-table nr)) x)))

;; Rozwiązanie:

(define forks-sem (map (lambda (x) (make-semaphore 1)) '(0 0 0 0 0)))

(define (get-fork i)
  (list-ref forks-sem i))

(define (is-free? i)
  (semaphore-try-wait? (get-fork i)))

(define (put-fork dining-table i)
  ((dining-table 'put-fork) i)
  (semaphore-post (get-fork i)))

(define (philosopher dining-table i)
  (define left-fork i)
  (define right-fork (modulo (+ i 1) 5))
  (define (loop)
    (if (is-free? left-fork)
        (if (is-free? right-fork)
            (begin
              ((dining-table 'pick-fork) left-fork)
              ((dining-table 'pick-fork) right-fork)
              (put-fork dining-table left-fork)
              (put-fork dining-table right-fork))
            (loop))
        (begin
          (semaphore-post (get-fork left-fork))
          (loop))))
  (loop))