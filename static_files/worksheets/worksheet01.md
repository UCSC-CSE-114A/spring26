---
geometry: margin=1in
documentclass: extarticle
fontsize: 10pt
mainfont: Helvetica
mathfont: Helvetica
---

<!-- Build this file with `pandoc --pdf-engine=xelatex worksheet01.md -o worksheet01.pdf` -->

Name: ________________________________\quad CruzID:  _____________________________@ucsc.edu

# CSE114A Section Worksheet 1: Up and Running with Elsa

In today's section you will set up a Haskell development environment on your computer and practice with lambda calculus on paper and with Elsa. Turn in this worksheet to your TA when you're done (or when section ends, whichever comes first). You may leave as soon as you turn in the worksheet; it's also fine to stay and help classmates if you want. If you need help, ask your TA or your classmates.

## Part 1: Set up your Haskell development environment

In this course, the centerpiece of your Haskell development environment will be a tool called *Stack*. Stack is a command-line tool for building Haskell software projects and managing their dependencies.  All of the assignments in CSE114A are structured as Stack projects. You should install Stack so that you can compile, run, and test your code. Check off the checkboxes below for each task that you complete. If you've already done these things on your own before section, then check the checkboxes and move on to Part 2!

**Spend no more than 30 minutes on this part of the worksheet.**  It's OK if you don't check all the boxes; you can get help from the course staff later.

- [ ] Install Stack by following the detailed directions on the Stack website (note that there are directions for Linux, MacOS, and Windows; make sure you use the correct ones): https://tinyurl.com/stackinstall

- [ ] After installing Stack, run the command `stack --version` at the command line. If everything worked, the output of the command should tell you what version of Stack you're using.

- [ ] If you have not done so yet, accept the `00-lambda` homework assignment via GitHub Classroom.  This will create a private GitHub repository for you on the course GitHub organization. Then clone your private assignment repository to your own computer.

- [ ] At the top level of your cloned `00-lambda` repository, run `stack build` at the command line.

Running `stack build` for the first time **will take several minutes** and will download, compile, and install a bunch of stuff. When `stack build` is done, it will show a message that starts with `Installing executable hw0`. While you're waiting for `stack build` to finish running, go on and do the exercises in part 2.

## Part 2: Practice with lambda calculus on paper

Consider the following lambda calculus expression (written using Elsa syntax):

```
(\x -> (\y -> x y)) (\q -> q) (\z -> z)
```

In the box below, evaluate this expression using the $\beta$-rule discussed in lecture, until no more $\beta$-steps can be taken. Remember, function application is *left-associative*: `p q r` means `(p q) r`, not `p (q r)`. You should need three $\beta$-steps to get to a value (that is, an expression that can't be further reduced).
 
\framebox(480, 130)
\newline

<!-- Solution:

eval problem_2_1 :
  (\x -> (\y -> x y)) (\q -> q) (\z -> z)
  =b> (\y -> (\q -> q) y) (\z -> z)
  =b> (\q -> q) (\z -> z)
  =b> \z -> z
-->
   
Now consider the following expression:

```
\f -> (\x -> f (x x)) (\x -> f (x x))
```

Find a place in this expression where you can use the $\beta$-rule, and use it once. Fill in the result below:

\framebox(480, 60)
\newline

Now take the result of the previous step, find a place where you can use the $\beta$-rule, and again fill in the result below. What seems to be happening with this expression as you take $\beta$-steps?

\framebox(480, 60)
\newline

## Part 3: Practice with Elsa

*Elsa* is a tiny language designed to build intuition about how the lambda calculus works. In Elsa, a *reduction* is a sequence of lambda calculus expressions, chained together with *steps*.

Check off the checkboxes below for each task that you complete.

- [ ] At the top level of your `00-lambda` assignment repository, create a file called `worksheet01.lc` using your favorite text editor. Enter the following code into your file, and save it:

```
eval part_3_1 : 
  (\x -> x) (\y -> y) z
```

- [ ] At the top level of your `00-lambda` assignment repository, run the command `stack exec elsa worksheet01.lc` at the command line. This command uses Stack (`stack`) to execute (`exec`) the Elsa executable (`elsa`) with the file `worksheet01.lc` as input; the Elsa executable is one of the dependencies that was installed by `stack build` previously.  Elsa will report a helpful error message.

- [ ] Add `=b>` steps to your code for the `part_3_1` reduction, so that Elsa no longer reports an error when you run `stack exec elsa worksheet01.lc` at the command line.

Finally, what about functions with multiple arguments? In lambda calculus, functions only have one argument, but this is no real limitation, since functions with multiple arguments can always be rewritten to take their arguments one at a time; this is called *currying*. For example, instead of a function that takes arguments `x`, `y`, and `z` and returns `e`, we would instead write a function that takes `x` and returns a function that takes `y`, which returns a function that takes `z`, which returns `e`, as follows: `\x -> (\y -> (\z -> e))`. As a convenient shorthand, we can leave out the parentheses and just write `\x -> \y -> \z -> e`. Furthermore, we can contract this sequence of lambda abstractions and simply write `\x y z -> e`, and Elsa supports this syntactic sugar.

- [ ] In your `worksheet01.lc` file, define a reduction called `part_3_2`. Start with the expression
```
(\x y -> y x) (\z -> z) (\r -> (\p q -> r)) 
```
and add `=b>` steps until no more such steps can be taken.  (Hint: even though we are using syntactic sugar to make it appear like functions take multiple arguments, curried functions still take their arguments one at a time, so each `=b>` step will deal with just one argument.)

- [ ] Run the `stack exec elsa worksheet01.lc` command to check your work for the `part_3_2` reduction. When Elsa reports `OK`, you are done!


