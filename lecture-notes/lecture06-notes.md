
# CSE114A lecture 6

Agenda: 

- First steps with Haskell
- Working with lists
- Writing functions with pattern matching
- Pattern guards
- Polymorphic types
- Intro to type checking and type inference
- Advice for hw1: `div` and `mod`

# First steps with Haskell

(running GHCi, essential GHCi commands (":t", ":l", ":r")) 

If you run `stack ghci` at the top level of a Stack project, Stack automatically loads up GHCi with all the library and executable components of all the packages in the project.

So, for example, for homework 1, if you run `stack ghci` in the top-level directory, then it will load in the definitions from `Hw1.hs` automatically.  Just run `stack ghci` and then at the GHCi prompt you'll be able to call functions that are defined in `Hw1.hs`.  Then, as you change things in `Hw1.hs`, run `:r`.  This is a great way to test your code as you go along.

- Evaluating expressions and inspecting types in GHCi

Functions in Haskell are usually called using prefix notation, or the function name followed by its arguments, just like weve been doing in lambda calculus. However, some functions are called using infix notation - putting the function name between its two arguments: 

```
3 + 4
```

But if you have an infix function, you can call it using prefix notation if you want; you just have to put parentheses around its name:

```
(+) 3 4
```

And if you have a prefix function, you can call it using infix notation if you want; you have to put backticks around its name.  An example of this is the `div` and `mod` functions.

```
div 100 5
```

I find that hard to read, but it's easier to read if I write it using infix notation:

```
100 `div` 5
```

Likewise with `mod`:

```
mod 10 3
```

is harder for me to read than

```
10 `mod` 3
```

# Working with lists

- The list constructors, `[]` and `:`
- Writing list literals like [1, 2, 3] or [x] or with : like 1:2:3:[] or x:[]
- Some functions that can be used on lists: `length`, `(++)`, `(==)`
  - Notice that (++) and (==) are just functions, but they look different because they are written infix by default.  If we want to use them prefix, we can, with parens.
    - It's the same with (:).  It is almost always used infix, but it can be written prefix.
- Strings are just lists!

# Functions

As our first example of a function in Haskell, let's write that function that computes triangular numbers that we did last lecture, and write it in Haskell instead of in lambda calculus.

```
tri = \n -> if n == 0 then 0 else n + tri (n-1)
```

We *could* write it like this.  It's completely legal Haskell.  However, there are a couple ways in which this is not idiomatic Haskell.


Slightly more idiomatic:

```
tri n = if n == 0 then 0 else n + tri (n-1)
```

# Writing functions with pattern matching

But what we really want is to use *pattern matching* instead of `if...then...else`.

In Haskell, we typically write a function as a sequence of equations.  Haskell will try to match the arguments against the *pattern* in each equation and will use the first one that matches.

```
tri 0 = 0
tri n = n + tri (n-1)
```

Finally, to make this really idiomatic, we should add its *type signature*.  Actually, if we don't write one Haskell will automatically infer the most general type signature for this function, which is very cool, and we can talk about that next time.  But we can also specify a type signature ourselves.

In Haskell, functions have *arrow* types.  The type `a -> b` is the type of a function that takes an argument of type `a` and returns something of type `b`.  So, let's give this function the signature `Int -> Int`.

- Pattern matching on lists with [] and :
- Patterns like (x:y:xs) that have more than one : (and the non-exhaustive pattern matching that can come with them)!

Patterns can also match against specific values. 

## Polymorphic types

We've been using functions like `(++)` on lists.  Let's write our own version of `(++)`:

```
append :: [a] -> [a] -> [a]
append []     ys = ys
append (x:xs) ys = x : xs ++ ys
```

Let's say we want to write a function `duplicateAll` that takes a list of any elements and returns a list that is twice the length of the original list, in which all of the original elements have been duplicated.

We shouldn't care what type of elements the list has.  Fortunately, it's easy to write this in Haskell.

```
-- >>> duplicateAll []
-- []
-- >>> duplicateAll [1, 2, 3]
-- [1, 1, 2, 2, 3, 3]
-- >>> duplicate
duplicateAll :: [a] -> [a]
duplicateAll []     = []
duplicateAll (x:xs) = x : x : duplicateAll xs
```

Let's write a polymorphic function that checks that the length of a list is 3, using the built-in `length` and `==` functions.

```
lengthIs3 :: [a] -> Bool
lengthIs3 xs = length xs == 3
```

If we didn't want to use the built-in functions, we could've done this:

```
lengthIs3' :: [a] -> Bool
lengthIs3' (x:y:z:[]) = True
lengthIs3' xs         = False -- catch-all pattern
```

Or this:

```
lengthIs3' :: [a] -> Bool
lengthIs3' [x, y, z] = True
lengthIs3' xs        = False -- catch-all pattern
```

# Pattern guards

Pattern matching is great, but sometimes you want to match on something extremely specific.

Pattern guards are useful when you want to match on something more specific than just what constructor something was implemented with.

```
f :: Int -> String
f n | n < 3 = "The argument was less than 3"
f 3         = "The argument was exactly 3"
f n | n > 3 = "The argument was greater than 3"
```

A pattern guard is just an expression of `Bool` type that follows a pattern, using the `|` syntax to separate the pattern from the guard.


We could also use this mechanism to write a version of `tri` that has nicer behavior if called with a negative number:

```
safeTri :: Int -> Int
safeTri n | n < 0 = error "Please don't call me with arguments less than 0 kthx"
safeTri n = tri n
``

## Intro to type checking and type inference

We've been talking about type signatures of functions, but types go much deeper than that.  In Haskell, *every expression has a type*.

Conversely, you can think of a type as a *set of expressions* that inhabit that type.

We can ask what the type of any Haskell expression is using the `:t` command in GHCi.

For example, `True` is an expression of type `Bool`:

```
ghci> :t True
Bool
```

But `Bool` is also the type of the expression `not False`:

```
ghci> :t not False
Bool
```

Or the expression `not (not (not False))`:

```
ghci> :t not (not (not False))
Bool
```

How do you suppose GHCi was able to determine that all these expressions have the type `Bool`?

Well, you can probably guess that they all evaluate to `True`, and you'd be correct:

```
ghci> not False
True
ghci> not (not (not False))
True
```

So someone might plausibly imagine that what the `:t` command does, whenever you give it an expression, is first evaluate the expression to a value, and then just print out what the type of that value is, perhaps using some baked-in knowledge that `True` has the type `Bool` and `False` has the type `Bool`.  But that is *not* what happens when we use `:t`?

Why isn't that what happens?  For one thing, expressions might take a very long time to evaluate.  Then, it would be really inefficient to evaluate them if all we want to know is their type.

In fact, you could have an infinite expression that never gets done evaluating.  Let's write one:

```
infiniteList :: a -> [a]
infiniteList x = x : infiniteList x
```

What does this function do?

Then, if we reload our file and we evaluate the expression, say, `infiniteList "sprinkles"`:

```
ghci> infiniteList "sprinkles"
...infinite list...
```

...then we get an infinite list of my cat's name.  But if we use `:t` to just ask what the *type* of the expression `infiniteList "sprinkles"` is:

```
ghci> infiniteList "sprinkles"
[String]
```

...then it returns right away and tells us that this expression is a list of `String`s.  So, clearly the `:t` command couldn't have evaluated the infinite list.  What is it doing?

What it's doing is *not* evaluation, but *type checking*.  Type checking is a *static analysis*, which means it can be done *without* running the code!  All Haskell programs are type-checked *before* they are run.

So, how was GHCi able to determine that the type of `infiniteList "sprinkles"` was `[String]`?  Any ideas?

Well, it knows that `"sprinkles"` is a `String`, because anything we write in double quotes is a string literal.

And it knows that the type of `infiniteList` is `a -> [a]`.

1. We're passing `infiniteList` an argument of type `String` (we know this because `"sprinkles"` is a string literal) 
2. `infiniteList` is a polymorphic function that, for all `a`, given an argument of type `a`, returns something of type `[a]` (we know this from the type signature on `infiniteList`)
3. Whenever a function `f` of type `t1 -> t2` is applied to an argument `x` of type `t1`, the resulting expression has type `t2` (this is a built-in typing rule)

Putting all those facts together, GHCi is able to do some constraint solving and conclude

So an interesting question to ask now is: what if `infiniteList` didn't have a type signature?  Then what?  Let's get rid of its type signature.

But `:t` still says that `infiniteList "sprinkles"` has type `[String]`, even when we didn't provide a type signature!  How did it know?  How was it able to figure that out?

Let's think about what `infiniteList` does:

```
infiniteList x = x : infiniteList x
```

So, `infiniteList` calls `(:)`.  What's the type of `(:)`?

```
ghci> :t (:)
a -> [a] -> [a]
```

(Note that I have to put the parentheses around it here, because it's an infix function.)

So, `(:)` has type `a -> [a] -> [a]`.  What does the type `a -> [a] -> [a]` mean?  It means that `(:)` takes two arguments: the first one is an element of any type `a`, and the second one is a list of things of that type `a`, whatever `a` may be.  And `(:)` returns a list of things of type `a` as well.

This type shouldn't be too surprising, because we know what `(:)` does: it puts a list *element* together with a *list*, and it produces a new list that 

Because it already knows the type of `(:)`, GHCi is able to *infer* that `infiniteList` has the type `a -> [a]`.  It does that by using that same built-in typing rule for function applications that I mentioned before: the rule that says that whenever a function `f` of type `t1 -> t2` is applied to an argument `x` of type `t1`, the resulting expression has type `t2`.

GHCi uses this fact to figure out that `infiniteList` has type `a -> [a]`, and it does this all *statically*, without any run-time information about what arguments it's called with.  This is type inference, and it's one of the major PL innovations of the last 50 years.

And by the end of the quarter, you'll know enough to be able to write your own implementation of a type inference algorithm.

Let's go back to our `not False` eaxmple:

```
ghci> :t not False
Bool
```

We can now understand how GHCi's type checker knows that `not False` has type `Bool`.  Since `False` is a Boolean literal, the type checker knows that `False` has type `Bool`.  And what's the type of `not`?

(You can ask GHCi.  I'll wait.)

Yeah, so the type of `not` is `Bool -> Bool`, and the type of `False` is `Bool`.  So the expression `not False` happens to be an application of a function of type `Bool -> Bool` to an argument of type `Bool`, therefore the entire expression has type `Bool`.

## Advice for hw1: `div` and `mod`

On homework 1, you'll need to do a problem where you have a number and you have to return a list of its digits.  This is hard unless you know the trick.

You can use any built-in functions that operate on numbers, and in particular, you can use `div` and `mod`.  So let's see how that works.

Like we said at the beginning, I think it's more readable to write `div` and `mod` infix rather than prefix, so let's keep doing that.

A good way to get the last digit of a number is to call `mod 10` on it:

```
ghci> 12345 `mod` 10
5
```

And a good way to get *all but the last* digit is to call `div 10` on it:

```
ghci> 12345 `div` 10
1234
```

So we could write a couple of tiny, convenient helpers:

```
lastDigit :: Integer -> Integer
lastDigit n = n `mod` 10

allButLastDigit :: Integer -> Integer
allButLastDigit n = n `div` 10
```

With those, you can now write a recursive function that turns a number into a list of its digits.
