---
geometry: margin=1in
documentclass: extarticle
fontsize: 10pt
mainfont: Helvetica
mathfont: Helvetica
---

<!-- Build this file with `pandoc --pdf-engine=xelatex worksheet04.md -o worksheet04.pdf` -->

Name: ________________________________\quad CruzID:  _____________________________@ucsc.edu

# CSE114A Section Worksheet 4: Abstract Syntax Trees

In today's section you will practice working with abstract syntax trees (ASTs) in Haskell. Turn in this worksheet to your TA when you're done (or when section ends, whichever comes first). You may leave as soon as you turn in the worksheet; it's also fine to stay and help classmates if you want. If you need help, ask your TA or your classmates.

This worksheet assumes that you have already completed the previous worksheets. If you haven't yet, you can find older worksheets on Zulip (#announcements > Section worksheets).

## Part 1: Setup

- [ ] If you have not done so yet, accept the `02-random-art` homework assignment via GitHub Classroom and clone your private assignment repository to your own computer.

- [ ] If you haven't yet, take the time to read the explanation of `Expr` in the Assignment 2 description, under "Part 2: Random Art".

- [ ] Create an empty file called `worksheet04.hs` at the top level of your `02-random-art` repository.  Run `stack ghci`, and at the `ghci>` prompt, use the command `:l worksheet04.hs` to load your empty file in. For the rest of this worksheet, as you edit the file, use the command `:r` to reload the same file into GHCi (without specifying the file name again).

**Pro tip:** `:l` is short for `:load` and `:r` is short for `:reload`.  You can use the long versions if you want, but why do all that typing?

## Part 2: Abstract Syntax Trees

An **abstract syntax tree (AST)** is a representation of the structure of a program (or part of a program). It captures the structure of the code, abstracting away specific syntactic details. Each node in an AST represents a construct in the source code.

For this worksheet, we'll represent ASTs using the `Expr` data type defined in Assignment 2, but without the `Thresh` constructor.

Here's the `Expr` definition:

```haskell
data Expr
  = VarX
  | VarY
  | Sine    Expr
  | Cosine  Expr
  | Average Expr Expr
  | Times   Expr Expr
```

And here is the grammar of expressions in the tiny programming language of Assignment 2:

```
e ::= x
    | y
    | sin(pi*e)      -- the "sinpi" function
    | cos(pi*e)      -- the "cospi" function
    | ((e+e)/2)      -- average the value of two expressions
    | e*e            -- multiply two expressions
```

Consider the following expression in this tiny language:
`sin(pi*((x+y)/2))`

The corresponding AST -- which is an expression of `Expr` type -- is:
`Sine (Average VarX VarY)`

<!-- question about converting a string to AST  -->
Converting a human-readable program string to an AST is *parsing*.  Be a (human) parser: in the boxes below, write out the ASTs that correspond to the given expressions.  Each one should be an expression of `Expr` type.

`cos(pi*x*y)`
\newline
\framebox(480, 40)
\newline
<!-- solution: Cosine (Times VarX VarY) -->

`sin(pi*(cos(pi*x)*y))`
\newline
\framebox(480, 40)
\newline
<!-- solution: Sine (Times (Cosine VarX) VarY) -->

<!-- question about converting a AST to string manually  -->
Converting an AST to a human-readable program string is *pretty-printing*.  Be a (human) pretty-printer: in the boxes below, write out the expressions for the given ASTs.

`Sine (Times (Cosine VarX) VarY)`
\newline
\framebox(480, 40)
\newline
<!-- solution: sin(pi*cos(pi*x)*y) -->

`Average (Sine (Times VarX VarY)) (Cosine (Average VarX VarY))`
\newline
\framebox(480, 40)
\newline
<!-- solution: ((sin(pi*x*y)+cos(pi*((x*y)/2)))/2)

<!-- question about evaluating the depth of an AST -->

Finally, write a Haskell function `depth` that takes an `Expr` and returns its *maximum nesting depth*.

For example:

  * `VarX` and `VarY` both have depth 0, so `depth VarX` should return 0.
  * `Sine VarX` has depth 1.
  * `Average (Sine VarX) VarY` has depth 2, since it has two subexpressions: one of which is `Sine VarX`, which has depth 1, and one of which is `VarY`, which has depth 0.
  
You can find a more detailed explanation of depth in the description of Assignment 2 Problem 2(c).

- [ ] Copy the `Expr` definition from `src/RandomArt.hs` to your `worksheet04.hs` file.  (This time, include the `Thresh` constructor.)

- [ ] In `worksheet04.hs`, implement the `depth` function with type signature `depth :: Expr -> Int`. 

**Hint:** Write one equation for each of the `Expr` constructors.  Use pattern matching to match against each constructor.  `VarX` and `VarY` are the two base cases, and every other case will call `depth` recursively.

**Hint:** You can use the `max` library function to get the maximum of two `Int`s.  For the `Thresh` case, you might need more than one call to `max`.

- [ ] In your `worksheet04.hs` file, define a value `myExpr` (of `Expr` type) that represents the AST of the program `((x+y)/2)*cos(pi*sin(pi*y))`.

- [ ] In GHCi, find the depth of `myExpr` using `depth`, and write down the depth you get in the box below.
\newline
\framebox(450, 30)
\newline
