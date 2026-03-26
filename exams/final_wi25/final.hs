-- Haskell code for winter 2025 final
import Data.List ( (\\), nub )
import GHCi.Message (EvalExpr(EvalApp))
question5 = \q r s -> [q, r]

question6 = \q r s -> [q, r, r == s]
  
question7 = \x y -> (x, y, "batman", "catman", "wingman")

question8 = \y z -> map (\x -> "kona" ++ x) [y, z]

andList :: [Bool] -> Bool
andList []     = True
andList (x:xs) = x && andList xs

andList' :: [Bool] -> Bool
andList' l = foldr (&&) True l

andListTR :: [Bool] -> Bool
andListTR l = helper l True
  where helper :: [Bool] -> Bool -> Bool
        helper []     b = b
        helper (x:xs) b = helper xs (x && b)

andListTR' :: [Bool] -> Bool
andListTR' l = foldl (&&) True l

data Expr = Var String           -- Variable
          | Num Int              -- Integer literal
          | Let String Expr Expr -- let-expression: `let x = e1 in e2`
          | Add Expr Expr        -- Addition: `e1 + e2`
          | Lam String Expr      -- Function definition
          | App Expr Expr        -- Function call
  deriving (Show, Eq)

exampleAST :: Expr
exampleAST = Let "f" (Lam "x" (Add (Var "x") (Num 5))) (App (Var "f") (Num 8))

-- (let x = 4 in x + 5) + ((\x -> x) 7)
question10 :: Expr
question10 = Add (Let "x" (Num 4) (Add (Var "x") (Num 5)))
                 (App (Lam "x" (Var "x")) (Num 7))

depth :: Expr -> Int
depth (Var s) = 1
depth (Num n) = 1
depth (Let s e1 e2) = 1 + max (depth e1) (depth e2)
depth (Add e1 e2) = 1 + max (depth e1) (depth e2)
depth (Lam s e) = 1 + depth e
depth (App e1 e2) = 1 + max (depth e1) (depth e2)

freeVars :: Expr -> [String]
freeVars (Var s) = [s]
freeVars (Num _) = []
freeVars (Let s e1 e2) = nub (freeVars e1 ++ freeVars e2) \\ [s]
freeVars (Add e1 e2) = nub (freeVars e1 ++ freeVars e2)
freeVars (Lam s e) = freeVars e \\ [s]
freeVars (App e1 e2) = nub (freeVars e1 ++ freeVars e2)

{-
let f = \x -> x + y in
  let z = f 5 in
    z + y
-}
freeVarsTest1 :: Expr
freeVarsTest1 = Let "f" (Lam "x" (Add (Var "x") (Var "y"))) (Let "z" (App (Var "f") (Num 5)) (Add (Var "z") (Var "y")))
{-
let f = \x -> x + y in
  z + y
-}
freeVarsTest2 :: Expr
freeVarsTest2 = Let "f" (Lam "x" (Add (Var "x") (Var "y"))) (Add (Var "z") (Var "y"))

{-
x + y
-}
freeVarsTest3 :: Expr
freeVarsTest3 = Add (Var "x") (Var "y")

{-
\x -> \y -> x + y
-}
freeVarsTest4 :: Expr
freeVarsTest4 = Lam "x" (Lam "y" (Add (Var "x") (Var "y")))

{-
\y -> x + x
-}
freeVarsTest5 :: Expr
freeVarsTest5 = Lam "y" (Add (Var "x") (Var "x"))

{-
(let x = y in y) + y
-}
freeVarsTest6 :: Expr
freeVarsTest6 = Add (Let "x" (Var "y") (Var "y")) (Var "y")

{-
(let x = 5 in x) + (let x = 5 in x)
-}
freeVarsTest7 :: Expr
freeVarsTest7 = Add (Let "x" (Num 5) (Var "x")) (Let "x" (Num 5) (Var "x")) 

{-
(let x = 5 in x) + (let y = 5 in x)
-}
freeVarsTest8 :: Expr
freeVarsTest8 = Add (Let "x" (Num 5) (Var "x")) (Let "y" (Num 5) (Var "x")) 

{-
(let y = 5 in x) + (let y = 5 in x)
-}
freeVarsTest9 :: Expr
freeVarsTest9 = Add (Let "y" (Num 5) (Var "x")) (Let "y" (Num 5) (Var "x")) 

{-
\x -> 3 + ((\y -> y + 7) x)
-}
freeVarsTest10 :: Expr
freeVarsTest10 = Lam "x" (Add (Num 3) (App (Lam "y" (Add (Var "y") (Num 7))) (Var "x")))

{-
let f = \x -> x + f y in
  let z = f 5 in
    z + y
-}
freeVarsTest11 :: Expr
freeVarsTest11 = Let "f" (Lam "x" (Add (Var "x") (App (Var "f") (Var "y")))) (Let "z" (App (Var "f") (Num 5)) (Add (Var "z") (Var "y")))

freeVarsTests :: [(Expr, [String])]
freeVarsTests = [
  (freeVarsTest1, ["y"]),
  (freeVarsTest2, ["y", "z"]),
  (freeVarsTest3, ["x", "y"]),
  (freeVarsTest4, []),
  (freeVarsTest5, ["x"]),
  (freeVarsTest6, ["y"]),
  (freeVarsTest7, []),
  (freeVarsTest8, ["x"]),
  (freeVarsTest9, ["x"]),
  (freeVarsTest10, [])]

testFreeVars :: [Bool]
testFreeVars = map (\p -> freeVars (fst p) == snd p) (freeVarsTests ++ [(freeVarsTest11, ["y"])])

-- Alternative version of `freeVars` where recursive let bindings are *not* allowed. 
-- Only the `Let` case is different.
freeVars' :: Expr -> [String]
freeVars' (Var s) = [s]
freeVars' (Num _) = []
freeVars' (Let s e1 e2) = nub (freeVars' e1 ++ (freeVars' e2 \\ [s]))
freeVars' (Add e1 e2) = nub (freeVars' e1 ++ freeVars' e2)
freeVars' (Lam s e) = freeVars' e \\ [s]
freeVars' (App e1 e2) = nub (freeVars' e1 ++ freeVars' e2)



testFreeVars' :: [Bool]
testFreeVars' = map (\p -> freeVars' (fst p) == snd p) (freeVarsTests ++ [(freeVarsTest11, ["f", "y"])])

data Value = ValNum Int | ValClos String Expr ListEnv
  deriving Show

type ListEnv = [(String, Value)]

lookupInEnv :: ListEnv -> String -> Maybe Value
lookupInEnv [] k = Nothing
lookupInEnv ((k',v):env') k =
  if k == k' then Just v else lookupInEnv env' k

eval :: ListEnv -> Expr -> Maybe Value
eval _   (Num n) = Just (ValNum n)
eval env (Var x) = lookupInEnv env x
eval env (Add e1 e2) = case (eval env e1, eval env e2) of
    (Just (ValNum v1), Just (ValNum v2)) -> Just (ValNum (v1 + v2))
    _                                    -> Nothing
eval env (Lam s body) = Just (ValClos s body env)
eval env (Let s e1 e2) = case eval env e1 of
    Just v -> eval ((s,v):env) e2
    _      -> Nothing
eval env (App e1 e2) = case (eval env e1, eval env e2) of
    (Just (ValClos s body closEnv), Just argval) -> eval ((s,argval):closEnv) body
    _  -> Nothing
