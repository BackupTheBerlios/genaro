%DESCRIPCION
/*
* Modulo que se encarga de generar semillas varias para la generacion de acordes, es decir, terminos S
* que cumplen es_progresion(S) y que expresan progresiones de acordes de longitud reducida
* POR AHORA TODO PARA BINARIO IMPLICITO
* */

%DECLARACION DEL MODULO
%:- module(generador_acordes_semillas).
:- module(generador_acordes_semillas,
                 [haz_prog_semilla/3
                  ,haz_prog_semilla/2
                  ,rango_prog_semilla/3
                  ,termina_haz_prog_semilla/1]).

%BIBLIOTECAS
%%:- use_module(library(lists)).
:- ensure_loaded(library(lists)).

%ARCHIVOS PROPIOS CONSULTADOS
:- use_module(generador_acordes_binario).
:- use_module(generador_acordes).
:- use_module(biblio_genaro_acordes).
:- use_module(biblio_genaro_listas).
:- use_module(biblio_genaro_fracciones).

		%PREDICADOS PARA CONSTRUIR SEMILLAS
/*!!!NO USA haz_prog_semilla2 PQ NO SE SI MANTIENE COMO INVARIANTE QUE EL RITMO ARMONICO SEA CORRECTO*/
/**
* haz_prog_semilla(+NumCompases, +Tipo,-S) devuelve en S una progresion pequeña usada en el principio de la generación.
* Esta progresion respetará el ritmo armonico
* @param +NumCompases natural que indica el numero exacto de compases que se quiere que dure la progresion semilla.
* !!!IMPORTANTE!!!: NumCompasese debe pertener al conjunto {0, 1, 2, 3, 4} si Tipo = 1 , o al conjunto {0, 1, 2, 3} si
* Tipo = 3 o fallará
* la evaluacion
* @param +Tipo si vale n entonces se utilizará haz_prog_semillan/2 para la generacion de la semilla, debe pertenecer al conjunto
* {1, 3} por ahora
* @param -S cumple generador_acordes:es_progresion(S)
* */
haz_prog_semilla(N,_ ,progresion([])) :- N =< 0, !, termina_haz_prog_semilla(progresion([])).
haz_prog_semilla(1,_ ,progresion([(C, figura(1,1))])) :-
	!, dame_grado_funcTonal_equiv2(grado(i), G), hazCuatriada(G,C),
        termina_haz_prog_semilla(progresion([(C, figura(1,1))])).

haz_prog_semilla(N, Tipo, S) :-
	haz_prog_semilla(Tipo, S),  numCompases(S, NumCompFloat),
        NumComp is ceiling(NumCompFloat), N = NumComp, /*pq en SWI el ceiling da un entero*/
        termina_haz_prog_semilla(S).

termina_haz_prog_semilla(progresion(S)) :-
        fichero_destinoGenAc_prog_semilla(FDest), escribeLista(FDest, S).

/**
* haz_prog_semilla(+Tipo,-S) devuelve en S una progresion pequeña usada en el principio de la generación.
* Esta progresion respetará el ritmo armonico y durara un numero de compases no determinado en un intervalos que
* depende de Tipo, entre 2 y 4 compases si este vale 1 y entre 2 y 3 compases si vale 3
* @param +Tipo si vale n entonces se utilizará haz_prog_semillan/2 para la generacion de la semilla, debe pertenecer al conjunto
* {1, 3} por ahora
* @param -S cumple generador_acordes:es_progresion(S)
* */
haz_prog_semilla(1,S) :- haz_prog_semilla1(S), termina_haz_prog_semilla(S).
/*haz_prog_semilla(2,S) :- haz_prog_semilla2(S), termina_haz_prog_semilla(S). garantiza el ritmo armonico correcto?? */
haz_prog_semilla(3,S) :- haz_prog_semilla3(S), termina_haz_prog_semilla(S).

/**
* rango_prog_semilla(+Tipo,-NumMin, -NumMax).
* @param -NumMin indica el número mínimo de compases que puede durar una progresión generada
* con el predicado haz_prog_semillaTipo/1
* @param -NumMax indica el número máximo de compases que puede durar una progresión generada
* con el predicado haz_prog_semillaTipo/1
* */
rango_prog_semilla(1,Min,Max) :- rango_prog_semilla1(Min,Max).
rango_prog_semilla(3,Min,Max) :- rango_prog_semilla3(Min,Max).

/**
* haz_prog_semilla1(-S). Devuelve en S una progresion que se usa para empezar la generación de la progresión entera. Esta progresion
* de salida es una cadencia o un patrón de acordes (ver es_patron_acordes/1 y es_cadencia/1) elegida al azar. Por tanto durará
* dos compases como minimo y cuatro como maximo. Esta progresion respetará el ritmo armonico
* @param -S cumple generador_acordes:es_progresion(S)
* */
haz_prog_semilla1(S) :- setof(Lg1, cadenciaValida(cadencia(Lg1,_)), Lc1)
        ,setof(Lg2, patAcordesVal(patAcord(Lg2,_)), Lc2), append(Lc1,Lc2,Lc)
	,dame_elemento_aleatorio(Lc, ListaGrados),listaGradosAProgresion(ListaGrados,S).
/**
* rango_prog_semilla1(-NumMin, -NumMax).
* @param -NumMin indica el número mínimo de compases que puede durar una progresión generada
* con el predicado haz_prog_semilla1/1
* @param -NumMax indica el número máximo de compases que puede durar una progresión generada
* con el predicado haz_prog_semilla1/1
* */
rango_prog_semilla1(0,4).

/**
* haz_prog_semilla3(-S). Devuelve en S una progresion que se usa para empezar la generación de la progresión entera. Esta progresion
* de salida es una cadencia (ver es_cadencia/1) a la que se le ha aplicado 10 veces el predicado cambia_acordes. Por tanto durará
* dos compases como minimo y tres como maximo. Esta progresion respetará el ritmo armonico
* @param -S cumple es_progresion(S)
* */
haz_prog_semilla3(S) :- setof(Lg, cadenciaValida(cadencia(Lg,_)), Lc)
				,dame_elemento_aleatorio(Lc, ListaGrados)
				,listaGradosAProgresion(ListaGrados, A)
				,aplica_cambia_acordes(A, 10, S).

aplica_cambia_acordes(Ori, N, Dest) :- N>0, !, N1 is N -1, cambia_acordes(Ori, Aux1), aplica_cambia_acordes(Aux1, N1, Dest).
aplica_cambia_acordes(Ori, _, Ori).
/**
* rango_prog_semilla3(-NumMin, -NumMax).
* @param -NumMin indica el número mínimo de compases que puede durar una progresión generada
* con el predicado haz_prog_semilla3/1
* @param -NumMax indica el número máximo de compases que puede durar una progresión generada
* con el predicado haz_prog_semilla3/1
* */
rango_prog_semilla3(0,3).

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
%cadenciaValida(cadencia([grado(v),grado(i)],0)).%autentica basica
cadenciaValida(cadencia([grado(iv),grado(v),grado(i)],1)).	%autentica
cadenciaValida(cadencia([grado(ii),grado(v),grado(i)],2)).	%autentica moderna
/*		%plagal
cadenciaValida(cadencia([grado(iv),grado(i)],3)).			%plagal basica
cadenciaValida(cadencia([grado(iv),grado(iii)],4)).			%plagal
cadenciaValida(cadencia([grado(iv),grado(vi)],5)).			%plagal
cadenciaValida(cadencia([grado(ii),grado(i)],6)).			%plagal
cadenciaValida(cadencia([grado(ii),grado(iii)],7)).			%plagal
cadenciaValida(cadencia([grado(ii),grado(vi)],8)).			%plagal*/
	%suspensivas
		%rota
/*cadenciaValida(cadencia([grado(v),grado(iii)],9)).
cadenciaValida(cadencia([grado(v),grado(vi)],10)).*/
cadenciaValida(cadencia([grado(iv),grado(v),grado(iii)],11)).
cadenciaValida(cadencia([grado(iv),grado(v),grado(vi)],12)).
cadenciaValida(cadencia([grado(ii),grado(v),grado(iii)],13)).
cadenciaValida(cadencia([grado(ii),grado(v),grado(vi)],14)).
/*cadencias modificadas para ajustarse al ritmo armonico*/
cadenciaValida(cadencia([grado(i),grado(v),grado(i)],0)).%autentica basica
		%plagal
cadenciaValida(cadencia([grado(i),grado(iv),grado(i)],3)).			%plagal basica
cadenciaValida(cadencia([grado(iii),grado(iv),grado(iii)],4)).			%plagal
cadenciaValida(cadencia([grado(vi),grado(iv),grado(vi)],5)).			%plagal
cadenciaValida(cadencia([grado(i),grado(ii),grado(i)],6)).			%plagal
cadenciaValida(cadencia([grado(iii),grado(ii),grado(iii)],7)).			%plagal
cadenciaValida(cadencia([grado(vi),grado(ii),grado(vi)],8)).			%plagal
cadenciaValida(cadencia([grado(iii),grado(v),grado(iii)],9)).
cadenciaValida(cadencia([grado(vi),grado(v),grado(vi)],10)).
		/*cadencias de dos acordes : todas semicadencias*/
cadenciaValida(cadencia([grado(iv),grado(v)],15)).
cadenciaValida(cadencia([grado(ii),grado(v)],16)).
cadenciaValida(cadencia([grado(i),grado(iv)],17)).
cadenciaValida(cadencia([grado(iii),grado(iv)],18)).
cadenciaValida(cadencia([grado(vi),grado(iv)],19)).
cadenciaValida(cadencia([grado(i),grado(ii)],20)).
cadenciaValida(cadencia([grado(iii),grado(ii)],21)).
cadenciaValida(cadencia([grado(vi),grado(ii)],22)).
num_cadencias(23).

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
/*mantiene el ritmo armonico pq es fuerte - debil y el debil es subdom - dom que cumple + fuerte a debil*/
patAcordesVal(patAcord([grado(i),grado(vi),grado(ii),grado(v)],0)).
/*mantiene el ritmo armonico*/
patAcordesVal(patAcord([grado(i),grado(v7 / v),grado(ii),grado(v)],1)).
/*mantiene el ritmo armonico*/
patAcordesVal(patAcord([grado(i),grado(v7 / ii),grado(ii),grado(v)],2)).
/*mantiene el ritmo armonico*/
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
