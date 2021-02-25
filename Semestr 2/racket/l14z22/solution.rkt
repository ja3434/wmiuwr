#lang racket

(require racklog)

(provide solve)

;; transpozycja tablicy zakodowanej jako lista list
(define (transpose xss)
  (cond [(null? xss) xss]
        ((null? (car xss)) (transpose (cdr xss)))
        [else (cons (map car xss)
                    (transpose (map cdr xss)))]))

;; procedura pomocnicza
;; tworzy listę n-elementową zawierającą wyniki n-krotnego
;; wywołania procedury f
(define (repeat-fn n f)
  (if (eq? 0 n) null
      (cons (f) (repeat-fn (- n 1) f))))

;; tworzy tablicę n na m elementów, zawierającą świeże
;; zmienne logiczne
(define (make-rect n m)
  (repeat-fn m (lambda () (repeat-fn n _))))

;; predykat binarny
;; (%row-ok xs ys) oznacza, że xs opisuje wiersz (lub kolumnę) ys
(define %row-ok
  (%rel (xs ys zs n)
        [(null null)]
        [(xs (cons '_ ys))
         (%row-ok xs ys)]
        [((cons n xs) ys)
         (%stars ys n)
         (%cut-first-n ys zs n)
         (%row-ok xs zs)]))


(define %suffix
  (%rel (xs ys x)
        [(xs xs)]
        [((cons x xs) ys)
         (%suffix xs ys)]))

(define %cut-first-n
  (%rel (xs ys n yl)
        [(xs xs 0)]
        [(xs ys n)
         (%suffix xs ys)
         (%is #t (= (- (length xs) (length ys)) n))]))
        

;; usun n pierwszych elementow z xs
(define (suffix xs n)
  (if (= n 0)
      xs
      (suffix (cdr xs) (- n 1))))


;; sprawdza czy pierwsze n elementów listy to gwiazdki (dokladnie n)
(define %stars
  (%rel (xs m n)
        [(null 0)]
        [((cons '_ xs) n)
         (%is n 0)]
        [((cons '* xs) n)
         (%is m (- n 1))
         (%stars xs m)]))

(define %board-ok
  (%rel (xss xs yss ys)
        [(null null)]
        [((cons xs xss) (cons ys yss))
         (%row-ok xs ys)
         (%board-ok xss yss)]))

;; funkcja rozwiązująca zagadkę
(define (solve rows cols)
  (define board (make-rect (length cols) (length rows)))
  (define tboard (transpose board))
  (define ret (%which (xss) 
                      (%= xss board)
                      (%board-ok rows board)
                      (%board-ok cols tboard)))
  (and ret (cdar ret)))


