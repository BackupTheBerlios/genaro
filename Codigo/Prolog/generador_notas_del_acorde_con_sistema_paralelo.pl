

% POSIBLEMENTE NO ES LA MEJOR FORMA DE IMPLEMENTARLO PERO ES LA MAS CLARA QUE HE ENCONTRADO YA QUE 
% COINCIDE CON LA NOTACION MUSICAL

:-use_module(library(random)).
:-use_module(library(lists)).
:-use_module(biblio_genaro_acordes).

% TODO: MIRAR LO DEL RANDOM(0,100,N)


es_triada(cifrado(_,matricula(mayor))).
es_triada(cifrado(_,matricula(m))).


traduce_lista_cifrados( progresion(ListaCifrados), PDisp1, PDisp2, PInv0, PInv1, PInv2, ListaAcrodes ) :-
	random( 1,100,NumAleatorio ),
	PDisp3 is 100 - PDisp1 - PDisp2,
	eleccion_aleatoria( NumAleatorio, PDisp1, PDisp2, PDisp3, Disp_aux ),    % de esta forma nunca da la disposicion 4
	Disposicion is Disp_aux + 1,
	traduce_lista_cifrados_recursivo( ListaCifrados, Disposicion, PInv0, PInv1, PInv2, ListaAcrodes).



traduce_lista_cifrados_recursivo( [], _, _, _, _, [] ):-
	!.
traduce_lista_cifrados_recursivo( [(Cifrado,Figura) | RestoCifrados], Disp, PInv0, PInv1, PInv2, [(Acorde,Figura) | RestoAcrodes]):-
	es_triada(Cifrado),
	!,
	random( 1,101,NumAleatorio ),
	PInv2_aux is 100-PInv0-PInv1,
	eleccion_aleatoria( NumAleatorio, PInv0, PInv1, PInv2_aux, Inversion ),    % esto nos asegura que cuando es triada no elige la cuarta inversion
	write('Es triada '),write(Inversion),nl,
	traduce_cifrado( Cifrado, Inversion, Disp, Acorde ),
	mostrar_acorde(Acorde),
	traduce_lista_cifrados_recursivo( RestoCifrados, Disp, PInv0, PInv1, PInv2, RestoAcrodes ).
traduce_lista_cifrados_recursivo( [(Cifrado,Figura) | RestoCifrados], Disp, PInv0, PInv1, PInv2, [(Acorde,Figura) | RestoAcrodes]):-
	random( 1,100,NumAleatorio ),
	eleccion_aleatoria( NumAleatorio, PInv0, PInv1, PInv2, Inversion ),
	write('No es triada '),write(Inversion),nl,
	traduce_cifrado( Cifrado, Inversion, Disp, Acorde ),
	mostrar_acorde(Acorde),
	traduce_lista_cifrados_recursivo( RestoCifrados, Disp, PInv0, PInv1, PInv2, RestoAcrodes ).

	





% solo para el ejemplo

:- consult(['generador_acordes.pl']).
ejemplo1 :- 
	haz_progresion(10, 10, P),
	nl,
	traduce_lista_cifrados(P, 33,33, 25,25,25, L).

ejemplo2 :- 
	traduce_lista_cifrados(
	progresion([
		(cifrado(grado(i), matricula(mayor)), figura(1,1)),
		(cifrado(grado(ii), matricula(mayor)), figura(1,1)),
		(cifrado(grado(ii), matricula(7)), figura(1,1))
	]), 30,20, 0,10,10, L
	),
	write(L).


