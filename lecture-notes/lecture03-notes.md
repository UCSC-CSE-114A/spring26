# CSE114A lecture 3

Agenda:

- Recap of lambda calculus syntax
- Notational conventions
- Redexes and normal form
- How to *encode* things we want in lambda calculus:
  - Booleans (true and false values)
  - Boolean operators (and, or, not, ...)
  - conditional expressions (if ... then ... else)
  - Numbers
  - Incrementing numbers
  - Adding numbers

## Recap of lambda calculus syntax

There are three syntactic forms in lambda calculus: variables, function definitions, and function calls. We can write a grammar:

e := x | \x -> e | e1 e2

That's it!

A function definition `\x -> e` is also called a *lambda abstraction*
A function call `e1 e2` is also called an *application* (you're *applying* the function `e1` to the argument `e2`)

## Notational conventions

- The body of a lambda abstraction *extends as far right as possible*: `\x -> m n` means `\x -> (m n)`, not `(\x -> m) n`.

- Applications are left-associative: `a b c` means `(a b) c`, not `a (b c)`.

This left-associativity fits together nicely with the fact that functions take their arguments one at a time. This is called *currying*. We can think of the expression `f g h` as being a call to a function `f` with *two* arguments, `g` and `h`. But since functions take their arguments one at a time, what really happens is that `f` only takes `g`, and then returns a function that takes `h`.  This is also going to be the case in Haskell, when we start writing Haskell.

- Instead of `\x -> (\y -> (\z -> e))`, as a convenient shorthand, we can leave out the parentheses and just write `\x -> \y -> \z -> e`. And once we do that, we can abbreviate further and just write `\x y z -> e`.  We'll use this convention from now on.

- Putting together all the above: instead of writing

(((\x -> (\y -> (\z -> z))) q) r) s

we could just write

(\x y z -> z) q r s

## Redexes and normal form

We talked about the notion of a "redex" last time. So, to recap, the word "redex" is a cute portmanteau of "reducible expression", so a redex is an expression that can be reduced via beta steps.  Anything that you can apply the beta rule to is a redex.

And now that we know what a redex is, now we can define what a lambda calculus expression in *normal form*  An expression in normal form is one that has no redexes. So expression in normal form is one where you've taken all the beta steps that you can.  So when you're working in Elsa, when Elsa complains that an expression can be further reduced, that's just another way of saying that it's not in normal form.

In general, an expression might have more than one redex.  There are times when you might have a lambda calculus expression that you want to evaluate, and so you'd like to take a beta step, and you have choices as to where in the expression you can take that beta step. Here's one:

```
(\x y -> (\z -> z) x) rainbow sprinkles
```

There are a few options for how we evaluate this expression.  We could do this:

```
eval multiple_redexes : 
  (\x y -> (\z -> z) x) rainbow sprinkles
  =b> (\y -> (\z -> z) rainbow) sprinkles
  =b> (\z -> z) rainbow
  =b> rainbow
```

Or this:

```
eval multiple_redexes_alt : 
  (\x y -> (\z -> z) x) rainbow sprinkles
  =b> (\x y -> x) rainbow sprinkles
  =b> (\y -> rainbow) sprinkles
  =b> rainbow
```

Notice that I ended up with the same thing either way.

In fact, that is true in general, any time you have an expression that where you can take a beta step in more than one place, it doesn't actually matter where you take it.  If the expression has a normal form, then the normal form is unique, and you'll get to the unique normal form eventually.  Maybe some reduction sequences have fewer steps than others, and some have more steps than others but eventually you'll get to the same normal form.  That's something that's fundamentally true about lambda calculus, and it's called the Church-Rosser theorem, if you want to look it up.

## How to encode things we want in lambda calculus

## Booleans

You might have already seen encodings of booleans, and boolean operators, and conditional expressions, if you started looking at homework 0:

```
let TRUE  = \x y -> x
let FALSE = \x y -> y
let ITE   = \b x y -> b x y
let NOT   = \b x y -> b y x
let AND   = \b1 b2 -> ITE b1 b2 FALSE
let OR    = \b1 b2 -> ITE b1 TRUE b2
```

But it might not have been obvious *why* they were defined that way.  So let's try to unpack it.

```
let TRUE  = \x y -> x
let FALSE = \x y -> y
let ITE = \b x y -> b x y -- "ITE" stands for "if ... then ... else"
```

Why are TRUE, FALSE, and ITE defined the way they are?
Let's write some unit tests.

eval if_true :
  ITE TRUE rainbow sprinkles
  =~> rainbow

eval if_false :
  ITE FALSE rainbow sprinkles
  =~> sprinkles

## Numbers

In particular, natural numbers.

A classic way to encode numbers in lambda calculus is known as *Church numerals*, after Alonzo Church.

With Church numerals, to encode the number N, we use a function that takes arguments `f` and `x`, and then applies `f` to `x` N times!

So, for instance:

```
let ONE   = \f x -> f x
let TWO   = \f x -> f (f x)
let THREE = \f x -> f (f (f x))
let FOUR  = \f x -> f (f (f (f x)))
let FIVE  = \f x -> f (f (f (f (f x))))
let SIX   = \f x -> f (f (f (f (f (f x)))))
```

What about the number zero?  Any idea how we'd write it?

We just apply `f` to `x` *zero* times!

```
let ZERO  = \f x -> x
```

We still want to *take* both arguments `f` and `x`, even though we never use `f`.  Why?

Because we want all numbers to have a uniform *interface*.  All numbers should be usable in a context that expects numbers.  So every function representing a number needs to expect the same number of arguments, but each has a different body.

## Incrementing numbers

Given that numbers are defined this way, how would you *increment* a number?

Well, let's think about it: if you had ZERO, how would you get ONE?

You have this:

```
\f x -> x
```

But what you want is this:

```
\f x -> f x
```

How would you write a function that, given the first thing, produces the second?

Your function needs to take a number as an argument.  So it takes one argument; let's call that argument `n`, for number.  So you know that the function starts like this:

```
\n -> ...
```

What should it return?  Well, all numbers are functions that look like `\f x -> ...`, so you know that your number-incrementing function had better return something of that shape.  So it's got to be something like:

```
let INCR = \n -> (\f x -> ...)
```

But what should go in the body of the function we're returning?

Clearly we need to use the argument, `n`, somehow.  We know that `n`, since it's a number, is something of the shape

```
\f x -> f ... (f x)
```

for some number of repetitions of f.  And what we want to produce is something that has one *more* repetition.

If we just wrote `n` in the body of the function returned by INCR, that wouldn't be right:

```
INCR = \n -> (\f x -> n) -- not quite right...
```

Because, then, for example, what if `n` were ZERO?  Then what we want is ONE, but what we'd get would be

```
INCR ZERO
=b> (\n -> (\f x -> n)) (\f x -> x)
=b> \f x -> (\f x -> x)
```

And that's not what ONE is supposed to be.  We want `\f x -> f x`, not `\f x -> (\f x -> x)`.

We can get closer to what we want by *applying* `n` to arguments `f` and `x`.  What if we defined `INCR` that way?

```
let INCR = \n -> (\f x -> n f x) -- still not quite right, but closer...
```

Then we'd have:

```
INCR ZERO
=b> (\n -> (\f x -> n f x)) ZERO
=b> \f x -> ZERO f x
=d> \f x -> (\f x -> x) f x
=b> \f x -> (\x -> x) x
=b> \f x -> x
```

But that's just `ZERO` again.  How do we make it into `\f x -> f x`, which is `ONE`?  We need another call to `f`!

```
let INCR = \n -> (\f x -> f (n f x)) -- finally what we want!
```

In Elsa:
```
eval inc_zero :
  INCR ZERO
  =d> (\n -> (\f x -> f (n f x))) ZERO
  =b> \f x -> f (ZERO f x)
  =d> \f x -> f ((\f x -> x) f x)
  =b> \f x -> f ((\x -> x) x)
  =b> \f x -> f x
  =d> ONE
```

So what we've ended up with is:

```
let INCR = \n -> (\f x -> f (n f x))
```

which takes a number (which is a function that calls `f` on `x` some number of times),
and then returns a function that calls `f` on `x` exactly one more time than `n` does,
resulting in a number that's one bigger.

```
eval inc_two :
  INCR TWO
  =d> (\n -> (\f x -> f (n f x))) TWO
  =b> \f x -> f (TWO f x)
  =d> \f x -> f ((\f x -> f (f x)) f x)
  =b> \f x -> f ((\x -> f (f x)) x)
  =b> \f x -> f (f (f x))
  =d> THREE
```

## Adding numbers

We're now at the point where we're ready to actually *add* numbers together.

Since we have `INCR`, how can we use it to implement addition?  Let's say we want to add two numbers.  We want a function, that, given two numbers, returns their sum.

So our function would have to be something like:

```
let ADD = \n m -> ...
```

If we know the numbers `n` and `m`, how do we get their sum?  Well, we have a way to increment numbers!

So we could take one of them, say, `n`, and increment it `m` times.
Or we could take `m` and increment it `n` times.  Either way would be fine.

Here's a function that does that:

```
let ADD = \n m -> n INC m
```

Why does this work?  Well, recall that the Church numeral for a number N is just a function that takes arguments `f` and `x`, and applies `f` to `x`, N times.

So when we call `n INC m`, `n` is some Church numeral, so it'll apply `INC` to `m` some number of times.  What number of times?  Whatever number it's supposed to be representing.

Let's try it:

```
eval add_two_one :
  ADD TWO ONE
  =d> (\n m -> n INC m) TWO ONE
  =b> (\m -> TWO INC m) ONE
  =b> TWO INC ONE
  =d> (\f x -> f (f x)) INC ONE
  =b> (\x -> INC (INC x)) ONE
  =b> INC (INC ONE)
  =~> THREE
```

We can see that `ADD` takes its first argument (in this case, `TWO`),
and calls it with the arguments `INC` and its second argument (in this case, `ONE`).

Because a number N is nothing but a function that takes as its first argument a function, and then applies that function to its second argument N times,

`TWO INC ONE` ends up evaluating to `INC (INC ONE)`, which evaluates to `THREE`, which is what we wanted!

So `ADD`, defined like this:

```
let ADD = \n m -> n INC m
```

will start from `m`, and just increments it by the number of times specified by its first argument, `n`. That gives us the sum of `n` and `m`!

It also would have been fine to take `n` and increment it `m` times, because addition happens to be commutative.  In that case, we'd write `ADD` like this:

```
let ADD = \n m -> m INC n
```

And that would also work fine!

```
eval add_two_three :
  ADD TWO THREE 
  =~> FIVE
```
