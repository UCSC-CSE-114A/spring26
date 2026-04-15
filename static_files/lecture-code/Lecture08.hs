-- Welcome to lecture 8!

{--
Agenda:

- First steps with Haskell
- Working with lists
- Writing functions (especially with pattern matching)
- Pattern guards
- If time: maybe more stuff?

--}

message :: String
message = "Welcome to lecture 8!"

{--
Lists!

In Haskell, a list is either
- An empty list, `[]` (pronounced "nil", or "empty list")
- An *element*, followed by...a list!
  This kind of list is constructed with the list constructor, `(:)`,
  pronounced "cons" (short for "construct list")!

ghci> []
[]
ghci> ["yuki", "moxie", "pepper"]
["yuki","moxie","pepper"]
ghci> "pepper":[]
["pepper"]
ghci> "moxie":"pepper":[]
["moxie","pepper"]

ghci> "yuki":"moxie":"pepper":[]
["yuki","moxie","pepper"]
ghci> ["yuki", "moxie", "pepper"]
["yuki","moxie","pepper"]
ghci> "yuki":["moxie", "pepper"]
["yuki","moxie","pepper"]
ghci> (:) "yuki" ["moxie", "pepper"]
["yuki","moxie","pepper"]
--}

-- Let's port our lecture 7 code to Haskell:
-- let TRI = \n -> ITE (ISZ n)
--                     ZERO
--                     (ADD n (TRI (DECR n)))

-- Not very idiomatic:
-- tri :: Int -> Int
-- tri = \n -> if n == 0 then 0 else n + tri (n-1)

-- More idiomatic, but still not very idiomatic:
-- tri :: Int -> Int
-- tri n = if n == 0 then 0 else n + tri (n-1)

{--
What we really want here is to use *pattern matching*
instead of if ... then ... else.

In Haskell typically we write a function
as a sequence of equations.  Haskell will try to match the arguments
against the *pattern* in each equation and will use the first one that matches.
--}
tri :: Int -> Int -- This is a *type signature*
tri 0 = 0
tri n = n + tri (n-1)

-- Let's write a function that operates on lists!
-- I want this function to take two lists of `Int`s
-- and return one list of `Int`s that gloms the arguments together.
-- Quiz question 1: what's the return type? It's `[Int]`, of course!

-- Why do you suppose type signatures are written this way?
appendIntLists :: [Int] -> [Int] -> [Int]
appendIntLists []      ys = ys -- Here `ys` is a pattern that matches anything
appendIntLists (x:xs)  ys = x : xs `appendIntLists` ys

-- We can write a safer version of `tri` like this:
-- We use a *pattern guard* to match against negative numbers!
safeTri :: Int -> Int -- This is a *type signature*
safeTri n | n < 0 = error "please don't call me with negative numbers kthx"
safeTri 0 = 0
safeTri n = n + safeTri (n-1)

-- Quiz question 2: What would happen if I didn't put the parens
-- around n-1 on line 85 above and why?