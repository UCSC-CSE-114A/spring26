-- Haskell code for spring 2024 final

{-# LANGUAGE InstanceSigs #-}

-- question3 =
--   let f = \x -> x in
--     let y = f "sylveon" in
--       let z = f True in
--         [y, z]

question4 :: Bool -> [Bool]
question4 =
  \y -> (y : map (\x -> True) "charmander")

question5 :: String
question5 =
  foldr (\x y -> x ++ y) "" ["xatu", "mew", "pineco"]

question6 :: Eq a => a -> a -> (a, a, Bool)
question6 =
  \s t -> (s, t, s == t)


question7 :: [a] -> [Bool]
question7 = map (\x -> True)

-- question8 = map (==) ["pikachu", "togepi", ["fletchling", "charizard"]]

data Expr = EBool Bool | EInt Int | EVar Id | EBin BinOp Expr Expr 
          | ELam Id Expr | EApp Expr Expr | ELet Id Expr Expr
  deriving Show

data BinOp = And | Plus | Minus
  deriving Show

type Id = String

question10 :: Expr
question10 = ELet "f" (ELam "x" (EBin And (EBool True) (EBool False)))
                     (EApp (EVar "f") (EBin Plus (EInt 3) (EInt 4)))

question10a :: Expr
question10a = ELet "n" (EBool True)
                       (ELet "m" (ELam "x" (EBin And (EVar "n") (EVar "x")))
                                 (EApp (EVar "m") (EBool True)))

question10b :: Expr
question10b = EApp (ELam "x" (EApp (ELam "y" (EBin Plus (EVar "x") (EVar "y")))
                                   (EInt 3))) 
                   (EInt 4)

testExpr =
  let a = 3 in
    let f = \x -> x + a in
      let a = 5 in
        f a

testExprParsed :: Expr
testExprParsed =
  ELet "a" (EInt 3) 
           (ELet "f" (ELam "x" (EBin Plus (EVar "x") (EVar "a")))
                     (ELet "a" (EInt 5)
                               (EApp (EVar "f") (EVar "a"))))

data Val a = VClos a Id Expr | VBool Bool | VInt Int
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

eval :: Env a => a -> Expr -> Val a
eval _   (EBool b)       = VBool b
eval _   (EInt n)        = VInt n
eval env (EVar id)       = lookupInEnv id env
eval env (EBin op e1 e2) = binHelper op (eval env e1) (eval env e2)
eval env (ELam id e)     = VClos env id e
eval env (EApp e1 e2)    = appHelper (eval env e1) (eval env e2)
eval env (ELet id e1 e2) = eval extendedEnv e2
  where extendedEnv = extendEnv id (eval env e1) env

appHelper :: Env a => Val a -> Val a -> Val a
appHelper (VClos cEnv id e) argVal = eval (extendEnv id argVal cEnv) e
appHelper _                 _      = error "type error!"

binHelper :: Env a => BinOp -> Val a -> Val a -> Val a
binHelper And  (VBool b1) (VBool b2) = VBool (b1 && b2)
binHelper Plus (VInt n1)  (VInt n2)  = VInt (n1 + n2)
binHelper Minus (VInt n1) (VInt n2)  = VInt (n1 - n2)
binHelper _    _          _          = error "type error!"
