# CSE114A lecture 5

Agenda:

- Non-terminating lambda calculus programs
- The Y combinator
- Writing recursive programs with lambda calculus
- If time: lambda calculus as a naturally parallel model of computation

## Non-terminating lambda calculus programs

Let's talk about non-termination. We've already encountered some programs that, when evaluated, never reach a normal form.  Here's a really simple and famous one.  It's called "omega":

```
let OMEGA = (\x -> x x) (\x -> x x)
```

Let's try evaluating it and see what happens:

```
eval omega : 
  (\x -> x x) (\x -> x x)
  =b> (\x -> x x) (\x -> x x)
```

It seems bad that we can so easily write a nonterminating program! But this is going to be the case in any Turing-complete programming language. If it's a Turing-complete language, then it means that some programs don't halt.

But `OMEGA` is a pretty useless nonterminating program.  It just loops endlessly and uselessly.  Let's look at a much more useful one.

## The Y combinator

There's another nonterminating program that you encountered in section last week.  It's of a similar flavor to `OMEGA`, but a little more complicated:

```
let Y = \f -> (\x -> f (x x)) (\x -> f (x x))
```

This is the famous *Y combinator*.

I noticed on the section worksheets, by the way, that some people wrote that `Y` is a recursive function.  That's not quite true.  A recursive function is a function that calls itself, and `Y` doesn't call itself.  It calls its *argument*, it doesn't call itself.  (It *can't* call itself, because it doesn't know its own name.) But we can *use* the `Y` combinator to accomplish recursion, which we'll see in a minute.

Let's try evaluating the Y combinator and see what happens:

``` 
eval y :
  \f -> (\x -> f (x x)) (\x -> f (x x))
  =b> \f -> f ((\x -> f (x x)) (\x -> f (x x)))
  =b> \f -> f (f ((\x -> f (x x)) (\x -> f (x x))))
  =b> \f -> f (f (f ((\x -> f (x x)) (\x -> f (x x)))))
```

Similar to `OMEGA`, we can see that `Y` doesn't seem to be getting any closer to a normal form when we evaluate it.  But it's rather different.  `OMEGA` just loops uselessly, not accomplishing anything.  On the other hand, with the `Y` combinator we're seeing that we get these repeated applications of `f`.  It seems like, if we want to apply a function repeatedly, for some unspecified number of times, we ought to pass it as an argument to the `Y` combinator!

(Note that this is different from what we do with Church numerals.  With Church numerals, the number N is a machine for applying a function to an argument exactly N times.  So, for example, if you know in advance that you need to apply some function to some argument exactly six times, you can pass that function and that argument to the number `SIX`.  But if you don't know in advance how many times you need to do something, then the `Y` combinator is your friend.

Let's look at how we might use the `Y` combinator.

## Writing recursive programs with lambda calculus

The triangular number T(n) is the sum of all the natural numbers up to n.

T(0) = 0
T(1) = 1 + 0 = 1
T(2) = 2 + 1 + 0 = 3
T(3) = 3 + 2 + 1 + 0 = 6

And so on.

In general, we can define this inductively:

T(0) = 0          -- base case
T(n) = n + T(n-1) -- inductive case

And since this is an inductive definition, then a natural way to compute it would be with a recursive function.

If we were to write a program called `TRI` to compute triangular numbers in lambda calculus, what would it have to look like?  Let's say that we want it to take a natural number n as its argument, and then return T(n).

Let's also suppose we already have `ISZ` and `DECR`, which you're implementing for the first homework assignment, and a few of you have finished implementing already.

I don't want to give away the homework solutions, but I actually have another file where I have those definitions written so I can use them, so I'll just cat these files together and then we'll run the resulting file.

```
cat defs.lc lecture05.lc > defslecture05.lc
stack exec elsa defslecture05.lc 
```

It's tempting to try to write `TRI` this way:

```
let TRI = \n -> ITE (ISZ n) 
                    ZERO 
					(ADD n (TRI (DECR n)))
```

But if we pop this into Elsa, what will happen?

Elsa will complain that `TRI` is unbound!  Why?

In Elsa, `let`-bound terms like `TRI` are just syntactic sugar.  To use `TRI`, we just replace it with its definition.  But the definition of `TRI` *contains* `TRI`.  So what do we do?

It kind of seems like we can't do recursion, because a recursive function has to call itself, and therefore it has to know its own name.

But it turns out we *can* do recursion, with the help of our friend the `Y` combinator.

First, instead of using `TRI` in the definition of `TRI`, we need to pass in an argument that we *can* use.  I'm going to name this version `TRI1`.

```
let TRI1 = \rec -> \n -> ITE (ISZ n) 
                         ZERO 
		   			     (ADD n (rec (DECR n)))
```

And now, we need to pass `TRI1` to some function that will call `TRI1` *with itself as an argument*.  It turns out that the `Y` combinator that we defined earlier is exactly such a function!

Let's write a few test cases that should pass:

```
eval triangular_number_zero :
  TRI ZERO
  =~> ZERO

eval triangular_number_one :
  TRI ONE
  =~> ONE

eval triangular_number_two :
  TRI TWO
  =~> THREE

eval triangular_number_three :
  TRI THREE
  =~> SIX
```

In general, the recipe for writing a recursive function is:

1. Write the function you wish you could write, with a recursive call
2. Take an extra argument as the first argument, and replace the name of the recursively called function with that argument
3. Pass this augmented function to `Y`

