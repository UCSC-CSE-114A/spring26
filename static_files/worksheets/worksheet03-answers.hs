tri :: Int -> Int
tri 0 = 0
tri n = n + tri (n-1)

triAcc :: Int -> Int -> Int
triAcc 0 acc = acc
triAcc n acc = triAcc (n-1) (n+acc)

{-

triAcc call visualization:

triAcc 3 0
= triAcc 2 3
= triAcc 1 5
= triAcc 0 6
= 6

-}

triAcc' :: Int -> Int
triAcc' n = helper n 0
    where helper :: Int -> Int -> Int
          helper 0 acc = acc
          helper n acc = helper (n-1) (n+acc)

duplicateAll :: [a] -> [a]
duplicateAll []     = []
duplicateAll (x:xs) = x : x : duplicateAll xs

duplicateAllAcc :: [a] -> [a] -> [a]
duplicateAllAcc []     acc = acc
duplicateAllAcc (x:xs) acc = duplicateAllAcc xs (acc ++ [x, x])