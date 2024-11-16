#lang racket

; USUALLY SCHEME EXERCISES IN THE EXAM INVOLVES MACROS, CONTINUATIONS AND SOMETIMES OBJECT-ORIENTED PROGRAMMING

; EXAM FROM 2020-06-29

(define-syntax define-with-type
  (syntax-rules (:)
    [(_ (NAME : RET-TYPE (ARG : ARG-TYPE) ...) BODY ...)
     (define (NAME ARG ...)
       (if (and (ARG-TYPE ARG) ...)
           (let ([result (begin BODY ...)])
             (if (RET-TYPE result)
                 result
                 (error "invalid return type")))
           (error "invalid argument type")))]))

(define-with-type
  (add-to-char : integer? (x : integer?) (y : char?))
  (+ x (char->integer y)))

(add-to-char 4 #\a) ; 101