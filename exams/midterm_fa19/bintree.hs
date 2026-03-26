data Tree = Leaf | Node Int Tree Tree

mmax :: Tree -> Int
mmax Leaf = 0
mmax (Node n t1 Leaf) = n
mmax (Node n t1 t2) = mmax t2

contains :: Int -> Tree -> Bool
contains n Leaf = False
contains n (Node m t1 t2) | (n == m) = True
                          | otherwise = if (n <= m) then (contains n t1) else (contains n t2)

foo bar (x, y)
  | bar x = y ++ y 
  | otherwise = y

main = undefined
