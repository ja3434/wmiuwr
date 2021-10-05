#lang racket

(define (var? t) (symbol? t))

(define (neg? t)
  (and (list? t)
       (= 2 (length t))
       (eq? 'neg (car t))))

(define (conj? t)
  (and (list? t)
       (= 3 (length t))
       (eq? 'conj (car t))))

(define (disj? t)
  (and (list? t)
       (= 3 (length t))
       (eq? 'disj (car t))))

(define (lit? t)
  (or (var? t)
      (and (neg? t)
           (var? (neg-subf t)))))

(define (prop? f)
  (or (var? f)
      (and (neg? f)
           (prop? (neg-subf f)))
      (and (disj? f)
           (prop? (disj-left f))
           (prop? (disj-right f)))
      (and (conj? f)
           (prop? (conj-left f))
           (prop? (conj-right f)))))

(define (make-conj left right)
  (list 'conj left right))

(define (make-disj left right)
  (list 'disj left right))

(define (make-neg f)
  (list 'neg f))

(define (conj-left f)
  (if (conj? f)
      (cadr f)
      (error "Złe dane ze znacznikiem -- CONJ-LEFT" f)))

(define (conj-right f)
  (if (conj? f)
      (caddr f)
      (error "Złe dane ze znacznikiem -- CONJ-RIGHT" f)))

(define (disj-left f)
  (if (disj? f)
      (cadr f)
      (error "Złe dane ze znacznikiem -- DISJ-LEFT" f)))

(define (disj-right f)
  (if (disj? f)
      (caddr f)
      (error "Złe dane ze znacznikiem -- DISJ-RIGHT" f)))

(define (neg-subf f)
  (if (neg? f)
      (cadr f)
      (error "Złe dane ze znacznikiem -- NEG-FORM" f)))

(define (lit-var f)
  (cond [(var? f) f]
        [(neg? f) (neg-subf f)]
        [else (error "Złe dane ze znacznikiem -- LIT-VAR" f)]))
      
(define (free-vars f)
  (cond [(null? f) null]
        [(var? f) (list f)]
        [(neg? f) (free-vars (neg-subf f))]
        [(conj? f) (append (free-vars (conj-left f))
                           (free-vars (conj-right f)))]
        [(disj? f) (append (free-vars (disj-left f))
                           (free-vars (disj-right f)))]
        [else (error "Zła formula -- FREE-VARS" f)]))

(define (gen-vals xs)
  (if (null? xs)
      (list null)
      (let*
          ((vss (gen-vals (cdr xs)))
           (x (car xs))
           (vst (map (λ (vs) (cons (list x true) vs)) vss))
           (vsf (map (λ (vs) (cons (list x false) vs)) vss)))
        (append vst vsf))))

(define (eval-formula f evaluation)
  (cond [(var? f)
         (let ((val (assoc f evaluation)))
           (if (not val)
               (error "Zmienna wolna nie wystepuje w wartościowaniu -- EVAL-FORMULA" f evaluation)
               (cadr val)))]
        [(neg? f) (not (eval-formula (neg-subf f) evaluation))]
        [(disj? f) (or (eval-formula (disj-left f) evaluation)
                       (eval-formula (disj-right f) evaluation))]
        [(conj? f) (and (eval-formula (conj-left f) evaluation)
                        (eval-formula (conj-right f) evaluation))]
        [else (error "Zła formuła -- EVAL-FORMULA" f evaluation)]))

(define (falsifable-eval? f)
  (let* ((evaluations (gen-vals (free-vars f)))
         (results (map (λ (evaluation) (eval-formula f evaluation)) evaluations)))
    (ormap false? results)))

(define (nff? f)
  (cond [(lit? f) true]
        [(neg? f) false]
        [(conj? f) (and (nff? (conj-left f))
                        (nff? (conj-right f)))]
        [(disj? f) (and (nff? (disj-left f))
                        (nff? (disj-right f)))]
        [else (error "Zła formuła -- NFF?" f)]))

(define (convert-to-nnf f)
  (cond [(lit? f) f]
        [(neg? f) (convert-negation (neg-subf f))]
        [(conj? f) (make-conj (convert-to-nnf (conj-left f))
                              (convert-to-nnf (conj-right f)))]
        [(disj? f) (make-disj (convert-to-nnf (disj-left f))
                              (convert-to-nnf (disj-right f)))]
        [else (error "Zła formuła -- CONVERT" f)]))

(define (convert-negation f)
  (cond [(lit? f)
         (if (var? f)
             (make-neg f)
             (neg-subf f))]
        [(neg? f) (convert-to-nnf (neg-subf f))]
        [(conj? f) (make-disj (convert-negation (conj-left f))
                              (convert-negation (conj-right f)))]
        [(disj? f) (make-conj (convert-negation (disj-left f))
                              (convert-negation (disj-right f)))]
        [else (error "Zła formuła -- CONVERT-NEGATION" f)]))

(define (clause? x)
  (and (list? x)
       (andmap lit? x)))

(define (clause-empty? x)
  (and (clause? x)
       (null? x)))

(define (cnf? x)
  (and (list? x)
       (andmap clause? x)))

(define (flatmap proc seq)
  (foldl append null (map proc seq)))

(define (convert-to-cnf f)
  (define (convert f)
    (cond [(lit? f) (list (list f))]
          [(conj? f) (append (convert-to-cnf (conj-left f))
                             (convert-to-cnf (conj-right f)))]
          [(disj? f)
           (let ((clause-left (convert-to-cnf (disj-left f)))
                 (clause-right (convert-to-cnf (disj-right f))))
             (flatmap (λ (clause)
                        (map (λ (clause2)
                               (append clause2 clause)) clause-left))
                      clause-right))]))
  (convert (convert-to-nnf f)))

(define (falsifable-clause? clause)
  (cond [(clause-empty? clause) true]
        [(lit? (findf (λ (l) (equal?
                              l
                              (convert-to-nnf (make-neg (car clause)))))
                              clause)) false]
        [else (falsifable-clause? (cdr clause))]))

(define (falsifable-cnf? f)
  (define (neg-value lit)
    (if (var? lit)
        (list lit false)
        (list (neg-subf lit) true)))
  (ormap (λ (clause) (if (falsifable-clause? clause)
                         (map neg-value clause)
                         false))
         (convert-to-cnf f)))