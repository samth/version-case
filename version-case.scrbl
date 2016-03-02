#lang scribble/manual
@(require (for-label racket version-case))


@title{version-case: conditionally compile code based on current version number}
@author[@author+email["Danny Yoo" "dyoo@hashcollision.org"]
        @author+email["Sam Tobin-Hochstadt" "samth@racket-lang.org"]]

@centered{@smaller{Source code can be found at:
@url{https://github.com/samth/version-case}.}}



This library provides support for conditionally compiling code based
on the version of Racket.  One common application of this module is to
write compatibility bindings.



@section{Example}

The following example shows how one can write unit code that works
with both the old and new @racket[unit] libraries.


@racketblock[
(module some-sample-unit-code mzscheme
  (require (planet "version-case.ss" ("dyoo" "version-case.plt" 1))
           (lib "mred.ss" "mred"))
  
  ;; Small test code to see that we can write unit-dependent code
  ;; that still runs under both 360 and 369.
  
  (version-case
   [(version<= (version) "360")
    (printf "old unit code~n")
    (require (lib "tool.ss" "drscheme")
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
    (require (lib "tool.ss" "drscheme")
             (lib "unit.ss"))
    (define-unit tool@
      (import drscheme:tool^)
      (export drscheme:tool-exports^)
      (define (phase1)
        (message-box "phase1"))
      (define (phase2)
        (message-box "phase2")))]))]
                

Another simple example:
@codeblock|{
#lang racket/base
(require version-case
         (for-syntax racket/base))
(printf "~a~n" (version-case [(version<= (version) "4")
                              'huh?]
                             [else
                              'ok]))}|


@section{Usage}
@defmodule[version-case]
@defform[(version-case [test code ...]
                       ... 
                       [else code ...])]
@racket[version-case] is a macro that expands out to one of the
@racket[code] blocks, depending on which test succeeds first.  The
@racket[test] expression is evaluated at compile-time.  Some
version-comparing functions are available for convenience.

@defproc[(version< [v1 string?] [v2 string?]) boolean?]{
Returns true if @racket[v1] is less than @racket[v2].
}
@defproc[(version<= [v1 string?] [v2 string?]) boolean?]{
Returns true if @racket[v1] is less than or equal to @racket[v2].
}
@defproc[(version= [v1 string?] [v2 string?]) boolean?]{
Returns true if @racket[v1] is equal to @racket[v2].
}
@defproc[(version> [v1 string?] [v2 string?]) boolean?]{
Returns true if @racket[v1] is greater than @racket[v2].
}
@defproc[(version>= [v1 string?] [v2 string?]) boolean?]{
Returns true if @racket[v1] is greater than or equal to @racket[v2].
}





@section{Gotchas}

The tests are done at compile time.  If the language of your module
doesn't include compile-time bindings for function application, you
may see funny error messages.  For example, @racket[scheme/base]
doesn't automatically provide the necessary compile-time bindings, so
if you use @racket[version-case] with it, you also need to do a
@racket[(require (for-syntax scheme/base))].



@section{Thanks}

Special thanks to Carl Eastlund providing the implementation that
doesn't use @racket[eval], and for feedback.  Thanks also to Ambjorn
Elder for noticing a bug regarding the use of syntax-case within a
version-case's body.
