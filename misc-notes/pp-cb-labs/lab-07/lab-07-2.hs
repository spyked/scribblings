{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-
  PP, lab 07: clase (varianta nouă)

  1. FIFO, operații cu el (push, pop, top)
  2. Arbori de expresii, evaluarea într-un context dat
-}

-- 1. FIFO-uri. Nu am timp să adaug comentarii detaliate acum, fac pe fugă.
data FIFO a = P [a] [a] deriving Show

data Result a = Value a | Error deriving Show

-- push: facem push în lista din stânga
push :: a -> FIFO a -> Result (FIFO a)
push e (P l1 l2) = Value (P (e:l1) l2)

-- normalize: dacă e necesar, inversează listele
normalize :: FIFO a -> FIFO a
normalize (P l1 []) = P [] (reverse l1)
normalize (P l1 l2) = P l1 l2

-- pop, top
pop :: FIFO a -> Result (FIFO a)
pop (P [] [])       = Error
pop (P l1 [])       = pop $ normalize $ P l1 []
pop (P l1 (e : l2)) = Value (normalize $ P l1 l2)

top :: FIFO a -> Result a
top (P [] [])     = Error
top (P l1 [])     = top $ normalize $ P l1 []
top (P _ (e : _)) = Value e

-- 2. Arbori de expresii și evaluarea lor
--
-- Ne dorim să definim un limbaj simplu format dintr-un arbore
-- sintactic, și să scriem un evaluator pentru el.
--
-- Vrem ca expresiile să aibă un tip oarecare a, și să avem următoarele
-- subexpresii posibile:
--
-- - valori atomice de tipul a
-- - variabile (string-uri) pe care în timpul evaluării le evaluăm
--   într-un context dat
-- - adunarea a două subexpresii
-- - înmulțirea a două subexpresii
data Expr a = Val a
            | Var String
            | Plus (Expr a) (Expr a)
            | Mult (Expr a) (Expr a)

-- Definim de asemenea un context al evaluării ca tipul Dictionary, care
-- e o listă de legări (perechi) (String, a)
type Dictionary a = [(String, a)]

d :: Dictionary Integer
d = [ ("x", 2)
    , ("y", 3)
    , ("z", 4)
    , ("u", 5)
    , ("v", 6)
    , ("w", 7)
    ]
  

-- Vrem de asemenea să definim evaluarea într-un sens abstract, folosind
-- o interfață comună. Funcția abstractă de evaluare primește un context
-- (un Dictionary), o valoare de un tip t a și întoarce rezultatul
-- evaluării.
class Eval t a where
  eval :: Dictionary a -> t a -> Result a

-- Se dau următoarele task-uri:
--
-- a. Implementarea unei funcții valueof care preia valoarea unei
-- variabile date din context (Dictionary).
--
-- b. Implementarea unei instanțe de Eval pentru tipul de date Expr
-- peste Integer

-- a. valueof
valueof :: Dictionary a -> String -> Result a
valueof c s = case filter (\ (s',_) -> s' == s) c of
              ((_,x):_) -> Value x
              _         -> Error

-- b. Instanță Eval pentru Expr Integer
instance Eval Expr Integer where
  eval _ (Val x)      = Value x
  eval c (Var s)      = valueof c s
  eval c (Plus e1 e2) = case (eval c e1, eval c e2) of
                        (Value v1, Value v2) -> Value $ v1 + v2
                        (_ ,_)               -> Error
  eval c (Mult e1 e2) = case (eval c e1, eval c e2) of
                        (Value v1, Value v2) -> Value $ v1 * v2
                        (_, _)               -> Error

e :: Expr Integer
e = ((Val 1 `Plus` Val 2) `Mult` Var "x") `Mult` Var "y"
