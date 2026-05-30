-- Welcome to lecture 24!

{--

Agenda:

- More discussion of unification
- Aspirationally: return to our tiny terrible type inferencer
  and make it better? maybe?
- Midterm 2 recap

--}

{--

Unification recap

A type substitution (or substitution for short) is a list of pairs
associating type variables with types

[(a, Int), (b, c -> c)]

Applying a substitution means replacing all the type variables
in a type with whatever the substitution maps them to

Applying the above substitution to the type `a -> b`
would give us `Int -> c -> c` which is just 
syntactic sugar for `Int -> (c -> c)`
but *not* for `(Int -> c) -> c`

Unification is the process of finding a substitution that makes
two types the same when it's applied to them both


These types             can be unified by:
-----------             ------------------
Int, Int                []
a, Int                  [(a, Int)]
a, Int                  [(a, Int), (b, Bool)]
a -> a, Int             nope!
a -> a, Int -> Int      [(a, Int)]
a, Int -> Int           [(a, Int -> Int)]
a -> Int, Int -> b      [(a, Int), (b, Int)]
a, a                    []
a, b                    [(a, b)] or [(b, a)]
a, b -> c               [(a, b -> c)]
a -> Int, b -> Int      [(a, b)] or [(b, a)]
a -> b, Int -> Bool     [(a, Int), (b, Bool)]
a -> Int, b -> Bool     nope!
a -> a, Int -> Bool     nope!
a, a -> a               nope! ("occurs check")
a, Int -> a             nope! ("occurs check")

In general, you can't unify a type variable with any larger type that contains
free occurrences of that type variable.  (This is known as the "occurs check".)

--}

{--
Let's infer the type of \x -> x + 3,
step by step,
starting from an empty type environment.

Type env: []
Expression: \x -> x + 3
Use T-Lam!

Type env: [(x, a)]
Expression: x + 3
Use T-Add!

Expression: x
Use T-Var
Inferred type for x: a

Expression: 3
Use T-Int
Inferred type for 3: Int

unify a with Int using the substitution [(a, Int)]

Apply the updated substitution
to the type environment [(x, a)],
giving us [(x, Int)].

Inferred type for x + 3: Int

Inferred type for \x -> x + 3: Int -> Int

-------------

Quiz question 1:

Write down a substitution that is a unifier for

a -> c
b -> Int -> a

This works:
[(a, b), (c, Int -> b)]
[(b, a), (c, Int -> a)]

This doesn't:
[(a, b -> Int), (c, a)]

[(b -> Int, a)] -- Can't do this because a substitution maps type variables to types

--}