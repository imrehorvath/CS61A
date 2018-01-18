
;;; Basic tables operations

(define (make-table)
  (list '*table*))

(define (lookup key table)
  (let ((record (assoc key (cdr table))))
    (if record
	(cdr record)
	#f)))

(define (insert! key value table)
  (let ((record (assoc key (cdr table))))
    (if record
	(set-cdr! record value)
	(set-cdr! table
		  (cons (cons key value)
			(cdr table))))
    'ok))

;;; Extended tables operations

(define (make-table-from alist)
  (cons '*table* (reverse alist)))

(define (lookup-record key table)
  (assoc key (cdr table)))

(define (insert-record! a-record table)
  (let ((record (assoc (car a-record) (cdr table))))
    (if record
	(set-cdr! record (cdr a-record))
	(set-cdr! table
		  (cons a-record (cdr table))))
    'ok))

(define (delete! key table)
  (define (loop this prev)
    (cond ((null? this) 'none)
	  ((equal? (caar this) key) (set-cdr! prev (cdr this)) 'done)
	  (else (loop (cdr this) this))))
  (loop (cdr table) table))

