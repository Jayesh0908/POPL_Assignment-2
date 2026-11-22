#lang racket

;; CS F301 Principles of Programming Languages - Assignment 2
;; Test suite for S2: Conditionally Insert into a Nested List (Group 76)
;; Run from repo root: racket tests/test_q4.rkt

(require racket/runtime-path)

(define-runtime-path code-path-in-repo "../code/76_q4.rkt")
(define-runtime-path code-path-local "76_q4.rkt")

(define solution-path
  (cond
    [(file-exists? code-path-in-repo) code-path-in-repo]
    [(file-exists? code-path-local) code-path-local]
    [else
     (error 'test_q4
            "Could not find 76_q4.rkt at ../code/76_q4.rkt or ./76_q4.rkt")]))

(define mod-path `(file ,(path->string solution-path)))

;; Test counters
(define passed 0)
(define failed 0)

(define (check-equal name actual expected)
  (if (equal? actual expected)
      (begin
        (set! passed (+ passed 1))
        (printf "[PASS] ~a~n" name))
      (begin
        (set! failed (+ failed 1))
        (printf "[FAIL] ~a~n  expected: ~s~n  actual:   ~s~n"
                name expected actual))))

;; 1. Verify silent loading (no top-level output when file is loaded)
(define load-output
  (with-output-to-string
    (lambda ()
      (dynamic-require mod-path #f))))

(check-equal "Silent load (no top-level printing)" load-output "")

;; Extract module-internal bindings without needing (provide ...) in 76_q4.rkt
(define ns (module->namespace mod-path))
(define my-length (eval 'my-length ns))
(define my-map (eval 'my-map ns))
(define make-inserter (eval 'make-inserter ns))
(define insert-if-short (eval 'insert-if-short ns))
(define print-insert-result (eval 'print-insert-result ns))

;; Helper to test print-insert-result via simulated stdin/stdout
(define (run-io input-str)
  (with-output-to-string
    (lambda ()
      (with-input-from-string input-str
        (lambda ()
          (print-insert-result))))))

;; 2. Unit tests for my-length and my-map
(check-equal "my-length empty" (my-length '()) 0)
(check-equal "my-length flat" (my-length '(a b c d)) 4)
(check-equal "my-length nested (top-level only)" (my-length '((1 2) () (3 (4 5)))) 3)

(check-equal "my-map empty" (my-map (lambda (v) (+ v 1)) '()) '())
(check-equal "my-map order preserved" (my-map (lambda (v) (* v 2)) '(1 2 3 4)) '(2 4 6 8))

;; 3. Official PDF examples (direct function calls)
(check-equal "PDF Example 1 (direct)"
             (insert-if-short 42 '((1 2) (3 4 5) (6) ()) 3)
             '((42 1 2) (3 4 5) (42 6) (42)))

(check-equal "PDF Example 2 (direct)"
             (insert-if-short 0 '(((1) 2) (3) ((4 5 6) ())) 3)
             '((0 (0 1) 2) (0 3) (0 (4 5 6) (0))))

(check-equal "PDF Example 3 (direct)"
             (insert-if-short 7 '() 3)
             '(7))

(check-equal "PDF Example 4 (direct)"
             (insert-if-short 7 '() 0)
             '())

;; 4. Official PDF examples (stdin/stdout via print-insert-result)
(check-equal "PDF Example 1 (I/O)"
             (run-io "42 ((1 2) (3 4 5) (6) ()) 3
")
             "((42 1 2) (3 4 5) (42 6) (42))
")

(check-equal "PDF Example 2 (I/O)"
             (run-io "0 (((1) 2) (3) ((4 5 6) ())) 3
")
             "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))
")

(check-equal "PDF Example 3 (I/O)"
             (run-io "7 () 3
")
             "(7)
")

(check-equal "PDF Example 4 (I/O)"
             (run-io "7 () 0
")
             "()
")

;; 5. Edge cases (symbols, boundary n, top-level insertion, n = 0)
(check-equal "Symbol atoms and nested empty lists"
             (insert-if-short 'x '((a b) c ()) 3)
             '((x a b) c (x)))

(check-equal "Top-level list shorter than n"
             (insert-if-short 'x '((a) (b)) 3)
             '(x (x a) (x b)))

(check-equal "Top-level length equals n (no top-level insert)"
             (insert-if-short 9 '((1) (2)) 2)
             '((9 1) (9 2)))

(check-equal "n = 0 never inserts anywhere"
             (insert-if-short 9 '(() (1) ((2) ())) 0)
             '(() (1) ((2) ())))

(check-equal "I/O with symbol atom"
             (run-io "tag ((a) (b c d) ()) 2
")
             "((tag a) (b c d) (tag))
")

;; 6. Higher-order make-inserter tests
(define insert-into-empty (make-inserter 'e (lambda (len) (= len 0))))
(check-equal "make-inserter only empty lists"
             (insert-into-empty '(() (1 ()) (2 3)))
             '((e) (1 (e)) (2 3)))

(define insert-into-even (make-inserter 'ev (lambda (len) (= (remainder len 2) 0))))
(check-equal "make-inserter even-length lists"
             (insert-into-even '((1 2) (3) ()))
             '((ev 1 2) (3) (ev)))

(define insert-never (make-inserter 'z (lambda (len) #f)))
(check-equal "make-inserter always false"
             (insert-never '(() (1) (2 (3))))
             '(() (1) (2 (3))))

;; 7. Stress test: nesting depth 100
(define (make-deep depth)
  (let loop ((d depth) (acc '()))
    (if (= d 0)
        acc
        (loop (- d 1) (list acc)))))

(define deep-100 (make-deep 100))

;; With n = 2, every level (outer 100 of len 1, innermost of len 0) gets 'a
(define deep-res-2 (insert-if-short 'a deep-100 2))
(define deep-2-ok
  (let loop ((d 100) (cur deep-res-2))
    (if (= d 0)
        (equal? cur '(a))
        (and (pair? cur)
             (eq? (car cur) 'a)
             (= (length cur) 2)
             (loop (- d 1) (cadr cur))))))
(check-equal "Stress: depth 100 with n = 2" deep-2-ok #t)

;; With n = 1, only the innermost empty list gets 'a
(define deep-res-1 (insert-if-short 'a deep-100 1))
(define deep-1-ok
  (let loop ((d 100) (cur deep-res-1))
    (if (= d 0)
        (equal? cur '(a))
        (and (pair? cur)
             (= (length cur) 1)
             (loop (- d 1) (car cur))))))
(check-equal "Stress: depth 100 with n = 1" deep-1-ok #t)

;; 8. Stress test: 10,000-element flat list
(define big-10k (build-list 10000 values))
(define big-res-insert (insert-if-short 99 big-10k 10001))
(define big-res-no-insert (insert-if-short 99 big-10k 10000))

(check-equal "Stress: 10,000 elements with n = 10001 (inserted)"
             (and (= (length big-res-insert) 10001)
                  (= (car big-res-insert) 99)
                  (equal? (cdr big-res-insert) big-10k))
             #t)

(check-equal "Stress: 10,000 elements with n = 10000 (unchanged)"
             (equal? big-res-no-insert big-10k)
             #t)

;; Summary
(printf "~nPassed: ~a, Failed: ~a~n" passed failed)
(when (> failed 0)
  (exit 1))
