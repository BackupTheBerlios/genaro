%DESCRIPCION
/*
GENERADOR DE SECUENCIAS DE ACORDES A REDONDAS EN ESCALA DE DO JONICO

-en compas de 2 por 4 y posición de tónica en primera disposicion
-pag 61: añadir, cambiar y quitar acordes
-pag 64: colocacion de los acordes en la frase armónica
-poner lo del movimineto entre fundamentales pg 66
-pg 81 : bVII
-todo de cadenas
*/

%DECLARACION DEL MODULO
:- module(generador_acordes_binario).

%BIBLIOTECAS

%ARCHIVOS PROPIOS CONSULTADOS
:- use_module(generador_acordes).
:- use_module(generador_acordes_semillas).
:- use_module(biblio_genaro_fracciones).
:- use_module(biblio_genaro_listas).
:- use_module(figuras_y_ritmo).
:- use_module(biblio_genaro_ES).
:- use_module(generador_notas_del_acorde_con_sistema_paralelo).
:- use_module(generador_notas_del_acorde_con_continuidad_armonica).

%PREDICADOS
genera_acordes :- genera_acordes(6,3, continuidad,1).
/**
* genera_acordes(+N, +M, +EnlaceVoces, +TipoSemilla)
* Construye una progresion que dura exactamente N compases y en la que se han aplicado M
* transformaciones durante su generacion. Esta progresion y otros terminos intermedios se
* escriben en los siguientes ficheros de texto:
* - En un fichero de texto cuya ruta es especificada en generador_acordes:fichero_destinoGenAc_prog_ord/1
* se escribe un termino que cumple biblio_genaro_acordes:es_progresion_ordenada/1 y que es el
* resultado final de la generacion
* - En un fichero de texto cuya ruta es especificada en generador_acordes:fichero_destinoGenAc_prog/1
* se escribe un termino que cumple biblio_genaro_acordes:es_progresion/1 y que es el resultado final de la generacion
* @param +N natural que indica el numero de compases que durará la progresion
* @param +M natural que indica el numero de transformaciones que se aplicarán a la progresion
* @param +EnlaceVoces pertenece al conjunto {paralelo, continuidad} e indica cual de los dos sistemas se empleará
* para enlazar las voces para generar el termino que cumple es_progresion_ordenada que luego se escribirá en el
* fichero
* @param +TipoSemilla indica cual de los predicados disponibles se utilizará para la generación de la semilla desde la que
* se parte para hacer la generacion de acordes
*
* FALTA ELEGIR LA DISPISICION SI CORRESPONDE
* */
genera_acordes(N,M, paralelo, TipoSemilla) :- haz_progresion(N, M, TipoSemilla, Prog)
        ,generador_notas_del_acorde_con_sistema_paralelo:traduce_lista_cifrados(Prog,100,0,100,0,0,Lista)
        ,fichero_destinoGenAc_prog_ord(Dd), escribeTermino(Dd, Lista).

genera_acordes(N,M, continuidad, TipoSemilla) :- haz_progresion(N, M, TipoSemilla, Prog)
        ,generador_notas_del_acorde_con_continuidad_armonica:traduce_lista_cifrados(Prog,Lista)
        ,fichero_destinoGenAc_prog_ord(Dd), escribeTermino(Dd, Lista).


	%PREDICADOS DE GENERACION

/**haz_progresion(+N, +M, +Tipo, -La)
* @param +N natural que indica el numero aproximado de compases que dura de la progresión. Me temo que tendrá que ser mayor o igual
*    que 3 (longitud de la cadencia más larga)
* @param +M natural que indica el numero de mutaciones que se realizaran para conseguir la progresion
* @param +Tipo indica si se utilizará haz_prog_semilla 1 o 2
* @param -La lista de acordes que ocupan N compases que se espera q se interpreten uno tras otro empezando por la cabeza.
*     Hace cierto es_progresion(La)
*/
/*haz_progresion(N, M, Tipo, progresion(La)) :- natural(N), natural(M), haz_prog_semilla(Tipo, progresion(S))
                ,escribeLista(S, 'C:/hlocal/cifradosSemilla.txt')
		,fija_compases_aprox(progresion(S), N, Laux1), modifica_prog(Laux1, M, Laux2)
                ,asegura_ritmo_armonico(Laux2, progresion(Laux3))
                ,escribeLista(Laux3, 'C:/hlocal/cifradospreFin.txt')
                ,haz_prog_semilla(1,progresion(Pfin)), append(Laux3, Pfin, Laux4)
                ,quita_grados_relativos(progresion(Laux4), progresion(La))
                ,escribeLista(La, 'C:/hlocal/cifrados.txt').*/
haz_progresion(N, M, Tipo, progresion(La)) :- natural(N), natural(M), haz_prog_semilla(Tipo, progresion(S))
                ,escribeLista(S, 'C:/hlocal/cifradosSemilla.txt')
		,fija_compases_aprox(progresion(S), N, Laux1), modifica_prog(Laux1, M, progresion(Laux2))
                ,escribeLista(Laux2, 'C:/hlocal/cifradospreFin.txt')
                ,haz_prog_semilla(1,progresion(Pfin)), append(Laux2, Pfin, Laux4)
                ,quita_grados_relativos(progresion(Laux4), progresion(La))
                ,escribeLista(La, 'C:/hlocal/cifrados.txt')
                ,fichero_destinoGenAc_prog(FDC)
                ,escribeTermino(FDC,progresion(La)).


/*haz_progresion(N, M, Tipo, progresion(La)) :- natural(N), natural(M), haz_prog_semilla(Tipo, S), fija_compases_aprox(S, N, Laux1)
 		,modifica_prog(Laux1, M, Laux2), asegura_ritmo_armonico(Laux2, progresion(Laux3))
                ,escribeLista(Laux3, 'C:/hlocal/cifrados.txt')
                ,quita_grados_relativos(progresion(Laux3), progresion(Laux4))
                ,haz_prog_semilla(1,progresion(Pfin)), append(Laux4, Pfin, La).*/


		%PREDICADOS QUE AÑADEN MAS COMPASES A LA PROGRESION
/*fija_compases_aprox(ProgSemilla, N, ProgResul). Partiendo de la progresion ProgSemilla construye otra
progresion de longitud N (N compases) APROXIMADAMENTE
in: ProgSemilla progresión de partida (semilla). Cumple es_progresion(ProgSemilla)
    N numero de compases que tendra la progresion como minimo. Es un natural mayor o igual que el numero de
    acordes de ProgSemilla
out: ProgResul resultado de las transformaciones, Cumple es_progresion(ProgResul)
*/
fija_compases_aprox(ProgSemilla, N, ProgSemilla) :- numCompases(ProgSemilla, NumComp), NumComp >= N,!.
fija_compases_aprox(ProgSemilla, N, ProgResul) :- alarga_progresion(ProgSemilla, ProgAux)
		,fija_compases_aprox(ProgAux, N, ProgResul).

/**
* alarga_progresion(Po, Pd) devuelve en Pd una progresion igual a Po salvo por que se le ha añadido un acorde
* extra que la hace más larga, elegiendo este acorde según las reglas de la armonía
* @param +Po cumple es_progresion(Po)
* @param -Pd cumple es_progresion(Pd)
* */
alarga_progresion(Po, Pd) :- num_acciones_alarga(N), random(0, N, E), alarga_progresion(Po, E, Pd).
alarga_progresion(Po, 0, Pd) :- aniade_dominante_sec(Po, Pd).
alarga_progresion(Po, 1, Pd) :- aniade_iim7_rel(Po, Pd).
num_acciones_alarga(2).
%alarga_progresion(Po, 3, Pd) :- aniade_acordes2(Po, Pd). un poco aburrido
%num_acciones_alarga(3).

			%DOMINANTES SECUNDARIOS
/**
* aniade_dominante_sec(Po,Pd): Pd es una progresion igual a Po pero en la que se ha añadido un dominante
* secundario de un acorde elegido al azar, dando la misma probabilidad de ser elegidos a todos los acordes
* El dominante secundario se añadirá sin asegurarse de respetar las reglas de ritmo armónico y durará lo mismo
* q el acorde sobre el que ejerce de dominante secundario
* @param +Po cumple es_progresion(Po)
* @param -Po cumple es_progresion(Pd)
*/
aniade_dominante_sec(progresion(Lo), progresion(Ld)) :- aniade_dom_sec_lista(Lo, Ld).
aniade_dom_sec_lista([], []) :- !.
aniade_dom_sec_lista(Lo, Ld):-
        buscaCandidatosADominanteSec(Lo, Lc)
	,length(Lc,Long), Long >0 ,!
	,dame_elemento_aleatorio(Lc, (cifrado(grado(G),matricula(M)), F, PosElegida), _)
	,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
    ,sublista_suf(Lo, PosElegMas, LdB)
    ,append(LdA, [(cifrado(grado(v7 / G),matricula(7)), F),(cifrado(grado(G),matricula(M)), F)], Laux)
    ,append(Laux, LdB, Ld).

aniade_dom_sec_lista(Lo, Lo).

/**
* buscaCandidatosADominanteSec(Li, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los acordes a los que se
* les puede añadir un dominante secundario por delante de ellos, esto es, aquellos que no son acordes del primer grado y a los que
* no se les ha añadido ya un dominante secundario
* @param +Li cumple es_progresion(progresion(Li))
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
buscaCandidatosADominanteSec([(cifrado(grado(i), M), F)|Li], Lo)
	:- !,buscaCandidatosADominanteSecAcu([(cifrado(grado(i), M), F)|Li], 2, Lo).
buscaCandidatosADominanteSec([(cifrado(grado(G),M), F)|Li], [(cifrado(grado(G),M), F, 1)|Lo])
	:- buscaCandidatosADominanteSecAcu([(cifrado(grado(G),M), F)|Li], 2, Lo).
/**
* % buscaCandidatosADominanteSecAcu(Li, PosActual, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los acordes a los que se
* les puede añadir un dominante secundario por delante de ellos, esto es, aquellos que no son acordes del primer grado y a los que
* no se les ha añadido ya un dominante secundario. !no implementado!: tampoco se debería poder añadir un dominante por extension entre un
* dominante secundario y su iim7 relativo correspondiente!!!!o si???? Al final lo dejo pq tiene su gracia
* PosActual indica la posicion del acorde que se considera, dentro de la lista
* total sobre la que se ha llamado a buscaCandidatosADominanteSec, que a su vez habrá llamado a este predicado
* @param +Li cumple es_progresion(progresion(Li))
* @param +PosActual es un natural
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
buscaCandidatosADominanteSecAcu([], _, []).
buscaCandidatosADominanteSecAcu([_],_,[]).%pq _ ya se habría examinado
%hay q darse cuenta de q el primer acorde de la progresion nunca será candidato entonces, por eso empieza en dos
buscaCandidatosADominanteSecAcu([(cifrado(grado(v7 / G2),matricula(_)), _),(cifrado(grado(G2),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(G2),matricula(M2)), F2)|Li], PosSig, Lo).
buscaCandidatosADominanteSecAcu([_,(cifrado(grado(i),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(i),matricula(M2)), F2)|Li], PosSig, Lo).
buscaCandidatosADominanteSecAcu([_,(cifrado(grado(G2),matricula(M2)), F2)|Li]
    , PosActual, [(cifrado(grado(G2),matricula(M2)), F2, PosActual)|Lo]) :-
                       PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(G2),matricula(M2)), F2)|Li], PosSig, Lo).


			%II-7 RELATIVO
/**
* aniade_iim7_rel(Po,Pd): Pd es una progresion igual a Po pero en la que se ha añadido un ii-7 de un
* dominante elegido al azar, dando la misma probabilidad de ser elegidos a todos los acordes
* El ii-7 se añadirá sin asegurarse de respetar las reglas de ritmo armónico y durará lo mismo
* q el dominante sobre el q se coloca. Falta lo mismo q con dominantes para no repetir!!!!!
* @param +Po cumple es_progresion(Po)
* @param -Po cumple es_progresion(Pd)
*/
aniade_iim7_rel(progresion(Lo), progresion(Ld)) :- aniade_iim7_rel_lista(Lo, Ld).
aniade_iim7_rel_lista([],[]) :- !.
aniade_iim7_rel_lista(Lo, Ld) :-
	 buscaCandidatosAiimRel(Lo, Lc)
	,length(Lc,Long), Long >0 ,!
   	,dame_elemento_aleatorio(Lc, (cifrado(grado(G),matricula(M)), F, PosElegida), _)
   	,monta_iim(grado(G),Seg)
	,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
    ,sublista_suf(Lo, PosElegMas, LdB)
    ,append(LdA, [(cifrado(Seg,matricula(m7)), F),(cifrado(grado(G),matricula(M)), F)], Laux)
    ,append(Laux, LdB, Ld).

aniade_iim7_rel_lista(Lo, Lo).

monta_iim(grado(v),grado(ii)).
monta_iim(grado(v7 / G),grado(iim7 / G)).

buscaCandidatosAiimRel([(cifrado(grado(v),M), F)|Li], [(cifrado(grado(v),M), F, 1)|Lo])
	:- !,buscaCandidatosAiimRelAcu([(cifrado(grado(v),M), F)|Li], 2, Lo).
buscaCandidatosAiimRel([(cifrado(grado(v7 / G),M), F)|Li], [(cifrado(grado(v7 / G),M), F, 1)|Lo])
	:- !,buscaCandidatosAiimRelAcu([(cifrado(grado(v7 / G),M), F)|Li], 2, Lo).
buscaCandidatosAiimRel([(cifrado(grado(G), M), F)|Li], Lo)
	:- buscaCandidatosAiimRelAcu([(cifrado(grado(G), M), F)|Li], 2, Lo).

buscaCandidatosAiimRelAcu([], _, []).
buscaCandidatosAiimRelAcu([_],_,[]).%pq _ ya se habría examinado
%hay q darse cuenta de q el primer acorde de la progresion nunca será candidato entonces, por eso empieza en dos
buscaCandidatosAiimRelAcu([(cifrado(grado(iim7 / G2),matricula(_)), _),(cifrado(grado(v7 / G2),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosAiimRelAcu([(cifrado(grado(v7 / G2),matricula(M2)), F2)|Li], PosSig, Lo).

buscaCandidatosAiimRelAcu([(cifrado(grado(ii),matricula(_)), _),(cifrado(grado(v),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosAiimRelAcu([(cifrado(grado(v),matricula(M2)), F2)|Li], PosSig, Lo).

buscaCandidatosAiimRelAcu([_,(cifrado(grado(v),matricula(M2)), F2)|Li]
    , PosActual, [(cifrado(grado(v),matricula(M2)), F2, PosActual)|Lo]) :-
                       !, PosSig is PosActual + 1
                       ,buscaCandidatosAiimRelAcu([(cifrado(grado(v),matricula(M2)), F2)|Li], PosSig, Lo).

buscaCandidatosAiimRelAcu([_,(cifrado(grado(v7 / G2),matricula(M2)), F2)|Li]
    , PosActual, [(cifrado(grado(v7 / G2),matricula(M2)), F2, PosActual)|Lo]) :-
                       !, PosSig is PosActual + 1
                       ,buscaCandidatosAiimRelAcu([(cifrado(grado(v7 / G2),matricula(M2)), F2)|Li], PosSig, Lo).

buscaCandidatosAiimRelAcu([_,(cifrado(grado(G2),matricula(M2)), F2)|Li]
    , PosActual, Lo) :-
                       PosSig is PosActual + 1
                       ,buscaCandidatosAiimRelAcu([(cifrado(grado(G2),matricula(M2)), F2)|Li], PosSig, Lo).

			%RITMO ARMONICO
/**
* asegura_ritmo_armonico(Po, Pd) dada la progresion Po devuelve en Pd el resultado de modificar Po para que
* se respeten las normas de ritmo armónico, es decir, que los acordes más inestables estén en compases más débiles
* que los acordes más estables
* @param +Po cumple es_progresion(Po)
* @param -Pd cumple es_progresion(Pd)
* */
asegura_ritmo_armonico(progresion(Lo), progresion(Ld))
	:- aseg_ritmo_arm_acu(Lo,(0,1),Ld).

aseg_ritmo_arm_acu([],_,[]).
aseg_ritmo_arm_acu([X],_,[X]).
aseg_ritmo_arm_acu([X,Y],_,[X,Y]).

aseg_ritmo_arm_acu([(C1,figura(N1,D1)),(C2,figura(N2,D2)),(C3,F3)|Lcin], (NumCompPre2Nom, NumCompPre2Den)
	, [(C1,figura(N1,D1)),(C1,figura(N1,D1)),(C2,figura(N2,D2))|Lcout]) :-
		dameFuncionTonalCifrado(C2, FuncTonal2)
		,dameFuncionTonalCifrado(C3, FuncTonal3)
		,menosEstable(FuncTonal2, FuncTonal3)
    	,fuerzaEnElCompas(NumCompPre2Nom,NumCompPre2Den,binario, fuerte),!
    	%el acorde 2 está en parte fuerte y el 1 y el 3 en débil al ser binario el compás, no mola pq el acorde 2
    	%es menos estable que el 3 => repito el acorde 1 para desplazar F2 a parte debil
    	,sumarFracciones(fraccion_nat(NumCompPre2Nom,NumCompPre2Den), fraccion_nat(N1,D1), fraccion_nat(Na1, Da1))
    	,sumarFracciones(fraccion_nat(Na1, Da1), fraccion_nat(N2,D2), fraccion_nat(Na2, Da2))
		,aseg_ritmo_arm_acu([(C2,figura(N2,D2)),(C3,F3)|Lcin],(Na2, Da2), Lcout).

aseg_ritmo_arm_acu([(C1,figura(N1,D1)),(C2,figura(N2,D2)),(C3,F3)|Lcin], (NumCompPre2Nom, NumCompPre2Den)
	, [(C1,figura(N1,D1)),(C1,figura(N1,D1)),(C2,figura(N2,D2))|Lcout]) :-
		dameFuncionTonalCifrado(C2, FuncTonal2)
		,dameFuncionTonalCifrado(C3, FuncTonal3)
		,menosEstable(FuncTonal3, FuncTonal2)
    	,fuerzaEnElCompas(NumCompPre2Nom,NumCompPre2Den,binario, debil),!
    	%el acorde 2 está en parte débil y el 1 y el 3 en fuerte al ser binario el compás, no mola pq el acorde 2
    	%es mas estable que el 3 => repito el acorde 1 para desplazar F2 a parte fuerte
    	,sumarFracciones(fraccion_nat(NumCompPre2Nom,NumCompPre2Den), fraccion_nat(N1,D1), fraccion_nat(Na1, Da1))
    	,sumarFracciones(fraccion_nat(Na1, Da1), fraccion_nat(N2,D2), fraccion_nat(Na2, Da2))
		,aseg_ritmo_arm_acu([(C2,figura(N2,D2)),(C3,F3)|Lcin],(Na2, Da2), Lcout).

aseg_ritmo_arm_acu([(C1,F1),(C2,figura(N2,D2)),(C3,F3)|Lcin], (NumCompPre2Nom, NumCompPre2Den)
	, [(C1,F1),(C2,figura(N2,D2))|Lcout]) :-
		%ninguno de los anteriores => OK
    	sumarFracciones(fraccion_nat(NumCompPre2Nom,NumCompPre2Den), fraccion_nat(N2,D2), fraccion_nat(Na1, Da1))
    	,aseg_ritmo_arm_acu([(C2,figura(N2,D2)),(C3,F3)|Lcin],(Na1, Da1), Lcout).



		%AÑADE ACORDES2
/**
* aniade_acordes(Po, Pd) a partir de la progresión origen Po se crea otra progresión destino Pd que es
* idéntica a  Po salvo porque se ha sustituido uno de sus acordes diatónicos!! por dos acordes, el primero del mismo cifrado
* del original y durando lo mismo y, el segundo de la misma función tonal que el original (elegido al azar
* y distinto) y durando lo mismo. El primero aparecerá siempre delante del segundo en la progresión. El
* acorde que será desdoblado se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser
* elegidos
* PENDIENTE MANTENER EL RITMO ARMÓNICO COMO INVARIANTE TB AQUI
* Pre!!! Lo en forma normal sería recomendable
* Post Ld está en forma normal
* in: Po progresión origen cumple es_progresion(Po)
* out:Pd progresión destino cumple es_progresion(Po)
*/
aniade_acordes2(progresion(Lo), progresion(Ld)) :- aniade_acordesLista2(Lo, Ld).
aniade_acordesLista2([], []) :-!.
aniade_acordesLista2(Lo, Ld) :-
       setof((cifrado(Gc,Mc), Fc, Posc),
             (
       	      nth(Posc, Lo, (cifrado(Gc,Mc), Fc))
              ,listaGradosNoDiatonicos(jonico,ListaGrados)
              ,\+(member(Gc, ListaGrados))
             )
              , Lc)
       ,length(Lc, Long), Long > 0, !
       ,dame_elemento_aleatorio(Lc, (AcordElegido, F), PosElegida)
      ,dame_cuat_funcTonal_equiv(AcordElegido, AcordAniadir)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
      ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordElegido, F),(AcordAniadir, F)], Laux), append(Laux, LdB, Ld).

aniade_acordesLista2(Lo, Lo).


		%PREDICADOS QUE CAMBIAN LA PROGRESION SIN AÑADIR COMPASES

modifica_prog(Pin, M, Pin) :- M =< 0.
modifica_prog(Pin, M, Pout) :- accion_modif(Pin, Paux), M1 is M - 1, modifica_prog(Paux, M1, Pout).
num_acciones_modif(3).
accion_modif(Pin, Pout) :- num_acciones_modif(N), random(0, N, NumAccion), accion_modif(Pin, Pout, NumAccion).
accion_modif(Pin, Pout, 0) :- aniade_acordes(Pin, Pout).
accion_modif(Pin, Pout, 1) :- quita_acordes(Pin, Pout).
accion_modif(Pin, Pout, 2) :- cambia_acordes(Pin, Pout).

aplica_cambia_acordes(Ori, N, Dest) :- N>0, !, N1 is N -1, cambia_acordes(Ori, Aux1), aplica_cambia_acordes(Aux1, N1, Dest).
aplica_cambia_acordes(Ori, _, Ori).

			%CAMBIA ACORDES
/**
* cambia_acordes(Po, Pd) a partir de la progresión origen Po se crea otra progresión destino Pd que es
* idéntica a Po excepto porque se ha realizado 1 cambio de un acorde diatónico!!! por otro de la misma función tonal
* (elegido al azar y distinto) y que dura lo mismo (misma figura en la progresión). El acorde que será
* sustituido se elige al azar, teniendo todos los acordes comsiderados la misma probabilidad de ser elegidos
* PENDIENTE MANTENER EL RITMO ARMÓNICO COMO INVARIANTE TB AQUI
* Pre!!! Po en forma normal sería recomendable
* Post: Pd está en forma normal
* @param +Po progresión origen cumple es_progresion(Po)
* @param -Pd progresión destino cumple es_progresion(Po)
*/
cambia_acordes(progresion(Lo), progresion(Ld)) :- cambia_acordesLista(Lo, Ld).
cambia_acordesLista([], []) :- !.
cambia_acordesLista(Lo, Ld) :-
       setof((cifrado(Gc,Mc), Fc, Posc),
             (
       	      nth(Posc, Lo, (cifrado(Gc,Mc), Fc))
              ,listaGradosNoDiatonicos(jonico,ListaGrados)
              ,\+(member(Gc, ListaGrados))
             )
              , Lc)
       ,length(Lc, Long), Long > 0, !
      ,dame_elemento_aleatorio(Lc, (AcordElegido, F, PosElegida), _)
      ,dame_cuat_funcTonal_equiv(AcordElegido, AcordSustituto)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
      ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordSustituto, F)], Laux), append(Laux, LdB, Ld).

cambia_acordesLista(Lo, Lo).

			%AÑADE ACORDES
/**
* aniade_acordes(Po, Pd) a partir de la progresión origen Po se crea otra progresión destino Pd que es
* idéntica a  Po salvo porque se ha sustituido uno de sus acordes diatónicos!!! por dos acordes, el primero
* del mismo cifrado del original pero durando la mitad y el segundo de la misma función tonal que el original
* (elegido al azar y distinto) y durando también la mitad. El primero aparecerá siempre delante del segundo en
* la progresión. El acorde que será desdoblado se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser
* elegidos
* PENDIENTE MANTENER EL RITMO ARMÓNICO COMO INVARIANTE TB AQUI
* Pre!!! Po en forma normal sería recomendable
* Post: Pd está en forma normal
* @param +Po progresión origen cumple es_progresion(Po)
* @param -Pd progresión destino cumple es_progresion(Po)
*/
aniade_acordes(progresion(Lo), progresion(Ld)) :- aniade_acordesLista(Lo, Ld).
aniade_acordesLista([], []) :- !.
aniade_acordesLista(Lo, Ld) :-
	   setof((cifrado(Gc,Mc), Fc, Posc),
             (
       	      nth(Posc, Lo, (cifrado(Gc,Mc), Fc))
              ,listaGradosNoDiatonicos(jonico,ListaGrados)
              ,\+(member(Gc, ListaGrados))
             )
              , Lc)
       ,length(Lc, Long), Long > 0, !
       ,dame_elemento_aleatorio(Lc, (AcordElegido, F, PosElegida), _)
       ,dame_cuat_funcTonal_equiv(AcordElegido, AcordAniadir)
      ,divideFigura(F, 2, Fmed)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
      ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordElegido, Fmed),(AcordAniadir, Fmed)], Laux), append(Laux, LdB, Ld).

aniade_acordesLista(Lo, Lo).


			%QUITA ACORDES
/**
* quita_acordes(Po,Pd) busca todas las parejas de acordes diatónicos !!!adyacentes que tengan la misma función tonal,
* elige una de éstas al azar asignando la misma probabilidad a cada pareja y sustituye a la pareja por otro
* acorde que dure mismo que la suma de las duraciones de las parejas y que tenga la misma función tonal
* (elegido al azar y no necesariamente distinto). Si no es posible hacer esto pq no hay parejas adyacentes
* de misma función tonal entonces devuelve en Pd la misma progresion Po
* PENDIENTE MANTENER EL RITMO ARMÓNICO COMO INVARIANTE TB AQUI
* Pre!!! Lo en forma normal sería recomendable
* Post Ld está en forma normal
* @param +Po progresión origen cumple es_progresion(Po)
* @param -Pd progresión destino cumple es_progresion(Po)
**/
quita_acordes(progresion(Lo), progresion(Ld)) :- quita_acordesLista(Lo, Ld).
quita_acordesLista([], []) :- !.
quita_acordesLista(Lo, Ld) :- busca_acordes_afines(Lo,LPos),dame_elemento_aleatorio(LPos, PosElegida),!
      ,nth(PosElegida, Lo, (Acord1, F1)), P2 is PosElegida + 1,nth(P2, Lo, (_, F2))
      ,dame_cuat_funcTonal_equiv2(Acord1, AcordSustituto), sumaFiguras(F1, F2, FigSustit)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 2 ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordSustituto, FigSustit)], Laux), append(Laux, LdB, Ld).
quita_acordesLista(Lo, Lo).
