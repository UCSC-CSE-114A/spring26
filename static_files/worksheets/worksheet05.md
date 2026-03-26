---
geometry: margin=1in
documentclass: extarticle
fontsize: 10pt
mainfont: Helvetica
mathfont: Helvetica
---

<!-- Build this file with `pandoc --pdf-engine=xelatex worksheet05.md -o worksheet05.pdf` -->
<!--
i dont know why but the above command does not work on my machine because im missing the
"Helvetica" font. So I produced the pdf with this command:
`pandoc --pdf-engine=xelatex -V 'mainfont:Arial' -V 'mathfont:Arial' worksheet05.md  -o worksheet05.pdf`
-->

Name: ________________________________\quad CruzID:  _____________________________@ucsc.edu

# CSE114A Section Worksheet 5: Environments

In today's section, you will gain practice with the PL concept of *environments*. Turn in this worksheet to your TA when you're done (or when section ends, whichever comes first). You may leave as soon as you turn in the worksheet, or stay and help classmates if you want. If you need help, ask your TA or your classmates.

This worksheet assumes that you have already completed the previous worksheets. If you haven't yet, you can find older worksheets on Zulip (#announcements > Section worksheets).

## Part 1: Setup

- [ ] If you have not done so yet, accept the `03-env` homework assignment via GitHub Classroom and clone your private assignment repository to your own computer.

- [ ] Create an empty file called `worksheet05.hs` at the top level of your `03-env` repository.  Run `stack ghci`, and at the `ghci>` prompt, use the command `:l worksheet05.hs` to load your empty file in. For the rest of this worksheet, as you edit the file, use the command `:r` to reload the same file into GHCi.

## Part 2: Case expressions

A useful sum type in the Haskell Prelude is the `Either` type:

```haskell
data Either a b = Left a | Right b
```
Here's a function that pattern-matches on an `Either String Int` and returns a `String`:

```haskell
toString :: Either String Int -> String
toString (Left s)  = s
toString (Right n) = show n -- here, `show` converts an `Int` to a `String`
```

We can also use `case` expressions for pattern matching.  Here is an alternate definition of `toString` that uses a `case` expression. A `case` expression evaluates to whatever is on the right side of the `->` for the first pattern that matches the expression being scrutinized (the *scrutinee*).  (The `->` in `case` expressions is not to be confused with the `->` in types or in lambda expressions!)

```haskell
toString' :: Either String Int -> String
toString' e = case e of
                Left s  -> s
                Right n -> show n
```

A `case` expression can appear anywhere expressions can appear, and its scrutinee can be any expression.  Here's an example where a `case` expression is the body of a lambda abstraction, and its scrutinee is a tuple:

```haskell
caseExample = \x y -> case (not x, "hello, " ++ y) of
  (False, s) -> s
  (True,  _) -> "the first argument must have been False"
```

Be the type inferencer: what is the *type* of `caseExample`?
\newline
\framebox(480,40)
\newline

(If you're not sure, add `caseExample` to your `worksheet05.hs` file and use `:t` in GHCi to check its type.)

## Part 3: Implementing a small language with variables

The following `Expr` data type is the type of ASTs for a small expression language for strings:

```haskell
data Expr = Var String    -- Variable
          | Str String    -- String literal
          | Cat Expr Expr -- Concatenate strings
          | Rev Expr      -- Reverse a string
  deriving Show           -- This allows GHCi to print an Expr
```

Expressions in our language can contain *variables*, which are represented as `String`s wrapped with the constructor `Var`.
To interpret an expression like `Rev (Cat (Var "x") (Var "y"))`, we need a way to associate variables `"x"` and `"y"` with their values.
This is done using an *environment*.

A simple way to represent an environment is as a list of name-value pairs.  Since we're representing variable names as strings, and the only values in our language are strings, we'll use the type `[(String, String)]` for environments.
We can use the Haskell `type` keyword to define a convenient *type alias*.

```haskell
type ListEnv = [(String, String)]
```

A variable name that is not associated with any value in the environment is *unbound*.  We'll define an `UnboundError` type for dealing with this situation:

```haskell
data UnboundError = Unbound String
  deriving Show
```

Give the Haskell type signature for a function `lookupInEnv`.  The `lookupInEnv` function should take an environment and a variable name (in that order), and should return either the variable's value from the environment, or a value of `UnboundError` type.  (Hint: Use `Either`.)

`lookupInEnv ::`
\newline
\framebox(480,40)
\newline
<!-- 
lookupInEnv :: ListEnv -> String -> Either UnboundError String
-->

Next, define `lookupInEnv` to have the following behavior: if the provided environment does not contain a name-value pair for the specified variable name, `lookupInEnv` should return a value of `UnboundError` type. Otherwise, it should return the corresponding value from the environment.
(We will assume that environments contain *at most one* binding for each variable name.)

`lookupInEnv = `
\newline
\framebox(480,60)
\newline
<!--
lookupInEnv [] k = Left (Unbound ("variable " ++ k ++ " is unbound!"))
lookupInEnv ((k',v):env') k = if k == k' then Right v else lookupInEnv env' k
-->

**Pro tip:** You can use the `String` inside the `Unbound` constructor to provide an error message that names the unbound variable.  For instance, a call to `lookupInEnv` might behave like this:

```
ghci> lookupInEnv [] "x"
Left (Unbound "variable x is unbound!")
```

Copy the definitions of `Expr`, `ListEnv`, `UnboundError`, and `lookupInEnv` over to your `worksheet05.hs` file.  Finally, in `worksheet05.hs`, implement an interpreter for `Expr`s with the type signature

```haskell
eval :: ListEnv -> Expr -> Either UnboundError String
```

**Hints:** The `Str` case will be the simplest, the `Var` case will use `lookupInEnv`, and you can use the Prelude functions `(++)` and `reverse` to implement the `Cat` and `Rev` cases.  When you need to make recursive calls, try using `case` expressions to deal with unbound variable errors.
