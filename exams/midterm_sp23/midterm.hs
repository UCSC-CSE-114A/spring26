-- Haskell code for spring 2023 midterm

{-# LANGUAGE InstanceSigs #-}

import Data.Char (toUpper)
import Data.List (nub, (\\), sort)

question4a = True : [False, True, False]

question4b = \x y -> "charizard"

question4c = foldr (++) "" ["mew", "lucario", "squirtle"]

question4d = \x -> if x then [x] else [False]

question4e = \x -> case x of
  Just s  -> s
  Nothing -> "Sorry, there's nothing here!"

question4f = map (\x y -> x) (foldr (++) [] [[True, False], [True]])

data LCExpr = Var String | Lam String LCExpr | App LCExpr LCExpr
  deriving Show

depth :: LCExpr -> Int
depth (Var id)    = 1
depth (Lam id e)  = 1 + depth e
depth (App e1 e2) = 1 + max (depth e1) (depth e2)

instance Eq LCExpr where
  (==) :: LCExpr -> LCExpr -> Bool
  (==) e1 e2 = depth e1 == depth e2

instance Ord LCExpr where
  (<=) :: LCExpr -> LCExpr -> Bool
  (<=) e1 e2 = depth e1 <= depth e2

question9 = map (\x -> map toUpper x) ["foo", "bar", "baz"] == [ [ toUpper c | c <- x ] | x <- ["foo", "bar", "baz"] ]

freeVars :: LCExpr -> [String]
freeVars (Var id)      = [id]
freeVars (Lam id expr) = freeVars expr \\ [id]
freeVars (App e1 e2)   = nub (freeVars e1 ++ freeVars e2)

sorted = sort [Var "z", App (Var "x") (Var "z"), Lam "y" (Var "y"), Var "x"]

question9_1 = freeVars (Var "x") == ["x"]
question9_2 = freeVars (Lam "y" (Var "y")) == []
question9_3 = freeVars (App (Var "f") (Var "x")) == ["f","x"]
question9_4 = freeVars (Lam "f" (Lam "y" (App (Var "g") (Var "y")))) == ["g"]
question9_5 = freeVars (App (Var "x") (Lam "x" (Var "x"))) == ["x"]
question9_6 = freeVars (App (Lam "x" (Var "y")) (Var "x")) == ["y","x"]
