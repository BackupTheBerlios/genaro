

:-module(generador_notas_del_acorde_con_continuidad_armonica,[traduce_lista_cifrados/2]).


%%:-use_module(library(random)).
%%:-use_module(library(lists)).
:- ensure_loaded(library(lists)).
:- use_module(compat_Sicstus_SWI).
:-use_module(biblio_genaro_acordes).


/**
* modulo12( +Nota, -NotaSalida)
* Calcula el modulo 12 de Nota representandola como un valor de 0 a 11 (0 es el La)
* @param +Nota nota a calcula el modulo 12
* @param -NotaSalida nota entre 0 y 11
*/
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


/**
* distancia_alturas( +Altura1, +Altura2, -Distancia )
* Calcula la distancia en semitonos de la Altura1 a la Altura2.
* @param +Altura1 altura1
* @param +Altura2 altura2
* @param -Distancia numero entero mayor o igual a cero que representa la distancia entre altura1 y altura2
*/
distancia_alturas( altura(numNota(N1),octava(O1)), altura(numNota(N2),octava(O2)), Dist ) :-
	N_aux1 is N1-3,
	N_aux2 is N2-3,
	modulo12(numNota(N_aux1), numNota(N_aux3)),
	modulo12(numNota(N_aux2), numNota(N_aux4)),
	Aux1 is N_aux3 + (O1 * 12),
	Aux2 is N_aux4 + (O2 * 12),
	Dist is abs(Aux1 - Aux2).

/**
* distancia_acorde( +Acorde1, +Acorde2, -Distancia)
* Calcula la distancia entre el Acorde1 y el Acorde2. Entendemos por distancia la suma de las distancias en
* semitonos de cada voz del acorde a la del siguiente acorde. Solo consideramos las cuatro primeras voces
* para hacerlo compatible con triadas y cuatriadas
* @param +Acorde1 acorde1
* @param +Acorde2 acorde2
* @param -Distancia numero entero mayor o igual a 0 que determina la distancia de Acorde1 con Acorde2
*/
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

/**
* menor_acorde( +Acorde_referencia, +Acorde1, +Acorde2, -AcordeMenor )
* Compara la distancia de Acorde1 y Acorde2 con el Acorde_referencia y devuelve en AcordeMenor el que tuviera
* la menor distancia
* @param +Acorde_referencia acorde con el que comparamos las distancias
* @param +Acorde1 acorde1
* @param +Acorde2 acorde2
* @param -AcordeMenor acorde1 si tiene menor distancia que acorde2 o viceversa
*/
menor_acorde(Acorde_referencia, Acorde1, Acorde2, Acorde2 ) :-
	distancia_acorde( Acorde_referencia, Acorde1, Dist1 ),
	distancia_acorde( Acorde_referencia, Acorde2, Dist2 ),
	Dist1 >= Dist2,
	!.
menor_acorde( _, Acorde1, _, Acorde1 ).



/**
* menor_lista_acordes( +Acorde_referencia, +ListaAcordes, -AcordeMenor )
* Devuelve el acorde de la ListaAcordes que tiene una distancia menor con el Acorde_referencia
* @param +Acorde_referencia acorde con el cual comparamos la distancia
* @param +ListaAcordes lista de acordes en la que buscamos el menor acorde
* @param -AcordeMenor un acorde que tiene una distancia menor con Acorde_referencia
*/
menor_lista_acordes( _, [Acorde], Acorde ) :-
	!.
menor_lista_acordes( Acorde_referencia, [Acorde | Resto], Acorde_salida) :-
	menor_lista_acordes( Acorde_referencia, Resto, Acorde_menor ),
	menor_acorde(Acorde_referencia, Acorde_menor, Acorde, Acorde_salida ).



/**
* elimina_diferentes( +Acorde_referencia, +Distancia_menor, +ListaEntrada, -ListaAcordes )
* elimina de la ListaEntrada aquellos acordes cuya distancia con Acorde_referencia sea mayor que
* Distancia_menor, dejando solamente los que tienen una distancia igual.
* @param +Acorde_referencia acorde con el cual se compara la distancia
* @param +Distancia_menor distancia menor de los acordes de ListaEntrada
* @param +ListaEntrada lista de acordes de entrada
* @param -ListaAcordes lista con los acordes que tienen la distancia con Acorde_referencia igual a Distancia_menor
*/
elimina_diferentes( _, _, [], [] ) :-
	!.
elimina_diferentes( Acorde_referencia, Distancia_menor, [Acorde | Resto], [Acorde | Salida] ) :-
	distancia_acorde( Acorde_referencia, Acorde, Distancia_menor ),	% Si es igual le dejamos
	elimina_diferentes( Acorde_referencia, Distancia_menor, Resto, Salida  ).
elimina_diferentes( Acorde_referencia, Distancia_menor, [_ | Resto], Salida ) :-
	elimina_diferentes( Acorde_referencia, Distancia_menor, Resto, Salida  ).

/**
* elegir_aleatoriamente( +Lista, -Elemento )
* Elige un elemento de la lista Lista aleatoriamente
* @param Lista lista de la cual se elige un elemento aleatoriamente
* @param Elemento elemento de la lista elegido aleatoriamente
*/
elegir_aleatoriamente( L, A ) :-
	length( L, N1 ),
	random(0, N1, N2),
	nth0(N2, L, A).

/**
* traduce_lista_cifrados(+Progresion,-ListaAcrodes )
* Este predicado traduce una lista de cifrados a una lista de acordes, en donde ya estan representadas las
* alturas de las notas, por el metodo de continuidad armonica. Dicho metodo consisten en buscar la inversion y
* la disposicion de cada acorde que haga que el movimiento de cada voz entre acordes sea el menor.
* 	El algoritmo consiste en lo siguiente. Primero elegimos una inversion y una disposicion aleatoriamente
* que nos servira de referencia para el siguiente acorde. Para cada cifrado de la progresion hacemos lo siguiente:
* calculamos todos los acordes con todas las disposiciones y buscamos los acorden que tengan una distancia
* menor al anterior acorde. De todas ellas elegimos una aleatoriamente.
* @param	Progresion es una progresion de cifrados
* @param	ListaAcrodes lista de acorde resultante de la traduccion a notas de la lista de cifrados Progresion
*/
traduce_lista_cifrados( progresion([(Cifrado, Figura) | Resto]), progOrdenada([ (Acorde_ref,Figura) | Salida]) ) :-
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





