# Project 4: Logo Interpreter

This is my solution to the Programming Project "Logo Interpreter" with some extras, like optional inputs to procedures, macros and templates.

This is a Logo interpreter written in Scheme. The language it implements is a subset of the Berkeley Logo language.

Some of its features are demonstrated below. The listing is from an actual interaction with the interpreter.

Most of the Logo code examples and the library are borrowed from the amazing book [Computer Science Logo Style 2nd Edition Volume 2: Advanced Techniques by Brian Harvey Mit Press](https://people.eecs.berkeley.edu/~bh/v2-toc2.html).

I use the [stklos Scheme](http://www.stklos.net), since it mixes very well with the Berkeley CS61A course material. To install stklos on macOS, I use [Homebrew](https://brew.sh).

To start the interpreter, fire-up stklos and use the below sequence to get a Logo prompt. The Logo prompt starts with a `? `.

```
stklos> (load "simply.scm")
stklos> (load "obj.scm")
stklos> (load "logo.scm")
stklos> (load "logo-meta.scm")
stklos> (initialize-logo)
?
```

Try the commands, `print`, `show` and `type`.

```
? print [a [b c] d]
a [b c] d
? show [a [b c] d]
[a [b c] d]
? type [a [b c] d]
a [b c] d? print "a print "b
a
b
?
```

Load sources

```
? load "logolib
?
```

For loops

```
? for [i 2 7 1.5] [print :i]
2
3.5
5.0
6.5
? for [i 1 3] [for [j 1 3] [print word :i :j]]
11
12
13
21
22
23
31
32
33
? for [i 1 2] [for [i 1 2] [print [Hello there!]]]
Hello there!
Hello there!
Hello there!
Hello there!
?
```

Define an iteration construct called `repeat` -as a procedure- and use it to do some iteration.

```
? to repeat :num :instr
> if :num=0 [stop]
> run :instr
> repeat :num-1 :instr
> end
? repeat 3 [print "hi print "bye]
hi
bye
hi
bye
hi
bye
?
```

Conditionals

```
? print ifelse 2=3 [5*6] [8*9]
72
? ifelse equalp 2 3 [print "yes] [print "no]
no
? ifelse equalp 3 3 [print "yes] [print "no]
yes
? print ifelse equalp 2 3 [product 5 6] [product 8 9]
72
? test equalp "hot first [hot chocolate]
? iftrue [print [Yes, it is hot.]]
Yes, it is hot.
? iftrue [print [Be careful!]]
Be careful!
? iffalse [print [This cannot happen.]]
?
```

Foreach

```
? foreach [a b c] [print (sentence [list item] % [has the value] ?)]
list item 1 has the value a
list item 2 has the value b
list item 3 has the value c
?
```

Use map with a template to square a list

```
? show map [? * ?] [1 2 3 4]
[1 4 9 16]
?
```

Tree map

```
? show map.tree [first ?] [This [should be] [a [nested [structure]]]]
[T [s b] [a [n [s]]]]
?
```

Filter a list of numbers for a given condition

```
? show filter [? > 2] [1 2 3 4]
[3 4]
?
```

Use map and reduce to mash the initials of the words of a sentence together to get a single word of the initials

```
? show reduce [word ?1 ?2] map [first ?] [every good boy does fine]
egbdf
?
```

Find the maximum in a number list

```
? show reduce [ifelse ?2 > ?1 [?2] [?1]] [1 22 19]
22
?
```

To access the template application count, use the `%` in the template

```
? show map [list ? %] [a b c]
[[a 1] [b 2] [c 3]]
?
```

Prefix- and infix arithmetic operations

```
? print sum product 3 4 8
20
? print (3 * 4) + 8
20
?
```

Use parenthesis if the procedure can handle variable number of arguments and you pass different number than the default

```
? print sum 2 3
5
? print sum 2 3 4
5
You don't say what to do with 4
? print (sum 2 3 4)
9
? print (sum 4 5 6 7 8)
30
? print (word "a "b "c "d)
abcd
? print (sum 4 5 product 6 7 8)
59
?
```

Define and use a global variable

```
? make "foo 27
? print :foo
27
?
```

This is a dynamically scoped language

```
? make "x 3
? to scope :x
> helper 5
> end
? to helper :y
> print (sentence :x :y)
> end
? scope 4
4 5
?
```

You can define optional inputs to procedures

```
? to opti :a [:b :a+1]
> print :b
> end
? opti 1
2
? (opti 1 5)
5
?
```

To quit the Logo interpreter and get back to stklos REPL, use the command `bye`

```
? bye
stklos>
```
