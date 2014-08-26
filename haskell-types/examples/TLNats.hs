{-# LANGUAGE FlexibleInstances #-}
data Z
data S n

class Card n where

instance Card Z where
instance (Card n) => Card (S n) where

class (Card n) => InBounds n where

instance InBounds (S Z) where
instance InBounds (S (S Z)) where
instance InBounds (S (S (S Z))) where

data MaxThree n = MaxThree
  deriving Show

maxthree :: InBounds n => n -> MaxThree n
maxthree _ = MaxThree

incr :: Card n => n -> S n
incr = undefined

d0 = undefined :: Z
d1 = incr d0
d2 = incr d1
d3 = incr d2
d4 = incr d3
d5 = incr d4
d6 = incr d5
d7 = incr d6
