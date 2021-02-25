#lang racket

(provide (contract-out
           [with-labels with-labels/c]
           [foldr-map foldr-map/c]
           [pair-from pair-from/c]))
(provide with-labels/c foldr-map/c pair-from/c)


(define with-labels/c (parametric->/c [a b] (-> (-> a b) (listof a) (listof (cons/c b (cons/c a null?))))))

(define (with-labels f xs)
  (if (null? xs)
      null
      (cons (list (f (car xs)) (car xs)) (with-labels f (cdr xs)))))



(define foldr-map/c (parametric->/c [x a f] (-> (-> x a (cons/c f a)) a (listof x) (cons/c (listof f) a))))

(define (foldr-map f a xs)
  (define (it a xs ys)
    (if (null? xs)
        (cons ys a)
        (let [(p (f (car xs) a))]
          (it (cdr p)
              (cdr xs)
              (cons (car p) ys)))))
  (it a (reverse xs) null))


(define pair-from/c (parametric->/c [x fx gx] (-> (-> x fx) (-> x gx) (-> x (cons/c fx gx)))))

(define (pair-from f g)
  (lambda (x) (cons (f x) (g x))))