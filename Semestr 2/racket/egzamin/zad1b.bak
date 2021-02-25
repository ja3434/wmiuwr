#lang racket

;; ZADANIE 1
;; =========

;; W tym zadaniu rozważamy język WHILE (w formie z grubsza
;; odpowiadającej tej z wykładu), z blokami deklarującymi zmienne o
;; lokalnym zakresie.

;; Zadanie polega na dodaniu do języka procedur definiowanych na
;; zewnątrz głównego polecenia programu (podobnie jak w C, gdzie
;; główne polecenie odpowiadałoby procedurze main, czy Pascalu) — o
;; dowolnym wybranym przez siebie modelu działania. W tym celu należy:
;; · rozszerzyć składnię abstrakcyjną o składnię procedur i rozbudować odpowiednio składnię programów
;; · rozszerzyć procedurę parsowania
;; · rozszerzyć ewaluator
;; · *opisać* wybrany model działania procedur, w tym jego potencjalne zalety lub ograniczenia
;; Należy rozszerzyć poniższy szablon, a część słowną zadania umieścić
;; w komentarzu, podobnie jak niniejsze polecenie.

;; Uwaga! Zadanie jest *bardzo* szeroko sformułowane, jest wiele
;; sensownych rozwiązań które stosowały liczne języki imperatywne w
;; historii — nie jest treścią zadania znalezienie *najlepszego*,
;; tylko swojego, które *rozumiecie*. Wybrany model działania procedur
;; *może* być relatywnie ubogi, jednak jeśli tak się zrobi, warto
;; pokazać że ma się tego świadomość w słownym opisie jego działania.

(struct const (val)           #:transparent)
(struct binop (op l r)        #:transparent)
(struct var-expr (name)       #:transparent)
(struct call-expr (name args) #:transparent)
(struct return-expr (val)     #:transparent)

(define (operator? x)
  (member x '(+ * - / > < = >= <=)))

(define (keyword? x)
  (member x '(skip while if := func call return)))

(define (expr? e)
  (match e
    [(const v)
     (integer? v)]
    [(var-expr x)
     (and (symbol? x)
          (not (keyword? x)))]
    [(binop op l r)
     (and (operator? op)
          (expr? l)
          (expr? r))]
    [_ false]))

(struct skip   ()                #:transparent)
(struct assign (id exp)          #:transparent)
(struct if-cmd (exp ct cf)       #:transparent)
(struct while  (exp cmd)         #:transparent)
(struct comp   (left right)      #:transparent)
(struct var-in (name expr cmd)   #:transparent)
(struct function (name args cmd) #:transparent)

(define (cmd? c)
  (match c
    [(skip) true]
    [(assign x e)  (and (symbol? x) (expr? e))]
    [(if-cmd e ct cf) (and (expr? e) (cmd? ct) (cmd? cf))]
    [(while e c)   (and (expr? e) (cmd? c))]
    [(comp c1 c2)  (and (cmd? c1) (cmd? c2))]
    [(var-in x e c) (and (symbol? x) (expr? e) (cmd? c))]
    [(function f a c) (and (symbol? f) (list? a) (andmap symbol? a) (cmd? c))]))

(define (prog? p)
  (cmd? p))

(define (parse-expr p)
  (cond
   [(number? p)    (const p)]
   [(and (symbol? p)
         (not (keyword? p)))
    (var-expr p)]
   [(and (list? p)
         (= 3 (length p))
         (operator? (car p)))
    (binop (first p)
           (parse-expr (second p))
           (parse-expr (third p)))]
   [(and (list? p)                           ; <------ wywołanie funkcji
         (= (length p) 3)
         (eq? (first p) 'call)
         (symbol? (second p))
         (list? (third p)))
    (call-expr (second p) (map parse-expr (third p)))]
   [else false]))

(define (parse-cmd q)
  (cond
   [(eq? q 'skip) (skip)]
   [(and (list? q)
         (= (length q) 3)
         (eq? (second q) ':=))
    (assign (first q) (parse-expr (third q)))]
   [(and (list? q)
         (= (length q) 4)
         (eq? (first q) 'if))
    (if-cmd (parse-expr (second q)) (parse-cmd (third q)) (parse-cmd (fourth q)))]
   [(and (list? q)
         (= (length q) 3)
         (eq? (first q) 'while))
    (while (parse-expr (second q)) (parse-cmd (third q)))]         
   [(and (list? q)
         (= (length q) 3)
         (eq? (first q) 'var)
         (list? (second q))
         (= (length (second q)) 2))
    (var-in (first (second q))
            (parse-expr (second (second q)))
            (parse-cmd (third q)))]
   [(and (list? q)                           ; <------ funkcje
         (= (length q) 4) 
         (eq? (first q) 'func)
         (symbol? (second q))
         (list? (third q))
         (andmap symbol? (third q)))
    (function (second q) (third q) (parse-cmd (fourth q)))]
   [(and (list? q)
         (= (length q) 2)
         (eq? (first q) 'return))
    (return-expr (parse-expr (second q)))]
   [(and (list? q)
         (>= (length q) 2))
    (desugar-comp (map parse-cmd q))]
   [else false]))

(define (desugar-comp cs)
  (if (null? (cdr cs))
      (car cs)
      (comp (car cs)
            (desugar-comp (cdr cs)))))

(define (value? v)
  (number? v))

(struct mem (xs) #:transparent)

(define (mem-lookup x m)
  (define (assoc-lookup xs)
    (cond
     [(null? xs) (error "Undefined variable" x)]
     [(eq? x (caar xs)) (cdar xs)]
     [else (assoc-lookup (cdr xs))]))
  (assoc-lookup (mem-xs m)))

(define (mem-defined? x m)         ; <----------- !!! Sprawdz, czy x jest w ogole zdefiniowane
  (define (assoc-lookup xs)
    (cond
      [(null? xs) #f]
      [(eq? x (caar xs) #t)]
      [else (assoc-lookup (cdr xs))]))
  (assoc-lookup (mem-xs m)))

(define (mem-update x v m)
  (define (assoc-update xs)
    (cond
     [(null? xs) (error "Undefined variable" x)]
     [(eq? x (caar xs)) (cons (cons x v) (cdr xs))]
     [else (cons (car xs) (assoc-update (cdr xs)))]))
  (mem (assoc-update (mem-xs m))))

(define (mem-alloc x v m)
  (mem (cons (cons x v) (mem-xs m))))

(define (mem-drop-last m)
  (cond
   [(null? (mem-xs m))
    (error "Deallocating from empty memory")]
   [else
    (mem (cdr (mem-xs m)))]))

(define empty-mem
  (mem null))

(define (op->proc op)
  (match op
    ['+ +]
    ['- -]
    ['* *]
    ['/ /]
    ['<  (lambda (x y) (if (< x y) 1 0))]
    ['>  (lambda (x y) (if (> x y) 1 0))]
    ['=  (lambda (x y) (if (= x y) 1 0))]
    ['<= (lambda (x y) (if (<= x y) 1 0))]
    ['>= (lambda (x y) (if (>= x y) 1 0))]
    ))

;; zał: (expr? e) i (mem? m) jest prawdą
;; (value? (eval e m)) jest prawdą
(define (eval e m)
  (match e
    [(const v) v]
    [(var-expr x)   (mem-lookup x m)]
    [(binop op l r)
     (let ((vl (eval l m))
           (vr (eval r m))
           (p  (op->proc op)))
       (p vl vr))]
    [(call-expr name args)
     (match (mem-lookup name m)
       [(clo func-args cmd)
        (if (= (length args) (length func-args))
            (let* ([func-mem (assign-values args func-args m)]
                   [final-mem (eval-cmd cmd func-mem)]
                   [ret (mem-lookup 'RETURN final-mem)])
              (if ret
                  ret
                  (error "No return statement in function" name)))
            (error "Arity mismatch, function" name "takes" (length func-args) ", got" (length args)))]
       [else (error "Undefined function" name)])]))

(define (assign-values args func-args mem)
  (define (iter args func-args new-mem)
    (if (null? args)
        new-mem
        (iter (cdr args) (cdr func-args) (mem-alloc (car func-args) (eval (car args) mem) new-mem))))
  (iter args func-args mem))


(struct clo (args cmd))

;; zał: (cmd? c) (mem? m)
;; (mem? (eval-cmd c m))
(define (eval-cmd c m)
  (if (mem-lookup 'RETURN m)
      m
      (match c
        [(skip)              m]
        [(assign x e)        (mem-update x (eval e m) m)]
        [(if-cmd e ct cf)    (if (= (eval e m) 0)
                                 (eval-cmd cf m)
                                 (eval-cmd ct m))]
        [(while e cw)        (if (= (eval e m) 0)
                                 m
                                 (let* ((m1 (eval-cmd cw m))
                                        (m2 (eval-cmd c m1)))
                                   m2))]
        [(comp c1 c2)        (let* ((m1 (eval-cmd c1 m))
                                    (m2 (eval-cmd c2 m1)))
                               m2)]
        [(var-in x e c)      (let* ((v  (eval e m))
                                    (m1 (mem-alloc x v m))
                                    (m2 (eval-cmd c m1)))
                               (mem-drop-last m2))]
        [(function name args cmd)
         (mem-alloc name (clo args cmd) m)]
        [(return-expr val)
         (mem-update 'RETURN (eval val m) m)]
        [_                   (error "Unknown command" c "— likely a syntax error")])))


(define (eval-prog p m)
  (let ((final-mem (eval-cmd p (mem-alloc 'RETURN #f m))))
    (with-handlers ([exn:fail? (lambda (v) (error "Undefined reference to main"))])
      (match (mem-lookup 'main final-mem)
        [(clo args cmd) (mem-lookup 'RETURN (eval-cmd cmd final-mem))]))))

(define WHILE_FACT
  '({func decr (x)
     {(x := (- x 1))
     (return x)}}
    {func main ()
    {(i := 1)
     (while (> t 0)
            {(i := (* i t))
             (t := (call decr (t)))})
     (return i)}}
    ))

(define (fact n)
  (let* ([init-env  (mem-alloc 'i 1 (mem-alloc 't n empty-mem))])
         (eval-prog (parse-cmd WHILE_FACT) init-env)))

(define TEST
  '({func decr (x) (return (- x 1))}
    {func main ()
          (var (x 1)
                {(x := (+ x 1))
                 (return (call decr (x)))})}))

(define TEST2
  '({func decr (x) (return (- x 1))}
    {func main () (return (call decr (3)))}))

(define TEST3
  '({func sth (x)
          {(i := -1)
           (return x)}}
    {func main ()
          {(i := 2)
           (return (call sth (i)))}}))

(define TEST4
  '(func f ()
          {return 1}))

(define TEST5
  '({func f1 (x y z)
          (return y)}
    {func f2 (x y z)
          (return (+ (+ x y) z))}
    {func main ()
          {(if (> 4 3)
              (var (x 2)
                   (return (call f1 (1 x 3))))
              (x := 5))
          (return (call f2 (x 3 4)))}}))
    