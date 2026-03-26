# CSE114A lecture 8

Agenda:

- Tail recursion in Haskell
  - `where` clauses
- Tuples (and pattern-matching on them)
- An interpreter for our little `ArithExpr` language
- Adding features to our little language

Let's write a Haskell function that computes the length of a list.  (Practically speaking, there's no need to write it ourselves because we can use the `length` function that's part of the Prelude, Haskell's standard library.  But for the moment, let's pretend we did need to write it.)

So, we want to take a list of anything, and return its length.  What should the type signature of our function be?

```
len :: [a] -> Int
len [] = 0
len (x:xs) = len xs + 1
```

Let's try evaluating a few calls to `len` with differently-sized lists.

```
ghci> len [1..10]
10
ghci> len [1..100]
100
ghci> len [1..100_000]
100000
ghci> len [1..1_000_000]
1000000
```

A cool thing we can do in GHCi is to enable an option that will display some stats after evaluating each expression, about its running time and how much memory it allocated.  We do this with the command `:set +s` (the "s" in "+s") is short for "stats".  So let's do that.

Important caveat: GHCi is an interpreter. If we wanted statistics on the running time of compiled programs, as opposed to interpreted ones, we would need to compile them with GHC and run and measure them.  So these numbers should *not* be considered indicative of the performance of compiled code.

Anyway, let's try evaluating some calls to `len` with bigger lists.

```
ghci> :set +s
ghci> len [1..1_000_000]
1000000
(0.45 secs, 234,578,888 bytes)
ghci> len [1..1_000_000]
1000000
(0.52 secs, 234,578,888 bytes)
ghci> len [1..1_000_000]
1000000
(0.49 secs, 234,578,888 bytes)
ghci> len [1..10_000_000]
10000000
(4.29 secs, 2,345,006,272 bytes)
ghci> len [1..100_000_000]
*** Exception: stack overflow
```

We got a stack overflow.  Let's think about why this would have happened.

len :: [a] -> Int
len [] = 0
len (x:xs) = len xs + 1

Let's visualize how evaluation of a call to `len [1, 2, 3, 4, 5]` proceeds.  (This visualization is an oversimplification, but will hopefully give us some intuition.)

len [1, 2, 3, 4, 5]
= (len [2, 3, 4, 5]) + 1
= ((len [3, 4, 5]) + 1) + 1
= (((len [4, 5]) + 1) + 1) + 1
= ((((len [5]) + 1) + 1) + 1) + 1
= (((((len []) + 1) + 1) + 1) + 1) + 1
= ((((0 + 1) + 1) + 1) + 1) + 1
= 5

We can see that a large expression has built up on the "outside" of the recursive call.  When we hit the base case, we still have to evaluate this large expression.

Looking back at the implementation of `len`, we can see that the culprit is the "+ 1" that's hanging around on the outside of the recursive call to `len`.

In other words, the last thing that `len` does is *not* call itself.  The last thing it does is call `+`.

How can we rewrite `len` so that the *last* thing it does is call itself?  If you went to section this week, you might know the answer.

We can add an extra accumulator argument:

```
len' :: [a] -> Int -> Int
len' []     acc  = acc
len' (x:xs) acc = len' xs (acc + 1)
```

Let's visualize how a call to `len'` is evaluated:

len' [1, 2, 3, 4, 5] 0
= len' [2, 3, 4, 5] 1
= len' [3, 4, 5] 2
= len' [4, 5] 3
= len' [5] 4
= len' [] 5
= 5

This time, there's nothing waiting around on the outside of the recursive call to be evaluated after the last recursive call returns.  Instead, we use the accumulator argument to accumulate the result as we go along.

We say that `len'` is tail-recursive, which means that every recursive call to `len'` is in tail position, meaning that it's the last thing that the function does.

However, I need to confess that been lying to you a little bit.  So let's compare the performance of `len` and `len'` and maybe I'll get caught in the lie.

ghci> len [1..100_000_000]
*** Exception: stack overflow
ghci> len' [1..100_000_000] 0
*** Exception: stack overflow

Womp womp.  We still got a stack overflow.

What about smaller lists?  Does the tail-recursive version have any better performance than the non-tail-recursive one?

ghci> len [1..1_000_000]
1000000
(0.44 secs, 234,578,888 bytes)
ghci> len [1..1_000_000]
1000000
(0.43 secs, 234,578,888 bytes)
ghci> len' [1..1_000_000] 0
1000000
(0.50 secs, 225,736,144 bytes)
ghci> len' [1..1_000_000] 0
1000000
(0.48 secs, 225,736,144 bytes)

It doesn't seem like the performance of `len'` is any better than `len`.  It might even be worse?

So, what gives?

It turns out that the culprit is *laziness*.  Haskell is a lazy programming language, which means that the arguments to functions don't get evaluated immediately; they only get evaluated when absolutely necessary.

This is both good and bad.  There are a lot of situations where it's great!  For example, let's say we have a function that gets the fifth element of a list.

We could easily use a built-in function for this, but it's a useful exercise to write it, so let's write it.

How can I use pattern matching to extract the fifth element from the list?

```
fifth :: [a] -> a
fifth (_:_:_:_:x:_) = x
fifth _             = error "no fifth element"
```

ghci> fifth ["hello", "i", "am", "a", "list", "of", "strings"]
"list"
ghci> fifth ["a", "shorter", "list"]
"*** Exception: no fifth element
CallStack (from HasCallStack):
  error, called at lecture08.hs:13:23 in main:Main

OK, so `fifth` works.  Let's try calling it on some really, really huge lists.

```
ghci> fifth [1..100_000_000]
5
(0.01 secs, 112,072 bytes)
ghci> fifth [1..100_000_000_000]
5
(0.01 secs, 112,072 bytes)
ghci> fifth [1..100_000_000_000_000]
5
(0.01 secs, 112,064 bytes)
```

Notice tht even when we called `fifth` on a 100-trillion-element list, it had the same running time and allocation behavior as when we called it on a 5-element list.  That's because of laziness!  Only the part of the list that was actually needed by `fifth` to run actually got evaluated.

In fact, we could even call `fifth` on an *infinite* list.  It's easy to make one with `[1..]`.

```
ghci> fifth [1..]
5
(0.01 secs, 112,016 bytes)
```

Works great!

So, laziness is often our friend, especially when we have to deal with infinite data structures.

However, understanding how laziness affects the performance of our programs can be confusing.  So let's come back to that supposedly tail-recursive function `len'` that seemed to be overflowing.

ghci> len [1..100_000_000]
*** Exception: stack overflow
ghci> len' [1..100_000_000] 0
*** Exception: stack overflow

When I told you about how calls to `len'` are evaluated, I lied a bit.  I said it looked like this:

len' [1, 2, 3, 4, 5] 0
= len' [2, 3, 4, 5] 1
= len' [3, 4, 5] 2
= len' [4, 5] 3
= len' [5] 4
= len' [] 5
= 5

But really, because of lazy evaluation, what *actually* happens?

Because of laziness, it's more like this:

len' [1, 2, 3, 4, 5] 0
= len' [2, 3, 4, 5] (0 + 1)
= len' [3, 4, 5] ((0 + 1) + 1)
= len' [4, 5] (((0 + 1) + 1) + 1)
= len' [5] ((((0 + 1) + 1) + 1) + 1)
= len' [] (((((0 + 1) + 1) + 1) + 1) + 1)
= (((((0 + 1) + 1) + 1) + 1) + 1)
= 5

Because the `acc` argument is evaluated lazily, writing the function in a tail-recursive way didn't actually help us.  The answer here is to force the `acc` argument to be evaluated strictly.  GHC has what's called a language pragma for that, which is called "BangPatterns".

If you turn on this special language pragma, you can put an exclamation point, or "bang", in front of a pattern.  If you do, then matching an expression against the pattern will be done by first evaluating the expression and then matching.  So we can do this: 

```
{-# LANGUAGE BangPatterns #-}

len' :: [a] -> Int -> Int
len' []     !acc  = acc
len' (x:xs) !acc = len' xs (acc + 1)
```

And now we can evaluate calls like `len' [1..100_000_000] 0` without blowing the stack.

To be very clear: we *don't* expect you to use bang patterns in the code you write for this class.  In fact, we don't even *want* you to.  I'm only pointing this out because I want to be honest with you about the way that laziness interacts with tail recursion.

Okay.  So now we have this tail-recursive function, `len'`.  The only thing left is to give it the same *type* as `len`.  We want it to be a drop-in replacement for `len'`.  So it needs to have the same type; it shouldn't take this extra accumulator argument. So what can we do?

(Discuss helper functions and `where` clauses)

OK, we're almost ready to do a quiz, but the quiz contains a couple of things we haven't seen yet, so let's talk about those before unleashing the quiz.

If you haven't encountered `Maybe` before, it is the following sum type and part of the Haskell Prelude:

```
data Maybe a = Nothing | Just a
```

Then, functions that take functions as arguments.

```
-- Take a predicate and an argument and apply the predicate to the argument, 
-- returning the result
-- (warm-up for the quiz)
applyPredicate :: (a -> Bool) -> a -> Bool
applyPredicate pred a = pred a
```

