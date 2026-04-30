-- Welcome to lecture 13!

{--

Agenda:

- More about tail calls (continuation-passing style!)
- Intro to abstract syntax trees (ASTs)

--}

-- Direct-style version
fact :: Int -> Int
fact 0 = 1
fact n = n * fact (n-1)

-- Tail-recursive version
-- Accumulator-passing style
factAcc :: Int -> Int
factAcc n = factAccHelper n 1
    where factAccHelper :: Int -> Int -> Int
          factAccHelper 0 acc = acc
          factAccHelper n acc = factAccHelper (n-1) (n * acc)

-- Continuation-passing-style version
-- A generalization of accumulator-passing style
-- The extra argument you pass around is a *function* that accumulates
-- the computation you want to do.
factCPS :: Int -> (Int -> Int) -> Int
factCPS 0 k = k 1
factCPS n k = factCPS (n-1) (\v -> k (n * v))

-- To call `factCPS`, we have to pass it a function to kick things off.
-- What should that function be?
-- The identity function!

{--
Visualization of a call to `factCPS 3 (\v -> v)`:

factCPS 3 (\v0 -> v0)
= factCPS 2 (\v1 -> (\v0 -> v0) (3 * v1))
= factCPS 1 (\v2 -> (\v1 -> (\v0 -> v0) (3 * v1)) (2 * v2))
= factCPS 0 (\v3 -> (\v2 -> (\v1 -> (\v0 -> v0) (3 * v1)) (2 * v2)) (1 * v3))
= (\v3 -> (\v2 -> (\v1 -> (\v0 -> v0) (3 * v1)) (2 * v2)) (1 * v3)) 1
= (\v2 -> (\v1 -> (\v0 -> v0) (3 * v1)) (2 * v2)) (1 * 1)
= (\v2 -> (\v1 -> (\v0 -> v0) (3 * v1)) (2 * v2)) 1
= (\v1 -> (\v0 -> v0) (3 * v1)) (2 * 1)
= (\v1 -> (\v0 -> v0) (3 * v1)) 2
= (\v0 -> v0) (3 * 2)
= (\v0 -> v0) 6
= 6

--}

-- What about this?  How would we write this in a tail-recursive way?
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)

-- The `fib` function in CPS!
-- All calls are tail calls. 

-- Every program can be converted to a tail-recursive program
-- by converting it to CPS.

-- Some compilers have an intermediate language that uses something called 
-- Static Single Assignment or SSA form.
-- SSA is very much like CPS!
-- Quiz question 1: What should the type of `fibCPS` be?
fibCPS :: Int -> (Int -> Int) -> Int
fibCPS 0 k = k 0
fibCPS 1 k = k 1
fibCPS n k = fibCPS (n-1) (\v1 -> fibCPS (n-2) (\v2 -> k (v1 + v2)))

-- A really simple PL!
-- All you can do is add and subtract numbers. 

-- Example programs:
-- 7
-- 3 + 4
-- 3 + (4 - 1)
-- (3 - 2) - (5 - 0)

-- Here are abstract syntax trees, or ASTs,
-- for the above programs:

-- Let's manually parse our strings into ASTs!
ast7 :: Expr
ast7 = Number 7

ast3plus4 :: Expr
ast3plus4 = Add (Number 3) (Number 4)

ast3plus4minus1 :: Expr
ast3plus4minus1 = Add (Number 3) (Sub (Number 4) (Number 1))

astBigExpr :: Expr
astBigExpr = Sub (Sub (Number 3) (Number 2)) (Sub (Number 5) (Number 0))

-- A tiny interpreter for our tiny language
eval :: Expr -> Int
eval (Number n) = n
eval (Add e1 e2) = eval e1 + eval e2
eval (Sub e1 e2) = eval e1 - eval e2

-- To refresh your memory on how a recursive data type is defined.
-- Not actually used in the definition of `Expr`.
data Tree = BinaryTree Int Tree Tree | Leaf Int | EmptyTree
    deriving Show

-- Let's write down a data type to represent these programs.
-- Quiz question 2: how should we define the Expr data type?
data Expr = Number Int | Add Expr Expr | Sub Expr Expr
    deriving Show