-- PP, laboratorul 3, aplicații cu funcții de ordin superior

-- 1. Matrice implementate ca liste de liste, funcții implementate
-- folosind funcții de ordin superior + take și drop:
m1 = [ [1,2,3]
     , [4,5,6]
     , [7,8,9]
     ]

m2 = [ [1,0,0]
     , [0,1,1]
     , [1,0,1]
     ]

-- 1. a. linia i dintr-o matrice
--
-- Prima linie din matricea fără primele i linii
matLine i m = head $ drop i m

-- 1. b. elementul (i, j) dintr-o matrice
--
-- Primul element din lista l fără primele j elemente, unde l este linia
-- i din m
matElem i j m = head $ drop j $ matLine i m

-- 1. c. suma a doua matrice
--
-- Întâi definim o funcție auxiliară mai generală, matZipWith, care
-- combină elementele din două matrice două câte două.
matZipWith op m1 m2 = zipWith (\ l1 l2 -> zipWith op l1 l2) m1 m2

-- Suma e dată de matZipWith (+)
matSum m1 m2 = matZipWith (+) m1 m2

-- 1. d. transpusa unei matrice
--
-- Mai greu de definit *doar* cu funcționale, dar poate fi definită ușor
-- iterând peste liniile matricei, i.e. prima coloană este map head,
-- restul coloanelor pot fi obținute recursiv peste map tail.
matTranspose ([] : _) = []
matTranspose ls = map head ls : matTranspose (map tail ls)

transposeFoldr m = foldr (zipWith (:))                               
                         (map (const []) m)
                         m

-- 1. e. produsul a două matrice
--
-- Îl definim pe baza produsului intern a două "linii" (vectori).
internProduct l1 l2 = sum $ zipWith (*) l1 l2

matProd m1 m2 = map (\ l1 -> map (\ l2 -> internProduct l1 l2) $ matTranspose m2 ) m1

-- 2. Imagine ca matrice, caractere ca "pixeli". Există trei tipuri de
-- pixeli, '.', '*' și ' '.
--
-- Exemplu de imagine:

pp_logo =
    [ "        ***** **            ***** **    "
    , "     ******  ****        ******  ****   "
    , "    **   *  *  ***      **   *  *  ***  "
    , "   *    *  *    ***    *    *  *    *** "
    , "       *  *      **        *  *      ** "
    , "      ** **      **       ** **      ** "
    , "      ** **      **       ** **      ** "
    , "    **** **      *      **** **      *  "
    , "   * *** **     *      * *** **     *   "
    , "      ** *******          ** *******    "
    , "      ** ******           ** ******     "
    , "      ** **               ** **         "
    , "      ** **               ** **         "
    , "      ** **               ** **         "
    , " **   ** **          **   ** **         "
    , "***   *  *          ***   *  *          "
    , " ***    *            ***    *           "
    , "  ******              ******            "
    , "    ***                 ***             "
    ]

-- pe care o putem afișa în consolă folosind funcția:
printImg img = mapM_ putStrLn img

-- Vrem să implementăm următoarele funcții:

-- 2. a. flip orizontal, vertical, rotație 90 de grade în sens
-- trigonometric și invers trigonometric
--
-- Flip pe orizontală <-> inversarea coloanelor
flipHorizImg img = map reverse img

-- Flip pe verticală <-> inversarea liniilor
flipVertImg img = reverse img

-- Rotire trigonometrică <-> transpusa flip-ului pe orizontală
rotateTrigImg img = matTranspose $ flipHorizImg img

-- Rotire anti-trigonometrică <-> transpusa flip-ului pe verticală
rotateAntiTrigImg img = matTranspose $ flipVertImg img

-- 2. b. negativul ('*' -> ' ', '.' -> ' ', ' ' -> '*')
--
-- Definim întâi o funcție care face transformarea la nivel de pixel:
negPixel p = case p of
               '*' -> ' '
               '.' -> ' '
               ' ' -> '*'
               _   -> error "Unknown pixel value."
negImg img = map (map negPixel) img

-- 2. c. scalarea unei imagini cu x unități
--
-- Scalarea se poate face pe orizontală, pe verticală sau în ambele
-- direcții. Pentru simplificare, considerăm doar scalarea pozitivă
-- (i.e. mărirea imaginii).
--
-- Scalarea pe orizontală. Pentru a lucra mai ușor, considerăm
-- următoarele funcții auxiliare:
--
-- - replicate n elem: întoarce o listă cu elem repetat de n ori
-- - concatMap f xs: aplică pe fiecare element din xs o funcție f al
--   cărei rezultat este o listă, și concatenează listele rezultate.
scaleHorizImg img n = map (concatMap (\ x -> replicate n x)) img

-- Scalarea pe verticală se face în mod similar, doar că pe linii:
scaleVertImg img n = concatMap (\ l -> replicate n l) img

-- Scalarea pe ambele dimensiuni:
scaleImg img n = scaleVertImg (scaleHorizImg img n) n

-- 2. d. alipirea a două imagini (cu aceeași înălțime) pe orizontală
--
-- e echivalentă cu concatenarea liniilor două câte două:
uniteHorizImg img1 img2 = zipWith (++) img1 img2

-- 2. e. alipirea a două imagini (cu aceeași lungime) pe verticală
uniteVertImg img1 img2 = img1 ++ img2

-- 2. f. crop orizontal de la coloana x la coloana y
--
-- Pentru crop-uri, definim o funcție generală, comună, care primește o
-- listă și lasă doar elementele dintre x și y
crop x y l = take (y - x) $ drop x $ l

-- coloane
cropHorizImg img x y = map (crop x y) img

-- 2. g. crop vertical de la linia x la linia y
cropVertImg img x y = crop x y img

-- 2. h. suprapunerea a două imagini (de aceeași dimensiune) una peste alta
--
-- Care sunt regulile de suprapunere? Presupunem că vrem să suprapunem
-- pixelul p peste p'.
--
-- - Dacă p este ' ', atunci suprapunerea este p'
-- - Altfel, suprapunerea este p
overlapPixels p p' = if p == ' ' then p' else p

-- Refolosim matZipWith
overlapImg img img' = matZipWith overlapPixels img img'
