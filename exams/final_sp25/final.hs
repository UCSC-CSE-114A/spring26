-- Haskell code for spring 2025 final

type Id = String

data Expr 
  = EStr String
  | EInt Int
  | ELam Id Expr
  | EVar Id
  | EConcat Expr Expr
  | EAdd Expr Expr
  | ELet Id Expr Expr
  | EApp Expr Expr
  deriving (Eq, Show)

data Value
  = VStr String
  | VInt Int
  | VClos Id Expr Env
  deriving (Eq, Show)

type Env = [(Id, Value)]

data Error = UnboundError | TypeError
  deriving (Eq, Show)

eval :: Expr -> Env -> Either Value Error
eval (EStr s) _ = Left (VStr s)
eval (EInt n) _ = Left (VInt n)
eval (ELam id e) env = Left (VClos id e env)
eval (EVar id) env = lookupInEnv id env
eval (EConcat e1 e2) env = case (eval e1 env, eval e2 env) of
    -- Handle errors first
    (Right err     , _             ) -> Right err
    (_             , Right err     ) -> Right err
    -- If both expressions evaluate to strings, concatenate them; otherwise, it's a type error
    (Left (VStr s1), Left (VStr s2)) -> Left (VStr (s1 ++ s2))
    (Left _        , Left _        ) -> Right TypeError
eval (EAdd e1 e2) env = case (eval e1 env, eval e2 env) of
    -- Handle errors first
    (Right err     , _             ) -> Right err
    (_             , Right err     ) -> Right err
    -- If both expressions evaluate to ints, add them; otherwise, it's a type error
    (Left (VInt n1), Left (VInt n2)) -> Left (VInt (n1 + n2))
    (Left _        , Left _        ) -> Right TypeError   
eval (ELet id e1 e2) env = case eval e1 env of
    Left v    -> eval e2 (extendEnv id v env)
    Right err -> Right err
eval (EApp e1 e2) env = case (eval e1 env, eval e2 env) of
    -- Handle errors first
    (Right err, _) -> Right err
    (_, Right err) -> Right err
    -- If the first expression evaluates to a closure, evaluate the body; otherwise, it's a type error
    -- For dynamic scope, use the dynamic environment instead of the one inside the closure
    (Left (VClos id expr _), Left argVal) -> eval expr (extendEnv id argVal env)
    (Left (VStr _), _) -> Right TypeError

staticEval :: Expr -> Env -> Either Value Error
staticEval (EStr s) _ = Left (VStr s)
staticEval (EInt n) _ = Left (VInt n)
staticEval (ELam id e) env = Left (VClos id e env)
staticEval (EVar id) env = lookupInEnv id env
staticEval (EConcat e1 e2) env = case (staticEval e1 env, staticEval e2 env) of
    -- Handle errors first
    (Right err     , _             ) -> Right err
    (_             , Right err     ) -> Right err
    -- If both expressions evaluate to strings, concatenate them; otherwise, it's a type error
    (Left (VStr s1), Left (VStr s2)) -> Left (VStr (s1 ++ s2))
    (Left _        , Left _        ) -> Right TypeError
staticEval (EAdd e1 e2) env = case (staticEval e1 env, staticEval e2 env) of
    -- Handle errors first
    (Right err     , _             ) -> Right err
    (_             , Right err     ) -> Right err
    -- If both expressions evaluate to ints, add them; otherwise, it's a type error
    (Left (VInt n1), Left (VInt n2)) -> Left (VInt (n1 + n2))
    (Left _        , Left _        ) -> Right TypeError   
staticEval (ELet id e1 e2) env = case staticEval e1 env of
    Left v    -> staticEval e2 (extendEnv id v env)
    Right err -> Right err
staticEval (EApp e1 e2) env = case (staticEval e1 env, staticEval e2 env) of
    -- Handle errors first
    (Right err, _) -> Right err
    (_, Right err) -> Right err
    -- If the first expression evaluates to a closure, evaluate the body; otherwise, it's a type error
    -- For static scope, use the environment inside the closure
    (Left (VClos id expr closEnv), Left argVal) -> staticEval expr (extendEnv id argVal closEnv)
    (Left (VStr _), _) -> Right TypeError

lookupInEnv :: Id -> Env -> Either Value Error
lookupInEnv id [] = Right UnboundError
lookupInEnv id ((s,v):rest) = if id == s then Left v else lookupInEnv id rest

extendEnv :: Id -> Value -> Env -> Env
extendEnv id value env = (id, value):env

{-
"hello"
-}
p1 :: Expr
p1 = EStr "hello"

{-
z
-}
p2 :: Expr
p2 = EVar "z"

{-
\x -> x
-}
p3 :: Expr
p3 = ELam "x" (EVar "x")

{-
"hello" ++ "larry"
-}
p4 :: Expr
p4 = EConcat (EStr "hello") (EStr "larry")

{-
let s = "larry" in
  "hello" ++ s
-}
p5 :: Expr
p5 = ELet "s" (EStr "larry") (EConcat (EStr "hello") (EVar "s"))

{-
(\x -> x ++ "minion") (EStr "hello")
-}
p6 :: Expr
p6 = EApp (ELam "x" (EConcat (EVar "x") (EStr "minion"))) (EStr "hello")

{-
let f = \x -> x ++ " is cute" in
  f "mo"
-}
p7 :: Expr
p7 = ELet "f" (ELam "x" (EConcat (EVar "x") (EStr " is cute"))) (EApp (EVar "f") (EStr "mo"))

{-
let s = "jacob" in
  let f = \x -> s ++ x in
    f "larry"
-}
p8 :: Expr
p8 = ELet "s" (EStr "jacob") (ELet "f" (ELam "x" (EConcat (EVar "s") (EVar "x"))) (EApp (EVar "f") (EStr "larry")))

{-
let s = "jacob" in
  let f = \x -> s ++ x in
    let s = "walter" in
      f "larry"

Under dynamic scope, we wouldn't use (s, "jacob") in f's closure.
So this would evaluate to "walterlarry".

Under static scope, we'd use (s, "jacob") in f's closure.
So this would evaluate to "jacoblarry".
-}
p9 :: Expr
p9 = ELet "s" (EStr "jacob") 
       (ELet "f" (ELam "x" (EConcat (EVar "s") (EVar "x")))
         (ELet "s" (EStr "walter")
           (EApp (EVar "f") (EStr "larry"))))

{-
let f = \x -> g x in
  let g = \y -> y ++ y in
    f "minion"

Under dynamic scope, we'd use the dynamic binding for `g`.
So this would evaluate to "minionminion".

Under static scope, there would be no binding for `g` in `f`'s closure.
So this would evaluate to an unbound variable error.
-}
p10 :: Expr
p10 = ELet "f" (ELam "x" (EApp (EVar "g") (EVar "x")))
        (ELet "g" (ELam "y" (EConcat (EVar "y") (EVar "y")))
          (EApp (EVar "f") (EStr "minion")))

{-
What if it's an application expression where the left-hand side is a type error,
and the right-hand side has an unbound variable error?  For instance:

let f = "hello" in
  f x

Then the unbound variable error takes priority.
-}
p11 :: Expr
p11 = ELet "f" (EStr "hello") (EApp (EVar "f") (EVar "x"))

{-
42
-}
p12 :: Expr
p12 = EInt 42

{-
21 + 21
-}
p13 :: Expr
p13 = EAdd (EInt 21) (EInt 21)

{-
let n = 5 in
  n + 3
-}
p14 :: Expr
p14 = ELet "n" (EInt 5) (EAdd (EVar "n") (EInt 3))

{-
let n = 0 in
  let f = \x -> n + x in
    let n = 6 in
      f n

Under dynamic scope, we wouldn't be using (n, 0) in f's closure.
So this would evaluate to 12.

Under static scope, we'd use (n, 0) in f's closure.
So this would evaluate to 6.
-}
p15 :: Expr
p15 = ELet "n" (EInt 0)
        (ELet "f" (ELam "x" (EAdd (EVar "n") (EVar "x")))
          (ELet "n" (EInt 6)
            (EApp (EVar "f") (EVar "n"))))

{-
let f = \x -> n + x in
  let n = 6 in
    f n

Under dynamic scope, we'd use the dynamic binding for n.
So this would evaluate to 12.

Under static scope, this would be an unbound variable error.
-}
p16 :: Expr
p16 = ELet "f" (ELam "x" (EAdd (EVar "n") (EVar "x")))
        (ELet "n" (EInt 6)
          (EApp (EVar "f") (EVar "n")))

{-
let f = \x -> x in
  f x

This would be an unbound variable error (under either static or dynamic scope).
-}
p17 :: Expr
p17 = ELet "f" (ELam "x" (EVar "x"))
        (EApp (EVar "f") (EVar "x"))

{-
let f = \x -> x in
  let f = \x -> 3 + x in
    f 3

This would evaluate to 6 (under either static or dynamic scope).
-}
p18 :: Expr
p18 = ELet "f" (ELam "x" (EVar "x"))
        (ELet "f" (ELam "x" (EAdd (EInt 3) (EVar "x")))
          (EApp (EVar "f") (EInt 3)))

p19 :: Expr
p19 = EAdd (EInt 3) (EAdd (EInt 4) (EVar "x"))
        
tests :: [(Expr, Either Value Error, Either Value Error)]
tests = [(p1, Left (VStr "hello")            , Left (VStr "hello")),
         (p2, Right UnboundError             , Right UnboundError),
         (p3, Left (VClos "x" (EVar "x") []) , Left (VClos "x" (EVar "x") [])),
         (p4, Left (VStr "hellolarry")       , Left (VStr "hellolarry")),
         (p5, Left (VStr "hellolarry")       , Left (VStr "hellolarry")),
         (p6, Left (VStr "hellominion")      , Left (VStr "hellominion")),
         (p7, Left (VStr "mo is cute")       , Left (VStr "mo is cute")),
         (p8, Left (VStr "jacoblarry")       , Left (VStr "jacoblarry")),
         (p9, Left (VStr "walterlarry")      , Left (VStr "jacoblarry")), -- different
         (p10, Left (VStr "minionminion")    , Right UnboundError),       -- different
         (p11, Right UnboundError            , Right UnboundError),
         (p12, Left (VInt 42)                , Left (VInt 42)),
         (p13, Left (VInt 42)                , Left (VInt 42)),
         (p14, Left (VInt 8)                 , Left (VInt 8)),
         (p15, Left (VInt 12)                , Left (VInt 6)),            -- different
         (p16, Left (VInt 12)                , Right UnboundError),       -- different
         (p17, Right UnboundError            , Right UnboundError),
         (p18, Left (VInt 6)                 , Left (VInt 6)),
         (p19, Right UnboundError            , Right UnboundError)
         ]

runDynTests :: Bool
runDynTests = and (map (\(expr, dynResult, _) -> eval expr [] == dynResult) tests)

runStaticTests :: Bool
runStaticTests = and (map (\(expr, _, staticResult) -> staticEval expr [] == staticResult) tests)


-- q4 :: Maybe a -> String
-- q4 =
--   \x -> case x of
--     Just y -> "larry"
--     Nothing -> Nothing

q5 :: Maybe (Maybe a) -> Maybe a
q5 =
  \x -> case x of
    Just y  -> y
    Nothing -> Nothing

q6 :: (String -> String) -> [String]
q6 = \g -> [g "walter", "rainbow", "sprinkles"]

q7 :: (String -> a) -> [a]
q7 = \g -> [g "walter", g "rainbow", g "sprinkles"]

q8 :: a -> (String -> a) -> [a]
q8 = \x y -> [x, y "walter"]

q9 :: [String]
q9 = foldr (:) [] ["h", "e", "l", "l", "o"]

combine :: (Int -> Int -> Int) -> Int -> Int -> Int
combine op 0 b = b
combine op n b = op n (combine op (n-1) b)

combineTests :: ((Int -> Int -> Int) -> Int -> Int -> Int) -> [(Int, Int)]
combineTests f =
    [(f (+) 0 0, 0),
     (f (+) 2 0, 3),
     (f (-) 2 0, 1),
     (f (+) 0 4, 4),
     (f (+) 1 2, 3),
     (f (-) 1 0, 1),
     (f (-) 3 0, 2),
     (f (+) 1 3, 4),
     (f (*) 1 0, 0),
     (f (*) 2 1, 2),
     -- This one will be different because these aren't Church numerals!
     -- (f (-) 3 2, 1),
     (f (*) 3 1, 6),
     (f (+) 3 0, 6),
     (f (*) 0 2, 2)]

runCombineTests :: Bool
runCombineTests = and (map (\(test,result) -> test == result) (combineTests combine))

-- (\s -> s) (let name = "larry" in "hello" ++ name)
q11 :: Expr
q11 = EApp (ELam "s" (EVar "s")) (ELet "name" (EStr "larry") (EConcat (EStr "hello") (EVar "name")))
