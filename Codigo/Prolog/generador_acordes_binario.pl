%DESCRIPCION
/*
GENERADOR DE SECUENCIAS DE ACORDES A REDONDAS EN ESCALA DE DO JONICO

-en compas de 2 por 4 y posici�n de t�nica en primera disposicion
-pag 61: a�adir, cambiar y quitar acordes
-pag 64: colocacion de los acordes en la frase arm�nica
-poner lo del movimineto entre fundamentales pg 66
-pg 81 : bVII
-todo de cadenas
*/

%DECLARACION DEL MODULO
%%:- module(generador_acordes_binario).
:- module(generador_acordes_binario
    ,[genera_acordes/0
      ,genera_acordes/4
      ,cambia_acordes/2
      ,inserta_dominante_sec/2]).

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
* @param +N natural que indica el numero exacto de compases que durar� la progresion
* @param +M natural que indica el numero de transformaciones que se aplicar�n a la progresion
* @param +EnlaceVoces pertenece al conjunto {paralelo, continuidad} e indica cual de los dos sistemas se emplear�
* para enlazar las voces para generar el termino que cumple es_progresion_ordenada que luego se escribir� en el
* fichero
* @param +TipoSemilla indica cual de los predicados disponibles se utilizar� para la generaci�n de la semilla desde la que
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
* @param +N natural que indica el numero exacto de compases que durar� de la progresi�n
* @param +M natural que indica el numero de mutaciones que se realizaran para conseguir la progresion
* @param +TipoSemilla si vale n entonces se utilizar� haz_prog_semillan/2 para la generacion de la semilla, debe pertenecer al conjunto
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
, FactorMul is N // NCompasesSemilla
, multiplica_duracion(ProgSemilla, FactorMul, ProgMutable)
, modifica_prog(ProgMutable, M, ProgMutada)
, termina_haz_progresion(ProgMutada, Progresion).

termina_haz_progresion(progresion(ProgRel), ProgNoRel) :-
		fichero_destinoGenAc_prog(FichNoRel), fichero_destinoGenAc_prog_con_rel(FichRel),
                escribeLista(FichRel, ProgRel), quita_grados_relativos(progresion(ProgRel), ProgNoRel),
                escribeTermino(FichNoRel, ProgNoRel).

		%PREDICADOS QUE CAMBIAN LA PROGRESION SIN A�ADIR COMPASES

			%DOMINANTES SECUNDARIOS
/**
* aniade_dominante_sec(Po,Pd): Pd es una progresion igual a Po pero en la que se ha a�adido un dominante
* secundario de un acorde elegido al azar, dando la misma probabilidad de ser elegidos a todos los acordes
* El dominante secundario se a�adir� sin asegurarse de respetar las reglas de ritmo arm�nico y durar� lo mismo
* q el acorde sobre el que ejerce de dominante secundario
* @param +Po cumple es_progresion(Po)
* @param -Pd cumple es_progresion(Pd)
*/
aniade_dominante_sec(progresion(Lo), progresion(Ld)) :- aniade_dom_sec_lista(Lo, Ld).
aniade_dom_sec_lista([], []) :- !.
aniade_dom_sec_lista(Lo, Ld):-
        buscaCandidatosADominanteSec(Lo, Lc)
	,length(Lc,Long), Long >0 ,!
	,dame_elemento_aleatorio(Lc, (Cif, F, PosElegida), _)
	,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
        ,sublista_suf(Lo, PosElegMas, LdB)
        ,inserta_dominante_sec((Cif,F), ListaInsertar)
        ,append(LdA, ListaInsertar, Laux),append(Laux, LdB, Ld).

aniade_dom_sec_lista(Lo, Lo).

monta_dominante_sec(grado(i),grado(v)) :-!.
monta_dominante_sec(grado(G),grado(v7 / G)).

inserta_dominante_sec((cifrado(grado(G),matricula(M)), F)
      , [(cifrado(grado(G),matricula(M)), Fcuart),(cifrado(GDominante,matricula(7)), Fcuart), (cifrado(grado(G),matricula(M)), Fmed)])
              :- !, monta_dominante_sec(grado(G), GDominante), divideFigura(F,2,Fmed), divideFigura(F,4,Fcuart).


/*
/**
* inserta_dominante_sec(Posicion, Lo, Ld). Devuelve en ListaResul el resultado de insertar en lista origen el cifrado correspondiente
* al dominante del acorde situado en la posicion indicada
* Se aumenta la duraci�n de la progresi�n en una fracci�n de un comp�s potencia de dos comp�s.
* Respeta la continuidad arm�nica, debido a ello puede duplicar algunos acordes
* @param +Dominante: cumple es_grado(GDominante) y sigue el patr�n grado(v7 / G) o grado(v)
* @param +Posicion es un natural
* @param +Lo cumple es_progresion(progresion(Lo))
* @param +Ld cumple es_progresion(progresion(Ld))
*/
/*no se puede insertar un dominante secundario en una progresion vac�a
inserta_dominante_sec(_, [], [(cifrado(grado(v),matricula(7)), figura(1,1))]) :-!.*/
/*C�mo mantener el ritmo arm�nico: si el acorde al que le a�ado el dominante dura (N/D) tomo N/D como unidad. Como estamos
en binario supongo invariante que N es 1 y D es potencia de 2 (demostrar!!!)."Lo" s�lo tiene un acorde, entonces la posicion 0
es fuerte y la posicion 0 + N/D es d�bil respecto a ella. Y tb ocurre que el segmento [0,2*N/D] se divide as�
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

*/
/**
* buscaCandidatosADominanteSec(Li, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los acordes a los que se
* les puede a�adir un dominante secundario por delante de ellos, esto es, aquellos a los que no se les ha a�adido ya un dominante
* secundario. Al primer grado se considera que se le puede a�adir un dominante secundario, por tanto el primer acorde de una progresi�n
* siempre ser� candidato
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
* les puede a�adir un dominante secundario por delante de ellos, esto es, aquellos a los que no se les ha a�adido ya un dominante
* secundario (se permite a�adir dom secundario al primer grado).
* PosActual indica la posicion del acorde que se considera, dentro de la lista
* total sobre la que se ha llamado a buscaCandidatosADominanteSec, que a su vez habr� llamado a este predicado
* @param +Li cumple es_progresion(progresion(Li))
* @param +PosActual es un natural
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
buscaCandidatosADominanteSecAcu([], _, []).
buscaCandidatosADominanteSecAcu([_],_,[]).%pq _ ya se habr�a examinado
/*hay q darse cuenta de q el primer acorde de la progresion nunca ser� candidato entonces, por eso se llama desde buscaCandidatosADominanteSec
dos con PosActual valiendo 2*/
buscaCandidatosADominanteSecAcu([(cifrado(grado(v7 / G2),matricula(_)), _),(cifrado(grado(G2),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(G2),matricula(M2)), F2)|Li], PosSig, Lo).
/*buscaCandidatosADominanteSecAcu([_,(cifrado(grado(i),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(i),matricula(M2)), F2)|Li], PosSig, Lo).*/
/*evita a�adir otra vez el v grado delante de un i grado precedido de v grado*/
buscaCandidatosADominanteSecAcu([(cifrado(grado(v),matricula(_)), _),(cifrado(grado(i),matricula(M2)), F2)|Li]
    , PosActual, Lo) :- !,PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(i),matricula(M2)), F2)|Li], PosSig, Lo).
buscaCandidatosADominanteSecAcu([_,(cifrado(grado(G2),matricula(M2)), F2)|Li]
    , PosActual, [(cifrado(grado(G2),matricula(M2)), F2, PosActual)|Lo]) :-
                       PosSig is PosActual + 1
                       ,buscaCandidatosADominanteSecAcu([(cifrado(grado(G2),matricula(M2)), F2)|Li], PosSig, Lo).


			%II-7 RELATIVO
/**
* aniade_iim7_rel(Po,Pd): Pd es una progresion igual a Po pero en la que se ha a�adido un ii-7 de un
* dominante elegido al azar, dando la misma probabilidad de ser elegidos a todos los acordes
* El ii-7 se a�adir� sin asegurarse de respetar las reglas de ritmo arm�nico y durar� lo mismo
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
buscaCandidatosAiimRelAcu([_],_,[]).%pq _ ya se habr�a examinado
%hay q darse cuenta de q el primer acorde de la progresion nunca ser� candidato entonces, por eso empieza en dos
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

modifica_prog(Pin, M, Pin) :- M =< 0.
modifica_prog(Pin, M, Pout) :- accion_modif(Pin, Paux), M1 is M - 1, modifica_prog(Paux, M1, Pout).
accion_modif(Pin, Pout) :- aniade_dominante_sec(Pin,Pout).
/* modif por pruebas
num_acciones_modif(3).
accion_modif(Pin, Pout) :- num_acciones_modif(N), random(0, N, NumAccion), accion_modif(Pin, Pout, NumAccion).
accion_modif(Pin, Pout, 0) :- aniade_acordes(Pin, Pout).
accion_modif(Pin, Pout, 1) :- quita_acordes(Pin, Pout).
accion_modif(Pin, Pout, 2) :- cambia_acordes(Pin, Pout).*/

			%CAMBIA ACORDES
/**
* cambia_acordes(Po, Pd) a partir de la progresi�n origen Po se crea otra progresi�n destino Pd que es
* id�ntica a Po excepto porque se ha realizado 1 cambio de un acorde diat�nico!!! por otro de la misma funci�n tonal
* (elegido al azar y distinto) y que dura lo mismo (misma figura en la progresi�n). El acorde que ser�
* sustituido se elige al azar, teniendo todos los acordes comsiderados la misma probabilidad de ser elegidos
* PENDIENTE MANTENER EL RITMO ARM�NICO COMO INVARIANTE TB AQUI
* Pre!!! Po en forma normal ser�a recomendable
* Post: Pd est� en forma normal
* @param +Po progresi�n origen cumple es_progresion(Po)
* @param -Pd progresi�n destino cumple es_progresion(Po)
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

			%A�ADE ACORDES
/**
* aniade_acordes(Po, Pd) a partir de la progresi�n origen Po se crea otra progresi�n destino Pd que es
* id�ntica a  Po salvo porque se ha sustituido uno de sus acordes diat�nicos!!! por dos acordes, el primero
* del mismo cifrado del original pero durando la mitad y el segundo de la misma funci�n tonal que el original
* (elegido al azar y distinto) y durando tambi�n la mitad. El primero aparecer� siempre delante del segundo en
* la progresi�n. El acorde que ser� desdoblado se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser
* elegidos
* PENDIENTE MANTENER EL RITMO ARM�NICO COMO INVARIANTE TB AQUI
* Pre!!! Po en forma normal ser�a recomendable
* Post: Pd est� en forma normal
* @param +Po progresi�n origen cumple es_progresion(Po)
* @param -Pd progresi�n destino cumple es_progresion(Po)
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
* quita_acordes(Po,Pd) busca todas las parejas de acordes diat�nicos !!!adyacentes que tengan la misma funci�n tonal,
* elige una de �stas al azar asignando la misma probabilidad a cada pareja y sustituye a la pareja por otro
* acorde que dure mismo que la suma de las duraciones de las parejas y que tenga la misma funci�n tonal
* (elegido al azar y no necesariamente distinto). Si no es posible hacer esto pq no hay parejas adyacentes
* de misma funci�n tonal entonces devuelve en Pd la misma progresion Po
* PENDIENTE MANTENER EL RITMO ARM�NICO COMO INVARIANTE TB AQUI
* Pre!!! Lo en forma normal ser�a recomendable
* Post Ld est� en forma normal
* @param +Po progresi�n origen cumple es_progresion(Po)
* @param -Pd progresi�n destino cumple es_progresion(Po)
**/
quita_acordes(progresion(Lo), progresion(Ld)) :- quita_acordesLista(Lo, Ld).
quita_acordesLista([], []) :- !.
quita_acordesLista(Lo, Ld) :- busca_acordes_afines(Lo,LPos),dame_elemento_aleatorio(LPos, PosElegida),!
      ,nth(PosElegida, Lo, (Acord1, F1)), P2 is PosElegida + 1,nth(P2, Lo, (_, F2))
      ,dame_cuat_funcTonal_equiv2(Acord1, AcordSustituto), sumaFiguras(F1, F2, FigSustit)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 2 ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordSustituto, FigSustit)], Laux), append(Laux, LdB, Ld).
quita_acordesLista(Lo, Lo).
