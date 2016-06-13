%% PP, laboratorul 13

% Parser de expresii aritmetice.
%
% AST-ul arată ca în laboratorul anterior:
%
% - var(string_alpha)
% - val(număr_întreg)
% - add(Expr1, Expr2)
% - mul(Expr1, Expr2)
%
% unde Expr1 și Expr2 sunt subexpresii.
%
% Parser-ul are două stagii: parsarea tokenilor (e.g. numere întregi,
% nume de variabile -- practic lexer-ul), apoi parsarea expresiilor
% propriu-zise. Pentru simplificare, considerăm că operatorii (gen '+'
% sau '*') sunt deja tokeni, iar restul tokenilor sunt înconjurați de
% whitespace.
%
% Gramatica asociată parser-ului ar fi, în mare:
%
% E -> T + E | T
% T -> Tok * T | Tok
% Tok -> WS Var WS | WS Val WS
% WS -> ' 'WS | șirul vid % spații de zero sau mai multe ori
% Var -> Alpha Var | Alpha % caractere cel puțin o dată
% Val -> Digit Val | Digit % cifre de cel puțin o dată
% Alpha -> a | b | c | d | ... | z
% Digit -> 0 | 1 | 2 | ... | 9
%
% Considerăm că parserele au forma:
%
% parser(List, Object, Rest).
%
% unde List e o listă de caractere, Object e obiectul rezultat, iar Rest
% e ce mai rămâne de parsat.

% Începem bottom-up, cu alpha și digit. Folosim char_type/2 pentru a
% pune condiția ca caracterul să fie alfabetic, respectiv numeric.
parse_alpha([H|T], H, T) :- char_type(H, alpha).
parse_digit([H|T], H, T) :- char_type(H, digit).

% De asemenea, vrem să parsăm caractere precum spațiu, +, *, etc. Primul
% parametru este extra, denotând caracterul parsat.
parse_char(C, [C|T], C, T).

% single white spaces
parse_sgws(String, Object, Rest) :- parse_char(' ', String, Object, Rest).

% Cum parsăm string-uri, respectiv numere? Trebuie să aplicăm repetat
% parse_alpha, respectiv parse_digit. Pentru asta definim două
% meta-predicate (definite și la curs), star și plus, care apelează un
% predicat de zero sau mai multe ori, respectiv cel puțin o dată.
star(Pred, String, [R|Results], Rest) :- call(Pred, String, R, Rest1),
                                         star(Pred, Rest1, Results, Rest),
                                         !.
star(_, String, [], String).

plus(Pred, String, [R|Results], Rest) :- call(Pred, String, R, Rest1),
                                         star(Pred, Rest1, Results, Rest).

% Acum putem parsa Var și Val. Folosim atomic_list_concat pentru a
% concatena lista de caractere obținută. Folosim atom_number pentru a
% converti un string atomic la un număr.
parse_var(String, Object, Rest) :- plus(parse_alpha, String, Atoms, Rest),
                                   atomic_list_concat(Atoms, Object).

parse_val(String, Object, Rest) :- plus(parse_digit, String, Atoms, Rest),
                                   atomic_list_concat(Atoms, Atom),
                                   atom_number(Atom, Object).

% Parsarea whitespace-urilor se face similar.
parse_ws(String, Object, Rest) :- star(parse_sgws, String, Object, Rest),
                                  !.
% Bonus: parsarea subexpresiilor aflate în paranteze
%% parse_tok(String, Object, Rest) :- parse_ws(String, _, String1),
%%                                    parse_char('(', String1, _, String2),
%%                                    parse_add(String2, Object, String3),
%%                                    parse_char(')', String3, _, String4),
%%                                    parse_ws(String4, _, Rest).
% Acum putem parsa tokeni: valori, respectiv variabile, separate
% (posibil) prin spații
parse_tok(String, Object, Rest) :- parse_ws(String, _, String1),
                                   (parse_val(String1, Object, String2) ;
                                    parse_var(String1, Object, String2)),
                                   parse_ws(String2, _, Rest).

% Termenii unei înmulțiri.
parse_mul(String, mul(X, Y), Rest) :- parse_tok(String, X, String1),
                                      parse_char('*', String1, _, String2),
                                      parse_mul(String2, Y, Rest),
                                      !.
parse_mul(String, Object, Rest) :- parse_tok(String, Object, Rest).

% Expresii de tip adunare. Ca mai sus.
parse_add(String, add(X, Y), Rest) :- parse_mul(String, X, String1),
                                      parse_char('+', String1, _, String2),
                                      parse_add(String2, Y, Rest),
                                      !.
parse_add(String, Object, Rest) :- parse_mul(String, Object, Rest).

% Parsare generică. Folosim atom_chars pentru a converti dintr-un string
% în listă de caractere.
parse(AtomString, Object, Rest) :- atom_chars(AtomString, ListString),
                                   parse_add(ListString, Object, Rest).

% Bonus: parsarea subexpresiilor (aflate între paranteze). See the
% additional parse_tok clause.
