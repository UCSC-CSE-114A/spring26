-- Welcome to lecture 14!

{--

Agenda:

- Intro to higher-order functions
- Some useful higher-order functions to know:
  - filter
  - map
--}

{--

Higher-order functions are functions that either
- take functions as arguments <-- what people usually mean by HOFs
- return functions as return values
- (or both!)

--}

-- find the first element in a list that satisfies a given predicate
-- A predicate is a function that returns true or false.
-- We'll also have to take the predicate we want to use as an argument.
-- We'll have to take a list of "whatever" as an argument.

-- Haskell has this built in, and it's called `Maybe`,
-- but we're defining our own just for fun. 
data ThisMightExist a = NopeThisDoesntExist | YesThisExists a
    deriving Show

find :: (a -> Bool) -> [a] -> ThisMightExist a
find predicate []     = NopeThisDoesntExist
-- We could've used pattern guards here too, btw
find predicate (x:xs) = if predicate x then YesThisExists x else find predicate xs

-- An example predicate:
isEven :: Int -> Bool
isEven n = n `mod` 2 == 0

isYuki :: String -> Bool
isYuki "yuki" = True
isYuki _      = False

isNotYuki :: String -> Bool
isNotYuki "yuki" = False
isNotYuki _      = True

-- Let's say I want to write a function that takes a list of `Int`s
-- and filters out all the odd ones.

evensOnly :: [Int] -> [Int]
evensOnly []     = []
evensOnly (x:xs) | even x    = x : evensOnly xs
                 | otherwise = evensOnly xs

fourOnly :: [String] -> [String]
fourOnly []      = []
fourOnly (x:xs) | length x == 4 = x : fourOnly xs
                | otherwise     = fourOnly xs

{--
What are the differences between `evensOnly` and `fourOnly`?
- The predicates, aka the guard expression
  - To generalize this, let's pass in a function of type `a -> Bool`
- The type of the list elements
  - To generalize this, let's have the list have elements of type `a`
--}

-- This is identical to the standard library `filter` function
myFilter :: (a -> Bool) -> [a] -> [a]
myFilter _ []     = []
myFilter f (x:xs) | f x       = x : myFilter f xs
                  | otherwise = myFilter f xs

-- We're partially applying the `myFilter` function. 
evensOnly' :: [Int] -> [Int]
evensOnly' = myFilter even

-- Your turn: Quiz question 2: write fourOnly in terms of `myFilter` (Hint: it's one line.)
fourOnly' :: [String] -> [String]
fourOnly' = myFilter (\x -> length x == 4)

-- Another famous higher-order function: `map`

squares :: [Int] -> [Int]
squares [] = []
squares (x:xs) = x*x : squares xs

-- Take a list of `Int`s and produce a list of `Bool`s that tell us
-- whether the corresponding `Int` is divisible by 3.
divisibleBy3 :: [Int] -> [Bool]
divisibleBy3 [] = []
divisibleBy3 (x:xs) = (x `mod` 3 == 0) : divisibleBy3 xs

{--
How do we generalize this pattern? We can do this with `map`!
It takes a function and a list, and applies the function to every element in the list,
giving us a new list.
--}

-- This is identical to the standard library `map` function
myMap :: (a -> b) -> [a] -> [b] 
myMap _ []     = []
myMap f (x:xs) = f x : myMap f xs

squares' :: [Int] -> [Int]
squares' = myMap (\x -> x * x)
divisibleBy3' :: [Int] -> [Bool]
divisibleBy3' = myMap (\x -> x `mod` 3 == 0)

-- Take a list of predicates, apply them all to the string "yuki",
-- and return a list of the results

applyAllToYuki :: [String -> Bool] -> [Bool]
applyAllToYuki = myMap (\f -> f "yuki")