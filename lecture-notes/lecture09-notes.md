# CSE114A lecture 9

Agenda:

- What's coming up
- More about tail calls
- More fun with ASTs
  - An interpreter for our ArithExpr language
  - Adding features to our ArithExpr language
  - An AST type for lambda calculus
  
# What's coming up

If you have finished assignment 2, you can add your favorite procedurally generated art to the art gallery topic on Zulip.  One thing to pay attention to, as you're finishing and submitting assignment 2 -- the autograder does actually generate images from the favorites you specify in the file, and it has a 10-minute timeout. So if you have some images that take a while to generate -- which can happen if you choose a particularly deep depth -- you can run into issues with the autograder timing out.  If that happens, then I suggest choosing a less deep depth.  Sorry that these practical considerations have to stand in the way of your artistic genius.

# More about tail calls

So today we're going to continue our discussion of tail recursion.  There was a question on Zulip about how to write a tail-recursive function when you have two recursive calls, and that's an interesting question, so let's dig into it a little bit.

Recall that the way we've been implementing tail-recursive functions so far is by passing an accumulator argument.

So, for instance, suppose we have the factorial function:

```
fact :: Int -> Int
fact 0 = 1
fact n = n * fact (n - 1)
```

This is not tail-recursive.  Why?

Because that "n times" is hanging around on the outside of the recursive call to `fact`.  We can rewrite it in a tail-recursive way by using an accumulator argument:

```
factAcc :: Int -> Int
factAcc n = helper n 1
    where helper 0 acc = acc
          helper n acc = helper (n - 1) (n * acc)
```

So this is the kind of thing you've been doing on assignment 2.  However, this particular trick doesn't always work.

What if we have a function that makes two recursive calls.  Like, say we want to compute Fibonacci numbers?

```
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)
```

First let's check if we have it right. This is a list comprehension in Haskell.


```
ghci> [fib n | n <- [1..10]]
[1,1,2,3,5,8,13,21,34,55]
```

I think that's the first 10 numbers in the Fibonacci sequence, isn't it?

OK.  So how would we write this in a tail-recursive way?

```
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)
```

That's a stumper.  You can't really do it using accumulator-passing style.

What people came up with in the 1970s is a way to do this using what they call *continuation-passing style*, or CPS.

We will write the Fibonacci function in CPS, but as a warm-up, let's first try converting the factorial function to CPS.

As a reminder, here it is in direct style:

```
fact :: Int -> Int
fact 0 = 1
fact n = n * fact (n - 1)
```

And here it is in accumulator-passing style:

```
factAcc :: Int -> Int -> Int
factAcc 0 acc = acc
factAcc n acc = factAcc (n - 1) (n * acc)
```

So, in accumulator-passing style you pass around an extra data structure (be it a number, or a list, or whatever) that accumulates the result you want to return.

In continuation-passing style, you pass around an extra *function* that accumulates the *computation you want to do*.  This computation is known as a "continuation", hence the name.

Let's see how that looks.

```
factCPS :: Int -> (Int -> Int) -> Int
factCPS 0 k = k 1
factCPS n k = factCPS (n - 1) (\v -> k (n * v))
```

Traditionally, the continuation is named `k`.  (You can name it whatever you want, I'm just picking a traditional name for it.)

In the base case, you pass whatever it is you want to return to the continuation `k`.

And in the recursive case, you construct a new continuation that calls the old continuation.

And then to *call* this function, you just call it with the identity function to start out with.

```
ghci> factCPS 3 (\v -> v)
6
```

This is all a bit mysterious, so let's try to visualize what happens when this call to factCPS is evaluated.

(It'll be easier to read if we use names other than just `v`, so let's alpha-rename to something else for each step.)

```
factCPS 3 (\v0 -> v0)
= factCPS 2 (\v1 -> (\v0 -> v0) (v1 * 3))
= factCPS 1 (\v2 -> (\v1 -> (\v0 -> v0) (v1 * 3)) (v2 * 2))
= factCPS 0 (\v3 -> (\v2 -> (\v1 -> (\v0 -> v0) (v1 * 3)) (v2 * 2)) (v3 * 1))
= (\v3 -> (\v2 -> (\v1 -> (\v0 -> v0) (v1 * 3)) (v2 * 2)) (v3 * 1)) 1
```

So we can see that what happens is that instead of accumulating a result, instead we accumulate this big lambda expression that then we can reduce to get a value.

I could actually evaluate it right now in GHCi and get 6.  But we can also step through it manually, taking beta steps, to convince ourselves that it's right.

```
(\v2 -> (\v1 -> (\v0 -> v0) (v1 * 3)) (v2 * 2)) (1 * 1)
(\v2 -> (\v1 -> (\v0 -> v0) (v1 * 3)) (v2 * 2)) 1
(\v1 -> (\v0 -> v0) (v1 * 3)) (1 * 2)
(\v1 -> (\v0 -> v0) (v1 * 3)) 2
(\v0 -> v0) (2 * 3)
(\v0 -> v0) 6
6
```

So we got on this topic, though, because we wanted to know how to deal with functions that make multiple recursive calls, like the `fib` function:

```
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)
```

So just real quick, and I'm not going to go into any detail on this, here's the fib function written tail-recursively, using continuation-passing style.

```
fibCPS :: Int -> (Int -> Int) -> Int
fibCPS 0 k = k 0
fibCPS 1 k = k 1
fibCPS n k = fibCPS (n - 1) (\v1 -> fibCPS (n - 2) (\v2 -> k (v1 + v2)))
```

OK, so why are we talking about this? Do I actually recommend you write code in this style? No.

However, an interesting thing about CPS is that it's possible for a compiler to automatically convert programs to continuation-passing style.  In CPS, all calls are tail calls, so then that code can be efficiently executed.  We're not going to talk about how to implement automatic CPS conversion, but it's something useful to be aware of.

In general, continuations are a beautiful and deep topic and there's lots to be said about them, and all we've done here is scratch the surface.  So that's something to maybe read up on on your own if you're interested.  But all I really want you to know is that every program can be converted to a tail-recursive program by converting it to CPS, and that transformation is something that compilers can do automatically.  And there are various other compiler transformations that are close cousins of the CPS transformation, and if you're interested in that, you should take compilers!

## More fun with ASTs

OK.  A couple lectures ago we left off having written down this type of abstract syntax trees for our tiny language of arithmetic expressions.

```
data Expr = Number Int 
          | Sum Expr Expr
          | Diff Expr Expr
          | Prod Expr Expr
          | IfZero Expr Expr Expr
  deriving Show
```

And we wrote a tiny interpreter for it:

```
interp :: Expr -> Int
interp (Number n) = n
interp (Sum e1 e2) = interp e1 + interp e2
interp (Diff e1 e2) = interp e1 - interp e2
interp (Prod e1 e2) = interp e1 * interp e2
interp (IfZero e1 e2 e3) = if interp e1 == 0 then interp e2 else interp e3
```

Now we can write a little pretty-printer for our code also.  If you did section worksheet 4, or if you've done the second half of assignment 2 yet, you've already encountered pretty-printing.

You can use printf:
````
import Text.Printf (printf)
```

```
prettyPrint :: Expr -> String
prettyPrint (Number n) = printf "%d" n 
prettyPrint (Sum e1 e2) = printf "(%s+%s)" (prettyPrint e1) (prettyPrint e2)
prettyPrint (Diff e1 e2) = printf "(%s-%s)" (prettyPrint e1) (prettyPrint e2)
prettyPrint (Prod e1 e2) = printf "(%s*%s)" (prettyPrint e1) (prettyPrint e2)
prettyPrint (IfZero e1 e2 e3) = printf "if0 %s then %s else %s" (prettyPrint e1) (prettyPrint e2) (prettyPrint e3) -- or it could be "if %s == 0 then %s else %s"
```

## An AST type for lambda calculus

Well, this is all pretty boring so far.  The language we're dealing with isn't even Turing-complete.  What if we did a Turing-complete language?  How about lambda calculus?

What would our AST need to look like?

```
data LCExpr = LCVar String | LCLam String LCExpr | LCApp LCExpr LCExpr
```

We're not quite equipped to write a lambda calculus interpreter yet; we'll get there, but not today.  But in the meantime, maybe one interesting thing we could do with our `LCExpr`s, other than interpret them, is at least do some simple analysis of lambda calculus programs.  For example, in a much earlier lecture, we wrote, on paper, how to compute the free variables of a lambda calculus expression.  Let's pull that up and then translate it to code.

```
import Data.Set
```

```
freeVars :: LCExpr -> Set String
freeVars (LCVar s) = singleton s
freeVars (LCLam s e) = freeVars e `difference` singleton s
freeVars (LCApp e1 e2) = freeVars e1 `union` freeVars e2
```


