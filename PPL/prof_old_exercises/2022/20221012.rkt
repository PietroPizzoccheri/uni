#lang racket

(struct node-base
  ((value #:mutable)))

(struct node node-base
  (left
   right))

(define node-nil (node-base #f))
(define (node-nil? n)
  (eq? node-nil n))

(define t (node 1
                (node 2
                      (node-base 4)
                      (node-base 5))
                (node-base 3)))

(define t1 (list 'node 1
                (list 'node 2
                      (list 'node-base 4)
                      (list 'node-base 5))
                (list 'node-base 3)))

(define tt (node 1
                 (node-base 2)
                 (node 3
                       (node 4
                             (node-base 5)
                             node-nil)
                       node-nil)))

(define (leaf? n)
  (and (node-base? n)
       (not (node? n))))

(define (tree-display tree)
  (cond
    ((node-nil? tree) (display "[]"))
    ((leaf? tree) (begin
                    (display "[")
                    (display (node-base-value tree))
                    (display "]")))
    (else
     (begin
       (display "[")
       (display (node-base-value tree))
       (display " ")
       (tree-display (node-left tree))
       (display " ")
       (tree-display (node-right tree))
       (display "]")))))
       

(define (tree-map f tree)
  (cond
    ((node-nil? tree) node-nil)
    ((leaf? tree) (node-base (f (node-base-value tree))))
    ((node? tree) (node
                   (f (node-base-value tree))
                   (tree-map f (node-left tree))
                   (tree-map f (node-right tree))))
    (else (error "not a tree"))))

(define (tree-map! f tree)
  (cond
    ((node-nil? tree) "ah!")
    ((leaf? tree) (set-node-base-value! tree (f (node-base-value tree))))
    ((node? tree) (begin
                   (set-node-base-value! tree (f (node-base-value tree)))
                   (tree-map! f (node-left tree))
                   (tree-map! f (node-right tree))))
    (else (error "not a tree"))))

(define x 10)
;(define (++ x)
;  (set! x (+ x 1))
;  x)

(define-syntax ++
  (syntax-rules ()
    ((_ var)
     (begin
       (set! var (+ var 1))
       var))))

(define (test)
  (let ((x 3))
    (++ x)))

; (proj 3 e1 e2 e3 ...)
; e3

(define (proj-f n . rest)
  (list-ref rest n))

(define (fact n)
  (if (= n 0)
      1
      (* n (fact (- n 1)))))

(define-syntax proj-m
  (syntax-rules ()
    ((_ n v1)
     v1)
    ((_ n v1 v2 ...)
     (if (= n 0)
         v1
         (proj-m (- n 1) v2 ...)))))

(define-syntax define-with-types
  (syntax-rules (:)
    ((_ (f : tf (x1 : t1) ...) e1 ...)
     (define (f x1 ...)
       (if (and (t1 x1) ...)
           (let ((res (begin
                        e1 ...)))
             (if (tf res)
                 res
                 (error "bad return type")))
           (error "bad input types"))))))

(define-with-types (add-to-char : integer? (x : integer?) (y : char?))
  (+ x (char->integer y)))

