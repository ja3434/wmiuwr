#lang typed/racket

; Do let-env.rkt dodajemy wartosci boolowskie
;
; Miejsca, ktore sie zmienily oznaczone sa przez !!!

; --------- ;
; Wyrazenia ;
; --------- ;

(define-type Expr (U const binop var-expr let-expr if-expr))
(define-type Value (U Real Boolean))
(define-type BinopSym (U '+ '- '/ '* '% '= '> '>= '< '<= 'and 'or))

(struct const    ([val : Value])                          #:transparent)
(struct binop    ([op : BinopSym] [l : Expr] [r : Expr])  #:transparent)
(struct var-expr ([id : Symbol])                          #:transparent)
(struct let-expr ([id : Symbol] [e1 : Expr] [e2 : Expr])  #:transparent)
(struct if-expr  ([eb : Expr] [et : Expr] [ef : Expr])    #:transparent)


(define-predicate expr? Expr)
(define-predicate value? Value)
(define-predicate binop-sym? BinopSym)
(define-predicate let-list? (List Symbol Any))

(: parse (-> Any Expr))
(define (parse q)
  (match q
    [_ #:when (value? q) (const  q)]
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

;;; (define (test-parse) (parse '(let [x (+ 2 2)] (+ x 1))))

; ---------- ;
; Srodowiska ;
; ---------- ;

(struct environ ([xs : (Listof (Pairof Symbol Value))]))
(define env-empty (environ null))

(: env-add (-> Symbol Value environ environ))
(define (env-add x v env)
  (environ (cons (cons x v) (environ-xs env))))

(: env-lookup (-> Symbol environ Value))
(define (env-lookup x env) 
  (: assoc-lookup (-> (Listof (Pairof Symbol Value)) Value))
  (define (assoc-lookup xs)
    (cond [(null? xs) (error "Unknown identifier" x)]
          [(eq? x (car (car xs))) (cdr (car xs))]
          [else (assoc-lookup (cdr xs))]))
  (assoc-lookup (environ-xs env)))

; --------- ;
; Ewaluacja ;
; --------- ;

(: arith-op (-> (-> Real Real Real) (-> Value Value Value)))
(define (arith-op op)
  (lambda (x y) (if (and (real? x) (real? y))
                    (ann (op x y) Value)
                    (error "Wrong args for arithmetic operator" op x y))))

(: mod-op (-> (-> Integer Integer Integer) (-> Value Value Value)))
(define (mod-op op)
  (lambda (x y) (if (and (exact-integer? x) (exact-integer? y))
                    (ann (op x y) Value)
                    (error "Wrong args for modulo operator" op x y))))

(: logic-op (-> (-> Boolean Boolean Boolean) (-> Value Value Value)))
(define (logic-op op)
  (lambda (x y) (if (and (boolean? x) (boolean? y))
                    (ann (op x y) Value)
                    (error "Wrong args for logic operator" op x y))))

(: comp-op (-> (-> Real Real Boolean) (-> Value Value Value)))
(define (comp-op op)
  (lambda (x y) (if (and (real? x) (real? y))
                    (ann (op x y) Value)
                    (error "Wrong args for comparator" op x y))))


(: op->proc (-> BinopSym (-> Value Value Value)))
(define (op->proc op)
  (match op ['+ (arith-op +)] ['- (arith-op -)] ['* (arith-op *)] ['/ (arith-op /)] 
            ['% (mod-op modulo)]
            ['= (comp-op =)] ['> (comp-op >)] ['>= (comp-op >=)] ['< (comp-op <)] ['<= (comp-op <=)]
            ['and (logic-op (lambda (x y) (and x y)))]
            ['or  (logic-op (lambda (x y) (or  x y)))]))

(: eval-env (-> Expr environ Value))
(define (eval-env e env)
  (match e
    [(const n) n]
    [(binop op l r) ((op->proc op) (eval-env l env)
                                   (eval-env r env))]
    [(let-expr x e1 e2)
     (eval-env e2 (env-add x (eval-env e1 env) env))]
    [(var-expr x) (env-lookup x env)]
    [(if-expr eb et ef) (if (eval-env eb env) ; <----------------- !!!
                            (eval-env et env)
                            (eval-env ef env))]))

(: eval (-> Expr Value))
(define (eval e) (eval-env e env-empty))

(define program
  '(if (or (< (% 123 10) 5)
           true)
       (+ 2 3)
       (/ 2 0)))

;;; (define (test-eval) (eval (parse program)))