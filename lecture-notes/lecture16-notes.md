# CSE114A lecture 16

Agenda: 

- More typing rules
- Unification

## More typing rules

OK, so we left off last time having written down a bunch of typing rules for a mini-version of the Nano language.  As a refresher, here's the grammar of expressions in our language:

```
e ::= n | b | x | e1 + e2 | \x -> e | e1 e2 | let x = e1 in e2
```

And for types, we have two base types and we have function types.

```
T ::= Int | Bool | T1 -> T2
```

And here are the typing rules we came up with so far -- for numeric literals, Boolean literals, addition expressions, variables, and `let`-expressions.  Let's give them names too.

```
-----------------[T-Int]  ------------------[T-Bool]
gamma |- n :: Int         gamma |- b :: Bool


gamma |- e1 :: Int    gamma |- e2 :: Int
----------------------------------------[T-Add]
         gamma |- e1 + e2 :: Int
		 
(x, T) in gamma
---------------[T-Var]
gamma |- x :: T

gamma |- e1 :: T1  (x,T1):gamma |- e2 :: T2
-------------------------------------------[T-Let]
    gamma |- let x = e1 in e2 :: T2
```

So that's five of the seven language forms handled.

What about function definitions and function applications?

Say we have a function, like

```
\x -> x + 3
```

What is its type? Well, we already know that if it's well-typed then it's going to have some kind of arrow type.  So the conclusion of our rule should be this:

```
            ???
----------------------------
gamma |- \x -> e :: T1 -> T2
```

But what about above the line?  What should we have for a premise?

For our example, `\x -> x + 3`, then whether or not that's well-typed depends on what the type is of `x` in the type environment.  If `x` is of type `Int` in the type environment, great, but if `x` is of type `Bool`, or if it's of function type, then the function is ill-typed, because `x` is part of this addition expression.

So in the premise of this rule, we need to check the body of our function in an extended type environment

```
  (x,T1):gamma |- e :: T2
----------------------------[T-Lam]
gamma |- \x -> e :: T1 -> T2
```

And then, finally, function application, my favorite typing rule.  If we're applying a function to an argument, then the function had better be of arrow type, and the argument better match the function's argument type.  And what you get back had better be the function's return type!

```
gamma |- e1 :: T1 -> T2   gamma |- e2 :: T1
-------------------------------------------[T-App]
           gamma |- e1 e2 :: T2
```

So now we finally have the full set of typing rules for mini-Nano.

We can now precisely say what it means for an expression to be "well-typed" or "ill-typed".  An expression `e` is *well-typed* in a type environment `gamma` if we can write down a derivation for `gamma |- e :: T` for some type `T`, and if we can't do that, the expression is *ill-typed*.

A type inference algorithm tries to automatically determine whether an expression is well-typed, and if so, what its type is.  Last time, we implemented an tiny, terrible `infer` function that used the typing rules that we had written down to infer the types of expressions.  The basic idea of `infer` for an expression `e` was:

- Find a typing rule that applies to `e` 
- If the rule has premises, recursively call `infer` to obtain the types of sub-
expressions
- Combine the types of sub-expressions according to the conclusion of the rule
- If we arrive at a situation where no rule applies, report a type error

It's tempting to go back and try to implement cases in `infer` for the two additional rules we just wrote down.  Unfortunately, this is not as straightforward as one might hope.

If we took our code from last lecture, extend our AST with a constructor for functions, and then tried to write the case of `infer` for functions...

```
infer gamma (ELam x e) = argType :=> resType
  where gamma' = extendTypeEnv x argType gamma
        resType = infer gamma' e
        argType = undefined -- what do we put here? :(
```

We don't know what to put for the type that we're putting in the type environment!  What do we do?

What would we do if we were doing a derivation on paper?  Let's do a derivation for the program `\x -> x + 1`.

```
        ---------------------------------------------------
                        [] |- \x -> x + 1 :: ???
```

(work out this example)


``` 
           (x,Int) in [(x, Int)]
           ---------------------    ---------------------
           [(x,Int)] |- x :: Int    [(x,Int)] |- 1 :: Int
           ----------------------------------------------
                     [(x,Int)] |- x + 1 :: Int
        ---------------------------------------------------
                  [] |- \x -> x + 1 :: Int -> Int
```

So, to do this, we had to essentially put *placeholders* in the typing derivation anytime we didn't know what to put for the type of something.  Then, any time a rule imposed a constraint on a type, we used the rule to figure out how to fill in our placeholders, until finally all placeholders had been filled in.  (If we had run into a situation where there was an unsatisfiable constraint, like something had to be an `Int` but it also had to be a `Bool`, then that would mean the expression was ill-typed.)

We're going to have to do this in our type inferencer also, and the way we are going to implement it is using a mechanism called *unification*.  So let's explain what that is and then we'll come back to this example.

## Unification

First, we need some terminology.  Those placeholders that I mentioned are called *type variables*, and we'll just use letters like `a`, `b`, `c`, and so on to represent them.  (You've seen type variables before -- in the types of polymorphic functions in Haskell -- more about that later.)  So we're going to need to extend our vocabulary of types to include type variables.  Anywhere that base types like `Int` and `Bool` can occur, type variables can now occur too.

Next, a *type substitution* is a list of pairs associating type variables with types.

For example, `[(a, Int), (b, c -> c)]` is a substitution.  Notice that the types associated with each type variable can contain type variables themselves.  So `c -> c` is a function type where both the argument and result types are the type variable `c`.

*Applying* a substitution to a type means replacing all the type variables in a type with whatever the subtitution maps them to.  For example, if you apply the substitution `[(a, Int), (b, c -> c)]` to the type `a -> a`, you'd get `Int -> Int`.

If there are no type variables in the type that the substitution is being applied to, then it will stay the same.

*Unification*, for the purposes of this class, is finding a substitution that makes two types the same when it is applied to both of them.  And we call such a substitution a *unifier* for those types.

By the way, unification is a general concept that shows up all over computer science -- it's good for more than just type inference!  You might have even encountered it in other courses before.  But here we're using it for the type inference.

For example:

- If I have the types `a -> Int` and `Bool -> b`, then a unifier for them is `[(a, Bool), (b, Int)]`, because applying this substitution to both types would make them both into `Bool -> Int`.  Notice that I couldn't say `[(Bool, a), (Int, b)]`, because that's not a substitution -- a substitution only maps type variables to types, and `Bool` and `Int` aren't type variables, so they can't go on the left-hand sides of these pairs.

- If the types I have are the same to begin with, then an empty substitution will unify them.

- If I have two different type variables, say, `a` and `b`, then `[(a, b)]` and `[(b, a)]` are unifiers for them.

- If I have a type variable and another type, say, `a` and `Int -> Bool`, then [(a, Int -> Bool)]` is a unifier for them.  **Except...**

- Suppose I have `a` and `Int -> a`.  Is there a way to unify those?

Would `[(a, Int -> a)]` work as a unifier?  No!  Because, remember, a unifier for two types is a substitution that makes two types the same when applied to both of them.  If we applied this substitution to `a` we'd get `Int -> a`, and if we applied it to `Int -> a`, we'd get `Int -> Int -> a`.  So that won't work.

In fact, in general, you cannot unify a variable with any type that contains free occurrences of that variable.  This is known as the "occurs check".  If you've started on part 1 of homework 5, this is why the homework has you implement a function that finds the free variables in a type, because you'll use that function later on in part 2 to handle the occurs check when you implement unification.

Let's do a bunch of quick examples.  I'll write down a pair of types, and you tell me whether they unify.

`a`        and `Int`        : `[(a, Int)]`
`a -> a`   and `Int -> Int` : `[(a, Int)]`
`a`        and `Int -> Int` : `[(a, Int -> Int)]`
`a`        and `b -> c`     : `[(a, b -> c)]`
`a -> Int` and `Int -> b`   : `[(a, Int), (b, Int)]`
`Int`      and `Int`        : `[]`
`a`        and `a`          : `[]`
`a`        and `b`          : `[(a, b)]`
`Int`      and `Int -> Int` : cannot unify!
`Int`      and `a -> a`     : cannot unify!
`a`        and `a -> a`     : cannot unify!

So now let's see a small example of the role that unification is going to play in type inference.  Let's try inferring the type of `\x -> x + 1`, step by step, starting in an empty type environment.

1. First, the rule that fits the expression is the T-Lam rule.
2. So now we need to look at the premise of T-Lam.  For the type of x, we pick a fresh type variable as a placeholder (call it `a`); and now we need to infer the type
of the body `x + 1` in the type environment `[(x,a)]`.  So the rule that fits the expression is the T-Add rule.
3. For the first premise of T-Add, we need to infer the type of `x` in `[(x,a)]`. We use the T-Var rule, which tells us to look up `x`'s type in the type environment, and there we go: the type of `x` is the new type variable we introduced, `a`.
4. Now, the the T-Add rule imposes a constraint: the first subexpression must be of type `Int`.  So we unify `a` and `Int` and update the current substitution to `[(a,Int)]`.
5. Next, we apply the current substitution `[(a,Int)]` *to the type environment* `[(x,a)]` to get `[(x,Int)]`. Now we infer the type of 1 in `[(x,Int)]`.  We use the T-Num rule and get `Int` as the type of 1, of course.
6. Now the T-Add rule imposes another constraint: the second subexpression must be of type `Int`.  So we unify `Int` and `Int`.  They already unify in the current substitution, so we don't change the substitution.
7. Now that the premises of T-Add are satisfied, we can return `Int` as the inferred type of `x + 1`.
8. And now that the premise of T-Lam is satisfied, we can return `Int -> Int` as the inferred type of the whole expression.

   TypeEnv   Expression   Step           Substitution         Inferred type

1. []        \x -> x + 1  T-Lam          []
2. [(x,a)]   x + 1        T-Add
3.           x            T-Var                               a
4.           x + 1        unify a Int    [(a,Int)]
5. [(x,Int)] 1            T-Num                               Int
6.           x + 1        unify Int Int
7.           x + 1                                            Int
8. []        \x -> x + 1                                      Int -> Int



