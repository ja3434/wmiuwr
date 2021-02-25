#lang typed/racket


;;; zadanie 1

(: prefixes (All (a) (-> (Listof a) (Listof (Listof a)))))
(define (prefixes xs)
  (if (null? xs)
      (list null)
      (cons xs (prefixes (cdr xs)))))



;;; zadanie 2

(struct vector2 ([x : Real] [y : Real])             #:transparent)
(struct vector3 ([x : Real] [y : Real] [z : Real])  #:transparent)

(define-type Vector (U vector2 vector3))
(define-predicate vector? Vector)


(: square (-> Real Nonnegative-Real))
(define (square x)
  (if (< x 0) (* x x) (* x x)))


;;; pierwsza wersja

(: vector-length (-> Vector Nonnegative-Real))
(define (vector-length v)
  (if (vector2? v)
      (match v [(vector2 x y) (sqrt (+ (square x) (square y)))])
      (match v [(vector3 x y z) (sqrt (+ (square x) (square y) (square z)))])))


;;; druga wersja

(: vector-length-match (-> Vector Nonnegative-Real))
(define (vector-length-match v)
  (match v
    [(vector2 x y) (sqrt (+ (square x) (square y)))]
    [(vector3 x y z) (sqrt (+ (square x) (square y) (square z)))]))



;;; zadanie 4

(struct leaf () #:transparent)
(struct [a] node ([v : a] [xs : (Listof (Tree a))]) #:transparent)

(define-type (Tree a) (node a))
(define-predicate tree? (Tree Any))


(: flat-map (All (a) (-> (-> (Tree a) (Listof a)) (Listof (Tree a)) (Listof a))))
(define (flat-map f xs)
  (if (null? xs)
      null
      (append (f (car xs)) (flat-map f (cdr xs)))))

(: preorder (All (a) (-> (Tree a) (Listof a))))
(define (preorder t)
  (match t
    [(node v xs)
     (cons v (flat-map preorder xs))]))

;;;  (preorder (node 1 (list 
;;;                     (node 2 (list 
;;;                               (node 3 '()) 
;;;                               (node 4 '()))) 
;;;                     (node 5 '()) 
;;;                     (node 'x (list 
;;;                               (node 't (list 
;;;                                           (node 'z '()))))))))


;;; zadanie 6

