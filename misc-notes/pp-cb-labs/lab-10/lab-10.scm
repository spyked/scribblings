;; PP, lab 10

; 0.a. Fluxul numerelor naturale
(define (repeat n)
  (cons n (delay (repeat n))))

; 0.b. Ia n elemente dintr-un flux
(define (take n strm)
  (if (zero? n)
      '()
      (cons (car strm) (take (- n 1) (force (cdr strm))))))

; 1. naturals
;
; Definim întâi o funcție contor
(define (mk-nats n)
  (cons n (delay (mk-nats (+ n 1)))))

; apoi naturals în funcție de contor
(define naturals (mk-nats 0))

; 2.a. takeWhile -- foarte similar cu take, doar că ne oprim în momentul
; când un predicat p nu mai este valabil.
(define (takeWhile p strm)
  (if (p (car strm))
      (cons (car strm) (takeWhile p (force (cdr strm))))
      '()))

; 2.b. drop -- inversul lui take
(define (drop n strm)
  (if (zero? n)
      strm
      (drop (- n 1) (force (cdr strm)))))

; 3. map pe fluxuri
(define (map-strm f strm)
  (cons (f (car strm)) (delay (map-strm f (force (cdr strm))))))

; 4. zipWith între două fluxuri
(define (zip-with-strm op strm1 strm2)
  (cons (op (car strm1) (car strm2))
        (delay (zip-with-strm op (force (cdr strm1)) (force (cdr strm2))))))

; 5. Numere pare (evens) -- înmulțim fiecare număr din naturals cu 2
(define evens
  (map-strm (lambda (x) (* 2 x)) naturals))

; 6. Puteri ale lui 2. Aici ar fi mai multe variante, e.g. să aplicăm
; funcția putere pe naturals. Putem însă să construim mai eficient șirul
; plecând de la el însuși (e.g. printr-un „contor” care înmulțește cu 2
; la fiecare pas).
;
; O variantă mai elegantă implică totuși folosirea lui map:
;
; (define pows-of-2 (cons 1 (delay
;                             (map-strm (lambda (x) (* 2 x)) pows-of-2)))
;
; define nu permite însă apelul recursiv înafara unui lambda, așa că
; folosim letrec:
(define pows-of-2
  (letrec ((pows (cons 1 (delay (map-strm (lambda (x) (* 2 x)) pows)))))
    pows))

; 7. Șirul numerelor lui Fibonacci, începând cu 0
;
; 0 : 1 : zipWith (+) fibs (tail fibs)
(define fibonacci
  (letrec
      ((fibs (cons 0
                   (delay (cons 1
                                (delay
                                  (zip-with-strm +
                                                 fibs
                                                 (force (cdr fibs)))))))))
    fibs))
