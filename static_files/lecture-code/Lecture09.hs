-- Welcome to lecture 9!

{--
Agenda:

- More about pattern guards
- Intro to types, type checking, type inference
- Polymorphic types
- Advice for hw1: `div` and `mod`

--}

{--
A pattern guard is an expression of `Bool` type that follows a pattern,
using the `|` syntax to separate the pattern from the guard.
--}

f :: Int -> String -- Read the `::` as "has type".
f n | n < 3  = "The argument was less than 3"
f 3 = "The argument was exactly 3"
f n | otherwise = "The argument was greater than 3"

{--

Every expression in Haskell has a type.

Conversely: you can think of a type as *a set of expressions
that inhabit that type*

So, e.g., the meaning of the type `Bool`
is { `True`, `False`, `not True`, `not False`, `not (not True)`, ...}
which is the (infinite!) set of expressions that inhabit it.

When you type check an expression,
you're *not* evaluating it!

Instead you're doing a static analysis.

Here's one of several rules that are part of Haskell's type system:
Whenever you have a function `f` of type `t1 -> t2`
applied to an argument `a` of type `t1`, 
that overall application expression `f a` has `t2`
--}

-- This signature says that `g` will take an an argument of any type `a`
-- and return something of type `[a]` (that is, a list where the elements are of type `a`)
g :: a -> [a]
g x = x : g x

-- Quiz question 1: what do you think `g` does?
-- Hint: it uses `(:)`, which we talked about last time. 

-- Quiz question 2: what's the type of `not`?

appendLists :: [a] -> [a] -> [a]
appendLists []      ys = ys -- Here `ys` is a pattern that matches anything
appendLists (x:xs)  ys = x : xs `appendLists` ys