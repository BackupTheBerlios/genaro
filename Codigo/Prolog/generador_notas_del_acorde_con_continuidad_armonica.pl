
:-use_module(library(random)).
:-use_module(library(lists)).


suma_vector( altura(numNota(N), octava(Oc)), vector3(A,B,C), [
		Altura1,
		Altura2,
		Altura3
		] 
) :-
	A_aux is A + N,
	B_aux is B + N, 
	C_aux is C + N,
	normaliza_altura( altura(numNota(A_aux), octava(Oc)), Altura1 ),
	normaliza_altura( altura(numNota(B_aux), octava(Oc)), Altura2 ),
	normaliza_altura( altura(numNota(C_aux), octava(Oc)), Altura3 ).

suma_vector( altura(numNota(N), octava(Oc)), vector4(A,B,C,D), [
		Altura1,
		Altura2,
		Altura3,
		Altura4
		] 
) :-
	A_aux is A + N,
	B_aux is B + N, 
	C_aux is C + N,
	D_aux is D + N,
	normaliza_altura( altura(numNota(A_aux), octava(Oc)), Altura1 ),
	normaliza_altura( altura(numNota(B_aux), octava(Oc)), Altura2 ),
	normaliza_altura( altura(numNota(C_aux), octava(Oc)), Altura3 ),
	normaliza_altura( altura(numNota(D_aux), octava(Oc)), Altura4 ).



%% ESTO DEBE IR EN OTRO FICHERO
normaliza_altura( altura(numNota(N), octava(O)) , altura(numNota(N), octava(O)) ) :-	
	(N < 11 ; N == 11),
	(N > 0; N == 0),
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

trasponer( altura(numNota(N), octava(O)), NumSemitonos, Altura ) :-
	Aux is N+NumSemitonos,
	normaliza_altura( altura(numNota(Aux), octava(O)), Altura ).



% REVISAR CON CUIDADITO
% primer parametro: inversion (0 es estado fundamental)
% segundo parametro: disposicion
% tercer parametro: 
inversion_y_disposicion( 0, 1, [A,B,C,D], [A,B,C,D,A1] ) :-
	trasponer(A,12,A1).
inversion_y_disposicion( 0, 2, [A,B,C,D], [A,C,D,A1,B1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1).
inversion_y_disposicion( 0, 3, [A,B,C,D], [A,D,A1,B1,C1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).
inversion_y_disposicion( 0, 4, [A,B,C,D], [A,A1,B1,C1,D1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).

inversion_y_disposicion( 1, 1, [A,B,C,D], [B,B1,C1,D1,A1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).
inversion_y_disposicion( 1, 2, [A,B,C,D], [B,C,D,A1,B1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1).
inversion_y_disposicion( 1, 3, [A,B,C,D], [B,D,A1,B1,C1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).
inversion_y_disposicion( 1, 4, [A,B,C,D], [B,A1,B1,C1,D1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).

inversion_y_disposicion( 2, 1, [A,B,C,D], [C,B1,C1,D1,A1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).
inversion_y_disposicion( 2, 2, [A,B,C,D], [C1,C,D,A1,B1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,-12,C1).
inversion_y_disposicion( 2, 3, [A,B,C,D], [C,D,A1,B1,C1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).
inversion_y_disposicion( 2, 4, [A,B,C,D], [C,A1,B1,C1,D1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).

inversion_y_disposicion( 3, 1, [A,B,C,D], [D,B1,C1,D1,A2] ) :-
	trasponer(A,24,A2),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).
inversion_y_disposicion( 3, 2, [A,B,C,D], [D1,C1,D,A1,B1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,-12,C1),
	trasponer(D,-12,D1).
inversion_y_disposicion( 3, 3, [A,B,C,D], [D1,D,A1,B1,C1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,-12,D1).
inversion_y_disposicion( 3, 4, [A,B,C,D], [D,A1,B1,C1,D1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1),
	trasponer(D,12,D1).


inversion_y_disposicion( 0, 1, [A,B,C], [A,B,C,A1] ) :-
	trasponer(A,12,A1).
inversion_y_disposicion( 0, 2, [A,B,C], [A,C,A1,B1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1).
inversion_y_disposicion( 0, 3, [A,B,C], [A,A1,B1,C1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).

inversion_y_disposicion( 1, 1, [A,B,C], [B,B1,C1,A1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).
inversion_y_disposicion( 1, 2, [A,B,C], [B,C,A1,B1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1).
inversion_y_disposicion( 1, 3, [A,B,C], [B,A1,B1,C1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).

inversion_y_disposicion( 2, 1, [A,B,C], [C,B1,C1,A1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).
inversion_y_disposicion( 2, 2, [A,B,C], [C1,C,A1,B1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,-12,C1).
inversion_y_disposicion( 2, 3, [A,B,C], [C,A1,B1,C1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(C,12,C1).



%% falta el suspendido
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

%% ESTO YA LO TIENE JUAN
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



traduce_a_estado_fundamental( cifrado(G, M), L ) :-
	gradoANumNota(G, N),
	vector_suma(M, Vector4),
	suma_vector(altura(N, octava(3)), Vector4, L).

traduce( Cifrado, Inv, Disp, Acorde ) :-
	traduce_a_estado_fundamental( Cifrado, L ),
	inversion_y_disposicion( Inv, Disp, L, Acorde).
	

	
eleccion_aleatoria( NumAleatorio, P0, _, _, 0 ) :-
	NumAleatorio < P0,
	!.
eleccion_aleatoria( NumAleatorio, P0, P1, _, 1 ) :-
	(NumAleatorio > P0 ; NumAleatorio == P0),
	NumAleatorio < P1 + P0,
	!.
eleccion_aleatoria( NumAleatorio, P0, P1, P2, 2 ) :-
	(NumAleatorio > P1+P0 ; NumAleatorio == P1+P0),
	NumAleatorio < P2 + P1 + P0,
	!.
eleccion_aleatoria( _, _, _, _, 3 ).


modulo12( numNota(N1), numNota(N1) ) :-
	-1<N1,
	12>N1.
modulo12( numNota(N1), numNota(N2) ) :-
	N1<0,
	Aux is N1 + 12,
	modulo12( numNota(Aux), numNota(N2) ).
modulo12( numNota(N1), numNota(N2) ) :-
	N1>11,
	Aux is N1 - 12,
	modulo12( numNota(Aux), numNota(N2) ).
	
	

distancia_alturas( altura(numNota(N1),octava(O1)), altura(numNota(N2),octava(O2)), Dist ) :-
	N_aux1 is N1-3,
	N_aux2 is N2-3,
	modulo12(numNota(N_aux1), numNota(N_aux3)),
	modulo12(numNota(N_aux2), numNota(N_aux4)),
	Aux1 is (N_aux3 - 3) + (O1 * 12),
	Aux2 is (N_aux4 - 3) + (O2 * 12),
	Dist is abs(Aux1 - Aux2).
	



