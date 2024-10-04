#lang racket




; STRUCTS

(struct person
  (name
   [age #:mutable]))

(define p1 (person "Ada" 24))
(define p2 "Bob")

(person? p2) ; false

(set-person-age! p1 25)

(person-age p1) ; 25




; TREES

(struct node
  ([value #:mutable]))

;BINARY TREE
(struct branch-node node
  (left right))

(define (leaf? n)
  (and (node? n) (not (branch-node? n))))

(define my-tree
  (branch-node 2
               (branch-node 3
                            (node 4)
                            (node 2))
               (node 1)))

(define (print-tree n)
  (displayln(node-value n))
  (unless (leaf? n)
    (print-tree (branch-node-left n))
    (print-tree (branch-node-right)))) ; 2 3 4 2 1 in vertical

;tree-apply f n
(define (tree-apply f n)
  (set-node-value! n (f (node-value n)))
  (when (branch-node? n)
    (tree-apply f (branch-node-left n))
    (tree-apply f (branch-node-right n))))

(tree-apply (lambda (x) (+ 1 x)) my-tree)




; MACROS

(define (my-and x . xs)
  (display x)(display " | ")(displayln xs)
  (if (null? xs)
      x
      (if x
          (apply my-and xs)
          #f)))



(define-syntax my-and-macro
  (syntax-rules (&&)
    [(my-and-macro) #t]
    [(my-and-macro EXPR) EXPR]
    [(my-and-macro EXPR OTHER-EXPRS ...)
     (if (EXPR)
         (my-and-macro OTHER-EXPRS ...)
         #f)]))

(my-and-macro #t #f (even? 42) "a") ; if the and is true returns "a"


; (report-f expr)
; print the expr ; (* 1 2 3 4)
; return the expr ; 24

(define (report-f expr)
  (displayln expr)
  expr)

(report-f (* 1 2 3 4))

(define x 0)

; (while (< x 10) break:break
;        (if (= x 7)
;            (break)
;            (set! x (= 1 x))))

; (for x in '(1 2 4)
;   (displayln x))



(defn my-func
  ([] (display "0 args!!"))
  ([a] (display "1 arg!"))
  ([a b] (displayln "2 args!!")))


(define-syntax defn
  (syntax-rules ()
    [(defn NAME (PARAMS BODY ...))
     (displayln 'NAME)
     (display "Params: ")(displayln '('PARAMS ...))
     (display "Body: ")(displayln '('BODY ...))
     (define (NAME . arg-v)
       (display "Calling ")(display 'NAME)(display arg-v))
     (let ([arg-n (length arg-v)])
       (cond
         [(= arg-n (length 'PARAMS))
          (apply (lambda PARAMS BODY) arg-v)])...)
     ]))