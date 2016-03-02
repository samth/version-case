(module test-version-case mzscheme
  (require "version-case.ss")


  ;; Small test code to see that we can write unit-dependent code
  ;; that still runs under both 360 and 369.

  ;; version-case should be usable in expression position
  (printf "~s~n" (version-case [(version= (version) "360")
                                "360"]
                               [else
                                "something else"]))


  ;; Ellipses should work in a version case.
  (printf "~s~n"
          (map syntax-e (syntax->list
                         (version-case 
                          (#f blah)
                          (else 
                           (syntax-case (syntax (foo bar)) ()
                             [(x ...) 
                              (syntax (x ...))]))))))
  ;; we expect '(foo bar)


  (version-case
   [(version<= (version) "360")
    (printf "old unit code~n")
    (require (lib "mred.ss" "mred")
             (lib "tool.ss" "drscheme")
             (lib "unitsig.ss"))
    
    (define tool@
      (unit/sig drscheme:tool-exports^
          (import drscheme:tool^)
        (define (phase1)
          (message-box "phase1"))
        (define (phase2)
          (message-box "phase2"))))]
   
   [else
    (printf "new unit code~n")
    (require scheme/gui/base
             (lib "tool.ss" "drscheme")
             (lib "unit.ss"))
    (define-unit tool@
      (import drscheme:tool^)
      (export drscheme:tool-exports^)
      (define (phase1)
        (message-box "phase1"))
      (define (phase2)
        (message-box "phase2")))]))