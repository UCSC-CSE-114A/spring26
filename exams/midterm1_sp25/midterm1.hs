-- Haskell code for spring 2025 midterm

data StrList = Nil | Cons String StrList
  deriving (Show, Eq)

strListLength :: StrList -> Int
strListLength Nil           = 0
strListLength (Cons _ xs) = 1 + strListLength xs

strListAppend :: StrList -> StrList -> StrList
strListAppend Nil         ys = ys
strListAppend (Cons x xs) ys = Cons x (strListAppend xs ys)


strListLengthTests = [
         (strListLength Nil, 0),
         (strListLength (Cons "phoebe" (Cons "sam" (Cons "larry" Nil))), 3)]

strListAppendTests = [                        
         (strListAppend Nil Nil, Nil),
         (strListAppend (Cons "james" (Cons "nella" Nil)) Nil, Cons "james" (Cons "nella" Nil)),
         (strListAppend (Cons "james" (Cons "nella" Nil)) (Cons "mo" Nil), Cons "james" (Cons "nella" (Cons "mo" Nil))),
         (strListAppend (Cons "james" Nil) (Cons "nella" (Cons "mo" Nil)), Cons "james" (Cons "nella" (Cons "mo" Nil)))]

results = (map (\(x, y) -> x == y) strListLengthTests)
          ++
          (map (\(x, y) -> x == y) strListAppendTests)
