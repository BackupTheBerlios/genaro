
% TODO: RELLENAR ESTO
% TODO: PONER BIEN LOS COMENTARIOS

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
	mostrar_acorde/1
]).


:- use_module(representacion_prolog_haskore).
:- use_module(library(random)).
:- use_module(library(lists)).


es_acorde( acorde(Lista) ) :-
	es_acorde_recursivo(Lista).

es_acorde_recursivo([]).
es_acorde_recursivo([Altura | RestoAlturas]) :-
	es_altura(Altura),
	es_acorde_recursivo(RestoAlturas).

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


/*
USO: inversion_y_disposicion(+Inv, +Disp, +Acorde1, -Acorde2 )
PARAMETROS:
	Inv: 	es la inversion del acorde. El estado funcamental se representa con un 0. Las triadas solo 
		tienen las inversiones 0, 1 y 2 mientras que las triadas tienen las tres.
	Disp: es la disposicion del acorde. Las disposiciones posibles para una triada son 1, 2 y 3 mientras que
		para una cuatriada son las cuatro.
	Acorde1: el acorde en posicion fundamental
	Acorde2: el acorde con la inversion y disposicion indicada en Inv y Disp.
DESCRIPCION: este predicado representa una base de datos sobre los acordes y la forma de colocar sus
	inversiones y disposiciones de la forma mas usual y en posicion cerrada.
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
inversion_y_disposicion( 3, 2, acorde([A,B,C,D]), acorde([D1,C,D,A1,B1]) ) :- %%%%%%%%%%%%%%%%
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
	trasponer(B,-12,B1),
	trasponer(C,12,C1).
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
/*
USO: vector_suma(+-M, +-V).
PARAMETROS:
	M: 	matricula del cifrado.
	V: 	vector de tres o cuatro componentes (segun sea triada o cuatriada) que representa el vector
		que hay que sumar a la fundamental para dar las notas del acorde.
DESCRIPCION: es una base de datos relacional con la matricula de un cifrado y su estructura expresada
	en forma de vector de suma de semitonos.
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


% no se muy bien donde poner esto
/*
USO: gradoANumNota(+-Grado, +-NumNota).
PARAMETROS:
	Grado: grado sobre el que se forma el acorde
	NumNota: numero de nota que representa el grado en la escala de do mayor
DESCRIPCION:
	Base de hechos que relaciona los grados con su nota en la escala de do mayor
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

/*
	
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
	

	
eleccion_aleatoria( NumAleatorio, P0, _, _, 0 ) :-
	NumAleatorio < P0,
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





