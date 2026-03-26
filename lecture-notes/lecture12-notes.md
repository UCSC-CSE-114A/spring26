# CSE114A lecture 12

Agenda: 
  
- `foldr` vs. `foldl`
- When do `foldr` and `foldl` behave differently?
- Let's add variables to the `Expr` language

## `foldr` vs. `foldl`

So, a week ago, in lecture 10, we talked about the `foldr` function; we wrote it ourselves, and then we practiced using it a bit.

So here's the definition that we wrote then:

```
foldr :: (a -> b -> b) -> b -> [a] -> b
foldr f b []     = b
foldr f b (x:xs) = f x (foldr f b xs)
```

And one of the functions that we wrote first manually, and then in terms of `foldr`:

```
ourSum :: [Int] -> Int
ourSum [] = 0
ourSum (x:xs) = x + ourSum xs


ourSum' :: [Int] -> Int
ourSum' = foldr (+) 0
```

At the end of that lecture a week ago, I asked you if `foldr` was tail-recursive, and we concluded that it was not.  And we can see that, from looking at its definition -- the recursive call is not the last thing that happens.  Instead it's an argument to a call to `f`.  So let's come back to that and think about how we could write a tail-recursive fold.

To get a better look about what happens when a call to `foldr` is evaluated, let's try visualizing it.  Let's call `ourSum'` with a list `[1, 2, 3, 4]`.  Of course this list sums to 10.  How do we arrive at that answer?

```
ourSum' [1, 2, 3, 4]
foldr (+) 0 [1, 2, 3, 4]
(+) 1 (foldr (+) 0 [2, 3, 4])
(+) 1 ((+) 2 (foldr (+) 0 [3, 4]))
(+) 1 ((+) 2 ((+) 3 (foldr (+) 0 [4])))
(+) 1 ((+) 2 ((+) 3 ((+) 4 (foldr (+) 0 []))))
(+) 1 ((+) 2 ((+) 3 ((+) 4 0)))
```

I wrote the `(+)` operation prefix because I was literally plugging it into the body of `foldr`.  But it's kind of hard to read, so let's write it infix instead.

```
ourSum' [1, 2, 3, 4]
foldr (+) 0 [1, 2, 3, 4]
1 + (foldr (+) 0 [2, 3, 4])
1 + (2 + (foldr (+) 0 [3, 4]))
1 + (2 + (3 + (foldr (+) 0 [4])))
1 + (2 + (3 + (4 + (foldr (+) 0 []))))
1 + (2 + (3 + (4 + 0)))
```

And then to finally do the computation, we have to do what's in the innermost parentheses first:

```
1 + (2 + (3 + (4 + 0)))
1 + (2 + (3 + 4))
1 + (2 + 7)
1 + 9
10
```

Notice that our original list was `[1, 2, 3, 4]`, and we accumulated the sum from the *right*.  We actually go all the way to the end of the list before we start adding things up.  In general, when you use `foldr`, you use the combiner function -- in this case it's `(+)`, but it could be whatever you specify -- to combine the list elements from the right.  First you combine the rightmost element with the base value that you specify -- in this case, `0`, but it could be whatever.  The you take the result of that and you combine it with the next-rightmost value, and so on.

This is what the "r" in the name `foldr` refers to: we're combining elements of the list starting from the *right*, so "r" stands for "right".

So what about the opposite -- combining elements from the left?

It may not surprise you to learn that there's a function for that, and it's called `foldl`.  And `foldl`, unlike `foldr`, *is* tail-recursive!

To motivate this a bit, here's our original version of `ourSum`, which isn't tail-recursive:

```
ourSum :: [Int] -> Int
ourSum [] = 0
ourSum (x:xs) = x + ourSum xs
```

How would we write this tail-recursively?  You all had to do this as a homework exercise.  One way to do it is with a helper function in a `where` clause, like this:

```
ourSumTR :: [Int] -> Int
ourSumTR l = helper 0 l
  where 
    helper :: Int -> [Int] -> Int
    helper acc []     = acc
    helper acc (x:xs) = helper (acc + x) xs
```

So the question is, can we factor this tail-recursive behavior out into one generic function?  And the answer is yes, and that's exactly what `foldl` does.  So here's `foldl`:

```
foldl :: (b -> a -> b) -> b -> [a] -> b
foldl f acc [] = acc
foldl f acc (x:xs) = foldl f (f acc x) xs
```

Its type is *almost* the same as `foldr`, but notice that the combiner function takes its arguments in the opposite order.  It takes something of the base type first, and then takes something of the list element type.

So now we can implement a one-liner version of `ourSumTR` using `foldl`:

```
ourSumTR' :: [Int] -> Int
ourSumTR' = foldl (+) 0
```

It looks almost like the non-tail-recursive version, but let's see how its execution is different.

```
ourSumTR' [1, 2, 3, 4]
foldl (+) 0 [1, 2, 3, 4]
foldl (+) (0 + 1) [2, 3, 4]
foldl (+) ((0 + 1) + 2) [3, 4]
foldl (+) (((0 + 1) + 2) + 3) [4]
foldl (+) ((((0 + 1) + 2) + 3) + 4) []
(((0 + 1) + 2) + 3) + 4
((1 + 2) + 3) + 4
(3 + 3) + 4
6 + 4
10
```

OK.  So, we got the tail-recursive behavior we wanted, and notice that we accumulate the sum from the left this time, instead of from the right.

But notice it wasn't quite what we wanted -- we would have rather had this accumulator argument be evaluated eagerly each time, instead of having to wait to the end to add it all up.  So if you look up `foldl` in the docs, that's exactly what they say too!

## When do `foldr` and `foldl` behave differently?

Often, `foldr` and `foldl` produce the same results:

```
ghci> foldr (++) "" ["sunny", "coco", "toby", "pinky"]
"sunnycocotobypinky"
ghci> foldl (++) "" ["sunny", "coco", "toby", "pinky"]
"sunnycocotobypinky"
```

What's going on here?  Well, here, `foldr` is computing something like

```
"sunny" ++ ("coco" ++ ("toby" ++ ("pinky" ++ "")))
```

while `foldl` is computing something like

```
((("" ++ "sunny") ++ "coco") ++ "toby") ++ "pinky"
```

String concatenation (like with `(++)`) is an associative operation (i.e., `"a" ++ ("b" ++ "c")` is the same as `("a" ++ "b") ++ "c"`), so you don't need to worry about the results being different if you're combining from the right or the left. The same goes for addition.

But sometimes `foldr` and `foldl` do produce different results.  For instance:

```
ghci> foldr (-) 0 [1, 2, 3, 4]
-2
ghci> foldl (-) 0 [1, 2, 3, 4]
-10
```

This time, `foldr` is computing something more like

```
ghci> 1 - (2 - (3 - (4 - 0)))
-2
```

while `foldl` is computing something more like

```
ghci> (((0 - 1) - 2) - 3) - 4
-10
```

The reason for the difference is that subtraction is not an associative operation! Personally, I suggest avoiding using non-associative operations with folds unless you really know what you're doing -- there's too much potential for confusion.

## Environment-passing interpreters

So here's our little interpreter that we've been playing with.

```
data Expr = Plus Expr Expr
          | Minus Expr Expr
          | Times Expr Expr
          | IfZero Expr Expr Expr
          | Number Int

interp :: Expr -> Int
interp (Number n) = n
interp (Plus e1 e2) = interp e1 + interp e2
interp (Minus e1 e2) = interp e1 - interp e2
interp (Times e1 e2) = interp e1 * interp e2
interp (IfZero e1 e2 e3) = if interp e1 == 0 then interp e2 else interp e3
```

Let's add variables to our language!
