% comentarios: % o /* */
/*random(+Lower, +Upper, -Number)
Binds Number to a random integer in the interval [Lower,Upper) if Lower and
Upper are integers. Otherwise Number is bound to a random oat between
Lower and Upper. Upper will never be generated.
*/
%DECLARACION DEL MODULO
:- module(generador_acordes,[genera_acordes/2, haz_progresion/3]).

%BIBLIOTECAS
:- use_module(library(lists)).
:- use_module(library(random)).

%ARCHIVOS PROPIOS CONSULTADOS
:- use_module(representacion_prolog_haskore).
:- use_module(biblio_genaro_listas).
:- use_module(biblio_genaro_fracciones).
:- use_module(biblio_genaro_ES).
:- use_module(grados_e_intervalos).
:- use_module(figuras_y_ritmo).
/*
GENERADOR DE SECUENCIAS DE ACORDES A REDONDAS EN ESCALA DE DO JONICO

-en compas de 2 por 4 y posici�n de t�nica en primera disposicion
-pag 61: a�adir, cambiar y quitar acordes
-pag 64: colocacion de los acordes en la frase arm�nica
-poner lo del movimineto entre fundamentales pg 66
-pg 81 : bVII
-todo de cadenas
*/
fichero_destinoGenAc('C:/hlocal/acordes.txt').
/*genera_acordes(N, M) hace una progresion de N compases aprox y con M transformaciones
guarda el resultado en C:/hlocal/acordes.txt. Solo funciona si C:/hlocal existe 
*/
genera_acordes(N, M) :- haz_progresion(N, M, Prog), progresion_a_Haskore(Prog, Musica)
	,fichero_destinoGenAc(Dd), escribeTermino(Dd, Musica).


%CIFRADOS
es_cifrado(cifrado(G,M)) :- es_grado(G), es_matricula(M).
es_matricula(matricula(M)) :- member(M, [mayor,m,au,dis,6,m6,m7b5, maj7,7,m7,mMaj7,au7,dis7]).
%%MUY TEMPORAL, DECISIONES ARBITRARIAS POR AHORA en futuro argumento en cifrado_a_haskore podria
%decir inversion y disposicion
cifrado_a_Haskore((cifrado(Grado,Matricula), Figura), Musica) :- gradoAAltura(Grado,Altura)
	,hazAcordePosTonica(nota(Altura,Figura), Matricula, ListaNotas)
	,hazCompSecuencial(ListaNotas, Musica).
%FALTAN GRADOS NO USUALES!!!!!!!!!!!!!!!! es as� pq Do Jonico, octava arbitraria
gradoAAltura(grado(i), altura(numNota(3),octava(1))).
gradoAAltura(grado(bii), altura(numNota(4),octava(1))).
gradoAAltura(grado(ii), altura(numNota(5),octava(1))).
gradoAAltura(grado(biii), altura(numNota(6),octava(1))).
gradoAAltura(grado(iii), altura(numNota(7),octava(1))).
gradoAAltura(grado(iv), altura(numNota(8),octava(1))).
gradoAAltura(grado(bv), altura(numNota(9),octava(1))).
gradoAAltura(grado(v), altura(numNota(10),octava(1))).
gradoAAltura(grado(auv), altura(numNota(11),octava(1))).
gradoAAltura(grado(vi), altura(numNota(0),octava(2))).
gradoAAltura(grado(bvii), altura(numNota(1),octava(3))).
gradoAAltura(grado(vii), altura(numNota(2),octava(4))).

/*hazAcordePosTonica(Fundamental, Matricula, ListaNotas)
s�lo metidas las cuatriadas basicas, falta picar mas datos
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

/*numAcordes(P,N) indica el numero de acordes que hay en una progresi�n. Podemos definir que una progresi�n 
est� en forma normal cuando no existen dos acordes adyacentes en el tiempo/ lista que tengan el mismo cifrado.
 Por ejemplo la progresi�n [(C-7, 1/2), (C-7 , 1/2), (Amaj7,1/1)] quedar�a en forma normal como
[(C-7, 1/1), (Amaj7,1/1)]. Ser�a deseable que todas las progresiones generadas por haz_progresion y sus predicados
 auxiliares generaran progresiones en forma normal (estos comentarios hay q estructurarlos luego). numAcordes(P,N) 
da el numero de elementos de la lista ListaAcordes si la forma normal de p es progresion(ListaAcordes)
*/
numAcordes(progresion(Lc), N) :- numAcordesLista(Lc,ninguno,N).
/* numAcordesLista(Lc, Uc, N): Uc es el cifrado del acorde anterior*/
numAcordesLista([], _ ,0).
numAcordesLista([C|Cs], C, N) :- numAcordesLista(Cs, C, N).
numAcordesLista([C|Cs], Uc, N1) :- \+(C = Uc), numAcordesLista(Cs, C, N), N1 is N + 1.

/*numCompases(P,S) indica el numero de compases que dura una progresi�n
in: P que cumple es_progresion(P)
out: S natural que indica el numero de compases que ocupa la progresi�n. !!!En Sicstus el ceiling da el float igual
al menor entero mayor o igual q el float al q se aplica, e.d., ceiling(2.3) = 3.0 => estudiar en el futuro posible arreglo
 (restricciones?, ceiling propio dicotomico?, ...?) 
*/
numCompases(progresion(L),M) :- numCompasesLista(L, fraccion_nat(N,D)),
	M is ceiling(N/D).
numCompasesLista([], fraccion_nat(0,1)).
numCompasesLista([(_,figura(N,D))|Cs], F) :- numCompasesLista(Cs, Fl), 	sumarFracciones(fraccion_nat(N,D), Fl, F).
  

%GENERA UN PROGRESION DE ACORDES
/*haz_progresion(N, M, La)
in: N natural que indica el numero aproximado de compases que dura de la progresi�n. Me temo que tendr� que ser mayor o igual
    que 3 (longitud de la cadencia m�s larga)
    M natural que indica el numero de mutaciones que se realizaran para conseguir la progresion
out: La lista de acordes que ocupan N compases que se espera q se interpreten uno tras otro empezando por la cabeza.
     Hace cierto es_progresion(La)
*/
haz_progresion(N, M, La) :- natural(N), natural(M), haz_prog_semilla(S), fija_compases_aprox(S, N, Laux1),
 		modifica_prog(Laux1, M, La).

/*fija_compases_aprox(ProgSemilla, N, ProgResul). Partiendo de la progresion ProgSemilla construye otra 
progresion de longitud N (N compases) APROXIMADAMENTE
in: ProgSemilla progresi�n de partida (semilla). Cumple es_progresion(ProgSemilla)
    N numero de compases que tendra la progresion como minimo. Es un natural mayor o igual que el numero de
    acordes de ProgSemilla
out: ProgResul resultado de las transformaciones, Cumple es_progresion(ProgResul)
*/
fija_compases_aprox(ProgSemilla, N, ProgSemilla) :- numCompases(ProgSemilla, NumComp), NumComp >= N,!. 
fija_compases_aprox(ProgSemilla, N, ProgResul) :- aniade_acordes2(ProgSemilla, ProgAux)
		,fija_compases_aprox(ProgAux, N, ProgResul).

modifica_prog(Pin, M, Pin) :- M =< 0.
modifica_prog(Pin, M, Pout) :- accion_modif(Pin, Paux), M1 is M - 1, modifica_prog(Paux, M1, Pout).
num_acciones_modif(3).
accion_modif(Pin, Pout) :- num_acciones_modif(N), random(0, N, NumAccion), accion_modif(Pin, Pout, NumAccion).
accion_modif(Pin, Pout, 0) :- aniade_acordes(Pin, Pout).
accion_modif(Pin, Pout, 1) :- quita_acordes(Pin, Pout).
accion_modif(Pin, Pout, 2) :- cambia_acordes(Pin, Pout).

/* haz_prog_semilla(S)
crea una progresi�n que ser� de la que parta el resto de la generaci�n.En un principio me basar� en las cadencias as� 
que tendr� entre dos y tres acordes.
out: S de tipo progresion*/
haz_prog_semilla(S) :- num_cadencias(NumCads),random(0,NumCads, CadElegida)
	,cadenciaValida(cadencia(ListaGrados,CadElegida)),listaGradosAProgresion(ListaGrados,S).

/*listaGradosAProgresion(ListaGrados,Progresion).
convierte una lista de grados en una progresi�n de acordes en la que cada acorde dura una redonda. A cada grado le hace 
corresponder su cuatr�ada por ahora!!!
in: ListaGrados hace cierto el predicado es_listaDeGrados
out: Progresion hace cierto el predicado es_progresion
*/

/*listaGradosAProgresion([],progresion([])).
listaGradosAProgresion([G|Gs],progresion([(C, figura(1,1))|Ps])) :-
		hazCuatriada(G,C) ,listaGradosAProgresion(Gs,Ps).*/

listaGradosAProgresion(LG, progresion(Prog)) :- listaGradosAProgresionRec(LG,Prog).
listaGradosAProgresionRec([],[]).
listaGradosAProgresionRec([G|Gs],[(C, figura(1,1))|Ps]) :-
		hazCuatriada(G,C) ,listaGradosAProgresionRec(Gs,Ps).

%CAMBIA ACORDES
/* cambia_acordes(Po, Pd) a partir de la progresi�n origen Po se crea otra progresi�n destino Pd que es
id�ntica a Po excepto porque se ha realizado 1 cambio de un acorde por otro de la misma funci�n tonal 
(elegido al azar y distinto) y que dura lo mismo (misma figura en la progresi�n). El acorde que ser� 
sustituido se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser elegidos
in: Po progresi�n origen cumple es_progresion(Po)
out:Pd progresi�n destino cumple es_progresion(Po)
Pre!!! Po en forma normal ser�a recomendable
Post: Pd est� en forma normal */
cambia_acordes(progresion(Lo), progresion(Ld)) :- cambia_acordesLista(Lo, Ld).
cambia_acordesLista([], []) .
cambia_acordesLista(Lo, Ld) :- 
	dame_elemento_aleatorio(Lo, (AcordElegido, F), PosElegida)
      ,dame_cuat_funcTonal_equiv(AcordElegido, AcordSustituto)
 	,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1
      ,sublista_suf(Lo, PosElegMas, LdB)
      ,append(LdA, [(AcordSustituto, F)], Laux), append(Laux, LdB, Ld).

%A�ADE ACORDES
/* aniade_acordes(Po, Pd) a partir de la progresi�n origen Po se crea otra progresi�n destino Pd que es 
id�ntica a  Po salvo porque se ha sustituido uno de sus acordes por dos acordes, el primero del mismo cifrado
del original pero durando la mitad y el segundo de la misma funci�n tonal que el original (elegido al azar
y distinto) y durando tambi�n la mitad. El primero aparecer� siempre delante del segundo en la progresi�n. El
acorde que ser� desdoblado se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser
elegidos
in: Po progresi�n origen cumple es_progresion(Po)
out:Pd progresi�n destino cumple es_progresion(Po)
Pre!!! Lo en forma normal ser�a recomendable
Post Ld est� en forma normal
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

%A�ADE ACORDES2
/* aniade_acordes(Po, Pd) a partir de la progresi�n origen Po se crea otra progresi�n destino Pd que es 
id�ntica a  Po salvo porque se ha sustituido uno de sus acordes por dos acordes, el primero del mismo cifrado
del original y durando lo mismo y, el segundo de la misma funci�n tonal que el original (elegido al azar
y distinto) y durando lo mismo. El primero aparecer� siempre delante del segundo en la progresi�n. El
acorde que ser� desdoblado se elige al azar, teniendo todos los acordes de Po la misma probabilidad de ser
elegidos
in: Po progresi�n origen cumple es_progresion(Po)
out:Pd progresi�n destino cumple es_progresion(Po)
Pre!!! Lo en forma normal ser�a recomendable
Post Ld est� en forma normal
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
/* quita_acordes(Po,Pd) busca todas las parejas de acordes adyacentes que tengan la misma funci�n tonal,
elige una de �stas al azar asignando la misma probabilidad a cada pareja y sustituye a la pareja por otro
acorde que dure mismo que la suma de las duraciones de las parejas y que tenga la misma funci�n tonal 
(elegido al azar y no necesariamente distinto)(!!!!!!estudiar si no conviene m�s simplemente dejar el 
fuerte de la funci�n tonal, es decir, I, IV o V). Si no es posible hacer esto pq no hay parejas adyacentes
de misma funci�n tonal entonces devuelve en Pd la misma progresion Po
in: Po progresi�n origen cumple es_progresion(Po)
out:Pd progresi�n destino cumple es_progresion(Po)
Pre!!! Lo en forma normal ser�a recomendable
Post Ld est� en forma normal
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
tengan la misma funci�n tonal y sean adyacentes en la lista, y devuelve en Lpos la lista de posisiones dentro
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
/*funciona para grados*/
mismaFuncionTonal(G1,G2) :- dameFuncionTonal(G1, F), dameFuncionTonal(G2, F).
mismaFuncionTonalCifrado(G1,G2) :- dameFuncionTonalCifrado(G1, F), dameFuncionTonalCifrado(G2, F).

/*dameFuncionTonal(G, Ft): Ft es la funci�n tonal del grado G
in: G cumple es_grado(G)
out: Ft pertenece a {tonica, subdominante, dominante}
*/
dameFuncionTonal(grado(G), tonica) :- member(G, [i, iii, vi]).
dameFuncionTonal(grado(G), subdominante) :- member(G, [ii, iv]).
dameFuncionTonal(grado(G), dominante) :- member(G, [v, vii]).

/*dameFuncionTonalCifrado(C, Ft): Ft es la funci�n tonal del cifrado C
in: C cumple es_cifrado(C)
out: Ft pertenece a {tonica, subdominante, dominante}
*/
dameFuncionTonalCifrado(cifrado(G,_), Ft) :- dameFuncionTonal(G, Ft).

/*dame_grado_funcTonal_equiv(GradoOrigen, GradoDestino)
devuelve en GradoDestino un grado que tiene la misma funci�n tonal que GradoOrigen y que adem�s es distinto 
a este
in: GradoOrigen hace cierto es_grado(GradoOrigen)
out: GradoDestino hace cierto es_grado(GradoDestino)
*/
dame_grado_funcTonal_equiv(Go, Gd) :- setof(Gc,(mismaFuncionTonal(Go,Gc), \+(Gc = Go)), Lc)
                                    ,dame_elemento_aleatorio(Lc, Gd).

/*dame_grado_funcTonal_equiv2(GradoOrigen, GradoDestino)
devuelve en GradoDestino un grado que tiene la misma funci�n tonal que GradoOrigen y que no tiene 
por que ser distinto a GradoOrigen a este
in: GradoOrigen hace cierto es_grado(GradoOrigen)
out: GradoDestino hace cierto es_grado(GradoDestino)
*/
dame_grado_funcTonal_equiv2(Go, Gd) :- setof(Gc,mismaFuncionTonal(Go,Gc), Lc)
                                    ,dame_elemento_aleatorio(Lc, Gd).

/*dame_cuat_funcTonal_equiv(CifOri,CuatDest) 
devuelve en CuatDestino la cuatriada de un grado que tiene la misma funci�n tonal que el correspondiente a 
CifOrigen y que adem�s es distinto a este
in: CifOrigen hace cierto es_cifrado(CifOrigen)
out: CuatDestino hace cierto es_cifrado(CuatDestino)
*/
dame_cuat_funcTonal_equiv(cifrado(GradoElegido,_),CuatDest) :- dame_grado_funcTonal_equiv(GradoElegido, GradoSustituto)
			,hazCuatriada(GradoSustituto, CuatDest).

/*dame_cuat_funcTonal_equiv2(CifOri,CuatDest)
devuelve en CuatDestino la cuatriada de un grado que tiene la misma funci�n tonal que el correspondiente a 
CifOrigen y que no tiene por que ser distinto a este
in: CifOrigen hace cierto es_cifrado(CifOrigen)
out: CuatDestino hace cierto es_cifrado(CuatDestino)
*/
dame_cuat_funcTonal_equiv2(cifrado(GradoElegido,_),CuatDest) :- dame_grado_funcTonal_equiv2(GradoElegido, GradoSustituto)
			,hazCuatriada(GradoSustituto, CuatDest).


%CADENCIAS
/*es_cadencia(cadencia(C,I)) :- es_listaDeGrados(C), natural(I),num_cadencias(N),I<N.*/

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
/*cadencia([grado(iv),grado(iii)],4).			%plagal
cadencia([grado(iv),grado(vi)],5).			%plagal
cadencia([grado(ii),grado(i)],6).			%plagal
cadencia([grado(ii),grado(iii)],7).			%plagal
cadencia([grado(ii),grado(vi)],8).			%plagal
	%suspensivas
		%semicadencia: reposo en dominante??
		%rota
cadencia([grado(v),grado(iii)],9). 			
cadencia([grado(v),grado(vi)],10). 			
cadencia([grado(iv),grado(v),grado(iii)],11). 
cadencia([grado(iv),grado(v),grado(vi)],12).
cadencia([grado(ii),grado(v),grado(iii)],13). 	
cadencia([grado(ii),grado(v),grado(vi)],14).
num_cadencias(15). Asumibles por intercambio de acordes*/
num_cadencias(4).

/*hazCuatriada(G,C) 
in: G de tipo grado
out: C cifrado con la matr�cula de cuatr�ada correspondiente al grado G en la escala de C J�nico
por ahora 
*/
hazCuatriada(grado(G),cifrado(grado(G), matricula(maj7))) :- 	member(G,[i,iv,bvii]).
hazCuatriada(grado(G),cifrado(grado(G), matricula(m7))) :- member(G,[ii,iii,vi]).
hazCuatriada(grado(G),cifrado(grado(G), matricula(7))) :- member(G,[v]).
hazCuatriada(grado(G),cifrado(grado(G), matricula(m7b5))) :- member(G,[vii]).

					
