#lang racket

(define *my-k* #f)

;; This code demonstrates the use of continuations in Racket using call/cc (call-with-current-continuation).
;; call/cc captures the current continuation (the rest of the computation) and allows it to be invoked later.

;; *my-k* is a global variable that will store a continuation.
(define (hi)
  (call/cc ; call/cc stands for call-with-current-continuation, which captures the current continuation (the rest of the computation) as a function.
   (lambda (k) ; k is the continuation function.
     (set! *my-k* k) ; Store the continuation in the global variable *my-k*.
     (displayln "A") ; Print "A".
     (k "C") ; Invoke the continuation with "C", which effectively jumps out of the current computation and returns "C".
     "B"))) ; This line is never reached because the continuation was invoked.

(hi) ; Call the hi function, which prints "A" and returns "C".

(*my-k* 5) ; Invoke the stored continuation with 5, which will jump back to the point where the continuation was captured and return 5.

(newline) ; Print a newline for separation.

;; 1
;;

(call/cc (lambda (k0) ; Capture the current continuation as k0.
           (+ 1 (call/cc (lambda (k1) ; Capture the current continuation as k1.
                           (+ 1 (k0 3))))))) ; Invoke k0 with 3, which jumps back to the outer call/cc and returns 3. The result is 3.

;; 2

(call/cc
 (lambda (k0) ; Capture the current continuation as k0.
   (+ 1 (call/cc (lambda (k1) ; Capture the current continuation as k1.
                   (+ 1 (k0 (k1 3)))))))) ; Invoke k1 with 3, which jumps back to the outer call/cc and returns 3. The result is 4.

;; 3

(call/cc (lambda (k0) ; Capture the current continuation as k0.
           (+ 1 (call/cc (lambda (k1) ; Capture the current continuation as k1.
                           (+ 1 (k1 3)))) ; Invoke k1 with 3, which jumps back to the inner call/cc and returns 3.
              (k0 1)))) ; Invoke k0 with 1, which jumps back to the outer call/cc and returns 1.

(newline)

(define x 0)

(let ([cc (call/cc (lambda (k) (k k)))]) ; Create a recursive continuation cc that captures itself.
  (set! x (+ 1 x)) ; Increment x by 1.
  (displayln x)  ; Print x.
  (if (< x 3) ; If x is less than 3, invoke the continuation cc.
      (cc cc) ; This will cause the code to loop back to the beginning of the let block.
      x)) ; Return x when the loop ends.

(newline)


(define *cont* '()) ; Global variable to store the continuation stack.
(define (return val) ((car *cont*) val)) ; Function to invoke the top continuation on a value.


;; implementation of RETURN
; (defret (fn x y) (body) (return))
(define-syntax defret ; Define a macro defret that creates a function with a return statement.
  (syntax-rules (return:) ; Define the syntax for the macro.
    [(_ (NAME ARGS ...) BODY ...) ; Define the macro pattern.
     (define (NAME ARGS ...) ; Define a function with the given name and arguments.
       (let ([result(call/cc (lambda (k) ;
                               (set! *cont* (cons k *cont*)) ; Push the current continuation onto the stack.
                               (displayln *cont*) ; Print the continuation stack.
                               (begin BODY ... )))]) ; Evaluate the body of the function.
         (set! *cont* (cdr *cont*)); Pop the continuation stack after the function completes.
         result) ; Return the result of the function.
       )])) ; Pop the continuation stack after the function completes.]))

(defret (gn x y) ; Define a function gn with arguments x and y.
  (if (= x 5) ; If x is equal to 5,
      (return 100000) ; Return 100000.
      (+ x y))) ; Otherwise, return the sum of x and y.


(defret (fn x y) ; Define a function fn with arguments x and y.
  (if (= x 5) ; If x is equal to 5,
      (return 42) ; Return 42.
      (+ x y))) ; Otherwise, return the sum of x and y.

(fn 3 (fn 5 (gn 5 0))) ; Call the fn function with arguments 3, 5, and the result of calling gn with arguments 5 and 0.
(fn 5 99)





;(for x from 1 to 10  BODY ...)

(define *for-cont* #f)

(define-syntax for ; Define a for loop macro.
  ( syntax-rules (from to) ; Define the syntax for the macro.
     [(_ X from MIN to MAX BODY ...) ; Define the macro pattern.
      (let loop ([X MIN]) ; Define a loop function with X starting at MIN.
        (when (< X MAX) ; When X is less than MAX,
          (call/cc ; Capture the current continuation.
           (lambda (k) ; Define a continuation function k. 
             (set! *for-cont* k) ; Store the continuation in the global variable *for-cont*.
             (begin ; Evaluate the body of the loop.
               BODY ... 
               ))) 
          (loop (+ X 1))))])) ; Increment X and loop back to the beginning.

(define (continue) (*for-cont*))

(for x from 1 to 10
  (if (= x 5)
      (continue)
      (displayln x)))

