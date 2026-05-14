-- Welcome to lecture 19!

{--

Agenda:

- Further expanding the repertoire of our interpreter:
  - Function definitions!
  - Function applications!

--}

-- Our AST type
data Expr = Number Int 
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

data ArithOp = Add | Sub | Mul
  deriving Show

-- Define a type for the things that our interpreter
-- can return (aka the things that programs can evaluate to)
data Value = VInt Int | VFunc String Expr -- note: this is subtly wrong!
  deriving Show

-- There's a subtle problem with this interpreter; can you figure out what it is?
eval :: Expr -> Env -> Value
eval (Number n) _ = VInt n
eval (Var s) env = lookupInEnv env s  
eval (Arith op e1 e2) env = applyOp op (eval e1 env) (eval e2 env)
eval (IfZero condition thenExpr elseExpr) env = case eval condition env of
  (VInt 0) -> eval thenExpr env
  (VInt _) -> eval elseExpr env
  _ -> error "you tried to call `if` on a function, you joker"

eval (Let s expr bodyExpr) env = let val = eval expr env in
                                   eval bodyExpr ((s, val):env)
-- Quiz question 1: what goes on the right side of this equation?
eval (Lam s expr) env = VFunc s expr -- It's a little sus that we don't use `env`, is it not?
eval (App expr1 expr2) env = case (eval expr1 env, eval expr2 env) of
  (VInt _, _) -> error "you tried to apply a number like it was a function."
  (VFunc s bodyExpr, argVal) -> eval bodyExpr ((s,argVal):env) -- Quiz question 2: What env do I put here?

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
applyOp _   _         _         = error "you tried to do arithmetic on functions, you fool"

lookupInEnv :: Env -> String -> Value
lookupInEnv [] _ = error "There was an unbound variable!"
lookupInEnv ((s, v):xs) str = if s == str then v else lookupInEnv xs str