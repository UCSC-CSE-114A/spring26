---
geometry: margin=1in
documentclass: extarticle
fontsize: 10pt
mainfont: Helvetica
mathfont: Helvetica
---

<!-- Build this file with `pandoc --pdf-engine=xelatex worksheet08.md -o worksheet08.pdf` -->
<!--
If the above command doesn't work due to missing fonts, use:
`pandoc --pdf-engine=xelatex -V 'mainfont:Arial' -V 'mathfont:Arial' worksheet08.md -o worksheet08.pdf`
-->

Name: ________________________________\quad CruzID:  _____________________________@ucsc.edu

# CSE114A Section Worksheet 8: Typing Derivations

In today's section, you'll practice working with typing derivations.  Turn in this worksheet to your TA when you're done (or when section ends, whichever comes first). You may leave as soon as you turn in the worksheet, or stay and help classmates if you want. If you need help, ask your TA or your classmates.

This worksheet assumes that you have already completed the previous worksheets. If you haven't yet, you can find older worksheets on Zulip (#announcements > Section worksheets).

## Part 1: Typing rules for our little language of strings

In lecture, we saw how to define a *typing relation* for a language, using a collection of *typing rules*.  Let's do this for the language that we've been working with in sections.  Consider a version of the language that has string literals, variables, `rev` (reverse) expressions, concatenation (`++`) expressions, function definitions, function calls, and `let`-expressions.  Here's our grammar of expressions:

```
e ::= s | x | rev e | e1 ++ e2 | \x -> e | e1 e2 | let x = e1 in e2
```

Our grammar of types has one base type, `Str`, as well as function types: `T ::= Str | T1 -> T2`.

We can now write typing rules to define the typing relation `G |- e :: T`, where `G` is a type environment, `e` is an expression, and `T` is a type. (We can pronounce `G |- e :: T` as "in type environment `G`, expression `e` has type `T`".) The T-Str rule says that a string literal `s` has type `Str`. The T-Rev rule says that an expression `rev e` has type `Str` as long as `e` has type `Str`.  The T-Cat rule says that an expression `e1 ++ e2` has type `Str` as long as both `e1` and `e2` have type `Str`.  Finally, the T-Var, T-Lam, T-App, and T-Let rules are what you've seen before in lecture.

```
                                  G |- e :: Str             G |- e1 :: Str    G |- e2 :: Str
[T-Str] -------------   [T-Rev] -----------------   [T-Cat] --------------------------------
        G |- s :: Str           G |- rev e :: Str                 G |- e1 ++ e2 :: Str

         (x,T) in G             (x,T1):G |- e :: T2 
[T-Var] -----------   [T-Lam] ------------------------
        G |- x :: T           G |- \x -> e :: T1 -> T2

        G |- e1 :: T1 -> T2    G |- e2 :: T1           G |- e1 :: T1    (x,T1):G |- e2 :: T2
[T-App] ------------------------------------   [T-Let] -------------------------------------
                  G |- e1 e2 :: T2                          G |- let x = e1 in e2 :: T2
```

Which rule proves that `"pikachu"` has type `Str`?
\newline
\framebox(480,30)
\newline

A *derivation tree* is when you stack up rules on top of each other, so the conclusion of one rule becomes a premise in the next rule.  For example (using `[]` as the empty type environment):

```
  [(a)] ----------------------
        [] |- "pikachu" :: Str
[(b)] ---------------------------
      [] |- rev "pikachu" :: Str
```	 

What are the names of rules (a) and (b)? Is the conclusion of rule (a) a valid premise in rule (b)?
\newline
\framebox(480,30)
\newline

## Part 2: Some more interesting derivations

Let's do some more interesting exercises. Here is a derivation tree with some missing rule names labeled (a)-(f), (h), (i), (l), and missing types labeled (g), (j), (k).  Fill in what (a) through (l) should be in the box below.

Let `G1 = [(x, Str)]` and `G2 = [(f, Str -> Str)]`.
```
       (x,Str) in G1           (f,Str->Str) in G2
  [(a)]--------------     [(b)]------------------- [(c)]-----------------
       G1 |- x :: Str          G2 |- f :: Str->Str      G2 |- "iH" :: Str
[(d)]------------------   [(e)]------------------------------------------ [(f)]------------------
     G1 |- rev x :: (g)                     G2 |- f "iH" :: Str                G2 |- " :D" :: Str
[(h)]------------------------          [(i)]-----------------------------------------------------
     [] |- \x -> rev x :: (j)                          G2 |- (f "iH") ++ " :D" :: (k)
[(l)]--------------------------------------------------------------------------------
               [] |- let f = \x -> rev x in (f "iH") ++ " :D" :: Str
```

\framebox(480,135)
\newline

A derivation tree for a typing judgment `G |- e :: T` constitutes a *proof* that `e` has type `T` (in type environment `G`).  When we implement a type checker or type inferencer for a programming language, the type checker/inferencer can be thought of as building the derivation tree that proves that a given `e` has a type `T` (although we don't keep the actual derivation tree around in a real type checker/inferencer).

Infer the type of the following program in an empty type environment by building its derivation tree:

`let g = \x -> x ++ x in \y -> g y`

(Hint: Find the rule that works. This will generate premises. Find the rules for those premises, and so on.)

\framebox(480,216)
\newline
