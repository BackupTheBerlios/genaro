% comentarios: % o /* */
/*random(+Lower, +Upper, -Number)
Binds Number to a random integer in the interval [Lower,Upper) if Lower and
Upper are integers. Otherwise Number is bound to a random oat between
Lower and Upper. Upper will never be generated.
*/
%DECLARACION DEL MODULO
/*:- module(generador_acordes,[
			               	, genera_acordes/2
			   				, genera_acordes/3
                            , genera_acordes/0
                            , haz_progresion/4]).*/
:- module(generador_acordes).

%BIBLIOTECAS
:- use_module(library(lists)).
:- use_module(library(random)).
:- use_module(generador_notas_del_acorde_con_sistema_paralelo).
:- use_module(generador_notas_del_acorde_con_continuidad_armonica).

%ARCHIVOS PROPIOS CONSULTADOS
:- use_module(representacion_prolog_haskore).
:- use_module(biblio_genaro_listas).
:- use_module(biblio_genaro_fracciones).
:- use_module(biblio_genaro_ES).
:- use_module(grados_e_intervalos).
:- use_module(figuras_y_ritmo).
/*
GENERADOR DE SECUENCIAS DE ACORDES A REDONDAS EN ESCALA DE DO JONICO

-en compas de 2 por 4 y posición de tónica en primera disposicion
-pag 61: añadir, cambiar y quitar acordes
-pag 64: colocacion de los acordes en la frase armónica
-poner lo del movimineto entre fundamentales pg 66
-pg 81 : bVII
-todo de cadenas
*/
fichero_destinoGenAc('C:/hlocal/acordes.txt').
fichero_destinoCifrados('C:/hlocal/cifrados.txt').
%Muy provisional
genera_acordes :- genera_acordes(6,3).
/*genera_acordes(N, M) hace una progresion de N compases aprox y con M transformaciones
guarda el resultado en C:/hlocal/acordes.txt. Solo funciona si C:/hlocal existe
*/
genera_acordes(N, M) :- random(1, 3, E), genera_acordes(N, M, E).

genera_acordes(N,M, paralelo) :- random(1, 3, E), genera_acordes(N, M, paralelo, E).
genera_acordes(N,M, continuidad) :- random(1, 3, E), genera_acordes(N, M, continuidad, E).

genera_acordes(N, M, Tipo) :- haz_progresion(N, M, Tipo, Prog), fichero_destinoCifrados(Df), escribeTermino(Df, Prog)
        , progresion_a_Haskore(Prog, Musica), fichero_destinoGenAc(Dd), escribeTermino(Dd, Musica).

genera_acordes(N,M, paralelo, Tipo) :- haz_progresion(N, M, Tipo, Prog), fichero_destinoCifrados(Df), escribeTermino(Df, Prog)
        ,generador_notas_del_acorde_con_sistema_paralelo:traduce_lista_cifrados(Prog,100,0,100,0,0,Lista)
        ,fichero_destinoGenAc(Dd), escribeTermino(Dd, Lista).

genera_acordes(N,M, continuidad, Tipo) :- haz_progresion(N, M, Tipo, Prog), fichero_destinoCifrados(Df), escribeTermino(Df, Prog)
        ,generador_notas_del_acorde_con_continuidad_armonica:traduce_lista_cifrados(Prog,Lista)
        ,fichero_destinoGenAc(Dd), escribeTermino(Dd, Lista).


%CIFRADOS
es_cifrado(cifrado(G,M)) :- es_grado(G), es_matricula(M).
es_matricula(matricula(M)) :- member(M, [mayor,m,au,dis,6,m6,m7b5, maj7,7,m7,mMaj7,au7,dis7]).
%%MUY TEMPORAL, DECISIONES ARBITRARIAS POR AHORA en futuro argumento en cifrado_a_haskore podria
%decir inversion y disposicion
cifrado_a_Haskore((cifrado(Grado,Matricula), Figura), Musica) :- gradoAAltura2(Grado,Altura)
	,hazAcordePosTonica(nota(Altura,Figura), Matricula, ListaNotas)
	,hazCompSecuencial(ListaNotas, Musica).
%FALTAN GRADOS NO USUALES!!!!!!!!!!!!!!!! es así pq Do Jonico, octava arbitraria
gradoAAltura2(grado(i), altura(numNota(3),octava(4))).
gradoAAltura2(grado(bii), altura(numNota(4),octava(4))).
gradoAAltura2(grado(ii), altura(numNota(5),octava(4))).
gradoAAltura2(grado(biii), altura(numNota(6),octava(4))).
gradoAAltura2(grado(iii), altura(numNota(7),octava(4))).
gradoAAltura2(grado(iv), altura(numNota(8),octava(4))).
gradoAAltura2(grado(bv), altura(numNota(9),octava(4))).
gradoAAltura2(grado(v), altura(numNota(10),octava(4))).
gradoAAltura2(grado(auv), altura(numNota(11),octava(4))).
gradoAAltura2(grado(vi), altura(numNota(0),octava(5))).
gradoAAltura2(grado(bvii), altura(numNota(1),octava(5))).
gradoAAltura2(grado(vii), altura(numNota(2),octava(5))).

/*hazAcordePosTonica(Fundamental, Matricula, ListaNotas)
sólo metidas las cuatriadas basicas, falta picar mas datos
la duracion de las notas es la de la fundamental entre el numero de notas del acorde
*/
/*hazAcordePosTonica(nota(A, F), _, [nota(A,F4)]):-
	divideFigura(F,4,F4).*/
hazAcordePosTonica(nota(A, F), matricula(maj7), [nota(A,F4), nota(Ter,F4), nota(Qui,F4), nota(Sept,F4)]):-
	divideFigura(F,4,F4) ,sumaSemitonos(A, 4, Ter),sumaSemitonos(A, 7, Qui),sumaSemitonos(A, 11, Sept).
hazAcordePosTonica(nota(A, F), matricula(m7), [nota(A,F4), nota(Ter,F4), nota(Qui,F4), nota(Sept,F4)]):-
	divideFigura(F,4,F4) ,sumaSemitonos(A, 3, Ter),sumaSemitonos(A, 7, Qui),sumaSemitonos(A, 10, Sept).
hazAcordePosTonica(nota(A, F), matricula(7), [nota(A,F4), nota(Ter,F4), nota(Qui,F4), nota(Sept,F4)]):-
	divideFigura(F,4,F4) ,sumaSemitonos(A, 4, Ter),sumaSemitonos(A, 7, Qui),sumaSemitonos(A, 10, Sept).
hazAcordePosTonica(nota(A, F), matricula(m7b5), [nota(A,F4), nota(Ter,F4), nota(Qui,F4), nota(Sept,F4)]):-
	divideFigura(F,4,F4) ,sumaSemitonos(A, 3, Ter),sumaSemitonos(A, 6, Qui),sumaSemitonos(A, 10, Sept).
hazAcordePosTonica(nota(A, F), matricula(m6), [nota(A,F4), nota(Ter,F4), nota(Qui,F4), nota(Sept,F4)]):-
	divideFigura(F,4,F4) ,sumaSemitonos(A, 3, Ter),sumaSemitonos(A, 7, Qui),sumaSemitonos(A, 9, Sept).


/*hazCompSecuencial(ListaNotas, Musica)*/
hazCompSecuencial([],silencio(figura(0,1))).
hazCompSecuencial([Mus|Ms], Mus :+: MusLis) :- hazCompSecuencial(Ms, MusLis).
%PROGRESION DE ACORDES
/*es una lista de cifrados*/
es_progresion(progresion(P)) :- es_listaDeCifrados(P).
es_listaDeCifrados([]).
es_listaDeCifrados([(C, F)|Cs]) :- es_cifrado(C), es_figura(F)
       ,es_listaDeCifrados(Cs).

/*progresion_a_Haskore(Prog, Musica)
convierte la presion de acordes a la representacion de musica de estilo haskore. Provisionalmente
se intentara pasar a arpegios ascendentes Fu-3-5-7
in: Prog cumple es_progresion(Prog)
out: Musica cumple es_musica(Musica)
*/
progresion_a_Haskore(progresion(LisCif), Musica) :- prog_a_HaskoreLista(LisCif, Musica).
prog_a_HaskoreLista([],silencio(figura(0,1))).
prog_a_HaskoreLista([Cif|Lcif], MusCif :+: MusLis) :- cifrado_a_Haskore(Cif, MusCif)
	, prog_a_HaskoreLista(Lcif, MusLis).

/*numAcordes(P,N) indica el numero de acordes que hay en una progresión. Podemos definir que una progresión
está en forma normal cuando no existen dos acordes adyacentes en el tiempo/ lista que tengan el mismo cifrado.
 Por ejemplo la progresión [(C-7, 1/2), (C-7 , 1/2), (Amaj7,1/1)] quedaría en forma normal como
[(C-7, 1/1), (Amaj7,1/1)]. Sería deseable que todas las progresiones generadas por haz_progresion y sus predicados
 auxiliares generaran progresiones en forma normal (estos comentarios hay q estructurarlos luego). numAcordes(P,N)
da el numero de elementos de la lista ListaAcordes si la forma normal de p es progresion(ListaAcordes)
*/
numAcordes(progresion(Lc), N) :- numAcordesLista(Lc,ninguno,N).
/* numAcordesLista(Lc, Uc, N): Uc es el cifrado del acorde anterior*/
numAcordesLista([], _ ,0).
numAcordesLista([C|Cs], C, N) :- numAcordesLista(Cs, C, N).
numAcordesLista([C|Cs], Uc, N1) :- \+(C = Uc), numAcordesLista(Cs, C, N), N1 is N + 1.

/**
* numCompases(P,S) indica en S el numero de compases que dura la progresión P
* @param +P que cumple es_progresion(P)
* @param -S float que indica el numero de compases que ocupa la progresión P
*/
numCompases(progresion(L),M) :- numCompasesLista(L, fraccion_nat(N,D)), M is N/D.
numCompasesLista([], fraccion_nat(0,1)).
numCompasesLista([(_,figura(N,D))|Cs], F) :- numCompasesLista(Cs, Fl), 	sumarFracciones(fraccion_nat(N,D), Fl, F).

/**
* numCompases(P,SN,SD) indica en SN/SD el numero de compases que dura la progresión P
* @param +P que cumple es_progresion(P)
* @param -SN natural que es el numerador de la fraccion que indica numero de compases que ocupa la progresión P
* @param -SD float que es el denominador de la fraccion que indica el numero de compases que ocupa la progresión P
*/
numCompases(progresion(L),N,D) :- numCompasesLista(L, fraccion_nat(N,D)).


%GENERA UN PROGRESION DE ACORDES
/**haz_progresion(N, M, Tipo, La)
* @param +N natural que indica el numero aproximado de compases que dura de la progresión. Me temo que tendrá que ser mayor o igual
*    que 3 (longitud de la cadencia más larga)
* @param +M natural que indica el numero de mutaciones que se realizaran para conseguir la progresion
* @param +Tipo indica si se utilizará haz_prog_semilla 1 o 2
* @param -La lista de acordes que ocupan N compases que se espera q se interpreten uno tras otro empezando por la cabeza.
*     Hace cierto es_progresion(La)
*/
haz_progresion(N, M, Tipo, progresion(La)) :- natural(N), natural(M), haz_prog_semilla(Tipo, S), fija_compases_aprox(S, N, Laux1)
 		,modifica_prog(Laux1, M, Laux2), asegura_ritmo_armonico(Laux2, Laux3), quita_grados_relativos(Laux3, progresion(Laux4))
                ,haz_prog_semilla(1,progresion(Pfin)), append(Laux4, Pfin, La).

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


modifica_prog(Pin, M, Pin) :- M =< 0.
modifica_prog(Pin, M, Pout) :- accion_modif(Pin, Paux), M1 is M - 1, modifica_prog(Paux, M1, Pout).
num_acciones_modif(3).
accion_modif(Pin, Pout) :- num_acciones_modif(N), random(0, N, NumAccion), accion_modif(Pin, Pout, NumAccion).
accion_modif(Pin, Pout, 0) :- aniade_acordes(Pin, Pout).
accion_modif(Pin, Pout, 1) :- quita_acordes(Pin, Pout).
accion_modif(Pin, Pout, 2) :- cambia_acordes(Pin, Pout).

/**
* haz_prog_semilla(Tipo,S) devuelve en S una progresion pequeña usada en el principio de la generación.
* @param +Tipo si vale 1 S será una cadencia o patron de acordes, si vale 2 entonces S se generará de forma pseudoaleatoria
* @param -S cumple es_progresion(S)
* */
haz_prog_semilla(1,S) :- haz_prog_semilla1(S).
haz_prog_semilla(2,S) :- haz_prog_semilla2(S).

/**
* haz_prog_semilla1(S). Devuelve en S una progresion que se usa para empezar la generación de la progresión entera. Esta progresion
* de salida es una cadencia o un patrón de acordes (ver es_patron_acordes/1 y es_cadencia/1)
* @param -S cumple es_progresion(S)
* */
haz_prog_semilla1(S) :- setof(Lg1, cadenciaValida(cadencia(Lg1,_)), Lc1)
        ,setof(Lg2, patAcordesVal(patAcord(Lg2,_)), Lc2), append(Lc1,Lc2,Lc)
	,dame_elemento_aleatorio(Lc, ListaGrados),listaGradosAProgresion(ListaGrados,S).

/*listaGradosAProgresion(ListaGrados,Progresion).
convierte una lista de grados en una progresión de acordes en la que cada acorde dura una redonda. A cada grado le hace
corresponder su cuatríada por ahora!!!
in: ListaGrados hace cierto el predicado es_listaDeGrados
out: Progresion hace cierto el predicado es_progresion
*/
listaGradosAProgresion(LG, progresion(Prog)) :- listaGradosAProgresionRec(LG,Prog).
listaGradosAProgresionRec([],[]).
listaGradosAProgresionRec([G|Gs],[(C, figura(1,1))|Ps]) :-
		hazCuatriada(G,C) ,listaGradosAProgresionRec(Gs,Ps).

%CAMBIA ACORDES
/* cambia_acordes(Po, Pd) a partir de la progresión origen Po se crea otra progresión destino Pd que es
idéntica a Po excepto porque se ha realizado 1 cambio de un acorde por otro de la misma función tonal
(elegido al azar y distinto) y que dura lo mismo (misma figura en la progresión). El acorde que será
sustituido se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser elegidos
in: Po progresión origen cumple es_progresion(Po)
out:Pd progresión destino cumple es_progresion(Po)
Pre!!! Po en forma normal sería recomendable
Post: Pd está en forma normal */
cambia_acordes(progresion(Lo), progresion(Ld)) :- cambia_acordesLista(Lo, Ld).
cambia_acordesLista([], []) .
cambia_acordesLista(Lo, Ld) :-
	dame_elemento_aleatorio(Lo, (AcordElegido, F), PosElegida)
      ,dame_cuat_funcTonal_equiv(AcordElegido, AcordSustituto)
 	,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
      ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordSustituto, F)], Laux), append(Laux, LdB, Ld).

%AÑADE ACORDES
/* aniade_acordes(Po, Pd) a partir de la progresión origen Po se crea otra progresión destino Pd que es
idéntica a  Po salvo porque se ha sustituido uno de sus acordes por dos acordes, el primero del mismo cifrado
del original pero durando la mitad y el segundo de la misma función tonal que el original (elegido al azar
y distinto) y durando también la mitad. El primero aparecerá siempre delante del segundo en la progresión. El
acorde que será desdoblado se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser
elegidos
in: Po progresión origen cumple es_progresion(Po)
out:Pd progresión destino cumple es_progresion(Po)
Pre!!! Lo en forma normal sería recomendable
Post Ld está en forma normal
*/
aniade_acordes(progresion(Lo), progresion(Ld)) :- aniade_acordesLista(Lo, Ld).
aniade_acordesLista([], []).
aniade_acordesLista(Lo, Ld) :-
       dame_elemento_aleatorio(Lo, (AcordElegido, F), PosElegida)
      ,dame_cuat_funcTonal_equiv(AcordElegido, AcordAniadir)
      ,divideFigura(F, 2, Fmed)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
      ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordElegido, Fmed),(AcordAniadir, Fmed)], Laux), append(Laux, LdB, Ld).

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
buscaCandidatosADominanteSec([(cifrado(grado(i),_), _)|Li], Lo) :- !,buscaCandidatosADominanteSecAcu(Li, 2, Lo).
buscaCandidatosADominanteSec([(cifrado(grado(G),M), F)|Li], [(cifrado(grado(G),M), F, 1)|Lo])
	:-!,buscaCandidatosADominanteSecAcu(Li, 2, Lo).
/**
* buscaCandidatosADominanteSec(Li, Lo): Procesa la procesion especificada en Li para devolver en Lo una lista de trios (C, F, Pos)
* en la que C es un cifrado, F una figura y Pos es una posicion dentro de Li. Estos trios corresponden a los acordes a los que se
* les puede añadir un dominante secundario por delante de ellos, esto es, aquellos que no son acordes del primer grado y a los que
* no se les ha añadido ya un dominante secundario
* @param +Li cumple es_progresion(progresion(Li))
* @param -Lo es una lista de trios (C, F, Pos) que cumplen es_cifrado(C), es_figura(F) y donde Pos es un natural que pertenece al
* intervalo [1, length(Li)] que indica la posicion de (C, F) dentro de Li
*/
buscaCandidatosADominanteSecAcu([], _, []).
buscaCandidatosADominanteSecAcu([_],_,[]).%pq _ ya se habría examinado
% buscaCandidatosADominanteSecAcu(Li, PosActual, Lo)
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
	setof((cifrado(grado(Gaux),matricula(M)), Faux, Pos)
	  ,(member((cifrado(grado(Gaux),matricula(M)), Faux), Lo)
	    ,nth(Pos, Lo, (cifrado(grado(Gaux),matricula(M)), Faux))
	    ,member(Gaux,[v, v7 /_])), Lc)
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


%QUITA GRADOS RELATIVOS
/**
* quita_grados_relativos(Po, Pd) Pd es una progresion equivalente a Po en la que se han eliminado las referencias indirectas
* a grados causadas por v7/G y iim7/G
* @param +Po cumple es_progresion(Po)
* @param -Pd cumple es_progresion(Pd)
* */
quita_grados_relativos(progresion(Po), progresion(Pd)) :- quita_grados_relativos_lista(Po, Pd).
quita_grados_relativos_lista([], []).
quita_grados_relativos_lista([(cifrado(Gi,M), F)|Li], [(cifrado(Go,M), F)|Lo]):-
               gradoRelativoAAbsoluto(Gi, Go),quita_grados_relativos_lista(Li, Lo).

%AÑADE ACORDES2
/* aniade_acordes(Po, Pd) a partir de la progresión origen Po se crea otra progresión destino Pd que es
idéntica a  Po salvo porque se ha sustituido uno de sus acordes por dos acordes, el primero del mismo cifrado
del original y durando lo mismo y, el segundo de la misma función tonal que el original (elegido al azar
y distinto) y durando lo mismo. El primero aparecerá siempre delante del segundo en la progresión. El
acorde que será desdoblado se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser
elegidos
in: Po progresión origen cumple es_progresion(Po)
out:Pd progresión destino cumple es_progresion(Po)
Pre!!! Lo en forma normal sería recomendable
Post Ld está en forma normal
*/
aniade_acordes2(progresion(Lo), progresion(Ld)) :- aniade_acordesLista2(Lo, Ld).
aniade_acordesLista2([], []).
aniade_acordesLista2(Lo, Ld) :-
       dame_elemento_aleatorio(Lo, (AcordElegido, F), PosElegida)
      ,dame_cuat_funcTonal_equiv(AcordElegido, AcordAniadir)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
      ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordElegido, F),(AcordAniadir, F)], Laux), append(Laux, LdB, Ld).

%QUITA ACORDES
/* quita_acordes(Po,Pd) busca todas las parejas de acordes adyacentes que tengan la misma función tonal,
elige una de éstas al azar asignando la misma probabilidad a cada pareja y sustituye a la pareja por otro
acorde que dure mismo que la suma de las duraciones de las parejas y que tenga la misma función tonal
(elegido al azar y no necesariamente distinto)(!!!!!!estudiar si no conviene más simplemente dejar el
fuerte de la función tonal, es decir, I, IV o V). Si no es posible hacer esto pq no hay parejas adyacentes
de misma función tonal entonces devuelve en Pd la misma progresion Po
in: Po progresión origen cumple es_progresion(Po)
out:Pd progresión destino cumple es_progresion(Po)
Pre!!! Lo en forma normal sería recomendable
Post Ld está en forma normal
*/
quita_acordes(progresion(Lo), progresion(Ld)) :- quita_acordesLista(Lo, Ld).
quita_acordesLista([], []) :- !.
quita_acordesLista(Lo, Ld) :- busca_acordes_afines(Lo,LPos),dame_elemento_aleatorio(LPos, PosElegida),!
      ,nth(PosElegida, Lo, (Acord1, F1)), P2 is PosElegida + 1,nth(P2, Lo, (_, F2))
      ,dame_cuat_funcTonal_equiv2(Acord1, AcordSustituto), sumaFiguras(F1, F2, FigSustit)
      ,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 2 ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordSustituto, FigSustit)], Laux), append(Laux, LdB, Ld).
quita_acordesLista(Lo, Lo).

/*busca_acordes_afines(Lacords, Lpos) busca en la lista de cifrados Lacords parejas de acordes tales que
tengan la misma función tonal y sean adyacentes en la lista, y devuelve en Lpos la lista de posisiones dentro
de Lacords (nunerando empezando por 1) de los primeros elementos de dichas parejas, es decir que se cumple
setof( Pos, (  nth( Pos,Lacords,(A1,_) ), PosS is Pos + 1, nth( PosS,Lacords,(A2,_) ),
mismaFuncionTonalCifrado(A1, A2)  ), Lpos).
in: Lacords cumple es_listaDeCifrados(Lacords)
out: Lpos es una lista de enteros que pertenecen al intervalo [1,longitud de Lacords)
*/
busca_acordes_afines(Lacords, Lpos):-busca_acordes_afines_acu(Lacords, 1, ninguno, Lpos).
/*busca_acordes_afines_acu(Lacords, PosActual, AcordeAnterior, Lpos)
*/
busca_acordes_afines_acu([], _, _, []).
busca_acordes_afines_acu([(AcAct,_)|La], PosAct, AcAnterior, [PosAniadir|Lp]):-
	mismaFuncionTonalCifrado(AcAct, AcAnterior),!, PosAniadir is PosAct - 1, PosSig is PosAct + 1
	,busca_acordes_afines_acu(La, PosSig, AcAct, Lp).

busca_acordes_afines_acu([(AcAct,_)|La], PosAct, _, Lp):-
	 PosSig is PosAct + 1,busca_acordes_afines_acu(La, PosSig, AcAct, Lp).


%FUNCIONES TONALES

/**
* menosEstable(F1,F2) se cumple si la función tonal F1 es menos estable que la funcion tonal F2
* @param +F1 pertenece a {tonica, subdominante, dominante}
* @param +F2 pertenece a {tonica, subdominante, dominante}
*/
menosEstable(dominante,tonica).
menosEstable(dominante,subdominante).
menosEstable(subdominante,tonica).

/*funciona para grados*/
mismaFuncionTonal(G1,G2) :- dameFuncionTonal(G1, F), dameFuncionTonal(G2, F).
mismaFuncionTonalCifrado(G1,G2) :- dameFuncionTonalCifrado(G1, F), dameFuncionTonalCifrado(G2, F).

/*dameFuncionTonal(G, Ft): Ft es la función tonal del grado G
in: G cumple es_grado(G)
out: Ft pertenece a {tonica, subdominante, dominante}
*/
dameFuncionTonal(grado(G), tonica) :- member(G, [i, iii, vi]).
dameFuncionTonal(grado(G), subdominante) :- member(G, [ii, iv]).
dameFuncionTonal(grado(iim7 / _), subdominante).
dameFuncionTonal(grado(G), dominante) :- member(G, [v, vii]).
dameFuncionTonal(grado(v7 / _), dominante).

/*dameFuncionTonalCifrado(C, Ft): Ft es la función tonal del cifrado C
in: C cumple es_cifrado(C)
out: Ft pertenece a {tonica, subdominante, dominante}
*/
dameFuncionTonalCifrado(cifrado(G,_), Ft) :- dameFuncionTonal(G, Ft).

/*dame_grado_funcTonal_equiv(GradoOrigen, GradoDestino)
devuelve en GradoDestino un grado diatónico!!! que tiene la misma función tonal que GradoOrigen y que además es distinto
a este
in: GradoOrigen hace cierto es_grado(GradoOrigen)
out: GradoDestino hace cierto es_grado(GradoDestino)
*/
dame_grado_funcTonal_equiv(Go, Gd) :- setof(Gc,(mismaFuncionTonal(Go,Gc), \+(Gc = Go)
											, \+(Gc = grado(v7 / _))
											, \+(Gc = grado(iim7 / _))
											), Lc)
                                    ,dame_elemento_aleatorio(Lc, Gd).

/*dame_grado_funcTonal_equiv2(GradoOrigen, GradoDestino)
devuelve en GradoDestino un grado diatónico!!! que tiene la misma función tonal que GradoOrigen y que no tiene
por que ser distinto a GradoOrigen a este
in: GradoOrigen hace cierto es_grado(GradoOrigen)
out: GradoDestino hace cierto es_grado(GradoDestino)
*/
dame_grado_funcTonal_equiv2(Go, Gd) :- setof(Gc,(mismaFuncionTonal(Go,Gc)
											, \+(Gc = grado(v7 / _))
											, \+(Gc = grado(iim7 / _))
											), Lc)
                                    ,dame_elemento_aleatorio(Lc, Gd).

/*dame_cuat_funcTonal_equiv(CifOri,CuatDest)
devuelve en CuatDestino la cuatriada de un grado que tiene la misma función tonal que el correspondiente a
CifOrigen y que además es distinto a este
in: CifOrigen hace cierto es_cifrado(CifOrigen)
out: CuatDestino hace cierto es_cifrado(CuatDestino)
*/
dame_cuat_funcTonal_equiv(cifrado(GradoElegido,_),CuatDest) :- dame_grado_funcTonal_equiv(GradoElegido, GradoSustituto)
			,hazCuatriada(GradoSustituto, CuatDest).

/*dame_cuat_funcTonal_equiv2(CifOri,CuatDest)
devuelve en CuatDestino la cuatriada de un grado que tiene la misma función tonal que el correspondiente a
CifOrigen y que no tiene por que ser distinto a este
in: CifOrigen hace cierto es_cifrado(CifOrigen)
out: CuatDestino hace cierto es_cifrado(CuatDestino)
*/
dame_cuat_funcTonal_equiv2(cifrado(GradoElegido,_),CuatDest) :- dame_grado_funcTonal_equiv2(GradoElegido, GradoSustituto)
			,hazCuatriada(GradoSustituto, CuatDest).


%CADENCIAS
es_cadencia(cadencia(C,I)) :- es_listaDeGrados(C), natural(I),num_cadencias(N),I<N.

es_listaDeGrados([]).
es_listaDeGrados([G|Gs]) :- es_grado(G), es_listaDeGrados(Gs).
%lista de cadencias
	%conclusivas
		%autentica
cadenciaValida(cadencia([grado(v),grado(i)],0)).%autentica basica
cadenciaValida(cadencia([grado(iv),grado(v),grado(i)],1)).	%autentica
cadenciaValida(cadencia([grado(ii),grado(v),grado(i)],2)).	%autentica moderna
		%plagal
cadenciaValida(cadencia([grado(iv),grado(i)],3)).			%plagal basica
cadenciaValida(cadencia([grado(iv),grado(iii)],4)).			%plagal
cadenciaValida(cadencia([grado(iv),grado(vi)],5)).			%plagal
cadenciaValida(cadencia([grado(ii),grado(i)],6)).			%plagal
cadenciaValida(cadencia([grado(ii),grado(iii)],7)).			%plagal
cadenciaValida(cadencia([grado(ii),grado(vi)],8)).			%plagal
	%suspensivas
		%semicadencia: reposo en dominante??
		%rota
cadenciaValida(cadencia([grado(v),grado(iii)],9)).
cadenciaValida(cadencia([grado(v),grado(vi)],10)).
cadenciaValida(cadencia([grado(iv),grado(v),grado(iii)],11)).
cadenciaValida(cadencia([grado(iv),grado(v),grado(vi)],12)).
cadenciaValida(cadencia([grado(ii),grado(v),grado(iii)],13)).
cadenciaValida(cadencia([grado(ii),grado(v),grado(vi)],14)).
num_cadencias(15).
/*No asumo las cadencias como cambios de las cadencias básicas pq entonces no estoy
contando bien el numero de mutaciones q hago a la progresion*/


%PATRONES DE ACORDES
es_patron_acordes(patAcord(C,I)) :- es_listaDeGrados(C), natural(I),num_patrones_acordes(N),I<N.
patAcordesVal(patAcord([grado(i),grado(vi),grado(ii),grado(v)],0)).
patAcordesVal(patAcord([grado(i),grado(v7 / v),grado(ii),grado(v)],1)).
patAcordesVal(patAcord([grado(i),grado(v7 / ii),grado(ii),grado(v)],2)).
patAcordesVal(patAcord([grado(i),grado(v7 / iv),grado(iv),grado(ivm6)],3)).
num_patrones_acordes(4).
%num_patrones_acordes(3).

/*hazCuatriada(G,C)
in: G de tipo grado
out: C cifrado con la matrícula de cuatríada correspondiente al grado G en la escala de C Jónico
por ahora
*/
hazCuatriada(grado(v7 / G), cifrado(grado(v7 / G), matricula(7))) :- !.
hazCuatriada(grado(iim7 / G), cifrado(grado(iim7 / G), matricula(m7))) :- !.
hazCuatriada(grado(ivm6), cifrado(grado(iv), matricula(m6))) :- !.
hazCuatriada(grado(G),cifrado(grado(G), matricula(maj7))) :- 	member(G,[i,iv,bvii]),!.
hazCuatriada(grado(G),cifrado(grado(G), matricula(m7))) :- member(G,[ii,iii,vi]),!.
hazCuatriada(grado(G),cifrado(grado(G), matricula(7))) :- member(G,[v]),!.
hazCuatriada(grado(G),cifrado(grado(G), matricula(m7b5))) :- member(G,[vii]),!.




/*****************************************************************************************
	CODIGO DE ROBERTO PARA UNA PRUEBA DE HAZ_PROG_SEMILLA2
*****************************************************************************************/

% No tengo el numero de acordes que tengo que generar, supongo 4

haz_prog_semilla2(S) :-
	genera_grados_aleatoriamente(LG1),
	arregla_lista_grados(LG1,LG2),
	listaGradosAProgresion(LG2, S).


% genera 4 grados totalmente aleatorios

genera_grados_aleatoriamente([A,B,C,D]) :-
	random(0,7,NA), entero_a_grado(NA, A),
	random(0,7,NB), entero_a_grado(NB, B),
	random(0,7,NC), entero_a_grado(NC, C),
	random(0,7,ND), entero_a_grado(ND, D).


% de numero a grado

entero_a_grado(0,grado(i)).
entero_a_grado(1,grado(ii)).
entero_a_grado(2,grado(iii)).
entero_a_grado(3,grado(iv)).
entero_a_grado(4,grado(v)).
entero_a_grado(5,grado(vi)).
entero_a_grado(6,grado(vii)).

% Añade un grado con funcion de tonica despues del de dominante

arregla_lista_grados([],[]) :-
	!.
arregla_lista_grados([G1],[G1,G2]) :-
	dameFuncionTonal(G1, dominante),
	!,
	dame_grado_de_tonica(G2).
arregla_lista_grados([G],[G]) :-
	!.
arregla_lista_grados([ G1, G2 | Resto ], [ G1 | RestoArreglao] ) :-
	dameFuncionTonal( G1, dominante ),
	dameFuncionTonal( G2, tonica ),
	!,
	arregla_lista_grados( [G2 | Resto], RestoArreglao ).
arregla_lista_grados([ G1, G2 | Resto ], [ G1, GT | RestoArreglao] ) :-
	dameFuncionTonal( G1, dominante ),
	!,
	dame_grado_de_tonica(GT),
	arregla_lista_grados( [ G2 | Resto], RestoArreglao ).
arregla_lista_grados([ G1, G2 | Resto ], [ G1 | RestoArreglao] ) :-
	arregla_lista_grados( [ G2 | Resto], RestoArreglao ).



% devuelve un grado que es de tonica

entero_a_tonica(0,grado(i)).
entero_a_tonica(1,grado(iii)).
entero_a_tonica(2,grado(vi)).

dame_grado_de_tonica(GT) :-
	random(0,3,Num),
	entero_a_tonica(Num,GT).



/*

ejemplo1 :-
	arregla_lista_grados([grado(vii),grado(vii),grado(v),grado(v)], L),
	write(L).
ejemplo2 :-
	arregla_lista_grados([grado(v)], L),
	write(L).
ejemplo3 :-
	arregla_lista_grados([grado(v),grado(i)], L),
	write(L).
ejemplo4 :-
	arregla_lista_grados([grado(v),grado(i),grado(vi),grado(vii)], L),
	write(L).

*/










