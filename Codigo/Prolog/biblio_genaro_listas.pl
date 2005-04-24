%%:- module(biblio_genaro_listas).
:- module(biblio_genaro_listas,
			[sublista/4
                        ,sublista_pref/3
                        ,sublista_suf/3
                        ,escribeLista/2
                        ,listaAListaConSaltos/2
                        ,listaAStringConSaltos/2
                        ,dame_elemento_aleatorio/2
			,dame_elemento_aleatorio/3
                        ,dame_elemento_aleatorio/4
                        ,dame_permutacion_aleatoria/2
                        ,dame_elemento_aleat_lista_pesos/4
                        ,sustituye/4]).

/* Modulos de Prolog */
:- use_module(compat_Sicstus_SWI).
:- ensure_loaded(library(lists)).
%%:- use_module(library(lists)).
%%:- use_module(library(random)).

/* Modulos propios consultados */
:- use_module(biblio_genaro_ES).

/**
* sublista(+Xs, +Iini, +Ifin, -Ys)
* Ys es la lista que tiene los elementos de Xs en posiciones en [Iini, Ifin), contando las posiciones empezando por el 1
* @param +Xs 	Lista de entrada
* @param +Iini	Posicion inicial de la lista Xs
* @param +Ifin	Posicion final de la lista Xs. Este elemento no entra en Ys
* @param -Ys	Lista salida con los elementos de Xs de las posiciones [ Iini, Ifin )
*/
sublista(Xs, Iini, Ifin, Ys) :-
	sublista_acu(Xs, Iini, Ifin, 1, Ys).
sublista_acu([], _, _, _, []) :-
	!.
%se pone a la altura del marcador izquierdo
sublista_acu([_|Xs], Iini, Ifin, PosAct, Ys) :-
	PosAct < Iini,
	PosAct < Ifin,
	PosAct2 is PosAct +1,
	sublista_acu( Xs, Iini, Ifin, PosAct2, Ys).
%esta entre los dos marcadores
sublista_acu([X|Xs], Iini, Ifin, PosAct, [X|Ys]) :-
	PosAct >= Iini,
	PosAct < Ifin,
	PosAct2 is PosAct +1,
	sublista_acu( Xs, Iini, Ifin, PosAct2, Ys).
%ha sobrepasado el marcador derecho
sublista_acu(_, _, Ifin, PosAct, []) :-
	PosAct >=Ifin.



/**
* sublista_pref(+Xs, +Ifin, -Ys)
* Ys es la lista que tiene los elementos de Xs en posiciones en [1, Ifin), contando las posiciones empezando por el 1
* @param +Xs 	Lista de entrada
* @param +Ifin	Posicion final de la lista Xs. Este elemento no entra en Ys
* @param -Ys	Lista salida con los elementos de Xs de las posiciones [ 1, Ifin )
*/
sublista_pref(Xs, Ifin, Ys) :-
	sublista_pref_acu(Xs, Ifin, 1, Ys).
sublista_pref_acu([], _, _, []) :-
	!.
%esta delante del marcador derecho
sublista_pref_acu([X|Xs], Ifin, PosAct, [X|Ys]) :-
	PosAct < Ifin, PosAct2 is PosAct +1,
	sublista_pref_acu( Xs, Ifin, PosAct2, Ys).
%ha sobrepasado el marcador derecho
sublista_pref_acu(_, Ifin, PosAct, []) :-
	PosAct >=Ifin.



/**
* sublista_suf(+Xs, +Iini, -Ys)
* Ys es la lista que tiene los elementos de Xs en posiciones desde Iini (inclusive) hasta el final de la lista, es decir,
* en posiciones [Iini, Tam_lista] si lenght(Xs, TamLista), contando las posiciones empezando por el 1
* @param +Xs 	Lista de entrada
* @param +Iini	Posicion inicial de la lista Xs
* @param -Ys	Lista salida con los elementos de Xs de las posiciones [Iini, Tam_lista] si lenght(Xs, TamLista)
*/
sublista_suf(Xs, Iini, Ys) :-
	sublista_suf_acu(Xs, Iini, 1, Ys).
sublista_suf_acu([], _, _, []) :-
	!.
%se pone a la altura del marcador izquierdo
sublista_suf_acu([_|Xs], Iini, PosAct, Ys) :-
	PosAct < Iini,
	PosAct2 is PosAct +1,
	sublista_suf_acu( Xs, Iini, PosAct2, Ys).
%ha sobrepasado el marcador izquierdo
sublista_suf_acu([X|Xs], Iini, PosAct, [X|Ys]) :-
	PosAct  >= Iini,
	PosAct2 is PosAct +1,
	sublista_suf_acu( Xs, Iini, PosAct2, Ys).


/**
* dame_elemento_aleatorio(+Lista, -E)
* Dada la lista Lista elige aleatoriamente un elemento de ella.
* @param +Lista lista de elementos de cualquier tipo. El predicado falla si Lista es vacia
* @param -E es un elemento de Lista elegido aleatoriamente. La probabilidad de elegir cada elemento es la misma,
* 		e.d. 1/numero de elementos de Lista
*/
dame_elemento_aleatorio(Lista, E) :-
	length(Lista, L),
	random(0, L, Pos),
	nth0(Pos, Lista, E).

/**
* dame_elemento_aleatorio(+Lista, -E, -Pos)
* Dada una lista Lista elige aleatoriamente un elemento de ella, lo devuelve en E y ademas nos da su posicion dentro de
* dicha lista. EL predicado falla si Lista es vacia
* @param +Lista lista de elementos de cualquier tipo
* @param -E es un elemento de E elegido aleatoriamente. La probabilidad de elegir cada elemento es la misma,
* 		e.d. 1/numero de elementos de Lista
* @param -Pos posicion de E dentro de la lista numerando a partir de 1
*/
dame_elemento_aleatorio(Lista, E, PosAux) :-
	length(Lista, L),
	random(0, L, Pos),
	nth0(Pos, Lista, E),
	PosAux is Pos + 1.

/**
* dame_elemento_aleatorio(+Lista, -E, -Pos, -Resto)
* Dada una lista Lista elige aleatoriamente un elemento de ella, lo devuelve en E y ademas nos da su posicion dentro de
* dicha lista y la lista formada por todos los elementos de la lista de entrada menos el elemento elegido. El predicado
* falla si Lista es vacia
* @param +Lista lista de elementos de cualquier tipo
* @param -E es un elemento de E elegido aleatoriamente. La probabilidad de elegir cada elemento es la misma,
* 		e.d. 1/numero de elementos de Lista
* @param -Pos posicion de E dentro de la lista numerando a partir de 1
* @param -Resto lista formada por todos los elementos de la lista de entrada menos el elemento elegido
*/
dame_elemento_aleatorio(Lista, E, PosAux, Resto) :-
	length(Lista, L),
	random(0, L, Pos),
	nth0(Pos, Lista, E),
	PosAux is Pos + 1,
        sublista_pref(Lista, PosAux, Laux1),
        PosAux2 is Pos + 2, sublista_suf(Lista, PosAux2, Laux2),
        append(Laux1, Laux2, Resto).
/**
* dame_elemento_aleat_lista_pesos(+ListaPesos, -Elem, -Pos, -Resto)
* Dada una lista de parejas (termino, peso), donde los pesos son naturales, devuelve en Elem un elemento (es decir, primer
* componente de una de las parejas que forman la lista de entrada) elegido al azar entre de los de la lista asignando a cada
* elemento/pareja una probabilidad de ser elegida igual a (peso/sumaPesos)*100, donde suma pesos es la suma de los pesos de
* todos los elementos de la lista
* */
dame_elemento_aleat_lista_pesos(ListaPesos, Elem, Pos, Resto) :-
	calculaSumaPesos(ListaPesos, SumaPesos), SumaPesos >0, SumaPesosMas is SumaPesos + 1,
        random(1, SumaPesosMas, Porcentaje), aplicaPorcentajeSumaPesos(Porcentaje, ListaPesos, Elem, Pos, Resto).

calculaSumaPesos([], 0).
calculaSumaPesos([(_, N)|Ls], Suma) :- calculaSumaPesos(Ls, SumaParc), Suma is N + SumaParc.

/*aplicaPorcentajeSumaPesos(Porcentaje, ListaPesos, Elem, Pos, Resto) :-
	aplicaPorcentajeSumaPesosAcu(Porcentaje, ListaPesos, PosicionEnRecta, Elem, Pos, Resto).*/

aplicaPorcentajeSumaPesos(Porcentaje, ListaPesos, Elem, Pos, Resto) :-
	aplicaPorcentajeSumaPesosAcu(Porcentaje, ListaPesos, 1, 1, Elem, Pos),
        sublista_pref(ListaPesos, Pos, Laux1),
        PosAux is Pos + 1, sublista_suf(ListaPesos, PosAux, Laux2),
        append(Laux1, Laux2, Resto).

aplicaPorcentajeSumaPesosAcu(_, [], _, _, ninguno, -1) :- !.
aplicaPorcentajeSumaPesosAcu(Porcentaje, [(Termino, Peso)|_], PosEnRecta, PosEnLista, Termino, PosEnLista) :-
	Porcentaje >= PosEnRecta,
        ExtremoDcho is (PosEnRecta + Peso - 1), Porcentaje =< ExtremoDcho,!.

aplicaPorcentajeSumaPesosAcu(Porcentaje, [(_, Peso)|Ls], PosEnRecta, PosEnLista, Elem, Pos) :-
	SigPosEnRecta is (PosEnRecta + Peso), SigPosEnLista is PosEnLista + 1,
	aplicaPorcentajeSumaPesosAcu(Porcentaje, Ls, SigPosEnRecta, SigPosEnLista, Elem, Pos).

/**
* dame_permutacion_aleatoria(+ListaEntrada, -ListaPermutada) dada una lista de elementos devuelve otra lista formada por los elementos
* de la lista de entrada permutados aleatoriamente
* @param +Lista lista de entrada sobre la que se permuta
* @param -ListaPermutada formada por los elementos de la lista de entrada permutados aleatoriamente
*/
dame_permutacion_aleatoria([], []):-!.
dame_permutacion_aleatoria(ListaEntrada, [ElemElegido| RestoPermutado]) :-
	dame_elemento_aleatorio(ListaEntrada, ElemElegido, _ ,RestoParcial),
	dame_permutacion_aleatoria(RestoParcial, RestoPermutado).
/**
* escribeLista(+Ruta, +Lista)
* escribe la lista de entrada en el fichero indicado por la ruta, sobreescribiendo el fichero
* o creándolo si este no existía. Al escribir la lista pone un salto de linea dentro del fichero
* entre cada elemento de la lista.
* @param +Ruta es una lista de caracteres entre ' '
* @param +Lista lista a escribir, cumple que es una lista
*/
escribeLista(Ruta, Lista) :-
	listaAListaConSaltos(Lista, ListaSaltos),
	escribeTermino(Ruta, ListaSaltos).

/**
* listaAListaConSaltos(+Lista, -ListaSaltos) : devuelve en ListaSaltos una lista igual a Lista salvo pq se ha introducido un caracter
* '\n' detrás de cada elemento de la lista
* @param +Lista cumple que es una lista cualquiera
* @param -ListaSaltos es una lista identica a Lista pero con un cierto formateo
*/
listaAListaConSaltos([], []).
listaAListaConSaltos([X|Xs], [X, '\n'|Ys]) :-
	listaAListaConSaltos(Xs, Ys).

listaAStringConSaltos(L, Str) :-
	listaAStringConSaltosAcu(L,StrContenido),
        string_to_atom(StrCorcheteAbre,'['),
        string_to_atom(StrCorcheteCierra,']'),
        string_concat(StrCorcheteAbre, StrContenido, StrAux),
        string_concat(StrAux, StrCorcheteCierra, Str).


listaAStringConSaltosAcu([],Str) :- string_to_list(Str,[]).
listaAStringConSaltosAcu([X|Xs], Str) :-
                term_to_atom(X,AtX),
		string_to_atom(StrX,AtX), string_to_atom(StrSalto, ',\n'),
                string_concat(StrX, StrSalto, StrXSalto),
                listaAStringConSaltosAcu(Xs, StrXs),
                string_concat(StrXSalto,StrXs, Str).

/**
* sustituye(+Lin, +N, +Elem, -Lout) : sustituye el elemento N de Lin por Elem y lo guarda en Lout. 
* Suponemos que la lista comienza en 1
*/
sustituye( [_ | Xs], 1, Elem, [Elem | Xs] ).
sustituye( [X | Xs], N, Elem, [X | Lout] ) :-
        N2 is N - 1
       ,sustituye(Xs, N2, Elem, Lout).

