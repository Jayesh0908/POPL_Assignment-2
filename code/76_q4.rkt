#lang racket/base

;; CS F301 Principles of Programming Languages - Assignment 2
;; S2: Conditionally Insert into a Nested List (Group 76)

;; my-length : list -> integer
;; Recursive reading: the length of an empty list is 0; otherwise, add 1
;; to the accumulator and recurse on the cdr (tail-recursive).
(define (my-length lst)
  (let loop ((xs lst) (acc 0))
    (if (null? xs)
        acc
        (loop (cdr xs) (+ acc 1)))))

;; my-reverse : list -> list
;; Recursive reading: reverse a list by consing each car onto an accumulator
;; until the input list is empty (tail-recursive).
(define (my-reverse lst)
  (let loop ((xs lst) (acc '()))
    (if (null? xs)
        acc
        (loop (cdr xs) (cons (car xs) acc)))))

;; my-map : (a -> b) list -> list
;; Recursive reading: apply f to each element of lst from left to right,
;; accumulating results in reverse order, then reverse once at the end
;; so flat 10,000-element lists run in O(1) stack space.
(define (my-map f lst)
  (let loop ((xs lst) (acc '()))
    (if (null? xs)
        (my-reverse acc)
        (loop (cdr xs) (cons (f (car xs)) acc)))))

;; my-list? : any -> boolean
;; Since inputs contain only atoms and proper lists (no dotted pairs),
;; a value is a list iff it is either the empty list or a pair.
(define (my-list? v)
  (or (null? v) (pair? v)))

;; make-inserter : atom (integer -> boolean) -> (list -> list)
;; Higher-order constructor returning a function that recursively traverses
;; a nested list, transforms every sublist, and prepends x to any list whose
;; original top-level length satisfies len-ok?.
(define (make-inserter x len-ok?)
  (letrec ((process-list
            (lambda (lst)
              (let ((orig-len (my-length lst))
                    (processed-elems
                     (my-map (lambda (elem)
                               (if (my-list? elem)
                                   (process-list elem)
                                   elem))
                             lst)))
                (if (len-ok? orig-len)
                    (cons x processed-elems)
                    processed-elems)))))
    process-list))

;; insert-if-short : atom list integer -> list
;; Inserts atom x at the front of every list (at every nesting level,
;; including the top-level list) whose original length is strictly less than n.
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))

;; print-insert-result : -> void
;; Reads x, lst, and n in order from standard input, applies insert-if-short,
;; and prints only the resulting list followed by a newline.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))
