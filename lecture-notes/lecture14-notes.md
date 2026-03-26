# CSE114A lecture 14

Agenda: 

- Expanding the repertoire of our interpreter
  - Function definitions!
  - Function applications!

So, homework 4 is out now.  It's a bigger assignment than what we've had, but you should be able to very quickly bang out part 1 and part 2 of the assignment using ideas that are already familiar to you from homework 3.

In fact, I think a good way to check how you're doing in the course is to see if you can just sit down and do parts 1 and 2 of the assignment without using any resources.  If you can, then that's a very good sign.

You should also be able to at least *start* part 3 of the assignment using what we discussed in the previous lecture.  My intention today is to give you most of the tools you need to do the rest.

OK, so recall from last time that we discussed `let`-epressions.  We might have an expression like this:

```
let x = 5 in
  x + 3
```

or in general,

`let <var> = <expr> in <body>`

By the way, `let`-expressions are just expressions, and can appear in any expression context.  So we could, for example, add two `let`-expressions.  What does this evaluate to?

```
(let x = 5 in x + 3) + (let x = 6 in x + 4)
```

Or this?

```
if (let x = 5 in x + 3) == 8 then (let x = 6 in x + 4) else (let x = 3 in x + 4)
```

The value of a `let`-expression is whatever the value of its body (`<body>`) is, but in an environment that's been *extended* with a new binding from the specified variable (`<var>`) to the value of the specified expression (`<expr>`).  Here, the value of 5 is just 5, of course.  So the value of this expression is the value of `x + 3`, in an environment where x is bound to 5.

We could have a more interesting one:

```
let x = 5 in
  let y = x + x in
    x + y
```

So the value of this expression is the value of its body, in an environment where x is bound to 5.  What is this expression's body?

It's this:

```
let y = x + x in
  x + y
```

And the value of *that* expression is the value of *its* body, which is `x + y`, in an environment where y is bound to the value of `x + x`.  How do we know what the value of `x + x` is?  Fortunately, we're in an environment where x is bound to 5, so the value of `x + x` is 10.

So we now need to determine the value of `x + y`, in an environment where x is bound to 5 and y is bound to 10.  So we get 15.

OK, all that's review.  Let's do something more interesting.

Suppose we had this program.  Take a minute to think about it.  What do you think it should evaluate to?

```
let f = \x -> x + x in
  let x = 5 in
    let f 3
```

This expression contains both a function definition and a function call, and we haven't talked about how to interpret either of those yet, but just intuitively, what do you think this expression should evaluate to?

(TODO: explain this code better)

```
-- AST Type
data Expr = Arith ArithOp Expr Expr
          | IfZero Expr Expr Expr
          | Leaf Int
          | Var String
          | Let String Expr Expr -- let <var> = <expr> in <body>
          | Lam String Expr -- function definitions
          | App Expr Expr -- function calls
  deriving (Show, Eq)

data ArithOp = Add | Sub | Mul
  deriving (Show, Eq)

data Value = VInt Int
           | VClos String Expr Env
  deriving (Show, Eq)


-- What an env might look like: [("x", VInt 3), ("y", VInt 4), ("f", VClos ...)]
type Env = [(String, Value)]

-- Our interpreter
interp :: Env -> Expr -> Maybe Value
interp _   (Leaf n) = Just (VInt n)
interp env (Var s) = lookup s env
interp env (Arith op e1 e2) = case (interp env e1, interp env e2) of
    (Just v1, Just v2) -> Just (applyOp op v1 v2)
    _                  -> Nothing 
  where applyOp :: ArithOp -> Value -> Value -> Value
        applyOp Add (VInt n1) (VInt n2) = VInt (n1 + n2)
        applyOp Sub (VInt n1) (VInt n2) = VInt (n1 - n2)
        applyOp Mul (VInt n1) (VInt n2) = VInt (n1 * n2)
        applyOp _   _         _         = error "type error!"
interp env (IfZero e1 e2 e3) = case interp env e1 of
    Just (VInt 0) -> interp env e2
    Just (VInt n) -> interp env e3
    _             -> Nothing
-- let <s> = <expr> in <body>    
interp env (Let s expr body) = case interp env expr of
    Just n  -> interp ((s,n):env) body
    Nothing -> Nothing
-- function definitions
interp env (Lam s body) = Just (VClos s body env)
-- function calls
interp env (App e1 e2)  = case (interp env e1, interp env e2) of
    (Just (VClos s body closureEnv), Just v) -> interp ((s,v):closureEnv) body
    (Just (VInt _), _)                       -> error "type error!"
    (_, _)                                   -> Nothing


data Test = Test Expr Env (Maybe Value)

tests :: [Test]
tests = [Test (Arith Add (Leaf 3) (Var "x")) [] Nothing, -- 3 + x
         -- 3 + x in an env where x=4
         Test (Arith Add (Leaf 3) (Var "x")) [("x", VInt 4)] (Just (VInt 7)),
         -- let x = 5 in x + 3
         Test (Let "x" (Leaf 5) (Arith Add (Var "x") (Leaf 3))) [] (Just (VInt 8)),
         -- let's do one that involves a function call!
         -- let x = 5 in let f = \y -> x + y in f 2
         Test (Let "x" (Leaf 5) (Let "f" (Lam "y" (Arith Add (Var "x") (Var "y"))) (App (Var "f") (Leaf 2)))) [] (Just (VInt 7))]

runTests :: [Bool]
runTests = map (\(Test expr env result) -> interp env expr == result) tests
```

So we have a recipe for how to evaluate function calls:

1. Evaluate the function expression, getting a *closure*.
2. Evaluate the argument expression, getting some kind of value.
3. Pull out the body of the closure from step (1) and evaluate it,
   in an extended environment where the formal parameter to the function
   is bound to the value of the argument from step (2)

Why extend the closure's environment (and not the "dynamic environment")?
The reason is: the closure's environment already contains 
all the variable bindings we need to evaluate the body of the function,
EXCEPT for the one being passed in as an argument
(which is what we're extending it with).

## Dynamic scope

To get a sense of what's subtly wrong with our interpreter, consider the program we tried to interpret last time and let's think about how it went wrong.
