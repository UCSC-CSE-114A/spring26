# CSE114A lecture 2

Agenda:

- Intro to lambda calculus
- Intro to Elsa

## Intro to lambda calculus

Lambda calculus is one of the simplest programming languages imaginable. We could write down the syntax for it in just one line, and in a minute, we're going to do just that. But despite its simplicity, or maybe because of its simplicity, it's an incredibly deep topic of study that has enthralled computer scientists for 100 years. 

Lambda calculus is a programming language where *everything* is a function.  The only thing you have is functions, and you have to build up everything else out of that one simple building block.  Because the building blocks are so simple, lambda calculus lends itself to reasoning in a rigorous and general way about software behavior.

So we're going to spend the next couple weeks getting really comfortable with lambda calculus. We'll learn what lambda calculus programs look like, how to evaluate them. We're going to play with a little language called Elsa that's designed for working with lambda calculus. However, we want to move on from lambda calculus as soon as possible, because programming directly in lambda calculus is kind of like programming with Turing machines. Although you technically could do it, you don't actually want to use it to solve problems in your day-to-day life -- it would be too tedious and painful. So we're going to move on as soon as we can to a language that has a lot more batteries included. And that's Haskell. But Haskell, as a functional language, has lambda calculus at its core, so the concepts we learned from studying lambda calculus will apply to Haskell too.  And then all *that* is the warm-up act for the main event in this course, which is implementing our own languages *using* Haskell.

So, let's get going on lambda calculus.  We can dispense with one misconception first.  When we use this word calculus, this doesn't refer to integrals and limits and derivatives.  It's another meaning of the word calculus. A calculus is a system of reasoning, and that's the sense in which we're going to be using the term. So that's the word "calculus".

So a really important thing happened in computer science in 1936. Does anybody know what it was?

Turing machines were invented!  By Alan Turing, of course.

It turns out that 1936 was a great year for universal models of computation, because it also happened to be the year that lambda calculus was invented by someone named Alonzo Church. And these are both universal models of computation. That means that any computer program that you wanted to write, you could write using one of these. They're also equivalent!  So anything that you can program with a Turing machine, you could also program with lambda calculus. And anything that you could program with lambda calculus, you could program with a Turing machine. Any computable function is expressible with both.

This is not to say that we would actually want to spend our time programming in either of them, but it's useful be aware of them. What's interesting, though, is that they're drastically different from each other. So what do you do with Turing machines? You have a tape and you read and write symbols on a tape. So it's all about reading and writing symbols. And the tape represents the state that you have to work with. You have this infinite tape, and the great power of a Turing machine is that you're allowed to read from it arbitrarily and write to it arbitrarily, and you can scroll around randomly on it. So it's like a big piece of state that you can do whatever you want with.

Lambda calculus is radically different. It doesn't have state at all. Instead, in lambda calculus, computation happens by evaluating expressions. So we'll see how that looks in a little while, but the essential thing to know about lambda calculus is that everything is a function. Functions are all we have. Anything else we might possibly want has to be built up out of functions. You want numbers, you have to implement them out of functions. You want Booleans, you have to implement them out of functions. You want anything else, you have to implement it out of functions. Weird, right? 

So, let's start building this up from the basics. To start out with, if everything's made out of functions, what's the simplest function that you can think of?

Metaphorically, a function is a machine that takes an input and yields some corresponding output.  So what's the simplest function?

The identity function is the simplest function I can think of.  It takes an input and it gives you back exactly what you gave it.  To express this function in lambda calculus, in traditional lambda calculus syntax, we would write:

`^x . x`


The word "lambda", by the way, is actually the result of a funny historical accident, at least according to the apocryphal tale that I was told when I was in undergrad.  So, when Alonzo Church invented lambda calculus, of course he needed to have his work typeset and printed. In his own writing, he was apparently using the `^` character, which is variously known as "hat", "caret" or "circumflex". So the story goes that when the typesetter needed to typeset his writing, they didn't have the hat character, and the closest thing that they could find was the Greek letter lambda. So the name "lambda calculus" comes from the fact that the lambda character is what the typesetter happened to have convenient, which is ironic because the caret character is an ASCII character that we all have on our keyboards today, and the Greek letter lambda is decidedly not an ASCII character!

Let's break down what this means.  The `^x` on the left is what we call a *binder*.  The binder consists of the lambda character, and it consists of the *formal parameter* to the function, which in this case is `x`.  The dot `.` is just a delimiter that separates the binder from the body of the function, and everything to the right of the dot is the body of the function, which in this case is just `x`.

The syntax that Elsa uses thankfully is ASCII, but it's also not the hat character.  In Elsa, we would write this same function as

`\x -> x`

So we use a backslash `\` instead of the lambda character, and we use an arrow `->` to separate the binder from the body.  Other than these notational differences, it's the same as what Alonzo Church wrote 90 years ago.

Off to the side, I'll also put some Python code for comparison.  Python actually has lambdas, so the most faithful translation to Python would just be something like

```
lambda x : x
```

But you could also define a function that has a name, like

```
def identity(x):
  return x
```

So these are all different ways of expressing the same thing.

Is it important that I used `x` as the formal parameter to this function? Could I have used some other name?

Sure.  If I were to write `\y -> y`, that's also the identity function.  And likewise in the case of our Python code, I could've written

```
lambda y : y
```

```
def identity(y):
  return y
```

So the name of the formal parameter doesn't matter, and we can rename it to something else, as long as we also rename occurrences of it inside the body of the function.  We'll talk more later about how to do this renaming correctly.

OK. So that's the identity function, the simplest function there is.  What else can we do?

What do you suppose this function does?

```
^z . (^x . x)
```

Or, in Elsa syntax:

```
\z -> (\x -> x)
```

Once again, we have a lambda character, which tells us that what we have here is a function. We have a formal parameter, which is named `z`. We have a dot that separates the binder from body from the rest. And what's the body? It is itself a function! Notice that the formal parameter, which is named `z`, doesn't occur anywhere in the body of the function.  So this is a function that takes an argument but then ignores that argument, drops it on the floor, and just returns the identity function.

OK, so we've now written down two functions.  We've defined the identity function, and we've defined a function that takes an argument and returns the identity function. 

So we know how to define functions.  But what do we want to be able to *do* with functions?

We want to *call* functions!

In lambda calculus, because everything is a function, we have an extremely lightweight syntax for calling functions.

In programming languages that you may be used to, let's say Python, if we want to call a function, we write the name of the function, and then a left paren, and then an argument, and then a right paren.  So to call the function `identity`, for instance, with the argument `"rainbow"`, which is the name of my cat, we would write 

```
identity("rainbow")
```

If we were to define `identity` and then evaluate that call to `identity` in the Python REPL, we'd get back the string `"rainbow"`, of course.   Or we could also write this:

```
(lambda x : x)("rainbow")
```


But in lambda calculus, the syntax for calling a function is more lightweight.  In particular, we do not put parentheses around the argument to a function.  Instead, because calling functions is so common, we want to use the lightest weight syntax possible. And so that super lightweight syntax is just going to be put the function right next to its argument, like this:

```
(\x -> x) "rainbow"
```

In lambda calculus, another name for function call is function *application*.  We say that this is an application of the identity function to the argument "rainbow"

Here, I put parentheses around the identity function just to show where the body of the function ends.  The convention in lambda calculus is that the body of a function extends as far to the right as possible.  So if I had written

```
\x -> x "rainbow" -- Function that takes an arbitrary argument x and applies it to "rainbow"
```

then I would *not* be calling the identity function with the argument `"rainbow"`.  What *would* this be?  Anyone know?

It would be a function that takes an argument named `x`, and `x` had better itself be a function, because in the body of the function we're calling `x` with the argument `"rainbow"`.

So the syntax for calling functions in lambda calculus is incredibly lightweight. And this particular syntactic convention of just putting the function next to the argument is also something that's adopted by most functional programming languages, including Haskell, so it's a good idea to start getting used to it now.

Okay, so what if we wrote a function like this?


```
\f -> f (\x -> x)
```

What do you suppose this function does?  Any ideas?


It takes an argument, which I've called `f` here. I decided to name it `f` on purpose, for mnemonic reasons, because we want to think of that argument as itself being a function, right? It had better be a function. Why? Well, partly because in everything in lambda calculus is a function, but also because in the body of this function we're about to apply `f` to an argument, which happens to be the identity function.

Okay, so let's take the function I just wrote down, and apply *it* to the identity function.  I'll write the identity function as `\y -> y`.

```
(\f -> f (\x -> x)) (\y -> y)
```

How do we evaluate this function call?


The function we're calling is `\f -> f (\x -> x)`, and the argument to which it's being applied is `\y -> y`.  When you apply a function to an argument, you're going to plug in the argument in place of occurrences of the formal parameter, and what we end up with is the body of the function, but with occurrences of the formal parameter replaced with whatever the argument was.  So if we do one step of evaluation here, we plug in `\y -> y` for occurrences of `f` in the function we're calling, and what we end up with is

```
(\f -> f (\x -> x)) (\y -> y)
=> (\y -> y) (\x -> x)
```

I'm using this arrow `=>` to mean "steps to". It says we've done one step of evaluation.  We haven't formalized yet what this "steps to" arrow means; for now, I'm just trying to build your intuition for it.

We can now do another step of evaluation.  Now we have `\y -> y` applied to `\x -> x`, so we're just applying the identity function to the identity function.  And whenever we call the identity function with any argument, we get back exactly what we passed in.  So we're left with...the identity function, `\x -> x`.

```
(\f -> f (\x -> x)) (\y -> y)
=> (\y -> y) (\x -> x)
=> \x -> x
```

To help solidify your intuition for what it means for us to do a step of evaluation:
Think back to what I wrote before when I was calling the Python `identity` function we wrote down.  If we define `identity` like this:

```
def identity(y):
  return y
```

and then we call it like this:

```
identity("rainbow")
```

Then what does that evaluate to?  If you were to ask the Python REPL to evaluate that call to `identity`, what would it give you?

You'd just get the string `"rainbow"`, but how do you know that?

Well, you can look at the body of the function, and you see that it says `return y`, and you know that the thing that got plugged in for `y` is the string `"rainbow"`, so you'd better return the string `"rainbow"`.  Normally we don't think about it in that much detail, right, because we're so used to that happening that we don't necessarily go through those steps one by one. But if we want to be really precise about what a function call means, one way to think about it is to say that what we're actually doing is substituting the argument into the function body, in place of occurrences of the formal parameter.

Let's now formalize this idea that we're talking about informally.  Let's write down a rule that tells us how to substitute in arguments for occurrences of a formal parameter in the body of a function. Here's the rule:

```
(\x -> e1) e2 =b> e1[x := e2]
```

This is the substitution rule, which is also, for historical reasons, known as the beta rule. Here, `b` is the Greek letter beta. If you have a function, `\x -> e1`, where `x` is the function's formal parameter and `e1` is its body (and `e1` could be any expression), and you apply that function to some argument `e2`, which could also be any expression, then the beta rule says that that expression steps to `e1`, which was the body of the original function, *but* with any occurrences of `x` replaced with `e2`.  So this notation I've introduced here `e1[x := e2]` means "`e1`, but with occurrences of `x` replaced by `e2`".  Or another way to say that is "`e1`, but with `e2` substituted for occurrences of `x`".  That's what this notation means.

We could be more precise about what substitution means, and in a future lecture we're going to do just that.  But for now I'm appealing to your intuition about what it means to substitute something for something else.

And this notion of substitution is at the heart of what it means to do computation in lambda calculus.  All computation in lambda calculus is going to be carried about by means of the application of this beta rule over and over, as long as there are places that we can use it.

Let's do a couple examples, and let's use the beta rule to evaluate a few lambda calculus expressions.

A really simple example is just applying the identity function to itself:

```
(\z -> z) \y -> y
```

What do we get when we use the beta rule?  Well, our body `e1` in this case is `z`, and our formal parameter is `z`, and our argument is `\y -> y`.  So what we get is `z[z := \y -> y]`.  That is, we get `z` but with `\y -> y` substituted for occurrences of `z`.  Well, `z` but with `\y -> y` substituted for occurrences of `z` is just `\y -> y`, of course.  This is kind of a silly example: it's kind like I said "Oh, I'd like to order a taco, please, except with a burrito substituted for a taco."

Questions about this?

OK.  So, so far the only kinds of functions we've talked about are functions that take one argument.  And that seems kind of limiting, right?  Like in the long run, we want to be able to do things like, for example, add two numbers together.  (Of course, we don't actually have numbers yet, so to be able to add numbers, we're going to have to come up with a way to represent numbers using the only thing we do have, which is functions, and we'll talk about that next time.)  But assuming we did have a way to represent numbers as functions, which we will have soon, then how could we write a function that adds two numbers, given that the functions that we're talking about only take one argument?

It turns out that only taking one argument is not actually that much of a limitation.

Let's forget about numbers for a seciond; let's say that we would like to write a function that takes two arguments and returns the first one. How could we encode that using the tools that we have now?

What we could actually do is we could write a function that takes an argument `x`, and then returns a function that takes an argument `y` and then returns `x`:

```
\x -> (\y -> x)
```

So this is actually one of the more interesting functions that we've seen so far, isn't it? Because it's a function that actually does something different, depending on what argument you give it.

Pretending for a moment that we already have a way to encode numbers, let's apply this function to the number five:

```
(\x -> (\y -> x)) 5
```

Here I've put parentheses around the function being applied to `5`, just to disambiguate things, to make it clear that the `5` isn't part of the body of this function or something.  Now let's take a beta step:

```
(\x -> (\y -> x)) 5
=b> \y -> 5
```

And now there are no more beta steps we can take, so we're done.  So what is this `\y -> 5` thing?  It's a *constant* function, which means that no matter what you give it, it returns `5`.  The constant function that returns `5` is what we get when we apply `\x -> (\y -> x)` to `5`.  And so we can think of `\x -> (\y -> x)` as a *machine for making constant functions*.

We plugged in five, so we got back a constant function that returns five.  If we plugged in six, we would get back a constant function that returns six, and so on.

Okay, so returning to the question of whether we can have functions that take multiple arguments...








