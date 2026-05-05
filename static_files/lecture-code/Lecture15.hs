-- Welcome to lecture 15!

{--

Agenda:

- Quick recap of last time
- More higher-order functions: foldr and foldl
- Tuples in Haskell

--}

-- Take a list of `Int`s and return their sum
sum' :: [Int] -> Int
sum' [] = 0 
sum' (x:xs) = x + sum' xs

-- Take a list of `String`s and concatenate them
concat' :: [String] -> String
concat' [] = ""
concat' (x:xs) = x ++ concat' xs

-- Take a list of lists and return their total length
lengthAll :: [[a]] -> Int
lengthAll [] = 0
lengthAll (x:xs) = length x + lengthAll xs

{-- 
What's the same about all these?

- They all take a list argument, but the lists are of different types
  - To generalize this: we need a polymorphic list argument, so something of type `[a]`.
- They all have a base case, but the base value is different
  - To generalize this: we need an argument that'll tell us what to return in the base case.
    We'd better give it type `b`.  This had better be our function's return type too. 
- They all make a recursive call on the tail of the list. 
- They're all combining the result of the recursive call with something,
  but they all do it in different ways. 
  - To generalize this: we need to pass in a function that does this.
    It'll be a two-argument function, where the arguments are of type `a` and `b`,
    It'll have to return something of type `b`.
--}

myFoldr :: (a -> b -> b) -> b -> [a] -> b
myFoldr f b []     = b
myFoldr f b (x:xs) = f x (myFoldr f b xs)

-- Quiz question 1:
-- Write `sum` in terms of `myFoldr`. (Hint: it's one line.)

sum'' :: [Int] -> Int
sum'' = myFoldr (+) 0

concat'' :: [String] -> String
concat'' = myFoldr (++) ""

-- Quiz question 2: 
-- Write `lengthAll` in terms of `myFoldr`.

lengthAll' :: [[a]] -> Int
lengthAll' = myFoldr (\l s -> length l + s) 0

-- Pattern matching on tuples
third :: (String, String, String) -> String
third (_, _, x) = x 

-- Take a list of tuples of strings and concatenate them all.
concatTuples :: [(String, String, String)] -> String
concatTuples = foldr (\(t1, t2, t3) r -> t1 ++ t2 ++ t3 ++ r) ""