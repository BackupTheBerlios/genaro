%DESCRIPCION
/*
* Modulo que se encarga de generar semillas varias para la generacion de acordes, es decir, terminos S
* que cumplen es_progresion(S) y que expresan progresiones de acordes de longitud reducida
* */

%DECLARACION DEL MODULO
%:- module(generador_acordes_semillas).
:- module(generador_acordes_semillas,[haz_prog_semilla/2]).

%BIBLIOTECAS
:- use_module(library(lists)).

%ARCHIVOS PROPIOS CONSULTADOS
:- use_module(biblio_genaro_acordes).
:- use_module(biblio_genaro_listas).

		%PREDICADOS PARA CONSTRUIR SEMILLAS
/**
* haz_prog_semilla(Tipo,S) devuelve en S una progresion pequeña usada en el principio de la generación.
* @param +Tipo si vale n entonces se utilizará haz_prog_semillan/2 para la generacion de la semilla
* @param -S cumple generador_acordes:es_progresion(S)
* */
haz_prog_semilla(1,S) :- haz_prog_semilla1(S).
haz_prog_semilla(2,S) :- haz_prog_semilla2(S).
haz_prog_semilla(3,S) :- haz_prog_semilla3(S).

/**
* haz_prog_semilla1(S). Devuelve en S una progresion que se usa para empezar la generación de la progresión entera. Esta progresion
* de salida es una cadencia o un patrón de acordes (ver es_patron_acordes/1 y es_cadencia/1)
* @param -S cumple generador_acordes:es_progresion(S)
* */
haz_prog_semilla1(S) :- setof(Lg1, cadenciaValida(cadencia(Lg1,_)), Lc1)
        ,setof(Lg2, patAcordesVal(patAcord(Lg2,_)), Lc2), append(Lc1,Lc2,Lc)
	,dame_elemento_aleatorio(Lc, ListaGrados),listaGradosAProgresion(ListaGrados,S).

/**
* haz_prog_semilla3(S). Devuelve en S una progresion que se usa para empezar la generación de la progresión entera. Esta progresion
* de salida es una cadencia (ver es_cadencia/1) a la que se le ha aplicado 10 veces el predicado cambia_acordes
* @param -S cumple es_progresion(S)
* */
haz_prog_semilla3(S) :- setof(Lg, cadenciaValida(cadencia(Lg,_)), Lc)
				,dame_elemento_aleatorio(Lc, ListaGrados)
				,listaGradosAProgresion(ListaGrados, A)
				,aplica_cambia_acordes(A, 10, S).

%CADENCIAS
/**
* es_cadencia(+C)
* Se cumple si P es un termino con la estructura que se le exige a una cadencia,
* es decir, si es la aplicacion de la constructora cadencia de aridad 2 a un par
* formado por una lista de grados y un natural identificador, y si ese natural pertenece
* al intervalo [0, numCadencias], donde numCadencias es el numero de cadencias almacenadas
* en este sistema
* @param +C termino cuya estructura se quiere analizar para ver si corresponde con la deseada
* */
es_cadencia(cadencia(C,I)) :- es_listaDeGrados(C), natural(I),num_cadencias(N),I<N.

es_listaDeGrados([]).
es_listaDeGrados([G|Gs]) :- es_grado(G), es_listaDeGrados(Gs).

/**
* cadenciaValida(+-C)
* Con este predicado se especifican los terminos que ademas de tener la estructura de una
* cadencia corresponden a cadencias según el sistema de armonia moderna, que ademas hayan sido
* almacenadas en este sistema
* @param +-C si cumple es_cadencia y corresponde a una cadencia de la armonia moderna , que ademas haya sido
* almacenada en este sistema el predicado se cumple
* */
%lista de cadencias
	%conclusivas
		%autentica
cadenciaValida(cadencia([grado(v),grado(i)],0)).%autentica basica
cadenciaValida(cadencia([grado(iv),grado(v),grado(i)],1)).	%autentica
cadenciaValida(cadencia([grado(ii),grado(v),grado(i)],2)).	%autentica moderna
		%plagal
cadenciaValida(cadencia([grado(iv),grado(i)],3)).			%plagal basica
cadenciaValida(cadencia([grado(iv),grado(iii)],4)).			%plagal
cadenciaValida(cadencia([grado(iv),grado(vi)],5)).			%plagal
cadenciaValida(cadencia([grado(ii),grado(i)],6)).			%plagal
cadenciaValida(cadencia([grado(ii),grado(iii)],7)).			%plagal
cadenciaValida(cadencia([grado(ii),grado(vi)],8)).			%plagal
	%suspensivas
		%semicadencia: reposo en dominante??
		%rota
cadenciaValida(cadencia([grado(v),grado(iii)],9)).
cadenciaValida(cadencia([grado(v),grado(vi)],10)).
cadenciaValida(cadencia([grado(iv),grado(v),grado(iii)],11)).
cadenciaValida(cadencia([grado(iv),grado(v),grado(vi)],12)).
cadenciaValida(cadencia([grado(ii),grado(v),grado(iii)],13)).
cadenciaValida(cadencia([grado(ii),grado(v),grado(vi)],14)).
num_cadencias(15).
/*No asumo las cadencias como cambios de las cadencias básicas pq entonces no estoy
contando bien el numero de mutaciones q hago a la progresion*/


%PATRONES DE ACORDES
/**
* es_patron_acordes(+P)
* Se cumple si P es un termino con la estructura que se le exige a un patron de acordes,
* es decir, si es la aplicacion de la constructora cadencia de aridad 2 a un par
* formado por una lista de grados y un natural identificador, y si ese natural pertenece
* al intervalo [0, numPatrones], donde numPatrones es el numero de Patrones almacenadas
* en este sistema
* @param +P termino cuya estructura se quiere analizar para ver si corresponde con la deseada
* */
es_patron_acordes(patAcord(C,I)) :- es_listaDeGrados(C), natural(I),num_patrones_acordes(N),I<N.

/**
* patAcordesVal(+-P)
* Con este predicado se especifican los terminos que ademas de tener la estructura de un patron de
* acordes corresponden a patrones de acordes según el sistema de armonia moderna, que ademas hayan sido
* almacenados en este sistema
* @param +-P si cumple es_patron_acordes y corresponde a un patron de acordes de la armonia moderna ,
* que ademas haya sido almacenado en este sistema el predicado se cumple
* */
patAcordesVal(patAcord([grado(i),grado(vi),grado(ii),grado(v)],0)).
patAcordesVal(patAcord([grado(i),grado(v7 / v),grado(ii),grado(v)],1)).
patAcordesVal(patAcord([grado(i),grado(v7 / ii),grado(ii),grado(v)],2)).
patAcordesVal(patAcord([grado(i),grado(v7 / iv),grado(iv),grado(ivm6)],3)).
num_patrones_acordes(4).

/**
* listaGradosAProgresion(+ListaGrados, -Progresion).
* Convierte una lista de grados en una progresión de acordes en la que cada acorde dura una redonda.
* A cada grado le hace corresponder su cuatríada segun la armonizacion de la escala mayor para grados
* diatónicos, ver biblio_genaro_acordes:hazCuatriada pq ese es el predicado que se usa para transformar
* cada grado individual en cuatriada
* @param +ListaGrados hace cierto el predicado es_listaDeGrados
* @param -Progresion hace cierto el predicado es_progresion
*/
listaGradosAProgresion(LG, progresion(Prog)) :- listaGradosAProgresionRec(LG,Prog).
listaGradosAProgresionRec([],[]).
listaGradosAProgresionRec([G|Gs],[(C, figura(1,1))|Ps]) :-
		hazCuatriada(G,C) ,listaGradosAProgresionRec(Gs,Ps).

/*****************************************************************************************
	CODIGO DE ROBERTO PARA UNA PRUEBA DE HAZ_PROG_SEMILLA2
*****************************************************************************************/

% No tengo el numero de acordes que tengo que generar, supongo 4

haz_prog_semilla2(S) :-
	genera_grados_aleatoriamente(LG1),
	arregla_lista_grados(LG1,LG2),
	listaGradosAProgresion(LG2, S).


% genera 4 grados totalmente aleatorios

genera_grados_aleatoriamente([A,B,C,D]) :-
	random(0,7,NA), entero_a_grado(NA, A),
	random(0,7,NB), entero_a_grado(NB, B),
	random(0,7,NC), entero_a_grado(NC, C),
	random(0,7,ND), entero_a_grado(ND, D).


% de numero a grado

entero_a_grado(0,grado(i)).
entero_a_grado(1,grado(ii)).
entero_a_grado(2,grado(iii)).
entero_a_grado(3,grado(iv)).
entero_a_grado(4,grado(v)).
entero_a_grado(5,grado(vi)).
entero_a_grado(6,grado(vii)).

% Añade un grado con funcion de tonica despues del de dominante

arregla_lista_grados([],[]) :-
	!.
arregla_lista_grados([G1],[G1,G2]) :-
	dameFuncionTonal(G1, dominante),
	!,
	dame_grado_de_tonica(G2).
arregla_lista_grados([G],[G]) :-
	!.
arregla_lista_grados([ G1, G2 | Resto ], [ G1 | RestoArreglao] ) :-
	dameFuncionTonal( G1, dominante ),
	dameFuncionTonal( G2, tonica ),
	!,
	arregla_lista_grados( [G2 | Resto], RestoArreglao ).
arregla_lista_grados([ G1, G2 | Resto ], [ G1, GT | RestoArreglao] ) :-
	dameFuncionTonal( G1, dominante ),
	!,
	dame_grado_de_tonica(GT),
	arregla_lista_grados( [ G2 | Resto], RestoArreglao ).
arregla_lista_grados([ G1, G2 | Resto ], [ G1 | RestoArreglao] ) :-
	arregla_lista_grados( [ G2 | Resto], RestoArreglao ).



% devuelve un grado que es de tonica

entero_a_tonica(0,grado(i)).
entero_a_tonica(1,grado(iii)).
entero_a_tonica(2,grado(vi)).

dame_grado_de_tonica(GT) :-
	random(0,3,Num),
	entero_a_tonica(Num,GT).



/*

ejemplo1 :-
	arregla_lista_grados([grado(vii),grado(vii),grado(v),grado(v)], L),
	write(L).
ejemplo2 :-
	arregla_lista_grados([grado(v)], L),
	write(L).
ejemplo3 :-
	arregla_lista_grados([grado(v),grado(i)], L),
	write(L).
ejemplo4 :-
	arregla_lista_grados([grado(v),grado(i),grado(vi),grado(vii)], L),
	write(L).

*/
