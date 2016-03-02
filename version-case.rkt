(module version-case mzscheme
  (require-for-syntax "version-misc.ss")

  ;; version-case: SYNTAX
  ;; Conditionally include code based on current version number.
  ;; Usage:
  ;;
  ;; (version-case [clause code] ... 
  ;;               [else ...])
  ;;
  ;; where clause has access to the mzscheme primitives.  In addition,
  ;; the following functions are available:
  ;;
  ;;     version<=: string string -> boolean
  ;;     version>=: string string -> boolean
  ;;     version=: string string -> boolean
  ;;     version<: string string -> boolean
  ;;     version>: string string -> boolean
  ;;
  ;; to make it easier to build the conditional clauses.


  ;; We choose at compile time of version-case which implementation can be used.
  (define-syntax (choose-version-case-implementation stx)
    (cond
     [(version< (version) "399")
      (syntax/loc stx 
        (begin
          (require "private/old-version-case.ss")
          (provide (all-from "private/old-version-case.ss"))))]
     [else
      (syntax/loc stx
        (begin
          (require "private/new-version-case.ss")
          (provide (all-from "private/new-version-case.ss"))))]))


  (choose-version-case-implementation))