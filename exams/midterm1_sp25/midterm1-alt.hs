-- Haskell code for spring 2025 midterm (alternate version)

data BooList = BNil | BCons Bool BooList
  deriving (Show, Eq)

booListFlip :: BooList -> BooList
booListFlip BNil         = BNil
booListFlip (BCons x xs) = BCons (not x) (booListFlip xs)

booListAnd :: BooList -> Bool
booListAnd BNil         = True
booListAnd (BCons x xs) = x && booListAnd xs


booListFlipTests = [
         (booListFlip BNil, BNil),
         (booListFlip (BCons False (BCons True (BCons False BNil))), BCons True (BCons False (BCons True BNil)))]

booListAndTests = [                        
         (booListAnd BNil, True),
         (booListAnd (BCons True (BCons False BNil)), False),
         (booListAnd (BCons True (BCons True BNil)), True),
         (booListAnd (BCons False BNil), False)]

results = (map (\(x, y) -> x == y) booListFlipTests)
          ++
          (map (\(x, y) -> x == y) booListAndTests)
