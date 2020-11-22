(display ";; This Logo interpeter implements a subset of UCBLogo, minus the turtle graphics.\n;; v1.0 2020, imi [dot] horvath [at] gmail [dot] com\n;; Library and examples taken from Berkeley Logo.\n;; Ymacs key bindings hint: C-S-y Paste from clipboard, M-S-w Copy to clipboard, C-x C-f find file\n;; Tip: C-x C-f examples.txt, C-x 3, C-x b *scheme*")
(newline)

;; Guile Scheme specific initialization

(load "simply.scm")
;; For compatibility. By default Guile does NOT unwind, while Gambit does.
(define with-exception-handler
  (let ((with-exception-handler with-exception-handler))
    (lambda (handler thunk)
      (with-exception-handler handler thunk #:unwind? #t))))
(load "tables.scm")
(load "obj.scm")
(load "logo.scm")
(load "logo-meta.scm")
(initialize-logo)
