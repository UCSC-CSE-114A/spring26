-- Welcome to lecture 12!

{--
Agenda:

- What to expect next Monday
- Return to user-defined types
- A little preview of where we're headed

--}

-- Quiz question 1:
-- Using recursive types, how can we define a Haskell data type
-- for binary trees of `Int`s, where the `Int`s are stored
-- only at the leaves of the tree?

-- Quiz question 2:
-- What would I change about this type if I also wanted to store
-- `Int`s at the internal nodes of the tree?

data Tree = BinaryTree Int Tree Tree | Leaf Int | EmptyTree
    deriving Show

-- Pet name, human name, pet type, pet age
data PetRecord = PetRec String String PetType PetAge
    deriving Show 

data PetType = Dog | Cat | Rabbit | Bird 
    deriving Show

data PetAge = IntAge Int | SadlyDeceased | Unspecified
    deriving Show

database :: [PetRecord]
database = [PetRec "onyx" "nathan" Cat Unspecified,
            PetRec "mochi" "nathan" Cat Unspecified,
            PetRec "sasuke" "michael" Cat (IntAge 3),
            PetRec "aspen" "angela" Cat Unspecified,
            PetRec "snowy" "ashwin" Rabbit (IntAge 7),
            PetRec "speedy" "ashwin" Rabbit SadlyDeceased]

getPetsByOwner :: [PetRecord] -> String -> [String]
getPetsByOwner []                         _     = [] -- Show that the second argument doesn't matter by using `_` for it
getPetsByOwner (PetRec name human _ _:xs) owner | human == owner = name : rest
                                                | otherwise    = rest
    where rest = getPetsByOwner xs owner


data PetDB = Empty | NotEmpty PetRecord PetDB
    deriving Show 

-- A verbose and awkward way to represent pet databases
-- but we wrote it ourselves instead of relying on Haskell's built in list type. 
database' :: PetDB
database' = 
    NotEmpty (PetRec "onyx" "nathan" Cat Unspecified)
        (NotEmpty (PetRec "mochi" "nathan" Cat Unspecified)
            (NotEmpty (PetRec "sasuke" "michael" Cat (IntAge 3))
                (NotEmpty (PetRec "aspen" "angela" Cat Unspecified) Empty)))

getPetsByOwner' :: PetDB -> String -> [String]
getPetsByOwner' Empty              _ = []
getPetsByOwner' (NotEmpty (PetRec name human _ _) xs) owner | human == owner = name : rest
                                                            | otherwise      = rest
    where rest = getPetsByOwner' xs owner 

-- Get all names of pets with an unspecified age
unspecifiedPets :: PetDB -> [String]
unspecifiedPets Empty = []
unspecifiedPets (NotEmpty (PetRec name _ _ Unspecified) restOfDB) = name : unspecifiedPets restOfDB
unspecifiedPets (NotEmpty _ restOfDB) = unspecifiedPets restOfDB


