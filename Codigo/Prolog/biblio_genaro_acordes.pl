:- module(biblio_genaro_acordes,[
	inversion_y_disposicion/4,
	vector_suma/2,
	gradoANumNota/2,
	suma_vector/3,
	eleccion_aleatoria/5,
	traduce_cifrado/4,
	traduce_a_estado_fundamental/2,
	trasponer/3,
	normaliza_altura/2,
	mostrar_acorde/1,
	es_acorde/1,
	es_lista_orden_acordes/1,
	es_progresion_ordenada/1,
        hazCuatriada/2
]).


:- use_module(representacion_prolog_haskore).
:- use_module(compat_Sicstus_SWI).
:- ensure_loaded(library(lists)).
%:- use_module(library(random)).
%:- use_module(library(lists)).


/* Definicion de la estructura */

/**
* es_progresion_ordenada(+ProgresionOrd)
* Es una lista de acordes ordenados con la constructora progOrdenada
* @param +ProgresionOrd verifica si es una progresion ordenada o no
*/
es_progresion_ordenada(progOrdenada(Loa)) :-
	es_lista_orden_acordes(Loa).

/**
* es_lista_orden_acordes(+ListaAcordesOrdenados)
* es una lista de acordes ordenados
* @param +ListaAcordesOrdenados verifica si es una lista de acordes ordenados
*/
es_lista_orden_acordes([]).
es_lista_orden_acordes([(Ac,F)|Loa]) :-
	es_acorde(Ac),es_figura(F),
	es_lista_orden_acordes(Loa).

/**
* es_acorde(+Acorde)
* Un acorde es una lista de alturas
* @param +Acorde lista de alturas
*/
es_acorde( acorde(Lista) ) :-
	es_acorde_recursivo(Lista).

/**
* es_acorde_recursivo(+ListaAlturas).
* Objetivo auxiliar de es_acorde. Identifica cada elemento para ver si es una altura
* @param +ListaAlturas una lista de alturas
*/
es_acorde_recursivo([]).
es_acorde_recursivo([Altura | RestoAlturas]) :-
	es_altura(Altura),
	es_acorde_recursivo(RestoAlturas).


/**
* mostrar_acorde( +Acorde )
* Escribe por pantalla el Acorde de una forma mas legible que la que mostraria Prolog
* @param +Acorde acorde que se escribe por pantalla
*/
mostrar_acorde( acorde(L) ) :-
	write('Acorde:'),
	nl,
	mostrar_acorde_recursivo(L).

mostrar_acorde_recursivo([]).
mostrar_acorde_recursivo([A | Resto]) :-
	write(A),
	nl,
	mostrar_acorde_recursivo(Resto).



es_vector(V) :- es_vector3(V).
es_vector(V) :- es_vector4(V).


es_vector3(vector(A,B,C)) :- integer(A), integer(B), integer(C).
es_vector4(vector(A,B,C,D)) :- integer(A), integer(B), integer(C), integer(D).


/**
* inversion_y_disposicion(+Inv, +Disp, +Acorde1, -Acorde2 )
* este predicado representa una base de datos sobre los acordes y la forma de colocar sus
* inversiones y disposiciones de la forma mas usual y en posicion cerrada.
* @param +Inv 	es la inversion del acorde. El estado funcamental se representa con un 0. Las triadas solo
* 	tienen las inversiones 0, 1 y 2 mientras que las triadas tienen las tres.
* @param +Disp es la disposicion del acorde. Las disposiciones posibles para una triada son 1, 2 y 3 mientras que
* 	para una cuatriada son las cuatro.
* @param +Acorde1 el acorde en posicion fundamental
* @param -Acorde2 el acorde con la inversion y disposicion indicada en Inv y Disp.

*/
inversion_y_disposicion( 0, 1, acorde([A,B,C,D]), acorde([A,B,C,D,A1]) ) :-
	trasponer(A,12,A1).
inversion_y_disposicion( 0, 2, acorde([A,B,C,D]), acorde([A,C,D,A1,B1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1).
inversion_y_disposicion( 0, 3, acorde([A,B,C,D]), acorde([A,D,A1,B1,C1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).
inversion_y_disposicion( 0, 4, acorde([A,B,C,D]), acorde([A,A1,B1,C1,D1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).

inversion_y_disposicion( 1, 1, acorde([A,B,C,D]), acorde([B1,B,C,D,A1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,-12,B1).
inversion_y_disposicion( 1, 2, acorde([A,B,C,D]), acorde([B,C,D,A1,B1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1).
inversion_y_disposicion( 1, 3, acorde([A,B,C,D]), acorde([B,D,A1,B1,C1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).
inversion_y_disposicion( 1, 4, acorde([A,B,C,D]), acorde([B,A1,B1,C1,D1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).

inversion_y_disposicion( 2, 1, acorde([A,B,C,D]), acorde([C1,B,C,D,A1]) ) :-
	trasponer(A,12,A1),
	trasponer(C,-12,C1).
inversion_y_disposicion( 2, 2, acorde([A,B,C,D]), acorde([C1,C,D,A1,B1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,-12,C1).
inversion_y_disposicion( 2, 3, acorde([A,B,C,D]), acorde([C,D,A1,B1,C1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).
inversion_y_disposicion( 2, 4, acorde([A,B,C,D]), acorde([C,A1,B1,C1,D1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).

inversion_y_disposicion( 3, 1, acorde([A,B,C,D]), acorde([D1,B,C,D,A1]) ) :-
	trasponer(A,12,A1),
	trasponer(D,-12,D1).
inversion_y_disposicion( 3, 2, acorde([A,B,C,D]), acorde([D1,C,D,A1,B1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(D,-12,D1).
inversion_y_disposicion( 3, 3, acorde([A,B,C,D]), acorde([D1,D,A1,B1,C1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,-12,D1).
inversion_y_disposicion( 3, 4, acorde([A,B,C,D]), acorde([D,A1,B1,C1,D1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).


inversion_y_disposicion( 0, 1, acorde([A,B,C]), acorde([A,B,C,A1]) ) :-
	trasponer(A,12,A1).
inversion_y_disposicion( 0, 2, acorde([A,B,C]), acorde([A,C,A1,B1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1).
inversion_y_disposicion( 0, 3, acorde([A,B,C]), acorde([A,A1,B1,C1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).

inversion_y_disposicion( 1, 1, acorde([A,B,C]), acorde([B1,B,C,A1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,-12,B1).
inversion_y_disposicion( 1, 2, acorde([A,B,C]), acorde([B,C,A1,B1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1).
inversion_y_disposicion( 1, 3, acorde([A,B,C]), acorde([B,A1,B1,C1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).

inversion_y_disposicion( 2, 1, acorde([A,B,C]), acorde([C1,B,C,A1]) ) :-
	trasponer(A,12,A1),
	trasponer(C,-12,C1).
inversion_y_disposicion( 2, 2, acorde([A,B,C]), acorde([C1,C,A1,B1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,-12,C1).
inversion_y_disposicion( 2, 3, acorde([A,B,C]), acorde([C,A1,B1,C1]) ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).


% FALTAN ALGUNAS MATRICULAS
/**
* vector_suma(+-M, +-V).
* es una base de datos relacional con la matricula de un cifrado y su estructura expresada
* en forma de vector de suma de semitonos.
* @param M matricula del cifrado.
* @param V vector de tres o cuatro componentes (segun sea triada o cuatriada) que representa el vector
* 	que hay que sumar a la fundamental para dar las notas del acorde.
*/
vector_suma( matricula(mayor), vector3(0,4,7) ).
vector_suma( matricula(m), vector3(0,3,7) ).
vector_suma( matricula(au), vector3(0,4,8) ).
vector_suma( matricula(dis), vector3(0,3,6) ).
vector_suma( matricula(6), vector4(0,4,7,9) ).
vector_suma( matricula(m6), vector4(0,3,7,9) ).
vector_suma( matricula(m7b5), vector4(0,3,6,10) ).
vector_suma( matricula(maj7), vector4(0,4,7,11) ).
vector_suma( matricula(7), vector4(0,4,7,10) ).
vector_suma( matricula(m7), vector4(0,3,7,10) ).
vector_suma( matricula(mMaj7), vector4(0,3,7,11) ).
vector_suma( matricula(au7), vector4(0,4,8,10) ).
vector_suma( matricula(dis7), vector4(0,3,6,9) ).


% ESTO CREO QUE HAY QUE CAMBIARLO
/**
* gradoANumNota(+-Grado, +-NumNota).
* Base de hechos que relaciona los grados con su nota en la escala de do mayor
* @param +-Grado grado sobre el que se forma el acorde
* @param +-NumNota numero de nota que representa el grado en la escala de do mayor
*/
gradoANumNota(grado(i), numNota(3)).
gradoANumNota(grado(bii), numNota(4)).
gradoANumNota(grado(ii), numNota(5)).
gradoANumNota(grado(biii), numNota(6)).
gradoANumNota(grado(iii), numNota(7)).
gradoANumNota(grado(iv), numNota(8)).
gradoANumNota(grado(bv), numNota(9)).
gradoANumNota(grado(v), numNota(10)).
gradoANumNota(grado(auv), numNota(11)).
gradoANumNota(grado(vi), numNota(0)).
gradoANumNota(grado(bvii), numNota(1)).
gradoANumNota(grado(vii), numNota(2)).

/**
* suma_vector( +Altura, +Vector, -Acorde )
* A la altura Altura le suma los semitonos que se encuentran en Vector para procudir un acorde en estado fundamental
* y en primera disposicion
* @param +Altura altura base del acorde
* @param +Vector vector suma que representa la estructura del acorde
* @param -Acorde acorde de salida es estado fundamental y primera disposicion
*/
suma_vector( Altura, vector3(A,B,C), acorde([
		Altura1,
		Altura2,
		Altura3
		])
) :-
	trasponer(Altura, A, Altura1),
	trasponer(Altura, B, Altura2),
	trasponer(Altura, C, Altura3).

suma_vector( Altura, vector4(A,B,C,D), acorde([
		Altura1,
		Altura2,
		Altura3,
		Altura4
		])
) :-
	trasponer(Altura, A, Altura1),
	trasponer(Altura, B, Altura2),
	trasponer(Altura, C, Altura3),
	trasponer(Altura, D, Altura4).


%% ESTO DEBE IR EN OTRO FICHERO
/**
* normaliza_altura( +Altura1, -Altura2 )
* Devuelve Altura1, que es equivalente en sonido a Altura2, pero en forma normal. Entendemos por forma normal aquella
* que tiene el mismo sonido pero numNota esta comprendida entre 0 y 11
* @param +Altura1 altura para normalizar
* @param -Altura2 altura normalizada
*/
normaliza_altura( altura(numNota(N), octava(O)) , altura(numNota(N), octava(O)) ) :-
	N =< 11,
	N >= 0,
	!.
normaliza_altura( altura(numNota(N1), octava(O1)) , altura(numNota(N2), octava(O2)) ) :-
	N1 > 11,
	!,
	Aux1 is N1 - 12,
	Aux2 is O1 + 1,
	normaliza_altura( altura(numNota(Aux1), octava(Aux2)) , altura(numNota(N2), octava(O2)) ).
normaliza_altura( altura(numNota(N1), octava(O1)) , altura(numNota(N2), octava(O2)) ) :-
	N1 < 0,
	!,
	Aux1 is N1 + 12,
	Aux2 is O1 - 1,
	normaliza_altura( altura(numNota(Aux1), octava(Aux2)) , altura(numNota(N2), octava(O2)) ).


/**
* trasponer( +Altura1, +NumSemitonos, -Altura2 )
* Traspone Altura1 el numero de semintonos indicados en NumSemitonos. Entendemos por trasponer la accion de sumar a
* una altura un numero de semitonos especificados.
* @param +Altura1 altura a trasponer
* @param +NumSemitonos semitonos que se traspone Altura1
* @param -Altura2 altura traspuesta y normalizada
*/
trasponer( altura(numNota(N), octava(O)), NumSemitonos, altura(numNota(N2), octava(O2)) ) :-
	N_aux is (12 + (N - 3)) mod 12,
	N_aux2 is N_aux + NumSemitonos,
	normaliza_altura( altura(numNota(N_aux2), octava(O)) , altura(numNota(N_aux3), octava(O2)) ),
	N2 is (N_aux3 + 3) mod 12.


traduce_a_estado_fundamental( cifrado(G, M), L ) :-
	gradoANumNota(G, N),
	vector_suma(M, Vector4),
	suma_vector(altura(N, octava(3)), Vector4, L).

traduce_cifrado( Cifrado, Inv, Disp, Acorde ) :-
	traduce_a_estado_fundamental( Cifrado, L ),
	inversion_y_disposicion( Inv, Disp, L, Acorde).


/**
* eleccion_aleatoria( +NumAleatorio, +P0, +P1, +P2, -Salida )
* Elige un numero entre 0 y 3 en funcion del numero aleatorio NumAleatorio y de las probabilidades (en tanto por ciento)
* de que suceda cada numero. Entendemos que la probabilidad de que suceda P3 es 100-P0-P1-P2
* @param +NumAleatorio numero aleatorio entre 0 y 99 que determina univocamente Salida
* @param +P0 probabilidad de que suceda el valor 0
* @param +P1 probabilidad de que suceda el valor 1
* @param +P2 probabilidad de que suceda el valor 2
* @param -Salida Numero elegido, entre 0 y 3
*/
eleccion_aleatoria( NumAleatorio, P0, _, _, 0 ) :-
	NumAleatorio =< P0,
	!.
eleccion_aleatoria( NumAleatorio, P0, P1, _, 1 ) :-
	NumAleatorio > P0,
	NumAleatorio =< P1 + P0,
	!.
eleccion_aleatoria( NumAleatorio, P0, P1, P2, 2 ) :-
	NumAleatorio > P1 + P0,
	NumAleatorio =< P2 + P1 + P0,
	!.
eleccion_aleatoria( _, _, _, _, 3 ).

/**
* hazCuatriada(+G,-C)
* Dado un grado devuelve la cuatriada correspondiente a la armonizacion de la escala Jonica, en el caso de grados diatonicos
* a esa escala. En el caso de los dominantes secundarios y segundas menores realtivos asigna la matricula de 7 y m7 respectivamente
* , y en el caso de ivm6 se asigna m6. Este truco puede ser utilizado mas veces en el futuro, se pasa de entrada un termino
* que en realidad no cumple es_grado para asi expresar que queremos una matricula concreta
* @param +G cumple generador_acordes:es_grado(G) en el caso de queramos armonizar de forma estándar (usando la armonizacion de la escala jonica)
* y si no lo cumple expresa que queremos asignar una matricula no estandar a un grado implicito en G
* @param -C cifrado con la matrícula de cuatríada correspondiente al grado G, cumple generador_acordes:es_cifrado(C)
*/
hazCuatriada(grado(v7 / G), cifrado(grado(v7 / G), matricula(7))) :- !.
hazCuatriada(grado(iim7 / G), cifrado(grado(iim7 / G), matricula(m7))) :- !.
hazCuatriada(grado(ivm6), cifrado(grado(iv), matricula(m6))) :- !.
hazCuatriada(grado(G),cifrado(grado(G), matricula(maj7))) :- 	member(G,[i,iv,bvii]),!.
hazCuatriada(grado(G),cifrado(grado(G), matricula(m7))) :- member(G,[ii,iii,vi]),!.
hazCuatriada(grado(G),cifrado(grado(G), matricula(7))) :- member(G,[v]),!.
hazCuatriada(grado(G),cifrado(grado(G), matricula(m7b5))) :- member(G,[vii]),!.
