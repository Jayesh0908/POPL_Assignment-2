---
name: scheme-s2-dev
description: Focused Scheme (Racket 8.x) skill file for CS F301 Assignment 2 Problem S2 (Conditionally Insert into a Nested List, 76_q4.rkt), including strict built-in constraints, coding conventions, testing workflow, self-review checklist, and known AI failure modes.
---

# S2 Scheme Development Skill (`scheme-s2-dev`)

## 1. Language, Runtime, and Submission Rules
- **Language & Version:** Racket 8.x using `#lang racket/base` on line 1.
- **Target File:** `code/76_q4.rkt`.
- **Definitions Only:** The file must contain **only** definitions. Do not execute top-level expressions, print anything on load, or add `(provide ...)` / `(require ...)`. The grader appends its own calls to the end of the file.
- **Decomposition Rule:** One prompt = one unit of work (one helper function, one core function, one refactor, one test file, or one review), mirrored by incremental Git commits.

---

## 2. S2 Allowed Built-ins (Strict Whitelist)
Only the following built-ins from `#lang racket/base` may be used in `76_q4.rkt`:

- **Core forms & bindings:** `define`, `lambda`, `let`, `let*`, `letrec`, named `let`, `if`, `cond` (with `else`), `and`, `or`, `not`, `begin`, `quote` (`'`).
- **List primitives:** `cons`, `car`, `cdr`, `list`, and all `car`/`cdr` compositions up to 4 levels (`cadr`, `cddr`, `caddr`, `cdddr`, `cadddr`, `cddddr`, etc.).
- **Predicates & association lists:** `null?`, `pair?`, `eq?`, `assq`, `assoc`.
- **Arithmetic & comparisons:** `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=`, `max`.
- **I/O (S2 allows `read`):** `read`, `display`, `newline`.

**Strictly Forbidden:** `set!` and all mutation forms, vectors, hash tables, strings, `do`, `for`/`for/*`, `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, `list-tail`, `list?`, `equal?`, `add1`, `sub1`, `provide`, `require`. Write custom helpers (`my-length`, `my-reverse`, `my-map`, `my-list?`) instead.

---

## 3. S2 Problem Invariants & Scale Requirements
- **Inputs:** Atom `x` (digit or symbol), proper nested list `lst` (no dotted pairs), and integer $n \ge 0$.
- **Original-length rule:** Each list's length is its number of top-level elements (atoms or sublists) measured on the **original** list before any insertion occurs.
- **Uniform list treatment:** Both the top-level list and empty lists `'()` are treated like any other list. Since `'()` has length $0$, it becomes `(x)` whenever $0 < n$.
- **Higher-order requirement (S2.c):** Define `(make-inserter x len-ok?)` returning a 1-argument function, and keep only a **single** definition of `(insert-if-short x lst n)` implemented via `make-inserter`.
- **I/O requirement (S2.a):** `(print-insert-result)` takes no arguments, reads `x`, `lst`, and `n` in exact order from standard input using `read`, prints the resulting list with `display` followed by `newline`, and prints no prompt or extra text.
- **Scale limits:** Must handle nesting depth $100$ and flat lists of $10{,}000$ elements cleanly and without stack overflow.

---

## 4. Coding Conventions
- **Naming:** Use lowercase `kebab-case`. Prefix custom standard-library replacements with `my-` (`my-length`, `my-reverse`, `my-map`, `my-list?`), and end boolean predicates with `?` (`my-list?`, `len-ok?`).
- **Comments & Recursive Readings:** Preceding every top-level `define`, include:
  1. A short type signature comment (e.g., `;; my-length : list -> non-negative integer`).
  2. A clear **recursive reading** describing the base case, recursive step, and accumulator invariant (for tail-recursive loops).
- **Tail Recursion:** Use named `let` with an accumulator for all linear list traversals (`my-length`, `my-reverse`, `my-map`) so $10{,}000$-element lists run in $O(1)$ stack space.
- **Sequenced `read`:** Always use `let*` (never `let`) when binding consecutive `(read)` calls to guarantee left-to-right input order.
- **Pure Functional Style:** Pass all state through function parameters; never mutate bindings or lists.

---

## 5. How to Run and Test Code
1. **Verify silent load (must print nothing and exit 0):**
   ```bash
   racket code/76_q4.rkt
   ```
2. **Run the full S2 test suite (examples, edge cases, depth 100, 10,000 elements):**
   ```bash
   racket tests/test_q4.rkt
   ```
3. **Manual I/O test (simulating grader execution of `print-insert-result`):**
   ```bash
   printf '42 ((1 2) (3 4 5) (6) ()) 3\n' | racket -e '(load "code/76_q4.rkt")'
   ```
   *(Or inspect via `tests/test_q4.rkt`, which uses `dynamic-require` and `module->namespace` so `code/76_q4.rkt` stays free of `provide`.)*

---

## 6. Self-Review Checklist (Run Before Accepting Any Output)
- [ ] Line 1 is `#lang racket/base`, and the file produces zero output when executed with `racket code/76_q4.rkt`.
- [ ] Every identifier is either locally defined, a bound parameter, or explicitly listed in Section 2.
- [ ] Zero occurrences of `length`, `map`, `reverse`, `append`, `list?`, `equal?`, `add1`, `sub1`, `set!`, `provide`, `require`, vectors, strings, or `for` loops.
- [ ] `my-length`, `my-reverse`, and `my-map` are tail-recursive and tested on a $10{,}000$-element list.
- [ ] Deeply nested lists up to depth $100$ are handled accurately.
- [ ] `'()` is recognized as a list of length $0$ (both nested and at the top level), and `n = 0` inserts nothing.
- [ ] There is exactly **one** definition of `insert-if-short`, defined using `make-inserter`.
- [ ] `print-insert-result` uses `let*` to read `x`, `lst`, `n` in order and prints only `(display result)` followed by `(newline)`.
- [ ] Every function has a type signature and recursive reading comment.

---

## 7. Known AI Failure Modes for Scheme / S2
1. **Using forbidden built-ins:** AI models commonly slip in `list?`, `length`, `map`, `reverse`, `append`, `equal?`, or `add1`/`sub1`. Audit every symbol against the whitelist.
2. **Wrong `#lang` header or adding `provide`:** Using `#lang racket` or adding `(provide ...)` violates the `#lang racket/base` definitions-only rule.
3. **Using `let` instead of `let*` for `read`:** Parallel `let` bindings do not guarantee sequential evaluation order for `(read)` calls; `x`, `lst`, and `n` can be read out of order.
4. **Non-tail-recursive `my-map` or `my-length`:** Naive recursion uses $O(N)$ stack space and risks slowdowns or stack exhaustion on $10{,}000$-element lists. Always accumulate in reverse and call tail-recursive `my-reverse`.
5. **Treating `'()` as an atom instead of a list:** Checking only `(pair? elem)` skips nested empty lists `'()`, breaking cases like `(insert-if-short 42 '(()) 3)`. Use `(or (null? val) (pair? val))`.
6. **Checking length after inserting `x` or forgetting the top-level list:** Length must be checked on the original list, and the top-level list itself must also receive `x` if its length satisfies `len-ok?`.
7. **Leaving two definitions of `insert-if-short`:** S2.b introduces a direct version and S2.c refactors it to use `make-inserter`; leaving both in `76_q4.rkt` causes a duplicate definition error.