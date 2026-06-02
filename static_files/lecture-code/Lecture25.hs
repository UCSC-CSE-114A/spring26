{-# LANGUAGE BangPatterns #-}

module Lecture25 where

import TypeInfProvided -- Roughly corresponds to stuff that's provided for you in hw5
import TypeInfHW -- Roughly corresponds to stuff you need to implement in hw5 parts 1 and 2

-- Welcome to lecture 25!

{- 

Agenda:

  - Type inference revisited

-}

-- A tiny, terrible type inferencer
infer :: InferState -> TypeEnv -> Expr -> (InferState, Type)
infer st _ (EInt _) = (st, TInt)
infer st _ (EBool _) = (st, TBool)
-- Caveat: this isn't exactly how the EVar case will look
-- in your final implementation of hw5
infer st gamma (EVar x) = (st, lookupVarType x gamma)
-- EAdd case: recursively infer types of operands
-- and enforce the constraint that the operands are `Int`s
infer st gamma (EAdd e1 e2) = (st4, TInt)
  where (st1, t1) = infer st gamma e1 -- 1. infer type of e1
        st2 = unify st1 t1 TInt -- 2. constraint: t1 is Int
        gamma' = apply (stSub st2) gamma -- 3. apply subst to type environment
        (st3, t2) = infer st2 gamma' e2 -- 4. infer type of e2
        st4 = unify st3 t2 TInt -- 5. constraint: t2 is Int
{-
What would go wrong if we *didn't* do all these steps?
These are all expressions that we want to make sure are ill-typed!

`(1 2) + 3` -- would fail in step 1
`1 + (2 3)` -- would fail in step 4
`(\x -> x) + 1` -- would fail in step 2
`1 + (\x -> x)` -- would fail in step 5
`\x -> (x + x 5)` -- would fail in step 3

-- This is ill-typed even though
-- `\x -> x + 3`
-- and
-- `f False`
-- are both fine in isolation
let f = \x -> x + 3 in
  f False

-}
infer st gamma (ELam x e) = (st2, finalT1 :=> t2)
  where t1 = freshTV (stCnt st)
        st1 = InferState (stSub st) (stCnt st + 1)
        gamma' = extendTypeEnv x t1 gamma
        (st2, t2) = infer st1 gamma' e
        finalT1 = apply (stSub st2) t1

-- A tiny, terrible test framework
data Test = Test Expr Type

tests :: [Test]
tests = [
      Test (EInt 7) TInt,
      Test (EBool False) TBool,
      Test (EAdd (EInt 7) (EInt 4)) TInt,
      Test (EAdd (EAdd (EInt 1) (EInt 2)) (EInt 3)) TInt,
      Test (ELam "x" (EAdd (EVar "x") (EInt 3))) (TInt :=> TInt),
      Test (ELam "x" (ELam "y" (EAdd (EVar "x") (EVar "y")))) (TInt :=> (TInt :=> TInt))]

runTests :: [Bool]
runTests = map
  (\(Test expr result) -> (let (_, r) = infer initInferState [] expr
                             in r) == result) tests

-- Quiz access code: Stephanie