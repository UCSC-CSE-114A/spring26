---
geometry: margin=1in
documentclass: extarticle
fontsize: 10pt
mainfont: Helvetica
mathfont: Helvetica
---

<!-- Build this file with `pandoc --pdf-engine=xelatex worksheet03.md -o worksheet03.pdf` -->

Name: ________________________________\quad CruzID:  _____________________________@ucsc.edu

# CSE114A Section Worksheet 3: Tail Recursion

In today's section you will practice writing tail-recursive functions in Haskell. Turn in this worksheet to your TA when you're done (or when section ends, whichever comes first). You may leave as soon as you turn in the worksheet; it's also fine to stay and help classmates if you want. If you need help, ask your TA or your classmates.

This worksheet assumes that you have already completed the previous worksheets. If you haven't yet, you can find older worksheets on Zulip (#announcements > Section worksheets).

## Part 1: Setup

- [ ] If you have not done so yet, accept the `02-random-art` homework assignment via GitHub Classroom and clone your private assignment repository to your own computer.

- [ ] If you haven't yet, take the time to read the **introduction to tail recursion** in the Assignment 2 description, under "Part 1: Tail Recursion" (https://tinyurl.com/hw2-tailrec), paying particular attention to `listLength` and `listLengthAcc`.

- [ ] Create an empty file called `worksheet03.hs` at the top level of your `02-random-art` repository.  Run `stack ghci`, and at the `ghci>` prompt, use the command `:l worksheet03.hs` to load your empty file in.  For the rest of this worksheet, as you edit the file, use the command `:r` to reload the same file into GHCi (without specifying the file name again).

**Pro tip:** `:l` is short for `:load` and `:r` is short for `:reload`.  You can use the long versions if you want, but why do all that typing?

## Part 2: Tail Recursion

Here's a visualization of the execution of a call to `listLength` on a three-element list:

```
listLength ["larry", "buford", "walter"]
= 1 + listLength ["buford", "walter"]
= 1 + (1 + listLength ["walter"])
= 1 + (1 + (1 + listLength []))
= 1 + (1 + (1 + 0))
= 1 + (1 + 1)
= 1 + 2
= 3
```

And here's a visualization of the execution of a call to `listLengthAcc` on the same list:

```
listLengthAcc ["larry", "buford", "walter"] 0
= listLengthAcc ["buford", "walter"] 1
= listLengthAcc ["walter"] 2
= listLengthAcc [] 3
= 3
```

In the tail-recursive version, each call is completely replaced with another call to `listLengthAcc`, so there's **no more work to do after the last recursive call** -- the answer of `3` has already been accumulated in the argument, and there's no need to "remember what to do next", which saves space on the call stack.  Functional programming languages typically guarantee that tail-recursive functions can be transformed into efficient loops by the language implementation.  This behavior is sometimes referred to as *tail call elimination* or *tail call optimization*.

**Caveat about Haskell:** Haskell is a *lazy* language, which means that functions don't evaluate their arguments until absolutely necessary. As a result, tail recursion is a more nuanced (and perhaps less useful) concept in Haskell than it is in most languages. However, this course is about PL in general, not about Haskell specifically, so we study tail recursion because it is a generally useful and interesting PL concept!

In lecture last week, we wrote the non-tail-recursive function `tri`:

```
tri :: Int -> Int
tri 0 = 0
tri n = n + tri (n-1)
```

- [ ] In your `worksheet03.hs` file, implement `triAcc`, a tail-recursive version of `tri`, with the type signature `triAcc :: Int -> Int -> Int`, where the second `Int` argument accumulates the sum.  Your definition should have two equations and should use pattern matching, just like `tri`.

- [ ] Use GHCi to evaluate some calls to `triAcc`, e.g.,, `triAcc 0 0` should evaluate to `0`, `triAcc 5 0` should evaluate to `15`, and `triAcc 60 0` should evaluate to `1830`. Fix any bugs you find in your code.

In the box below, **write out a visualization** of a call to `triAcc 3 0`, similar to the one for `listLengthAcc` on the previous page.

`triAcc 3 0`\newline
\framebox(480, 100)
\newline

It is annoying and error-prone to have to pass the accumulator argument of `0` to `triAcc`, so let's fix it.

- [ ] In your `worksheet03.hs` file, refactor your `triAcc` implementation to take only one argument, so that it has the type signature `Int -> Int`, like `tri`.

**Hint:** Two ways to do this are by writing a separate helper function or by using a `where` clause.  The introduction to tail recursion in the Assignment 2 description gives examples of both of these approaches.

Finally, here's another function we wrote in lecture last week:

```
duplicateAll :: [a] -> [a]
duplicateAll []     = []
duplicateAll (x:xs) = x : x : duplicateAll xs
```

The `duplicateAll` function is *almost* tail-recursive, except for two calls to `(:)`. Such functions are known as *tail-recursive modulo cons* (see https://en.wikipedia.org/wiki/Tail_call#Tail_recursion_modulo_cons for more information).  For practice, though, let's write an *entirely* tail-recursive version of `duplicateAll`.

- [ ] In your `worksheet03.hs` file, implement `duplicateAllAcc`, a tail-recursive version of `duplicateAll`, with the type signature `duplicateAllAcc :: [a] -> [a] -> [a]`, where the second argument of type `[a]` accumulates the result list.  Your definition should have two equations and use pattern matching.

**Hint:** You might need to use the append function `(++)` to append something to the accumulator argument.

- [ ] Evaluate some calls to `duplicateAllAcc` in GHCi and fix any bugs you find in your code. For instance:
  ```
  ghci> duplicateAllAcc [1, 2, 3] []
  [1,1,2,2,3,3]
  ghci> duplicateAllAcc ["the creature", "minion"] []
  ["the creature","the creature","minion","minion"]
  ```
