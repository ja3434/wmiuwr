#lang racket

(provide (struct-out const) (struct-out binop) (struct-out var-expr) (struct-out let-expr) (struct-out var-dead) find-dead-vars)


; --------- ;
; Wyrazenia ;
; --------- ;

(struct const    (val)      #:transparent)
(struct binop    (op l r)   #:transparent)
(struct var-expr (id)       #:transparent)
(struct var-dead (id)       #:transparent)
(struct let-expr (id e1 e2) #:transparent)

(define (expr? e)
  (match e
    [(const n) (number? n)]
    [(binop op l r) (and (symbol? op) (expr? l) (expr? r))]
    [(var-expr x) (symbol? x)]
    [(var-dead x) (symbol? x)]
    [(let-expr x e1 e2) (and (symbol? x) (expr? e1) (expr? e2))]
    [_ false]))

(define (parse q)
  (cond
    [(number? q) (const q)]
    [(symbol? q) (var-expr q)]
    [(and (list? q) (eq? (length q) 3) (eq? (first q) 'let))
     (let-expr (first (second q))
               (parse (second (second q)))
               (parse (third q)))]
    [(and (list? q) (eq? (length q) 3) (symbol? (first q)))
     (binop (first q)
            (parse (second q))
            (parse (third q)))]))

; ---------------------------------- ;
; Wyszukaj ostatnie uzycie zmiennych ;
; ---------------------------------- ;

(struct environ (xs))

(define env-empty (environ null))
(define (env-add x v env)
  (environ (cons (cons x v) (environ-xs env))))
(define (env-lookup x env)
  (define (assoc-lookup xs)
    (cond [(null? xs) (error "unbound identifier" x)]
          [(eq? x (car (car xs))) (cdr (car xs))]
          [else (assoc-lookup (cdr xs))]))
  (assoc-lookup (environ-xs env)))
(define (env-erase x env)
  (define (assoc-lookup xs)
    (cond [(null? xs) (error "unbound identifier" x)]
          [(eq? x (caar xs)) (cdr xs)]
          [else (cons (car xs) (assoc-lookup (cdr xs)))]))
  (if (env-lookup x env)
      (environ (assoc-lookup (assoc-lookup (environ-xs env))))
      (environ (assoc-lookup (environ-xs env)))))


(define (find-dead-vars-env e env)
  (match e
    [(const r) (cons (const r) env)]
    [(var-expr x) (if (env-lookup x env)
                     (cons (var-expr x) env)
                     (cons (var-dead x) (env-add x true env)))]
    [(binop op l r) (let* ((right-expr (find-dead-vars-env r env))
                           (r (car right-expr))
                           (env (cdr right-expr))
                           (left-expr (find-dead-vars-env l env))
                           (l (car left-expr))
                           (env (cdr left-expr)))
                        (cons (binop op l r) env))]
    [(let-expr x e1 e2) (let* ((right-expr (find-dead-vars-env e2 (env-add x false env)))
                               (e2 (car right-expr))
                               (env (env-erase x (cdr right-expr)))
                               (left-expr (find-dead-vars-env e1 env))
                               (e1 (car left-expr))
                               (env (cdr left-expr)))
                            (cons (let-expr x e1 e2) env))]))

(define (find-dead-vars e)
  (car (find-dead-vars-env e env-empty)))


(define (sample2) (find-dead-vars (let-expr 'x (const 3)
                                      (binop '+ (var-expr 'x)
                                      (let-expr 'x (const 5) (binop '+ (var-expr 'x) (var-expr 'x)))))))

(define (test1) (find-dead-vars (parse '(let (x 3) (let (x (* x (+ x x))) (+ x x))))))
(define (test2) (find-dead-vars (parse '(let (x 2) (let [x (let [x (+ x 2)] x)] x)))))
(define (test3) (find-dead-vars (parse '(let [x 2] (+ (let [x (+ 2 x)] (* 3 x)) x)))))
(define (test4) (find-dead-vars (parse '(let [x 2] (let [x (+ x 3)] (* x x))))))
(define (test5) (find-dead-vars (parse '(let [x 2] (+ x (let [x (+ 2 x)] x))))))
(define (test6) (find-dead-vars (parse '(let [x 2] 
                                             (let [y (let [x (* x (+ x x))] 
                                                          (let [y (* x x)] 
                                                               (+ y 2)))] 
                                             (+ x (* y y)))))))
(define (test7) (find-dead-vars (parse '(let [x (let [x (let [x 2] (+ x x))] (+ x x))] (+ x x)))))
;;; (define (test7) (find-dead-vars (parse '(let [x (let [x (let [x 2] (let (x 2) (+ x x)))] (+ x x))] (+ x x)))))
(define (test8) (find-dead-vars (parse '(let [x 2] (let [x 2] (+ x x))))))