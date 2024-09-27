#lang racket

; Display "Hello, world!" and a newline -- does not return a value
(define (hello)
  (displayln "Hello, world!"))

; Returns the string "Hello, world!" -- it can be put in a variable
(define (hello2)
  "Hello, world")

; Returns the length of a list with the recursive function
(define (len L)
  (if (null? L)
      0
      (+ 1 (len (cdr L)))))

; Returns the length of a list with the tail-recursive function
(define (len-tail L)
  (define (len-iter L acc)
    (if (null? L)
        acc
        (len-iter (cdr L) (+ acc 1))))
  (len-iter L 0))

; Returns a prefix of a list of n items with the recursive function
(define (prefix n L)
  (if (= n 0)
      '()
      (cons (car L) (prefix (- n 1) (cdr L)))))

; Returns a prefix of a list of n items with the tail-recursive function
(define (pref n L)
  (define (pref-helper n L r)
    (if (= n 0)
        r
        (pref-helper (- n 1) (cdr L) (append r (list (car L))))))
  (pref-helper n L '()))

; Returns the k-th element of a list with the recursive function
(define (ref k L)
  (if (= k 0)
      (car L)
      (ref (- k 1) (cdr L))))

; Returns the k-th element of a list with the tail-recursive function
(define (ref-tail k L)
  (define (ref-iter k L)
    (if (= k 0)
        (car L)
        (ref-iter (- k 1) (cdr L))))
  (ref-iter k L))

; Creates a list from s to e
(define (range s e)
  (if (= s e)
      (list e)
      (cons s (range (+ s 1) e))))


(define (range-tail x . y)
  (define (r s e)
    (if (= s e)
        (list e)
        (cons s (r (+ s 1) e))))
  (if (null? y)
      (r 0 x)
      (r x (car y))))


(define (while c b)
  (when (c)
    (b)               ; (c) and (b) are both functions !!!!!!!
    (while c b)))


(define (rev L)
  (if (null? L)
      '()
      (append (rev (cdr L)) (list (car L)))))

; given a list of lists like '(1 (2 3) (4 (5 (6)))) it flattens it in a list like '(1 2 3 4 5 6)
(define (flatten L)
  (if (null? L)
      '()
      (if (list? (car L))
          (append (flatten (car L)) (flatten (cdr L)))
          (cons (car L (flatten (cdr L)))))))