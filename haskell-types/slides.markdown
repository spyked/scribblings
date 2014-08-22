% Enforcing static invariants using Haskell's type checker
% Lucian Mogoșanu
% 27.08.2014

# Questions

* What are types?

* Why do we need types/type checking?

* How do we make a friend of Haskell types?

# Sample code

~~~~ {.haskell}
data Bla = Bla
  deriving (Show, Eq)

myfunc :: Int -> Maybe Int
myfunc = undefined

"yadda" :: String
~~~~
