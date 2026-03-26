---
geometry: margin=1in
documentclass: extarticle
fontsize: 10pt
mainfont: Helvetica
mathfont: Helvetica
---

<!-- Build this file with `pandoc --pdf-engine=xelatex worksheet02.md -o worksheet02.pdf` -->

Name: ________________________________\quad CruzID:  _____________________________@ucsc.edu

# CSE114A Section Worksheet 2: More Lambda Calculus and Up and Running with Haskell

In today's section you will practice programming in lambda calculus, and you will start familiarizing yourself with tools for working with the Haskell programming language. Turn in this worksheet to your TA when you're done (or when section ends, whichever comes first). You may leave as soon as you turn in the worksheet; it's also fine to stay and help classmates if you want. If you need help, ask your TA or your classmates.

This worksheet assumes that you have already completed the previous week's worksheet. If you haven't yet, you can find the previous worksheet on Zulip (#announcements > Section worksheets).

## Part 1: More Lambda Calculus

Part 3 of the `00-lambda` assignment (the `tests/03_minus.lc` file) asks you to *define* named lambda calculus expressions in such a way that the provided tests pass.

Once an expression is named and defined, it can be used in the definition of another expression. For example, `TRUE` and `ITE` are used in the definition of `OR`:

```
let TRUE  = \x y -> x
let ITE   = \b x y -> b x y
let OR    = \b1 b2 -> ITE b1 TRUE b2
```
This will make our job when defining complicated expressions much easier.

- [ ] At the top level of your `00-lambda` assignment repository, create a file called `worksheet02.lc` using your favorite text editor. Copy and paste the definitions from the `tests/03_minus.lc` file (everything from `let TRUE = ...` to `let SND = ...`) into `worksheet02.lc`.  You'll use these combinators to do the rest of this worksheet.

In the box below, define a new lambda calculus combinator `NOT` that takes one argument, returns `TRUE` if its argument evaluates to `FALSE`, and returns `FALSE` if its argument evaluates to `TRUE`. (Don't worry about the behavior of `NOT` if it is passed arguments that evaluate to anything other than `TRUE` or `FALSE`.  For example, the program `NOT TWO` is nonsensical.)

`let NOT = `\newline
\framebox(480, 60)
\newline

**Hint:** Use `ITE`, `TRUE`, and `FALSE` to define `NOT`.

Next, in the box below, define a lambda calculus combinator `INCRFLIP` that takes one argument, which is a `PAIR` of a number and a Boolean.  `INCRFLIP` should return a new `PAIR` with an *incremented* first element (e.g., from `ONE` to `TWO`) and a *flipped* second element (e.g., from `FALSE` to `TRUE`).

`let INCRFLIP = `\newline
\framebox(480, 60)
\newline

**Hint:** Use `PAIR`, `FST`, `SND`, `INCR`, and `NOT` to define `INCRFLIP`.

Below are a few unit tests for the `NOT` and `INCRFLIP` combinators, written as Elsa reductions, that should all pass if you've written the combinators correctly.  These tests use the `=~>` step: in Elsa, `t =~> t'` says that `t` reduces to `t'` in zero or more steps *and* that `t'` is in *normal form* (that is, it cannot be reduced further).  These tests are far from exhaustive -- one could certainly have incorrect implementations of `NOT` and `INCRFLIP` that still pass all the tests -- but they help give us some confidence about the correctness of our code.

```
eval not_test1 : NOT TRUE =~> FALSE
eval not_test2 : NOT FALSE =~> TRUE
eval not_test3 : NOT (AND FALSE TRUE)  =~> TRUE
eval not_test4 : NOT (NOT (NOT FALSE)) =~> TRUE
eval incrflip_test1 : INCRFLIP (PAIR ONE FALSE) =~> (\b -> b TWO TRUE)
```

- [ ] Add your definitions of `NOT` and `INCRFLIP` to your `worksheet02.lc` file.  Then, add the above unit tests at the bottom of the file and run `stack exec elsa worksheet02.lc`. If your implementations are correct, Elsa will report `OK not_test1, not_test2, not_test3, not_test4, incrflip_test1`. If any tests fail, go back and fix your definitions (and ask for help if you need it!).

- [ ] Now come up with a unit test of your own for `INCRFLIP`, and use Elsa to check to see if it passes. (Keep in mind that the only numbers defined in `03_minus.lc` to begin with are `ZERO`, `ONE`, and `TWO`, so if you want to use other numbers, you'll want to add definitions for them.)

In the `incrflip_test1` reduction above, you might have expected to see `INCRFLIP (PAIR ONE FALSE)` evaluate to `PAIR TWO TRUE`. Instead, it is `(\b -> b TWO TRUE)`.  Why?  Because `PAIR TWO TRUE` is *not in normal form*!  Instead, `(\b -> b TWO TRUE)` is what `PAIR TWO TRUE` *normalizes to*, and since the test is written with `=~>`, it's what we have to use.  You will notice something similar when writing your own test for `INCRFLIP`, and when working on part 3 of the `00-lambda` assignment.

## Part 2: Up and Running with Haskell

- [ ] If you have not done so yet, accept the `01-haskell` homework assignment via GitHub Classroom.  Then clone your private assignment repository to your own computer.

- [ ] At the top level of your cloned `01-haskell` repository, run `stack build` at the command line.

If you successfully completed last week's section worksheet, `stack build` won't need to run for long, because you already have the correct version of GHC, the *Glasgow Haskell Compiler*, installed. GHC is the *de facto* standard implementation of Haskell, and we'll use it for all the assignments in this course.  Each assignment is structured as its own distinct Stack project, but they all use the same version of GHC, so Stack won't need to reinstall GHC each time.

- [ ] At the top level of your `01-haskell` repository, run the command `stack ghci`.

Welcome to GHCi, GHC's interactive environment (the "i" stands for "interactive"). From here, at the `ghci>` prompt, you can type Haskell expressions to be evaluated.  Give it a try:

- [ ] Try evaluating some expressions, like `1 + 2`, or `not False`, or `(\x -> x) "hello haskell"`

GHCi also supports many *commands*. One of the most useful commands is `:t`, which tells you the *type* of an expression!

- [ ] Run the command `:t not False` to ask GHCi what the type of `not False` is.

- [ ] What do you suppose the type of `not` is?  What about the type of the identity function, `\x -> x`?  Use `:t` to ask GHCi about them.

Earlier, we said that the lambda calculus program `NOT TWO` is nonsensical: it will evaluate to *something*, but not anything that "makes sense". Haskell has a *type system* that *rules out* such programs: they cannot be run at all! Haskell's type checker will stop them from running *before* they can wreak havoc at run time.

- [ ] Try to evaluate `not 2` in GHCi. You'll get an informative *type error*. See if you can understand what the error message is saying. Try some other nonsensical programs, like `not "hello"` -- what happens?
