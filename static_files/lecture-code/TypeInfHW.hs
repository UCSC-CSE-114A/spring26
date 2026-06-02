module TypeInfHW where

import qualified Data.List as L
import TypeInfProvided
import Control.Exception (throw)

-- | Unify a type variable with a type; 
--   if successful return an updated state, otherwise throw an error
unifyTVar :: InferState -> TId -> Type -> InferState
unifyTVar = undefined

-- | Unify two types;
--   if successful return an updated state, otherwise throw an error
unify :: InferState -> Type -> Type -> InferState
unify = undefined

-- | Things that have free type variables
class HasTVars a where
  freeTVars :: a -> [TId]

-- | Type variables of a type
instance HasTVars Type where
  freeTVars :: Type -> [TId]
  freeTVars = undefined

-- | Free type variables of a type environment
instance HasTVars TypeEnv where
  freeTVars :: TypeEnv -> [TId]
  freeTVars gamma   = concat [freeTVars s | (x, s) <- gamma]

-- | Look up a type variable in a substitution;
--   if not present, return the variable unchanged
lookupTVar :: TId -> Subst -> Type
lookupTVar = undefined

-- | Remove a type variable from a substitution
removeTVar :: TId -> Subst -> Subst
removeTVar = undefined

-- | Things to which type substitutions can be applied
class Substitutable a where
  apply :: Subst -> a -> a

-- | Apply substitution to type
instance Substitutable Type where
  apply :: Subst -> Type -> Type
  apply = undefined

-- | Apply substitution to a type environment or a substitution
instance Substitutable [(String, Type)] where
  apply sub gamma = zip keys (map (apply sub) vals)
    where
      (keys, vals) = unzip gamma

-- | Extend substitution with a new type assignment
extendSubst :: Subst -> TId -> Type -> Subst
extendSubst = undefined

-- This is actually provided, but I had to put it in this file to avoid a cyclic dependency
-- | Extend the current substitution of a state with a new type assignment   
extendState :: InferState -> TId -> Type -> InferState
extendState (InferState sub n) a t = InferState (extendSubst sub a t) n