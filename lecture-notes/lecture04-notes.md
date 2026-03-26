# CSE114A lecture 4

Agenda:

- Variable scope
- Free and bound variables
- Computing the set of free variables of an expression
- Revisiting the beta rule
- Capture-avoiding substitution
- More lambda calculus encoding: Pairs!

## Variable scope

A *binding* is an association of a name to some entity.

The *scope* of a binding in a program (*any* program, not just lambda calculus programs!)
is the part of the program where the name can be used to refer to the entity.

In lambda calculus in particular, if we have a function `\x -> e`,

the name `x` (also known as the *formal parameter* of the function) gets associated with whatever actual argument is passed to the function.  So that's a binding.

And the *scope* of that binding is `e`, which is the *body* of the function.

If `\x -> e` is one small part of some bigger program, elsewhere in the program, `x` might refer to something else, or it might not refer to anything.

## Free and bound variables

In the function `\x -> e`, we say that any *occurrence* of `x` in `e` is *bound* by the *binder* `\x`.

For instance, the functions

`\x -> x`

`\x -> (\y -> x)`

both have *bound occurrences* of the variable `x` in their bodies.

An occurrence of a variable `x` is a *free occurrence* if it is not a *bound occurrence*.

So, for instance, there are free occurrences of `x` in all of the following expressions:

`x y` <- here, `x` occurs free because there aren't any binders at all! `y` also occurs free.

`\y -> x y` <- there's a binder here but it's not binding `x`.  `x` is free in this expression because there's no binder for it. `y` only occurs bound.

`(\x y -> y) x` <- in this expression, there are binders that bind x and y, but `x` occurs free outside of the scope of those binders.  `y` only occurs bound.

## Computing the set of free variables of an expression

Given any lambda calculus expression, we can compute the set of variables that occur free in the expression.

Remember the grammar of lambda calculus has just three syntactic forms:

e ::= x | \x -> e | e1 e2

So those are the three cases we have to deal with.

Let FV(e) be the set of variables that occur free in e.  We can define FV this way:

FV(x)       = { x }
FV(\x -> e) = FV(e) - { x }  <- "-" is set difference, here
FV(e1 e2)   = union of FV(e1) and FV(e2)

An expression that has no free variables is said to be *closed*.  A closed expression is also known as a *combinator*.

What's the shortest combinator you can think of?  Our friend the identity function: `\x -> x`!

## Revisiting the beta rule

OK, so now that we know what the free variables of an expression are, we can revisit the beta rule.

Before, we said that the beta rule was:

(\x -> e1) e2 =b> e1[x := e2]

and we said that e1[x := e2] means "e1, but with all occurrences of x replaced with e2".

But what if you had something like this?

(\x -> (\x -> x)) y

What should happen when we take a beta step here?
There's one occurrence of the variable `x` in the body of the function.
If we naively applied the beta rule, replacing occurrences of `x` in the body with the actual argument `y`, we'd get this:

\x -> y

Is this right? No, it isn't!

Elsa would complain at this:

```
eval bad_reduction :
  (\x -> (\x -> x)) y
  =b> \x -> y
```

Really, `(\x -> (\x -> x))` is a function that should take an argument, *ignore it*, and return the identity function.

Elsa would be happy about this:

```
eval good_reduction :
  (\x -> (\x -> x)) y
  =b> \x -> x
```

OK, so we need to change how we're thinking of the beta rule slightly.  Instead of

(\x -> e1) e2 =b> e1 [x := e2]

where e1 [x := e2] means "e1, but with all occurrences of x in it replaced with e2"

we need it to be 

where e1 [x := e2] means "e1, but with all **free** occurrences of x in it replaced with e2".  Leave the bound occurrences alone!

Is that good enough?  Well...but what about this tricky one?

(\x -> (\y -> x)) y

What do we get when we take a beta step?  The body of the function is `\y -> x`.  So we should get

"`\y -> x`, but with all **free** occurrences of `x` in it replaced with `y`"

So we'd get 

(\x -> (\y -> x)) y
=b> \y -> y

But wait!  That's not right, either! D:

What went wrong here was that `y` occurred free in the *argument*, and then it got *captured* by the `\y` binder in the body of the function!

What should we do about this?

We have to make sure that the binders used in the *body* of a function are different from variables that occur free in the *argument* to a function.
If that isn't true, then we just can't take a correct beta step.

So, instead of

e1 [x := e2] means "e1, but with all **free** occurrences of x in it replaced with e2"

we *really* want

e1[x := e2] means "e1, but with all **free** occurrences of x in it replaced with e2, **as long as no variables that occur free in e2 get captured by binders in e1**".

And if any variables *do* get captured, the substitution operation is *undefined*.  This means that if we want to use the beta rule, we sometimes need to *rename* formal parameters until we can take a correct beta step.

This brings us finally to *capture-avoiding substitution*.

## Capture-avoiding substitution

We can now formally define the substitution operation.

Once more, the beta rule is:

(\x -> e1) e2 =b> e1[x := e2]

where e1[x := e2] means "e1, but with all **free** occurrences of x in it replaced with e2, **as long as no variables that occur free in e2 get captured by binders in e1**".

So, how to define the substitution operation

e1[x := e2]

What are the things that e1 might be?  Remember our three syntactic forms.

e ::= x | \x -> e | e1 e2

So there are three cases to deal with that e1 might be.

### Variables

e1 might be a variable, which might either be the same as the binder or not.

If e1 is a variable and the same as the formal parameter in the binder (that is, e1 == x):

(\x -> x) e2 =b> e2

x[x := e2] = e2

If e1 is a variable and *not* the same as the formal parameter in the binder (that is, e1 == y):

(\x -> y) e2 =b> y

y[x := e2] = y

### Applications

If e1 is an application (e1 == e' e''):

(e' e'')[x := e2] = (e'[x := e2]) (e''[x := e2])

### Lambda abstractions

If e1 is a function with `x` as its formal parameter (e1 == \x -> e'):

(\x -> e')[x := e2] = \x -> e'

(Why? Because there are no free occurrences of x in `\x -> e'`, so it stays the same!)

And finally, if e1 is a function with something other than `x` as its formal parameter (e1 == \y -> e'):

If y is **not** in FV(e2):

(\y -> e')[x := e2] = \y -> e'[x := e2]

If y **is** in FV(e2), then *substitution is undefined* and we need to do a *renaming* step before we can do substitution.  We can *rename* y to something else that isn't in the set of free variables of e2.

So back to that tricky one:

(\x -> (\y -> x)) y

Before taking a beta-step, we can *rename* the formal parameter `y` and replace all occurrences that are bound by it with the new name.

This is called an alpha-step, or alpha-renaming, written `=a>` in Elsa.

When one expression can step to another using just alpha-steps, we call those two expressions *alpha-equivalent*.

It's always safe to alpha-rename a function `\x -> e` --
as long as the new name you pick does not occur free in `e` (because you don't want to accidentally capture a variable that's in use!)

To see why this is important, think about this Python code:

```
y = 3

def identity(x):
    return x

def add_3(x):
    return x + y
```

In the function `identity`, we can safely rename the formal parameter `x` to `y`.  But if we renamed the formal parameter `x` to `y` in the function `add_3`, what would happen?  We would capture `y`!  So we need to pick a name that does not occur free in the body of `add_3`.

Back to our tricky example: 

`(\x -> (\y -> x)) y`

We can just rename `y` to `z`, since `z` isn't in use:

`(\x -> (\z -> x)) y`

And now we can finally safely step to the correct answer:

`\z -> y`

which is alpha-equivalent to `\q -> y`, or `\r -> r`, or `\x -> y`, et cetera -- but it's *not* alpha-equivalent to `\y -> y`.  So, Elsa would complain about this:

```
eval alpha_example :
  \x -> y
  =a> \y -> y
```

...but it wouldn't complain if we chose any name for the formal parameter *other* than `y` (such as `z`).

Coming back to the original expression that we wanted to deal with, in Elsa:

```
eval needs_renaming :
  (\x -> (\y -> x)) y
  =a> (\x -> (\z -> x)) y
  =b> \z -> y
```

## More lambda calculus encoding: Pairs

A pair is a two-element tuple.  What do we want to be able to do with a pair?

- Take two elements and create a new pair
- Access the first element of a pair
- Access the second element of a pair

So we need to be able to define three functions:

```
let PAIR = \x y -> ??? -- Given `x` and `y`, create a pair (x, y)
let FST = \p -> ???    -- Given a pair p = (x, y), get back its first element, x
let SND = \p -> ???    -- Given a pair p = (x, y), get back its second element, y
```

Let's write some unit tests using my cats' names, as usual:

```
FST (PAIR rainbow sprinkles) =~> rainbow
SND (PAIR rainbow sprinkles) =~> sprinkles
```

Last time we saw how to implement `TRUE`, `FALSE`, and a conditional expression, `ITE`:
	
```
let TRUE  = \x y -> x
let FALSE = \x y -> y
let ITE   = \b x y -> b x y
```

We can use those mechanisms to implement `FST`, `SND`, and `PAIR`!  The intuition here is that both Booleans and pairs are in some sense about making a choice between two options.

```
let PAIR = \x y -> (\b -> ITE b x y)
let FST = \p -> p TRUE -- call p w/ arugment TRUE, get 1st value out of p
let SND = \p -> p FALSE -- call p w/ argument FALSE, get 2nd value out of p
```

Let's step through evaluation of one our unit tests to see if it works:

```
eval pair_of_cats_1 :
  FST (PAIR rainbow sprinkles)
  =d> (\p -> p TRUE) (PAIR rainbow sprinkles)
  =b> (PAIR rainbow sprinkles) TRUE
  =d> ((\x y -> (\b -> ITE b x y)) rainbow sprinkles) TRUE
  =b> ((\y -> (\b -> ITE b rainbow y)) sprinkles) TRUE
  =b> (\b -> ITE b rainbow sprinkles) TRUE
  =b> ITE TRUE rainbow sprinkles
  =d> (\b x y -> b x y) TRUE rainbow sprinkles
  =*> TRUE rainbow sprinkles
  =d> (\x y -> x) rainbow sprinkles
  =b> (\y -> rainbow) sprinkles
  =b> rainbow
```

What does this program do?

```
\p -> ITE (FST p) (SND p) FALSE
```




















