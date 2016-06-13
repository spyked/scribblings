%% PP, Lab 11

% I. Exerciții liste & diverse

% I. 1. Ilustrare a unificării
%
% firstTwo(?X, ?Y, ?L). -- întoarce true atunci când X și Y sunt primele
% două elemente din L
firstTwo(X, Y, [X,Y|_]).

% I. 2. Verificarea că un element există într-o litsă
%
% contains(?E, ?L).
contains(E,[E|_]).
contains(E,[_|L]) :- contains(E,L).

% I. 3. Invers, verificarea că un element *nu* există într-o listă
%
% notContains(+E, +L).
%
% Cea mai simplă implementare ar fi negarea celei de mai sus:
%
% notContains(E, L) :- \+ contains(E, L).
notContains(_, []).
notContains(E, [X|L]) :- E \= X, notContains(E,L).

% I. 4. Eliminarea duplicatelor dintr-o listă
%
% unique(+L1, -L2). -- L2 este L1 fără duplicate
unique([], []).
unique([X|L1], [X|L2]) :- unique(L1, L2), notContains(X, L2), !.
unique([X|L1], L2) :- unique(L1, L2), contains(X, L2).

% I. 5. Păstrarea listelor dintr-o listă de elemente care sunt posibil
% liste.
%
% Definim întâi un predicat pentru a verifica că X este o listă.
isList([]).
isList([_|_]).

% listOnly(+L1, -L2). -- L2 este L1 din care sunt scoase non-listele
listOnly([], []).
% similar cu exercițiul anterior
listOnly([X|L1], [X|L2]) :- listOnly(L1, L2), isList(X).
listOnly([X|L1], L2) :- listOnly(L1, L2), \+ isList(X).

% I. 6. Insertion sort
%
% Definim întâi un predicat auxiliar pentru inserarea unui element
% într-o listă parțial sortată.
insertSorted(X, [], [X]) :- !.
insertSorted(X, [E|L], [X,E|L]) :- X =< E, !.
insertSorted(X, [E|L], [E|L1]) :- X > E, insertSorted(X,L,L1).

% Acum putem sorta prin inserție lista element cu element.
% 
% insertionSort(+L1, -L2).
insertionSort([],[]).
insertionSort([X|L1],L2) :- insertionSort(L1,L11), insertSorted(X,L11,L2).

% II. Arbori
%
% II. 1. Putem reprezenta TDA-ul arbore folosind liste de forma:
%
% [ValRadacina, Subarbore1, Subarbore2, ..]
%
% e.g. [1,[2,[3]],[4,[5,[6]],[7,[8]]]].
%
% II. 2. Dorim să aflăm a. numărul de noduri din arbore (size) și
% b. înălțimea arborelui (height). Pentru aceasta, refolosim predicatul
% length/2.
%
% a. size(+Arbore,-Număr).
size([_],1) :- !.
size([X,Subtree|Subtrees], N) :- size(Subtree, N1), size([X|Subtrees], N2),
                                 N is N1 + N2.

% Înălțimea e foarte similară, doar că calculăm maximul înălțimii
% subarborilor în loc de suma lor.
%
% b. height(+Arbore, -Număr).
height([_], 0) :- !.
height([X,Subtree|Subtrees], N) :- height(Subtree,N1),
                                   height([X|Subtrees], N2),
                                   N is 1 + max(N1, N2).

% II. 3. Parcurgerea arborelui și transformarea lui în listă. E foarte
% similară cu exercițiul anterior, doar că concatenăm (cu append/3)
% sublistele obținute și verificăm dacă elementul curent e listă sau nu.
%
% flatten(+Arbore, -Listă).
flatten([], []).
flatten([X|L1], L2) :- isList(X), !, flatten(X,L11), flatten(L1,L12),
                       append(L11,L12,L2).
flatten([X|L1], [X|L2]) :- \+ isList(X), flatten(L1, L2).

% III. Reprezentarea datelor în Prolog
%
% Nu există o diferență clar delimitată între fapte și date în
% Prolog. Din acest motiv putem "imbrica" fapte pentru a obține o
% structură de date nouă.
%
% Să presupunem (conform enunțului din textul laboratorului) că avem un
% mic limbaj care permite existența constantelor aritmetice, a
% variabilelor și a operației de adunare și înmulțire pe cele
% două. Pentru a reprezenta legarea variabilei la o valoare, vom folosi
% predicatul asgn/2, având forma:
%
% asgn(+Variabilă, +Valoare).
%
% Pentru a reprezenta restul operațiilor, folosim structuri (care se
% aseamănă cu fapte, deși nu sunt declarate propriu-zis ca fapte) de
% forma:
%
% - val/1 -- valori
% - var/1 -- variabile
% - add/2 -- adunare
% - mul/2 -- înmulțire
%
% Considerăm că „semnăturile” structurilor de mai sus sunt evidente. :)
%
% Să spunem că vrem să reprezentăm o mulțime de legări.
asgn(x, val(2)). % x <- 2
asgn(y, mul(add(val(2),val(3)),val(2))). % y <- (2 + 3) * 2 == 5 * 2 == 10
asgn(z, add(mul(var(x),var(y)),val(1))). % z <- (x * y) + 1 == (2 * 10) + 1 == 21

% Astfel, putem reprezenta evaluarea folosind predicatul eval/2,
% determinat e următoarele reguli.
%
% eval(+Expr, -Rezultat).
eval(val(N), N).
eval(mul(X,Y), N) :- eval(X, N1), eval(Y, N2), N is N1 * N2.
eval(add(X,Y), N) :- eval(X, N1), eval(Y, N2), N is N1 + N2.
eval(var(X), N) :- asgn(X, E), eval(E, N).
