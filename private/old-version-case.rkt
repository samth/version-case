(module old-version-case mzscheme
  (require-for-syntax (prefix m: "../version-misc.ss"))
  (provide version-case)

  
  (define-for-syntax usage-message "Usage: (version-case [test code] ... [else ...]))")
  
  
  (define-syntax (version-case stx)
    (syntax-case stx ()
      [(_ [test code ...] ... [-else last-code ...])
       (and (not (null? (syntax->list (syntax ((test code ...) ...)))))
            (identifier? #'-else)
            (eq? (syntax-e #'-else) 'else))
       (with-syntax ([name (syntax/loc stx the-macro)]
                     [version<= (datum->syntax-object stx 'version<=)]
                     [version< (datum->syntax-object stx 'version<)]
                     [version= (datum->syntax-object stx 'version=)]
                     [version>= (datum->syntax-object stx 'version>=)]
                     [version> (datum->syntax-object stx 'version>)]                                         
                     [transformer
                      (syntax/loc stx
                        (lambda (stx*)
                          (cond [test
                                 (syntax-local-introduce
                                  (quote-syntax (begin code ...)))]
                                ...
                                [else (syntax-local-introduce
                                       (quote-syntax (begin last-code ...)))])))])
         (case (syntax-local-context)
           [(expression)
            (syntax/loc stx
              (begin
                (let-syntax ([version<= m:version<=]
                             [version< m:version<]
                             [version= m:version=]
                             [version>= m:version>=]
                             [version> m:version>]
                             [name transformer])
                  (name))))]
           [else
            (begin
              (syntax/loc stx
                (begin
                  (define-for-syntax version<= m:version<=)
                  (define-for-syntax version< m:version<)
                  (define-for-syntax version= m:version=)
                  (define-for-syntax version>= m:version>=)
                  (define-for-syntax version> m:version>)
                  (define-syntax name transformer)
                  (name))))]))]
      [else
       (raise-syntax-error 
        #f 
        usage-message
        stx)])))