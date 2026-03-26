# CSE114A lecture 17

Agenda: 

- Type inference revisited
- Polymorphism

OK, friends.  So, in lecture 15 we began talking about type inference, and we wrote a tiny, terrible type inferencer for a tiny language. Then in lecture 16, we added some more stuff to our language, but then we arrived at a situation where the simple approach we were taking in our tiny, terrible type inferencer would no longer work.

In particular, the reason that approach will no longer work is because there are times when our typing rules seem to require us to *guess* the type of something.  When that happens, we need to put some sort of placeholder in that spot, in the form of a type variable.  Then, as we go further along, our typing rules impose constraints, and we have to use the typing rules to *update* those guesses whenever we learned new information from a constraint, and we do that by means of *unification*, which we talked about last time.

If you took the advice I gave on Zulip, then you're already done with parts 1 and 2 of hw5, in particular part 2 of hw5, which is about implementing unification.  So if you're done with that then you're ready to do part 3 of hw5, which is about implementing type inference with the help of unification.  (I dropped a bunch of part 3 hints on Zulip.  Some of you are already doing part 3, and a handful of you are even done with it already, in which case you're ahead of the game.  If you haven't done it yet, then plan to devote some time to it in the next new days.  You *are* still allowed to use your late days for hw5 if you have late days left, but remember, our final exam is next Tuesday afternoon.  So really, for most people it's a better use of your time to turn in the assignment by the due date on Saturday (even if it's not 100% done), and then you'll have the time between then and Tuesday available for studying for the final.  At least, that's what I recommend.  But you're an adult and I'm not going to tell you how to spend your time.

## Type inference revisited

OK!  So let's come back to our tiny terrible type inferencer and make it less terrible.

What I'm demonstrating today is kind of a mini-version of what hw5 part 3 will ask you to do.

There's a whole bunch of infrastructure that hw5 provides for you, which I have the equivalent of here in a module called `Lecture17Provided`.  (One new thing compared to lecture 15 is that we now have type *variables*.)

We're also going to be relying on some things that you will have already done in hw5 parts 1 and 2, and those are in the `Lecture17HW` module.

As we talked about last time, a *type substitution*  unification is about finding a *type substitution* that makes two types the same.  The way that the type substitution is going to represented in our code is as part of a thing called an `InferState`.

(Explain this code line by line, comparing to the old `infer` from lecture 14)

```
-- A less terrible type inferencer
infer :: InferState -> TypeEnv -> Expr -> (InferState, Type)
infer st _ (EInt _) = (st, TInt)
infer st _ (EBool _) = (st, TBool)
infer st gamma (EVar x) = (st, lookupVarType x gamma)
-- EAdd case: recursively infer types of operands
-- and enforce constraint that they are both `Int`s
infer st tEnv (EAdd e1 e2) = (st4, TInt)
  where (st1, t1) = infer st tEnv e1        -- 1. infer type of e1
        st2       = unify st1 t1 TInt       -- 2. constraint: t1 is Int
        tEnv'     = apply (stSub st2) tEnv  -- 3. apply subst to type environment
        (st3, t2) = infer st2 tEnv' e2      -- 4. infer e2 type in new ctx
        st4       = unify st3 t2 TInt       -- 5. constraint: t2 is Int
```

For the `EAdd` case, you might wonder why all this is really necessary.  It almost seems like overkill.

So let's think about ways in which things could go wrong if we left out any of these steps.  So here are some programs that we want to have be ill-typed.

`1 2 + 3` -- first operand is ill-typed -- would fail in step 1
`1 + 2 3` -- second operand is ill-typed -- would fail in step 4
`(\x -> x) + 1` -- both sides are well-typed, but first operand is not an `Int` -- would fail in step 2
`1 + (\x -> x)` -- both sides are well-typed, but second operand is not an `Int` -- would fail in step 5
`\x -> x + x 5` -- both sides are well-typed by themselves, but can't be well-typed at the same time -- this is why we need `apply` in step 3!


But why do we need to do all this stuff at all?  Why wasn't the old `EAdd` case enough?  It looked like this:

```
infer gamma (EAdd e1 e2) = case (infer gamma e1, infer gamma e2) of
    (TInt, TInt) -> TInt
    (_, _)       -> error "ill-typed expression"
```

Why isn't that good enough?


```
let f = \x -> 3 + x in
  f False
```

Here, the expression `3 + x` imposes a constraint on the type of `x`: it means that `x` has to have the type `Int`.  But the expression `f False` imposes a constraint that `x` has to have the type `Bool`.  These two things can't both be true.

TODO: spell this out more

OK, let's write the `ELam` case.  If you recall from lecture last time, we attempted to write down an `ELam` case in our type inferencer based on the typing rule.  And it looked like this:

```
infer gamma (ELam x e) = argType :=> resType
  where gamma' = extendTypeEnv x argType gamma
        resType = infer gamma' e
        argType = undefined -- what do we put here? :(
```

But we didn't know what to put for the argument type.  But now that we have type variables, we can actually solve this problem!

```
infer st gamma (ELam x e) = (st2, finalArgType :=> resType)
  where argType        = freshTV (stCnt st)
        st1            = InferState (stSub st) (stCnt st + 1)
        gamma1         = extendTypeEnv x argType gamma
        (st2, resType) = infer st1 gamma1 e
        finalArgType   = apply (stSub st2) argType
```

(Leave out the `apply` line the first time!)

```
ghci> snd (infer initInferState [] (ELam "x" (EAdd (EVar "x") (EInt 1))))
TVar "a0" :=> TInt
```

Let's write a tiny test framework like we did before for our interpreter.

```
data Test = Test Expr Type

tests :: [Test]
tests = [Test (EInt 7) TInt,
         Test (EBool False) TBool,
         Test (EAdd (EInt 7) (EInt 4)) TInt,
         -- \x -> x + 1
         Test (ELam "x" (EAdd (EVar "x") (EInt 1))) (TInt :=> TInt),
         -- 3 + (4 + 5)
         Test (EAdd (EInt 3) (EAdd (EInt 4) (EInt 5))) TInt
         ]

runTests :: [Bool]
runTests = map (\(Test expr result) -> snd (infer initInferState [] expr) == result) tests
```

TODO: discuss polymorphism

## Polymorphism

Go through slides 55-57 from https://ucsc-cse-114a.github.io/fall24/static_files/presentations/types.pdf

```
infer :: InferState -> TypeEnv -> Expr -> (InferState, Type)
infer st gamma (EInt _) = (st, TInt)
infer st gamma (EBool _) = (st, TBool)
-- This will work for now, but it isn't the final answer
infer st gamma (EVar x) = (st, lookupVarType x gamma)
-- For the EAdd case,
-- recursively infer the types of our operands, e1 and e2,
-- and enforce the constraint that they're both `Int`s
infer st gamma (EAdd e1 e2) = (st4, TInt)
  where (st1, t1) = infer st gamma e1 -- 1. infer type of e1
        st2       = unify st1 t1 TInt -- 2. enforce constraint that e1 is an Int
        gamma'    = apply (stSub st2) gamma -- apply substitution to type environment
        (st3, t2) = infer st2 gamma' e2 -- 3. infer type of e2 (in updated type environment!)
        st4       = unify st3 t2 TInt -- 4. enforce constraint that e2 is an Int

infer st gamma (ELam x e) = (st2, argType' :=> resType)
  where argType = freshTV (stCnt st) -- Create a new fresh type variable
        st1 = InferState (stSub st) (stCnt st + 1) -- Keep track of the fact that I used a type variable
        gamma' = extendTypeEnv x argType gamma
        (st2, resType) = infer st1 gamma' e
        -- Propagate what we learned from inferring the type of e
        -- back to the argument type!
        argType' = apply (stSub st2) argType

{-

How could addition expressions be ill-typed,
and how does type inference catch those ill-typed expressions?

`\x -> x + x 5` -- what about this? How do we make this ill-typed?
step 1 would tell us that x is some kind of type variable (gamma = [("x", a0)])
step 2 would tell us that that type variable must be Int (subst = [("a0", TInt)])
We need to *apply* the substituion to the type environment gamma,
which would give us gamma = [("x", TInt)].

`\x -> x 5 + x` -- something similar would happen.

The AST here would be `EAdd (EApp (EInt 1) (EInt 2)) (EInt 3)`
`1 2 + 3` -- would fail to type check in step 1

The AST here would be `EAdd (EInt 1) (EApp (EInt 2) (EInt 3))`
`1 + 2 3` -- would fail to type check in step 3

The AST here would be `EAdd (ELam "x" (Var "x")) (EInt 1)`
`(\x -> x) + 1`
Both sides of the addition are well-typed, but first operand isn't an Int,
so this would fail to unify in step 2

`1 + (\x -> x)`
Same deal -- so this would fail to unify in step 4

-}

-- Tiny test framework

data Test = Test Expr Type

tests :: [Test]
tests = [Test (EInt 7) TInt,
         Test (EBool False) TBool,
         Test (EAdd (EInt 7) (EInt 4)) TInt,
         --Test (EAdd (EInt 7) (EBool False)) TInt, -- this one's ill-typed and should raise an exception
         Test (ELam "x" (EAdd (EVar "x") (EInt 1))) (TInt :=> TInt)]

-- Have to use `!` here to make sure that the `InferState` actually gets evaluated
runTests :: [Bool]
runTests = map (\(Test expr result) -> (let (!_, r) = infer initInferState [] expr in r) == result) tests

quiz :: Int -> Int
quiz = let f = \x -> x in -- f should be of type `forall a . a -> a`
         let y = f 5 in -- we're *instantiating* `a` with `Int`
           f (\z -> z + y) -- we're *instantiating* `a` with `Int -> Int`

-- How to make sure that programs like `quiz` are considered well-typed 
-- in our type inferencer?

-- When we put a type into the type environment for a `let`-bound variable (like `f`), 
-- we need to *generalize* that type first. (This happens in the `ELet` case of `infer`).

-- When we *use* a type *from* the type environment,
-- we need to *instantiate it* with a fresh type variable!
-- (Use the provided `instantiate` function in the `EVar` case of `infer`.)
```
