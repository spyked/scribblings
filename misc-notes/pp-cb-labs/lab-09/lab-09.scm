; PP, laboratorul 9: introducere în Scheme

; 1. Warm-up: funcții simpluțe
;
; 1.a. Factorialul unui număr: se aseamănă foarte mult cu Haskell, minus
; zahărul sintactic
(define (factorial n) ; sau, (define factorial (lambda (n) ...))
  (if (= n 0)
      1
      (* n (factorial (- n 1)))))

; 1.b. Verificarea dacă o listă este palindrom
;
; Definim întâi inversa unei liste (natural pe coadă):
(define (reverse-helper L acc)
  (if (null? L)
      acc
      (reverse-helper (cdr L) (cons (car L) acc))))

(define (reverse L)
  (reverse-helper L '()))

; Apoi definim verificarea dacă o listă este palindrom:
(define (palindrom L)
  (equal? L (reverse L)))

; 2. Funcții de ordin superior
;
; 2.a. map și zip-with; map e deja implementată, dar o reimplementăm:
(define (map f L)
  (if (null? L)
      '()
      (cons (f (car L)) (map f (cdr L)))))

(define (zip-with f L1 L2)
  (if (or (null? L1) (null? L2))
      '()
      (cons (f (car L1) (car L2)) (zip-with f (cdr L1) (cdr L2)))))

; 2.b. foldl, foldr
(define (foldl op init L)
  (if (null? L)
      init
      ; observație: în Haskell ordinea operației e inversată, i.e. (op
      ; init (car L))
      (foldl op (op (car L) init) (cdr L))))

(define (foldr op init L)
  (if (null? L)
      init
      (op (car L) (foldr op init (cdr L)))))

; 2.c. filter
(define (filter p L)
  (if (null? L)
      '()
      (if (p (car L))
          (cons (car L) (filter p (cdr L)))
          (filter p (cdr L)))))

; 3. Exerciții cu funcții de ordin superior
;
; 3.a. Flatten pentru liste imbricate. Putem verifica dacă o variabilă
; este listă folosind predicatul list?. Avem deja funcția append, care
; concatenează două (sau mai multe) liste. Putem folosi foldr pentru a
; parcurge lista:
(define (flatten L)
  (foldr (lambda (e acc)
           (if (list? e)
               ; facem recursiv flatten pe listă
               (append (flatten e) acc)
               (cons e acc)))
         '()
         L))

; 3.b. Grupăm elementele consecutive identice ale unei liste într-o
; listă de liste.
;
; e.g. '(1 1 1 1 2 2 3 3 3 4) -> '((1 1 1 1) (2 2) (3 3 3) (4))
;
; Similar, parcurgem lista și în acumulator ținem rezultate parțiale. Ne
; interesează valoarea lui (car (car acc)), adică (caar acc), pentru a
; compara cu valoarea elementului curent din listă.
(define (group-equal L)
  (foldr (lambda (e acc)
           (if (or (null? acc) ; acc e gol
                   (not (equal? (caar acc) e))) ; avem un element nou
               (cons (list e) acc)
               (cons (cons e (car acc)) (cdr acc))))
         '()
         L))

; 3.c. Dorim să obținem o listă de perechi/liste de forma (element,
; număr de apariții) plecând de la o listă similară cu cea de la punctul
; anterior. Putem să refolosim funcția implementată anterior.
(define (count-equal L)
  (map (lambda (L) (list (car L) (length L)))
       (group-equal L)))

; 3.d. Dorim să obținem același rezultat ca la punctul anterior, dar
; pentru liste arbitrare.
;
; O variantă ar fi să sortăm lista inițială. Varianta asta e ok pentru
; numere, dar nu funcționează pe liste de elemente arbitrare.
;
; Așa că pornim de la următoarele funcții:
;
; - (member-occurrence? element occurrence-list): verifică dacă un
;   element există deja într-o listă de forma (element, nr. apariții).
; - (add-occurence element occurence-list): adaugă o apariție într-o
;   listă de apariții
(define (member-occurence? e L)
  (not (null? (filter (lambda (pair) (equal? (car pair) e)) L))))

(define (add-occurence e L)
  (if (member-occurence? e L)
      (map (lambda (pair)
             (if (equal? (car pair) e)
                 (list e (+ 1 (cadr pair)))
                 pair))
           L)
      (cons (list e 1) L)))

; Acum count-equal pe liste arbitrare (count-equal-arb) ar fi un simplu
; foldr după add-occurence, e.g.
;
; '(1 2 3 1 4 2 2 5) ⇒ '((1 2) (2 3) (3 1) (4 1) (5 1))
(define (count-equal-arb L)
  (foldr add-occurence '() L))

; 4. Rotirea unei liste la stânga/dreapta cu n poziții. Exemple:
;
; - 3 poziții (la stânga): '(1 2 3 4 5 6 7) -> '(4 5 6 7 1 2 3)
; - -3 poziții (la dreapta): '(1 2 3 4 5 6 7) -> '(5 6 7 1 2 3 4)
;
; Pentru ușurință, pornim de la cazul rotirii la stânga; putem considera
; (ca în Haskell) funcțiile take și drop, care iau, respectiv
; discardează un număr de elemente din listă:
(define (take n L)
  (if (or (null? L) (= n 0))
      '()
      (cons (car L) (take (- n 1) (cdr L)))))

(define (drop n L)
  (if (or (null? L) (= n 0))
      L
      (drop (- n 1) (cdr L))))

; Implementăm rotirea generală în funcție de semnul lui n. Luăm în
; calcul și cazurile când n > lungimea listei, făcând rotirea modulo
; n. Introducem construcția cond pentru a lucra mai ușor cu
; condiționale. De asemenea, introducem construcția let, pentru a putea
; face definiții interne:
(define (rotate n L)
  (let* ((len-L (length L))
         (to-rotate (modulo (abs n) len-L)))
    (cond
     ((> n 0) (append (drop to-rotate L) (take to-rotate L)))
     ((< n 0) (append (drop (- len-L to-rotate) L) (take (- len-L to-rotate) L)))
     (else L))))

; 5. Funcții curry, uncurry
;
; Dacă în Haskell toate funcțiile erau implicit curry, aici funcțiile
; sunt implicit uncurry, i.e., o funcție primește o listă de parametri,
; aceasta neputând fi aplicată parțial pe ei. De exemplu, în cazul
; adunării a două numere:
;
; > (+ x y)
;
; funcția + primește ca parametru lista formată din x și y. Putem însă
; să controlăm legarea variabilelor la valori folosind lambda-uri.
;
; 5.a. În Haskell, \ x y -> (+) x y era echivalent cu \ x -> \ y -> (+)
; x y. Aici trebuie să scriem explicit:
(define add-curry
  (lambda (x)
    (lambda (y)
      (+ x y))))

; Observăm că de exemplu (add-curry 2) va întoarce o închidere
; funcțională, pe care apoi o putem aplica pe următorul parametru, e.g.
;
; > ((add-curry 2) 3)
; > (map (add-curry 2) '(1 2 3 4))
;
; 5.b. Vrem să scriem funcția care ne transformă o funcție din forma
; curry în formă uncurry, e.g. ((curry->uncurry add-curry) 2 3) -> 5
(define (curry->uncurry f)
  (lambda (x y)
    ((f x) y)))

; 5.c. Invers, vrem să putem face uncurry pe o funcție; e.g.
;
; (((uncurry->curry +) 2) 3) -> 5
;
; Observăm că funcția asta e o generalizare (parametrizare după o
; funcție) a lui add-curry:
(define (uncurry->curry f)
  (lambda (x)
    (lambda (y)
      (f x y))))

; 5. bonus: swap pe parametrii unei funcții uncurry:
(define (swap f)
  (lambda (x y)
    (f y x)))

; map (: []) în Scheme:
;
; > (map ((uncurry->curry (swap cons)) '()) '(1 2 3 4))
