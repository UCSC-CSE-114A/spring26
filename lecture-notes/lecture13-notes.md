# CSE114A lecture 13

Agenda: 

- Interpreter recap
- Expanding the repertoire of our interpreter: `let`-expressions

## Interpreter recap

So, up until now, we've written a lot of interpreters, but they're all rather simple.

We got as far as implementing support for variables, via environment passing.  That's an important step, but we're going to start taking it further, and hopefully by the end of next week, we'll have what you could really call a full-fledged programming language.

So, here's the interpreter we already have:

```
-- AST type
data Expr = Plus Expr Expr
               | Minus Expr Expr
               | Times Expr Expr
               | IfZero Expr Expr Expr
               | Number Int
               | Var String
  deriving Show

-- [("x", 3), ("y", 4)]
type Env = [(String, Int)]

-- Interpreter
interp :: Env -> Expr -> Maybe Int
interp _   (Number n) = Just n
interp env (Var s) = lookupInEnv s env
interp env (Plus e1 e2) = case (interp env e1, interp env e2) of
    (Just v1, Just v2) -> Just (v1 + v2)
    _                  -> Nothing 
interp env (Minus e1 e2) = case (interp env e1, interp env e2) of
    (Just v1, Just v2) -> Just (v1 - v2)
    _                  -> Nothing
interp env (Times e1 e2) = case (interp env e1, interp env e2) of
    (Just v1, Just v2) -> Just (v1 * v2)
    _                  -> Nothing
interp env (IfZero e1 e2 e3) = case interp env e1 of
    Just 0 -> interp env e2
    Just n -> interp env e3
    _      -> Nothing

```

Before we move on, let's just make the code a little less repetitive.  Notice that the cases for addition, subtraction, and multiplication are all basically the same.  So there's an opportunity to consolidate things there.  We can just define a type for those arithmetic operations.

```
data ArithOp = Add | Sub | Mul
  deriving Show
```

And then our `Plus`, `Minus`, and `Times` AST nodes can go away and be replaced by a single `Arith` AST node that has one field to represent what kind of arithmetic operation it is, like this:

```
data Expr = Arith ArithOp Expr Expr
          | IfZero Expr Expr Expr
          | Number Int
          | Var String
  deriving Show
```


And then let's just use that in our interpreter.

```
interp :: Env -> Expr -> Maybe Int
interp _   (Number n) = Just n
interp env (Var s) = lookup s env
interp env (Arith op e1 e2) = case (interp env e1, interp env e2) of
    (Just v1, Just v2) -> Just (applyOp op v1 v2)
    _                  -> Nothing
  where applyOp :: ArithOp -> Int -> Int -> Int
        applyOp Add n1 n2 = n1 + n2
        applyOp Sub n1 n2 = n1 - n2
        applyOp Mul n1 n2 = n1 * n2
interp env (IfZero e1 e2 e3) = case interp env e1 of
    Just 0 -> interp env e2
    Just n -> interp env e3
    _      -> Nothing
```

We could test this manually, but let's just write a little bit of test infrastructure.

```
data Test = Test Expr Env (Maybe Int)

tests :: [Test]
tests = [
    Test (Arith Add (Number 3) (Number 4)) [] (Just 7),
    Test (Arith Sub (Number 3) (Number 4)) [] (Just (-1))]

runTests :: [Test] -> [Bool]
runTests [] = []
runTests ((Test expr env val):rest) = (interp env expr == val) : runTests rest
```

We could actually just write `runTests` using `map`!

```
runTests :: [Test] -> [Bool]
runTests = map (\(Test expr env val) -> interp env expr == val)
```

OK, so now we can run all our tests by just calling `runTests tests` in GHCi.

Cool, they pass.  Moving on!

## `let`-expressions

So you may or may not have encountered `let`-expressions yet in Haskell, so *let* us discuss `let`-expressions.  We're going to add them to the language that our interpreter supports, but first we want to know what they are.

So a `let`-expression is a way to introduce a new variable and give it a scope.

For example, if I write 

```
let x = 5 in 
  x + 3
```

So in general, the anatomy of a `let`-expression is

```
let <var> = <expr> in <body>
```

Every `let` expression binds at least one variable to an expression, and has a body.  The body is itself an expression, and the variable can be used in the body.

In Haskell, if you want to, you can introduce multiple bindings in a `let`-expression and then use all of them in the body:

```
letExample' :: Int
letExample' = let x = 5
                  y = 4
                in x + y
```

And bindings can even refer to each other:

```
letExample'' :: Int
letExample'' = let x = 5
                   y = x + x
			     in x + y
```

What should this expression evaluate to?

We're not going to actually handle `let`-expressions with multiple bindings like this in our own interpreter, though.  But that's not a huge limitation, because instead, we could just write this:

```
letExample''' :: Int
letExample''' = let x = 5 in
                  let y = x + x in
				    x + y
```

So here I have *nested* `let`s, which is completely fine to do.  A `let`-expression is just an expression, which means it can appear anyplace an expression can appear, even in the body of another `let`-expression!

That brings us to the question of how to *evaluate* a `let`-expression.

Suppose I have this `let`-expression:

```
let <var> = <expr> in <body>
```

What do you think the *value* of this expression should be?

(As a concrete example, keep in mind that the value of this expression is 8.)

```
let x = 5 in x + 3
```

OK, with that hint in mind:  The *value* of 

```
let <var> = <expr> in <body> 
```

should be

 - whatever the value of `<body>` is...
 - ...in an environment in which `<var>` is bound to the value of `<expr>`
 
 So to evaluate a `let`-expression, we're going to need to:
 
 - determine the value that the variable should be bound to, by evaluating `<expr>`
 - add a binding of `<var> `to the value of `<expr>` to the environment we have
 - and finally, evaluate `<body>` in that *extended* environment
 
Here we're just using lists as our environments, so when we need to extend an environment, we can do so by just consing a new tuple on to the front of it.  On homework 3 you're doing it in a nice representation-independent way.  But here, we're just keeping it simple and we're using lists as our environment representation.

OK.  So, let's add `let`-expressions to our language.  We'll need to update both our AST type and our interpreter.

Since a `let`-expression has a variable and two subexpressions, I've decided to represent it as a product of a `String` (representing the variable name), an `Expr` (representing the expression that the variable's bound to), and another `Expr` (representing the body).

Now we just neet to add a `Let` case to our interpreter, and we're in good shape.

There are different ways to go about this, but let's do it in the same style that we did some of the other cases:

```
interp env (Let s expr body) = case interp env expr of
    Just n -> interp ((s,n):env) body
    _      -> Nothing
```

OK!  So now we should be able to write that `let`-expression that we wrote in Haskell earlier, but now as an AST in our own language that we're in the process of implementing:

```
ghci> let x = 5 in x + 3
8
ghci> interp [] (Let "x" (Number 5) (Arith Add (Var "x") (Number 3)))
Just 8
```

Cool, it works.  What about the nested `let`-expression that we did after that?

```
ghci> let x = 5 in let y = x + x in x + y
15
ghci> interp [] (Let "x" (Number 5) (Let "y" (Arith Add (Var "x") (Var "x")) (Arith Add (Var "x") (Var "y"))))
Just 15
```

It works!

