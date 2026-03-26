f :: (a -> b) -> b -> [a] -> b
f = undefined
g :: (c -> Bool) -> a -> [c] -> [c]
g = undefined
-- h :: (c -> Bool) -> a -> [c] -> [c]
-- h = f

foo a b = let c = \a -> b ++ a in
            let b = a ++ (c a) in 
              c (bar b)
  where bar e = e ++ a ++ b

data Tree a = Leaf | Node a (Tree a) (Tree a) deriving (Show)

t = (Node "foo" (Node "bar" (Node "boo"  Leaf (Node "bah" Leaf Leaf)) Leaf) (Node "qux" Leaf (Node "quux" Leaf Leaf)))

foldTree f d Leaf = d 
foldTree f d (Node v l r) = f v (foldTree f (foldTree f d r) l)

main = putStrLn $ foo "x" "o"
