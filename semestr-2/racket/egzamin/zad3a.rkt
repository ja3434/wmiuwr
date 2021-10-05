#lang racket

;; ZADANIE 3
;; =========

;; Z gramatykami bezkontekstowymi spotkaliście się już na Wstępie do
;; Informatyki. W tym zadaniu potraktujemy je jako dane dla naszych
;; programów.

;; Przypomnijmy, że gramatyka bezkontekstowa składa się z
;; · skończonego zbioru *symboli nieterminalnych*
;; · skończonego zbioru *symboli terminalnych*
;; · wybranego nieterminalnego symbolu startowego
;; · zbioru *produkcji*, czyli par symbol nieterminalny - lista
;;   (potencjalnie pusta) symboli terminalnych lub nieterminalnych

;; Słowo (ciąg symboli terminalnych) możemy wyprowadzić z gramatyki,
;; jeśli możemy zacząć od ciągu składającego się z symbolu startowego
;; możemy użyć skończonej liczby produkcji z gramatyki przepisując
;; symbol nieterminalny na ciąg symboli mu odpowiadających (w danej
;; produkcji).


;; Przykład: poprawne nawiasowania

;; Gramatyka składa się z jednego symbolu nieterminalnego, S (który
;; jest oczywiście symbolem startowym) i dwóch symboli terminalnych
;; "(" i ")", i zawiera następujące produkcje (zwyczajowo zapisywane
;; przy użyciu strzałki; zwróćcie uwagę że pierwszy ciąg jest pusty!):
;;   S ->
;;   S -> SS
;;   S -> (S)

;; W często spotykanej, bardziej zwięzłej, postaci BNF moglibyśmy tę
;; gramatykę zapisać tak (dbając trochę bardziej o wizualne
;; oddzielenie symboli terminalnych i nieterminalnych):
;; S ::= "" | SS | "(" S ")"
;; Mamy tu te same produkcje, ale tylko raz zapisujemy każdą z
;; powtarzających się lewych stron.

;; Z gramatyki tej da się wyprowadzić wszystkie poprawnie rozstawione
;; ciągi nawiasów — zobaczmy jak wyprowadzić (na jeden ze sposobów)
;; ciąg "(()())". Zaczynamy, jak zawsze, od słowa złożonego z symbolu
;; startowego i przepisujemy:
;;   S -> (S) -> (SS) -> ((S)S) -> ((S)(S)) -> (()(S)) -> (()())


;; Zadanie cz. 1

;; Zdefiniuj reprezentację gramatyki jako typu danych w
;; Rackecie. Warto zastanowić się co można uprościć względem definicji
;; matematycznej — w szczególności możemy założyć że dowolne napisy
;; (typu string) są ciągami symboli terminalnych, i że nie musimy
;; podawać jawnie zbioru nieterminali; również reprezentacja produkcji
;; gramatyki jako worka z parami wejście-wyjście niekoniecznie jest
;; najwygodniejsza.

;; Uwaga: w tym zadaniu nie wymagamy definiowania składni konkretnej i
;; parsowania, ale bardzo polecamy wybranie jakiejś formy, żeby móc
;; sensownie przetestować swoje rozwiązanie!


;; "Optymalizacja" gramatyk

;; Gramatyki, podobnie jak programy, piszą ludzie — może więc zdarzyć
;; się że znajdą się tam śmieci. Mogą one mieć dwojaką formę: symboli
;; nieterminalnych, których nie da się wyprowadzić z symbolu
;; startowego, lub symboli nieterminalnych z których nie da się
;; wyprowadzić żadnego słowa terminalnego (tj. niezawierającego
;; symboli nieterminalnych). Przykładowo, do naszej gramatyki
;; moglibyśmy dodać symbole P i Q, i produkcje:
;;  S -> ")(" P
;;  P -> PP "qed"
;;  Q -> "abc"

;; Mimo że nasza gramatyka wygląda inaczej na pierwszy rzut oka, tak
;; naprawdę się nie zmieniła: do symbolu Q nie możemy dojść z symbolu
;; S, a więc "abc" nigdy nie wystąpi w słowie wyprowadzalnym z
;; gramatyki. Analogicznie, z P nie da się wyprowadzić żadnego słowa,
;; które nie zawierałoby symbolu P — a zatem żadnego słowa złożonego
;; tylko z symboli terminalnych. To znaczy, że naszą gramatykę możemy
;; uprościć wyrzucając z niej symbole nieterminalne (i produkcje które
;; ich używają) do których nie da się dojść (tj. są *nieosiągalne*) i
;; te, z których nie da się ułożyć słowa terminalnego (tj. są
;; *nieproduktywne*). Jeśli z naszej rozszerzonej gramatyki wyrzucimy
;; takie symbole, dostaniemy oczywiście gramatykę początkową.


;; Zadanie cz. 2

;; Dla swojej reprezentacji gramatyki z poprzedniej części zadania
;; napisz dwie procedury: cfg-unreachable, znajdującą symbole
;; nieterminalne które są nieosiągalne z symbolu startowego, i
;; cfg-unproductive, znajdującą symbole nieterminalne które nie są
;; produktywne. Następnie użyj tych procedur żeby zdefiniować
;; procedurę cfg-optimize, która uprości daną gramatykę usuwając z
;; niej symbole nieosiągalne i nieproduktywne, a także odpowiednie
;; produkcje.

;; Rozwiązanie wpisz w poniższym pliku, i opatrz komentarzem
;; opisującym wybraną reprezentację (i podjęte przy jej projektowaniu
;; decyzje), a także zaimplementowane w cz. 2. algorytmy.






;; Zadanie 1

;; Postanowiłem napisać parser, bo bez tego zadanie wydaje mi się dosyć ubogie
;; Składnia konkretna naszych gramatyk wygląda bardzo podobnie do zapisu
;; przedstawionego w treści zadania.
;; np. gramatyka nawiasowania będzie wyglądać następująco:
;; '(grammar S (S ::= "" -- SS -- "(" S ")"))
;; ale mogłaby wyglądać też tak:
;; '(grammar S (S ::= "") (S ::= SS -- "(" S ")"))
;; a np. ta nieciekawa gramatyka przedstawiona w treści zadania:
;; '(grammar S (S ::= "] [" P) (P ::=  PP "qed") (Q ::= "abc"))
;; Zatem będzie to lista, która na pierwszym miejscu ma symbol 'grammar
;; na drugim miejscu ma symbol startowy
;; następnie następuje lista produkcji w formacie:
;; <non-terminal> ::= <lista produkcji, produkcje oddzielone są separatorem -->
;; Zalety:
;; - rozróżnienie w składni konkretnej symboli nieterminalnych i terminalnych
;;   przez użycie symboli i stringów pozwala na to, aby symbole terminalne nazywały się tak
;;   jak terminalne, tj. "S" nie jest tym samym co 'S.
;; - składnia wydaje się bardzo wygodna w użyciu, nie ma też problemu, żeby później dopisać
;;   dodatkowe produkcje dla jednego symbolu nieterminalnego, np. (S ::= "") (S ::= SS)
;; - parser jest łatwy w implementacji
;; Wady:
;; - symbole nieterminalne mogą składać się jedynie z jednego symbolu, zatem nie możemy robić ich
;;   zbyt wiele

;; Reprezentacja gramatyki: podczas parsowania gramatyki symbole i stringi wewnątrz produkcji
;; reprezentowane są przez struktury terminal oraz non-terminal. Cała gramatyka to
;; struktura dwuelementowa - pierwszym jest symbol startowy, a drugim lista par <symbol . produkcja>
;; Taka decyzja właśnie pozwoliła na to, że zaproponowana przeze mnie składania konkretna jest
;; bardzo prosta do sparsowania - wystarczy każdą produkcję podzielić ze względu na separator '--
;; i do czegoś podobnego do środowisk dodawać po prostu odpowiednie pary.
;; dla przykładu taka gramatyka:
;; '(grammar S (S ::= "" -- SS -- "(" S ")" -- Q) (Q ::= "" -- QS -- "[" Q "]"))
;; będzie reprezentowana następująco:
;; (grammar
;;  'S
;;  (production
;;   (list
;;    (list 'S (terminal ""))
;;    (list 'S (non-terminal 'S) (non-terminal 'S))
;;    (list 'S (terminal "(") (non-terminal 'S) (terminal ")"))
;;    (list 'S (non-terminal 'Q))
;;    (list 'Q (terminal ""))
;;    (list 'Q (non-terminal 'Q) (non-terminal 'S))
;;    (list 'Q (terminal "[") (non-terminal 'Q) (terminal "]")))))
;; Prosze zauważyć, że np. SS zostało zamienione na dwa sąsiednie nieterminalne symbole S
;; (to właśnie powód, dlaczego symbole nieterminalne mogą być jedynie jednoznakowe).

;; Zdecydowałem się dodać strukturę production, bo wtedy łatwo można na niej operować
;; pisząc funkcje production-add, czy production-lookup itp.


(struct non-terminal (sym)    #:transparent)
(struct terminal (sym)        #:transparent)
(struct grammar (start rules) #:transparent)

(define SEPARATOR '--)

(define (make-cfg q)
  (cond
    [(and (list? q) (eq? 'grammar (first q)))
     (grammar (second q) (append-map make-cfg (cddr q)))]
    [(and (list? q) (eq? '::= (second q)))
     (let ([nt (first q)]
           [rules (split-by-separator (cddr q))])
       (map (lambda (x) (cons nt x)) (map make-rules rules)))]
    [else (error "MAKE-CFG -- Parse error, unknown token" q)]))

(define (make-cfg start rules)
  (grammar start (make-rules rules)))

(define (make-rules xs)
  (cond
    [(null? xs) null]
    [(string? (car xs)) (cons (terminal (car xs)) (make-rules (cdr xs)))]
    [(symbol? (car xs)) (append (map non-terminal (symbol->list (car xs))) (make-rules (cdr xs)))]
    [else (error "Invalid syntax in production" xs)]))

(define (split-at-symb symb xs)
  (define (iter left right)
    (cond
      [(null? right) (cons left null)]
      [(eq? symb (car right)) (cons left (cdr right))]
      [else (iter (cons (car right) left) (cdr right))]))
  (let ([res (iter null xs)])
    (cons (reverse (car res)) (cdr res))))

(define (split-by-separator xs)
  (let ([res (split-at-symb SEPARATOR xs)])
    (if (null? (cdr res))
        res
        (cons (car res) (split-by-separator (cdr res))))))

(define (symbol->list s)
  (map string->symbol
       (map string
            (string->list (symbol->string s)))))
                         
(define sample '(S ::= "" -- SS -- "(" S ")"))
(define sample2 '(grammar S (S ::= "" -- SS -- "(" S ")" -- Q) (Q ::= "" -- QQ -- "[" Q "]")))
(define sample3 '(grammar S
                          (S ::= A B -- D E)
                          (A ::= "a")
                          (B ::= "b" C)
                          (C ::= "c")
                          (D ::= "d" F)
                          (E ::= "e")
                          (F ::= "f" D)))

;; zadanie 2

;; korzystam z algorytmów przedstawionych w tej książce:
;; https://bit.ly/3ev0NUA, konkretnie te ze stron 50-51
;; Pozwoliłem sobie trochę zmienić przeznaczenie funkcji cfg-unreachable oraz cfg-unproductive
;; Zamiast zwracać nieproduktywne nieterminale, zwracają właśnie produktywne
;; i analogicznie w tym drugim. Po prostu taka implementacja jest dla mnie wygodniejsza,
;; a jest bardzo nieistotną zmianą koncepcyjną.
;; Stąd zmiana nazwy na cfg-productive oraz cfg-reachable

;; cfg-productive działa w ten sposób:
;; Jakiś nieterminal nazywamy produktywnym, jeśli ma co najmniej jedną produktywną zasadę
;; Jakąś zasadę nazywamy produktywną, jeśli składa się z terminali oraz produktywnych nieterminali
;; Jasno widać, że wg tej definicji te nieterminale, które nie są produktywne, są nieproduktywne
;; wg definicji zadania, a cała reszta jest produktwna.

;; Algorytm znajdowania produktywnych nieterminali:
;; Mamy listę produktywnych nieterminali P, początkowo pustą
;; 1. Stwórz nową listę P'
;; 2. Przejdź po liście produkcji
;; -> jeśli dana produkcja jest produktywna (wg P), dodaj jej nieterminal do P'
;; 3. Jeśli P != P', zrób P := P' i wróć do 1.
;; 4. Zwróć P

;; Fajne w tym algorytmie jest to, że jeśli mamy jakiś nieterminal, którego
;; używamy w jakiejś produkcji, ale ten nieterminal nie ma zdefiniowanej swojej produkcji
;; to nie zostanie oznaczony jako produktywny, co jest dla nas korzystne

;; Algorytm znajdowania osiągalnych nieterminali:
;; Traktujemy nitereminale jak wierzchołki w grafie a zasady jako listy sąsiedztwa.
;; Terminale są liśćmi, a nieterminale węzłami. Robimy po prostu DFSa z nieterminalu
;; startowego i węzły do których dotrzemy oznaczamy jako osiągalne. 

;; Wg papierka który tutaj podałem, jeśli najpierw usuniemy nieproduktywne nieterminale,
;; a w następnej kolejności nieosiągalne, to nasza gramatyka stanie się regularna.

(define (productive? p productive-nt)
  (or (terminal? p) (member (non-terminal-sym p) productive-nt)))
(define (rule-productive? r productive-nt)
  (andmap (lambda (x) (productive? x productive-nt)) r))

(define (cfg-productive g)
  (define (find-productive-nt productive-nt rules)
    (cond
      [(null? rules) (remove-duplicates productive-nt)]
      [(rule-productive? (cdar rules) productive-nt)
       (find-productive-nt (cons (caar rules) productive-nt) (cdr rules))]
      [else (find-productive-nt productive-nt (cdr rules))]))
  (define (iter productive-nt)
    (let ([new-prod-nt (find-productive-nt productive-nt (grammar-rules g))])
      (if (equal? productive-nt new-prod-nt)
          productive-nt
          (iter new-prod-nt))))
  (iter null))

(define (cfg-reachable g)
  (define (iter verts vis)
    (cond
      [(null? verts) vis]
      [(member (car verts) vis) (iter (cdr verts) vis)]
      [else (iter (cdr verts) (dfs (car verts) vis))])) 
  (define (dfs v vis)
    (display v)
    (newline)
    (let* ([rules (filter (lambda (r) (eq? (car r) v)) (grammar-rules g))]
           [verts (append-map (lambda (r) (cdr r)) rules)]
           [verts (filter non-terminal? verts)]
           [verts (map non-terminal-sym verts)])
      (iter verts (cons v vis))))
  (dfs (grammar-start g) null))

(define (cfg-optimize g)
  (let* ([productive-nt (cfg-productive g)]
         [productive-rules (filter (lambda (r)
                                     (rule-productive? (cdr r) productive-nt))
                                   (grammar-rules g))]
         [new-g (grammar (grammar-start g) productive-rules)]
         [reachable-nt (cfg-reachable new-g)]
         [res-g (grammar (grammar-start new-g) (filter
                                                (lambda (r) (member (car r) reachable-nt))
                                                (grammar-rules new-g)))])
    res-g))
        