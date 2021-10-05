#lang racket

;; Oświadczam, że rozwiązanie zadania egzaminacyjnego przygotowałem
;; w pełni samodzielnie, korzystając wyłącznie z materiałów do wykładu,
;; notatek, podręcznika, oraz materiałów zacytowanych w treści rozwiązania.
;; Oświadczam że nie korzystałem w żadnej formie z pomocy osób trzecich
;; w przygotowaniu rozwiązania ani też takiej pomocy nie udzielałem
;; i nie udostępniałem nikomu swojego rozwiązania.

;; ZADANIE 2
;; =========

;; W tym zadaniu przyjrzymy się pierwszemu "językowi programowania"
;; który widzieliśmy na zajęciach: wyrażeniom arytmetycznym. Ich
;; prostota przejawia się przede wszystkim tym że nie występują w nich
;; zmienne (a w szczególności ich wiązanie) — dlatego możemy o nich
;; wnioskować nie używając narzędzi cięższych niż te poznane na
;; wykładzie.

;; W tym zadaniu będziemy chcieli udowodnić że nasza prosta kompilacja
;; do odwrotnej notacji polskiej jest poprawna. Konkretniej, należy
;; · sformułować zasady indukcji dla obydwu typów danych
;;   reprezentujących wyrażenia (expr? i rpn-expr?)
;; · sformułować i udowodnić twierdzenie mówiące że kompilacja
;;   zachowuje wartość programu, tj. że obliczenie wartości programu
;;   jest równoważne skompilowaniu go do RPN i obliczeniu.
;; · sformułować i udowodnić twierdzenie mówiące że translacja z RPN
;;   do wyrażeń arytmetycznych (ta która była zadaniem domowym;
;;   implementacja jest poniżej) jest (prawą) odwrotnością translacji
;;   do RPN (czyli że jak zaczniemy od wyrażenia i przetłumaczymy do
;;   RPN i z powrotem, to dostaniemy to samo wyrażenie).
;; Swoje rozwiązanie należy wpisać na końcu tego szablonu w
;; komentarzu, podobnie do niniejszej treści zadania; proszę zadbać o
;; czytelność dowodów!

(struct const (val) #:transparent)
(struct binop (op l r) #:transparent)

(define (operator? x)
  (member x '(+ * - /)))

(define (expr? e)
  (match e
    [(const v)
     (integer? v)]
    [(binop op l r)
     (and (operator? op)
          (expr? l)
          (expr? r))]
    [_ false]))


(define (value? v)
  (number? v))

(define (op->proc op)
  (match op
    ['+ +]
    ['- -]
    ['* *]
    ['/ /]))

;; zał: (expr? e) jest prawdą
;; (value? (eval e)) jest prawdą
(define (eval e)
  (match e
    [(const v) v]
    [(binop op l r)
     (let ((vl (eval l))
           (vr (eval r))
           (p  (op->proc op)))
       (p vl vr))]))

(define (rpn-expr? e)
  (and (list? e)
       (pair? e)
       (andmap (lambda (x) (or (number? x) (operator? x))) e)))

;; mój kod
(define (parse-expr q)
  (cond
    [(integer? q) (const q)]
    [(and (list? q) (= (length q) 3) (operator? (first q)))
     (binop (first q) (parse-expr (second q)) (parse-expr (third q)))]))

(struct stack (xs))

(define empty-stack (stack null))
(define (empty-stack? s) (null? (stack-xs s)))
(define (top s) (car (stack-xs s)))
(define (push a s) (stack (cons a (stack-xs s))))
(define (pop s) (stack (cdr (stack-xs s))))


(define (eval-am e s)
  (cond
   [(null? e)            (top s)]
   [(number? (car e))    (eval-am (cdr e) (push (car e) s))]
   [(operator? (car e))
    (let* ((vr (top s))
           (s  (pop s))
           (vl (top s))
           (s  (pop s))
           (v  ((op->proc (car e)) vl vr)))
      (eval-am (cdr e) (push v s)))]))

(define (rpn-eval e)
  (eval-am e empty-stack))

(define (arith->rpn e)
  (match e
    [(const v)      (list v)]
    [(binop op l r) (append (arith->rpn l) (arith->rpn r) (list op))]))

(define (rpn-translate e s)
  (cond
   [(null? e)
    (top s)]

   [(number? (car e))
    (rpn-translate (cdr e) (push (const (car e)) s))]

   [(operator? (car e))
    (let* ((er (top s))
           (s  (pop s))
           (el (top s))
           (s  (pop s))
           (en (binop (car e) el er)))
      (rpn-translate (cdr e) (push en s)))]))

(define (rpn->arith e)
  (rpn-translate e empty-stack))


;;  W kilku miejscach pozwoliłem sobie zapomnieć że symbol operatora i operator
;;  to nie to samo, ale nie ma to znaczenia w kontekście dowodów.
;;  Przez ES oznaczam empty-stack
;;
;;  Zasada indukcji dla expr:
;;  Dla dowolnej własności P, jeśli
;;  · zachodzi P((const x)) dla dowolnego x oraz
;;  · dla dowolnych e1, e2 oraz operator op jeśli zachodzi P(e1), P(e2) 
;;    to zachodzi P((binop op e1 e2))
;;  to dla dowolnego e, jeśli zachodzi (expr? e) to zachodzi P(e)
;;    
;;  Zasada indukcji dla rpn (ale tego wg rpn-expr?):
;;  Dla dowolnej własności P, jeśli
;;  · zachodzi P(x) dla dowolnej liczby lub opeartora x oraz
;;  · dla dowolnej listy liczb lub operatorów xs oraz dowolnej liczby lub
;;    operatora x, jesli zachodzi P(xs), to zachodzi P((cons x xs))
;;  to dla dowolnej listy xs liczb lub operatorów zachodzi P(xs)
;;
;;
;;  Tw. 1: Jeśli spełnione jest (expr? e), to (eval e) ≡ (rpn-eval (arith->rpn e))
;;
;;  D-d. Skorzystamy z zasady indukcji dla wyrażeń. 
;;  · Weźmy dowolną liczbę x. Wtedy jeśli e ≡ (const x), to zachodzi
;;    (eval (const x)) ≡ x ≡ (rpn-eval '(x)) ≡ (rpn-eval (arith->rpn (const x)))
;;  · Weźmy dowolne e1, e2 spełniające naszą tezę oraz jakiś operator op. Wtedy
;;    (eval (binop op e1 e2))  ≡
;;    (op (eval e1) (eval e2)) ≡                                                      [Z definicji eval-am]               
;;    (eval-am '() (push (op (eval e1) (eval e2)) ES)) ≡
;;    (eval-am '(op) (push (eval e2) (push (eval e1) ES))) ≡                          [Z założenia indukcyjnego]
;;    (eval-am '(op) (push (rpn-eval (arith->rpn e2)) (push (eval e1) ES))) ≡
;;    (eval-am (append (arith->rpn e2) '(op)) (push (eval e1) ES)) ≡                  [Z założenia indukcyjnego]
;;    (eval-am (append (arith->rpn e1) (arith->rpn e2) '(op)) ES) ≡
;;    (rpn-eval (append (arith->rpn e1) (arith->rpn e2) '(op))) ≡                     [Z definicji arith->rpn]
;;    (rpn-eval (arith->rpn (binop op e1 e2)))
;;  Pokazaliśmy oba warunki indukcji dla wyrażeń, zatem twierdzenie prawdziwe jest
;;  dla dowolnego wyrażenia e spełniającego (expr? e).
;;
;;  Tw. 2: Jeśli spełnione jest (expr? e), to (rpn->arith (arith->rpn e)) ≡ e
;;
;;  D-d. Skoryzstamy z indukcji dla wyrażeń.
;;  · Weźmy dowolną liczbę x. Wtedy dla e ≡ (const x) zachodzi
;;    (rpn->arith (arith->rpn e)) ≡ (rpn->arith '(x)) ≡ (const x)
;;  · Weźmy dowolne e1, e2 dla których twierdzenie zachodzi oraz operator op. Wtedy
;;    (rpn->arith (arith->rpn (binop op e1 e2))) ≡                                    [Z definicji arith->rpn]
;;    (rpn->arith (append (arith->rpn e1) (arith->rpn e2) '(op))) ≡
;;    (rpn-translate (append (arith->rpn e1) (arith->rpn e2) '(op)) ES) ≡             [Z zał. (arith->rpn e1) ewaluuje się do liczby]
;;    (rpn-translate (append (arith->rpn e2) '(op)) (push e1 ES)) ≡                   [Z zał. (arith->rpn e2) ewaluuje się do liczby]
;;    (rpn-translate '(op) (push e2 (push e1 ES))) ≡                                  [Z definicji rpn-translate]
;;    (rpn-translate '() (push (binop op e1 e2) ES)) ≡
;;    (binop op e1 e2)
;;  Pokazaliśmy oba warunki indukcji dla wyrażeń, zatem twierdzenie jest prawdziwe
;;  dla dowolnego e spełniającego (expr? e).
