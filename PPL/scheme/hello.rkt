#lang racket

(define (hello)
    (displayln "Hello, world!")) ; Display "Hello, world!" and a newline -- does not return a value

(define (hello2) 
    "Hello, world") ; Returns the string "Hello, world!" -- it can be put in a variable

(define (len L)
    (if (null? L)
        0
        (+ 1 (len (cdr L))))) ; Returns the length of a list with the recursive function

        (define (len-tail L)
            (define (len-iter L acc)
                (if (null? L)
                        acc
                        (len-iter (cdr L) (+ acc 1))))
            (len-iter L 0))