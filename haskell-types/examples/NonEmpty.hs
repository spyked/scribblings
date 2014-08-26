import Data.List.NonEmpty as NE
import Data.MinLen as ML
import Data.MonoTraversable

myList = 1 :| [2, 3, 4]

cadr :: MinLen (Succ (Succ nat)) [a] -> a
cadr = ML.head . ML.tailML

-- try = cadr $ mlcons 2 $ toMinLenZero []
