#lang racket

(require "graph.rkt")
(provide bag-stack@ bag-fifo@)

;; struktura danych - stos
(define-unit bag-stack@
  (import)
  (export bag^)

  (define (bag? b)
    (and (cons? b)
         (eq? (car b) 'stack)))

  (define empty-bag (cons 'stack null))
  
  (define (bag-empty? b)
    (null? (cdr b)))

  (define (bag-insert b val)
    (cons 'stack (cons val (cdr b))))

  (define (bag-peek b)
    (cadr b))
  
  (define (bag-remove b)
    (cons 'stack (cddr b)))
)

;; struktura danych - kolejka FIFO
(define-unit bag-fifo@
  (import)
  (export bag^)

  (define (bag? b)
    (and (list? b)
         (eq? (length b) 3)
         (eq? (first b) 'queue)))

  (define empty-bag
    (list 'queue null null))

  (define (bag-empty? b)
    (and (null? (second b)) (null? (third b))))

  (define (bag-insert b val)
    (list 'queue (cons val (second b)) (third b)))

  (define (bag-peek b)
    (let ((insq (second b))
          (popq (third b)))
      (cond
        [(null? popq) (last insq)]
        [else (first popq)])))

  (define (bag-remove b)
    (let ((insq (second b))
          (popq (third b)))
      (cond
        [(null? popq) (list 'queue null (cdr (reverse insq)))]
        [else (list 'queue insq (cdr popq))])))
)

;; otwarcie komponentów stosu i kolejki

(define-values/invoke-unit bag-stack@
  (import)
  (export (prefix stack: bag^)))

(define-values/invoke-unit bag-fifo@
  (import)
  (export (prefix fifo: bag^)))

;; testy w Quickchecku
(require quickcheck)

;; liczba zapytań na test quickchecka
(define TESTS 1000)


;; TESTY DO KOLEJKI

;; xs to lista jakichś liczb, queries to rodzaj wykonywanych operacji
;; 0 - popuje na listę pops
;; 1 - insertuje na queue
;; jest nie ma nic na kolejce/stosie i dostajemy 0, to nic nie robimy
;; jesli queries albo xs są puste to po prostu kończymy obsługiwanie zapytań
;; na koncu sprawdzamy, czy (reverse pops) jest prefiksem xs


(define (check-queue xs queries)
  (define (iter xs queries queue pops)
    ;; (display queue)
    ;; (newline)
    (if (or (null? queries) (null? xs))
        (reverse pops)
        (cond
          [(and (eq? (car queries) 0) (not (fifo:bag-empty? queue)))
           (iter xs (cdr queries) (fifo:bag-remove queue) (cons (fifo:bag-peek queue) pops))]
          [else (iter (cdr xs) (cdr queries) (fifo:bag-insert queue (car xs)) pops)])))
  (define (is-prefix? xs ys)
    (if (null? xs)
        #t
        (and (equal? (car xs) (car ys)) (is-prefix? (cdr xs) (cdr ys)))))
  (is-prefix? (iter xs queries fifo:empty-bag null) xs))

;; sprawdzenie czy nasza funkcja testująca w ogóle działa
(define check-queue-test (lambda () (check-queue (list 1 2 3 4 5 6 7 8) (list 0 1 1 1 0 0 0 1 1 0 1 0 1 0 0))))

;; testowanie kolejki
(define-unit queue-tests@
  (import bag^)
  (export)

  (quickcheck
   (property ([xs (choose-list (choose-real -100000 100000) TESTS)]
              [ops (choose-list (choose-integer 0 1) TESTS)])
             (check-queue xs ops))))

(invoke-unit queue-tests@ (import (prefix fifo: bag^)))


;; TESTY DO STOSU

;; niestety tutaj nie jest tak kolorowo, na kolejce
;; dokładnie wiemy jaka jest koljeność popowanych, na stosie to dosyć dowolne.
;; Z drugiej strony jego implementacja jest dużo prostsza, więc testy też nie muszą
;; być bardzo rygorystyczne.

(define (check-stack xs)
  (define (insert-list stack xs)
    (if (null? xs)
        stack
        (insert-list (stack:bag-insert stack (car xs)) (cdr xs))))
  (define (clear-stack stack pops)
    (if (stack:bag-empty? stack)
        pops
        (clear-stack (stack:bag-remove stack) (cons (stack:bag-peek stack) pops))))
  (equal? xs (clear-stack (insert-list stack:empty-bag xs) null)))


;; testowanie stacka
(define-unit stack-tests@
  (import bag^)
  (export)
  (quickcheck
   (property ([xs (choose-list (choose-real -100000 100000) TESTS)])
             (check-stack xs))))

(invoke-unit stack-tests@ (import (prefix stack: bag^)))



;; testy kolejek i stosów
(define-unit bag-tests@
  (import bag^)
  (export)
  
  ;; test przykładowy: jeśli do pustej struktury dodamy element
  ;; i od razu go usuniemy, wynikowa struktura jest pusta
  (quickcheck
   (property ([s arbitrary-symbol])
             (bag-empty? (bag-remove (bag-insert empty-bag s)))))

  ;; Sprawdzenie własności wspólnych dla obu struktur
  (quickcheck
   (property ([s arbitrary-symbol])
             (equal? s (bag-peek (bag-insert empty-bag s)))))          
)

;; uruchomienie testów dla obu struktur danych

(invoke-unit bag-tests@ (import (prefix stack: bag^)))
(invoke-unit bag-tests@ (import (prefix fifo: bag^)))



;; TESTOWANIE PRZESZUKIWAŃ

;; otwarcie komponentu grafu
(define-values/invoke-unit/infer simple-graph@)

;; otwarcie komponentów przeszukiwania 
;; w głąb i wszerz
(define-values/invoke-unit graph-search@
  (import graph^ (prefix stack: bag^))
  (export (prefix dfs: graph-search^)))

(define-values/invoke-unit graph-search@
  (import graph^ (prefix fifo: bag^))
  (export (prefix bfs: graph-search^)))

;; graf testowy
(define test-graph
  (graph
   (list 1 2 3 4)
   (list (edge 1 3)
         (edge 1 2)
         (edge 2 4)))) 

(define test-graph2
  (graph (list 1) null))

(define test-graph3
  (graph (list 1 2 3 4 5 6 7 8 9 10)
         (list (edge 1 2)
               (edge 1 3)
               (edge 2 3)
               (edge 3 2)
               (edge 3 5)
               (edge 6 5)
               (edge 5 7)
               (edge 5 8)
               (edge 7 9)
               (edge 8 9)
               (edge 9 10)
               (edge 1 10)
               (edge 10 1))))
 

(define test-graph4
  (graph (list 1 2 3 4 5 6)
         (list (edge 1 2)
               (edge 2 3)
               (edge 3 4)
               (edge 4 5)
               (edge 5 6))))

;; uruchomienie przeszukiwania na przykładowym grafie
(bfs:search test-graph 1)
(dfs:search test-graph 1)

(bfs:search test-graph2 1)
(dfs:search test-graph2 1)

(bfs:search test-graph3 1)
(dfs:search test-graph3 1)

(bfs:search test-graph3 6)
(dfs:search test-graph3 6)

(bfs:search test-graph4 1)
(dfs:search test-graph4 1)


