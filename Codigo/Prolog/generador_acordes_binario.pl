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
%%:- module(generador_acordes_binario).
:- module(generador_acordes_binario
    ,[genera_acordes/0
      ,genera_acordes/4
      ,cambia_acordes/2]).

%BIBLIOTECAS

%ARCHIVOS DE COMPATIBILIDAD
:- use_module(compat_Sicstus_SWI).

%ARCHIVOS PROPIOS CONSULTADOS
:- use_module(generador_acordes).
:- use_module(generador_acordes_semillas).
:- use_module(biblio_genaro_listas).
:- use_module(biblio_genaro_fracciones).
:- use_module(figuras_y_ritmo).
:- use_module(grados_e_intervalos).
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
* @param +N natural que indica el numero exacto de compases que durará la progresion
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
        ,generador_notas_del_acorde_con_sistema_paralelo:traduce_lista_cifrados(Prog,100,0,100,0,0,ListaAcordes)
        ,termina_genera_acordes(ListaAcordes).

genera_acordes(N,M, continuidad, TipoSemilla) :- haz_progresion(N, M, TipoSemilla, Prog)
        ,generador_notas_del_acorde_con_continuidad_armonica:traduce_lista_cifrados(Prog,ListaAcordes)
        ,termina_genera_acordes(ListaAcordes).

termina_genera_acordes(ListaAcordes) :-
        fichero_destinoGenAc_prog_ord(Dd), escribeTermino(Dd, ListaAcordes).

	%PREDICADOS DE GENERACION

/**
* haz_progresion(+N, +M, +TipoSemilla, -Progresion)
* Genera una progresion de acordes en modo Jonico sin especificar la tonalidad (como lista de grados asociados a un
* cifrado americano), que empleando tecnicas de armonia moderna y de forma pseudoaleatoria
* @param +N natural que indica el numero exacto de compases que durará de la progresión
* @param +M natural que indica el numero de mutaciones que se realizaran para conseguir la progresion
* @param +TipoSemilla si vale n entonces se utilizará haz_prog_semillan/2 para la generacion de la semilla, debe pertenecer al conjunto
* {1, 3} por ahora
* @param -Progresion termino que hace cierto el predicado es_progresion con el que se expresa la progresion de
* acordes generada
*/
/*haz_progresion(N, _, _, progresion([])) :- N < 0, !.
haz_progresion(N, M, 1, Progresion) :- N>=0, N =< 4,!, haz_prog_semilla(N, 1, PAux1),
	modifica_prog(PAux1, M, PAux2), termina_haz_progresion(PAux2, Progresion).
haz_progresion(N, M, 3, Progresion) :- N>=0, N =< 3,!, haz_prog_semilla(N, 3, PAux1),
	modifica_prog(PAux1, M, PAux2), termina_haz_progresion(PAux2, Progresion).

haz_progresion(N, M, Tipo, ProgNoRel) :- haz_prog_semilla(Tipo, ProgSem)
		,fija_compases(ProgSem, N, Paux1), modifica_prog(Paux1, M, Paux2)
                ,termina_haz_progresion(Paux2, ProgNoRel).*/

haz_progresion(N, _, _, progresion([])) :- N < 0, !.
haz_progresion(N, M, Tipo, Progresion) :- rango_prog_semilla(Tipo,MinComp, MaxComp)
, intervaloEntero(MinComp, MaxComp, CompPos), divisores(N, CompPos, CompCand)
, setof((CC,CC),member(CC,CompCand), ListaEligeSemilla)
, dame_elemento_aleat_lista_pesos(ListaEligeSemilla, NCompasesSemilla, _, _)
, haz_prog_semilla(NCompasesSemilla, Tipo, ProgSemilla)
, modifica_prog(ProgSemilla, M, ProgMutada)
, termina_haz_progresion(ProgMutada, Progresion).




/*setof((N,N),member(N,Xs), Ys)*/
                

termina_haz_progresion(progresion(ProgRel), ProgNoRel) :-
		fichero_destinoGenAc_prog(FichNoRel), fichero_destinoGenAc_prog_con_rel(FichRel),
                escribeLista(FichRel, ProgRel), quita_grados_relativos(progresion(ProgRel), ProgNoRel),
                escribeTermino(FichNoRel, ProgNoRel).

		%PREDICADOS QUE AÑADEN MAS COMPASES A LA PROGRESION
/*fija_compases(ProgSemilla, N, ProgResul). Partiendo de la progresion ProgSemilla construye otra
progresion de longitud N (N compases) alragando la de entrada. Por tanto si la progresión de entrada
dura N o más compases entonces no hace nada.
in: ProgSemilla progresión de partida (semilla). Cumple es_progresion(ProgSemilla)
    N numero de compases que tendra la progresion.
out: ProgResul resultado de las transformaciones, Cumple es_progresion(ProgResul)
*/
fija_compases(ProgSemilla, N, ProgSemilla) :- numCompases(ProgSemilla, NumComp), NumComp >= N,!.
fija_compases(ProgSemilla, N, ProgResul) :- alarga_progresion(ProgSemilla, ProgAux)
		,fija_compases(ProgAux, N, ProgResul).

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
* @param -Pd cumple es_progresion(Pd)
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

monta_dominante_sec(grado(i),grado(v)).
monta_dominante_sec(grado(G),grado(v7 / G)).

/**
* inserta_dominante_sec(Posicion, Lo, Ld). Devuelve en ListaResul el resultado de insertar en lista origen el cifrado correspondiente
* al dominante del acorde situado en la posicion indicada
* Se aumenta la duración de la progresión en una fracción de un compás potencia de dos compás.
* Respeta la continuidad armónica, debido a ello puede duplicar algunos acordes
* @param +Dominante: cumple es_grado(GDominante) y sigue el patrón grado(v7 / G) o grado(v)
* @param +Posicion es un natural
* @param +Lo cumple es_progresion(progresion(Lo))
* @param +Ld cumple es_progresion(progresion(Ld))
*/
/*no se puede insertar un dominante secundario en una progresion vacía
inserta_dominante_sec(_, [], [(cifrado(grado(v),matricula(7)), figura(1,1))]) :-!.*/
/*Cómo mantener el ritmo armónico: si el acorde al que le añado el dominante dura (N/D) tomo N/D como unidad. Como estamos
en binario supongo invariante que N es 1 y D es potencia de 2 (demostrar!!!)."Lo" sólo tiene un acorde, entonces la posicion 0
es fuerte y la posicion 0 + N/D es débil respecto a ella. Y tb ocurre que el segmento [0,2*N/D] se divide así
  F              D
F    D       F      D
0    N/2*D   N/D    3*N/2*D , cada fragmento de los 4 dura N/2*D

se alarga la progresion en N/D
*/
inserta_dominante_sec(_, [(cifrado(grado(G),matricula(M)), F)]
      , [(cifrado(grado(G),matricula(M)), Fmed),(cifrado(GDominante,matricula(7)), Fmed), (cifrado(grado(G),matricula(M)), F)])
              :- !, monta_dominante_sec(grado(G), GDominante), divideFigura(F,2,Fmed).
/*inserta_dominante_sec(_, [(cifrado(grado(G),matricula(M)), F)]
      , [(cifrado(GDominante,matricula(7)), figura(1,1)), (cifrado(grado(G),matricula(M)), F)])
              :- !, monta_dominante_sec(grado(G), GDominante).*/
/**
* buscaCandidatosADominanteSec(Li, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los acordes a los que se
* les puede añadir un dominante secundario por delante de ellos, esto es, aquellos a los que no se les ha añadido ya un dominante
* secundario. Al primer grado se considera que se le puede añadir un dominante secundario, por tanto el primer acorde de una progresión
* siempre será candidato
* @param +Li cumple es_progresion(progresion(Li))
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
/*buscaCandidatosADominanteSec([(cifrado(grado(i), M), F)|Li], Lo)
	:- !,buscaCandidatosADominanteSecAcu([(cifrado(grado(i), M), F)|Li], 2, Lo).*/
buscaCandidatosADominanteSec([(cifrado(grado(G),M), F)|Li], [(cifrado(grado(G),M), F, 1)|Lo])
	:- buscaCandidatosADominanteSecAcu([(cifrado(grado(G),M), F)|Li], 2, Lo).
/**
* % buscaCandidatosADominanteSecAcu(Li, PosActual, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los acordes a los que se
* les puede añadir un dominante secundario por delante de ellos, esto es, aquellos a los que no se les ha añadido ya un dominante
* secundario (se permite añadir dom secundario al primer grado).
* PosActual indica la posicion del acorde que se considera, dentro de la lista
* total sobre la que se ha llamado a buscaCandidatosADominanteSec, que a su vez habrá llamado a este predicado
* @param +Li cumple es_progresion(progresion(Li))
* @param +PosActual es un natural
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
buscaCandidatosADominanteSecAcu([], _, []).
buscaCandidatosADominanteSecAcu([_],_,[]).%pq _ ya se habría examinado
/*hay q darse cuenta de q el primer acorde de la progresion nunca será candidato entonces, por eso se llama desde buscaCandidatosADominanteSec
dos con PosActual valiendo 2*/
buscaCandidatosADominanteSecAcu([(cifrado(grado(v7 / G2),matricula(_)), _),(cifrado(grado(G2),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(G2),matricula(M2)), F2)|Li], PosSig, Lo).
/*buscaCandidatosADominanteSecAcu([_,(cifrado(grado(i),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(i),matricula(M2)), F2)|Li], PosSig, Lo).*/
/*evita añadir otra vez el v grado delante de un i grado precedido de v grado*/
buscaCandidatosADominanteSecAcu([(cifrado(grado(v),matricula(_)), _),(cifrado(grado(i),matricula(M2)), F2)|Li]
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
