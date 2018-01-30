;; logo-meta.scm      Part of programming project #4

;;; Differences between the book and this version:  Eval and apply have
;;; been changed to logo-eval and logo-apply so as not to overwrite the Scheme
;;; versions of these routines. An extra procedure initialize-logo has been
;;; added. This routine resets the global environment and then executes the
;;; driver loop. This procedure should be invoked to start the Logo
;;; evaluator executing.  Note: It will reset your global environment and all
;;; definitions to the Logo interpreter will be lost. To restart the Logo
;;; interpreter without resetting the global environment, just invoke
;;; driver-loop.  Don't forget that typing control-C will get you out of
;;; the Logo evaluator back into Scheme.

;;; Problems A1, A2, and B2 are entirely in logo.scm
;;; Problems 3, 7, and up require you to find and change existing procedures.

;;;  Procedures that you must write from scratch:

;;; Problem B1    eval-line

(define (eval-line line-obj env)
  (define (loop)
    (if (ask line-obj 'empty?)
	'=no-value=
	(let ((val (logo-eval line-obj env)))
	  (if (eq? val '=no-value=)
	      (loop)
	      val))))
  (loop))


;;; Problem 4    variables  (other procedures must be modified, too)
;;; data abstraction procedures

(define (variable? exp)
  (and (word? exp)
       (eqv? (string-ref (word->string exp) 0) #\:)))

(define (variable-name exp)
  (bf exp))


;;; Problem A5   handle-infix

(define infix-oper-proc-alist '((+ . sum)
				(- . difference)
				(* . product)
				(/ . quotient)
				(% . remainder)
				(= . equalp)
				(< . lessp)
				(> . greaterp)))

(define (de-infix token)
  (cdr (assoc token infix-oper-proc-alist)))

(define (infix-operator? token)
  (assoc token infix-oper-proc-alist))

(define (handle-infix value line-obj env)
  (if (ask line-obj 'empty?)
      value
      (let ((token (ask line-obj 'next)))
	(cond ((infix-operator? token)
	       (handle-infix
		(logo-apply
		 (lookup-procedure (de-infix token))
		 (list value (eval-prefix line-obj env))
		 env)
		line-obj
		env))
	      (else
	       (ask line-obj 'put-back token)
	       value)))))


;;; Problem B5    eval-definition

;; Eval procedure definitions with required and optional inputs

(define (eval-definition line-obj)
  (define def-no-args #f)
  (define (collect-formals)
    (define (collect-required)
      (if (ask line-obj 'empty?)
	  '()
	  (let ((formal (ask line-obj 'next)))
	    (cond ((variable? formal)
		   (cons (variable-name formal)
			 (collect-required)))
		  ((list? formal)
		   (ask line-obj 'put-back formal)
		   (collect-optional))
		  (else (logo-error "Invalid input to procedure" formal))))))
    (define (collect-optional)
      (if (ask line-obj 'empty?)
	  '()
	  (let ((formal (ask line-obj 'next)))
	    (cond ((and (list? formal)
			(not (null? formal))
			(variable? (car formal))
			(> (length formal) 1))
		   (cons (cons (variable-name (car formal))
			       (cdr formal))
			 (collect-optional)))
		  ((or (list? formal)
		       (number? formal))
		   (ask line-obj 'put-back formal)
		   (collect-rest))
		  (else (logo-error "Invalid input to procedure" formal))))))
    (define (collect-rest)
      (let ((formal (ask line-obj 'next)))
	(cond ((number? formal)
	       (ask line-obj 'put-back formal)
	       (collect-def-no-args))
	      ((and (list? formal)
		    (not (null? formal))
		    (variable? (car formal))
		    (null? (cdr formal)))
	       (cons (list (variable-name (car formal)))
		     (collect-def-no-args)))
	      (logo-error "Invalid input to procedure" formal))))
    (define (collect-def-no-args)
      (if (ask line-obj 'empty?)
	  '()
	  (let ((formal (ask line-obj 'next)))
	    (cond ((not (ask line-obj 'empty?))
		   (logo-error "Invalid input to procedure after" formal))
		  ((number? formal)
		   (set! def-no-args formal)
		   '())
		  (else (logo-error "Invalid input to procedure" formal))))))
    (collect-required))
  (define (collect-body)
    (define (end-line? line)
      (and (= (length line) 1)
	   (eq? (car line) 'end)))
    (define (helper)
      (prompt "> ")
      (let ((line (logo-read)))
	(cond ((null? line) (logo-error "Procedure definition incomplete"))
	      ((end-line? line) '())
	      (else (cons line (helper))))))
    (helper))
  (define (compute-arg-count formals)
    (define (number-of-required formals)
      (define (iter formals cnt)
	(cond ((null? formals) cnt)
	      ((symbol? (car formals)) (iter (cdr formals) (+ cnt 1)))
	      (else (iter (cdr formals) cnt))))
      (iter formals 0))
    (let ((req (number-of-required formals)))
      (if (= req
	     (length formals))
	  req
	  (- req))))
  (if (ask line-obj 'empty?)
      (logo-error "Empty procedure definition")
      (let ((name (ask line-obj 'next)))
	(cond ((not (word? name))
	       (logo-error "Procedure name is not a word" name))
	      (else
	       (let ((formals (collect-formals)))
		 (let ((body (collect-body)))
		   (let ((arg-count (if def-no-args
					def-no-args
					(compute-arg-count formals))))
		     (add-compound name arg-count formals body)
		     '=no-value=))))))))


;;; Eval simple macro definitions

(define (eval-macro-definition line-obj)
  (define (collect-formals)
    (if (ask line-obj 'empty?)
	'()
	(let ((formal (ask line-obj 'next)))
	  (if (not (variable? formal))
	      (logo-error "Invalid formal name" formal)
	      (cons (variable-name formal)
		    (collect-formals))))))
  (define (collect-body)
    (define (end-line? line)
      (and (= (length line) 1)
	   (eq? (car line) 'end)))
    (define (helper)
      (prompt "> ")
      (let ((line (logo-read)))
	(cond ((null? line) (logo-error "Macro definition incomplete"))
	      ((end-line? line) '())
	      (else (cons line (helper))))))
    (helper))
  (if (ask line-obj 'empty?)
      (logo-error "Empty macro definition")
      (let ((name (ask line-obj 'next)))
	(cond ((not (word? name))
	       (logo-error "Macro name is not a word" name))
	      (else
	       (let ((formals (collect-formals)))
		 (let ((arg-count (length formals)))
		   (let ((body (collect-body)))
		     (add-macro name arg-count formals body)
		     '=no-value=))))))))


;;; Problem 6    eval-sequence

(define (eval-sequence exps env)
  (cond ((null? exps) '=no-value=)
	(else
	 (let ((result (eval-line (make-line-obj (car exps))
				  env)))
	   (cond ((eq? result '=stop=) '=no-value=)
		 ((and (pair? result)
		       (eq? (car result) '=output=)) (cdr result))
		 ((not (eq? result '=no-value=))
		  (logo-error "You don't say what to do with" result))
		 (else
		  (eval-sequence (cdr exps) env)))))))




;;; SETTING UP THE ENVIRONMENT

(define the-primitive-procedures '())

(define (add-prim name count proc)
  (set! the-primitive-procedures
	(cons (list name 'primitive count proc)
	      the-primitive-procedures)))

(add-prim 'first 1 first)
(add-prim 'butfirst 1 bf)
(add-prim 'bf 1 bf)
(add-prim 'last 1 last)
(add-prim 'butlast 1 bl)
(add-prim 'bl 1 bl)
(add-prim 'word -2 word)
(add-prim 'sentence -2 se)
(add-prim 'se -2 se)
(add-prim 'list -2 list)
(add-prim 'fput 2 cons)
(add-prim 'append -2 append)
(add-prim 'item 2 item)
(add-prim 'count 1 count)
(add-prim 'reverse 1 reverse)
(add-prim 'random 1 random)

(add-prim 'sum -2 (make-logo-arith +))
(add-prim 'difference 2 (make-logo-arith -))
(add-prim '=unary-minus= 1 (make-logo-arith -))
(add-prim '- 1 (make-logo-arith -))
(add-prim 'product -2 (make-logo-arith *))
(add-prim 'quotient 2 (make-logo-arith /))
(add-prim 'remainder 2 (make-logo-arith remainder))
(add-prim 'sqrt 1 (make-logo-arith sqrt))
(add-prim 'abs 1 (make-logo-arith abs))

(add-prim 'print 1 logo-print)
(add-prim 'pr 1 logo-print)
(add-prim 'show 1 logo-show)
(add-prim 'type 1 logo-type)
(add-prim 'readlist 0 readlist)

(add-prim 'make '(2) make)
(add-prim 'local '(1) local)
(add-prim 'thing '(1) thing)

(add-prim 'run '(1) run)
(add-prim 'apply '(2) apply-template)

(add-prim 'if '(2) logo-if)
(add-prim 'ifelse '(3) ifelse)
(add-prim 'test '(1) test)
(add-prim 'iftrue '(1) iftrue)
(add-prim 'ift '(1) iftrue)
(add-prim 'iffalse '(1) iffalse)
(add-prim 'iff '(1) iffalse)

(add-prim 'not 1 logo-not)
(add-prim 'namep '(1) (logo-pred namep))
(add-prim 'procedurep 1 (logo-pred procedurep))
(add-prim 'equalp 2 (logo-pred (make-logo-arith equalp)))
(add-prim 'lessp 2 (logo-pred (make-logo-arith <)))
(add-prim 'greaterp 2 (logo-pred (make-logo-arith >)))
(add-prim 'emptyp 1 (logo-pred empty?))
(add-prim 'numberp 1 (logo-pred (make-logo-arith number?)))
(add-prim 'listp 1 (logo-pred list?))
(add-prim 'wordp 1 (logo-pred (lambda (x) (not (list? x)))))
(add-prim 'memberp 2 (logo-pred memberp))

(add-prim 'pprop 3 pprop)
(add-prim 'gprop 2 gprop)
(add-prim 'remprop 2 remprop)
(add-prim 'plist 1 plist)

(add-prim 'stop 0 (lambda () '=stop=))
(add-prim 'output 1 (lambda (x) (cons '=output= x)))
(add-prim 'op 1 (lambda (x) (cons '=output= x)))

(add-prim 'load 1 meta-load)
(add-prim 'bye 0 (lambda () (exit-logo)))

;; (define (pcmd proc) (lambda args (apply proc args) '=no-value=))
;; (add-prim 'cs 0 (pcmd cs))
;; (add-prim 'clearscreen 0 (pcmd cs))
;; (add-prim 'fd 1 (pcmd fd))
;; (add-prim 'forward 1 (pcmd fd))
;; (add-prim 'bk 1 (pcmd bk))
;; (add-prim 'back 1 (pcmd bk))
;; (add-prim 'lt 1 (pcmd lt))
;; (add-prim 'left 1 (pcmd lt))
;; (add-prim 'rt 1 (pcmd rt))
;; (add-prim 'right 1 (pcmd rt))
;; (add-prim 'setxy 2 (pcmd setxy))
;; (add-prim 'setx 1 (lambda (x) (setxy x (ycor)) '=no-value=))
;; (add-prim 'sety 1 (lambda (y) (setxy (xcor) y) '=no-value=))
;; (add-prim 'xcor 0 xcor)
;; (add-prim 'ycor 0 ycor)
;; (add-prim 'pos 0 pos)
;; (add-prim 'seth 1 (pcmd setheading))
;; (add-prim 'setheading 1 (pcmd setheading))
;; (add-prim 'heading 0 heading)
;; (add-prim 'st 0 (pcmd st))
;; (add-prim 'showturtle 0 (pcmd st))
;; (add-prim 'ht 0 (pcmd ht))
;; (add-prim 'hideturtle 0 (pcmd ht))
;; (add-prim 'shown? 0 shown?)
;; (add-prim 'pd 0 (pcmd pendown))
;; (add-prim 'pendown 0 (pcmd pendown))
;; (add-prim 'pu 0 (pcmd penup))
;; (add-prim 'penup 0 (pcmd penup))
;; (add-prim 'pe 0 (pcmd penerase))
;; (add-prim 'penerase 0 (pcmd penerase))
;; (add-prim 'home 0 (pcmd home))
;; (add-prim 'setpc 1 (pcmd setpc))
;; (add-prim 'setpencolor 1 (pcmd setpc))
;; (add-prim 'pc 0 pc)
;; (add-prim 'pencolor 0 pc)
;; (add-prim 'setbg 1 (pcmd setbg))
;; (add-prim 'setbackground 1 (pcmd setbg))

(define exit-logo #f)
(define back-to-top-level #f)

(define the-global-environment '())
(define the-procedures-table (make-table-from the-primitive-procedures))
(define the-plists-table (make-table))
(define the-macros '())

;;; INITIALIZATION AND DRIVER LOOP

;;; The following code initializes the machine and starts the Logo
;;; system.  You should not call it very often, because it will clobber
;;; the global environment, and you will lose any definitions you have
;;; accumulated.

(define (initialize-logo)
  (set! the-global-environment (extend-environment '() '() '()))
  (set! the-procedures-table (make-table-from the-primitive-procedures))
  (set! the-plists-table (make-table))
  (set! the-macros '())
  (driver-loop))

(define (driver-loop)
  (define (helper)
    (prompt "? ")
    (let ((line (logo-read)))
      (if (not (null? line))
  	  (let ((result (eval-line (make-line-obj line)
				   the-global-environment)))
	    (if (not (eq? result '=no-value=))
		(logo-print (list "You don't say what to do with" result))))))
    (helper))
  (call-with-current-continuation
   (lambda (exit-cont)
     (set! exit-logo exit-cont)
     (call-with-current-continuation
      (lambda (top-level-cont)
	(set! back-to-top-level top-level-cont)))
     (helper))))

;;; APPLYING PRIMITIVE PROCEDURES

;;; To apply a primitive procedure, we ask the underlying Scheme system
;;; to perform the application.  (Of course, an implementation on a
;;; low-level machine would perform the application in some other way.)

(define (apply-primitive-procedure p args)
  (apply (text p) args))


;;; Now for the code that's based on the book!!!


;;; Section 4.1.1

;; Given an expression like (proc :a :b :c)+5
;; logo-eval calls eval-prefix for the part in parentheses, and then
;; handle-infix to check for and process the infix arithmetic.
;; Eval-prefix is comparable to Scheme's eval.

(define (logo-eval line-obj env)
  (handle-infix (eval-prefix line-obj env) line-obj env))

(define (eval-prefix line-obj env)
  (define (eval-helper paren-flag)
    (let ((token (ask line-obj 'next)))
      (cond ((self-evaluating? token) token)
            ((variable? token)
	     (lookup-variable-value (variable-name token) env))
            ((quoted? token) (text-of-quotation token))
            ((procedure-definition? token) (eval-definition line-obj))
	    ((macro-definition? token) (eval-macro-definition line-obj))
	    ((left-paren? token)
	     (let ((result (handle-infix (eval-helper #t)
				       	 line-obj
				       	 env)))
	       (let ((token (ask line-obj 'next)))
	       	 (if (right-paren? token)
		     result
		     (logo-error "Too much inside parens" token)))))
	    ((right-paren? token)
	     (logo-error "Unexpected ')'"))
	    ((macro-call? token)
	     (let ((macro (lookup-macro token)))
	       (handle-macro macro
			     (collect-n-args (arg-count macro)
					     line-obj
					     env
					     (macro-name macro))
			     env)))
            (else
	     (let ((proc (lookup-procedure token)))
		     (if (not proc)
			 (logo-error "I don't know how  to" token)
			 (cond ((pair? (arg-count proc))
				(logo-apply proc
					    (cons env
						  (collect-n-args (car (arg-count proc))
								  line-obj
								  env
								  (procedure-name proc)))
					    env))
			       ((and (negative? (arg-count proc))
				     (not paren-flag))
				(logo-apply proc
					    (collect-n-args (abs (arg-count proc))
							    line-obj
							    env
							    (procedure-name proc))
					    env))
			       (paren-flag
				(logo-apply proc
					    (collect-n-args -1
							    line-obj
							    env
							    (procedure-name proc))
					    env))
			       (else
				(logo-apply proc
					    (collect-n-args (arg-count proc)
							    line-obj
							    env
							    (procedure-name proc))
					    env)))))) )))
  (eval-helper #f))

(define (macro-call? token)
  (lookup-macro token))

(define (handle-macro macro arguments env)
  (let ((macro-output (eval-sequence
		       (procedure-body macro)
		       (extend-environment
			(procedure-parameters macro)
			arguments
			env))))
    (eval-line (make-line-obj macro-output)
	       env)))

(define (logo-apply procedure arguments env)
  (cond ((primitive-procedure? procedure)
         (apply-primitive-procedure procedure arguments))
        ((compound-procedure? procedure)
	 (eval-sequence
	  (procedure-body procedure)
	  (extend-environment-for-proc-application
	   (procedure-parameters procedure)
	   arguments
	   env)))
        (else
         (logo-error "Unknown procedure type" procedure))))

(define (collect-n-args n line-obj env name)
  (cond ((= n 0) '())
	((and (< n 0) (not (ask line-obj 'empty?)))
	 (let ((token (ask line-obj 'next)))
	   (ask line-obj 'put-back token)
	   (if (right-paren? token)
	       '()
      	       (let ((next (logo-eval line-obj env)))
        	 (cons next
	      	       (collect-n-args (- n 1) line-obj env name)) ))))
	(else      
      	 (if (not (ask line-obj 'empty?))
	     (let ((next (logo-eval line-obj env)))
	       (cons next
		     (collect-n-args (- n 1) line-obj env name)) )
	     (logo-error "Too few arguments supplied" name)))))

;;; Section 4.1.2 -- Representing expressions

;;; numbers

(define (self-evaluating? exp) (number? exp))

;;; quote

(define (quoted? exp)
  (or (list? exp)
      (eqv? (string-ref (word->string (first exp)) 0) #\")))

(define (text-of-quotation exp)
  (if (list? exp)
      exp
      (bf exp)))

;;; parens

(define (left-paren? exp) (eq? exp left-paren-symbol))

(define (right-paren? exp) (eq? exp right-paren-symbol))

;;; definitions

(define (procedure-definition? exp)
  (eq? exp 'to))

;;; procedures

(define (lookup-procedure name)
  (let ((proc (lookup-record name the-procedures-table)))
    (if proc
	proc
	(let ((lib-name (string-append "logolib/procedures/"
				       (if (word? name)
					   (word->string name)
					   name))))
	  (cond ((file-exists? lib-name)
		 (meta-load lib-name)
		 (let ((lproc (lookup-record name the-procedures-table)))
		   (if lproc
		       lproc
		       (logo-error "Library does not contain definition" name))))
		(else #f))))))

(define (add-compound name arg-count formals body)
  (insert-record! (list name 'compound arg-count (cons formals body))
		  the-procedures-table))

(define (procedure-name p)
  (car p))

(define (primitive-procedure? p)
  (eq? (cadr p) 'primitive))

(define (compound-procedure? p)
  (eq? (cadr p) 'compound))

(define (arg-count proc)
  (caddr proc))

(define (text proc)
  (cadddr proc))

(define (procedure-parameters proc) (car (text proc)))

(define (procedure-body proc) (cdr (text proc)))

;;; macro

(define (macro-definition? exp)
  (equal? exp ".macro"))

(define (lookup-macro name)
  (let ((macro (assoc name the-macros)))
    (if macro
	macro
	(let ((lib-name (string-append "logolib/macros/"
				       (if (word? name)
					   (word->string name)
					   name))))
	  (cond ((file-exists? lib-name)
		 (meta-load lib-name)
		 (let ((lmacro (assoc name the-macros)))
		   (if lmacro
		       lmacro
		       (logo-error "Library does not contain macro definition" name))))
		(else #f))))))

(define (add-macro name arg-count formals body)
  (set! the-macros
	(cons (list name 'macro arg-count (cons formals body))
	      the-macros)))

(define (macro-name macro)
  (car macro))


;;; Section 4.1.3

;;; Operations on environments

(define (enclosing-environment env) (cdr env))

(define (first-frame env) (car env))

(define the-empty-environment '())

(define (make-frame variables values)
  (cons variables values))

(define (frame-variables frame) (car frame))
(define (frame-values frame) (cdr frame))

(define (add-binding-to-frame! var val frame)
  (set-car! frame (cons var (car frame)))
  (set-cdr! frame (cons val (cdr frame))))

(define (extend-environment vars vals base-env)
  (if (= (length vars) (length vals))
      (cons (make-frame vars vals) base-env)
      (if (< (length vars) (length vals))
          (logo-error "Too many arguments supplied" vars vals)
          (logo-error "Too few arguments supplied" vars vals))))

(define (extend-environment-for-proc-application vars vals base-env)
  (let ((env (cons (make-frame '() '())
		   base-env)))
    (let ((frame (first-frame env)))
      (define (params-args-loop params args)
	(cond ((null? params)
	       (if (null? args)
		   env
		   (logo-error "Too many arguments supplied" vars vals)))
	      ((symbol? (car params))
	       (if (null? args)
		   (logo-error "Too few arguments supplied" vars vals)
		   (begin
		     (add-binding-to-frame! (car params)
					    (car args)
					    frame)
		     (params-args-loop (cdr params) (cdr args)))))
	      ((and (pair? (car params))
		    (not (null? (cdar params))))
	       (cond ((null? args)
		      (let ((result (eval-line (make-line-obj (cdar params))
					       env)))
			(add-binding-to-frame! (caar params)
					       result
					       frame)
			(params-args-loop (cdr params) args)))
		     (else
		      (add-binding-to-frame! (caar params)
					     (car args)
					     frame)
		      (params-args-loop (cdr params) (cdr args)))))
	      ((and (pair? (car params))
		    (null? (cdar params)))
	       (cond ((null? (cdr params))
		      (add-binding-to-frame! (caar params)
					     args
					     frame)
		      env)
		     (else (logo-error "Parameter(s) after rest" (cdr params)))))
	      (else (logo-error "Unknown parameter" (car params)))))
      (params-args-loop vars vals))))

(define (lookup-variable-value var env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
             (env-loop (enclosing-environment env)))
            ((equal? var (car vars))
	     (if (eq? (car vals) '=unassigned=)
		 (logo-error "Variable is unassigned" var)
		 (car vals)))
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        (logo-error "Unbound variable" var)
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop env))

(define (lookup-variable-binding var env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
             (env-loop (enclosing-environment env)))
            ((equal? var (car vars))
             (cons var (car vals)))
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        '()
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop env))

(define (set-variable-value! var val env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
             (env-loop (enclosing-environment env)))
            ((equal? var (car vars))
             (set-car! vals val))
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        (let ((frame (first-frame the-global-environment)))
	  (add-binding-to-frame! var val frame))
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop env))

(define (define-variable! var val env)
  (let ((frame (first-frame env)))
    (define (scan vars vals)
      (cond ((null? vars)
             (add-binding-to-frame! var val frame))
            ((equal? var (car vars))
             (set-car! vals val))
            (else (scan (cdr vars) (cdr vals)))))
    (scan (frame-variables frame)
          (frame-values frame))))

(define (logo-error reason . args)
  (display "*** Error: ")
  (display reason)
  (for-each (lambda (arg) (display " ") (logo-type (list arg)))
	    args)
  (newline)
  (back-to-top-level))
