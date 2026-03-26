# CSE114A lecture 10

Agenda:

- Intro to higher-order functions
- Some useful higher-order functions to know
  - filter
  - map
- More higher-order functions to know
  - foldr
  - foldl (if time)

## Higher-order functions

Higher-order functions are functions that either
 - take functions as arguments
 - return functions as return values
 - or both
 
We've actually already been working with higher-order functions from day one in this course.  For instance, in lambda calculus, everything is a function, and so of course all functions take functions as arguments, because they couldn't do otherwise. And all functions return functions, because they couldn't do otherwise.

But usually, when we speak of higher-order functions, we're talking about when we have a choice in the matter.

We encountered a higher-order function last week, on a quiz question.

```
-- Find the first element in a list that satisfies a given predicate
find :: (a -> Bool) -> [a] -> Maybe a
find predicate [] = Nothing
find predicate (x:xs) = if predicate x then Just x else find predicate xs
```

`find` is a higher-order function because it takes a function as its first argument.  If we didn't have `find`, then we would need to write a different function for every predicate we wanted, and our code would be really repetitive and verbose.

And that's in a nutshell why higher-order functions are useful.  You might have noticed that a lot of the code we've written in 114A has been repetitive -- we see the same patterns over and over.  Higher-order functions let us express those patterns.

## filter

Let's see an example of that.  Let's say I want to write a function that takes a list of `Int`s and filters out all the odd ones.

We can do that easily with tools we've already learned.

```
evensOnly :: [Int] -> [Int]
evensOnly []     = []
evensOnly (x:xs) | x `mod` 2 == 0 = x : evensOnly xs
                 | otherwise      = evensOnly xs
```

But then let's say I need to take a list of `String`s and only keep the strings of length 4.

```
fourOnly :: [String] -> [String]
fourOnly []     = []
fourOnly (x:xs) | length x == 4 = x : fourOnly xs
                | otherwise     = fourOnly xs
```

But look how similar these functions are.  What are the only differences?

- the type of list elements
- the guard expression

So we want to write a function that generalizes both those things.

To generalize the type of list elements, we need to make this a polymorphic function.  Instead of something specific like `Int` or `String`, we'll use a type variable `a`.

To generalize the guard expression, we'll pass in a function that takes something of type `a` and returns `Bool`.

And now we can write the `filter` function.  In the base case, we don't even use the function we passed in.  In the case where we have a non-empty list, what do we do?

We call `f` on `x`, and since `f` is a function of type `a -> Bool`, and `x` has type `a`, then `f x` will have type `Bool`.  So we can use it as a guard, and if the guard expression is `True`, we include `x` in the list.  Otherwise, we don't.

```
filter :: (a -> Bool) -> [a] -> [a]
filter _ []     = []
filter f (x:xs) | f x       = x : filter f xs
                | otherwise = filter f xs
```
-- Tak
And now `evensOnly` and `fourOnly` are one-liners that can be written in terms of `filter`:

```
evensOnly' = filter (\x -> x `mod` 2 == 0)
fourOnly' = filter (\x -> length x == 4)
```

By the way, this illustrates one of the coolest and most interesting things about Haskell.  How many arguments does `filter` take?

It takes two arguments, a function of type `a -> Bool` and a list with elements of type `a`.  But when I defined `evensOnly'` and `fourOnly'`, I only called `filter` with one argument.

In Haskell, this is fine to do!  You can always *partially apply* functions.  If I apply `filter` to just one argument, then what I get back is *another function* that's waiting for the next argument.  And in the case of `evensOnly'` and `fourOnly'`, that's precisely what I wanted.  I wanted to get back a function.

Another way to think about this is that in Haskell, just like in lambda calculus, all functions are really one-argument functions.  A so-called two-argument function is really just a function that takes one argument and returns a function that takes the second argument and then returns the return value.

## map

Let's look at another higher-order function, a famous one, `map`.  And let's again approach it from the perspective of having multiple one-off functions that we'd like to generalize.

```
-- Take a list of `Int`s and square all of them
squares :: [Int] -> [Int]
squares []     = []
squares (x:xs) = x*x : squares xs

-- Take a list of `Int`s and produce a list of `Bool`s that
-- tell us whether the corresponding `Int` is divisible by 3.
divisibleBy3 :: [Int] -> [Bool]
divisibleBy3 []     = []
divisibleBy3 (x:xs) = (x `mod` 3 == 0) : divisibleBy3 xs

-- Take a list of predicates, apply them all to the string "rainbow", and return a list of the results
applyAllPreds :: [String -> Bool] -> [Bool]
applyAllPreds []     = []
applyAllPreds (f:fs) = f "rainbow" : applyAllPreds fs 
```

```
ghci> applyAllPreds [\s -> length s == 7, \s -> s == "sprinkles"]
[True,False]
```

These are all essentially the same function. We can generalize this pattern with the `map` function. `map` takes a function and a list, and applies the function to every element in the list, resulting in a new list.

```
map :: (a -> b) -> [a] -> [b]
map _ []     = []
map f (x:xs) = f x : map f xs
```

## foldr

So far we've been talking about higher-order functions that take and return *lists*.  But what about boiling down a list to just one value?

```
-- Take a list of `Int`s and return their sum
sum :: [Int] -> Int
sum []     = 0
sum (x:xs) = x + sum xs

-- Take a list of strings and concatenate them
concat :: [String] -> String
concat []     = ""
concat (x:xs) = x ++ concat xs

-- Take a list of lists and return their total length
lengthAll :: [[a]] -> Int
lengthAll []     = 0
lengthAll (x:xs) = length x + lengthAll xs
```

What's the same about all these?

- They all take a list, but the lists are of different types.
- They all have a base case, where there's some kind of base value we want to return.  In the case of `sum` and `lengthAll` it's `0`; in the case of `concat` it's the empty string.
- They all make a recursive call on the tail of the list.
- They all combine the result of the recursive call with something, but they all do it in different ways.  `lengthAll` adds `length x` to the result of the recursive call.  `sum` adds the head of the list `x` to the result of the recursive call.  And `concat` concatenates `x` with the result of the recursive call by calling the `(++)` function.

So it seems like to generalize these into a pattern, we need

- a polymorphic list argument, so, something of type `[a]`
- something to return in the base case, which might not be the same type as the elements of the list.  So we've better give it another type, `b`.  Since this thing of type `b` is what gets returned in the base case, it had better be the function's return type also.
- a function that does the combining.  This function needs to take two arguments: one of them is the first element of the list, so it has type `a`, and one of them is the result of a recursive call, so it has type `b`.  And what we should get back is something of type `b`, because that's what we need to return.

And that leaves us with the type of the legendary `foldr` function!

```
foldr :: (a -> b -> b) -> b -> [a] -> b
foldr f b []     = b
foldr f b (x:xs) = f x (foldr f b xs)
```

Let's see if we can rewrite all of `sum`, `concat`, and `lengthAll` as one-liners using `foldr`.  I didn't practice this part!
