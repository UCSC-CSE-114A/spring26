-- Welcome to lecture 22!

-- AST type
data Expr = ENum Int
          | EBool Bool
          | EVar String
          | EAdd Expr Expr
          | ELet String Expr Expr
  deriving (Show, Eq)

data Type = TInt
          | TBool
          | Type :=> Type
  deriving Show


-- A type environment maps variable names to types
type TypeEnv = [(String, Type)]

lookupVarType :: String -> TypeEnv -> Type
lookupVarType x [] = error ("unbound variable: " ++ x)
lookupVarType x ((y, t):rest) = if x == y then t else lookupVarType x rest

-- A tiny, terrible type inferencer
infer :: TypeEnv -> Expr -> Type
infer _ (ENum _) = TInt
infer _ (EBool _) = TBool
infer gamma (EVar x) = lookupVarType x gamma
infer gamma (EAdd e1 e2) = case (infer gamma e1, infer gamma e2) of
  (TInt, TInt) -> TInt
  (_, _)       -> error "ill-typed expression"
infer gamma (ELet x e1 e2) = infer extGamma e2
  where extGamma = (x,infer gamma e1):gamma

-- Let's try this on a couple of expressions.
-- let x = 3 in 
--   let y = 4 in 
--     x + y
expr :: Expr
expr = ELet "x" (ENum 3) (ELet "y" (ENum 4) (EAdd (EVar "x") (EVar "y")))

-- Here's an ill-typed expression!
-- let x = 3 in
--   let y = True in
--     x + y    
illTypedExpr :: Expr
illTypedExpr = ELet "x" (ENum 3) (ELet "y" (EBool True) (EAdd (EVar "x") (EVar "y")))