
/*
GENERADOR DE SECUENCIAS DE ACORDES A REDONDAS EN ESCALA DE DO JONICO

-en compas de 2 por 4 y posici?n de t?nica en primera disposicion
-pag 61: a?adir, cambiar y quitar acordes
-pag 64: colocacion de los acordes en la frase arm?nica
-poner lo del movimineto entre fundamentales pg 66
-pg 81 : bVII
-todo de cadenas
*/

%DECLARACION DEL MODULO
%:- module(generador_acordes_binario).
:- module(generador_acordes_binario
    ,[ haz_progresion/4
      ,accion_modif/3
      ,modifica_prog/3
      ,pasa_args_a_tipo_mutacion/2
      ,es_tipo_mutacion/1
      ,modifica_prog2/3
      ,haz_progresion2/4
      ,duracionProg/2] ).

%BIBLIOTECAS
:- ensure_loaded(library(lists)).
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

	%PREDICADOS DE GENERACION

/**
* haz_progresion(+N, +M, +TipoSemilla, -Progresion)
* Genera una progresion de acordes en modo Jonico sin especificar la tonalidad (como lista de grados asociados a un
* cifrado americano), que empleando tecnicas de armonia moderna y de forma pseudoaleatoria
* @param +N natural que indica el numero exacto de compases que durar? de la progresi?n
* @param +M natural que indica el numero de mutaciones que se realizaran para conseguir la progresion
* @param +TipoSemilla si vale n entonces se utilizar? haz_prog_semillan/2 para la generacion de la semilla, debe pertenecer al conjunto
* {1, 3} por ahora
* @param -Progresion termino que hace cierto el predicado es_progresion con el que se expresa la progresion de
* acordes generada
*/

haz_progresion(N, _, _, progresion([])) :- N =< 0, !.
haz_progresion(N, M, Tipo, ProgMutada) :- rango_prog_semilla(Tipo,MinComp, MaxComp)
, intervaloEntero(MinComp, MaxComp, CompPos), divisores(N, CompPos, CompCand)
, setof((CC,CC),member(CC,CompCand), ListaEligeSemilla)
, dame_elemento_aleat_lista_pesos(ListaEligeSemilla, NCompasesSemilla, _, _)
, haz_prog_semilla(NCompasesSemilla, Tipo, ProgSemilla)
, FactorMul is N // NCompasesSemilla
, multiplica_duracion(ProgSemilla, FactorMul, ProgMutable)
, modifica_prog(ProgMutable, M, ProgMutada)
, termina_haz_progresion(ProgMutada).

termina_haz_progresion(progresion(Prog)) :-
		fichero_destinoGenAc_prog(FichProg),
		fichero_destinoGenAc_prog_depura(FichProgDepura),
                escribeTermino(FichProg, progresion(Prog)),
                escribeLista(FichProgDepura, Prog).


modifica_prog(Pin, M, Pin) :- M =< 0.
modifica_prog(Pin, M, Pout) :- accion_modif(Pin, Paux), M1 is M - 1, modifica_prog(Paux, M1, Pout).
accion_modif(Pin, Pout) :- num_acciones_modif(N), random(0, N, NumAccion), accion_modif(Pin, Pout, NumAccion).
num_acciones_modif(5).
accion_modif(Pin, Pout, 0) :- aniade_dominante_sec(Pin,Pout).
accion_modif(Pin, Pout, 1) :- aniade_iim7_rel(Pin, Pout).
accion_modif(Pin, Pout, 2) :- aniade_acordes(Pin, Pout).
accion_modif(Pin, Pout, 3) :- quita_acordes(Pin, Pout).
accion_modif(Pin, Pout, 4) :- cambia_acordes(Pin, Pout).

/* modif por pruebas
num_acciones_modif(3).
accion_modif(Pin, Pout) :- num_acciones_modif(N), random(0, N, NumAccion), accion_modif(Pin, Pout, NumAccion).
accion_modif(Pin, Pout, 0) :- aniade_acordes(Pin, Pout).
accion_modif(Pin, Pout, 1) :- quita_acordes(Pin, Pout).
accion_modif(Pin, Pout, 2) :- cambia_acordes(Pin, Pout).*/


		%PREDICADOS QUE CAMBIAN LA PROGRESION SIN A?ADIR COMPASES

			%DOMINANTES SECUNDARIOS
/**
* aniade_dominante_sec(Po,Pd): Pd es una progresion igual a Po pero en la que se ha a?adido un dominante
* secundario de un acorde elegido al azar, dando mayor probabilidad de recibir dominante a los acordes que
* duran m?s
* El dominante secundario se a?adir? seg?n generador_acordes_binario:inserta_dominante_sec/2, por lo que no
* a?adir? m?s acordes a la progresi?n
* @param +Po cumple es_progresion(Po)
* @param -Pd cumple es_progresion(Pd)
*/
aniade_dominante_sec(progresion(Lo), progresion(Ld)) :- aniade_dom_sec_lista(Lo, Ld).
aniade_dom_sec_lista([], []) :- !.
/*FIXME:lo del 1024 es una guarrer?a muy chunga que hay que arreglar*/
aniade_dom_sec_lista(Lo, Ld):-
    buscaCandidatosADominanteSec(Lo, Lc)
	,length(Lc,Long), Long >0 ,!
    ,setof(((Cif, figura(N,D), PosElegida),Peso),
    	(member((Cif, figura(N,D), PosElegida),Lc), Peso is round(N/D*2048))
    	, ListaEligeDominante)
    ,dame_elemento_aleat_lista_pesos(ListaEligeDominante, (Cif, F, PosElegida), _, _)
	,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
    ,sublista_suf(Lo, PosElegMas, LdB)
    ,inserta_dominante_sec((Cif,F), ListaInsertar)
    ,append(LdA, ListaInsertar, Laux),append(Laux, LdB, Ld).

aniade_dom_sec_lista(Lo, Lo).

monta_dominante_sec(grado(i),grado(v)) :-!.
monta_dominante_sec(grado(G),grado(v7 / G)).

/**
* inserta_dominante_sec((+Cif,+Figura), -Ld). Devuelve en Ld una lista de parejas (cifrado,acorde) correspondientes a una progresion
* formada por el acorde correspondiente a Cif durando un cuarto de lo que duraba ?ste, seguido del dominate correspondiente a Cif
* durando un cuarto de lo que duraba Cif, seguido del acorde correspondiente a Cif durando un medio de lo que duraba ?ste. De esta
* forma se obtiene una progresi?n que dura lo mismo que el acorde correspondiente a Cif y que respeta el ritmo arm?nico
*   F              D
* F    D       F      D
*
* @param +Cif cumple es_cifrado(Cif)
* @param +Figura cumple es_figura(Figura)
* @param +Ld cumple es_progresion(progresion(Ld))
*/

inserta_dominante_sec((cifrado(G,Mat), F)
      , [(cifrado(G,Mat), Fcuart),(cifrado(GDominante,matricula(7)), Fcuart), (cifrado(G,Mat), Fmed)])
              :- !, monta_dominante_sec(G, GDominante), divideFigura(F,2,Fmed), divideFigura(F,4,Fcuart).
/*inserta_dominante_sec((cifrado(grado(G),Mat), F)
      , [(cifrado(grado(G),Mat), Fcuart),(cifrado(GDominante,matricula(7)), Fcuart), (cifrado(grado(G),Mat), Fmed)])
              :- !, monta_dominante_sec(grado(G), GDominante), divideFigura(F,2,Fmed), divideFigura(F,4,Fcuart).*/
/**
* buscaCandidatosADominanteSec(Li, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los acordes a los que se
* les puede a?adir un dominante secundario por delante de ellos, esto es, aquellos a los que no se les ha a?adido ya un dominante
* secundario. Al primer grado se considera que se le puede a?adir un dominante secundario, por tanto el primer acorde de una progresi?n
* siempre ser? candidato, a menos que sea el septimo grado
* @param +Li cumple es_progresion(progresion(Li))
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
buscaCandidatosADominanteSec([(cifrado(grado(vii),M), F)|Li], Lo)
	:- !, buscaCandidatosADominanteSecAcu([(cifrado(grado(vii),M), F)|Li], 2, Lo).
buscaCandidatosADominanteSec([(cifrado(grado(G),M), F)|Li], [(cifrado(grado(G),M), F, 1)|Lo])
	:- buscaCandidatosADominanteSecAcu([(cifrado(grado(G),M), F)|Li], 2, Lo).
/**
* buscaCandidatosADominanteSecAcu(Li, PosActual, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los acordes a los que se
* les puede a?adir un dominante secundario por delante de ellos, esto es, aquellos a los que no se les ha a?adido ya un dominante
* secundario (se permite a?adir dom secundario al primer grado).
* PosActual indica la posicion del acorde que se considera, dentro de la lista
* total sobre la que se ha llamado a buscaCandidatosADominanteSec, que a su vez habr? llamado a este predicado
* @param +Li cumple es_progresion(progresion(Li))
* @param +PosActual es un natural
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
buscaCandidatosADominanteSecAcu([], _, []).
buscaCandidatosADominanteSecAcu([_],_,[]).%pq _ ya se habr?a examinado
/*hay q darse cuenta de q el primer acorde de la progresion nunca ser? candidato entonces, por eso se llama desde buscaCandidatosADominanteSec
dos con PosActual valiendo 2*/
/*evita añadir dos veces un dominante secundario*/
buscaCandidatosADominanteSecAcu([(cifrado(grado(v7 / G2),matricula(_)), _),(cifrado(grado(G2),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(G2),matricula(M2)), F2)|Li], PosSig, Lo).

/*evita a?adir otra vez el v grado delante de un i grado precedido de v grado*/
buscaCandidatosADominanteSecAcu([(cifrado(grado(v),matricula(_)), _),(cifrado(grado(i),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(i),matricula(M2)), F2)|Li], PosSig, Lo).

/*evita añadir un dominante secundario a un vii grado*/
buscaCandidatosADominanteSecAcu([_,(cifrado(grado(vii),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(vii),matricula(M2)), F2)|Li], PosSig, Lo).

buscaCandidatosADominanteSecAcu([_,(cifrado(grado(G2),matricula(M2)), F2)|Li]
    , PosActual, [(cifrado(grado(G2),matricula(M2)), F2, PosActual)|Lo]) :-
                       PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(G2),matricula(M2)), F2)|Li], PosSig, Lo).


			%II-7 RELATIVO
/**
* aniade_iim7_rel(Po,Pd): Pd es una progresion igual a Po pero en la que se ha a?adido un ii-7 de un
* dominante elegido al azar, dando mayor probabilidad de recibir ii-7 a los dominantes que
* duran m?s
* El dominante secundario se a?adir? seg?n
* @param +Po cumple es_progresion(Po)
* @param -Pd cumple es_progresion(Pd)
*/

aniade_iim7_rel(progresion(Lo), progresion(Ld)) :- aniade_iim7_rel_lista(Lo, Ld).
aniade_iim7_rel_lista([],[]) :- !.
/*FIXME:lo del 1024 es una guarrer?a muy chunga que hay que arreglar*/
aniade_iim7_rel_lista(Lo, Ld):-
    buscaCandidatosAiimRel(Lo, Lc)
	,length(Lc,Long), Long >0 ,!
    ,setof(((Cif, figura(N,D), PosElegida),Peso),
    	(member((Cif, figura(N,D), PosElegida),Lc), Peso is round(N/D*2048))
    	, ListaEligeiimRel)
    ,dame_elemento_aleat_lista_pesos(ListaEligeiimRel, (Cif, F, PosElegida), _, _)
	,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
    ,sublista_suf(Lo, PosElegMas, LdB)
    ,inserta_iim7_rel((Cif,F), ListaInsertar)
    ,append(LdA, ListaInsertar, Laux),append(Laux, LdB, Ld).

aniade_iim7_rel_lista(Lo, Lo).

monta_iim(grado(v),grado(ii)).
monta_iim(grado(v7 / G),grado(iim7 / G)).


/**
* inserta_iim7_rel((+CifDom,+Figura), -Ld). Devuelve en Ld una lista de parejas (cifrado,acorde) correspondientes a una progresion
* formada por el acorde correspondiente al iim7 relativo de CifDom durando la mitad de lo que duraba ?ste, seguido del acorde
* correspondiente a CifDom durando un medio de lo que duraba ?ste. De esta forma se obtiene una progresi?n que dura lo mismo que el
* acorde correspondiente a CifDom y que respeta el ritmo arm?nico
*   F              D
*
* @param +CifDom cumple es_cifrado(Cif) y corresponde a un acorde de dominante, si no fallar?
* @param +Figura cumple es_figura(Figura)
* @param +Ld cumple es_progresion(progresion(Ld))
*/
inserta_iim7_rel((cifrado(GD,matricula(7)), F)
      , [(cifrado(GIIm7,matricula(m7)), Fmed),(cifrado(GD,matricula(7)), Fmed)])
              :- !, monta_iim(GD, GIIm7), divideFigura(F,2,Fmed).

/**
* buscaCandidatosAiimRel(Li, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los dominantes a los que se
* les puede a?adir un iim7 relativo por delante de ellos, esto es, aquellos a los que no se les ha a?adido ya un iim7 relativo
* @param +Li cumple es_progresion(progresion(Li))
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/

buscaCandidatosAiimRel([(cifrado(grado(v),M), F)|Li], [(cifrado(grado(v),M), F, 1)|Lo])
	:- !,buscaCandidatosAiimRelAcu([(cifrado(grado(v),M), F)|Li], 2, Lo).
buscaCandidatosAiimRel([(cifrado(grado(v7 / G),M), F)|Li], [(cifrado(grado(v7 / G),M), F, 1)|Lo])
	:- !,buscaCandidatosAiimRelAcu([(cifrado(grado(v7 / G),M), F)|Li], 2, Lo).
buscaCandidatosAiimRel([(cifrado(grado(G), M), F)|Li], Lo)
	:- buscaCandidatosAiimRelAcu([(cifrado(grado(G), M), F)|Li], 2, Lo).

/**
* buscaCandidatosAIImRelAcu(Li, PosActual, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los dominantes a los que se
* les puede a?adir un iim7 relativo por delante de ellos, esto es, aquellos a los que no se les ha a?adido ya un iim7 relativo
* PosActual indica la posicion del acorde que se considera, dentro de la lista
* total sobre la que se ha llamado a buscaCandidatosAiimRelAcu, que a su vez habr? llamado a este predicado
* @param +Li cumple es_progresion(progresion(Li))
* @param +PosActual es un natural
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
buscaCandidatosAiimRelAcu([], _, []).
buscaCandidatosAiimRelAcu([_],_,[]).%pq _ ya se habr?a examinado
%hay q darse cuenta de q el primer acorde de la progresion nunca ser? candidato entonces, por eso empieza en dos
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


			%CAMBIA ACORDES
/**
* cambia_acordes(Po, Pd) a partir de la progresi?n origen Po se crea otra progresi?n destino Pd que es
* id?ntica a Po excepto porque se ha realizado 1 cambio de un acorde diat?nico!!! por otro de la misma funci?n tonal
* (elegido al azar y distinto) y que dura lo mismo (misma figura en la progresi?n). El acorde que ser?
* sustituido se elige al azar, teniendo todos los acordes comsiderados la misma probabilidad de ser elegidos
* @param +Po progresi?n origen cumple es_progresion(Po)
* @param -Pd progresi?n destino cumple es_progresion(Po)
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

			%A?ADE ACORDES
/**
* aniade_acordes(Po, Pd) a partir de la progresi?n origen Po se crea otra progresi?n destino Pd que es
* id?ntica a  Po salvo porque se ha sustituido uno de sus acordes diat?nicos!!! por dos acordes, el primero
* del mismo cifrado del original pero durando la mitad y el segundo de la misma funci?n tonal que el original
* (elegido al azar y distinto) y durando tambi?n la mitad. El primero aparecer? siempre delante del segundo en
* la progresi?n. El acorde que ser? desdoblado se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser
* elegidos
* PENDIENTE MANTENER EL RITMO ARM?NICO COMO INVARIANTE TB AQUI
* Pre!!! Po en forma normal ser?a recomendable
* Post: Pd est? en forma normal
* @param +Po progresi?n origen cumple es_progresion(Po)
* @param -Pd progresi?n destino cumple es_progresion(Po)
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
* quita_acordes(Po,Pd) busca todas las parejas de acordes diat?nicos !!!adyacentes que tengan la misma funci?n tonal,
* elige una de ?stas al azar asignando la misma probabilidad a cada pareja y sustituye a la pareja por otro
* acorde que dure mismo que la suma de las duraciones de las parejas y que tenga la misma funci?n tonal
* (elegido al azar y no necesariamente distinto). Si no es posible hacer esto pq no hay parejas adyacentes
* de misma funci?n tonal entonces devuelve en Pd la misma progresion Po
* PENDIENTE MANTENER EL RITMO ARM?NICO COMO INVARIANTE TB AQUI
* Pre!!! Lo en forma normal ser?a recomendable
* Post Ld est? en forma normal
* @param +Po progresi?n origen cumple es_progresion(Po)
* @param -Pd progresi?n destino cumple es_progresion(Po)
**/
quita_acordes(progresion(Lo), progresion(Ld)) :- quita_acordesLista(Lo, Ld).
quita_acordesLista([], []) :- !.
quita_acordesLista(Lo, Ld) :- busca_acordes_afines(Lo,LPos),
      length(LPos, Long), Long >0, dame_elemento_aleatorio(LPos, PosElegida),!
      ,nth(PosElegida, Lo, (Acord1, F1)), P2 is PosElegida + 1,nth(P2, Lo, (_, F2))
      ,dame_cuat_funcTonal_equiv2(Acord1, AcordSustituto), sumaFiguras(F1, F2, FigSustit)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 2 ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordSustituto, FigSustit)], Laux), append(Laux, LdB, Ld).
quita_acordesLista(Lo, Lo).




/*********************** CODIGO DE ROBERTO **********************************/
/*
* Este codigo es usado por el mainargs. Crea y modifica una progresion en funcion de 
* los parametros que se le pasen. Es una generalizacion del codigo que esta arriba.
*/

/**
* es_tipo_mutacion( +Tipo_Mutacion )
* Define la estructura de terminos que indican como son las mutaciones que hay que hacer a una progresion
* @param +Tipo_Mutacion termino que indica el numero de las diferentes posibilidades para las mutaciones
*/
es_tipo_mutacion( tm([NM]) ) :- 
       number(NM).
es_tipo_mutacion( tab([NMTA, NMTB]) ) :- 
       number(NMTA)
      ,number(NMTB).
es_tipo_mutacion( ta45([NMTA, NMT4, NMT5]) ) :- 
       number(NMTA)
      ,number(NMT4)
      ,number(NMT5).
es_tipo_mutacion( t12345([NMT1, NMT2, NMT3, NMT4, NMT5]) ) :- 
       number(NMT1)
      ,number(NMT2)
      ,number(NMT3)
      ,number(NMT4)
      ,number(NMT5).
es_tipo_mutacion( t123b([NMT1, NMT2, NMT3, NMTB]) ) :-
       number(NMT1)
      ,number(NMT2)
      ,number(NMT3)
      ,number(NMTB).


/**
* para_args_a_tipo_mutacion( +Argumentos, -Tipo_Mutacion )
* Traduce los parametros relacionados con las mutaciones que se pasa al mainargs a un tipo mas manejable por prolog
* @param +Argumentos lista de atomos que indican las mutaciones tal y como las recibe el mainargs
* @param -Tipo_Mutacion cumple es_tipo_mutacion/1
*/
% Solamente numero de mutaciones
pasa_args_a_tipo_mutacion( [ MT, N_mutaciones ] , tm([NM]) ) :-
        atom_to_term(MT, mt, _)
       ,atom_number(N_mutaciones, NM).
% Tipo A y Tipo B
pasa_args_a_tipo_mutacion( [ TA, N_TA, TB, N_TB ], tab([NMTA, NMTB]) ) :-
        atom_to_term(TA, ta, _)
       ,atom_number(N_TA, NMTA)
       ,atom_to_term(TB, tb, _)
       ,atom_number(N_TB, NMTB).
% Tipo A y Tipo 4 y 5
pasa_args_a_tipo_mutacion( [ TA, N_TA, T4, N_T4, T5, N_T5 ] , ta45([NMTA, NMT4, NMT5]) ) :-
        atom_to_term(TA, ta, _)
       ,atom_number(N_TA, NMTA)
       ,atom_to_term(T4, t4, _)
       ,atom_number(N_T4, NMT4)
       ,atom_to_term(T5, t5, _)
       ,atom_number(N_T5, NMT5).
% Tipo 1, 2, 3, 4 y 5
pasa_args_a_tipo_mutacion( [ T1, N_T1, T2, N_T2, T3, N_T3, T4, N_T4, T5, N_T5 ] , t12345([NMT1, NMT2, NMT3, NMT4, NMT5]) ) :-
        atom_to_term(T1, t1, _)
       ,atom_number(N_T1, NMT1)
       ,atom_to_term(T2, t2, _)
       ,atom_number(N_T2, NMT2)
       ,atom_to_term(T3, t3, _)
       ,atom_number(N_T3, NMT3)
       ,atom_to_term(T4, t4, _)
       ,atom_number(N_T4, NMT4)
       ,atom_to_term(T5, t5, _)
       ,atom_number(N_T5, NMT5).
% Tipo 1, 2 y 3 y Tipo B
pasa_args_a_tipo_mutacion( [ T1, N_T1, T2, N_T2, T3, N_T3, TB, N_TB ] , t123b([NMT1, NMT2, NMT3, NMTB]) ) :-
        atom_to_term(T1, t1, _)
       ,atom_number(N_T1, NMT1)
       ,atom_to_term(T2, t2, _)
       ,atom_number(N_T2, NMT2)
       ,atom_to_term(T3, t3, _)
       ,atom_number(N_T3, NMT3)
       ,atom_to_term(TB, tb, _)
       ,atom_number(N_TB, NMTB).   

/**
* crea_progresion(+NumCompases, +Tipo, -Progresion)
* Crea una progresion de NumCompases a partir de una progresion semilla de tipo Tipo pero sin hacer ninguna mutacion
* @param +NumCompases numero de compases de Progresion
* @param +Tipo tipo de la progresion semilla usada
* @param -Progresion cumple es_progresion/1 creada sin ninguna mutacion
*/
crea_progresion(N, _, progresion([])) :- 
        N =< 0
       ,!.
crea_progresion(N, Tipo, Prog) :- 
        rango_prog_semilla(Tipo,MinComp, MaxComp)
       ,intervaloEntero(MinComp, MaxComp, CompPos), divisores(N, CompPos, CompCand)
       ,setof((CC,CC),member(CC,CompCand), ListaEligeSemilla)
       ,dame_elemento_aleat_lista_pesos(ListaEligeSemilla, NCompasesSemilla, _, _)
       ,haz_prog_semilla(NCompasesSemilla, Tipo, ProgSemilla)
       ,FactorMul is N // NCompasesSemilla
       ,multiplica_duracion(ProgSemilla, FactorMul, Prog).


/**
* modifica_prog2( +Pin, +TipoMutacion, -Pout)
* Muta la progresion de entrada en funcion de TipoMutacion
* @param +Pin cumple es_progresion/1. Progresion para mutar
* @param +TipoMutacion forma en que hay que mutarla
* @param -Pout cumple es_progresion/1. Progresion de salida
*/
% cuando se le da Tipo A y tipo B
modifica_prog2( Pin, tab([NTA, NTB]), Pout ) :-
        modificaProgTipoA(Pin,  Paux, NTA)
       ,modificaProgTipoA(Paux, Pout, NTB).
% cuando se le da Tipo A y tipo 4 y 5
modifica_prog2( Pin, ta45([NTA, NT4, NT5]), Pout ) :-
        modificaProgTipoA(Pin,  Paux1, NTA)
       ,modificaProgTipoNum(Paux1, Paux2, 4, NT4)
       ,modificaProgTipoNum(Paux2, Pout, 5, NT5).
% cuando se le da Tipo 1, 2, 3, 4 y 5
modifica_prog2( Pin, t12345([NT1, NT2, NT3 , NT4, NT5]), Pout ) :-
        modificaProgTipoNum(Pin,   Paux1, 1, NT1)
       ,modificaProgTipoNum(Paux1, Paux2, 2, NT2)
       ,modificaProgTipoNum(Paux2, Paux3, 3, NT3)
       ,modificaProgTipoNum(Paux3, Paux4, 4, NT4)
       ,modificaProgTipoNum(Paux4, Pout,  5, NT5).
% cuando se le da Tipo 1, 2 y 3 y tipo B
modifica_prog2( Pin, t123b([NT1, NT2, NT3, NTB]), Pout ) :-
        modificaProgTipoNum(Pin, Paux1, 1, NT1)
       ,modificaProgTipoNum(Paux1, Paux2, 2, NT2)
       ,modificaProgTipoNum(Paux2, Paux3, 3, NT3)
       ,modificaProgTipoB(Paux3,  Pout, NTB).
% cuando se le da el numero de mutaciones totales
modifica_prog2( Pin, tm([NM]), Pout ) :-
        modifica_prog(Pin, NM, Pout).


/**
* haz_progresion2( +NumCompases, +TipoSemilla, +TipoMutaciones, -Prog)
* Crea y modifica una progresion en funcion de los parametros que se le pasa
* @param +NumCompases numero de compases de la progresion de salida
* @param +TipoSemilla tipo de semilla usada en la creacion
* @param +TipoMutaciones forma en que hay que mutar
* @param -Prog progresion salida. Cumple es_progresion/1
*/
haz_progresion2(N, TipoSemilla, TipoMutaciones, Prog) :-
        crea_progresion(N, TipoSemilla, ProgAux)
       ,modifica_prog2( ProgAux, TipoMutaciones, Prog).


/**
* modificaProgTipoA( +Pin, -Pout, +Num_mut)
* Hacer Num_mut de tipo A a la progresion de entrada
* @param +Pin progresion entrada. Cumple es_progresion/1
* @param -Pout progresion de salida y mutada con Num_mut de tipo A. Cumple es_progresion/1
* @param +Num_mut numero de mutaciones de tipo A
*/
modificaProgTipoA( Pin, Pin, Num_mut) :- Num_mut =< 0.
modificaProgTipoA( Pin, Pout, Num_mut) :-
        Num_mut_aux is Num_mut + 1
       ,random(0, Num_mut_aux, Num_tipo1) %numero aleatorio entre 0 y Num_mut => [0,Num_mut] = [0,Num_mut+1)
       ,Aux is Num_mut - Num_tipo1 + 1
       ,random(0, Aux, Num_tipo2) %numero aleatorio entre 0 y Aux => [0,Aux] = [0,Aux+1)
       ,Num_tipo3 is Num_mut - Num_tipo1 - Num_tipo2
       ,modificaProgTipoNum( Pin,    Paux,  1, Num_tipo1 )
       ,modificaProgTipoNum( Paux,   Paux2, 2, Num_tipo2 )
       ,modificaProgTipoNum( Paux2,  Pout,  3, Num_tipo3 ).


/**
* modificaProgTipoB( +Pin, -Pout, +Num_mut)
* Hacer Num_mut de tipo B a la progresion de entrada
* @param +Pin progresion entrada. Cumple es_progresion/1
* @param -Pout progresion de salida y mutada con Num_mut de tipo B. Cumple es_progresion/1
* @param +Num_mut numero de mutaciones de tipo A
*/
modificaProgTipoB( Pin, Pin, Num_mut) :- Num_mut =< 0.
modificaProgTipoB( Pin, Pout, Num_mut) :-
        Num_mut_aux is Num_mut + 1
       ,random(0, Num_mut_aux, Num_tipo4)      %numero aleatorio entre 0 y Num_mut => [0,Num_mut] = [0,Num_mut+1)
       ,Num_tipo5 is Num_mut - Num_tipo4
       ,modificaProgTipoNum( Pin,  Paux, 4, Num_tipo4 )
       ,modificaProgTipoNum( Paux, Pout, 5, Num_tipo5 ). 

/**
* modificaProgTipoNum( +Pin, -Pout, +TipoMutacion, +Num_mut)
* Hace Num_mut de tipo TipoMutacion a la progresion de entrada
* @param +Pin progresion entrada. Cumple es_progresion/1
* @param -Pout progresion de salida y mutada con Num_mut de tipo TipoMutacion. Cumple es_progresion/1
* @param +TipoMutacion numero del 1 al 5 correspondiente con las cinco formas de mutar una progresion
* @param +Num_mut numero de mutaciones de tipo A
*/
modificaProgTipoNum( Pin, Pin, _, Num_mut ) :- 
        Num_mut =< 0.
modificaProgTipoNum( Pin, Pout, TipoR, Num_mut ) :-
        Num_mut > 0
       ,traducedeTipoRobertoATipoJuan(TipoR, TipoJ)
       ,accion_modif(Pin, Paux, TipoJ)
       ,Num_mut2 is Num_mut - 1
       ,modificaProgTipoNum( Paux, Pout, TipoR, Num_mut2 ).


/**
* traducedeTipoRobertoATipoJuan( ?TipoRober, ?TipoJuan)
* Debido a que hay una diferencia de numeracion entre las mutaciones que estaban ya puestas y las que van a ser
* definitivas se ha creado esta mini base de datos relacional que relaciona los dos tipos
* @param ?TipoRober numero de la mutacion definitivo. De 1 a 5
* @param ?TipoJuan numero de la mutacion que estaba ya hecho. de 0 a 5
*/
traducedeTipoRobertoATipoJuan(1, 3). % quita acordes
traducedeTipoRobertoATipoJuan(2, 2). % aniade acordes
traducedeTipoRobertoATipoJuan(3, 4). % cabia acordes
traducedeTipoRobertoATipoJuan(4, 0). % aniade dominantes secundarios
traducedeTipoRobertoATipoJuan(5, 1). % aniade IIm7 relativos



/**
* haz_progresion2_con_semilla( +NumeroCompases, +ProgSemilla, +Tipo_Mutacion, -Pout)
* Crea y muta una progresion a partir de una mutacion semilla y los parametros pasados
* @param +NumeroCompases numero de compases de Pout
* @param +ProgSemilla progresion semilla. Cumple es_progresion/1 
* @param +Tipo_Mutacion tipo de mutaciones. Cumple es_tipo_mutacion/1
* @param -Pout progresion de salida. Cumple es_progresion/1
*/
haz_progresion2_con_semilla( NC, _, _, progresion([]) ) :-
        NC =< 0
       ,!.       
haz_progresion2_con_semilla( NC, P, Tipo_Mutacion, ProgMutada) :-
       NC > 0
      ,duracionProg(P, Dur)  % DURACION DE LA PROGRESION
      ,figuras_y_ritmo:divideFiguras( figura(NC, 1), Dur, FactorMul )
      ,multiplica_duracion2(P, FactorMul, ProgMutable)
      ,modifica_prog2(ProgMutable, Tipo_Mutacion, ProgMutada).



/**
* multiplica_duracion2( +Pin, +Figura , -Pout )
* multiplica cada acorde la la progresion Pin por Figura.
* @param +Pin progresion de entrada. Cumple es_progresion/1
* @param +Figura cumple es_figura/1
* @param +Pout progresion de salida. Cumple es_progresion/1
*/
multiplica_duracion2(progresion(L), Figura , progresion(Lout) ) :-
       multiplica_duracion2_rec(L, Figura, Lout).


/** 
* multiplica_duracion2_rec( +ListaCifradosIn, +Figura, -ListaCifradosOut)
* predicado auxiliar de multiplica_duracion2_rec. Recorre la lista multiplicando la duracion de cada
* acorde por Figura
* @param +ListaCifradosIn lista de acordes de entrada
* @param +Figura cumple es_figura/1
* @param -ListaCifradosOut lista de acordes de salida
*/
multiplica_duracion2_rec([], _, []).
multiplica_duracion2_rec([(C, F1) | Resto], F2, [(C, F3) | Lout] ) :-
       figuras_y_ritmo:multiplicaFiguras(F1, F2, F3)
      ,multiplica_duracion2_rec( Resto, F2, Lout ).


/**
* duracionProg( +Prog, +Duracion)
* Obtiene la duracion de la progresion Prog
* @param +Prog progresion de entrada. Cumple es_progresion/1
* @param +Duracion duracion de la progresion. Cumple es_figura/1
*/
duracionProg(progresion(L), Dur) :- duracionProg_rec(L, Dur).


/**
* duracionProg_rec( +Prog, +Duracion)
* Predicado auxiliar de duracionProg/2. Recorre la lista acumulando la duracion de cada acorde.
* @param +Prog lista de acordes
* @param +Duracion duracion de la progresion. Cumple es_figura/1
*/
duracionProg_rec([], figura(0,1)).
duracionProg_rec([(_, F1) | Resto], F3) :-
       duracionProg_rec(Resto, F2)
      ,figuras_y_ritmo:sumaFiguras(F1, F2, F3).










