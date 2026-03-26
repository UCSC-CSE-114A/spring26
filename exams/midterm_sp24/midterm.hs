-- Haskell code for spring 2024 midterm

data Expr = ENum Int 
          | EBool Bool
          | EVar String 
          | EPlus Expr Expr
          | EMinus Expr Expr
          | EIf Expr Expr Expr
  deriving Show

size :: Expr -> Int
size (ENum _) = 1
size (EBool _) = 1
size (EVar _) = 1
size (EPlus e1 e2) = 1 + size e1 + size e2
size (EMinus e1 e2) = 1 + size e1 + size e2
size (EIf e1 e2 e3) = 1 + size e1 + size e2 + size e3

sizeAll :: [Expr] -> Int
sizeAll []     = 0
sizeAll (x:xs) = size x + sizeAll xs

sizeAllTR :: [Expr] -> Int
sizeAllTR xs = helper xs 0
  where helper :: [Expr] -> Int -> Int
        helper []     acc = acc
        helper (x:xs) acc = helper xs (acc + size x)

sizeAllFoldr :: [Expr] -> Int
sizeAllFoldr xs = foldr (\x y -> size x + y) 0 xs


data Value = VNum Int | VBool Bool
  deriving Show

type Env = [(String, Value)]

eval :: Expr -> Env -> Value
eval (ENum n)       env = VNum n
eval (EBool b)      env = VBool b
eval (EVar s)       env = lookupInEnv s env
eval (EPlus e1 e2)  env = evalNumOp (+) (eval e1 env) (eval e2 env)
eval (EMinus e1 e2) env = evalNumOp (-) (eval e1 env) (eval e2 env)
eval (EIf e1 e2 e3) env = evalIf (eval e1 env) (eval e2 env) (eval e3 env)

evalNumOp :: (Int -> Int -> Int) -> Value -> Value -> Value
evalNumOp f (VNum n) (VNum m) = VNum (f n m)
evalNumOp f v1       v2       = error ("Type error: " ++ show v1 ++ " and " ++ show v2 ++ " aren't both numbers!")

evalIf :: Value -> Value -> Value -> Value
evalIf (VBool True)  v1 v2 = v1
evalIf (VBool False) v1 v2 = v2
evalIf v             _  _  = error ("Type error: " ++ show v ++ " isn't a boolean!")

lookupInEnv :: String -> Env -> Value
lookupInEnv _ []          = error "Unbound variable!"
lookupInEnv s ((k,v):kvs) = if s == k then v else lookupInEnv s kvs




