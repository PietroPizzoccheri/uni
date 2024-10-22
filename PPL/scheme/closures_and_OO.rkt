#lang racket

; CLOSURES

(define (make-counter) ; returns a function
  (let ([count 0]) ; count is kept alive by the closure
    (lambda () ; returns a function
      (set! count (+ count 1)) ; increments count
      count))) ; returns count

(define counter1 (make-counter)) ; counter1 is a function
(define counter2 (make-counter)) ; counter2 is a function

(displayln (counter1)) ; displays 1
(displayln (counter1)) ; displays 2
(displayln (counter2)) ; displays 1
(displayln (counter1)) ; displays 3
(displayln (counter2)) ; displays 2

; OBJECT-ORIENTED PROGRAMMING

; class person with name and age attributes and constructor

(define (new-person
         init-name
         init-age)
  ;state
  (let ([name init-name]
        [age init-age])
    ;method (public)
    (define (get-name)
      name)
    (define (get-age)
      age)
    (define (grow-older years)
      (set! age (+ age years))
      age)
    (define (show)
      (printf "Name: ~a, Age: ~a\n" name age))
    ;dispatcher - displays results
    (lambda (msg . args)
      (apply (case msg
               [(get-name) get-name]
               [(get-age) get-age]
               [(grow-older) grow-older]
               [(show) show]
               [else (error "unknown message")])
             args))))

(define ada (new-person "Ada" 25))
(define bob (new-person "Bob" 24))

(ada 'grow-older 10) ; returns 35
(bob 'get-name) ; returns "Bob"

(ada 'show) ; displays "Name: Ada, Age: 35"

;inheritance

(define (new-superhero name age init-power)
  (let([parent(new-person name age)]
       [power init-power])
    (define (use-power)
      (printf "~a uses ~a\n" name power))
    (define (show)
      (parent 'show)
      (printf "Power: ~a\n" power))
    (lambda (msg . args)
      (case msg
        [(use-power) (apply use-power args)]
        [(show) (apply show args)]
        [else (apply parent (cons msg args))]))))

(define superman (new-superhero "Clark" 32 "flight"))

(superman 'use-power) ; displays "Clark uses flight"



; Hash Maps

; protoype approch to OO

(define new-obj make-hash)
(define clone hash-copy)

(define-syntax-rule ; SET
  (obj-set object msg new-val)
  (hash-set! object 'msg new-val))

(define-syntax-rule ; GET
  (obj-get object msg)
  (hash-ref object 'msg))

(define-syntax-rule ; SEND
  (obj-send object msg args ...)
  ((hash-ref object 'msg) object args ...))


(define carl (new-obj)) ; creates a new object (hashmap)

(obj-set carl name "Carl") ; sets the name attribute of carl to "Carl"

(obj-set carl show
         (lambda (self)
           (printf "Name: ~a\n" (obj-get self name)))) ; sets the show method of carl

(obj-set carl greet
         (lambda (self to)
           (printf "Name: ~a says hi to ~a\n" (obj-get self name) to))) ;  sets the greet method of carl

(obj-send carl show) ; displays "Name: Carl"

(obj-send carl greet "Alice") ; displays "Name: Carl says hi to Alice"

(define dan (clone carl)) ; clones carl

((obj-get dan show) dan) ; displays "Name: Carl"

(obj-set dan name "Dan") ; sets the name attribute of dan to "Dan"

((obj-get dan show) dan) ; displays "Name: Dan"

(obj-send carl greet (obj-get dan name)) ; displays "Name: Carl says hi to Dan"

; Javascript-like

(define-syntax obj-create
  (syntax-rules ()
    [(_)
     (make-hash '(["__proto__" . #f]))]
    [(_ PROTOTYPE)
     (make-hash (list [cons "__proto__" PROTOTYPE]))]))

;SET
(define (obj-set-js object key new-val)
  (hash-set! object key new-val))

;GET
(define (obj-get-js object key)
  (hash-ref object key))

;GET PROTOTYPE
(define (obj-get-prototype object)
  (hash-ref object "__proto__"))

;
(define (obj-find object key)
  (hash-ref object key
            (lambda ()
              (let ([protoype (obj-get-prototype object)])
                (when protoype
                  (obj-find protoype key))))))

(define-syntax-rule
  (obj-call object key args ...)
  (let ([method (obj-find object key)])
    (when (not (void? method))
      (method object args ...))))


(define Object (obj-create))
(obj-set-js Object "toString"
            (lambda (self)
              (displayln "[object Object]")))
Object
(define String (obj-create Object))
((obj-call Object "toString"))
String

