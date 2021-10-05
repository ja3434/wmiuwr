#lang racket
(provide falsifiable-cnf?) (require "props.rkt")


(define (falsifiable-cnf? p)
  ;literał
  (define (lit? p)
    (or (var? p)
        (and (neg? p) (var? (neg-subf p)))
        ))
  
  (define (lit-pos? p)
    (if (lit? p)
        (var? p)
        (error "not a literal" p)
        ))
  
  (define (lit-var p)
    (cond
      [(not (lit? p)) (error "not a literal" p)]
      [(lit-pos? p) p]
      [else (neg-subf p)]
      ))

  (define (contr p)
    (if (lit? p)
        (if (neg? p) (neg-subf p) (neg p))
        (error "not a literal" p)
    ))

  ;konwertowanie
  (define (convert-to-cnf p)
    (define (convert-to-nnf p)
      (cond
        [(lit? p) p]
        [(and (neg? p) (conj? (neg-subf p)))
         (let ((A (neg-subf p)))
           (disj (convert-to-nnf (neg (conj-left A))) (convert-to-nnf (neg (conj-right A)))))]
        [(and (neg? p) (disj? (neg-subf p)))
         (let ((A (neg-subf p)))
           (conj (convert-to-nnf (neg (disj-left A))) (convert-to-nnf (neg (disj-right A)))))]
        [(and (neg? p) (neg? (neg-subf p))) (convert-to-nnf (neg-subf (neg-subf p)))]
        [(conj? p) (conj (convert-to-nnf (conj-right p)) (convert-to-nnf (conj-left p)))]
        [(disj? p) (disj (convert-to-nnf (disj-right p)) (convert-to-nnf (disj-left p)))]
        [else (error "not a proposition" p)]))
    
    (define (flatmap proc seq)
      (foldr append null (map proc seq)))
    
    (define (merge a b)
      (flatmap (lambda (c) (map (lambda (c2) (append c c2)) b)) a))
    
    (define (convert p)
      (cond
        [(lit? p) (list (list p))]
        [(conj? p) (append (convert (conj-left p)) (convert (conj-right p)))]
        [(disj? p) (let* ((L (convert (disj-left p))) (R (convert (disj-right p))))
                     (merge L R))]
        [else (error "it should never be here" p)]
        ))
    
    (map (lambda (c) (remove-duplicates c)) (convert (convert-to-nnf p))))

  ;prawdziwa funkcja
  (define cnf (convert-to-cnf p))
  
  (define (falsifiable-clause? c)
    (cond
      [(null? c) #t]
      [(eq? #f (member (contr (car c)) c)) (falsifiable-clause? (cdr c))]
      [else #f]
    ))
  
  (define (falsified-clause c)
    (if (null? c)
        null
        (cons (list (lit-var (car c)) (not (lit-pos? (car c)))) (falsified-clause (cdr c)))
    ))
  
  (define (falsified-val p)
    (cond
      [(null? p)  false]
      [(falsifiable-clause? (car p)) (falsified-clause (car p))]
      [else (falsified-val (cdr p))]
    )
  )
  (falsified-val cnf))


;złożoność wykładnicza tak jak falsible-eval ale często w praktyce szybsza jak nie ma za dużo alternatyw.