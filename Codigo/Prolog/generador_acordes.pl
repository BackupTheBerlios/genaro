% comentarios: % o /* */
/*random(+Lower, +Upper, -Number)
Binds Number to a random integer in the interval [Lower,Upper) if Lower and
Upper are integers. Otherwise Number is bound to a random oat between
Lower and Upper. Upper will never be generated.
*/
%BIBLIOTECAS
:- use_module(library(lists)).
:- use_module(library(random)).
%ARCHIVOS PROPIOS CONSULTADOS
:- consult(['representacion_prolog_haskore.pl']).
:- consult(['biblio_genaro_listas.pl']).
:- consult(['biblio_genaro_fracciones.pl']).
:- consult(['grados_e_intervalos.pl']).
:- consult(['figuras_y_ritmo.pl']).

/*
GENERADOR DE SECUENCIAS DE ACORDES A REDONDAS EN ESCALA DE DO JONICO

-en compas de 2 por 4 y posición de tónica en primera disposicion
-pag 61: añadir, cambiar y quitar acordes
-pag 64: colocacion de los acordes en la frase armónica
-poner lo del movimineto entre fundamentales pg 66
-pg 81 : bVII
-todo de cadenas
*/


%CIFRADOS
es_cifrado(cifrado(G,M)) :- es_grado(G), es_matricula(M).
es_matricula(matricula(M)) :- member(M, [mayor,m,au,dis,6,m6,m7b5, maj7,7,m7,mMaj7,au7,dis7]).

/*hazCuatriada(G,C) 
in: G de tipo grado
out: C cifrado con la matrícula de cuatríada correspondiente al grado G en la escala de C Jónico
por ahora 
*/
hazCuatriada(grado(G),cifrado(grado(G), matricula(maj7))) :- 	member(G,[i,iv,bvii]).
hazCuatriada(grado(G),cifrado(grado(G), matricula(m7))) :- member(G,[ii,iii,vi]).
hazCuatriada(grado(G),cifrado(grado(G), matricula(7))) :- member(G,[v]).
hazCuatriada(grado(G),cifrado(grado(G), matricula(m7b5))) :- member(G,[vii]).

%PROGRESION DE ACORDES
/*es una lista de cifrados*/
es_progresion(progresion(P)) :- es_listaDeCifrados(P).
es_listaDeCifrados([]).
es_listaDeCifrados([(C, F)|Cs]) :- es_cifrado(C), es_figura(F)
       ,es_listaDeCifrados(Cs).

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

/*numCompases(P,S) indica el numero de compases que dura una progresión
in: P que cumple es_progresion(P)
out: S natural que indica el numero de compases que ocupa la progresión. !!!En Sicstus el ceiling da el float igual
al menor entero mayor o igual q el float al q se aplica, e.d., ceiling(2.3) = 3.0 => estudiar en el futuro posible arreglo
 (restricciones?, ceiling propio dicotomico?, ...?) 
*/
numCompases(progresion(L),M) :- numCompasesLista(L, fraccion_nat(N,D)),
	M is ceiling(N/D).
numCompasesLista([], fraccion_nat(0,1)).
numCompasesLista([(_,figura(N,D))|Cs], F) :- numCompasesLista(Cs, Fl), 	sumaFracciones(fraccion_nat(N,D), Fl, F).
  

%GENERA UN PROGRESION DE ACORDES
/*haz_progresion(N,La)
in: N natural que indica el numero de compases que dura de la progresión. Me temo que tendrá que ser mayor o igual
    que 3 (longitud de la cadencia más larga)
out: La lista de acordes que ocupan N compases que se espera q se interpreten uno tras otro empezando por la cabeza.
     Hace cierto es_progresion(La)
*/
haz_progresion(N,La) :- haz_prog_semilla(S), modifica_prog(S,N,La).

/* haz_prog_semilla(S)
crea una progresión que será de la que parta el resto de la generación.En un principio me basaré en las cadencias así 
que tendrá entre dos y tres acordes.
out: S de tipo progresion*/
haz_prog_semilla(S) :- num_cadencias(NumCads),random(0,NumCads, CadElegida)
	,cadenciaValida(cadencia(ListaGrados,CadElegida)),listaGradosAProgresion(ListaGrados,S).

/*listaGradosAProgresion(ListaGrados,Progresion).
convierte una lista de grados en una progresión de acordes en la que cada acorde dura una redonda. A cada grado le hace 
corresponder su cuatríada por ahora!!!
in: ListaGrados hace cierto el predicado es_listaDeGrados
out: Progresion hace cierto el predicado es_progresion
*/

/*listaGradosAProgresion([],progresion([])).
listaGradosAProgresion([G|Gs],progresion([(C, figura(1,1))|Ps])) :-
		hazCuatriada(G,C) ,listaGradosAProgresion(Gs,Ps).*/

listaGradosAProgresion(LG, progresion(Prog)) :- 			listaGradosAProgresionRec(LG,Prog).
listaGradosAProgresionRec([],[]).
listaGradosAProgresionRec([G|Gs],[(C, figura(1,1))|Ps]) :-
		hazCuatriada(G,C) ,listaGradosAProgresionRec(Gs,Ps).


/*modifica_prog(S,N,La). Partiendo de la progresión S construye otra progresión de longitud N (N compases)
in: S progresión de partida (semilla). Cumple es_progresion(S)
    N numero de compases que tendrá la progresión. Es un natural mayor o igual que el numero de acordes de S
out: La resultado de las transformaciones, Cumple es_progresion(La)
*/
%modifica_prog(S,N,La) :- natural(N), numCompases(S,Ls), Ls <= N, ¿?? 

%CAMBIA ACORDES
/* cambia_acordes(Po, Pd) a partir de la progresión origen Po se crea otra progresión destino Pd que es idéntica a Po excepto
poruqe se ha realizado 1 cambio de un acorde por otro de la misma función tonal y que dura lo mismo (misma figura en la progresión)
in: Po progresión origen cumple es_progresion(Po)
out:Pd progresión destino cumple es_progresion(Po)
Pre!!! Po en forma normal sería recomendable
Post: Pd está en forma normal */
cambia_acordes(progresion(Lo), progresion(Ld)) :- cambia_acordesLista(Lo, Ld).
cambia_acordesLista([], []) .
cambia_acordesLista(Lo, Ld) :- 
	dame_elemento_aleatorio(Lo, (AcordElegido, F), PosElegida)
      ,dame_cuat_funcTonal_equiv(AcordElegido, AcordSustituto)
 	,sublista_pref(Lo, PosElegida, LdA), PosElegMas is PosElegida + 1, 
      sublista_suf(Lo, PosElegMas, LdB), 
      append(LdA, [(AcordSustituto, F)], Laux), append(Laux, LdB, Ld).

%AÑADE ACORDES
/* aniade_acordes(Po, Pd) a partir de la progresión origen Po se crea otra progresión destino Pd que es idéntica a  Po salvo porque se
ha sustituido una de sus acordes por dos acordes, el primero del mismo cifrado del original pero durando la mitad y el segundo de la misma 
función tonal que el original y durando también la mitad. El primero aparecerá siempre delante del segundo en la progresión
in: Po progresión origen cumple es_progresion(Po)
out:Pd progresión destino cumple es_progresion(Po)
Pre!!! Lo en forma normal sería recomendable
Post Ld está en forma normal
*/
/*aniade_acordes(progresion(Lo), progresion(Pd)) :- aniade_acordesLista(Lo, Ld).
aniade_acordesLista([], []).
aniade_acordesLista(Lo, Ld) :-
       dame_elemento_aleatorio(Lo, (AcordElegido, F), PosElegida)
      ,dame_cuat_funcTonal_equiv(AcordElegido, AcordAniadir)*/



%FUNCIONES TONALES
mismaFuncionTonal(G1,G2) :- dameFuncionTonal(G1, F), dameFuncionTonal(G2, F).

dameFuncionTonal(grado(G), tonica) :- member(G, [i, iii, vi]).
dameFuncionTonal(grado(G), subdominante) :- member(G, [ii, iv]).
dameFuncionTonal(grado(G), dominante) :- member(G, [v, vii]).

/*dame_grado_funcTonal_equiv(GradoOrigen, GradoDestino)*/
dame_grado_funcTonal_equiv(Go, Gd) :- setof(Gc,(mismaFuncionTonal(Go,Gc), \+(Gc = Go)), Lc),dame_elemento_aleatorio(Lc, Gd).

/*dame_cuat_funcTonal_equiv(CuatOri,CuatDest)*/
dame_cuat_funcTonal_equiv(cifrado(GradoElegido,_),CuatDest) :- dame_grado_funcTonal_equiv(GradoElegido, GradoSustituto)
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


					
