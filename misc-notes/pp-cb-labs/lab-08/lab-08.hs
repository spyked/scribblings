{-
  Paradigme de programare, laboratorul 8, evaluare leneșă
-}
import Data.List (foldl')

-- Dorim să ilustrăm utilitatea evaluării leneșe pentru lucrul cu
-- fluxuri. Întâi, câteva exemple:
zeroes = 0 : zeroes
naturals = let mkNats n = n : mkNats (n + 1)
           in mkNats 0

-- alternativ, folosind funcții de ordin superior:
naturals' = 0 : map (+ 1) naturals'

-- Exerciții:

-- 1. Șirul numerelor pare
evens = let mkEvens n = n : mkEvens (n + 2)
        in mkEvens 0

evens' = 0 : map (+ 2) evens'

-- 2. Șirul lui Fibonacci
fibs = let mkFibs n1 n2 = n1 : mkFibs n2 (n1 + n2)
       in mkFibs 0 1

-- să încercăm și varianta cu funcții de ordin superior, fiindcă diferă
-- un pic față de exemplele anterioare
fibs' = 0 : 1 : zipWith (+) fibs' (tail fibs')

-- 3. Funcție de ordin superior generală pentru generarea șirurilor
-- infinite (a se vedea și funcția iterate). Primește o funcție f și o
-- valoare inițială x, și întoarce lista infinită:
--
-- [x, f x, f (f x), f (f (f x)), ..]
--
-- Funcția este o generalizare a funcțiilor anterioare
build :: (a -> a) -> a -> [a]
build f x = x : build f (f x)

-- să încercăm să reimplementăm funcțiile anterioare folosind build:

-- zeroes, naturals, evens
zeroes' = build (\ _ -> 0) 0
naturals'' = build (+ 1) 0
evens'' = build (+ 2) 0

-- fibs: trebuie să îl adaptăm la funcții de forma (a -> a); pentru asta
-- trimitem perechi către build și facem pattern matching pe ele:
fibs'' = map fst (build (\ (n1, n2) -> (n2, n1 + n2)) (0, 1))

-- 4. select: primim o toleranță e, o listă posibil infinită, și
-- întoarcem valoarea din șir a cărei variație e mai mică decât
-- toleranța.
--
-- Pentru că folosim (-) și (<), e de ajuns să impunem ca restricții Num
-- a și Ord a.
select :: (Num a, Ord a) => a -> [a] -> a
select e (x : x' : xs) | abs (x - x') < e = x
                       | otherwise        = select e (x' : xs)

--Testăm pe următorul exercițiu

-- 5. Aproximație pentru sqrt (e = 0.01):
--
-- a0(k) = k
-- an(k) = 0.5 * (a{n-1} + k / a{n-1}) converge către sqrt(k) când n ->
-- inf.
mySqrt k = select e (build (\ x -> 0.5 * (x + k / x)) k)
  where e = 0.01

-- 6. Aproximație pentru derivata unei funcții.
--
-- Definim întâi șirul [x/2, x/4, x/8, ..] -> observăm că șirul converge
-- la 0.
reversePows x = build (\ x -> x / 2) x

-- Definim șirul aproximărilor lui f', pe baza relației:
-- f' (a) = (f (a + h) - f a) / h), unde h e deocamdată dat.
approxDerivs h0 f a = map (\ h -> (f (a + h) - f a) / h) (reversePows h0)

-- Definim derivata aproximativă folosind select. Considerăm că valoarea
-- inițială a lui h este a, deși pentru cazuri simple nu prea contează.
deriv f a = select e (approxDerivs a f a)
  where e = 0.01

-- exemple:
--
-- > deriv (\ x -> x * x) 2
-- cam 4
-- > deriv (\ x -> x * x * x) 2
-- cam 12
-- > deriv sin pi
-- cam -1

-- 7. Aproximație pentru integrala unei funcții. Pornim prin a modela un
-- interval [a,b] sub forma unei liste cu două sau mai multe elemente.
-- Pentru a „rafina” acest interval, „spargem” sub-intervalul [a,b]
-- într-un interval [a,m,b], unde m = (a + b) / 2:
refinePoints []            = []
refinePoints (x : [])      = [x]
refinePoints (x : x' : xs) = x : (x + x') / 2 : refinePoints (x' : xs)

-- Apoi construim fluxul aproximărilor din ce în ce mai granulare ale
-- intervalului [a,b], pornind de la lista cu cele două capete:
approxPoints a b = build (\ xs -> refinePoints xs) [a,b]

-- Definim integrala folosind regula pătratului:
--
-- (https://en.wikipedia.org/wiki/Integral_approximation#Quadrature_rules_based_on_interpolating_functions)
squareIntegral f a b = (b - a) * f ((a + b) / 2)
-- Dorim să integrăm pe fiecare „pătrat” în parte, deci generăm fluxul
-- perechilor de puncte:
approxPairs a b = map (\ xs -> zip xs (tail xs)) (approxPoints a b)

-- Dorim de asemenea să generăm fluxul aproximărilor integralelor
-- (folosind metoda pătratului, definită mai sus). Pentru a însuma
-- aproximările intervalelor „pătrate”, putem folosi fie funcția
-- predefinită sum, fie să ne definim propriul sum, cu blackjack și
-- hookers. Ca observație, folosim varianta ne-leneșă (aplicativă) a lui
-- foldl, foldl'.
mySum xs = foldl' (+) 0 xs
approxIntegrals f a b =
  map (\ xs -> mySum $ map (\ (a, b) -> squareIntegral f a b) xs)
      (approxPairs a b)

-- Alegem cea mai rafinată aproximare, folosind select
integralOf f a b = select e (approxIntegrals f a b)
  where e = 0.01

-- > integralOf (\ x -> 3 * x * x) 1 3
-- cam 26
-- > integralOf cos 0 pi
-- aproape 0 :P
