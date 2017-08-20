;; ADV.SCM
;; This file contains the definitions for the objects in the adventure
;; game and some utility procedures.

(define-class (basic-object)
  (instance-vars
   (properties (make-table)))
  (method (put prop val)
	  (insert! prop val properties))
  (default-method (lookup message properties)))

(define-class (place name)
  (parent (basic-object))
  (instance-vars
   (directions-and-neighbors '())
   (things '())
   (people '())
   (entry-procs '())
   (exit-procs '()))
  (method (place?) #t)
  (method (neighbors) (map cdr directions-and-neighbors))
  (method (exits) (map car directions-and-neighbors))
  (method (look-in direction)
    (let ((pair (assoc direction directions-and-neighbors)))
      (if (not pair)
	  '()                     ;; nothing in that direction
	  (cdr pair))))           ;; return the place object
  (method (appear new-thing)
    (if (memq new-thing things)
	(error "Thing already in this place" (list name new-thing)))
    (set! things (cons new-thing things))
    'appeared)
  (method (may-enter? person) #t)
  (method (enter new-person)
    (if (memq new-person people)
	(error "Person already in this place" (list name new-person)))
    (set! people (cons new-person people))
    (for-each (lambda (proc) (proc)) entry-procs)
    (for-each (lambda (pers) (ask pers 'notice new-person))
	      (filter (lambda (pers) (not (eq? pers new-person)))
		      people))
    'appeared)
  (method (gone thing)
    (if (not (memq thing things))
	(error "Disappearing thing not here" (list name thing)))
    (set! things (delete thing things)) 
    'disappeared)
  (method (exit person)
    (for-each (lambda (proc) (proc)) exit-procs)
    (if (not (memq person people))
	(error "Disappearing person not here" (list name person)))
    (set! people (delete person people)) 
    'disappeared)

  (method (new-neighbor direction neighbor)
    (if (assoc direction directions-and-neighbors)
	(error "Direction already assigned a neighbor" (list name direction)))
    (set! directions-and-neighbors
	  (cons (cons direction neighbor) directions-and-neighbors))
    'connected)

  (method (add-entry-procedure proc)
    (set! entry-procs (cons proc entry-procs)))
  (method (add-exit-procedure proc)
    (set! exit-procs (cons proc exit-procs)))
  (method (remove-entry-procedure proc)
    (set! entry-procs (delete proc entry-procs)))
  (method (remove-exit-procedure proc)
    (set! exit-procs (delete proc exit-procs)))
  (method (clear-all-procs)
    (set! exit-procs '())
    (set! entry-procs '())
    'cleared) )

(define-class (locked-place name)
  (parent (place name))
  (instance-vars
   (locked #t))
  (method (may-enter? person)
	  (not locked))
  (method (unlock)
	  (set! locked #f)
	  'unlocked))

(define-class (garage name)
  (parent (place name))
  (class-vars (serial 0))
  (instance-vars (registry (make-table)))
  (method (park vehicle)
	  (if (not (memq vehicle (ask self 'things)))
	      (error "Car is not in the garage" (list vehicle self)))
	  (set! serial (+ serial 1))
	  (let ((ticket (instantiate ticket 'ticket serial)))
	    (ask self 'appear ticket)
	    (let ((owner (ask vehicle 'possessor)))
	      (ask owner 'lose vehicle)
	      (ask owner 'take ticket)
	      (insert! serial vehicle registry)
	      'parked)))
  (method (unpark ticket)
	  (if (not (ticket? ticket))
	      (error "To unpark a car, you need a ticket!" ticket))
	  (let ((number (ask ticket 'number)))
	    (let ((vehicle (lookup number registry)))
	      (if (not vehicle)
		  (error "Car not found in garage for ticket number"
			 (list number self vehicle)))
	      (let ((owner (ask ticket 'possessor)))
		(ask owner 'lose ticket)
		(ask owner 'take vehicle)
		(insert! number #f registry)
		'unparked)))))

(define-class (hotspot name password)
  (parent (place name))
  (instance-vars
   (connected-laptops '()))
  (method (connect laptop pass)
	  (if (and (eq? pass password)
		   (memq laptop (ask self 'things)))
	      (begin
		(set! connected-laptops
		      (cons laptop connected-laptops))
		'laptop-connected)))
  (method (gone thing)
	  (if (laptop? thing)
	      (set! connected-laptops
		    (delete thing connected-laptops)))
	  (ask self 'gone thing))
  (method (surf laptop url)
	  (if (memq laptop connected-laptops)
	      (system (string-append "lynx " url)))))

(define-class (restaurant name food-class price)
  (parent (place name))
  (method (menu) (list (ask food-class 'name) price))
  (method (sell buyer what)
	  (cond ((not (eq? what (ask food-class 'name))) #f)
		((or (policeperson? buyer)
		     (ask buyer 'pay-money price))
		 (let ((food (instantiate food-class)))
		   (ask self 'appear food)
		   food))
		(else #f))))

(define-class (person name place)
  (parent (basic-object))
  (instance-vars
   (possessions '())
   (saying ""))
  (initialize
   (ask place 'enter self)
   (ask self 'put 'strength 25)
   (ask self 'put 'money 100))
  (method (person?) #t)
  (method (get-money money)
	  (ask self 'put 'money
	       (+ (ask self 'money)
		  money)))
  (method (pay-money money)
	  (let ((have (ask self 'money)))
	    (if (> money have)
		#f
		(begin
		  (ask self 'put 'money
		       (- have money))
		  #t))))
  (method (eat)
	  (for-each
	   (lambda (food)
	     (ask self 'put 'strength
		  (+ (ask self 'strength)
		     (ask food 'calories)))
	     (ask place 'gone food)
	     (ask self 'lose food))
	   (filter edible? possessions)))
  (method (buy what)
	  (let ((food (ask place 'sell self what)))
	    (if food
		(ask self 'take food))))
  (method (look-around)
    (map (lambda (obj) (ask obj 'name))
	 (filter (lambda (thing) (not (eq? thing self)))
		 (append (ask place 'things) (ask place 'people)))))
  (method (take thing)
    (cond ((not (thing? thing)) (error "Not a thing" thing))
	  ((not (memq thing (ask place 'things)))
	   (error "Thing taken not at this place"
		  (list (ask place 'name) thing)))
	  ((memq thing possessions) (error "You already have it!"))
	  ((ask thing 'may-take? self)
	   (announce-take name thing)
	   (set! possessions (cons thing possessions))
	       
	   ;; If somebody already has this object...
	   (for-each
	    (lambda (pers)
	      (if (and (not (eq? pers self)) ; ignore myself
		       (memq thing (ask pers 'possessions)))
		  (begin
		    (ask pers 'lose thing)
		    (have-fit pers))))
	    (ask place 'people))
	   
	   (ask thing 'change-possessor self)
	   'taken)
	  (else #f)))

  (method (lose thing)
    (set! possessions (delete thing possessions))
    (ask thing 'change-possessor 'no-one)
    'lost)
  (method (talk) (print saying))
  (method (set-talk string) (set! saying string))
  (method (exits) (ask place 'exits))
  (method (notice person) (ask self 'talk))
  (method (go direction)
    (let ((new-place (ask place 'look-in direction)))
      (cond ((null? new-place)
	     (error "Can't go" direction))
	    ((not (ask new-place 'may-enter? self))
	     (error "Cannot enter place" (list new-place direction)))
	    (else
	     (ask place 'exit self)
	     (announce-move name place new-place)
	     (for-each
	      (lambda (p)
		(ask place 'gone p)
		(ask new-place 'appear p))
	      possessions)
	     (set! place new-place)
	     (ask new-place 'enter self)))))
  (method (go-directly-to new-place)
	  (ask place 'exit self)
	  (announce-move name place new-place)
	  (for-each
	   (lambda (p)
	     (ask place 'gone p)
	     (ask new-place 'appear p))
	   possessions)
	  (set! place new-place)
	  (ask new-place 'enter self))
  (method (take-all)
	  (for-each
	   (lambda (t) (ask self 'take t))
	   (filter (lambda (t)
		     (eq? (owner t) 'no-one))
		   (ask place 'things)))))

(define-class (thing name)
  (parent (basic-object))
  (instance-vars
   (possessor 'no-one))
  (method (thing?) #t)
  (method (may-take? receiver)
	  (cond ((eq? possessor 'no-one) self)
		((> (ask receiver 'strength)
		    (ask possessor 'strength)) self)
		(else #f)))
  (method (change-possessor new-possessor)
	  (set! possessor new-possessor)))

(define-class (food)
  (parent (thing 'food))
  (initialize
   (ask self 'put 'edible? #t)
   (ask self 'put 'calories 0)))

(define-class (bagel)
  (parent (food))
  (class-vars
   (name 'bagel))
  (initialize
   (ask self 'put 'calories 15)))

(define-class (coffee)
  (parent (food))
  (class-vars
   (name 'coffee)))

(define-class (ticket name number)
  (parent (thing name)))

(define-class (laptop name)
  (parent (thing name))
  (method (laptop?) #t)
  (method (connect password)
	  (let ((possessor (ask self 'possessor)))
	    (if (eq? possessor 'no-one)
		(error "Cannot connect a laptop which is not owned"))
	    (let ((place (ask possessor 'place)))
	      (ask place 'connect self password))))
  (method (surf url)
	  (let ((possessor (ask self 'possessor)))
	    (if (eq? possessor 'no-one)
		(error "Cannot surf with a laptop which is not owned"))
	    (let ((place (ask possessor 'place)))
	      (ask place 'surf self url)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Implementation of thieves for part two
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (edible? thing)
  (ask thing 'edible?))

(define-class (thief name initial-place)
  (parent (person name initial-place))
  (instance-vars
   (behavior 'steal))
  (initialize
   (ask self 'put 'strength 50))
  (method (thief?) #t)
  
  (method (notice person)
	  (cond ((eq? behavior 'steal)
		 (for-each
		  (lambda (thing)
		    (ask self 'take thing)
		    (set! behavior 'run))
		  (filter (lambda (thing)
			    (and (edible? thing)
				 (not (eq? (ask thing 'possessor)
					   self))))
			  (ask (usual 'place) 'things))))
		((eq? behavior 'run)
		 (if (not (null? (ask self 'exits)))
		     (ask self 'go (pick-random
				    (filter (lambda (direction)
					      (let ((new-place (ask (usual 'place)
								    'look-in
								    direction)))
						(ask new-place 'may-enter? self)))
					    (ask (usual 'place) 'exits))))))
		(else
		 (error "Invalid behavior" behavior)))))

(define-class (police name initial-place)
  (parent (person name initial-place))
  (initialize
   (ask self 'set-talk "Crime Does Not Pay,")
   (ask self 'put 'strength 100))
  (method (police?) #t)
  (method (notice person)
	  (if (thief? person)
	      (begin
		(ask self 'talk)
		(for-each
		 (lambda (thing)
		   (ask self 'take thing))
		 (ask person 'possessions))
		(ask person 'go-directly-to Jail)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; this next procedure is useful for moving around

(define (move-loop who)
  (newline)
  (print (ask who 'exits))
  (display "?  > ")
  (let ((dir (read)))
    (if (equal? dir 'stop)
	(newline)
	(begin (print (ask who 'go dir))
	       (move-loop who)))))


;; One-way paths connect individual places.

(define (can-go from direction to)
  (ask from 'new-neighbor direction to))


(define (announce-take name thing)
  (newline)
  (display name)
  (display " took ")
  (display (ask thing 'name))
  (newline))

(define (announce-move name old-place new-place)
  (newline)
  (newline)
  (display name)
  (display " moved from ")
  (display (ask old-place 'name))
  (display " to ")
  (display (ask new-place 'name))
  (newline))

(define (have-fit p)
  (newline)
  (display "Yaaah! ")
  (display (ask p 'name))
  (display " is upset!")
  (newline))


(define (nth n things)
  (cond ((null? things) (error "NTH called with empty input list" n))
	((zero? n) (car things))
	(else (nth (- n 1) (cdr things)))))

(define (pick-random set)
  (nth (random (length set)) set))

(define (delete thing stuff)
  (cond ((null? stuff) '())
	((eq? thing (car stuff)) (cdr stuff))
	(else (cons (car stuff) (delete thing (cdr stuff)))) ))

(define (place? obj)
  (and (procedure? obj)
       (ask obj 'place?)))

(define (person? obj)
  (and (procedure? obj)
       (ask obj 'person?)))

(define (thing? obj)
  (and (procedure? obj)
       (ask obj 'thing?)))


(define (name obj) (ask obj 'name))
(define (inventory obj)
  (if (person? obj)
      (map name (ask obj 'possessions))
      (map name (ask obj 'things))))

(define (whereis obj)
  (if (person? obj)
      (let ((place (ask obj 'place)))
	(name place))
      (error "whereis not called with a person")))

(define (owner obj)
  (if (thing? obj)
      (let ((possessor (ask obj 'possessor)))
	(if (procedure? possessor)
	    (ask possessor 'name)
	    possessor))
      (error "owner not called with a thing")))

(define (ticket? obj)
  (and (thing? obj)
       (eq? (ask obj 'name)
	    'ticket)))

(define (laptop? obj)
  (and (procedure? obj)
       (ask obj 'laptop?)))

(define (thief? obj)
  (and (procedure? obj)
       (ask obj 'thief?)))

(define (policeperson? obj)
  (and (procedure? obj)
       (ask obj 'police?)))
