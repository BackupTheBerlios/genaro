

:- module(generador_notas_del_acorde_con_sistema_paralelo,
	[traduce_lista_cifrados/7]).

:-use_module(library(random)).
:-use_module(library(lists)).
:-use_module(biblio_genaro_acordes).


es_triada(cifrado(_,matricula(mayor))).
es_triada(cifrado(_,matricula(m))).


/**
* traduce_lista_cifrados( +Progresion, +PDisp1, +PDisp2, +PInv0, +PInv1, +PInv2, -ListaAcordes )
* Este predicado traduce una lista de cifrados a una lista de acordes, en donde ya estan representadas las
* alturas de las notas, por el metodo del sistema paralelo. El metodo consiste en colocar todos los acordes 
* en la misma disposicion, teniendo libertad de elegir la inversion.
* 	Como tambien estan contempladas las triadas la eleccion de la disposicion no puede estar en cuarta. La 
* probabilidad de que los acordes esten en primera disposicion es de PDisp1. Idem para PDisp2. La 
* probabilidad de que esten en tercera disposicion es de 100-PDisp1-PDisp2. Es por eso que la suma de 
* PDisp1 y PDisp2 no exceda nunca de 100.
* 	Lo mismo sucede para las inversiones. La probabilidad de la inversion 3 es de 100-PInv0-PInv1-PInv2.
* Como las triadas no pueden estar en tercera inversion usaremos PInv2 como 100-PInv0-PInv1 en vez del
* valor del parametro.
* 	El algoritmo es facil. Primero se elige una disposicion al azar que llevaran todos los acordes.
* Segundo se elige una inversion aleatoria para cada cifrado y con ello se genera las alturas del
* acorde segun la tabla de inversion_y_disposicion.
* @param Progresion: es una progresion de cifrados
* @param PDisp1: Probabilidad de que la lista de acordes de salida esten en primera disposicion
* @param PDisp2: Probabilidad de que la lista de acordes de salida esten en segunda disposicion
* @param PInv0: Probabilidad de que un acorde este en estado fundamental o, tambien llamado, inversion 0
* @param PInv1: Probabilidad de que un acorde este en primera inversion
* @param PInv2: Probabilidad de que un acorde este en segunda inversion
* @param ListaAcordes: Lista de acorde resultante de la traduccion a notas de la lista de cifrados Progresion
*		      Hace cierto biblio_genaro_acordes:es_lista_orden_acordes(ListaAcordes)
*/
traduce_lista_cifrados( progresion(ListaCifrados), PDisp1, PDisp2, PInv0, PInv1, PInv2, progOrdenada(ListaAcrodes) ) :-
	random( 0,100,NumAleatorio ),
	PDisp3 is 100 - PDisp1 - PDisp2,
	eleccion_aleatoria( NumAleatorio, PDisp1, PDisp2, PDisp3, Disp_aux ),  
	% Hacemos esto porque Disp_aux esta entre 0 y 3, pero las disposiciones estan entre 1 y 4
	Disposicion is Disp_aux + 1,  
	traduce_lista_cifrados_recursivo( ListaCifrados, Disposicion, PInv0, PInv1, PInv2, ListaAcrodes).



traduce_lista_cifrados_recursivo( [], _, _, _, _, [] ):-
	!.
traduce_lista_cifrados_recursivo( [(Cifrado,Figura) | RestoCifrados], Disp, PInv0, PInv1, PInv2, [(Acorde,Figura) | RestoAcrodes]):-
	es_triada(Cifrado),
	!,
	random( 0,100,NumAleatorio ),
	PInv2_aux is 100-PInv0-PInv1,
	% esto nos asegura que cuando es triada no elige la cuarta inversion
	eleccion_aleatoria( NumAleatorio, PInv0, PInv1, PInv2_aux, Inversion ),   
	traduce_cifrado( Cifrado, Inversion, Disp, Acorde ),
	traduce_lista_cifrados_recursivo( RestoCifrados, Disp, PInv0, PInv1, PInv2, RestoAcrodes ).
traduce_lista_cifrados_recursivo( [(Cifrado,Figura) | RestoCifrados], Disp, PInv0, PInv1, PInv2, [(Acorde,Figura) | RestoAcrodes]):-
	random( 1,100,NumAleatorio ),
	eleccion_aleatoria( NumAleatorio, PInv0, PInv1, PInv2, Inversion ),
	traduce_cifrado( Cifrado, Inversion, Disp, Acorde ),
	traduce_lista_cifrados_recursivo( RestoCifrados, Disp, PInv0, PInv1, PInv2, RestoAcrodes ).

