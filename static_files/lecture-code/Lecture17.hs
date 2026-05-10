-- Welcome to lecture 17!
import Text.Printf (printf)

{--
Agenda:

- Wrap up intro to type classes
- `foldr` vs. `foldl`
  - When do they behave differently?

--}

data Expr = Number Int 
          | Add Expr Expr
          | Sub Expr Expr
          | IfZero Expr Expr Expr

ast7 :: Expr
ast7 = Number 7

ast3plus4 :: Expr
ast3plus4 = Add (Number 3) (Number 4)

ast3plus4minus1 :: Expr
ast3plus4minus1 = Add (Number 3) (Sub (Number 4) (Number 1))

astBigExpr :: Expr
astBigExpr = Sub (Sub (Number 3) (Number 2)) (Sub (Number 5) (Number 0))

prettyPrint :: Expr -> String
prettyPrint (Number n) = printf "%d" n
prettyPrint (Add e1 e2) = printf "(%s + %s)" (prettyPrint e1) (prettyPrint e2)
prettyPrint (Sub e1 e2) = printf "(%s - %s)" (prettyPrint e1) (prettyPrint e2)
prettyPrint (IfZero c t e) = printf "if %s == 0 then %s else %s" (prettyPrint c) (prettyPrint t) (prettyPrint e)

instance Show Expr where
    show :: Expr -> String
    show = prettyPrint

-- Here are (somewhat silly) instances of `Show` and `Eq` for 16-element tuples!

instance (Show a, Show b, Show c, Show d, Show e, Show f, Show g,
          Show h, Show i, Show j, Show k, Show l, Show m, Show n, Show o, Show p) =>
         Show (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) where
    show :: (Show a, Show b, Show c, Show d, Show e, Show f, Show g, Show h, Show i, Show j, Show k, Show l, Show m, Show n, Show o, Show p) => (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) -> String
    show (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) = 
        "(" ++ show a ++ ", " ++ show b ++ ", " ++ show c ++ ", " ++ show d ++ " and some other stuff idk)"

instance (Eq a, Eq b, Eq c, Eq d, Eq e, Eq p) => Eq (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) where
    (==) :: (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) -> (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) -> Bool 
    (==) (a1, b1, c1, d1, e1, f1, g1, h1, i1, j1, k1, l1, m1, n1, o1, p1) (a2, b2, c2, d2, e2, f2, g2, h2, i2, j2, k2, l2, m2, n2, o2, p2) =
         a1 == a2 && b1 == b2 && c1 == c2 && d1 == d2 && e1 == e2 && p1 == p2 -- I'm too bored to actually compare them all

{--

Recall what `foldr` does: it boils down a list to one element.

--}       

-- Not tail-recursive
ourFoldr :: (a -> b -> b) -> b -> [a] -> b
ourFoldr f b []     = b
ourFoldr f b (x:xs) = f x (ourFoldr f b xs)

-- Tail-recursive!
-- Notice that the combiner function takes its arguments in the opposite order. 
ourFoldl :: (b -> a -> b) -> b -> [a] -> b
ourFoldl f acc []     = acc
ourFoldl f acc (x:xs) = ourFoldl f (f acc x) xs

-- Not tail-recursive
ourSum :: [Int] -> Int
ourSum [] = 0
ourSum (x:xs) = x + ourSum xs

ourSum' :: [Int] -> Int
ourSum' xs = ourFoldr (+) 0 xs

{--

foldr combines elements from the right!
First you combine the rightmost element with the base value.
Then you combine the result of that with the next-rightmost element,
and so on.
That's why it's called `foldr` with an r. 

ourSum' [1, 2, 3, 4]
= ourFoldr (+) 0 [1, 2, 3, 4]
= (+) 1 (ourFoldr (+) 0 [2, 3, 4])
= (+) 1 ((+) 2 (ourFoldr (+) 0 [3, 4]))
= (+) 1 ((+) 2 ((+) 3 (ourFoldr (+) 0 [4])))
= (+) 1 ((+) 2 ((+) 3 ((+) 4 (ourFoldr (+) 0 []))))
= (+) 1 ((+) 2 ((+) 3 ((+) 4 0)))
= (+) 1 ((+) 2 ((+) 3 4))
= (+) 1 ((+) 2 7)
= (+) 1 9
= 10
--}

-- Quiz question 1: How would you write ourSum tail-recursively?
-- Here's the original version again:

{--
ourSum :: [Int] -> Int
ourSum [] = 0
ourSum (x:xs) = x + ourSum xs
--}

-- Tail-recursive
ourSumTR :: [Int] -> Int
ourSumTR xs = helper xs 0
    where helper :: [Int] -> Int -> Int
          helper [] acc = acc
          helper (x:xs) acc = helper xs (x + acc)

-- Tail-recursive with foldl
ourSumTR' :: [Int] -> Int
ourSumTR' xs = ourFoldl (+) 0 xs

-- Eta reduction
-- \x -> f x == f

{--
Accumulate the result from the left!

ourFoldl (+) 0 [1, 2, 3, 4]
= ourFoldl (+) (0 + 1) [2, 3, 4]
= ourFoldl (+) ((0 + 1) + 2) [3, 4]
= ourFoldl (+) (((0 + 1) + 2) + 3) [4]
= ourFoldl (+) ((((0 + 1) + 2) + 3) + 4) []
= (((0 + 1) + 2) + 3) + 4
= ((1 + 2) + 3) + 4
= (3 + 3) + 4
= 6 + 4
= 10

--}

-- Quiz question 2:
-- What would this evaluate to?
-- foldr (++) "" ["coco", "moxie", "yuki"]

-- Quiz question 3:
-- What would this evaluate to?
-- foldl (++) "" ["coco", "moxie", "yuki"]

-- String concatenation is associative!
-- "a" ++ ("b" ++ "c") == ("a" ++ "b") ++ "c"