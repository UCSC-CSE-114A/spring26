exam5 = map (\s -> "hello " ++ s) ["apple", "orange"]

subtractThree :: Int -> Int
subtractThree x = x - 3

exam6 = subtractThree (foldr (+) 0 [1,2,3])

exam7 = let f = \x -> x + 1
            g = filter (\y -> y > 1)
          in g (map f [0,1,2,3])

exam8 =
  let b = 3 < 5 in
    case b of
      True  -> (\s -> "hello, " ++ s)
      False -> (\s -> "goodbye, " ++ s)

listify :: Int -> a -> [a]  
listify n x  
    | n <= 0 = []  
    | otherwise = x:listify (n-1) x

data AExp = Num Int | Plus AExp AExp | Minus AExp AExp

evalAExp :: AExp -> Int
evalAExp e = case e of
  Num i       -> i
  Plus  e1 e2 -> evalAExp e1 + evalAExp e2
  Minus e1 e2 -> evalAExp e1 - evalAExp e2

exam10a = evalAExp (Plus (Num 3) (Plus (Num 4) (Num 5)))

exam10b = evalAExp (Plus (Num 3) (Num 4))

exam10c = evalAExp (Minus (Num 7) (Plus (Num 3) (Num 12)))

exam10d = evalAExp (Num 3)

showAExp :: AExp -> String
showAExp e = case e of
  Num i       -> show i
  Plus  e1 e2 -> "(" ++ showAExp e1 ++ " + " ++ showAExp e2 ++ ")"
  Minus e1 e2 -> "(" ++ showAExp e1 ++ " - " ++ showAExp e2 ++ ")"

exam11a = showAExp (Plus (Num 3) (Plus (Num 4) (Num 5)))

exam11b = showAExp (Plus (Num 3) (Num 4))

exam11c = showAExp (Minus (Num 7) (Plus (Num 3) (Num 12)))

exam11d = showAExp (Num 3)
