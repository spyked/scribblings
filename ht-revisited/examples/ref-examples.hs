{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
import Prelude (Num(..), Show(..), Int, Char, String, undefined)

-- Some basic types to illustrate constructors
data Void
data Unit = MkUnit
data Bool = False | True deriving Show
data Weight = MkWeight Int

-- Canonical ADTs
data Pair a b = Pair a b
data Either a b = Left a | Right b
-- data Maybe a = Nothing | Just a
type Maybe a = Either Unit a

data Identity a = Identity a
data Const a b = Const a

-- Recursive data types
data Nat = Z | S Nat
data List a = Empty | Cons a (List a)
  deriving Show

append :: List a -> List a -> List a
append Empty l2       = l2
append (Cons x l1) l2 = Cons x (append l1 l2)

-- This is an incorrect definition of append which compiles and can incorrectly
-- pass as "good" behaviour. Thus we need to consider append to be an axiom.
--append Empty l2       = case l2 of
--  Empty -> l2
--  Cons x _ -> Cons x l2

class Eq a where
  (==) :: a -> a -> Bool

instance Eq Bool where
  True == True   = True
  False == False = True
  _ == _         = False

instance Eq Nat where
  Z == Z = True
  S n1 == S n2 = n1 == n2
  _ == _ = False


data Z
data S n

class Card n where

instance Card Z where
instance Card n => Card (S n) where

type family AddNat x y
type instance AddNat Z y = y
type instance AddNat (S x) y = AddNat x (S y)

newtype Vector n a = Vector { fromVect :: List a }
  deriving Show

vnil :: Vector Z a
vnil = Vector Empty

vcons :: Card n => a -> Vector n a -> Vector (S n) a
vcons x (Vector xs) = Vector (x `Cons` xs)

vhead :: Card n => Vector (S n) a -> a
vhead (Vector (Cons x _)) = x

vtail :: Card n => Vector (S n) a -> Vector n a
vtail (Vector (Cons _ xs)) = Vector xs

vappend :: Card n => Vector n a -> Vector m a -> Vector (AddNat n m) a
vappend (Vector l1) (Vector l2) = Vector (l1 `append` l2)
