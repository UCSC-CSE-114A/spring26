---
geometry: margin=1in
documentclass: extarticle
fontsize: 10pt
mainfont: Helvetica
mathfont: Helvetica
---

<!-- Build this file with `pandoc --pdf-engine=xelatex worksheet07.md -o worksheet07.pdf` -->
<!--
If the above command doesn't work due to missing fonts, use:
`pandoc --pdf-engine=xelatex -V 'mainfont:Arial' -V 'mathfont:Arial' worksheet07.md -o worksheet07.pdf`
-->

Name: ________________________________\quad CruzID:  _____________________________@ucsc.edu

# CSE114A Section Worksheet 7: More Interpreter Practice

In today's section, you will gain more practice with writing interpreters, and you'll learn about the concepts of **static scope** and **dynamic scope**. Turn in this worksheet to your TA when you're done (or when section ends, whichever comes first). You may leave as soon as you turn in the worksheet, or stay and help classmates if you want. If you need help, ask your TA or your classmates.

This worksheet assumes that you have already completed the previous worksheets. If you haven't yet, you can find older worksheets on Zulip (#announcements > Section worksheets).

## Part 1: Setup

- [ ] If you have not done so yet, accept the `04-nano` homework assignment via GitHub Classroom and clone your private assignment repository to your own computer.

- [ ] Create an empty file called `worksheet07.hs` at the top level of your `04-nano` repository. Run `stack ghci`, and at the `ghci>` prompt, use the command `:l worksheet07.hs` to load your empty file. For the rest of this worksheet, as you edit the file, use the command `:r` to reload the same file into GHCi.

## Part 2: Extending our AST (again)

In section worksheet 6, we extended the language from section worksheet 5 to support Boolean literals, operations on Booleans, and `let`-expressions. We'll now extend it again to support function definitions (`Lam`) and function calls (`App`):

```haskell
data Expr = Var String           -- Variable
          | Str String           -- String literal
          | Boo Bool             -- Boolean literal: `True`, `False`
          | Rev Expr             -- Reverse a string: `reverse`
          | Let String Expr Expr -- let-expression: `let x = e1 in e2`
          | Bin Binop Expr Expr  -- Binary operations: `e1 ++ e2`, etc
          | Lam String Expr      -- Function definition
          | App Expr Expr        -- Function call
  deriving Show                  -- This allows GHCi to print an Expr

data Binop = Cat  -- Concatenate strings: (++)
           | Eq   -- Equality check: (==)
           | And  -- Boolean conjunction: (&&)
           | Or   -- Boolean disjunction: (||)
  deriving Show
```

Now that our language supports functions, we need to extend our `Value` type from section worksheet 6 with a constructor for *closures*:

```haskell
data Value = ValStr String | ValBoo Bool | ValClos String Expr ListEnv
  deriving Show
  
type ListEnv = [(String, Value)]
```

- [ ] Copy the definitions of `Expr`, `Binop`, `Value`, and `ListEnv` into your `worksheet07.hs` file.  You can start with what you had from section worksheet 6 (or just find the solutions to worksheet 6 on Zulip and start from there), and just add the `Lam` and `App` constructors to `Expr` and the `ValClos` constructor to `Value`. The rest will stay the same.

We can now write ASTs for expressions like `let f = \s -> s ++ " is cute" in f "nympha"`. Write down the AST that corresponds to this expression. You'll need the `Lam` and `App` constructors (among others).

`exampleAST =`
\newline
\framebox(480,85)
\newline

## Part 3: Extending our interpreter

- [ ] Starting with your implementation of `eval` from section worksheet 6, add cases for `Lam` and `App`.  The rest of the cases will stay the same.  (For this worksheet, you do *not* need to support recursive functions.)  You'll need to pull in the definitions of `UnboundError`, `lookupInEnv`, and `applyOp` from section worksheet 6; they'll all stay the same, too.

**Hints:** The `Lam` case of `eval` is easy; recall that the value of a `Lam` expression is a closure.  For the `App` case, remember the three-step recipe:

1. Evaluate the function expression, hopefully getting a closure.
2. Evaluate the argument expression, hopefully getting some kind of value.
3. Evaluate the body of the closure from step (1) *using the environment from the closure*, extended with a binding from the function's formal parameter to the argument value from step (2).

You'll need to do some error handling to deal with the situations where the function expression and argument expression *don't* evaluate to a closure and a value, respectively.  If you get stuck, ask for help or check the live code from last week's lecture.

When you're done with `eval`, add the definition of `exampleAST` to `worksheet07.hs` and test your work in GHCi: `eval [] exampleAST` should return something that compliments Maya's cat.

## Part 4: The perils of dynamic scope

Suppose you had an expression like this:

```haskell
example2 = let str = " is cute" in
             let f = \s -> s ++ str in
               let str = " is smelly" in
                 f "nympha"
```

We evaluate function bodies *using the environment saved inside the function's closure*, and *not* the environment from the place where the function is *called*.  This gives us what is known as **static scope**.  Without static scope, `example2` would evaluate to something mean about AJ's cat!

Evaluating function bodies using the environment at the place the function is *called* would give us what is known as **dynamic scope**. It is often considered a Bad Idea (although some languages do use it).

- [ ] Make a *tiny* one-line change to the `App` case of `eval`, so that your interpreter implements dynamic scope instead of static scope. (**Hint:** don't use the environment from inside the closure.)

- [ ] Write down an AST for `example2` above, define it as `example2AST`, and run `eval [] example2AST` in GHCi.  (Remember: `:r` to reload.) Tragically, you should get something that insults AJ's cat.

- [ ] Finally, change `eval` back to how it was, reload the file into GHCi, and evaluate `example2AST` again. Thankfully, you should once again get something that compliments AJ's cat.
