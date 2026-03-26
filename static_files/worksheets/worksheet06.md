---
geometry: margin=1in
documentclass: extarticle
fontsize: 10pt
mainfont: Helvetica
mathfont: Helvetica
---

<!-- Build this file with `pandoc --pdf-engine=xelatex worksheet06.md -o worksheet06.pdf` -->
<!--
If the above command doesn't work due to missing fonts, use:
`pandoc --pdf-engine=xelatex -V 'mainfont:Arial' -V 'mathfont:Arial' worksheet06.md -o worksheet06.pdf`
-->

Name: ________________________________\quad CruzID:  _____________________________@ucsc.edu

# CSE114A Section Worksheet 6: Interpreter Practice

In today's section, you will gain practice with the concepts of **abstract syntax trees (ASTs)**, **environments**, and **let-expressions** by implementing an interpreter. Turn in this worksheet to your TA when you're done (or when section ends, whichever comes first). You may leave as soon as you turn in the worksheet, or stay and help classmates if you want. If you need help, ask your TA or your classmates.

This worksheet assumes that you have already completed the previous worksheets. If you haven't yet, you can find older worksheets on Zulip (#announcements > Section worksheets).

## Part 1: Setup

- [ ] If you have not done so yet, accept the `04-nano` homework assignment via GitHub Classroom and clone your private assignment repository to your own computer.

- [ ] Create an empty file called `worksheet06.hs` at the top level of your `04-nano` repository. Run `stack ghci`, and at the `ghci>` prompt, use the command `:l worksheet06.hs` to load your empty file. For the rest of this worksheet, as you edit the file, use the command `:r` to reload the same file into GHCi.

## Part 2: Extending our AST

In section worksheet 5, you wrote an interpreter for a tiny expression language for strings.  We will now extend that language with more features: Boolean literals (`True` and `False`), `(&&)`  and `(||)` operations on Booleans, the `(==)` operation, and `let`-expressions.  Here is the AST type:

```haskell
data Expr = Var String           -- Variable
          | Str String           -- String literal
          | Boo Bool             -- Boolean literal: `True`, `False`
          | Rev Expr             -- Reverse a string: `reverse`
          | Let String Expr Expr -- let-expression: `let x = e1 in e2`
          | Bin Binop Expr Expr  -- Binary operations: `e1 ++ e2`, etc
  deriving Show                  -- This allows GHCi to print an Expr
```

We are now representing binary operations `(++)`, `(==)`, `(&&)`, and `(||)` as `Bin` AST nodes, each with a specified `Binop` constructor:

```haskell
data Binop = Cat  -- Concatenate strings: (++)
           | Eq   -- Equality check: (==)
           | And  -- Boolean conjunction: (&&)
           | Or   -- Boolean disjunction: (||)
  deriving Show
```

For example, we can represent the expression

```haskell
let s = "cookie" ++ "nympha" 
  in reverse s == "ahpmyneikooc"
```

as the AST

```haskell
example = Let "s" (Bin Cat (Str "cookie") (Str "nympha"))
  (Bin Eq (Rev (Var "b")) (Str "ahpmyneikooc"))
```

- [ ] Copy the definitions of the above `Expr` and `Binop` types into your `worksheet06.hs` file.

- [ ] Use `:t` in GHCi to make sure the type of `example` above is `Expr`.

\newpage

Here's a slightly bigger expression:

```haskell
let str1 = "larry" in
  let str2 = "min" ++ "ion" in
    str1 == str2 || "minion" == str2
```
Be the parser: write down the AST that corresponds to the above expression.
\newline
\framebox(480,110)
\newline

## Part 3: Extending our interpreter and dealing with type errors

Our language now has expressions that will evaluate to `Bool`s (not just `String`s anymore), so we'll need to define a new `Value` type to represent both `Bool` and `String` values:

```haskell
data Value = ValStr String | ValBoo Bool
  deriving Show
```

- [ ] Instead of binding variable names to `String`s, our environments should bind them to `Value`s. Add the definition of `Value` to your `worksheet06.hs` file, and add updated definitions of `ListEnv` and `lookupInEnv` from section worksheet 5 that work with `Value`s. You should only need to make a tiny change to both definitions. You will also want the `UnboundError` type from section worksheet 5. (If you didn't complete section worksheet 5, start from the solutions posted on Zulip.)

What should happen with an expression like `Cat (Str "larry") (Boo False)`? This is a legal `Expr` AST, but it represents a program that is *ill-typed*: the program `"larry" ++ False`.  We'll raise a *run-time type error* in such cases (by throwing an exception with `error "type error!"` when they arise). 

- [ ] In your `worksheet06.hs` file, implement a function `applyOp :: Binop -> Value -> Value -> Value` that takes a binary operation (`Cat`, `Eq`, `And`, or `Or`) and two `Value`s, and returns a new `Value` that is the result of applying the operation to the `Value`s.  If the provided `Value`s don't match up with the types expected by the operation, `applyOp` should throw an exception with `error "type error!"`.

**Hint:** You can implement `applyOp` with six cases: one case each for `Cat`, `And`, and `Or`; two cases for `Eq`; and a catch-all case to deal with type errors.  The `Eq` operation needs two cases because it is special: it should work on both kinds of `Value`s, but both arguments should be of the same type.  For example, the expression `True == False` is well-typed, and so is `"larry" == "minion"`, but `True == "larry"` is ill-typed.

- [ ] Finally, in your `worksheet06.hs` file, implement an interpreter for `Expr`s with the type signature
  ```haskell
  eval :: ListEnv -> Expr -> Either UnboundError Value
  ```

**Hints:** You can use the implementation of `eval` from section worksheet 5 as a starting point. The `Var` case should stay the same. The `Str` case will need a tiny tweak because we are returning something of type `Value`, and the new `Boo` case will be similar to the `Str` case. The new `Bin` case will replace (and generalize) the old `Cat` case; use your `applyOp` function to implement it. The `Rev` case will need to change in two ways: first, to deal with the fact that we are returning `Value`s rather than `String`s, and second, to handle possible type errors. Finally, the `Let` case will be similar to what we have seen in lecture.

When you are done with your interpreter, test your work in GHCi: `eval [] example` (where `example` is as defined on the previous page) should return `Right (ValBoo True)`.  You should get the same result when evaluating the expression from the top of this page.

