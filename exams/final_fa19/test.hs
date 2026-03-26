data Tree a =  Leaf | Node a (Tree a) (Tree a) deriving Show

t = (Node "foo"  
      (Node "bar" (Node "baz" Leaf Leaf) Leaf) 
      (Node "qux" Leaf (Node "quux" Leaf Leaf)))

foldTree f d Leaf = d 
foldTree f d (Node v l r) = f v (foldTree f (foldTree f d r) l)

maxTree d = foldTree max d

joinTree t Leaf = t 
joinTree t (Node v l r) = Node v (joinTree t l) r 

filterTree p Leaf = Leaf
filterTree p (Node v l r) | p v = 
  Node v (filterTree p l) (filterTree p r) 
filterTree p (Node v l r) | otherwise = 
  case filterTree p l of 
    Leaf -> filterTree p r
    fl   -> case filterTree p r of
              Leaf -> fl
              fr   -> joinTree fl fr
