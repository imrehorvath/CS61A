;; Use this initialization to run the project in Guile Scheme!

(display ";; This Logo interpeter implements a subset of UCBLogo, minus the turtle graphics.\n;; v1.0 2020, imi [dot] horvath [at] gmail [dot] com\n;; Library and examples taken from Berkeley Logo.\n;; This is the Guile Scheme-specific initialization.")
(newline)

;; Guile Scheme-specific initialization

;; This enables the use of the same source code in both Guile and Gambit Scheme.
(define with-exception-handler
  (let ((with-exception-handler with-exception-handler))
    (lambda (handler thunk)
      (with-exception-handler handler thunk #:unwind? #t))))

(load "simply.scm")
(load "tables.scm")
(load "obj.scm")
(load "logo.scm")
(load "logo-meta.scm")
(initialize-logo)
