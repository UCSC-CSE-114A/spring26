-- Welcome to lecture 10!

{--

Agenda:

- Product types, sum types, recursive types
- Some Haskell features we'll encounter: multiple pattern guards, `where` clauses

--}

-- Let's create a "database" of everyone's pets!
-- In Haskell we can use the `data` keyword to define a type.

-- Here `PetRec` is the *data constructor* for data
-- of type `PetRecord`.
-- A data constructor is a function you can call to construct
-- data of a particular type.

-- Pet name, human name, pet type, pet age
data PetRecord = PetRec String String PetType PetAge
    deriving Show 

data PetType = Dog | Cat | Rabbit
    deriving Show

data PetAge = IntAge Int | SadlyDeceased | Unspecified
    deriving Show

-- `PetRecord` is a *product type*
-- because it's the cross product
-- String x String x String x Int

-- `PetType` and `PetAge` are *sum types*
-- because they're sums of sets

database :: [PetRecord]
database = [PetRec "onyx" "nathan" Cat Unspecified,
            PetRec "mochi" "nathan" Cat Unspecified,
            PetRec "sasuke" "michael" Cat (IntAge 3),
            PetRec "aspen" "angela" Cat Unspecified,
            PetRec "snowy" "ashwin" Rabbit (IntAge 7),
            PetRec "speedy" "ashwin" Rabbit SadlyDeceased]

-- getPetsByOwner should take a pets database and a pet owner's name
-- and return a list of that owner's pet's names. 

-- Quiz question 1: what should the type signature of `getPetsByOwner` be?

getPetsByOwner :: [PetRecord] -> String -> [String]
getPetsByOwner []     _     = [] -- Show that the second argument doesn't matter by using `_` for it
getPetsByOwner (PetRec name human _ _:xs) owner | human == owner = name : rest
                                                | otherwise    = rest
    where rest = getPetsByOwner xs owner

-- The `where` clause above defines a binding that is only in scope within the definition of
-- `getPetsByOwner`. 

-- What if we had to define our own list type?
-- Just for lists of strings, to keep it simple. 
-- This is a recursive type because it refers to itself!
-- data StringList = Empty | (Quiz question 2: what should go here?)
data StringList = Empty | NotEmpty String StringList

-- We could do this if we want:
data PetDB = EmptyDB | NonEmptyDB PetRecord PetDB
-- but we'll stick with Haskell lists of `PetRecord`s for now!