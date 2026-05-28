-- Welcome to lecture 20!

{--
Agenda:

- Fixing the bug in our interpreter from last time:
  - Closures! (Some code (like a function body), together with an environment)

--}

-- Quiz question 1: what should this evaluate to (in Haskell)?
{--
let y = 5 in 
  let f = \x -> x + y in -- This occurrence of y is bound to 5
    let y = 6 in
      f y -- This occurrence of y is bound to 6
--}

{--
What does our interpreter do with this?

Expression:
```
let y = 5 in 
  let f = \x -> x + y in
    let y = 6 in
      f y
```
Environment: []

Expression:
```
  let f = \x -> x + y in
    let y = 6 in
      f y
```
Environment: [("y", VInt 5)]

Expression:
```
    let y = 6 in
      f y
```
Environment: [("f", VFunc "x" (Arith (Add (Var "x") (Var "y")))), ("y", VInt 5)]

```
      f y
```
Environment: [("y", VInt 6), ("f", VFunc "x" (Arith (Add (Var "x") (Var "y")))), ("y", VInt 5)]

Remember the beta rule: (\x -> e1) e2 => e1[x := e2]

Expression:
```
(Arith (Add (Var "x") (Var "y"))
or, if you want:
x + y
```
Environment:
[("x", VInt 6), ("y", VInt 6), ("f", VFunc "x" (Arith (Add (Var "x") (Var "y")))), ("y", VInt 5)]

In this environment, the value of `x + y` is 12! Oh, no!

In *dynamic scope*, we evaluate the body of a function
using the environment present at the place the function is *called*.

Using *static scope*, we evaluate the body of a function
using the environment present at the place the function is *defined*.
--}

-- Expr AST
data Expr = Number Int 
          | Str String
          | Arith ArithOp Expr Expr
          | Var String
          | IfZero Expr Expr Expr
          | Let String Expr Expr -- let x = e1 in e2
          | Lam String Expr -- function definitions: \x -> e
          | App Expr Expr -- function calls: e1 e2
  deriving Show

-- A type alias for environments
type Env = [(String, Value)]

letExample' :: Int
letExample' = let x = 5 in
                let y = x + x in
                  x + y

-- What if we had this program?
letExample'' :: Int
letExample'' = let f = \x -> x + x in
                 let x = 5 in
                   f 3
-- \x -> x + x
expr :: Expr
expr = Lam "x" (Arith Add (Var "x") (Var "x"))

-- ArithOp now includes something that's not an ArithOp...oh well
data ArithOp = Add | Sub | Mul | Append
  deriving Show

-- Define a type for the things that our interpreter
-- can return (aka the things that programs can evaluate to)
data Value = VInt Int | VStr String | VFunc String Expr Env -- A closure!
  deriving Show

eval :: Expr -> Env -> Value
eval (Number n) _ = VInt n
eval (Str s) _ = VStr s
eval (Var s) env = lookupInEnv env s  
eval (Arith op e1 e2) env = applyOp op (eval e1 env) (eval e2 env)
eval (IfZero condition thenExpr elseExpr) env = case eval condition env of
  (VInt 0) -> eval thenExpr env
  (VInt _) -> eval elseExpr env
  _ -> error "you tried to call `if` on a function or a string, you joker"

eval (Let s expr bodyExpr) env = let val = eval expr env in
                                   eval bodyExpr ((s, val):env)
-- Quiz question 1: what goes on the right side of this equation?
eval (Lam s expr) env = VFunc s expr env
eval (App expr1 expr2) env = case (eval expr1 env, eval expr2 env) of
  (VInt _, _) -> error "you tried to apply a number like it was a function."
  (VStr _, _) -> error "you tried to apply a string like it was a function."
  (VFunc s bodyExpr savedEnv, argVal) -> eval bodyExpr ((s,argVal):savedEnv) -- Quiz question 2: What env do I put here?

{--
Our recipe for evaluating function calls:
1. Evaluate function expression, getting a value (hopefully) constructed with `VFunc`
2. Evaluate argument expression, getting a value (hopefully)
3. Pull out the function body from the `VFunc` we got from step (1),
   and evaluate it in an extended environment, where the formal parameter to the function
   is bound to the value of the argument we got from step (2)
--}

applyOp :: ArithOp -> Value -> Value -> Value
applyOp Add (VInt n1) (VInt n2) = VInt (n1 + n2)
applyOp Sub (VInt n1) (VInt n2) = VInt (n1 - n2)
applyOp Mul (VInt n1) (VInt n2) = VInt (n1 * n2)
applyOp Append (VStr s1) (VStr s2) = VStr (s1 ++ s2)
applyOp _   _         _         = error "you tried to do arithmetic on functions or append non-strings, you fool"

lookupInEnv :: Env -> String -> Value
lookupInEnv [] _ = error "There was an unbound variable!"
lookupInEnv ((s, v):xs) str = if s == str then v else lookupInEnv xs str

example =
    let message = " is cute" in
      let f = \s -> s ++ message in
        let message = " is smelly" in
         f "nico"

{--
Quiz question 2:

What would this evaluate to under dynamic scope and under static scope?
(Answer: 9 and 10)

let x = 4 in
  let f = \y -> y + x in
    let x = 5 in
      f x

--}