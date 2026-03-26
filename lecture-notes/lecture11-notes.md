# CSE114A lecture 11

Agenda: 
  
- Type classes!
  - Type class constraints in type signatures
  - Derived instances of type classes
  - Implementing our own instances of type classes

# Type class constraints in type signatures

We know that every expression in Haskell has a type, and we know that functions have arrow types that tell us the type of arguments they take and the type that they return.

Think about a function like `(+)`.  We've used it a lot.  What kinds of things can be added?

Obviously, we can add integers:
```
ghci> 3 + 2
5
```

So, what should the type signature of `(+)` be?  Should it be `Int -> Int -> Int`?

No!  Because we also want to add numbers that aren't `Int`s:

```
ghci> 3.1 + 2.4
5.5
```

So we need to give `(+)` a more general type than `Int -> Int -> Int`.

So, should its signature be `a -> a -> a`?

No, because that would be too general!  For instance, that would let us add `Bool`s and `String`s and other things that we don't want to have be addable.  So `Int -> Int -> Int` is too specific, but `a -> a -> a` is too general.

Another issue is that under the hood, arithmetic on different types ought to be implemented differently!  So we really don't want there to be just one definition of `(+)`.  We want there to be a bunch of definitions, and we want Haskell to use whichever one makes sense for the particular arguments we pass to it.

Haskell has a cool mechanism for solving both of these problems, and this mechanism is called *type classes*. (A type class is *not* the same thing as the notion of a class from object-oriented programming, so if that's what you're thinking of, banish that thought from your mind.)

Type classes:

  - let us specify what operations can be used on things of a certain type
  - let us provide specific definitions of those functions for specific types when necessary

So, to put an end to the mystery, let's see what GHCi says the type of `(+)` is.

```
ghci> :t (+)
(+) :: Num a => a -> a -> a
```

So GHCi says that the type of `(+)` is almost `a -> a -> a`, but there's something extra: this `Num a =>` at the beginning.

The `Num a` is a *type class constraint* on the type variable `a`.  The constraint tells us that we can call `(+)` on things of whatever type, *as long as* that type is an *instance of* something called the `Num` type class.

We can use the `:info` command in GHCi, or `:i` for short, to learn more about `Num`.  Let's try it.

A type class can be thought of as a collection of operations that we'd like to be able to use on a whole bunch of types.

The type `Int` is an *instance* of `Num`, and so is `Float`, and so are a few other numeric types.

Let's look at another type class that you might have encountered.

```
ghci> True == False
False
ghci> 3 == 3
True
ghci> [1, 2, 3] == [1, 2, 3]
True
ghci> (\x -> x) == (\y -> y)

<interactive>:10:11: error:
    • No instance for (Eq (p0 -> p0)) arising from a use of ‘==’
        (maybe you haven't applied a function to enough arguments?)
    • In the expression: (\ x -> x) == (\ y -> y)
      In an equation for ‘it’: it = (\ x -> x) == (\ y -> y)
ghci> (\x -> x) 5 == (\y -> y) 5
True
```

What's the type of `(==)`?

```
ghci> :t (==)
(==) :: Eq a => a -> a -> Bool
```

GHCi says it's `a -> a -> Bool`, *but* with a type class constraint that says that whatever type `a` we're comparing, it has to be an instance of the `Eq` type class.

We can see from `:info Eq` that if a type is an instance of `Eq`, then you can do just two operations on it: `(==)` and `(/=)`.

## Derived instances of type classes

There are a ton of built-in types that are instances of `Eq`.  But what if we want to use `(==)` on types we've defined ourselves?

Recall our `Expr` type, and the little interpreter we defined for it.  Let's pull that in.

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

Right now, we don't have any way to call `(==)` on values of `Expr` type.  What happens if we try?

```
ghci> :t (Plus (Number 3) (Number 4))
ghci> (Plus (Number 3) (Number 4)) == (Plus (Number 3) (Number 4))

<interactive>:9:26: error:
    • No instance for (Eq Expr) arising from a use of ‘==’
    • In the expression:
        (Plus (Number 3) (Number 4)) == (Plus (Number 3) (Number 4))
      In an equation for ‘it’:
          it = (Plus (Number 3) (Number 4)) == (Plus (Number 3) (Number 4))
ghci> 
```

So, one option we have here is to just tell Haskell to try to automatically derive an instance of the `Eq` type class for `Expr`.  We can stick `deriving Eq` on the definition of `Expr`, like this:

```
data Expr = Plus Expr Expr
          | Minus Expr Expr
          | Times Expr Expr
          | IfZero Expr Expr Expr
          | Number Int
  deriving Eq
```

We've seen this before with `deriving Show`.  In fact, we could do both.  (If we want to do `deriving` more than once, we have to put them in parentheses and separate them with commas.)

```
data Expr = Plus Expr Expr
          | Minus Expr Expr
          | Times Expr Expr
          | IfZero Expr Expr Expr
          | Number Int
  deriving (Eq, Show)
```

(Not every type class is automatically derivable, by the way.  Just a handful of them are.)

Now that we added `deriving Eq`, let's see what happens now when we compare `Expr`s with `(==)`.

```
ghci> (Plus (Number 3) (Number 4)) == (Plus (Number 3) (Number 4))
True
```

It works!

## Implementing our own instances of existing type classes

But there's a hitch.

We know that *semantically*, adding 3 and 4 is kind of the same as adding 4 and 3, since addition is commutative.  And our interpreter behaves accordingly.

```
ghci> interp (Plus (Number 3) (Number 4))
7
ghci> interp (Plus (Number 4) (Number 3))
7
```

But what happens when we try to compare these two `Expr`s, `Plus (Number 3) (Number 4)` and `Plus (Number 4) (Number 3)`, for equality?

```
ghci> (Plus (Number 3) (Number 4)) == (Plus (Number 4) (Number 3))
False
```

Womp womp.  What went wrong here?  The issue is that the automatically derived definition of `(==)` that we got from `deriving Eq` just compares the two `Expr`s structurally.  It's not smart enough to know anything about the *meaning* of an `Expr`.

So, let's define our own instance of `Eq` for `Expr`s! 

We can implement our own instance using the `instance` keyword, like this:

```
instance Eq Expr where
    (==) :: Expr -> Expr -> Bool
    (==) e1 e2 = interp e1 == interp e2
```

It's also possible to define one's own type classes.  In fact, on assignment 3, there's a definition of a type class for environments, and then we ask you to implement your own instances of that type class.
