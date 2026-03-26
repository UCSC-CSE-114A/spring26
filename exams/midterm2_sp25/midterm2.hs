-- Haskell code for spring 2025 midterm 2

q3 :: Maybe a -> String
q3 = \x -> case x of
  Just _  -> "something"
  Nothing -> "nothing"

data Expr = Var String    -- Variable
          | Str String    -- String literal
          | Cat Expr Expr -- Concatenate strings: `(++)`
          | Rev Expr      -- Reverse a string: `reverse`


example :: Expr
example = Rev (Cat (Var "s") (Rev (Str "cookie")))

depth :: Expr -> Int
depth (Var _) = 1
depth (Str _) = 1
depth (Cat e1 e2) = 1 + max (depth e1) (depth e2)
depth (Rev e) = 1 + depth e

depthAll :: [Expr] -> Int
depthAll []     = 0
depthAll (x:xs) = depth x + depthAll xs

instance Eq Expr where
  (==) :: Expr -> Expr -> Bool
  (==) e1 e2 = depth e1 == depth e2

data ArithExpr = ANum Int 
               | AAdd ArithExpr ArithExpr
               | ASub ArithExpr ArithExpr
               | AVar String

instance Show ArithExpr where
  show :: ArithExpr -> String
  show (ANum n) = show n -- uses the built-in `Show` instance for `Int`s
  show (AVar s)    = s
  show (AAdd e1 e2) = "(" ++ show e1 ++ "+" ++ show e2 ++ ")"
  show (ASub e1 e2) = "(" ++ show e1 ++ "-" ++ show e2 ++ ")"

type Env = [(String, String)]

eval :: Expr -> Env -> Maybe String
eval (Rev e) env = case eval e env of
  Just v -> Just (reverse v)
  _      -> Nothing
eval (Var s) env = lookupInEnv s env
eval (Str s) _   = Just s
eval (Cat e1 e2) env = case (eval e1 env, eval e2 env) of
  (Just v1, Just v2) -> Just (v1 ++ v2)
  _                  -> Nothing
  

lookupInEnv :: String -> Env -> Maybe String
lookupInEnv _ []          = Nothing
lookupInEnv s ((k,v):kvs) = if s == k then Just v else lookupInEnv s kvs

showTests :: [(String, String)]
showTests = [(show (ANum 3), "3"),
             (show (AAdd (ANum 3) (AVar "x")), "(3+x)"),
             (show (AAdd (ASub (AVar "x") (AVar "y")) (ANum 2)), "((x-y)+2)"), 
             (show (AVar "y"), "y"),
             (show (ASub (ASub (ANum 5) (ANum 3)) (AVar "z")), "((5-3)-z)"),
             (show (AAdd (ASub (ANum 5) (ANum 3)) (AAdd (ANum 2) (AVar "x"))), "((5-3)+(2+x))")]

evalTests :: [(Maybe String, Maybe String)]
evalTests = [(eval (Str "larry") [], Just "larry"),
             (eval (Rev (Str "larry")) [], Just "yrral"),
             (eval (Rev (Var "x")) [("x", "the creature")], Just "erutaerc eht"),
             (eval (Rev (Var "x")) [("y", "cali")], Nothing),
             (eval (Cat (Rev (Var "x")) (Rev (Var "y"))) [("x", "cookie"), ("y", "mo")], Just "eikoocom"),
             (eval (Cat (Rev (Var "x")) (Rev (Var "y"))) [("x", "cookie")], Nothing),
             (eval (Rev (Rev (Rev (Rev (Var "s"))))) [("s", "phoebe")], Just "phoebe")]

results = map (\(x, y) -> x == y) showTests ++ map (\(x, y) -> x == y) evalTests

