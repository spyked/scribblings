-- PP, laboratoarele 4-5, ADT-uri

-- Outline:
--
-- - Tipuri monomorfice și operații: IList, ITree
-- - Tipuri polimorfice și operații: List, Tree
-- - Tipul FIFO, implementare cu două liste
-- - Operații pe arbori: DFS, BFS, construcția unui heap

-- 1. Definirea listelor și arborilor monomorfici
--
-- Reminder: o listă are două tipuri de valori
-- - Lista vidă, sau
-- - O pereche formată dintr-un element (întreg) și o listă
--
-- Definiția de mai sus se mapează pe următoarea declarație Haskell:
data IList = INil | ICons Integer IList deriving Show

-- (Nu studiem acum ce înseamnă acel "deriving Show". Pe scurt, ne
-- permite să afișăm valorile de tipul IList în consolă

-- Similar pentru arbori:
-- - Arborele vid
-- - Un nod format din subarborele stânga, valoarea, și subarborele
--   dreapta
data ITree = IVoid | INode ITree Integer ITree deriving Show

-- Cum lucrăm cu liste? Începem cu fold-uri (cele mai generale)
--
-- Ne obișnuim să scriem semnătura funcțiilor pe care le definim. E
-- util, pentru că ne ajută să ne dăm seama în mare ce fac
-- funcțiile. e.g.
ifoldr :: (Integer -> a -> a) -> a -> IList -> a
-- la fel ca în cazul listelor standard, putem face pattern matching pe
-- constructorii tipului de date, în cazul nostru INil și ICons.
ifoldr _  acc INil         = acc
ifoldr op acc (ICons i is) = op i (ifoldr op acc is)

ifoldl :: (a -> Integer -> a) -> a -> IList -> a
ifoldl _  acc INil         = acc
ifoldl op acc (ICons i is) = ifoldl op (op acc i) is

-- Să implementăm următoarele operații folosind funcțiile de mai sus:
--
-- a. Inversul unei liste
irev :: IList -> IList
irev is = ifoldl (flip ICons) INil is

-- b. IList -> listă Haskell
itoList :: IList -> [Integer]
itoList is = ifoldr (:) [] is

-- c. listă -> IList
ifromList :: [Integer] -> IList
ifromList xs = foldr (ICons) INil xs

-- 2. Variante polimorfice de liste, arbori
--
-- Tipurile de date polimorfice în Haskell sunt parametrizate după o
-- variabilă de tip, e.g.:
data List a = Nil | Cons a (List a) deriving Show
data Tree a = Void | Node (Tree a) a (Tree a) deriving Show

-- Variante polimorfice de foldl/foldr pe listele definite mai sus
afoldr :: (b -> a -> a) -> a -> List b -> a
afoldr _  acc Nil         = acc
afoldr op acc (Cons x xs) = op x (afoldr op acc xs)

afoldl :: (a -> b -> a) -> a -> List b -> a
afoldl _  acc Nil         = acc
afoldl op acc (Cons x xs) = afoldl op (op acc x) xs

-- Alte operații:
--
-- a. [a] -> List
afromList :: [a] -> List a
afromList = foldr Cons Nil

-- b. List -> [a]
atoList :: List a -> [a]
atoList = afoldr (:) []

-- c. reverse pe List
arev :: List a -> List a
arev = afoldl (flip Cons) Nil

-- d. append între două List-uri
aappend :: List a -> List a -> List a
aappend xs ys = afoldr Cons ys xs

-- e. map pe list
amap :: (a -> b) -> List a -> List b
amap f xs = afoldr (\ x acc -> Cons (f x) acc) Nil xs

-- 3. Lucrul cu structuri de date funcționale mai complexe: arbori,
-- FIFO, heap-uri.
--
-- Exemplu de arbore
t = Node (Node
            Void
            'a'
            (Node
              (Node
                Void
                'b'
                Void)
              'c'
              Void))
         'd'
         (Node
            (Node
              (Node
                Void
                'e'
                Void)
              'f'
              Void)
            'g'
            (Node
              Void
              'h'
              Void))
t2 = Node (Node (Node Void 5 Void) 3 (Node Void 6 Void)) 2 (Node Void 4 Void)

-- zeta. Calculul adâncimii arborilor
depth :: Tree a -> Integer
depth Void         = 0
depth (Node l _ r) = 1 + max (depth l) (depth r)

-- a. Parcurgere în adâncime a arborilor (DFS), în inordine
flatten :: Tree a -> List a
flatten Void         = Nil
flatten (Node l k r) = aappend (flatten l) (Cons k (flatten r))

-- b. Parcurgere în lățime a arborilor (BFS), în preordine
bfs :: Tree a -> List a
bfs t = let getKey (Node _ k _) = k
            op (Node Void _ Void) rest = rest
            op (Node Void _ r)    rest = Cons r rest
            op (Node l _ Void)    rest = Cons l rest
            op (Node l _ r)       rest = Cons l (Cons r rest)
            bf Nil   = Nil
            bf trees = amap getKey trees `aappend` bf (afoldr op Nil trees)
        in bf (Cons t Nil)

-- c. FIFO, reprezentat folosind două stive, una din care scoatem și una
-- în care punem.
data FIFO a = Fifo (List a) (List a) deriving Show

-- Adăugăm întotdeauna în FIFO în lista din stânga, în O(1)
push :: a -> FIFO a -> FIFO a
push x (Fifo l r) = Fifo (Cons x l) r

-- Scoaterea din FIFO are două operații: preluarea elementului din capul
-- cozii (top) și preluarea restului cozii (pull).
--
-- Scoatem întotdeauna din FIFO din lista din dreapta, în O(1). Putem
-- însă să ajungem în situația în care avem elemente doar în lista din
-- stânga, moment în care trebuie să adăugăm elementele din stânga în
-- dreapta. Deși această operație e în O(n), presupunem că în medie
-- executăm un număr egal de adăugări și scoateri din listă, deci
-- complexitatea amortizată rămâne O(1).
--
-- Pentru a reprezenta înlocuirea listelor, implementăm operația de
-- "normalizare" a unui FIFO:
normalize :: FIFO a -> FIFO a
normalize (Fifo l1 Nil) = Fifo Nil (arev l1)
normalize (Fifo l1 l2)  = Fifo l1 l2

top :: FIFO a -> a
top (Fifo _ (Cons x _)) = x
top (Fifo l1 Nil)       = top (normalize (Fifo l1 Nil))

pull :: FIFO a -> FIFO a
pull (Fifo l1 (Cons _ l2)) = Fifo l1 l2
pull (Fifo l1 Nil)         = pull (normalize (Fifo l1 Nil))

-- d. (Min-)heap. Structura heap-ului este aceeași cu a arborelui binar,
-- în plus conținând un contor cu numărul de copii al nodului
-- curent. Contorul este utilizat strict pentru a păstra arborele
-- balansat.
data Heap a =
    HVoid
  | HNode (Heap a) a (Heap a) Int
  deriving Show

heapInsert :: Ord a => a -> Heap a -> Heap a
heapInsert x HVoid         = HNode HVoid x HVoid 0
heapInsert x (HNode l k r n) =
             let (stay, move) = if x < k then (x, k) else (k, x)
             in case (l, r) of
                (HVoid, HVoid) ->
                  HNode (HNode HVoid move HVoid 0) stay HVoid 1
                (HVoid, _) ->
                  HNode (HNode HVoid move HVoid 0) stay r (n + 1)
                (_, HVoid) ->
                  HNode l stay (HNode HVoid move HVoid 0) (n + 1)
                (HNode _ _ _ n1, HNode _ _ _ n2) ->
                  if n1 <= n2
                  then HNode (heapInsert move l) stay r (n + 1)
                  else HNode l stay (heapInsert move r) (n + 1)
