-- PP, Laboratorul 3, funcții

-- 1. Închidere funcțională care prefixează lista [1,2,3] la un
-- parametru
--
-- O definiție care ilustrează foarte bine ideea de închidere
pre = \ x -> 1 : 2 : 3 : x
pre' = (++) [1,2,3] -- currying
pre'' = ([1,2,3] ++) -- more currying

-- 2. Funcție de ordin superior care primește o funcție și un număr și
-- aplică de două ori funcția pe numărul dat
applyTwice f n = f (f n)

-- 3. Funcție care primește un operator binar și întoarce același
-- operator cu ordinea parametrilor inversată
myFlip op = (\ x y -> op y x) -- închidere explicită
myFlip' op x y = op y x -- same thing

-- 4. Funcții de ordin superior

-- 4. a. foldl: parantezele se adună la stânga
--
-- foldl op init [x1, x2, ...] = ((init `op` x1) `op` x2) `op` ...
--
-- pro-tip: foldl este „în mod natural” recursivă pe coadă
myFoldl op init []       = init -- init e acumulator
myFoldl op init (x : xs) = myFoldl op (op init x) xs

-- 4. b. foldr: parantezele se adună la dreapta
--
-- foldr op init [x1, x2, ...] = x1 `op` (x2 `op` (... (xn `op` init)))
--
-- pro-tip: op e folosit inversat în foldr față de foldl (see xn `op` init)
myFoldr op init []       = init
myFoldr op init (x : xs) = x `op` myFoldr op init xs

-- 4. c. map
--
-- map f [x1, x2, x3, ...] = [f x1, f x2, f x3, ...]
myMap f []       = []
myMap f (x : xs) = f x : myMap f xs

-- 4. d. filter
--
-- filter p xs = { x | x \in xs ^ p x }
myFilter p []       = []
-- construcție foarte alambicată (doar pentru a ilustra funcțiile de
-- ordin superior): vrem să alegem dacă adăugăm x în lista returnată de
-- apelul recursiv, cum facem asta? Fie aplicăm (x :), care adaugă x în
-- capul listei, fie id (funcția identitate), care întoarce lista
-- inițială.
myFilter p (x : xs) = (if p x
                      then (x :)
                      else id) (myFilter p xs)

-- 4. e. zipWith
--
-- zipWith op [x1, x2, ...] [y1, y2, ...] = [x1 `op` y1, x2 `op` y2, ...]
myZipWith op []       ys       = []
myZipWith op xs       []       = []
myZipWith op (x : xs) (y : ys) = op x y : myZipWith op xs ys

-- 4. f. operatorul de compoziție (.)
--
-- (f . g) x = f (g x)
--
-- pro-tip: compoziția e invers față de cea din matematică
compose f g = \ x -> f (g x)

-- 5. Implementări folosind foldr/foldl
--
-- Pentru claritate/simplitate, o să folosim foldr pentru a implementa
-- cele două funcții. Ținem cont de faptul că foldl, fiind recursiv pe
-- coadă, inversează lista rezultată. Ca fapt divers:
--
-- foldl (flip (:)) [] xs == reverse xs

-- 5. a. map cu foldr/foldl
--
-- Ținem minte că operatorul primit de foldr primește ca prim argument
-- un element al listei, al doilea argument fiind starea curentă a
-- acumulatorului)
--
-- De asemenea, ținem minte că init e valoarea întoarsă pe cazul de
-- bază, în cazul nostru [].
myMap' f xs = foldr (\ x acc -> f x : acc) [] xs

-- 5. b. filter cu foldr/foldl
myFilter' p xs = foldr (\ x acc -> if p x then x : acc else acc) [] xs
