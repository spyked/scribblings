% Enforcing static invariants using Haskell's type checker
% Lucian Mogoșanu
% 27.08.2014

# A bit about what I do

**Research** (UPB/ACS)

* Improving the security of software systems

* In general, system software

* In particular, operating systems

# A bit about what I do

**Development** (VirtualMetrix)

* VMXL4, a "provably secure" microkernel/hypervisor

* Virtualization for mobile phones

# A bit about what I do

**Teaching** assistant (UPB/ACS) for the following courses:

* Programming Paradigms

* Operating System Security

* Advanced Operating Systems

# Some related work

seL4 microkernel

* Developed by UNSW/NICTA/General Dynamics

* Formally verified protection model and implementation

* Prototype written in Haskell

* Recently GPLed:
[https://github.com/seL4/seL4](https://github.com/seL4/seL4)

. . .

Is it deployed in the real world?

# Designing software using Haskell

Haskell is:

. . .

* Pure, lazy
* Strongly typed, statically-typed

. . .

Haskell's type system has the following particularities:

* Algebraic data types
* Parametric polymorphism
* Ad-hoc polymorphism

# Algebraic data types

Every Haskell type is

* Either a primitive type

* Or a sum of types

* Or a product of types

# Example 1: primitive types

~~~~ {.haskell}
3 :: Int
120894192912541294198294982 :: Integer
3.14 :: Float
'a' :: Char
"The cake is a lie" :: String
True :: Bool
~~~~

* `::` is similar to set membership ($\in$)
* **Intuition**: types are (a generalization of) sets

# Example 2: sum types

* Problem: encode an enumeration of fruits
* Suppose we wish to have **exactly** four types of fruit
	* Apples
	* Pears
	* Oranges
	* Tomatoes

# Example 2 in C

~~~~ {.c}
typedef enum {
	Apples = 1,
	Pears = 2,
	Oranges = 3,
	Tomatoes = 4
} fruit_e;
~~~~

Now we can say:

~~~~ {.c}
fruit_e fr = Tomatoes;
~~~~

# Example 2 in C

~~~~ {.c}
typedef enum {
	Apples = 1,
	Pears = 2,
	Oranges = 3,
	Tomatoes = 4
} fruit_e;
~~~~

But we can also say:

~~~~ {.c}
fruit_e fr = 5;
~~~~

# Example 2 in Haskell

~~~~ {.haskell}
data Fruit =
    Apples
  | Pears
  | Oranges
  | Tomatoes
~~~~

* `Fruit` is the type's name
* `|` is the **sum** type-level operator
* `Apples`, `Pears`, `Oranges`, `Tomatoes` are possible values
	* More generally, **constructors**

# Example 2 in Haskell

~~~~ {.haskell}
data Fruit =
    Apples
  | Pears
  | Oranges
  | Tomatoes
~~~~

~~~~ {.haskell}
> :t Apples
Apples :: Fruit
> 5 :: Fruit

<interactive>
  No instance for (Num Fruit) ..
~~~~

# Example 2 in Haskell

~~~~ {.haskell}
data Fruit =
    Apples
  | Pears
  | Oranges
  | Tomatoes
~~~~

* **Note**: we select **one of** the values in `Fruit`
* `|` is in general similar to `union`s
* **Intuition**: `|` is the logical equivalent of **or**

# Example 3: product types

* Problem: encode "a bucket of fruit"
* A bucket of fruit consists of:
	* A type of fruit
	* The quantity of fruit in the bucket

# Example 3

Possible approach: use built-in pairs

~~~~ {.haskell}
> :t (,)
(,) :: a -> b -> (a, b)
> (,) Pears 2 :: (Fruit, Int)
(Pears,2)
> (Pears, 2) -- sugar
(Pears,2)
~~~~

* `(,)` defines pairs of values
* **Note**: small letters denote **type variables**
	* **Parametric polymorphism**

# Example 3

~~~~ {.haskell}
data Bucket = MkBucket Fruit Int
~~~~

* `Bucket` is the type's name
* `MkBucket` is the **constructor**

~~~~ {.haskell}
> :t MkBucket
MkBucket :: Fruit -> Int -> Bucket
~~~~

# Example 3

* It may be useful to generalize
* In this case, `Fruit` is too particular

~~~~ {.haskell}
data Bucket a = MkBucket a Int
~~~~

# Example 3

* We can implicitly define field selectors
* ... by using record notation

~~~~ {.haskell}
data Bucket a = MkBucket
  { bucketObject  :: a
  , bucketQty     :: Int
  }
~~~~

~~~~ {.haskell}
> let myBucket = MkBucket Apples 10
> bucketQty myBucket
10
~~~~

# Example 3

* We can implicitly define field selectors
* ... by using record notation

~~~~ {.haskell}
data Bucket a = MkBucket
  { bucketObject  :: a
  , bucketQty     :: Int
  }
~~~~

* Type fields are similar to `struct`s
* **Intuition**: tuples are the logical equivalent of **and**

# Example 4: MultiBuckets

* What if we want to hold more than one type of fruit in a bucket?

~~~~ {.haskell}
> MkBucket (Pears, Apples) 50
~~~~

* ... but we can't distinguish between types of fruits

. . .

* **Idea**: `MultiBucket`s as lists of `Bucket`s

# Example 4

~~~~ {.haskell}
type MultiBucket a = [Bucket a]
~~~~

* `type` is similar to C's `typedef`
	* Type synonyms
* **Note**: synonyms are **not** subjected to type checking
	* E.g. `MultiBucket a` and `[Bucket a]` are the same thing

# Example 4

~~~~ {.haskell}
type MultiBucket a = [Bucket a]
~~~~

Extracting all the `Apple`s from a MultiBucket

~~~~ {.haskell}
> let mb = [MkBucket Apples 20,
  MkBucket Pears 30]
> head $
  filter (\ b -> bucketObject b == Apples ) mb
MkBucket {bucketObject = Apples, bucketQty = 20}
~~~~

# Example 4

~~~~ {.haskell}
type MultiBucket a = [Bucket a]
~~~~

What if there are no apples in the MultiBucket?

~~~~ {.haskell}
> let mb = [MkBucket Pears 30]
> head $
  filter (\ b -> bucketObject b == Apples ) mb
*** Exception: Prelude.head: empty list
~~~~

# Example 5: representing failure

~~~~ {.haskell}
data Maybe a = Nothing | Just a
~~~~

* `Nothing` is similar to `void`
* `Just` is a $1$-tuple that wraps values
* **Intuition**: return `Nothing` on failure

# Example 5

~~~~ {.haskell}
getBucket :: Fruit -> MultiBucket Fruit
                   -> Maybe (Bucket Fruit)
getBucket obj mb = case filter isEqual mb of
  []      -> Nothing
  (x : _) -> Just x
  where isEqual x = bucketObject x == obj
~~~~

* **Note**: `case` performs pattern matching on values
* **Note**: `[]` is the empty list `x : list` is a non-empty list

# Example 5

~~~~ {.haskell}
> let mb = [MkBucket Pears 30]
> getBucket Apples mb
Nothing
> getBucket Pears mb
Just (MkBucket
  {bucketObject = Pears, bucketQty = 30})
~~~~

# Example 5

We can make `getBucket` polymorphic:

~~~~ {.haskell}
getBucket :: Eq a => a -> MultiBucket a
                       -> Maybe (Bucket a)
~~~~

* Implementation stays the same
* `Eq a`: constraint imposed on `a` due to `(==)`

# Example 5

~~~~ {.haskell}
> :t (==)
(==) :: Eq a => a -> a -> Bool
~~~~

* `deriving` tries to automatically implement `(==)` for ADTs
* `Eq a` is a **type class** constraint
* **Ad-hoc polymorphism**:
	* `Eq a` $\equiv$ "all types `a` that implement `(==)`"

# Example 6: seL4 kernel objects

~~~~ {.haskell}
 data KernelObject 
     = KOEndpoint  Endpoint
     | KOAEndpoint AsyncEndpoint
     | KOKernelData
     | KOUserData
     | KOTCB       TCB
     | KOCTE       CTE
     | KOArch      ArchKernelObject
~~~~

# Example 6

~~~~ {.haskell}
data TCB = Thread {
        tcbCTable :: CTE,
        tcbVTable :: CTE,
        tcbReply :: CTE,
        tcbCaller :: CTE,
        tcbIPCBufferFrame :: CTE,
        tcbDomain :: Domain,
        tcbState :: ThreadState,
        ..
        tcbFaultHandler :: CPtr,
        tcbIPCBuffer :: VPtr,
        tcbContext :: UserContext }
    deriving Show
~~~~

# Example 7: natural numbers

`Bucket`s can have non-sensical values:

~~~~ {.haskell}
> :t MkBucket Apples (-2)
MkBucket Apples (-2) :: Bucket Fruit
~~~~

# Example 7

Possible approach: smart constructors

~~~~ {.haskell}
newtype Nat1 = Nat1 { fromNat1 :: Int }
~~~~

* `newtype` is like `data`, only
	* It has exactly one constructor
	* ... and exactly one field
* Additionally, it's erased at compile-time
	* No run-time overhead

# Example 7

Possible approach: smart constructors

~~~~ {.haskell}
mkNat :: Int -> Nat1
mkNat n = if n < 0
  then error "Only positive numbers are permitted"
  else Nat1 n
~~~~

* `mkNat` checks for positive numbers at run-time
* It provides **some** compile-time guarantees
	* All type conversions are explicit
	* Signedness is (a weak) invariant under `Nat1`

# Example 8: more naturals 

Possible approach: Peano naturals

~~~~ {.haskell}
data Nat2 = Z | S Nat2
~~~~

~~~~ {.haskell}
> :t Z -- 0
Z :: Nat2
> :t S $ S $ S Z -- 3
S $ S $ S Z :: Nat2
~~~~

# Example 8

Possible approach: Peano naturals

~~~~ {.haskell}
data Nat2 = Z | S Nat2
~~~~

* Very clunky and inefficient
* Works well for small enough numbers

# Example 9: even more naturals

Possible approach: type-level numbers

~~~~ {.haskell}
data Z
data S n
~~~~

* `Z` and `S n` are types encoding numbers!
* **Note**: `Z` and `S n` lack constructors

# Digression: kinds

* Types also have types
* They are called **kinds**

~~~~ {.haskell}
> :k Z
Z :: *
> :k S
S :: * -> *
> :k (S (S Z))
(S (S Z)) :: *
~~~~

* Well-formed typed expressions have the kind `*`

# Digression: type classes

~~~~ {.haskell}
class MyClass a where
  myMethod :: a -> Int

instance MyClass Int where
  myMethod = (+ 1) . fromIntegral
~~~~

~~~~ {.haskell}
> myMethod (42 :: Int)
42
~~~~

# Example 9

First we define cardinalities on type-level naturals

~~~~ {.haskell}
class Card n where

instance Card Z where
instance (Card n) => Card (S n) where
~~~~

* **Note**: computations are done purely at type-level
	* type class and instances have no methods

# Example 9

Next, we define a class for bound checking

~~~~ {.haskell}
class (Card n) => InBounds n where

instance InBounds (S Z) where
instance InBounds (S (S Z)) where
instance InBounds (S (S (S Z))) where
~~~~

# Example 9

Finally, we define a concrete type and a smart constructor

~~~~ {.haskell}
data MaxThree n = MaxThree
  deriving Show

maxthree :: InBounds n => n -> MaxThree n
maxthree _ = MaxThree
~~~~

* **Note**: We restrict smart constructor to `InBounds`

# Example 9

Some useful auxiliary functions

~~~~ {.haskell}
incr :: Card n => n -> S n
incr = undefined

d0 = undefined :: Z
d1 = incr d0
d2 = incr d1
d3 = incr d2
d4 = incr d3
~~~~

# Example 9

Testing

~~~~ {.haskell}
> maxthree d4

<interactive>
  No instance for (InBounds Z) ..
> maxthree d1
MaxThree
~~~~

# Example 9: conclusion

* We can perform compile-time checks on numbers

* However, it's very tedious to do that

* We can use dependently typed languages (e.g. Idris) as an alternative

# Haskell extensions for static checking

* Functional dependencies  
[http://haskell.org/haskellwiki/Functional_dependencies](http://www.haskell.org/haskellwiki/Functional_dependencies)
* Contract checking  
[http://research.microsoft.com/en-us/um/people/simonpj/papers/verify/index.htm](http://research.microsoft.com/en-us/um/people/simonpj/papers/verify/index.htm)  
[http://goto.ucsd.edu/~rjhala/liquid/haskell/blog/about/](http://goto.ucsd.edu/~rjhala/liquid/haskell/blog/about/)

# Extra example: non-empty lists

`head` and `tail` are unsafe

~~~~ {.haskell}
> let xs = []
> head xs
*** Exception: Prelude.head: empty list
> tail xs
*** Exception: Prelude.tail: empty list
~~~~

# Extra example

We can make them safe by encoding non-emptiness in the program logic

~~~~ {.haskell}
data NonEmpty a = a :| [a] -- Data.List.NonEmpty
~~~~

~~~~ {.haskell}
> let xs = 1 :| [2,3,4]
> -- provably non-empty
> head xs
1
~~~~

* **Note**: This can make coding more difficult!

# Extra example

Generalization using type-level numbers: `mono-traversable`

~~~~ {.haskell}
cadr :: MinLen (Succ (Succ nat)) [a] -> a
cadr = ML.head . ML.tailML
~~~~

~~~~ {.haskell}
> let xs = mlcons 3 $ mlcons 2 $ toMinLenZero []
> cadr xs
2
~~~~

# Extra example

Generalization using type-level numbers: `mono-traversable`

~~~~ {.haskell}
-- this fails at compile-time!
> let xs = mlcons 2 $ toMinLenZero []
> cadr xs

<interactive>
  Couldn't match type `Zero' with `Succ nat0'
  Expected type: MinLen (Succ (Succ nat0)) .. 
  Actual type: MinLen (Succ Zero) ..
~~~~
