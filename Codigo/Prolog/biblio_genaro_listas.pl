
:- module(biblio_genaro_listas,
			[sublista/4
                        ,sublista_pref/3
                        ,sublista_suf/3
                        ,escribeLista/2
                        ,dame_elemento_aleatorio/2
			,dame_elemento_aleatorio/3]).

/* Modulos de Prolog */
:- use_module(library(lists)).
:- use_module(library(random)).

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
* @param -Ys	Lista salida con los elementos de Xs de las posiciones [ Iini, Ifin )
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
* en posiciones [Iini, Tam_lista] si lenght(Xs, TamLista)
* @param +Xs 	Lista de entrada
* @param +Iini	Posicion inicial de la lista Xs
* @param -Ys	Lista salida con los elementos de Xs de las posiciones [ Iini, Ifin )
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
* escribeLista(+Lista, +Ruta)
* escribe la lista de entrada en el fichero indicado por la ruta, sobreescribiendo el fichero
* o creándolo si este no existía. Al escribir la lista pone un salto de linea dentro del fichero 
* entre cada elemento de la lista.
* @param +Lista lista a escribir, cumple que es una lista
* @param +Ruta es una lista de caracteres entre ' '
*/
escribeLista(Lista, Ruta) :- 
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



