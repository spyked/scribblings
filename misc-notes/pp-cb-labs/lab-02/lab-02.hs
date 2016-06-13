--  Paradigme de programare, laboratorul 2: functii recursive

-- 1. Factorialul unui număr dat, fără restricții și tail recursive.
--
-- TDA-ul număr se aseamănă cu TDA-ul listă:
-- - 0 (caz de bază) <- 0! = 1
-- - n (pas de inducție) <- n! = n * (n - 1)!
factorial 0 = 1
factorial n = n * factorial (n - 1)

-- Cum se evaluează un factorial n oarecare?
--
-- > factorial n
-- > n * factorial (n - 1)
-- > n * (n - 1) * factorial (n - 2)
-- > ...
--
-- Avem aceeași problemă cu spațiul, iar optimizarea tail-recursive
-- poate fi făcută adăugând un parametru de tip "acumulator", care va
-- avea valoarea inițială 1 (valoarea cazului de bază). Observăm că
-- astfel calculul se face pe avans.

factorialTail n = let factorialAux acc 0 = acc
                      factorialAux acc n = factorialAux (acc * n) (n - 1)
                  in factorialAux 1 n

-- 2. Al n-lea număr din șirul fibonacci. Problema e similară cu cea
-- anterioară, doar că avem de-a face cu o recurență de ordinul 2:
--
-- - Numărul Fibonacci de la indicele 0 este 0
-- - Numărul Fibonacci de la indicele 1 este 1
-- - Numărul Fibonacci de la indicele n este suma numerelor de la
--   indicele n - 1 și n - 2.
fibonacci 0 = 0
fibonacci 1 = 1
fibonacci n = fibonacci (n - 1) + fibonacci (n - 2)

-- Evaluarea fibonacci 4:
-- > fibonacci 4
-- > fibonacci 3 + fibonacci 2
-- > (fibonacci 2 + fibonacci 1) + (fibonacci 1 + fibonacci 0)
-- > ((fibonacci 1 + fibonacci 0) + 1) + (1 + 0)
-- > ((1 + 0) + 1) + 1
-- > (1 + 1) + 1
-- > 2 + 1
-- > 3
--
-- Implementarea tail-recursive nu este așa de evidentă. La fiecare pas
-- trebuie să reținem n - 1 și n - 2, iar la următorul pas n - 1 devine
-- n - 2 iar n devine n - 1.
--
-- Scriem primele elemente din șirul lui Fibonacci:
--
-- 0 1 1 2 3 5 8 13
--
-- și vrem să le calculăm pe avans. Pentru asta trebuie să reținem două
-- acumulatoare, câte unul pentru fiecare rezultat parțial al șirului
-- Fibonacci. "Mutăm" acumulatorul asociat lui (n - 1) în cel asociat
-- lui (n - 2) după calculul noului rezultat parțial:
--
-- acc1_0 = 1; acc1_1 = (1 + 0) = 1; acc1_2 = 2; acc1_3 = 3; ...
-- acc2_0 = 0; acc2_1 = acc1_0  = 1; acc2_2 = 1; acc2_3 = 2; ...
fibonacciTail n = let
  fibonacciAux acc1 acc2 0 = acc2
  fibonacciAux acc1 acc2 n = fibonacciAux (acc1 + acc2) acc1 (n - 1)
  in fibonacciAux 1 0 n
-- Notă: cazul de bază fibonacciAux acc1 acc2 1 nu e necesar, va fi în
-- mod natural calculat când se trece de la 1 la 0 (acc2 va primi vechea
-- valoare a lui acc1 și va fi întors de funcție).

-- 3. Avem de implementat două funcții: concatenarea a două liste și
-- inversul unei liste. Cele două funcții sunt folosite pentru a ilustra
-- faptul că recursivitatea poate fi uneori făcută „în mod natural” pe
-- coadă.
--
-- 3.a. Concatenarea a două liste. Să luăm un exemplu:
-- cat [1,2,3,4] [5,6,7] = [1,2,3,4,5,6,7]
--
-- O putem privi ca pe adăugarea „în coada lui [1,2,3,4]” pe
-- [5,6,7]. Dat fiind că nu putem accesa coada lui [1,2,3,4] imediat,
-- trebuie să o parcurgem până ajungem la lista vidă.
-- 
-- În limbaj natural:
-- - concatenarea listei vide l1 cu o listă l2 este lista l2
-- - concatenarea unei liste formată din elementul h și lista l1 este
--   lista formată din elemetnul h și concatenarea lui l1 la l2.
cat [] l2 = l2
cat (h : l1) l2 = h : cat l1 l2

-- Evaluare:
-- > cat [1,2,3,4] [5,6,7]
-- > 1 : cat [2,3,4] [5,6,7]
-- > 1 : 2 : cat [3,4] [5,6,7]
-- > 1 : 2 : 3 : cat [4] [5,6,7]
-- > 1 : 2 : 3 : 4 : cat [] [5,6,7]
-- > 1 : 2 : 3 : 4 : [5,6,7]
--
-- Deși cat nu e tail-recursive, este ceea ce se numește „tail-recursive
-- modulo cons”, i.e. ultimul apel este un cons. Funcțiile
-- tail-recursive modulo cons pot fi la rândul lor optimizate să
-- utilizeze spațiu constant pe stivă.

-- 3.b. Inversarea ordinii elementelor dintr-o listă. La o primă vedere,
-- cea mai intuitivă metodă de implementare a funcției ar folosi append,
-- i.e. pentru pasul de recursivitate facem append în coada
-- listei. Dezavantajul acestei metode e că merge în O(n^2).
--
-- O implementare naturală ar fi însă cea în care facem cons într-un
-- acumulator, iar pe cazul de bază întoarcem acumulatorul:
-- - Inversul listei vide este acumulatorul
-- - Inversul unei liste formată din h și l este același cu inversul
--   lui l când acumulatorul conține ca prim element h.
inv l = let invAux acc [] = acc
            invAux acc (h : l) = invAux (h : acc) l
        in invAux [] l

-- Evaluare:
-- > inv [1,2,3,4]
-- > invAux [] [1,2,3,4]
-- > invAux (1 : []) [2,3,4]
-- > invAux (2 : [1]) [3,4]
-- > invAux (3 : [2,1]) [4]
-- > invAux (4 : [3,2,1]) []
-- > [4,3,2,1]

-- 4. Sortări pe liste.

-- 4.a. Merge sort
--
-- Considerăm două cazuri de bază: lista vidă și lista cu un singur
-- element. Al doilea caz e folosit pentru a lăsa recursivitatea să se
-- oprească în mod natural atunci când lista e împărțită în două.
mergeSort [] = []
mergeSort [x] = [x]
mergeSort l = let untilSplit = length l `div` 2
                  -- funcția de interclasare
                  merge l1 [] = l1
                  merge [] l2 = l2
                  merge (h1 : l1) (h2 : l2) = if h1 < h2
                                              then h1 : merge l1 (h2 : l2)
                                              else h2 : merge (h1 : l1) l2
                  -- împarte lista în două jumătăți (în funcție de
                  -- numărul de elemente)
                  left = take untilSplit l
                  right = drop untilSplit l
                 -- sortează rezultatele parțiale și le interclasează
              in merge (mergeSort left) (mergeSort right)

-- 4.b. Insertion sort
--
-- E oarecum similar cu bubble sort, doar că în loc de swap, parcurge
-- lista și inserează elementele în ordinea dorită.
insertionSort [] = []
insertionSort (h : l) = let insert e [] = [e]
                            insert e (h : l) = if e < h
                                               -- dacă elementul e mai
                                               -- mic decât capul
                                               -- listei, inserează-l în
                                               -- cap
                                               then e : h : l
                                               -- altfel caută-i alt loc
                                               else h : insert e l
                           -- inserează elementul în lista sortată
                        in insert h (insertionSort l)

-- 4.c. QuickSort
--
-- Ideea din spatele algoritmului:
-- - Alege un element pivot
-- - Împarte lista în două subliste:
--   + Sublista conținând elementele < pivot
--   + Sublista conținând elementele >= pivot
-- - Concatenează listele obținute plus pivotul
quickSort [] = []
quickSort (p : l) = let left = filter (< p) l
                        right = filter (>= p) l
                    in quickSort left ++ [p] ++ quickSort right

-- 5. Numărul de inversiuni dintr-o listă
--
-- Folosim aceeași definiție ca cea din laborator: având dată o listă l
-- și l[i] fiind elementul de pe poziția i (unde i începe cu 0 și se
-- termină cu lungimea listei - 1), să se afle numărul de elemente ale
-- listei care respectă proprietatea l[i] > l[j] și i < j.
--
-- (Sau, intuitiv, numărul de elemente care nu sunt „în poziția în care
-- ar trebui să fie” în raport cu o listă sortată.)
--
-- Intuitiv, trebuie să comparăm fiecare două elemente din listă la un
-- loc cu pozițiile lor, și să adunăm 1 la rezultatul parțial (aka
-- „acumulator”) când proprietatea ține
numberOfInversions l =
  let -- am terminat de parcurs l1, întorc rezultatul
      go [] l2 n1 n2 acc = acc
      -- am terminat de parcurs l2, reparcurg pentru restul lui l1
      go (h1 : l1) [] n1 n2 acc = go l1 l (n1 + 1) 0 acc
      go (h1 : l1) (h2 : l2) n1 n2 acc =
        -- dacă am o inversiune, incrementez acc, altfel îl las cum e
        let acc1 = if h1 > h2 && n1 < n2 then acc + 1 else acc
        in go (h1 : l1) l2 n1 (n2 + 1) acc1
  in go l l 0 0 0
-- Alternativ, se poate modifica mergeSort pentru a număra inversiunile
-- dintr-o listă (în pasul de interclasare).
