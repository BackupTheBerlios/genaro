

:-module(generador_notas_del_acorde_con_continuidad_armonica,[traduce_lista_cifrados/2]).


:-use_module(library(random)).
:-use_module(library(lists)).
:-use_module(biblio_genaro_acordes).


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
	Aux1 is N_aux3 + (O1 * 12),
	Aux2 is N_aux4 + (O2 * 12),
	Dist is abs(Aux1 - Aux2).
	

distancia_acorde(acorde(Acorde1), acorde(Acorde2), Distancia) :-
	reverse(Acorde1, Acorde1_aux),
	reverse(Acorde2, Acorde2_aux),
	distancia_acorde_recursivo(Acorde1_aux, Acorde2_aux, Distancia, 4).   % no se si poner 3 o 4

distancia_acorde_recursivo(_, _, 0, 0) :-
	!.
distancia_acorde_recursivo( [Altura1 | RestoAlturas1 ] , [Altura2 | RestoAlturas2] , Dist, N) :-
	distancia_alturas(Altura1, Altura2, Dist1),
	N1 is N - 1,
	distancia_acorde_recursivo( RestoAlturas1, RestoAlturas2, Dist2, N1 ),
	Dist is Dist1 + Dist2.


menor_acorde(Acorde_referencia, Acorde1, Acorde2, Acorde2 ) :-
	distancia_acorde( Acorde_referencia, Acorde1, Dist1 ),
	distancia_acorde( Acorde_referencia, Acorde2, Dist2 ),
	Dist1 >= Dist2,
	!.
menor_acorde( _, Acorde1, _, Acorde1 ).


menor_lista_acordes( _, [Acorde], Acorde ) :-
	!.
menor_lista_acordes( Acorde_referencia, [Acorde | Resto], Acorde_salida) :-
	menor_lista_acordes( Acorde_referencia, Resto, Acorde_menor ),
	menor_acorde(Acorde_referencia, Acorde_menor, Acorde, Acorde_salida ).
	

elimina_diferentes( _, _, [], [] ) :-
	!.
elimina_diferentes( Acorde_referencia, Distancia_menor, [Acorde | Resto], [Acorde | Salida] ) :-
	distancia_acorde( Acorde_referencia, Acorde, Distancia_menor ),	% Si es igual le dejamos
	elimina_diferentes( Acorde_referencia, Distancia_menor, Resto, Salida  ).
elimina_diferentes( Acorde_referencia, Distancia_menor, [_ | Resto], Salida ) :-
	elimina_diferentes( Acorde_referencia, Distancia_menor, Resto, Salida  ).


elegir_aleatoriamente( L, A ) :-
	length( L, N1 ),
	random(0, N1, N2),
	nth0(N2, L, A).

/*
USO:
	traduce_lista_cifrados(+Progresion,-ListaAcrodes )
PARAMETROS:
	Progresion: es una progresion de cifrados
	ListaAcrodes: lista de acorde resultante de la traduccion a notas de la lista de cifrados Progresion
DESCRIPCION:
	Este predicado traduce una lista de cifrados a una lista de acordes, en donde ya estan representadas las
	alturas de las notas, por el metodo de continuidad armonica. Dicho metodo consisten en buscar la inversion y 
	la disposicion de cada acorde que haga que el movimiento de cada voz entre acordes sea el menor.
		El algoritmo consiste en lo siguiente. Primero elegimos una inversion y una disposicion aleatoriamente
	que nos servira de referencia para el siguiente acorde. Para cada cifrado de la progresion hacemos lo siguiente:
	calculamos todos los acordes con todas las disposiciones y buscamos los acorden que tengan una distancia
	menor al anterior acorde. De todas ellas elegimos una aleatoriamente.
*/
traduce_lista_cifrados( progresion([(Cifrado, Figura) | Resto]), [ (Acorde_ref,Figura) | Salida] ) :-
	findall(A , traduce_cifrado(Cifrado, _, _, A), Lista),
	elegir_aleatoriamente( Lista, Acorde_ref ),
	traduce_lista_cifrados_recursiva( Resto, Acorde_ref, Salida ).

traduce_lista_cifrados_recursiva( [], _, [] ) :-
	!.
traduce_lista_cifrados_recursiva( [(Cifrado, Figura) | Resto], Acorde_ref, [ (Acorde_ref2, Figura) | Salida] ) :-
	findall(A , traduce_cifrado(Cifrado, _, _, A), Lista),
	menor_lista_acordes( Acorde_ref, Lista, Acorde_menor ),
	distancia_acorde( Acorde_ref, Acorde_menor, Distancia ),
	elimina_diferentes( Acorde_ref, Distancia, Lista, Lista2 ),
	elegir_aleatoriamente( Lista2, Acorde_ref2 ),
	traduce_lista_cifrados_recursiva( Resto, Acorde_ref2, Salida ).





