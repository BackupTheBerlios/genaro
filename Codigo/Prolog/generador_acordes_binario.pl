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
    ,[haz_progresion/4]).

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
:- use_module(generador_notas_del_acorde_con_sistema_paralelo).
:- use_module(generador_notas_del_acorde_con_continuidad_armonica).


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

haz_progresion(N, _, _, progresion([])) :- N =< 0, !.
haz_progresion(N, M, Tipo, Progresion) :- rango_prog_semilla(Tipo,MinComp, MaxComp)
, intervaloEntero(MinComp, MaxComp, CompPos), divisores(N, CompPos, CompCand)
, setof((CC,CC),member(CC,CompCand), ListaEligeSemilla)
, dame_elemento_aleat_lista_pesos(ListaEligeSemilla, NCompasesSemilla, _, _)
, haz_prog_semilla(NCompasesSemilla, Tipo, ProgSemilla)
, FactorMul is N // NCompasesSemilla
, multiplica_duracion(ProgSemilla, FactorMul, ProgMutable)
, modifica_prog(ProgMutable, M, ProgMutada)
, termina_haz_progresion(ProgMutada, Progresion).

termina_haz_progresion(progresion(ProgRel), ProgNoRel) :-
		fichero_destinoGenAc_prog(FichNoRel), fichero_destinoGenAc_prog_con_rel(FichRel),
                fichero_destinoGenAc_prog_con_rel_depura(FichRelDepura),
                escribeTermino(FichRel, progresion(ProgRel)),
                escribeLista(FichRelDepura, ProgRel), quita_grados_relativos(progresion(ProgRel), ProgNoRel),
                escribeTermino(FichNoRel, ProgNoRel).


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


		%PREDICADOS QUE CAMBIAN LA PROGRESION SIN AÑADIR COMPASES

			%DOMINANTES SECUNDARIOS
/**
* aniade_dominante_sec(Po,Pd): Pd es una progresion igual a Po pero en la que se ha añadido un dominante
* secundario de un acorde elegido al azar, dando mayor probabilidad de recibir dominante a los acordes que
* duran más
* El dominante secundario se añadirá según generador_acordes_binario:inserta_dominante_sec/2, por lo que no
* añadirá más acordes a la progresión
* @param +Po cumple es_progresion(Po)
* @param -Pd cumple es_progresion(Pd)
*/
aniade_dominante_sec(progresion(Lo), progresion(Ld)) :- aniade_dom_sec_lista(Lo, Ld).
aniade_dom_sec_lista([], []) :- !.
/*FIXME:lo del 1024 es una guarrería muy chunga que hay que arreglar*/
aniade_dom_sec_lista(Lo, Ld):-
    buscaCandidatosADominanteSec(Lo, Lc)
	,length(Lc,Long), Long >0 ,!
    ,setof(((Cif, figura(N,D), PosElegida),Peso),
    	(member((Cif, figura(N,D), PosElegida),Lc), Peso is N/D*1024)
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
* formada por el acorde correspondiente a Cif durando un cuarto de lo que duraba éste, seguido del dominate correspondiente a Cif
* durando un cuarto de lo que duraba Cif, seguido del acorde correspondiente a Cif durando un medio de lo que duraba éste. De esta
* forma se obtiene una progresión que dura lo mismo que el acorde correspondiente a Cif y que respeta el ritmo armónico
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
* les puede añadir un dominante secundario por delante de ellos, esto es, aquellos a los que no se les ha añadido ya un dominante
* secundario. Al primer grado se considera que se le puede añadir un dominante secundario, por tanto el primer acorde de una progresión
* siempre será candidato
* @param +Li cumple es_progresion(progresion(Li))
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
buscaCandidatosADominanteSec([(cifrado(grado(G),M), F)|Li], [(cifrado(grado(G),M), F, 1)|Lo])
	:- buscaCandidatosADominanteSecAcu([(cifrado(grado(G),M), F)|Li], 2, Lo).
/**
* buscaCandidatosADominanteSecAcu(Li, PosActual, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
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
* dominante elegido al azar, dando mayor probabilidad de recibir ii-7 a los dominantes que
* duran más
* El dominante secundario se añadirá según
* @param +Po cumple es_progresion(Po)
* @param -Pd cumple es_progresion(Pd)
*/

aniade_iim7_rel(progresion(Lo), progresion(Ld)) :- aniade_iim7_rel_lista(Lo, Ld).
aniade_iim7_rel_lista([],[]) :- !.
/*FIXME:lo del 1024 es una guarrería muy chunga que hay que arreglar*/
aniade_iim7_rel_lista(Lo, Ld):-
    buscaCandidatosAiimRel(Lo, Lc)
	,length(Lc,Long), Long >0 ,!
    ,setof(((Cif, figura(N,D), PosElegida),Peso),
    	(member((Cif, figura(N,D), PosElegida),Lc), Peso is N/D*1024)
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
* formada por el acorde correspondiente al iim7 relativo de CifDom durando la mitad de lo que duraba éste, seguido del acorde
* correspondiente a CifDom durando un medio de lo que duraba éste. De esta forma se obtiene una progresión que dura lo mismo que el
* acorde correspondiente a CifDom y que respeta el ritmo armónico
*   F              D
*
* @param +CifDom cumple es_cifrado(Cif) y corresponde a un acorde de dominante, si no fallará
* @param +Figura cumple es_figura(Figura)
* @param +Ld cumple es_progresion(progresion(Ld))
*/
inserta_iim7_rel((cifrado(GD,matricula(7)), F)
      , [(cifrado(GIIm7,matricula(m7)), Fmed),(cifrado(GD,matricula(7)), Fmed)])
              :- !, monta_iim(GD, GIIm7), divideFigura(F,2,Fmed).

/**
* buscaCandidatosAiimRel(Li, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los dominantes a los que se
* les puede añadir un iim7 relativo por delante de ellos, esto es, aquellos a los que no se les ha añadido ya un iim7 relativo
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
* les puede añadir un iim7 relativo por delante de ellos, esto es, aquellos a los que no se les ha añadido ya un iim7 relativo
* PosActual indica la posicion del acorde que se considera, dentro de la lista
* total sobre la que se ha llamado a buscaCandidatosAiimRelAcu, que a su vez habrá llamado a este predicado
* @param +Li cumple es_progresion(progresion(Li))
* @param +PosActual es un natural
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
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


			%CAMBIA ACORDES
/**
* cambia_acordes(Po, Pd) a partir de la progresión origen Po se crea otra progresión destino Pd que es
* idéntica a Po excepto porque se ha realizado 1 cambio de un acorde diatónico!!! por otro de la misma función tonal
* (elegido al azar y distinto) y que dura lo mismo (misma figura en la progresión). El acorde que será
* sustituido se elige al azar, teniendo todos los acordes comsiderados la misma probabilidad de ser elegidos
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
quita_acordesLista(Lo, Ld) :- busca_acordes_afines(Lo,LPos),
      length(LPos, Long), Long >0, dame_elemento_aleatorio(LPos, PosElegida),!
      ,nth(PosElegida, Lo, (Acord1, F1)), P2 is PosElegida + 1,nth(P2, Lo, (_, F2))
      ,dame_cuat_funcTonal_equiv2(Acord1, AcordSustituto), sumaFiguras(F1, F2, FigSustit)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 2 ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordSustituto, FigSustit)], Laux), append(Laux, LdB, Ld).
quita_acordesLista(Lo, Lo).
