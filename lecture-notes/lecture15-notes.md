# CSE114A lecture 15

Agenda: 

- Intro to type checking and type inference
- A type system for mini-Nano
- A tiny, terrible type inferencer

## Intro to type checking and type inference

So, what we've been talking about the last couple weeks in lecture, and in the last couple of homework assignments, is writing interpreters that take ASTs and produce values.

And we left off last time having extended our interpreter to handle function definitions and function calls, so our language is starting to feel pretty "real"!

What happens, though, if we try to interpret an AST that does something like apply a number to a number?

```
(App (Leaf 3) (Leaf 4))
```

Or multiply two functions?

```
(Arith Mul (Lam "x" (Var "x")) (Lam "y" (Var "y")))
```

We'd get type errors, because you can't apply 3 to an argument, and you can't multiply a function.

```
ghci> interp [] (App (Leaf 3) (Leaf 4)) 
*** Exception: type error!
```

```
ghci> interp [] (Arith Mul (Lam "x" (Var "x")) (Lam "y" (Var "y")))
Just *** Exception: type error!
```

However, both of those ASTs are perfectly well-typed `Expr`s!

```
ghci> :t (App (Leaf 3) (Leaf 4)) 
(App (Leaf 3) (Leaf 4)) :: Expr
ghci> :t (Arith Mul (Lam "x" (Var "x")) (Lam "y" (Var "y")))
(Arith Mul (Lam "x" (Var "x")) (Lam "y" (Var "y"))) :: Expr
```

So you can have a *well-typed* `Expr` that still corresponds to an *ill-typed* *program*.  In other words, the set of all legal `Expr`s is much larger than the set of `Expr`s that actually correspond to programs that will run without an error.  This is unfortunate!

You'll notice the same thing on homework 4.  For example, `Plus (VBool True) (VInt 2)` is a well-typed expression of type `Expr`, representing a Nano AST.  But the program it corresponds to is `True + 2`, and if you try to evaluate the AST, you'll get a run-time type error (or at least you should, if you implement your interpreter correctly).

One way to deal with this problem is to implement a *type checker*. The type checker's job is to rule out ill-typed programs *before* they are interpreted -- that is, *before* run time.  The type checker tries to filter the set of programs to rule out all the ones that *would* "go wrong" at run time, if you were to run them.

Type checking can be done as kind of *static program analysis*.  The word "static" means the analysis can be done without actually *running* the program.  This is great, because it means we don't have to wait until run time to find out that an expression is ill-typed.

Haskell actually does more than just type *checking*; it does type *inference*.  This means that for the most part, you don't have to put type annotations on Haskell code.  Most people do at least write down the type signatures of their functions, but you wouldn't *have* to, because Haskell will infer types for you, and it will do its best to infer the most general type for any expression you write.

We've done several "be the type inferencer" exercises. where we try to informally talk through *how* the type inferencer does what it's doing. As an example, if we have an expression like

```
(\x -> x) "hello"
```

It's `String`.  How did we know that?  Well, we know that when we apply a function of type `a -> b` to an argument of type `a`, then we'll get something of type `b`.  That's a rule that we can make use of.

We also know that the type of this particular argument is `String`.  And we also know that because this is the identity function, its return type is the same as its argument type.

So here's a bunch of facts we know:

1) When we apply a function to an argument, then if the type of the argument matches what the function's argument type is supposed to be, then we'll get something of the function's return type.

2) This function's body is just `x`, so if the actual argument passed in for the formal parameter named `x` is of type `t`, then the function will also return something of type `t`.

3) The type of `"hello"` is `String`.

And putting all those facts together and doing a bit of constraint solving in our heads, we can conclude that the whole expression has type `String`.  So we just inferred the type `String` for this expression.

So what we're going to turn to now, in these last couple weeks of class, is actually *implementing* that type inference algorithm that we ran in our heads just now.  And homework 5 is about doing exactly that -- implementing type inference for the Nano language.

Our type inferencer is going to be much, *much* less sophisticated than Haskell's.  We won't have to deal with a lot of stuff that Haskell has.  (Just to pick one obvious example, Nano doesn't have typeclasses.)  But even so, we're going to need some rather fancy machinery to be able to implement type inference, so today we'll begin talking about that.

Before we jump in, to get a feel for where we're going, let's do our quiz now.

## A type system for mini-Nano

Let's suppose we have a sort of mini-version of the Nano language.  Here's the grammar of our language:

```
e ::= n | b | x | e1 + e2 | \x -> e | e1 e2 | let x = e1 in e2
```

So, we've got numbers, booleans, variables, addition, function definitions, function application, and `let`-expressions.  We don't have primitive functions, we don't have subtraction or multiplication, we don't have `if`-expressions, we don't have lists, and so on.

What *types* can expressions in this tiny language have?

We wrote down a grammar of expressions, so le's also write down a grammar of types.  I'll use the letter `T` for types.

```
T ::= Int | Bool | T1 -> T2
```

So, this is a pretty simple syntax of types.  We can have expressions with the types `Int` and `Bool`, and we can have arrow types, like `Int -> Int`.  But in our syntax of arrow types, the `t1` and `t2` can themselves be instantiated with arrow types, so `Int -> (Int -> Bool)` would be a type, `(Bool -> Bool) -> (Bool -> Bool)` would be a type, and so on,  That'd be like the the type of a function that takes a function from `Bool` to `Bool` and returns a function from `Bool` to `Bool`.

So, we want to define what's called a *typing relation* for mini-Nano. The typing relation will consist of a bunch of *typing rules* that will tell us under what circumstances an expression `e` has a type `T`.  It's a relation because it *relates* expressions to types.  We'll write the relation with a double colon, just like we do in type signatures: `e :: T`.  And eventually we'll be able to use this typing relation to infer types for mini-Nano expressions.

Each of the typing rules will deal with a particular kind of Nano expression.  Well, we only have seven kinds of expressions in our grammar, right?

```
e ::= n | b | x | e1 + e2 | \x -> e | e1 e2 | let x = e1 in e2
```

So we'll need only seven rules.  We won't get to all of them today.

Let's get the easy ones first.  In mini-Nano, if I have a number, a literal number, what type does that expression have?

`Int`!  So our rule is:

```
n :: Int
```

which is just read as "`n` has type `Int`".  That's it -- that's the whole rule for giving a type to numeric literals.  So the expression `3` has type `Int`, the expression `5000000` has type `Int`, and so on.

What about if I have a literal Boolean, `True` or `False`?  What's the rule then?

```
b :: Bool
```

"`b` has type `Bool`".  And that's it, that's the whole rule for giving a type to Boolean literals.  This is all quite easy and boring so far, isn't it?

Okay, two down, five to go.  Let's skip over variables for now, and deal with addition expressions.  If you have an expression `e1 + e2`, what type do you *want* it to have?

You really want it to have type `Int`.  But what nees to be true for `e1 + e2` to have type `Int`?

The expressions `e1` and `e2` both themselves have to have type `Int`.

So our rule is

```
e1 + e2 :: Int
```

-- except, unlike before, that's not all.  Now there are *premises*, or preconditions, that need to be satisfied before that's true.  So our notation for this will be to draw a horizontal line, and put the premises above the line.  Then we'll put the thing that the premises will let us conclude below the line, and call that the *conclusion*.  The complete rule is then:


```
e1 :: Int    e2 :: Int        <-- premises
----------------------
   e1 + e2 :: Int             <-- conclusion
```

This is called an *inference rule*, and it shows up all over the study of PL -- not just when talking about type systems, but in all kinds of other places, too.

We can now also see that our typing relation is *inductively* defined.  Whether an expression has a certain type depends on whether its subexpressions have certain types.  The base cases of our inductively defined typing relation will be the rules for numeric literals and boolean literals that we wrote down before, and this rule, the rule for addition expressions, is one of the inductive cases.

We can read this rule out loud like:

"If `e1` has type `Int`, and `e2` has type `Int`, then `e1 + e2` has type `Int`."

By the way, when we wrote the rules for numeric literals and boolean literals, we didn't draw a line to separate premises and conclusion because there were no premises.  Each of those rules was *only* a conclusion.  But some people like to draw the line anyway, and just have nothing above the line, to make it really clear that there are no premises.  So we can do that too for both of those rules, if we like.

```
--------         ---------
n :: Int         b :: Bool


e1 :: Int    e2 :: Int 
----------------------
   e1 + e2 :: Int
```

OK. We've only written down three typing rules so far, but we can already use our rules to construct a *proof* that a given mini-Nano expression has a certain type.  For instance, suppose we have the expression

`3 + (4 + 5)`

Which rule fits?  At the top level, this is an addition expression, so we have to use the addition rule.  And the two things that we're adding are `3` and `4 + 5`.  `3` is just a numeric literal, so it has type `Int`.  `4 + 5` is another addition expression, so for that expression to have type `Int` we would need premises saying that `4` is an `Int` and `5` is an `Int`.  They are, because they're just numeric literals too.  So our proof is complete.

```
                --------   --------
                4 :: Int   5 :: Int
--------        -------------------
3 :: Int           4 + 5 :: Int
-----------------------------------
       3 + (4 + 5) :: Int
```

Here, `3 + (4 + 5) :: Int` is called a *typing judgment*, and what I just wrote down is called a *derivation* for that typing judgment.  The derivation can be thought of as a tree.  The leaves of the tree are `3 :: Int`, `4 :: Int`, and `5 :: Int`, and the internal nodes use leaves or other internal nodes as premises.

So this particular typing derivation used the rule for numeric literals three times, and it used the rule for addition expressions twice.  Not too complicated, right?

Well, it's about to get more complicated.  We skipped over variables, so let's go back and deal with that.

How would we write a typing rule for variables?


```
  ???
--------
x :: ???
```

How do you know what the type of a variable is?  Any ideas?

So, in our interpreters that we've been writing the last couple of assignments, we pass around these things called environments that bind variables to their *values*, and when we want to know the value of a variable, we look it up in the environment.  So an environment might look something like

```
-- Environment (binds variables to their values)
[(x, 5), (f, closure...), (y, 7), ...]
```

But what we want to do now is something similar, but instead of letting us look up the *value* of a variable, it'll let us look up the *type* of a variable.  So let's call that a *type environment*.

```
-- Type environment (binds variables to their types)
[(x, Int), (f, Int -> Int), (y, Int), ...]
```

So it seems like, just like an interpreter needs to take an environment argument, our typing relation is going to need to take a type environment argument.

There's a traditional name that always gets used for type environments in the programming languages literature.  I don't actually know why this traditional name is the one that's used, but it is, and we're going to use it too.  The traditional name is `Gamma`, the Greek letter.  So we'll use `Gamma` as our name for it also.

Before we wrote our typing relation as `e :: T`, pronounced "`e` has type `T`".  But now we need to add a type environment argument to this relation.  It will now become a three-place relation that relates a type environment, an expression, and a type.

```
gamma |- e :: T
```

The thing that looks like a sideways letter T here is a "turnstile" symbol, and what it means is that *in* the type environment `gamma`, `e` has type `T`.  That's how I would now pronounce this judgment: In type environment `gamma`, `e` has type `T`.  Or, I could pronounce turnstile as "entails", and I could say "`gamma` entails that `e` has type `T`."

And this is what's going to enable us to give types to expressions that contain variables.  So, coming back to our rule for variables, it's now pretty easy: a variable has a certain type as long as the type environment binds it to that type.

```
(x, T) in gamma
---------------
gamma |- x :: T
```

So, now that `gamma` is part of our typing relation, we need to go back and modify the other rules to also include `gamma`.  So here's the new set of rules:


```
(x, T) in gamma
---------------
gamma |- x :: T


-----------------         ------------------
gamma |- n :: Int         gamma |- b :: Bool


gamma |- e1 :: Int    gamma |- e2 :: Int
----------------------------------------
         gamma |- e1 + e2 :: Int
```


So, to sum up, this `gamma` thing is analogous to the environments that we've been talking about for weeks, but instead of binding variables to values, it binds variables to types.  Notice that the rules for numeric literals and boolean literals don't actually use `gamma`.  That's exactly analogous to how, when you write an interpreter, you don't need to use the environment when you're interpreting a numeric literal or a boolean literal.  But you do need to use the environment when you're interpreting variable, and likewise, we ned to use `gamma`, the type environment, when we're determining the type of a variable.

Coming back to that derivation we wrote down before, it's now gotten a little more complicated.  We want to talk about the type of this expression starting in an empty type environment, just like usually when we evaluate expressions we want to determine their value starting from an empty environment.  So our derivation would look like this:

```
                      --------------  --------------
                      [] |- 4 :: Int  [] |- 5 :: Int
--------------        ------------------------------
[] |- 3 :: Int               [] |- 4 + 5 :: Int
-----------------------------------------------
            [] |- 3 + (4 + 5) :: Int
```

But now we could actually deal with expressions that contain variables, as long as they have bindings in the type environment.  So we might have the expression `x + (4 + 5)`, for instance, and that expression is well-typed as long as `x` is bound to `Int` in the type environment.

```
                            ---------------------  ---------------------
(x,Int) in [(x,Int)]        [(x,Int)] |- 4 :: Int  [(x,Int)] |- 5 :: Int
--------------------        --------------------------------------------
[(x,Int)] |- x :: Int                 [(x,Int)] |- 4 + 5 :: Int
---------------------------------------------------------------
                 [(x,Int)] |- x + (4 + 5) :: Int
```

So I would read the judgment here as: "In the type environment that binds `x` to `Int`, `x + (4 + 5)` has type `Int`.


Okay! So far we've dealt with numbers, booleans, variables, and addition expressions.  All that's left to deal with is function definitions, function applications, and `let`-expressions.  Let's do `let`-expressions next!

What's the type of a `let`-expression?  Suppose we have

```
let x = 3 in
  let y = 4 in
    x + y
```

What should the type of this expression be?

It should be `Int`, of course.  How did we know that?

Because the body, `x + y`, has type `Int` -- in a type environment where `x` has type `Int` and `y` has type `Int`.  So that tells us what the rule should be.

```
gamma |- e1 :: T1  (x,T1):gamma |- e2 :: T2
-------------------------------------------
    gamma |- let x = e1 in e2 :: T2
```

## A tiny, terrible type inferencer

I'm itching to write some code, so let's just write a tiny, terrible type inferencer with the rules we have so far.

```
data Type = TInt
          | TBool
          | Type :=> Type
  deriving Show

data Expr = ENum Int
          | EBool Bool
          | EVar String
          | EAdd Expr Expr
          | ELet String Expr Expr
  deriving (Show, Eq)

-- A type environment maps variable names to types
type TypeEnv = [(String, Type)]

lookupVarType :: String -> TypeEnv -> Type
lookupVarType x [] = error ("unbound variable: " ++ x)
lookupVarType x ((y, t):rest) = if x == y then t else lookupVarType x rest

extendTypeEnv :: String -> Type -> TypeEnv -> TypeEnv
extendTypeEnv x t gamma = (x,t):gamma

infer :: TypeEnv -> Expr -> Type
infer _     (ENum _) = TInt
infer _     (EBool _) = TBool
infer gamma (EVar x) = lookupVarType x gamma
infer gamma (EAdd e1 e2) = case (infer gamma e1, infer gamma e2) of
    (TInt, TInt) -> TInt
    (_, _)       -> error "ill-typed expression"
infer gamma (ELet x e1 e2) = infer extGamma e2
  where extGamma = extendTypeEnv x (infer gamma e1) gamma

-- let x = 3 in
--   let y = 4 in
--     x + y
exampleWellTyped :: Expr
exampleWellTyped = ELet "x" (ENum 3) (ELet "y" (ENum 4) (EAdd (EVar "x") (EVar "y")))

-- let x = 3 in
--   let y = True in
--     x + y
exampleIllTyped :: Expr
exampleIllTyped = ELet "x" (ENum 3) (ELet "y" (EBool True) (EAdd (EVar "x") (EVar "y")))
```

Why is this type inferencer terrible? Well, it doesn't support functions yet.  No function definitions, no function calls.  And it turns out that to be able to support functions, we'll have to do something more sophisticated than what we're doing now, so we'll pick up with that next time.
