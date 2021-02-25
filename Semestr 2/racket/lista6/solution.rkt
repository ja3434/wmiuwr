#lang racket

(provide (struct-out complex) parse eval)

(struct complex (re im) #:transparent)

(define value?
  complex?)

(define (comp-plus x y)
  (let ((x-re (complex-re x))
        (x-im (complex-im x))
        (y-re (complex-re y))
        (y-im (complex-im y)))
    (complex (+ x-re y-re) (+ x-im y-im))))

(define (comp-minus x y)
  (let ((x-re (complex-re x))
        (x-im (complex-im x))
        (y-re (complex-re y))
        (y-im (complex-im y)))
    (complex (- x-re y-re) (- x-im y-im))))

(define (comp-mult x y)
  (let ((x-re (complex-re x))
        (x-im (complex-im x))
        (y-re (complex-re y))
        (y-im (complex-im y)))
    (complex (- (* x-re y-re) (* x-im y-im)) (+ (* x-re y-im) (* x-im y-re)))))

(define (comp-mod2 x)
  (let ((x-re (complex-re x))
        (x-im (complex-im x)))
    (complex (+ (* x-re x-re) (* x-im x-im)) 0)))

(define (comp-mod x)
  (let ((mod2 (comp-mod2 x))
        (x-re (complex-re x)))
    (complex (sqrt x-re) 0)))

(define (comp-div x y)
  (let* ((mod2 (complex-re (comp-mod2 y)))
        (x-re (complex-re x))
        (x-im (complex-im x))
        (y-re (complex-re y))
        (y-im (complex-im y))
        (real (+ (* x-re y-re) (* x-im y-im)))
        (imag (- (* x-im y-re) (* x-re y-im))))
    (complex (/ real mod2) (/ imag mod2))))
  

;; Ponizej znajduje sie interpreter zwyklych wyrazen arytmetycznych.
;; Zadanie to zmodyfikowac go tak, by dzialal z liczbami zespolonymi.

(struct const (val)    #:transparent)
(struct binop (op l r) #:transparent)

(define (imaginary-unit? c)
  (eq? c 'i))

(define (op->proc op)
  (match op ['+ comp-plus] ['- comp-minus] ['* comp-mult] ['/ comp-div]))

(define (eval e)
  (match e
    [(const n) n]
    [(binop op l r) ((op->proc op) (eval l) (eval r))]))

(define (parse q)
  (cond [(number? q) (const (complex q 0))]
        [(imaginary-unit? q) (const (complex 0 1))]
        [(and (list? q) (eq? (length q) 3) (symbol? (first q)))
         (binop (first q) (parse (second q)) (parse (third q)))]))