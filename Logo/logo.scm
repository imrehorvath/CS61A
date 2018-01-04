;;; logo.scm         part of programming project #4


;;; Problem A1   make-line-obj

(define-class (line-obj line)
  (method (empty?)
	  (null? line))
  (method (next)
	  (if (ask self 'empty?)
	      (logo-error "Next called on empty line" self)
	      (let ((token (car line)))
		(set! line (cdr line))
		token)))
  (method (put-back token)
	  (set! line (cons token line))))

(define (make-line-obj text)   
  (instantiate line-obj text)) 


;;; Problem A2   logo-type

(define (logo-type val)   
  (cond ((null? val)
	 '=no-value=)
	((pair? val)                  ;; list
	 (cond ((pair? (car val))     ;; sub-list
		(display "[")
		(logo-type (car val))
		(display "]"))
	       ((null? (car val))     ;; empty list
		(display "[]"))
	       (else                  ;; word
		(display (car val)))) 
	 (if (not (null? (cdr val)))
	     (display " "))
	 (logo-type (cdr val)))
	(else                         ;; word
	 (display val)
	 '=no-value=)))

(define (logo-print val)   
  (logo-type val)  
  (newline) 
  '=no-value=) 

(define (logo-show val)   
  (logo-print (list val)))   



;; Read a line and turn it into a list

(define (readlist)
  (logo-read))


;; Apply template to arguments

(define (apply-template env template inputlist)
  (define (expand-slots template)
    (if (null? template)
	'()
	(cond ((and (symbol? (car template))
		    (eq? (first (car template)) '?)
		    (number? (bf (car template))))    ;;; expand ?<num> into (? <num>)
	       (cons left-paren-symbol
		     (cons '?
			   (cons (bf (car template))
				 (cons right-paren-symbol
				       (expand-slots (cdr template)))))))
	      ((list? (car template))
	       (cons (expand-slots (car template))
		     (expand-slots (cdr template))))
	      (else
	       (cons (car template)
		     (expand-slots (cdr template)))))))
  (define (transform inputlist tail)
    (define (transform1 inputlist n)
      (if (null? inputlist)
	  tail
	  (cons (word '? n)
		(transform1 (cdr inputlist) (+ n 1)))))
    (transform1 inputlist 1))
  (cond ((list? template)
	 (let ((ext-env (extend-environment
			 '(template.inputs)
			 (list inputlist)
			 env)))
	   (run ext-env (expand-slots template))))
	((symbol? template)
	 (apply-template env
			 (cons left-paren-symbol
			       (cons template
				     (transform inputlist
						(list right-paren-symbol))))
			 inputlist))
	(else
	 (logo-error "Invalid argument to APPLY-TEMPLATE" template))))


;;; Problem 4   variables   (logo-meta.scm is also affected)

(define (make env var val) 
  (set-variable-value! var val env)
  '=no-value=) 


;;; Here are the primitives RUN, IF, and IFELSE.  Problem B2 provides
;;; support for these, but you don't have to modify them.   

(define (exp->instruction-list exp)
  (cond ((list? exp) exp)
	((word? exp) (list exp))
	(else (logo-error "EXP->INSTRUCTION-LIST" exp))))

(define (run env exp)
  (eval-line (make-line-obj (exp->instruction-list exp))
	     env))

(define (logo-if env t/f exp) 
  (cond ((eq? t/f 'true)
	 (eval-line (make-line-obj (exp->instruction-list exp))
		    env))
        ((eq? t/f 'false) '=no-value=)
        (else (logo-error "Input to IF not TRUE or FALSE " t/f))))

(define (ifelse env t/f exp1 exp2)  
  (cond ((eq? t/f 'true)
	 (eval-line (make-line-obj (exp->instruction-list exp1))
		    env))
        ((eq? t/f 'false)
	 (eval-line (make-line-obj (exp->instruction-list exp2))
		    env))
        (else (logo-error "Input to IFELSE not TRUE or FALSE " t/f))))

;;; Problem B8   TEST, IFTRUE and IFFALSE

(define (test env t/f)
  (cond ((eq? t/f 'true)
	 (define-variable! " TEST" t/f env)
	 '=no-value=)
	((eq? t/f 'false)
	 (define-variable! " TEST" t/f env)
	 '=no-value=)
	(else (logo-error "Input to TEST not TRUE or FALSE" t/f))))

(define (iftrue env exp)
  (let ((binding (lookup-variable-binding " TEST" env)))
    (cond ((null? binding)
	   (logo-error "IFTRUE/IFT can only be used after a TEST"))
	  ((eq? (cdr binding) 'true)
	   (eval-line (make-line-obj (exp->instruction-list exp))
		      env))
	  (else '=no-value=))))

(define (iffalse env exp)
  (let ((binding (lookup-variable-binding " TEST" env)))
    (cond ((null? binding)
	   (logo-error "IFFALSE/IFF can only be used after a TEST"))
	  ((eq? (cdr binding) 'false)
	   (eval-line (make-line-obj (exp->instruction-list exp))
		      env))
	  (else '=no-value=))))

;; Local

(define (local env var)
  (cond ((word? var)
	 (define-variable! var '=unassigned= env)
	 '=no-value=)
	((list? var)
	 (for-each (lambda (v) (define-variable! v '=unassigned= env))
		   var)
	 '=no-value=)
	(else (logo-error "LOCAL invalid argument" var))))


(define (thing env var)
  (lookup-variable-value var env))

(define (logo-not t/f)
  (cond ((eq? t/f 'true) 'false)
	((eq? t/f 'false) 'true)
	(else (logo-error "NOT called with not a TRUE/FALSE value" t/f))))

;;; Problem B2   logo-pred

(define (logo-pred pred)   
  (lambda args (if (apply pred args)
		   'true
		   'false)))

;;; Here is an example of a Scheme predicate that will be turned into  
;;; a Logo predicate by logo-pred:  

(define (equalp a b)
  (if (and (number? a) (number? b))  
      (= a b)   
      (equal? a b)))   

(define (namep env var)
  (not (null? (lookup-variable-binding var env))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;  Stuff below here is needed for the interpreter to work but you  ;;;  
;;;  don't have to modify anything or understand how they work.      ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 


;;; The Logo reader

(define left-paren-symbol (string->symbol (make-string 1 #\( )))
(define right-paren-symbol (string->symbol (make-string 1 #\) )))
(define quote-symbol (string->symbol (make-string 1 #\" )))

(define (logo-read)  
  (define lookahead #f)   
  (define (logo-read-help depth)   
    (define (get-char)  
      (if lookahead  
          (let ((char lookahead))   
            (set! lookahead #f)   
            char) 
          (let ((char (read-char)))   
            (if (eq? char #\\)
                (list (read-char))  
                char)))) 
    (define (quoted char)   
      (if (pair? char)   
          char 
          (list char)))  
    (define (get-symbol char)   
      (define (iter sofar char)
        (cond ((pair? char) (iter (cons (car char) sofar) (get-char))) 
              ((memq char  
                     '(#\space #\newline #\+ #\- #\* #\/  
                               #\= #\< #\> #\( #\) #\[ #\] #\~ ))
               (set! lookahead char)   
               sofar) 
              (else (iter (cons char sofar) (get-char))) ))   
      (string->word (list->string (reverse (iter '() char)))) )
    (define (get-token space-flag)   
      (let ((char (get-char)))   
              (cond ((eq? char #\space) (get-token #t))  
              ((memq char '(#\+ #\* #\/ #\= #\< #\> #\( #\) ))   
               (string->symbol (make-string 1 char)))
              ((eq? char #\-)   
               (if space-flag  
                   (let ((char (get-char)))   
                     (let ((result (if (eq? char #\space)  
                                       '- 
                                       '=unary-minus=))) 
                       (set! lookahead char)   
                       result)) 
                   '-)) 
              ((eq? char #\[) (logo-read-help (+ depth 1)))  
              ((pair? char) (get-symbol char))
              ((eq? char #\")   
               (let ((char (get-char)))   
                 (if (memq char '(#\[ #\] #\newline #\space))  
                     (begin (set! lookahead char) quote-symbol)
                     (string->symbol (word quote-symbol
					   (get-symbol (quoted char)))))))
	      (else (get-symbol char)) )))

    (define (after-space)
      (let ((char (get-char)))
	(if (eq? char #\space)
	    (after-space)
	    char)))
    (define (until-newline)
      (let ((char (get-char)))
	(if (or (eq? char #\newline)
		(eof-object? char))
	    (set! lookahead char)
	    (until-newline))))
    (let ((char (get-char)))   
      (cond ((eq? char #\newline)
             (if (> depth 0) (set! lookahead char))   
             '()) 
	    ((eq? char #\space)
	     (let ((char (after-space)))
	       (cond ((eq? char #\newline)
		      (begin (if (> depth 0) (set! lookahead char))
			     '()))
		     ((eq? char #\])
		      (if (> depth 0) '() (logo-error "Unexpected ]")))
		     ((eq? char #\~)
		      (let ((char (get-char)))
			(if (eq? char #\newline)
			    (logo-read-help depth)
			    (begin (set! lookahead char)
				   (until-newline)
				   (logo-error "~ not followed by newline")))))
		     ((eq? char #\;) (until-newline) (logo-read-help depth))
		     (else (set! lookahead char)
			   (let ((token (get-token #t)))
			     (cons token (logo-read-help depth)))))))
            ((eq? char #\])   
             (if (> depth 0) '() (logo-error "Unexpected ]")))
	    ((eq? char #\~)
	     (let ((char (get-char)))
	       (if (eq? char #\newline)
		   (logo-read-help depth)
		   (begin (set! lookahead char)
			  (until-newline)
			  (logo-error "~ not followed by newline")))))
	    ((eq? char #\;) (until-newline) (logo-read-help depth))
            ((eof-object? char) char)   
            (else (set! lookahead char)
                  (let ((token (get-token #f)))
                    (cons token (logo-read-help depth)) ))))) 
  (logo-read-help 0))  


;;; Assorted stuff   

(define (make-logo-arith op)   
  (lambda args (apply op (map maybe-num args))))   

(define (maybe-num val)
  (if (word? val)
      (string->word (word->string val))
      val))

(define tty-port (current-input-port))   

(define (prompt string)   
  (if (eq? (current-input-port) tty-port)
  (begin (display string) (force-output))))  

(define (meta-load fn)   
  (define (loader)  
    (let ((exp (logo-read)))   
      (if (eof-object? exp)   
          '() 
          (begin (eval-line (make-line-obj exp)
			    the-global-environment) 
		 (loader))))) 
  (with-input-from-file (symbol->string fn) loader)
  '=no-value=) 
