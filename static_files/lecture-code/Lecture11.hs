{-# LANGUAGE BangPatterns #-}

-- Welcome to lecture 11! 

{--
Agenda:

- Tail recursion in Haskell

--}

-- Here's the `duplicateAll` function that the section
-- worksheet claimed we saw in lecture last week.
-- Better late than never!

-- Not tail-recursive!
duplicateAll :: [a] -> [a]
duplicateAll []     = []
duplicateAll (x:xs) = x : x : duplicateAll xs

-- Take a list of anything and return its length
-- Quiz question 1: what should the type of `len` be?

-- `len` doesn't call itself last!
-- it calls `(+)` last.
-- Not tail-recursive. 
len :: [a] -> Int
len []     = 0
len (_:xs) = 1 + len xs

{-- 
Let's visualize the execution of a call to `len`

len [1, 2, 3, 4]
= 1 + (len [2, 3, 4])
= 1 + (1 + len [3, 4]))
= 1 + (1 + (1 + len [4])))
= 1 + (1 + (1 + (1 + len []))))
= 1 + (1 + (1 + (1 + 0)))
= 1 + (1 + (1 + 1))
= 1 + (1 + 2)
= 1 + 3
= 4
--}

-- Let's add an accumulator argument to `len`.
-- `len'` is tail-recursive,
-- which means that every recursive call to `len'`
-- is in tail position,
-- meaning that it's the last thing the function does. 
len' :: [a] -> Int -> Int
len' []     !acc = acc
len' (_:xs) !acc = len' xs (acc + 1)

{--

Let's visualize the execution of a call to len'

len' [1, 2, 3, 4] 0
= len' [2, 3, 4] (0 + 1)
= len' [2, 3, 4] 1
= len' [3, 4] (1 + 1)
= len' [3, 4] 2
= len' [4] (2 + 1)
= len' [4] 3
= len' [] (3 + 1)
= len' [] 4
= 4

But because of lazy evaluation, that is not quite what happened.
Because the `acc` argument is evaluated lazily, it's more like this:

len' [1, 2, 3, 4] 0
= len' [2, 3, 4] (0 + 1)
= len' [3, 4] ((0 + 1) + 1)
= len' [4] (((0 + 1) + 1) + 1)
= len' [] ((((0 + 1) + 1) + 1) + 1)
...
= 4
--}

-- A situation where laziness is your friend

fifth :: [a] -> a
fifth (_:_:_:_:x:_) = x
fifth _             = error "no fifth element"