# Project 4: Logo Interpreter

This is my solution to the [Programming Project "Logo Interpreter"](https://inst.eecs.berkeley.edu/%7Ecs61a/reader/vol1.html) with some extras, like optional inputs to procedures, macros, templates and more.

This is a Logo interpreter written in Scheme. The language it implements is a subset of the Berkeley Logo language. (Note that this implementation lacks the turtle graphics part of Logo and focuses on the symbolic computing part instead.)

Most of the Logo code here are borrowed from-, or based on the amazing book series [Computer Science Logo Style 2nd Edition Volume 1-2 by Brian Harvey MIT Press](https://people.eecs.berkeley.edu/~bh/logo.html).

The originally supplied code to this project was probably intended to be used with UCB Scheme (A modified version of STk). My solution to this problem was working fine with STk and STKlos too. But when I switched to another scheme, I faced problems with output flushing and the one argument `eval` -usage.

To improve portability between scheme implementations, I made a few changes to the supplied code. Now it should be easier to switch between scheme implementations in the future.

Experimental online version of this interpreter can be found on github.io: [https://imrehorvath.github.io/logo-in-the-browser/](https://imrehorvath.github.io/logo-in-the-browser/). The online version runs on Gambit and the UI is Ymacs. It's based on Marc Feeley's gambit-in-emacs-in-the-browser.

## Examples

```
GNU Guile 2.2.3
Copyright (C) 1995-2017 Free Software Foundation, Inc.

Guile comes with ABSOLUTELY NO WARRANTY; for details type `,show w'.
This program is free software, and you are welcome to redistribute it
under certain conditions; type `,show c' for details.

Enter `,help' for help.
scheme@(guile-user)> (load "simply.scm")
$1 = #t
scheme@(guile-user)> (load "obj.scm")
scheme@(guile-user)> (load "tables.scm")
scheme@(guile-user)> (load "logo.scm")
scheme@(guile-user)> (load "logo-meta.scm")
scheme@(guile-user)> (initialize-logo)
? for [i 1 3] [print :i]
1
2
3
? to average [:nums] 2
> op (apply "sum :nums) / (count :nums)
> end
? print average 1 5
3
? print (average 1 2 3 4 5)
3
? to buzz :n
> if (:n % 7) = 0 [print "buzz stop]
> if memberp 7 :n [print "buzz stop]
> print :n
> end
? foreach [1 14 17 89] "buzz
1
buzz
buzz
89
? to plural :word
> if equalp last :word "y [op word bl :word "ies]
> if equalp last :word "s [op word :word "es]
> output word :word "s
> end
? print map "plural [book body virus]
books bodies viruses
? to pigl :word
> if punctuationp last :word [op word pigl.real bl :word last :word]
> op pigl.real :word
> end
? to pigl.real :word
> if vowelp first :word [op word :word "ay]
> op pigl.real word bf :word first :word
> end
? to vowelp :letter
> op memberp :letter [a e i o u]
> end
? to punctuationp :letter
> op memberp :letter [. , ? !]
> end
? print map "pigl [pig latin is fun, and hard to master at the same time!]
igpay atinlay isay unfay, anday ardhay otay astermay atay ethay amesay imetay!
? print filter [?>2] [1 2 3 4]
3 4
? print map [?*?] [1 2 3 4]
1 4 9 16
? print reduce [max ?1 ?2] [1 999 432 654]
999
? print filter [?%2 =0] [1 2 3 4]
2 4
? 
```
