# Project 4: Logo Interpreter

This is my solution to the [Programming Project "Logo Interpreter"](https://inst.eecs.berkeley.edu/%7Ecs61a/reader/vol1.html) with some extras, like optional inputs to procedures, macros, templates and more.

This is a Logo interpreter written in Scheme. The language it implements is a subset of the Berkeley Logo language. (Note that this implementation lacks the turtle graphics part of Logo and focuses on the symbolic computing part instead.)

Most of the Logo code here are borrowed from-, or based on the amazing book series [Computer Science Logo Style 2nd Edition Volume 1-2 by Brian Harvey Mit Press](https://people.eecs.berkeley.edu/~bh/logo.html).

I use the [stklos](http://www.stklos.net) scheme implementation, since it mixes well with the Berkeley CS61A course material. To install stklos on macOS, I use [Homebrew](https://brew.sh).

## Examples

### Some basics

The snippet below can be used to start up the interpreter. (It also loads a small Logo library with useful procedures like `map`, `foreach`, etc.)

```
*   STklos version 1.10
 *  Copyright (C) 1999-2011 Erick Gallesio - Universite de Nice <eg@unice.fr>
* * [Darwin-16.1.0-x86_64/pthread/no-readline/utf8]
stklos> (load "simply.scm")
stklos> (load "obj.scm")
stklos> (load "logo.scm")
stklos> (load "logo-meta.scm")
stklos> (initialize-logo)
? load "logolib 
? 
```

Logo source code can be loaded into the interpreter using the `load` command. The below example load the `choices` command, and uses it to list all the combinations of menu items.

```
? load "choices 
? choices [[small medium large] ~
           [vanilla [ultra chocolate] lychee [rum raisin] ginger] ~
           [cone cup]]
small vanilla cone
small vanilla cup
small ultra chocolate cone
small ultra chocolate cup
small lychee cone
small lychee cup
small rum raisin cone
small rum raisin cup
small ginger cone
small ginger cup
medium vanilla cone
medium vanilla cup
medium ultra chocolate cone
medium ultra chocolate cup
medium lychee cone
medium lychee cup
medium rum raisin cone
medium rum raisin cup
medium ginger cone
medium ginger cup
large vanilla cone
large vanilla cup
large ultra chocolate cone
large ultra chocolate cup
large lychee cone
large lychee cup
large rum raisin cone
large rum raisin cup
large ginger cone
large ginger cup
? 
```

### For loop

```
? for [i 2 7 1.5] [print :i]
2
3.5
5.0
6.5
? for [i 1 3] ~
      [for [j 1 3] ~
           [print word :i :j]]
11
12
13
21
22
23
31
32
33
? 
```

### Foreach

```
? foreach [a b c] [print (sentence "item # [has the value] ?)]
item 1 has the value a
item 2 has the value b
item 3 has the value c
?
```

### Map

```
? show map [?*?] [1 2 3 4]
[1 4 9 16]
?
```

```
? show map [list ? #] [a b c]
[[a 1] [b 2] [c 3]]
?
```

### Tree map

```
? show map.tree [first ?] [This [should be] [a [nested [structure]]]]
[T [s b] [a [n [s]]]]
?
```

### Filter

```
? show filter [?>2] [1 2 3 4]
[3 4]
?
```

### Reduce

```
? show reduce [word ?1 ?2] map [first ?] [every good boy does fine]
egbdf
?
```

```
? show reduce [ifelse ?2>?1 [?2] [?1]] [1 22 19]
22
?
```

### Parens must be used if commands or operations are called with non-defult number of arguments

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

### Conditionals

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

### Prefix- and infix arithmetic

```
? print sum product 3 4 8
20
? print (3 * 4) + 8
20
?
```

### Dynamic scoping

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

## More advanced features

### Optional inputs to procedures

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
