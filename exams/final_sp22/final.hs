{-# LANGUAGE InstanceSigs #-}

import Data.List

exam6 =
  let f = foldl (.) (\x -> x) in
    let g = f [(\x -> x - 1), (\x -> x - 2)] in
      g 2

exam7 =
  let l = filter (\n -> n <= 3) [1, 2, 3, 4] in
    case l of
      []     -> (\y -> True)
      (x:xs) -> (\y -> False)

naiveLength :: [a] -> Int
naiveLength []     = 0
naiveLength (x:xs) = 1 + naiveLength xs

lengthTR :: [a] -> Int
lengthTR l = helper l 0
  where helper []     n = n
        helper (x:xs) n = helper xs (n + 1)

# Alternate solution
lengthTR' :: [a] -> Int
lengthTR' l = foldl (\x _ -> x + 1) 0 l

type Id = String

data LExpr =
    Var Id
  | Lam Id LExpr
  | App LExpr LExpr
  deriving Show

-- >>> occurs "x" (Var "x")
-- True
-- >>> occurs "y" (Lam "y" (Var "y"))
-- True
-- >>> occurs "y" (App (Var "f") (Var "x"))
-- False
-- >>> occurs "g" (Lam "f" (Lam "y" (App (Var "g") (Var "y"))))
-- True
-- >>> occurs "x" (Lam "x" (Var "y"))
-- False
occurs :: Id -> LExpr -> Bool
occurs id1 (Var id2)      = id1 == id2
occurs id1 (Lam id2 expr) = occurs id1 expr
occurs id1 (App e1 e2)    = occurs id1 e1 || occurs id1 e2

-- >>> freeVars (Var "x")
-- ["x"]
-- >>> freeVars (App (Var "f") (Var "x"))
-- ["f","x"]
-- >>> freeVars (Lam "f" (Lam "x" (App (Var "f") (Var "x"))))
-- []
-- >>> freeVars (ELet "f" (Lam "x" (Var "y")) (ELet "y" (EInt 5) (App (Var "f") (EInt 1)))) 
-- ["y"]
-- >>> freeVars (ELet "f" (Lam "x" (Var "x")) (ELet "y" (EInt 5) (App (Var "f") (EInt 1))))
-- []
-- >>> freeVars (App (Var "y") (Var "y"))
-- ["y"]

freeVars :: LExpr -> [Id]
freeVars (Var id)       = [id]
freeVars (Lam id expr)  = freeVars expr \\ [id]
freeVars (App e1 e2)    = nub (freeVars e1 ++ freeVars e2)

exam12 =
  let a = 1 in
    let b = 2 in
      let f = \x y -> x + y + a + b in
        let a = 3 in
          let b = 4 in
            f a b

-- exam13 =
--   let a = 1 in
--     let b = 2 in
--       let f = \x -> x + a + b + c in
--         let a = 3 in
--           let c = 4 in
--             f a

data Expr =
    EInt Int
  | EVar Id
  | ELam Id Expr
  | EApp Expr Expr
  | ELet Id Expr Expr
  deriving Show

data Val a =
    VClos a Id Expr
  | VInt Int
  deriving Show

class Env a where
  emptyEnv :: a
  extendEnv :: Id -> Val a -> a -> a
  lookupInEnv :: Id -> a -> Val a

data ListEnv = ListEnv [(Id, Val ListEnv)]
  deriving Show

instance Env ListEnv where
  emptyEnv :: ListEnv
  emptyEnv = ListEnv []

  extendEnv :: Id -> Val ListEnv -> ListEnv -> ListEnv
  extendEnv id val (ListEnv env) =
    ListEnv ((id, val) : env)

  lookupInEnv :: Id -> ListEnv -> Val ListEnv
  lookupInEnv id (ListEnv []) =
    error ("unbound variable: " ++ id)
  lookupInEnv id (ListEnv ((x,v):xs))
    | id == x   = v
    | otherwise = lookupInEnv id (ListEnv xs)

data FunEnv = FunEnv (Id -> Val FunEnv)

instance Show FunEnv where
  show _ = "<env>"

instance Env FunEnv where
  emptyEnv :: FunEnv
  emptyEnv =
    FunEnv (\x -> error ("unbound variable: " ++ x))

  extendEnv :: Id -> Val FunEnv -> FunEnv -> FunEnv
  extendEnv id val (FunEnv f) =
    FunEnv (\x -> if x == id then val else f x)

  lookupInEnv :: Id -> FunEnv -> Val FunEnv
  lookupInEnv id (FunEnv f) = f id

-- >>> eval (emptyEnv :: FunEnv) (ELet "f" (Lam "x" (Var "y") (ELet "y" (EInt 5) (App (Var "f") (EInt 1))))
--

--- >>> eval emptyEnv (ELet "f" (Lam "x" (Var "y")) (ELet "y" (EInt 5) (App (Var "f") (EInt 1))))

eval :: Env a => a -> Expr -> Val a
eval _   (EInt n)     = VInt n
eval env (EVar id)    = lookupInEnv id env
eval env (ELam id e)  = VClos env id e
eval env (EApp e1 e2) = case eval env e1 of
  (VClos cEnv cId cExpr) -> eval env' cExpr
    where env' = extendEnv cId v2 cEnv
          v2   = eval env e2
  _ -> error "type error!"
eval env (ELet id e1 e2) = eval env (EApp (ELam id e2) e1)

{-

let f = \x -> y in
  let y = 5 in
    f 1

-}

