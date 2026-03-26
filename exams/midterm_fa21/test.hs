data Expr = Abs String Expr
          | App Expr Expr
          | Var String

subst :: Expr -> String -> Expr -> Expr
subst (Var x)     y e  = undefined
subst (App e1 e2) y e3 = undefined
subst (Abs x e1)  y e2 
  | x == y             = undefined
  | notElem y (fv e2)  = undefined

fv :: Expr -> [String]
fv e = undefined
