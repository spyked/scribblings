%% PP, lab 12: Diverse
%%
%% I. Operații cu mulțimi. Nu folosim findall și alte bălării.

% 1. Produsul cartezian a două mulțimi-ca-liste
%
% Întâi definim un predicat make_pairs/3 care împerechează un element cu
% fiecare din elementele unei liste.
make_pairs(_, [], []).
make_pairs(E, [X|XS], [(E,X)|R]) :- make_pairs(E, XS, R).

% Pentru fiecare element din prima listă, îl împerechem cu a doua.
%
% cartesian(L1, L2, R).
cartesian([], _, []).
cartesian([X|XS], YS, R) :- cartesian(XS, YS, Part1),
                            make_pairs(X, YS, Part2),
                            append(Part2, Part1, R).

% 2. Reuniunea a două mulțimi reprezentate ca liste. La fel ca mai sus,
% facem recursivitatea pe primul argument. Aproape identic cu append.
%
% reunion(L1, L2, R).
reunion([], YS, YS).
reunion([X|XS], YS, [X|R]) :- \+ member(X, YS), reunion(XS, YS, R).
reunion([X|XS], YS, R) :- member(X, YS), reunion(XS, YS, R).

% 3. Intersecția a două mulțimi reprezentate ca liste. Aproape identic
% cu exercțiul anterior.
%
% intersection(L1, L2, R).
intersection([], _, []).
intersection([X|XS], YS, [X|R]) :- member(X, YS), intersection(XS, YS, R).
intersection([X|XS], YS, R) :- \+ member(X, YS), intersection(XS, YS, R).

% 4. Diferența între două mulțimi reprezentate ca liste. Identic cu 2,
% înafară de cazul de bază.
%
% diff(L1, L2, R).
diff([], _, []).
diff([X|XS], YS, [X|R]) :- \+ member(X, YS), diff(XS, YS, R).
diff([X|XS], YS, R) :- member(X, YS), diff(XS, YS, R).

%% II. Permutări, aranjamente, combinări.
%
% Mic reminder:
% - p(n) = n! -- atenție, ăsta e doar *numărul* permutărilor
% - a(n,k) = n! / (n - k)!
% - c(n,k) = n! / (k! * (n - k)!)
%
% Distincția între aranjamente și combinări e că aranjamentele țin cont
% de ordine (sunt permutările k-submulțimilor).

% 1. Powerset-ul unei mulțimi -- mulțimea tuturor submulțimilor. Plecăm
% constructivist, de la mulțimea submulțimilor listei vide (lista care
% conține lista vidă) și construim submulțimile cu noul element.

% addToAll(E, L, R).
addToAll(_, [], []).
addToAll(E, [X|XS], [[E|X]|R]) :- addToAll(E, XS, R).

% pow(L, R).
pow([], [[]]).
pow([X|XS], R) :- pow(XS, R1),
                  addToAll(X, R1, R2),
                  append(R1, R2, R).

% 2. Permutările unei liste date. Abordarea e similară cu cea de la 1,
% doar că generăm lista cu adăugarea elementului în toate pozițiile
% posibile.

% addEverywhere(E, L, R).
addEverywhere(E, L, [E|L]).
addEverywhere(E, [X|XS], [X|R]) :- addEverywhere(E, XS, R).

% perm(L, R).
perm([], []).
perm([X|XS], R) :- perm(XS, R1), addEverywhere(X, R1, R).

% 3. Aranjamentele unei liste date. Ne ajutăm de pow și de perm =>
% aranjamentele unei liste sunt permutările k-subsets. Deci extragem
% doar submulțimile de cardinal k punând condiția length(X, K).
%
% arr(K, L, R).
arr(K, L, R) :- pow(L, Subs),
                member(X, Subs),
                length(X, K),
                perm(X, R).

% 4. Combinările unei liste date. Similar cu 3, doar că nu e nevoie să
% generăm toate permutările (nu contează ordinea elementelor).
%
% comb(K, L, R).
comb(K, L, R) :- pow(L, Subs),
                 member(R, Subs),
                 length(R, K).
