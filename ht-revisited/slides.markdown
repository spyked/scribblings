% Haskell Types Revisited
% Lucian Mogosanu
% 25.02.2015

# Type systems

*"Source code is for humans to read, and only incidentally for machines to run."*

* Tools for abstraction

* Tools for documentation

* Safeguards against errors

# "Advanced" type systems

Curry-Howard isomorphism:

* Proofs as programs

* Propositions as types

# Haskell typing philosophy

* Strong

* Static

* Algebraic

* "If it passes the type checker, then it's correct"

# Primitive types

~~~~ {.haskell}
3 :: Int
120894192912541294198294982 :: Integer
3.14 :: Float
'a' :: Char
"The cake is a lie" :: String
True :: Bool
~~~~

<!--
* `::` is similar to set membership ($\in$)
* **Intuition**: types are (a generalization of) sets
-->

# Basic type constructors

~~~~ {.haskell}
data Void
data Unit = MkUnit
data Bool = False | True
data Kg = MkKg Int -- newtype?
~~~~

<!--
* **Intuition**: constructors are functions that return a specific type
-->

# Canonical types

~~~~ {.haskell}
data Pair a b = Pair a b -- (a, b)
data Either a b = Left a | Right b
type Maybe a = Either Unit a -- Nothing | Just a

data Identity a = Identity a
data Const a b = Const a
~~~~

# Recursive data structures

~~~~ {.haskell}
data Nat =
    Z
  | S Nat

data List a =
    Empty
  | Cons a (List a)
~~~~

# Digression: type classes

~~~~ {.haskell}
class Eq a where
  (==) :: a -> a -> Bool
~~~~

~~~~ {.haskell}
instance Eq Bool where
  True  == True  = True
  False == False = True
  _     == _     = False
~~~~

# Digression: kinds

* Types also have types
* They are called **kinds**

~~~~ {.haskell}
> :k Bool
Bool :: *
> :k List 
List :: * -> *
> :k List Int
List Int :: *
~~~~

* Well-formed typed expressions have the kind `*`

# Type-level numbers

~~~~ {.haskell}
data Z
data S n
~~~~

~~~~ {.haskell}
class Card n where
~~~~

~~~~ {.haskell}
instance Card Z where
instance Card n => Card (S n) where
~~~~

# Fixed-length lists

~~~~ {.haskell}
newtype Vector n a = Vector
	{ fromVect :: List a }
~~~~

* `Vector` constructor is not sufficient
* Use smart constructors

# Fixed-length lists: smart constructors

~~~~ {.haskell}
newtype Vector n a = Vector
	{ fromVect :: List a }
~~~~

~~~~ {.haskell}
vnil :: Vector Z a
vnil = Vector Empty

vcons :: Card n => a -> Vector n a
                     -> Vector (S n) a
vcons x (Vector xs) = Vector (x `Cons` xs)
~~~~

# Fixed-length lists: useful functions

* `head` and `tail` are type safe

~~~~ {.haskell}
vhead :: Card n => Vector (S n) a -> a
vhead (Vector (Cons x _)) = x

vtail :: Card n => Vector (S n) a
                -> Vector n a
vtail (Vector (Cons _ xs)) = Vector xs
~~~~

# Fixed-length lists: problems

* `vappend`?

~~~~ {.haskell}
vappend :: Card n => Vector n a
                  -> Vector m a
				  -> Vector (n + m) a
~~~~

* Type family for `Z` and `S n`
* Undecidable instances 

# Conclusion

* [hackage.haskell.org/package/mono-traversable](https://hackage.haskell.org/package/mono-traversable)

* Dependently-typed languages: Idris, Agda, Coq
	* Require (mostly) manual typechecking!
