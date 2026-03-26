-- Haskell code for winter 2025 midterm

data LCExpr = LCVar String 
            | LCLam String LCExpr 
            | LCApp LCExpr LCExpr

size :: LCExpr -> Int
size (LCVar _) = 1
size (LCLam _ e) = 1 + size e
size (LCApp e1 e2) = 1 + size e1 + size e2

data Expr = EPlus Expr Expr
          | EMinus Expr Expr
          | ENum Int
          | EVar String

type Env = [(String, Int)]

eval :: Expr -> Env -> Maybe Int
eval (ENum n)       _   = Just n
eval (EVar s)       env = lookupInEnv s env
eval (EPlus e1 e2)  env = evalNumOp (+) (eval e1 env) (eval e2 env)
eval (EMinus e1 e2) env = evalNumOp (-) (eval e1 env) (eval e2 env)

evalNumOp :: (Int -> Int -> Int) -> Maybe Int -> Maybe Int -> Maybe Int
evalNumOp f (Just n) (Just m) = Just (f n m)
evalNumOp f _        _        = Nothing

lookupInEnv :: String -> Env -> Maybe Int
lookupInEnv _ []          = Nothing
lookupInEnv s ((k,v):kvs) = if s == k then Just v else lookupInEnv s kvs