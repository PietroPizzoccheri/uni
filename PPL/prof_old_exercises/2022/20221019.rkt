#lang racket

(define-syntax block
  (syntax-rules (where then <-)
    ((_ (a ...) then (b ...))
     (begin
       a ...
       b ...))
    ((_ (a ...) then (b ...) where (v <- x y) ...)
     (begin
       (let ((v x) ...)
         a ...)
       (let ((v y) ...)
         b ...)))))

(block
  ((displayln (+ x y))
   (displayln (* x y))
   (displayln (* z z)))
  then
  ((displayln (+ x y))
   (displayln (* z x)))
  where (x <- 12 3)(y <- 8 7)(z <- 3 2))

(block
 ((displayln "one")
 (displayln "two"))
 then
 ((displayln "three")))


(define-syntax define-dispatcher
  (syntax-rules (methods: parent:)
    ((_ methods: (m ...) parent: p)
     (lambda (msg . pars)
       (case msg
         ((m) (apply m pars))
         ...
         (else (apply p (cons msg pars))))))
    ((_ methods: (m ...))
     (lambda (msg . pars)
       (case msg
         ((m) (apply m pars))
         ...
         (else (error "I do not understand your message")))))))
      
(define (break-negative l)
  (call/cc (lambda (b)
             (for-each (lambda (x)
                         (if (< x 0)
                             (b 'end)
                             (displayln x)))
              l))))

(define (continue-negative l)
  (for-each (lambda (x)
              (call/cc (lambda (c)
                         (if (< x 0)
                             (c)
                             (displayln x)))))
            l))


(define *storage* '()) ; continuations stack
(define (ret x)
  ((car *storage*) x))

(define-syntax defun
  (syntax-rules ()
    ((_ f (p ...) b ...)
     (define (f p ...)
       (let ((v (call/cc (lambda (c)
                  (set! *storage* (cons c *storage*))
                  b ...))))
         (set! *storage* (cdr *storage*))
         v)))))

(defun g (x y)
  (if (< x y)
      (ret x)
      y))

