#lang racket



;; Oświadczam, że rozwiązanie zadania egzaminacyjnego przygotowałem
;; w pełni samodzielnie, korzystając wyłącznie z materiałów do wykładu,
;; notatek, podręcznika, oraz materiałów zacytowanych w treści rozwiązania.
;; Oświadczam że nie korzystałem w żadnej formie z pomocy osób trzecich
;; w przygotowaniu rozwiązania ani też takiej pomocy nie udzielałem
;; i nie udostępniałem nikomu swojego rozwiązania.

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







;; Postanowiłem, że struktura programów w moim języku będzie miała trochę z pythona i trochę z C.
;; Istotną decyzją którą podjąłem jest to, że wszystkie funkcje w naszym języku muszą zwracać
;; jakąś wartość (zawsze zwracają inta), łącznie z funkcją main, przy pomocy dyrektywy "return".
;; To, co zwraca main, jest tym co zwraca
;; cały program (z małym wyjątkiem, ale o tym  później). Okazało się, że takie podejście
;; do sprawy jest bardzo wygodne -- nie musiałem się dzięki temu nawet przejmować
;; osobnym implementowaniem funkcji rekurencyjnych, wzajemnie rekurencyjnych
;; czy nawet zagnieżdżonych, a do tego można definiować funkcje w dowolnej kolejności!
;; Co więcej, funkcje przyjmują dowolnie wiele argumentów, również 0.
;; On top of that, do funkcji można przekazywać cokolwiek co ewaluuje się do wartości
;; Czyli mozna przekazywać wartości zmiennych, jak i dowolne wyrażenia!

;; Oto przykładowy kod, po którym raczej jasno widać w jak wygląda nowa składnia:
(define BINOM '({func main ()
                      (return (call binom (N K)))}
                {func fact (t)
                      (if (= t 0)
                          (return 1)
                          ({func decr (x) (return (- x 1))}
                           (return (* t (call fact ((call decr (t))))))))}
                {func binom (n k)
                      (if (= k 0)
                          (return 1)
                          (var (num (call fact (n)))
                               (var (den (* (call fact (k)) (call fact ((- n k)))))
                                    (return (/ num den)))))}
                ))
(define (bin n k)
  (eval-prog (parse-cmd BINOM) (mem-alloc 'i 1 (mem-alloc 'N n (mem-alloc 'K k empty-mem)))))
;; Specjalnie trochę pokomplikowałem, ale widać featury naszego języka.

;; Jak to w ogóle działa?

;; Za każdym razem, kiedy definiuję funkcję, to do środowiska dodaję parę (nazwa funkcji . clo),
;; gdzie clo jest takim quasi-domknięciem, jest to po prostu struktura trzymająca nazwy
;; argumentów funkcji oraz jej ciało. Właśnie takie podejście bardzo dobrze
;; załatwiło łatwość w definiowaniu funkcji rekurencyjnych oraz wzajemnie rekurencyjnych i
;; zagnieżdżonych -- żadna funkcja nie zostanie wywołana, dopóki nie wywołam maina,
;; a tego wywołam dopiero po zewaluowaniu wszystkich definicji (tym samym dodaniu ich do środowiska).

;; Takie podejście ma trochę problemów, chyba największym z nich jest to, że nie ma możliwości
;; zmiany wartości globalnych wewnątrz funkcji. Tj. możemy je zmieniać, ale zmiany będą
;; widoczne jedynie w jej lokalnym zakresie.
;; W zasadzie nie jest to aż tak bolesne -- globalne zmienne możemy traktować po prostu
;; jak argumenty wywołania funkcji main.

;; Wywoływać funkcję mogę tylko za pomocą specjalnego wyrażenia call,
;; które jako pierwszy argument
;; przyjmuje nazwę funkcji, a jako drugi przyjmuje listę argumentów.
;; Żeby wiedzieć jak działa call, spójrzmy najpierw jak działa return.

;; return napisane jest tak, że jeśli w jakimkolwiek miejscu funkcji
;; się na niego trafi, to reszta funkcji nie jest już wywoływana
;; (czyli tak jakbyśmy sie spodziewali). Jak on w sumie działa?
;; Na samym początku eval-prog, zanim zacznę w ogóle ewaluować definicje funkcji,
;; dodaje do środowiska specjalną zmienną o nazwie RETURN o wartości #f.
;; Jeśli w funkcji gdziekolwiek wywołam returna, to
;; zmieniam wartość RETURN w środowisku na to, co chcę zwrócić.
;; W eval-cmd za każdym razem sprawdzam jaka jest wartość RETURN.
;; Jeśli jest to #f, to pracuje jakby nigdy nic, a jeśli jest to coś innego,
;; to po prostu zwracam aktualne środowisko.
;; Zatem funkcja zwraca środowisko, w którym zmienna RETURN
;; ustawiona jest na wynik jej obliczenia. 

;; Teraz już prosto widać, że jedyne co robi call, to szuka ciała funkcji
;; w środowisku i wywołuje ją dla podanych argumentów, dostaje od tej
;; funkcji środowisko, a następnie odzyskuje wartość RETURN w zwróconym
;; przez nią środowisku. Dzięki temu po wywołaniu funkcji
;; wewnątrz innej funkcji nie zmienią się wartości żadnych zmiennych (w tym globalnych).
;; Jest to dosyć podobne do pythona -- tam inty są immutable i nie można ich wysłać przez
;; referencję. Ale możemy to robić jeśli się uprzemy np. tak:
;; {func decr (x)
;;       (return (- x 1))}
;; {func main ()
;;       {(i := (call decr (i)))
;;        (return i)}
;; Uruchomienie takiego programu ze zmienną globalną i zwróci oczywiście i-1.

;; Mały problem którego za bardzo nie umiem rozwiązać jest taki, że jeśli gdzieś poza
;; jakąkolwiek funkcją wywołam return, to wartość którą tam zwrócę będzie
;; wartością dla całego programu, bo zmienna RETURN w środowisku zmieni swoją wartość
;; na coś innego od #f i niestety main nawet się nie wykona (na samym wstępie stwierdzi,
;; że coś zostało już zwrócone). Widać to w TEST10. Generalnie co za tym idzie,
;; między definicjami funkcji mogą być jakieś instrukcje, które zostaną
;; wywołane razem z ewaluacją programu, zanim zostanie wywołany main.

;; Dodatkowe informacje umieściłem w komentarzach w odpowiednich miejscach pliku.
;; Na dole umieściłem kilka testów które pokazują co jak działa.

(struct const (val)           #:transparent)
(struct binop (op l r)        #:transparent)
(struct var-expr (name)       #:transparent)
(struct call-expr (name args) #:transparent)      ;; wywołanie funkcji

(define (operator? x)
  (member x '(+ * - / > < = >= <=)))

(define (keyword? x)
  (member x '(skip while if := func func-rec call return)))  ;; kilka nowych słów kluczowych

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
    [(call-expr n a)
     (and (symbol? n)
          (list? a)
          (andmap expr? a))]
    [_ false]))

(struct skip   ()                #:transparent)
(struct assign (id exp)          #:transparent)
(struct if-cmd (exp ct cf)       #:transparent)
(struct while  (exp cmd)         #:transparent)
(struct comp   (left right)      #:transparent)
(struct var-in (name expr cmd)   #:transparent)
(struct function (name args cmd) #:transparent)    ;; dodane funkcje, funkcje rekurencyjne oraz return
(struct funcrec (name args cmd)  #:transparent)
(struct return-stat (exp)        #:transparent)

(define (cmd? c)
  (match c
    [(skip) true]
    [(assign x e)  (and (symbol? x) (expr? e))]
    [(if-cmd e ct cf) (and (expr? e) (cmd? ct) (cmd? cf))]
    [(while e c)   (and (expr? e) (cmd? c))]
    [(comp c1 c2)  (and (cmd? c1) (cmd? c2))]
    [(var-in x e c) (and (symbol? x) (expr? e) (cmd? c))]
    [(function f a c) (and (symbol? f) (list? a) (andmap symbol? a) (cmd? c))]
    [(funcrec f a c) (and (symbol? f) (list? a) (andmap symbol? a) (cmd? c))]
    [(return-stat exp) (expr? exp)]))

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
   [(and (list? q)                           ; <------ return
         (= (length q) 2)
         (eq? (first q) 'return))
    (return-stat (parse-expr (second q)))]
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
    [(call-expr name args)                          ;; <------ ewaluacja wywołania funkcji
     (match (mem-lookup name m) 
       [(clo func-args cmd)
        (if (= (length args) (length func-args))    ;; <------ sprawdzanie arnosci
            (let* ([func-mem (assign-values args func-args m)]
                   [final-mem (eval-cmd cmd func-mem)]
                   [ret (mem-lookup 'RETURN final-mem)])
              (if ret
                  ret
                  (error "No return statement in function" name)))
            (error "Arity mismatch, function" name "takes" (length func-args) "arguments, got" (length args)))]
       [else (error "Undefined function" name)])]))

(define (assign-values args func-args mem) ;; <------ przypisanie wartosci do argumentow funkcji
  (define (iter args func-args new-mem)
    (if (null? args)
        new-mem
        (iter (cdr args) (cdr func-args) (mem-alloc (car func-args) (eval (car args) mem) new-mem))))
  (iter args func-args mem))


(struct clo (args cmd))     ; <----- tak trzymana jest funkcja w środowisku, tj. jako lista nazw argumentow i cialo funkcji

;; zał: (cmd? c) (mem? m)
;; (mem? (eval-cmd c m))
(define (eval-cmd c m)
  (if (mem-lookup 'RETURN m)         ; <----- jeśli RETURN jest na coś ustawione, to chcemy zrwócic pamięc
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
        [(function name args cmd)        ; <------ dodanie ciała funkcji do środowiska
         (mem-alloc name (clo args cmd) m)]
        [(return-stat val)               ; <------ zmiana wartości zmiennej RETURN
         (mem-update 'RETURN (eval val m) m)]
        [_                   (error "Unknown command" c "— likely a syntax error")])))


;; program ewaluowany jest tak
;; ewaluowane są wszystkie definicje funkcji, wtedy
;; ręcznie szukam definicji main i ewaluuje jej ciało i zwracam to co zwróci main.
;; zakładam, że main nie przyjmuje żadnych argumentów.
(define (eval-prog p m)
  (let ((final-mem (eval-cmd p (mem-alloc 'RETURN #f m))))
    (match (mem-lookup 'main final-mem)
      [(clo args cmd)
       (let ((res (mem-lookup 'RETURN (eval-cmd cmd final-mem))))
         (if res res (error "No return statement in main")))])))

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
                {(x := (+ x 2))
                 (return (call decr (x)))})}))
(define (test) (eval-prog (parse-cmd TEST) empty-mem))

(define TEST2
  '({func decr (x) (return (- x 1))}
    {func main () (return (call decr (3)))}))
(define (test2) (eval-prog (parse-cmd TEST2) empty-mem))

; nie da się zmienić wartości zmiennej globalnej, zmienne są wysyłane przez kopie
(define TEST3
  '({func sth (x)
          {(i := -1)
           (return x)}}
    {func main ()
          {(i := 2)
           (return (call sth (i)))}}))
(define (test3) (eval-prog (parse-cmd TEST3) (mem-alloc 'i 3 empty-mem)))

; nie ma maina, wywala błąd
(define TEST4
  '(func f ()
          {return 1}))
(define (test4) (eval-prog (parse-cmd TEST4) empty-mem))

; funkcje wieloargumentowe
(define TEST5
  '({func f1 (x y z)
          (return y)}
    {func f2 (x y z)
          (return (+ (+ x y) z))}
    {func main ()
          {(if (> X 3)
              (var (x 2)
                   (return (call f1 (1 x 3))))
              (x := 5))
          (return (call f2 (x 3 4)))}}))
(define (test5) (eval-prog (parse-cmd TEST5) (mem-alloc 'x -1 (mem-alloc 'X 4 empty-mem))))

; Działa rekurencja!!
(define TEST6
  '({func f (x)
          (if (= x 0)
              (return 1)
              (return (* x (call f ((- x 1))))))}
    {func main ()
          (return (call f (X)))}))
(define (test6) (eval-prog (parse-cmd TEST6) (mem-alloc 'X 5 empty-mem)))

; kolejnośc deklaracji funkcji nie ma znaczenia, można zagnieżdżać funkcje
(define TEST7
  '(
    {func main ()
          (return (call f (2)))}
    {func f (x)
          (return (call f1 (x)))}
    {func f1 (x)
          {{func local-fun (x)
                (return (+ 1 x))}
          (return (call local-fun (x)))}}))
(define (test7) (eval-prog (parse-cmd TEST7) empty-mem))

; instrukcje poza jakimikolwiek funkcjami sa wykonywane przed wywołaniem main
(define TEST8
  '({func main ()
          (return i)}
     (i := 2)))
(define (test8) (eval-prog (parse-cmd TEST8) (mem-alloc 'i 1 empty-mem)))

; nic nie zwraca main, wywala błąd
(define TEST9
  '(func main ()
          (i := 1)))
(define (test9) (eval-prog (parse-cmd TEST9) (mem-alloc 'i 1 empty-mem)))

; return poza jakąkolwiek funkcją jest wynikiem programu
(define TEST10
  '({func main ()
          (return i)}
     (i := 2)
     (return -1)))
(define (test10) (eval-prog (parse-cmd TEST10) (mem-alloc 'i 1 empty-mem)))


; arity mismatch
(define TEST11
  '({func main ()
          (return (call decr ()))}
    {func decr (x)
          (return (- x 1))}))
(define (test11) (eval-prog (parse-cmd TEST11) empty-mem))
