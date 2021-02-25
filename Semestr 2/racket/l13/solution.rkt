#lang typed/racket

; --------- ;
; Wyrazenia ;
; --------- ;

(provide parse typecheck)

(define-type Expr (U const binop var-expr let-expr if-expr))
(define-type Value (U Real Boolean))
(define-type ArithOp (U '+ '- '/ '* '%))
;;; (define-type ModOp '%)
(define-type CompOp (U '= '> '>= '< '<=))
(define-type LogicOp (U 'and 'or))
(define-type BinopSym (U ArithOp CompOp LogicOp))

(struct const    ([val : Value])                          #:transparent)
(struct binop    ([op : BinopSym] [l : Expr] [r : Expr])  #:transparent)
(struct var-expr ([id : Symbol])                          #:transparent)
(struct let-expr ([id : Symbol] [e1 : Expr] [e2 : Expr])  #:transparent)
(struct if-expr  ([eb : Expr] [et : Expr] [ef : Expr])    #:transparent)

(define-predicate expr? Expr)
(define-predicate value? Value)
(define-predicate arith-op? ArithOp)
;;; (define-predicate mod-op? ModOp)
(define-predicate comp-op? CompOp)
(define-predicate logic-op? LogicOp)
(define-predicate binop-sym? BinopSym)
(define-predicate let-list? (List Symbol Any))

(: parse (-> Any Expr))
(define (parse q)
  (match q
    [_ #:when (value? q) (const q)]
    [_ #:when (eq? q 'true) (const true)] 
    [_ #:when (eq? q 'false) (const false)] ; <---------------------------- !!!
    [_ #:when (symbol? q) (var-expr q)]
    [`(,s ,e1 ,e2)
      #:when (and (eq? s 'let) (let-list? e1))
      (let-expr (car e1)
                (parse (cadr e1))
                (parse e2))]
    [`(,s ,eb ,et ,ef)
      #:when (eq? s 'if)
     (if-expr (parse eb)
              (parse et)
              (parse ef))]
    [`(,s ,e1 ,e2)
      #:when (binop-sym? s)
     (binop s
            (parse e1)
            (parse e2))]
    [else (error "Parse error" q)]))

; ---------- ;
; Srodowiska ;
; ---------- ;

(define-type EType (U 'real 'boolean))
(define-predicate EType? EType)

(struct environ ([xs : (Listof (Pairof Symbol EType))]))
(define env-empty (environ null))

(: env-add (-> Symbol EType environ environ))
(define (env-add x v env)
  (environ (cons (cons x v) (environ-xs env))))

(: env-lookup (-> Symbol environ EType))
(define (env-lookup x env) 
  (: assoc-lookup (-> (Listof (Pairof Symbol EType)) EType))
  (define (assoc-lookup xs)
    (cond [(null? xs) (error "Unknown identifier" x)]
          [(eq? x (car (car xs))) (cdr (car xs))]
          [else (assoc-lookup (cdr xs))]))
  (assoc-lookup (environ-xs env)))

(: check-op (-> Expr Expr EType EType environ (U EType #f)))
(define (check-op e1 e2 arg-type ret-type env)
  (if (and (eq? (typecheck-env e1 env) arg-type)
           (eq? (typecheck-env e2 env) arg-type))
      ret-type
      #f))

(: typecheck-env (-> Expr environ (U EType #f)))
(define (typecheck-env e env)
  (match e
    [(const val) 
      (cond
        [(real? val)    'real]
        [(boolean? val) 'boolean])]
    [(var-expr id) (env-lookup id env)]
    [(binop op e1 e2)
      (cond 
        [(arith-op? op) (check-op e1 e2 'real 'real env)]
        [(comp-op? op)  (check-op e1 e2 'real 'boolean env)]
        [(logic-op? op) (check-op e1 e2 'boolean 'boolean env)])]
    [(let-expr id e1 e2)
      (let ((id-type (typecheck-env e1 env)))
        (if id-type
            (typecheck-env e2 (env-add id id-type env))
            #f))]
    [(if-expr eb et ef)
      (let ((eb-type (typecheck-env eb env)))
        (if (not (eq? eb-type 'boolean))
            #f
            (let ((et-type (typecheck-env et env))
                  (ef-type (typecheck-env ef env)))
              (if (eq? et-type ef-type)   ;;; nie trzeba sprawdzac czy ktores z nich to #f
                  et-type                 ;;; jesli tak jest, to i tak sie na pewno zwroci #f    
                  #f))))]))

(: typecheck (-> Expr (U EType #f)))
(define (typecheck e)
  (typecheck-env e env-empty))

(define program
  '(if (or (< (% 123 10) 5)
           true)
       (+ 2 3)
       (/ 2 0)))

(define (test-eval) (eval (parse program)))