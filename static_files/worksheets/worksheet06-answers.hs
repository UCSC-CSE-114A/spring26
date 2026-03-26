data Expr = Var String           -- Variable
          | Str String           -- String literal
          | Boo Bool             -- Boolean literal: `True`, `False`
          | Rev Expr             -- Reverse a string: `reverse`
          | Let String Expr Expr -- let-expression: `let x = e1 in e2`
          | Bin Binop Expr Expr  -- Binary operations: `e1 ++ e2`, etc
  deriving Show                  -- This allows GHCi to print an Expr

data Binop = Cat  -- Concatenate strings: (++)
           | Eq   -- Equality check: (==)
           | And  -- Boolean conjunction: (&&)
           | Or   -- Boolean disjunction: (||)
  deriving Show

example :: Expr
example = Let "b" (Bin Cat (Str "cookie") (Str "nympha"))
  (Bin Eq (Rev (Var "b")) (Str "ahpmyneikooc"))

-- let str1 = "larry" in
--   let str2 = "min" ++ "ion" in
--     str1 == str2 || "minion" == str2

expr :: Expr
expr = Let "str1" (Str "larry")
         (Let "str2" (Cat (Str "min") (Str "ion"))
            (Bin Or (Bin Eq (Var "str1") (Var "str2"))
                    (Bin Eq (Str "minion") (Var "str2"))))
                               
data UnboundError = Unbound String
  deriving Show

data Value = ValStr String | ValBoo Bool
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

applyOp :: Binop -> Value -> Value -> Value
applyOp Cat (ValStr s1) (ValStr s2) = ValStr (s1 ++ s2)
applyOp Eq  (ValStr s1) (ValStr s2) = ValBoo (s1 == s2)
applyOp Eq  (ValBoo b1) (ValBoo b2) = ValBoo (b1 == b2)
applyOp And (ValBoo b1) (ValBoo b2) = ValBoo (b1 && b2)
applyOp Or  (ValBoo b1) (ValBoo b2) = ValBoo (b1 || b2)
applyOp _   _           _           = error "type error!"
