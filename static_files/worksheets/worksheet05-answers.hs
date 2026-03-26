data Expr = Var String -- Variable
          | Str String -- String literal
          | Cat Expr Expr -- Concatenate strings
          | Rev Expr -- Reverse a string
  deriving Show -- This allows GHCi to print an Expr

type ListEnv = [(String, String)]

data UnboundError = Unbound String
  deriving Show
 
caseExample :: Bool -> String -> String
caseExample = \x y -> case (not x, "hello, " ++ y) of
  (False, s) -> s
  (True,  _) -> "the first argument must have been False"

lookupInEnv :: ListEnv -> String -> Either UnboundError String
lookupInEnv [] k = Left (Unbound ("variable " ++ k ++ " is unbound!"))
lookupInEnv ((k',v):env') k = if k == k' then Right v else lookupInEnv env' k

-- A simple implementation of `eval`.
-- A more sophisticated implementation could pattern-match against each error possibility
-- and return more informative error messages in the recursive cases.
eval :: ListEnv -> Expr -> Either UnboundError String
eval env (Var x) = lookupInEnv env x
eval _   (Str s) = Right s
eval env (Cat e1 e2) =
  case (eval env e1, eval env e2) of
    (Right s1,  Right s2) -> Right (s1 ++ s2)
    _                     -> Left  (Unbound "at least one variable was unbound")
eval env (Rev e) = 
  case eval env e of
    Right s -> Right (reverse s)
    _       -> Left  (Unbound "at least one variable was unbound")
