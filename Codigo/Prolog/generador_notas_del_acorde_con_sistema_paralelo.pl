

% POSIBLEMENTE NO ES LA MEJOR FORMA DE IMPLEMENTARLO PERO ES LA MAS CLARA QUE HE ENCONTRADO YA QUE 
% COINCIDE CON LA NOTACION MUSICAL

:-use_module(library(random)).
:-use_module(library(lists)).

/*
valores_posibles_de_estructura([1,3,5,7]).
estructura_base(estructura(1,3,5,7)).

es_estructura(estructura(A,B,C,D)) :- 
	valores_posibles_de_estructura(L),
	member(A,L),
	member(B,L),
	member(C,L),
	member(D,L).

invierte_acorde( estructura(A,B,C,D) , estructura(B,C,D,A) ).

estado_fundamental( E ) :-
	estructura_base( E ).

inversion( 0, E ) :-
	estado_fundamental( E ).
inversion( 1, E ) :-
	primera_inversion( E ).
inversion( 2, E ) :-
	segunda_inversion( E ).
inversion( 3, E ) :-
	tercera_inversion( E ).

primera_inversion( E2 ) :-
	estructura_base( E1 ),
	invierte_acorde( E1, E2 ).

segunda_inversion( E3 ) :-
	estructura_base( E1 ),
	invierte_acorde( E1, E2 ),
	invierte_acorde( E2, E3 ).

tercera_inversion( E4 ) :-
	estructura_base( E1 ),
	invierte_acorde( E1, E2 ),
	invierte_acorde( E2, E3 ),
	invierte_acorde( E3, E4 ).

relacion_disposicion_con_primera_voz( 1, 1 ).
relacion_disposicion_con_primera_voz( 2, 3 ).
relacion_disposicion_con_primera_voz( 3, 5 ).
relacion_disposicion_con_primera_voz( 4, 7 ).

disposicion( Disposicion, estructura(A,B,C,Voz) , [A,B,C,Voz] ) :-
	relacion_disposicion_con_primera_voz( Disposicion, Voz ),
	!.
disposicion( Disposicion, estructura(A,B,C,D) , [A,B,C,D,Voz] ) :-
	relacion_disposicion_con_primera_voz( Disposicion, Voz ),
	!.

% N estructuras
% P0 probabilidad de estar en estado fundamental (entre 0 y 100)
% P1 probabilidad de estar en primera inversion
% P2 probabilidad de estar en segunda inversion
% 100-P0-P1-P2 probabilidad de estar en tercera inversion
% L salida
% D disposicion
% TODO: falta hacer cambio de disposicion

lista_de_estructuras( 0, _, _, _, _, [] ) :-
	!.
lista_de_estructuras( N, D, P0, P1, P2, [E2 | L2] ) :-
	elegir_inversion_aleatoria(P0, P1, P2, E1),
	disposicion( D, E1, E2 ),
	N2 is N-1,
	lista_de_estructuras( N2, D, P0, P1, P2, L2 ).
	
elegir_inversion_aleatoria(P0, P1, P2, E) :-
	random(0, 100, NumAleatorio),
	eleccion_aleatoria(NumAleatorio, P0, P1, P2, Inv),
	inversion(Inv, E).	


%% traduce el acorde a sus notas pero en la posicion fundamental
traduce_acorde_a_notas( cifrado(G,M), L ) :-
	vector_suma_triada( M, Vector3 ),
	gradoANumNota( G, N ),
	suma_vector( N, Vector3, L ).
traduce_acorde_a_notas( cifrado(G,M), L ) :-
	vector_suma_cuatriada( M, Vector4 ),
	gradoANumNota( G, N ),
	suma_vector( N, Vector4, L ).

%% ordena las notas dependiendo de la estructura de orden
ordena_segun_estructura( _, [], [] ).
ordena_segun_estructura( ListaAlturas, [A | Resto], [Nota | RestoNotas] ) :-
	dame_nota_iesima( A, ListaAlturas, Nota ),
	ordena_segun_estructura( ListaAlturas, Resto, RestoNotas ).
ordena_segun_estructura( ListaAlturas, [_ | Resto], RestoNotas ) :-
	ordena_segun_estructura( ListaAlturas, Resto, RestoNotas ).

dame_nota_iesima( Indice, Lista, Elem ) :-
	relacion_disposicion_con_primera_voz( IndiceReal, Indice ),
	nth(IndiceReal, Lista, Elem).


ejemplo :-
	traduce_acorde_a_notas(cifrado(grado(i), matricula(mayor)), L),
	ordena_segun_estructura(L, [3,5,7,1,3], L2),
	write(L2).

*/
/***************************************************************/

%% empezamos otra vez


%% falta el suspendido
vector_suma_triada( matricula(mayor), vector3(0,4,7) ).
vector_suma_triada( matricula(m), vector3(0,3,7) ).
vector_suma_triada( matricula(au), vector3(0,4,8) ).
vector_suma_triada( matricula(dis), vector3(0,3,6) ).
vector_suma_cuatriada( matricula(6), vector4(0,4,7,9) ).
vector_suma_cuatriada( matricula(m6), vector4(0,3,7,9) ).
vector_suma_cuatriada( matricula(m7b5), vector4(0,3,6,10) ).
vector_suma_cuatriada( matricula(maj7), vector4(0,4,7,11) ).
vector_suma_cuatriada( matricula(7), vector4(0,4,7,10) ).
vector_suma_cuatriada( matricula(m7), vector4(0,3,7,10) ).
vector_suma_cuatriada( matricula(mMaj7), vector4(0,3,7,11) ).
vector_suma_cuatriada( matricula(au7), vector4(0,4,8,10) ).
vector_suma_cuatriada( matricula(dis7), vector4(0,3,6,9) ).



traduce_acorde_a_notas( cifrado(G,M), L ) :-
	vector_suma_triada( M, Vector3 ),
	gradoANumNota( G, N ),
	suma_vector( N, Vector3, L ).

traduce_acorde_a_notas( cifrado(G,M), L ) :-
	vector_suma_cuatriada( M, Vector4 ),
	gradoANumNota( G, N ),
	suma_vector( N, Vector4, L ).


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
inversion_y_disposicion( 1, 3, [A,B,C,D], [B,C,A1,B1,D1] ) :-
	trasponer(A,12,A1),
	trasponer(B,12,B1),
	trasponer(D,12,D1).
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


%% falta el suspendido
vector_suma_triada( matricula(mayor), vector3(0,4,7) ).
vector_suma_triada( matricula(m), vector3(0,3,7) ).
vector_suma_triada( matricula(au), vector3(0,4,8) ).
vector_suma_triada( matricula(dis), vector3(0,3,6) ).
vector_suma_cuatriada( matricula(6), vector4(0,4,7,9) ).
vector_suma_cuatriada( matricula(m6), vector4(0,3,7,9) ).
vector_suma_cuatriada( matricula(m7b5), vector4(0,3,6,10) ).
vector_suma_cuatriada( matricula(maj7), vector4(0,4,7,11) ).
vector_suma_cuatriada( matricula(7), vector4(0,4,7,10) ).
vector_suma_cuatriada( matricula(m7), vector4(0,3,7,10) ).
vector_suma_cuatriada( matricula(mMaj7), vector4(0,3,7,11) ).
vector_suma_cuatriada( matricula(au7), vector4(0,4,8,10) ).
vector_suma_cuatriada( matricula(dis7), vector4(0,3,6,9) ).

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
	vector_suma_cuatriada(M, Vector4),
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



% inicializa los campos adecuados para su formula recursiva
traduce_lista_cifrados( [],_,_,_,_,_,_,[] ).
traduce_lista_cifrados( [ (Cifrado, F) | ListaCifrados ], 
				ProbI0, ProbI1, ProbI2, 
				ProbD1, ProbD2, ProbD3,
				[ Acorde | ListaAcordes ] 
) :-
	random(0,100,R1),
	random(0,100,R2),
	eleccion_aleatoria(R1, ProbI0, ProbI1, ProbI2, Inv),
	eleccion_aleatoria(R2, ProbD1, ProbD2, ProbD3, Disp_aux),
	Disp is Disp_aux + 1,
	traduce(Cifrado, Inv, Disp, Alturas),
	anade_alturas(Alturas, F, Acorde),
	random(0,100,R3),
	random(0,100,R4),
	traduce_lista_cifrados_recursivo(
		ListaCifrados, R3, R4, ProbI0, ProbI1, ProbI2, 
		ProbD1, ProbD2, ProbD3, Disp, ListaAcordes
	).



traduce_lista_cifrados_recursivo( [], _, _, _, _, _, _, _, _, _, [] ).
traduce_lista_cifrados_recursivo( [(Cifrado,F) | ListaCifrados], NumAleatorio1, NumAleatorio2,
				ProbI0, ProbI1, ProbI2, 
				ProbD1, ProbD2, ProbD3, DispAnterior, [ Acorde | ListaAcordes ] 
) :-
	eleccion_aleatoria(NumAleatorio1, ProbI0, ProbI1, ProbI2, Inv),
	eleccion_aleatoria(NumAleatorio2, ProbD1, ProbD2, ProbD3, Disp_aux),
	Disp is Disp_aux + 1,
	Disp == DispAnterior,
	traduce(Cifrado, Inv, Disp, Alturas),
	random(0,100,R1),
	random(0,100,R2),
	anade_figura(Alturas, F, Acorde),
	traduce_lista_cifrados_recursivo(
		ListaCifrados, R1, R2, ProbI0, ProbI1, ProbI2, 
		ProbD1, ProbD2, ProbD3, Disp, ListaAcordes
	).

%%caso en que hay un cambio de disposicion
traduce_lista_cifrados_recursivo( [(Cifrado,F) | ListaCifrados], NumAleatorio1, NumAleatorio2,
				ProbI0, ProbI1, ProbI2, 
				ProbD1, ProbD2, ProbD3, DispAnterior, [ cambio(Acorde1, Acorde2) | ListaAcordes ] 
) :-
	eleccion_aleatoria(NumAleatorio1, ProbI0, ProbI1, ProbI2, Inv),
	eleccion_aleatoria(NumAleatorio2, ProbD1, ProbD2, ProbD3, Disp_aux),
	Disp is Disp_aux + 1,
	Disp \== DispAnterior,
	traduce(Cifrado, Inv, DispAnterior, Alturas1),
	traduce(Cifrado, Inv, Disp, Alturas2),
	random(0,100,R1),
	random(0,100,R2),
	% ATENCION: FALTA DIVIDIR F ENTRE DOS
	anade_figura(Alturas1, F, Acorde1),
	anade_figura(Alturas2, F, Acorde2),
	traduce_lista_cifrados_recursivo(
		ListaCifrados, R1, R2, ProbI0, ProbI1, ProbI2, 
		ProbD1, ProbD2, ProbD3, Disp, ListaAcordes
	).
	


anade_figura( [], _, [] ).
anade_figura( [ A | RestoAlturas ], F, [nota(A,F) | RestoNotas] ) :-
	anade_figura( RestoAlturas, F, RestoNotas ).





