#lang racket

; (define x (choose '(1 2 3))) non-deterministic choice
; x = 2
; (fail)

(define *paths* '())

(define (choose choices)
  (if (null? choices)
      (fail)
      (call/cc
       (lambda (cc)
         (set! *paths* (cons
                        (lambda ()
                         (cc (choose (cdr choices))))
                        *paths*))
         (car choices)))))

(define fail #f) ; placeholder
(call/cc (lambda (cc)
           (set! fail
                 (lambda ()
                   (if (null? *paths*)
                       (cc 'failure)
                       (let ((p1 (car *paths*)))
                         (set! *paths* (cdr *paths*))
                         (p1)))))))
         
(define (is-sum-of n) ; n must be between 0 and 10
  (let* ((L '(0 1 2 3 4 5))
         (x (choose L))
         (y (choose L)))
    (if (= (+ x y) n)
        (list x y)
        (fail))))
