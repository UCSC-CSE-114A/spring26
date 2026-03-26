data Expr = Var String           -- Variable
          | Str String           -- String literal
          | Boo Bool             -- Boolean literal: `True`, `False`
          | Rev Expr             -- Reverse a string: `reverse`
          | Let String Expr Expr -- let-expression: `let x = e1 in e2`
          | Bin Binop Expr Expr  -- Binary operations: `e1 ++ e2`, etc
          | Lam String Expr      -- Function definition
          | App Expr Expr        -- Function call
  deriving Show                  -- This allows GHCi to print an Expr

data Binop = Cat  -- Concatenate strings: (++)
           | Eq   -- Equality check: (==)
           | And  -- Boolean conjunction: (&&)
           | Or   -- Boolean disjunction: (||)
  deriving Show

-- let f = \s -> s ++ " is cute" in f "nympha"
exampleAST = 
    Let "f" (Lam "s" (Bin Cat (Var "s") (Str " is cute")))
        (App (Var "f") (Str "nympha"))

-- let str = " is cute" in
--   let f = \s -> s ++ str in
--     let str = " is smelly" in
--       f "nympha"
exampleAST2 =
    Let "str" (Str " is cute")
        (Let "f" (Lam "s" (Bin Cat (Var "s") (Var "str")))
              (Let "str" (Str " is smelly")
                   (App (Var "f") (Str "nympha"))))

data UnboundError = Unbound String
  deriving Show

data Value = ValStr String | ValBoo Bool | ValClos String Expr ListEnv
  deriving Show

type ListEnv = [(String, Value)]

lookupInEnv :: ListEnv -> String -> Either UnboundError Value
lookupInEnv [] k = Left (Unbound ("variable " ++ k ++ " is unbound!"))
lookupInEnv ((k',v):env') k = if k == k' then Right v else lookupInEnv env' k

eval :: ListEnv -> Expr -> Either UnboundError Value
eval env (Var x) = lookupInEnv env x
eval _   (Str s) = Right (ValStr s)
eval _   (Boo b) = Right (ValBoo b)
eval env (Bin op e1 e2) =
  case (eval env e1, eval env e2) of
    (Right v1,  Right v2) -> Right (applyOp op v1 v2)
    _                     -> Left  (Unbound "at least one variable was unbound")
eval env (Rev e) = 
  case eval env e of
    Right (ValStr s) -> Right (ValStr (reverse s))
    Right (ValBoo _) -> error "type error!"
    _                -> Left  (Unbound "at least one variable was unbound")
eval env (Let s e1 e2) =
  case eval env e1 of
    Right v -> eval ((s,v):env) e2
    _       -> Left (Unbound "at least one variable was unbound")
eval env (Lam s body) = Right (ValClos s body env)
eval env (App e1 e2) = case (eval env e1, eval env e2) of
    (Right (ValClos s body closEnv), Right argval) -> eval ((s,argval):closEnv) body -- version that implements static scope
--    (Right (ValClos s body _      ), Right argval) -> eval ((s,argval):env) body   -- version that implements dynamic scope
    (Right _                       , _           ) -> error "type error!"
    (Left _                        , _           ) -> Left (Unbound "at least one variable was unbound")

applyOp :: Binop -> Value -> Value -> Value
applyOp Cat (ValStr s1) (ValStr s2) = ValStr (s1 ++ s2)
applyOp Eq  (ValStr s1) (ValStr s2) = ValBoo (s1 == s2)
applyOp Eq  (ValBoo b1) (ValBoo b2) = ValBoo (b1 == b2)
applyOp And (ValBoo b1) (ValBoo b2) = ValBoo (b1 && b2)
applyOp Or  (ValBoo b1) (ValBoo b2) = ValBoo (b1 || b2)
applyOp _   _           _           = error "type error!"
