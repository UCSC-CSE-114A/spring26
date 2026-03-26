-- Haskell code for spring 2023 final

{-# LANGUAGE InstanceSigs #-}

question5a =
  \x -> [True, False, x]

question5b =
  map (\x -> if x then "xatu" else "mew") [True, False]

question5c =
  map (\x -> if x then "vaporeon" else "espeon")

question5d =
  \x -> case x of
          Just val -> (val, x)
          Nothing  -> ("cramorant", x)

question5e =
  \x -> case x of
          Just val -> val
          Nothing  -> ["dodrio", "delphox", "dragonite"]

-- question 6
foo :: b -> (a -> b) -> Maybe a -> b
foo n _ Nothing  = n
foo _ f a = f a

-- alternative q6 answer
foo' :: b -> (a -> b) -> Maybe a -> b
foo' n f v = case v of
  Nothing -> n
  Just x  -> f x

foo'' :: b -> (a -> b) -> Maybe a -> b
foo'' n f v | v == Just x  = f x
            | v == Nothing = n


question7a = map (\x -> []) "lucario"
question7b = foldl (++) "pikachu" []
question7c = foldl (++) "" []
question7d = foldl (\x y -> x) [] ["ninetales"]
question7e = foldl (\x y -> "aipom") "" [1, 2, 3]

question8a = [ if x == 3 then False else True | x <- [1, 2, 3] ]
question8b = [ (\y -> if y then False else True) x | x <- [True, False] ]
--question8c = [ if x then False else True | x <- [1, 2, 3] ]
question8d = [ (\y -> if y == 3 then False else True) 3 | x <- [True] ]

data Expr = ENum Int
          | EVar Id
          | EPlus Expr Expr
          | ELam Id Expr
          | EApp Expr Expr
          | ELet Id Expr Expr

type Id = String

data Value = VNum Int | VClos Env Id Expr

type Env = [(Id, Value)]

lookupInEnv :: Id -> Env -> Value
lookupInEnv id []     = error "unbound variable"
lookupInEnv id ((x,val):xs) = if id == x
                                then val
                                else lookupInEnv id xs

extendEnv :: Id -> Value -> Env -> Env
extendEnv id val env = (id, val) : env

eval :: Env -> Expr -> Value
eval env (ENum n)       = VNum n
eval env (EVar s)       = lookupInEnv s env
eval env (EPlus e1 e2)  = case (eval env e1, eval env e2) of
  (VNum n1, VNum n2) -> VNum (n1 + n2)
  _                  -> error "type error: not a number"
eval env (ELam id body) = VClos env id body
eval env (EApp e1 e2)   = case eval env e1 of
  VClos ce id e -> let argVal      = eval env e2
                       extendedEnv = extendEnv id argVal ce
                     in eval extendedEnv e
  _             -> error "type error: not a function"                      
eval env (ELet id e1 e2) =
  let v1          = eval env e1
      extendedEnv = extendEnv id v1 env
    in eval extendedEnv e2

true  = ELam "x" (ELam "y" (EVar "x"))
false = ELam "x" (ELam "y" (EVar "y"))
ite   = ELam "b" (ELam "x" (ELam "y" (EApp (EApp (EVar "b") (EVar "x")) (EVar "y"))))

zero  = ELam "f" (ELam "x" (EVar "x"))
one   = ELam "f" (ELam "x" (EApp (EVar "f") (EVar "x")))

question13_1 = (EApp (EApp (EApp ite true) zero) one)
question13_2 = (EApp (EApp (EApp ite false) zero) one)

-- (\x -> (\y -> x)) y
-- should evaluate to \y -> x, not \y -> y
tricky = EApp (ELam "x" (ELam "y" (EVar "x"))) (EVar "y")

-- (\y -> (\x -> (\y -> x)) y) (\z -> z)
tricky2 = EApp (ELam "y" (EApp (ELam "x" (ELam "y" (EVar "x"))) (EVar "y"))) (ELam "z" (EVar "z"))

-- (\f -> \a -> f a) (\x -> x)
closureWithNonEmptyEnv = (EApp (ELam "f" (ELam "a" (EApp (EVar "f") (EVar "a")))) (ELam "x" (EVar "x")))

part3Example = ELet "f" (ELam "x" (EVar "x"))
                         (EApp (EVar "f") (EPlus (ENum 3) (ENum 4)))

question10a = ELet "n" (ENum 2)
                       (ELet "m" (EPlus (ENum 3) (EVar "n"))
                                 (ELam "x" (EPlus (EVar "m") (EVar "x"))))

question10b = EApp (ELam "x" (EVar "x"))
                   (ELam "z" (ELam "y" (EApp (EVar "y") (EVar "z"))))

question14a =
  let a = 3 in
    let f = \x y -> x + y + a in
      let x = 4 in
        let a = 5 in
          f x a

-- 3 + 4 + 5 = 12
-- 5 + 4 + 5 = 14
-- 3 + 4 + 3 = 10
         
instance Show Expr where
  show :: Expr -> String
  show (ENum n)        = show n
  show (EVar s)        = s
  show (EPlus e1 e2)   = "(" ++ show e1 ++ " + " ++ show e2 ++ ")"
  show (ELam id body)  = "(\\" ++ id ++ " -> " ++ show body ++ ")"
  show (EApp e1 e2)    = "(" ++ show e1 ++ " " ++ show e2 ++ ")"
  show (ELet id e1 e2) = "let " ++ id ++ " = " ++ show e1 ++ " in " ++ show e2

-- instance Show Value where
--   show :: Value -> String
--   show (VNum n)            = show n
--   show (VClos env id body) = "(\\" ++ id ++ " -> " ++ show body ++ ") with environment " ++ show env
