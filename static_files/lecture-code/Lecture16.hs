-- Welcome to lecture 16!
import Text.Printf (printf)

{--

Agenda:

- Type classes!
  - Type class constrains in type signatures
  - Derived instances of type classes
  - Implementing our own instances of type classes
- More fun with ASTs

--}

{--
Type classes:

 - Let us specify what operations can be used on things of a certain type
 - Let us provide specific definitions of those operations for specific types when necessary

 In the signature of `(+)`:

 (+) :: Num a => a -> a -> a

 The `Num a` is a type class constraint on the type variable `a`

 We can call `(+)` on things of whatever type,
 *as long as* that type is an *instance of* the `Num` type class

--}

data Expr = Number Int 
          | Add Expr Expr
          | Sub Expr Expr
          | IfZero Expr Expr Expr
    deriving Show -- If we're deriving more than one thing for a type, put them in parens like this: (Show, Eq)

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
-- If `condition` evaluates to 0, then we want to evaluate `thenCase`,
-- otherwise we want to evaluate `elseCase`
-- Quiz question 2: implement the `IfZero` case of `eval`
eval (IfZero condition thenCase elseCase) | eval condition == 0 = eval thenCase
                                          | otherwise           = eval elseCase 
-- Alternative implementation of the `IfZero` case
-- eval (IfZero condition thenCase elseCase) = if eval condition == 0 then eval thenCase else eval elseCase

prettyPrint :: Expr -> String
prettyPrint (Number n) = printf "%d" n
prettyPrint (Add e1 e2) = printf "(%s + %s)" (prettyPrint e1) (prettyPrint e2)
prettyPrint (Sub e1 e2) = printf "(%s - %s)" (prettyPrint e1) (prettyPrint e2)
prettyPrint (IfZero c t e) = printf "if %s == 0 then %s else %s" (prettyPrint c) (prettyPrint t) (prettyPrint e)

-- Quiz question 1: How should we implement `(==)` for `Expr`s?
-- This is an instance of `Eq` for `Expr`
instance Eq Expr where
    (==) :: Expr -> Expr -> Bool
    (==) e1 e2 = eval e1 == eval e2

-- (IfZero (Sub (Number 2) (Number 2)) (Number 3) (Number 4))
-- "if0 (2 - 2) then 3 else 4"