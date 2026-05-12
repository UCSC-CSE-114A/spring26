-- Welcome to lecture 18!

{--

Agenda:

- Expanding the repertoire of our interpreter:
  - variables
  - let-expressions

--}

letExample :: Int
letExample = let x = 5
                 y = x + x
               in x + y

-- We could also have nested let-expressions:
letExample' :: Int
letExample' = let x = 5 in
                let y = x + x in
                  x + y

{--
A let-expression is a way to introduce a new variable and give it a scope.

let x = 5 in
  x + 3

The value of a let-expression
`let <var> = <expr> in <body>`
should be
- Whatever the value of <body> is...
- ...in an environment in which `<var>` in bound to to the value of `<expr>`

To evaluate a let-expression, then, we'll have to:
- figure out what <var> should be bound to, by evaluating <expr>
- add a new binding of <var> to the value of <expr> in the environment we have
- finally, evaluate <body> in that *extended* environment

--}
 
data Expr = Number Int 
          | Arith ArithOp Expr Expr
          | Var String
          | IfZero Expr Expr Expr
          | Let String Expr Expr
  deriving Show

-- A type alias for environments
type Env = [(String, Int)]

data ArithOp = Add | Sub | Mul
  deriving Show

-- Quiz question 1:
-- What should the type of `applyOp` be?
applyOp :: ArithOp -> Int -> Int -> Int
applyOp Add n1 n2 = n1 + n2
applyOp Sub n1 n2 = n1 - n2
applyOp Mul n1 n2 = n1 * n2

-- A tiny interpreter for our tiny language
-- We need an environment to tell us what the values of variables are.
-- It can be a list of pairs that maps variable names to their values.
eval :: Expr -> Env -> Int
eval (Number n) _ = n
eval (Var s) env = lookupInEnv env s  
eval (Arith op e1 e2) env = applyOp op (eval e1 env) (eval e2 env)
eval (IfZero condition thenCase elseCase) env | eval condition env == 0 = eval thenCase env
                                              | otherwise               = eval elseCase env
-- To evaluate a let-expression, then, we'll have to:
-- - figure out what <var> should be bound to, by evaluating <expr>
-- - add a new binding of <var> to the value of <expr> in the environment we have
-- - finally, evaluate <body> in that *extended* environment
-- Quiz question 2: How should we evaluate `(Let s expr bodyExpr)`?
eval (Let s expr bodyExpr) env = let val = eval expr env in
                                   eval bodyExpr ((s, val):env)

lookupInEnv :: Env -> String -> Int
lookupInEnv [] _ = error "There was an unbound variable!"
lookupInEnv ((s, v):xs) str = if s == str then v else lookupInEnv xs str

ast7 :: Expr
ast7 = Number 7

ast3plus4 :: Expr
ast3plus4 = Arith Add (Number 3) (Number 4)

ast3plus4minus1 :: Expr
ast3plus4minus1 = Arith Add (Number 3) (Arith Sub (Number 4) (Number 1))

astBigExpr :: Expr
astBigExpr = Arith Sub (Arith Sub (Number 3) (Number 2)) (Arith Sub (Number 5) (Number 0))