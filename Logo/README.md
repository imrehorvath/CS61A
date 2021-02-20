# Programming Project #4: Logo Interpreter

This is my solution to the [Programming Project "Logo Interpreter"](https://inst.eecs.berkeley.edu/%7Ecs61a/reader/vol1.html) with some extras, like optional inputs to procedures, templates, macro-support and many more.

This Logo interpreter is written in Scheme. The language it implements is a subset of UCB Logo. (Note that this implementation lacks turtle graphics and focuses on the symbolic computational aspects.)

Most of the Logo code found here were borrowed from, or based on the amazing book series [Computer Science Logo Style 2nd Edition Volume 1-2 by Brian Harvey MIT Press](https://people.eecs.berkeley.edu/~bh/logo.html).

The originally supplied code to this project was intended to be used with the UCB Scheme interpreter. In order to improve the project's portability between Scheme implementations, I made a few changes to the supplied code.

For bootstrapping the Logo interpreter in Scheme, two initialization files have been provided. [.gambcini](.gambcini) for Gambit and [guileini.scm](guileini.scm) for Guile Scheme.

An experimental online version of this interpreter can be found at: [https://imrehorvath.github.io/logo-in-the-browser/](https://imrehorvath.github.io/logo-in-the-browser/). The online version runs Gambit Scheme in Ymacs. It is based on Marc Feeley's gambit-in-emacs-in-the-browser.

## Usage

In Guile, you can `(load "guileini.scm")` to bootstrap the Logo interpreter.

For examples, refer to: [examples.txt](examples.txt)
