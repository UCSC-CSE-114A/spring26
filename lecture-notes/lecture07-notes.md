# CSE114A lecture 7

Agenda:

- Product types, sum types, recursive types
- Some Haskell features we'll encounter along the way: multiple pattern guards, `where` clauses
- Break/quiz
- Defining and working with abstract syntax trees
- Comments on hw0

## Product types

Let's create a toy database of everyone's pets in CSE114A.

We want to keep track of particular information about each pet, like name, owner, species, age, and maybe other things, and store that information together in a database record.

The goal is to be able to write code to answer questions like "how many people have a cat?" and "who has the oldest pet?"

In statically typed languages, a nice way to do that is to define our own type for these database records.

In Haskell we can define a type using the `data` keyword:


```
data PetRecord = PetRec String String String Int
```

Here, `PetRecord` is the new type we're defining.  A `PetRecord` contains a `String` for the pet's name, a `String` for the owner's name, a `String` for the species of pet, and an `Int` for the pet's age.

`PetRec` is what we call a *data constructor* for data of type `PetRecord`.  Think of it as a special kind of function.  The only way to get a value of type `PetRecord` is to call the `PetRec` data constructor and pass it arguments.

We can do this in GHCi:

```
ghci> PetRec "rainbow" "lindsey" "cat" 3
```

However, GHCi will give us an error: "No instance for `(Show PetRecord)`.  This isn't a serious problem with our code; our code is not ill-typed.  (We could run the command `:t PetRec "rainbow" "lindsey" "cat" 3` to convince ourselves that it is in fact a well-typed expression with type `PetRecord`.)

Instead, the "No instance for `(Show PetRecord)` error just means that GHC doesn't know how to *print out* a `PetRecord`.  This is not too surprising, since `PetRecord` is a type we just made up ourselves.

We can fix that in a simple way by adding a magic incantation `deriving Show` to the definition of the `PetRecord` type.  This just tells GHC to just do its best to print `PetRecord`s in a boring, default way.

(In the future, instead of using `deriving Show`, we might want to define our own custom ways to print things, and we'll talk about how to do that in a future lecture.)

Now we can print `PetRecord`s:

```
ghci> PetRec "rainbow" "lindsey" "cat" 3
PetRec "rainbow" "lindsey" "cat" 3
ghci> PetRec "sprinkles" "lindsey" "cat" 4
PetRec "sprinkles" "lindsey" "cat" 4
```

These `PetRecord` things are known as *product types*.  Why?

One way to think of a type is as a set of values.  For instance, the type `String` is the set of all strings.

So, the type `PetRecord`, because it puts together a bunch of sets:

```
data PetRecord = PetRec String String String Int
```

it can be thought of as the *cross product* of all those sets.  In a mathematical sense, elements of the set `PetRecord` are elements of the set `String` x `String` x `String` x `Int`.  Lots of languages support product types in one way or another.

So let's put our `PetRecord`s together into a database.  To keep things simple, our database will just be a list of `PetRecord`s.

I'm just guessing at the ages of Niko's cats because I need to put something there.  That's a little unsatisfying.  We'll come back to that later.

```
database :: [PetRecord]
database = [
    PetRec "rainbow"   "lindsey" "cat"  3,
    PetRec "sprinkles" "lindsey" "cat"  4,
    PetRec "kona"      "niko"    "cat" 10,
    PetRec "batman"    "niko"    "cat"  4,
    PetRec "bowie"     "niko"    "cat"  4] 
```

Here I've defined a top-level binding to the variable `database`, and given it the type `[PetRecord]` -- which is just a list of `PetRecord`s.  Now we can write functions that operate on it, like we'd be able to do with any list, as we saw in the last lecture.

```
-- `getPetsByOwner` takes a pets database and a pet owner's name,
-- and returns a list of that owner's pets
getPetsByOwner :: [PetRecord] -> String -> [String]
getPetsByOwner [] _ = []
getPetsByOwner (PetRec name o _ _:xs) owner = 
    if o == owner 
        then name : getPetsByOwner xs owner 
        else getPetsByOwner xs owner
```

In particular, we can pattern-match on the fields of a record.  Here we only care about what's in the first and second fields, and so the other ones can just be underscores.

This is OK, but we can make it more idiomatic. Let's refactor it little by little.

(use as a vehicle to introduce multiple pattern guards, `otherwise`, and `where` clauses)

```
-- Using multiple pattern guards and a `where` clause
getPetsByOwner' :: [PetRecord] -> String -> [String]
getPetsByOwner' [] _ = []
getPetsByOwner' (PetRec n o _ _:xs) owner | sameOwner o owner = n : rest 
                                          | otherwise         = rest
    where rest = getPetsByOwner' xs owner
          sameOwner :: String -> String -> Bool
          sameOwner s s' = s == s'
```

We've seen pattern guards before, but we only wrote one per equation in the definition of a function.  We can actually have as many different pattern guards as we want in a single equation.  Haskell will evaluate these in the order they appear and will go with the first one that evaluates to `True`.

A useful pre-defined pattern guard in the standard library is `otherwise`.  This is just a synonym for `True`!  So it's a pattern guard that always evaluates to `True`, and it's good to put last in a list of pattern guards as a catch-all pattern.  It makes guards a little more readable.

Finally, our code is a little repetitive, so we can factor out the repetitive parts with a `where` clause.  This will let us define bindings that are only in scope within the definition of another binding.

You can put multiple bindings in a `where` clause, and they'll be local to the binding that the `where` clause is attached to.  We could even factor `sameOwner` out into a function, though it'd be a little silly.

## Sum types

OK, so we saw an example of a product type, our `PetRecord` type.  But there was something a little dissatisfying about how we had to define our pets database.  We had to make up an age for some pets even though we didn't know what it was, because the type we were using to represent age was just `Int`.  

It seems like we need a more expressive type for representing pet ages.  So let's define one!

For this, instead of a product type, which puts multiple types together into one type, we want a type that says that something is one of a list of distinct options.

In this case, for some pets we know their age as an `Int` and for others we might just have a string.  So let's do that.

```
data PetAge = IntAge Int | ApproxAge String
```

In Haskell, we can define these types using a vertical bar to separate the distinct optsions.

This is known as a *sum type* , because in a mathematical sense, elements of the set `PetAge` are the sum of two sets: the set of elements of `Int`, and the set of elements of `String`.

One really useful thing to do with sum types is for situations where you might have something and might have nothing.  For instance, for some of the pets in our pets database we might have *no* age information.  But that's not a problem, we can just add a case for that.

```
data PetAge = IntAge Int | ApproxAge String | Unspecified
```

The `Unspecified` data constructor doesn't need to take any arguments.

Now we can add more pets to our database.
```
database :: [PetRecord]
database = [
    PetRec "rainbow"   "lindsey" "cat"  (IntAge 3),
    PetRec "sprinkles" "lindsey" "cat"  (IntAge 4),
    PetRec "kona"      "niko"    "cat"  (ApproxAge "older"),
    PetRec "batman"    "niko"    "cat"  (ApproxAge "younger"),
    PetRec "bowie"     "niko"    "cat"  (ApproxAge "younger"),
    PetRec "edelman"   "maya"    "cat"  Unspecified]
```

## Recursive types

So, we have a database where we're making use of product types for the database records, and sum types for some of the fields in the database.  But this data has a "flat" definition.  Sometimes we want to deal with inductively defined data.

In fact, we've already been dealing with inductively defined data in Haskell from day one.  Think of lists.  There are two things that a list can be:

- an empty list
- an element, together with a list

and in Haskell, we construct those two types of lists with the `[]` constructor and the `:` constructor, respectively.  Every list is either an empty list, or it's a list assembled one element at a time with `:`.

Lists are built into Haskell, but if we had to define a list type, how would we do it?  Let's suppose we just want the type of lists of `String`s, just to make it easy.

```
data StringList = ...
```

Since there are two things that a list can be, it seems like we should use a sum type, right?  And the first alternative is just going to be `Empty`.  The constructor for an empty list doesn't need to take any arguments.

```
data StringList = Empty | ... 
```

What about the other one?  Well, it needs a name.  Let's call it...`NonEmpty`.  And then what should the `NonEmpty` constructor take?

We said it before: "an element, together with a list".  So now we end up with this:

```
data StringList = Empty | NonEmpty String StringList
```

This is a *recursive type* because it refers to itself.

We've now used all three concepts, product types, sum types, and recursive types, here in the definition of `StringList`. `StringList` is a sum type: its elements are either `Empty` or `NonEmpty`.  And `NonEmpty` values have product types: they put a `String` together with a `StringList`.

This is exactly how lists are defined in the Haskell standard library, except instead of being named `Empty` and `NonEmpty`, the constructors are named "nil" and "cons", respectively, and they're spelled like `[]` and `(:)`, respectively.

If we wanted to, at this point we could define our own recursive type for our pets database, instead of just using the built-in Haskell list type.  It would honestly be more awkward than using the built-in list type from the standard library, but we could do it!

```
data PetDB = Empty | NonEmpty PetRecord PetDB
  deriving Show

database :: PetDB
database = NonEmpty (PetRec "rainbow" "lindsey" "cat"  (IntAge 3))
                    (NonEmpty (PetRec "rainbow" "lindsey" "cat"  (IntAge 3))
                              (NonEmpty (PetRec "sprinkles" "lindsey" "cat"  (IntAge 4))
                                        (NonEmpty (PetRec "kona" "niko" "cat" (ApproxAge "older"))
                                                  Empty)))

-- `getPetsByOwner` takes a pets database and a pet owner's name,
-- and returns a list of that owner's pets
getPetsByOwner :: PetDB -> String -> [String]
getPetsByOwner Empty _ = []
getPetsByOwner (NonEmpty (PetRec n o _ _) xs) owner = 
    if o == owner 
        then n : getPetsByOwner xs owner 
        else getPetsByOwner xs owner

-- Using multiple pattern guards and a `where` clause
getPetsByOwner' :: PetDB -> String -> [String]
getPetsByOwner' Empty _ = []
getPetsByOwner' (NonEmpty (PetRec n o _ _) xs) owner | sameOwner o owner = n : rest 
                                                     | otherwise         = rest
    where rest = getPetsByOwner' xs owner
          sameOwner :: String -> String -> Bool
          sameOwner s s' = s == s'

-- Get all pets with an approximate age of "younger"
youngerPets :: PetDB -> [String]
youngerPets Empty = []
youngerPets (NonEmpty (PetRec n _ _ (ApproxAge "younger")) xs) = n : youngerPets xs
youngerPets (NonEmpty _ xs) = youngerPets xs
```

The reason we're spending time on recursive types is not because we want to write our own version of Haskell's list type; that'd be silly.

Rather, we're spending time on recursive types because we ultimately want to implement programming languages, and to do that, we need a data type for expressions in a programming language, and we'll use recursive types for that.
