{-
  PP, laboratorul 7, clase de tipuri.

  Dorim să implementăm următoarele:

  1. Instanțe de Show pentru List a și Tree a
  2. Instanțe de Eq pentru List a și Tree a
  3. Sortare pentru List a, unde a este în Ord
  4. Căutare binară pentru Tree a, unde a este în Ord
  5. Instanță Functor pentru List și Tree
-}

{-
  Redefinim tipurile de date de la laboratorul anterior (de data asta
  fără deriving):
-}
data List a = Nil | Cons a (List a)
data Tree a = Void | Node (Tree a) a (Tree a)

{-
  1. Instanțe de Show
-}
-- 1.a. Pentru List a:
instance (Show a) => Show (List a) where
  show xs = "[" ++ go xs
    where go Nil          = "]"
          go (Cons x Nil) = show x ++ "]"
          go (Cons x xs)  = show x ++ "," ++ go xs

-- 1.pre-b. Implementăm un arbore simplu:
t = Node (Node (Node Void 'a' Void) 'b' (Node Void 'c' Void))
         'd'
         (Node Void 'e' (Node Void 'f' Void))
-- 1.b. Pentru Tree a. Folosim o reprezentare simplă, unde nivelul de
-- indentare e același cu adâncimea curentă în arbore:
instance (Show a) => Show (Tree a) where
  -- far from perfect, but decent
  show = go 0
    where go _ Void         = ""
          go n (Node l v r) = replicate n ' ' ++ "| " ++ show v ++ "\n" ++
                              maybeGo (n + 1) l ++
                              maybeGo (n + 1) r
          maybeGo n Void = ""
          maybeGo n t    = replicate (n-1) ' ' ++ "\\\n" ++ go n t

-- 2.a. Înrolare List a în Eq
instance (Eq a) => Eq (List a) where
  (==) Nil Nil                 = True
  (==) (Cons x xs) (Cons y ys) = (==) x y && (==) xs ys
  (==) _ _                     = False

-- 2.b. Înrolare Tree a în Eq
instance (Eq a) => Eq (Tree a) where
  (==) Void Void                    = True
  (==) (Node l v r) (Node l' v' r') = (==) v v' && (==) l l' && (==) r r'
  (==) _ _                          = False

-- 3. Sortare pentru List a; pentru ușurință, vom face QuickSort.
-- 3. a. filter pe List a
filterList :: (a -> Bool) -> List a -> List a
filterList _ Nil         = Nil
filterList p (Cons x xs) = if p x then Cons x (filterList p xs)
                                  else filterList p xs

appendList :: List a -> List a -> List a
appendList Nil l2         = l2
appendList (Cons x xs) l2 = Cons x (appendList xs l2)

-- 3. c. sort pe List a
sort :: Ord a => List a -> List a
sort Nil         = Nil
sort (Cons x xs) = filterList (< x) xs ++. (Cons x Nil) ++. filterList (>= x) xs
  where
  (++.) = appendList

-- 4. Căutare binară pentru Tree a; folosim Maybe: întoarcem Nothing
-- dacă nu am găsit elementul căutat, sau Just x pentru un x găsit.
binarySearch :: Ord a => a -> Tree a -> Maybe a
binarySearch _ Void         = Nothing
binarySearch x (Node l v r) | x > v     = binarySearch x r
                            | x < v     = binarySearch x l
                            | otherwise = Just v

-- 5. Clasa Functor generalizează map, i.e. cere implementarea unei
-- funcții fmap cu semnătura similară:
--
-- fmap :: Functor f => (a -> b) -> f a -> f b
--
-- unde f (după cum arată semnătura) e un tip de date parametrizat după
-- o variabilă de tip. A se consulta clasa Functor pentru mai multe detalii:
--
-- > :info Functor

-- 5.a. Functor pentru List
instance Functor List where
  fmap _ Nil         = Nil
  fmap f (Cons x xs) = Cons (f x) (fmap f xs)

-- 5.b. Functor pentru Tree
instance Functor Tree where
  fmap _ Void         = Void
  fmap f (Node l v r) = Node (fmap f l) (f v) (fmap f r)
