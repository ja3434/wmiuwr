#lang typed/racket

; Do let-env.rkt dodajemy wartosci boolowskie
;
; Miejsca, ktore sie zmienily oznaczone sa przez !!!

; --------- ;
; Wyrazenia ;
; --------- ;
(provide parse typecheck)

(define-type Value (U Boolean Real))
(define-type Expr (U const binop var-expr let-expr if-expr))
(define-type ArithSymbol (U '+ '- '* '/))
(define-type LogicSymbol (U 'and 'or))
(define-type CompSymbol (U '< '= '> '<= '>=))
(define-type BinomSymbol (U ArithSymbol LogicSymbol CompSymbol))

(define-type Binop-list (List BinomSymbol Any Any))
(define-type Let-list (List 'let (List Symbol Any) Any))
(define-type If-list (List 'if Any Any Any))

(define-predicate Binop-list? Binop-list)
(define-predicate Let-list? Let-list)
(define-predicate If-list? If-list)

(struct const    ([val : Value])      #:transparent)
(struct binop    ([op : BinomSymbol] [l : Expr] [r : Expr])   #:transparent)
(struct var-expr ([id : Symbol])       #:transparent)
(struct let-expr ([id : Symbol] [e1 : Expr] [e2 : Expr]) #:transparent)
(struct if-expr  ([eb : Expr] [et : Expr] [ef : Expr]) #:transparent)

(define-predicate Value? Value)
(define-predicate Expr? Expr)
(define-predicate BinomSymbol? BinomSymbol)
(define-predicate ArithSymbol? ArithSymbol)
(define-predicate LogicSymbol? LogicSymbol)
(define-predicate CompSymbol? CompSymbol)
(define-predicate BinomValue? BinomValue)



(: parse (-> Any Expr))
(define (parse q)
  (cond
    [(real? q) (const q)]
    [(eq? q 'true)  (const true)]  ; <---------------------------- !!!
    [(eq? q 'false) (const false)] ; <---------------------------- !!!
    [(symbol? q) (var-expr q)]
    [(Let-list? q)
     (let-expr (first (second q))
               (parse (second (second q)))
               (parse (third q)))]
    [(If-list? q) ; <--- !!!
     (if-expr (parse (second q))
              (parse (third q))
              (parse (fourth q)))]
    [(Binop-list? q)
     (binop (first q)
            (parse (second q))
            (parse (third q)))]
    [else (error "Blad parsowania" q)]))

   


(define (test-parse) (parse '(let [x (+ 2 2)] (+ x 1))))

; ---------- ;
; Srodowiska ;
; ---------- ;
(define-type EType ( U 'real 'boolean ) )
(define-type Env (Listof (Pairof Symbol EType)))
(define-predicate Env? Env)
(struct environ ([xs : Env]))

(: env-empty environ)
(define env-empty (environ null))
(: env-add (-> Symbol EType environ environ))
(define (env-add x v env)
  (environ (cons (cons x v) (environ-xs env))))
(: env-lookup (-> Symbol environ (U EType #f)))
(define (env-lookup x env)
  (: assoc-lookup (-> Env EType))
  (define (assoc-lookup xs)
    (cond [(null? xs) (error "Unknown identifier" x)]
          [(eq? x (car (car xs))) (cdr (car xs))]
          [else (assoc-lookup (cdr xs))]))
  (assoc-lookup (environ-xs env)))


(: typecheck (-> Expr (U EType #f)))
(define (typecheck q)
  (: give (-> Expr environ (U EType #f)))
  (define (give q envi)
  (cond
    [(const? q) (if (boolean? (const-val q)) 'boolean 'real)]
    [(var-expr? q) (env-lookup (var-expr-id q) envi)]
    [(let-expr? q)
     (let ([p (give (let-expr-e1 q) envi)]) (if (false? p) #f (give (let-expr-e2 q) (env-add (let-expr-id q) p envi))))]
    [(binop? q)
     (cond
       ([ArithSymbol? (binop-op q)] (if (and (eq? 'real (give (binop-l q) envi)) (eq? 'real (give (binop-r q) envi))) 'real #f))
       ([LogicSymbol? (binop-op q)] (if (and (eq? 'boolean (give (binop-l q) envi)) (eq? 'boolean (give (binop-r q) envi))) 'boolean #f))
       ([CompSymbol? (binop-op q)] (if (and (eq? 'real (give (binop-l q) envi)) (eq? 'real (give (binop-r q) envi))) 'boolean #f))
       [else #f])]
    [(if-expr? q)
     (if (and (eq? 'real (if-expr-eb q)) 
              (eq? (give (if-expr-et q) envi) (give (if-expr-ef q) envi))) 
         (give (if-expr-et q) envi) 
         #f)]
    [else #f]))


  (give q env-empty))



(define program2
  '(if true
       (let [x 5] (+ 5 false))
       (/ 2 2)))

(define program3
  '(let [x (+ 2 3)]
     (let [y (< 2 3)]
       (+ x y))))

(define program4
  '(let [x (and true true)] x))

(define wtf
  '(and true true))

(typecheck (parse program2))
(typecheck (parse program3))
(typecheck (parse program4))
