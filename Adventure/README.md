# Project 3: Adventure Game

This is my solution to the Object Oriented Programming Project "Adventure Game".

```
stklos> (load "simply.scm")
stklos> (load "obj.scm")
stklos> (load "adv.scm")
stklos> (load "tables.scm")
stklos> (load "labyrinth.scm")
stklos> (load "adv-world.scm")
stklos> (ask Imi 'place)
#[closure noahs]
stklos> (let ((where (ask Imi 'place)))
	  (ask where 'name))
noahs
stklos> (fancy-move-loop Imi)

You see here
imis-laptop
(east south north)
?  > help
Usage: stop look north south east west up down
You see here
imis-laptop
(east south north)
?  > north
How about a cinnamon raisin bagel for dessert?


imi moved from noahs to telegraph-ave
There are tie-dyed shirts as far as you can see...


You see here
jack
(south north)
?  > north


imi moved from telegraph-ave to sproul-plaza

You see here
nasty
(down west south north east)
?  > east


imi moved from sproul-plaza to sproul-hall
Miles and miles of students are waiting in line...

You see here

(west east)
?  > east
**** Error:
error: You can check out any time you'd like, but you can never leave
	(type ",help" for more information)
stklos> (fancy-move-loop Imi)

You see here

(west east)
?  > east
**** Error:
error: You can check out any time you'd like, but you can never leave
	(type ",help" for more information)
stklos> (fancy-move-loop Imi)

You see here

(west east)
?  > east
**** Error:
error: You can check out any time you'd like, but you can never leave
	(type ",help" for more information)
stklos> (fancy-move-loop Imi)

You see here

(west east)
?  > east
You're free to leave!


imi moved from sproul-hall to 61a-lab
The computers seem to be down


You see here
hacker
(west north)
?  >
```
