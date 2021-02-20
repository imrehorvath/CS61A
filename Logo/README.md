# Project 4: Logo Interpreter

This is my solution to the [Programming Project "Logo Interpreter"](https://inst.eecs.berkeley.edu/%7Ecs61a/reader/vol1.html) with some extras, like optional inputs to procedures, macros, templates and many more.

This is a Logo interpreter written in Scheme. The language it implements is a subset of the Berkeley Logo language. (Note that this implementation lacks the turtle graphics part of Logo and focuses on the symbolic computing part only.)

Most of the Logo code found here were borrowed from, or based on the amazing book series [Computer Science Logo Style 2nd Edition Volume 1-2 by Brian Harvey MIT Press](https://people.eecs.berkeley.edu/~bh/logo.html).

The originally supplied code to this project was intended to be used with the UCB Scheme interpreter. To improve portability between scheme implementations, I made a few changes to the supplied code. Now it should be easier to switch between scheme implementations in the future.

For bootstrapping the Logo interpreter in Scheme, two initialization files have been provided. [.gambcini](.gambcini) for Gambit and [guileini.scm](guileini.scm) for Guile Scheme.

Experimental online version of this interpreter can be found on github.io: [https://imrehorvath.github.io/logo-in-the-browser/](https://imrehorvath.github.io/logo-in-the-browser/). The online version runs on Gambit and the UI is Ymacs. It's based on Marc Feeley's gambit-in-emacs-in-the-browser.

## Usage

In Guile, you can `(load "guileini.scm")` to start up the Logo interpreter.

For examples, refer to [examples.txt](examples.txt)!
