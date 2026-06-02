module TypeInfProvided where

import Control.Exception

-- Representing expressions
data Expr = EInt Int
          | EBool Bool
          | EVar String
          | EAdd Expr Expr
          | ELet String Expr Expr
          | ELam String Expr
          | EApp Expr Expr

data Error = Error {errMsg :: String}
  deriving (Show)

instance Exception Error

-- Representing types
-- Here, `:=>` is just an infix data constructor
-- that takes two arguments
data Type = TInt | TBool | Type :=> Type | TVar String
  deriving (Eq, Show)

-- A substitution maps type variable names to types
type Subst = [(String, Type)]

-- A type environment maps (program) variable names to types
type TId = String
type TypeEnv = [(TId, Type)]

-- | State of the type inference algorithm
data InferState = InferState {
    stSub :: Subst -- ^ current substitution
  , stCnt :: Int   -- ^ number of fresh type variables generated so far
} deriving (Eq, Show)

-- | Initial state: empty substitution; 0 type variables
initInferState :: InferState
initInferState = InferState { stSub = [], stCnt = 0 }

-- | Fresh type variable number n
freshTV :: Show a => a -> Type
freshTV n = TVar ("a" ++ show n)

-- | Look up a variable in a type environment
lookupVarType :: String -> TypeEnv -> Type
lookupVarType x [] = error ("unbound variable: " ++ x)
lookupVarType x ((y,t):rest) = if x == y then t else lookupVarType x rest

-- | Extend a type environment with a new binding
extendTypeEnv :: String -> Type -> TypeEnv -> TypeEnv
extendTypeEnv x t gamma = (x,t):gamma