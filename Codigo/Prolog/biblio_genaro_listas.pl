/* sublista(Xs, Iini, Ifin, Ys)
Ys es la lista que tiene los elementos de Xs en posiciones en [Iini, Ifin), contando las posiciones empezando por el 1*/
sublista(Xs, Iini, Ifin, Ys) :- sublista_acu(Xs, Iini, Ifin, 1, Ys).
sublista_acu([], _, _, _, []) :- !.
%se pone a la altura del marcador izquierdo
sublista_acu([_|Xs], Iini, Ifin, PosAct, Ys) :- PosAct < Iini, PosAct < Ifin,  PosAct2 is PosAct +1
						,sublista_acu( Xs, Iini, Ifin, PosAct2, Ys).
%esta entre los dos marcadores
sublista_acu([X|Xs], Iini, Ifin, PosAct, [X|Ys]) :- PosAct >= Iini, PosAct < Ifin, PosAct2 is PosAct +1
						,sublista_acu( Xs, Iini, Ifin, PosAct2, Ys).
%ha sobrepasado el marcador derecho
sublista_acu(_, _, Ifin, PosAct, []) :- PosAct >=Ifin.



/*sublista_pref(Xs, Ifin, Ys)
Ys es la lista que tiene los elementos de Xs en posiciones en [1, Ifin), contando las posiciones empezando por el 1*/
sublista_pref(Xs, Ifin, Ys) :- sublista_pref_acu(Xs, Ifin, 1, Ys).
sublista_pref_acu([], _, _, []) :- !.
%esta delante del marcador derecho
sublista_pref_acu([X|Xs], Ifin, PosAct, [X|Ys]) :- PosAct < Ifin, PosAct2 is PosAct +1
						,sublista_pref_acu( Xs, Ifin, PosAct2, Ys).
%ha sobrepasado el marcador derecho
sublista_pref_acu(_, Ifin, PosAct, []) :- PosAct >=Ifin.



/*sublista_suf(Xs, Iini, Ys)
Ys es la lista que tiene los elementos de Xs en posiciones desde Iini (inclusive) hasta el final de la lista, es decir, en
posiciones [Iini, Tam_lista] si lenght(Xs, TamLista)*/
sublista_suf(Xs, Iini, Ys) :- sublista_suf_acu(Xs, Iini, 1, Ys).
sublista_suf_acu([], _, _, []) :- !.
%se pone a la altura del marcador izquierdo
sublista_suf_acu([_|Xs], Iini, PosAct, Ys) :- PosAct < Iini, PosAct2 is PosAct +1
						,sublista_suf_acu( Xs, Iini, PosAct2, Ys).
%ha sobrepasado el marcador izquierdo
sublista_suf_acu([X|Xs], Iini, PosAct, [X|Ys]) :- PosAct  >= Iini, PosAct2 is PosAct +1
						,sublista_suf_acu( Xs, Iini, PosAct2, Ys).


/*dame_elemento_aleatorio(Lista, E) 
in: Lista lista de elementos de cualquier tipo
out: E es un elemento de E elegido aleatoriamente. La probabilidad de elegir cada elemento es la misma, e.d. 1/numero de elementos de Lista
dame_elemento_aleatorio(Lista, E, Pos) 
in: Lista lista de elementos de cualquier tipo
out: E es un elemento de E elegido aleatoriamente. La probabilidad de elegir cada elemento es la misma, e.d. 1/numero de elementos de Lista
Pos: posicion de E dentro de la lista numerando a partir de 1
*/
dame_elemento_aleatorio(Lista, E) :- length(Lista, L), random(0, L, Pos)	,nth0(Pos, Lista, E).
dame_elemento_aleatorio(Lista, E, PosAux) :- length(Lista, L), random(0, L, Pos) ,nth0(Pos, Lista, E), PosAux is Pos + 1.
