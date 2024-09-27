#lang racket

(define (hello)
  (displayln "hello world"))

(define (len L)
  (define (tail-len L k)
    (if (null? L) k
        (tail-len (cdr L) (+ 1 k))))
  (tail-len L 0))

(define (prefix n L)
  (define (p n L a)
    (if (= n 0)
      a
      (p (- n 1) (cdr L) (append a (list (car L))))))
  (p n L '()))

; better:
(define (pref n L)
  (if (= n 0)
      (list (car L))
      (cons (car L) (pref (- n 1) (cdr L)))))


(define (ref k L)
  (if (= k 0)
      (car L)
      (ref (- k 1) (cdr L))))


;(range 3)  (0 1 2 3)
;(range 2 3)   (2 3)

(define (range s . e)
  (define (r s e)
    (if (= s e)
        (list s)
        (cons s (r (+ s 1) e))))
  (if (null? e)
      (r 0 s)
      (r s (car e))))

(define (test-while)
  (let ((x 0))
    (while (lambda () (< x 10))
         (lambda ()
           (displayln x)
           (set! x (+ 1 x))))))

(define (while c b)
  (when (c)
    (b)
    (while c b)))

(define (tsil L)
  (if (null? L)
      '()
       (append (tsil (cdr L)) (list (car L)))))

(define (flat L)
  (if (null? L)
      '()
      (append (if (list? (car L))
                  (flat (car L))
                  (list (car L)))
              (flat (cdr L)))))






