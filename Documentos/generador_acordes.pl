% comentarios: % o /* */
%BIBLIOTECAS
:- use_module(library(lists)).


%OPERADORES
%composicion secuencial (asocia a dcha)
:- op(100, xfy,[:+:]).
%composicion paralela (asocia a dcha)
:- op(101, xfy, [:=:]).


/*
GENERADOR DE SECUENCIAS DE ACORDES A REDONDAS EN ESCALA DE DO JONICO

-en compas de 2 por 4 y posición de tónica en primera disposicion
-pag 61: añadir, cambiar y quitar acordes
-pag 64: colocacion de los acordes en la frase armónica
-poner lo del movimineto entre fundamentales pg 66
-pg 81 : bVII
-todo de cadenas
*/

natural(N) :- integer(N), N>0.

%ALTURA TONAL
% la altura de una nota es su nombre y su octava 
es_altura(altura(N,O)) :- es_numNota(N), es_octava(O).
%la correspondencia es la=0, las/sib=1, si=2, ...
es_numNota(numNota(N)) :- member(N,[0,1,2,3,4,5,6,7,8,9,10,11]).
%el numero de octavas que consideremos, este esta puesto al azar aqui
es_octava(octava(O)) :- member(O,[0,1,2,3,4,5,6]).

%INTERVALOS SIMPLES
%usuales
es_interSimple(interSimple(G)) :- member(G, [i, bii, ii, biii, iii, iv, bv, v, auv, vi, bvii, vii]).
%raros
es_interSimple(interSimple(G)) :- member(G, [bbii, bbiii, auii, biv, auiii, auiv, bbvi, bvi, auvi, bviii, auviii ]).

%GRADOS
es_grado(grado(G)) :- es_interSimple(interSimple(G)).

%CIFRADOS
es_cifrado(cifrado(G,M)) :- es_grado(G), es_matricula(M).
es_matricula(matricula(M)) :- member(M, [mayor,m,au,dis,6,m6,m7b5, maj7,7,m7,mMaj7,au7,dis7]).

/*hazCuatriada(G,C) 
in: G de tipo grado
out: C cifrado con la matrícula de cuatríada correspondiente al grado G en la escala de C Jónico
por ahora 
*/
hazCuatriada(G,cifrado(G,maj7)) :- member(G,[i,iv,bvii]).
hazCuatriada(G,cifrado(G,m7)) :- member(G,[ii,iii,vi]).
hazCuatriada(G,cifrado(G,7)) :- member(G,[v]).
hazCuatriada(G,cifrado(G,m7b5)) :- member(G,[vii]).


%PROGRESION DE ACORDES
/*es una lista de cifrados*/
es_progresion(progresion(P)) :- es_listaDeCifrados(P).
es_listaDeCifrados([]).
es_listaDeCifrados([C|Cs]) :- es_cifrado(C), es_listaDeCifrados(Cs).

%FUNCIONES TONALES
es_tonica(grado(G)):- member(G, [i, iii, vi]).
es_subdominante(grado(G)):- member(G, [ii, iv]).
es_dominante(grado(G)):- member(G, [v, vii]).

%CADENCIAS
es_cadencia(cadencia(C,I)) :- es_listaDeGrados(C), natural(I), 			 		 		num_cadencias(N),I<N.

es_listaDeGrados([]).
es_listaDeGrados([G|Gs]) :- es_grado(G), es_listaDeGrados(Gs).
%lista de cadencias
	%conclusivas
		%autentica
cadencia([grado(v),grado(i)],0). 			%autentica basica
cadencia([grado(iv),grado(v),grado(i)],1). 	%autentica 
cadencia([grado(ii),grado(v),grado(i)],2). 	%autentica moderna
		%plagal
cadencia([grado(iv),grado(i)],3).			%plagal basica
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





/*intervalo: como par formado por un intervalo simple y un natural
que indica cuantas veces se ha salido de la octava: ej: 5º justa = intervalo(interSimple (v),0), 9ºmenor = intervalo(interSimple (bii),1)
8ª = intervalo(interSimple (i),1)*/
es_intervalo(intervalo(G,O)) :- es_interSimple(G), natural(O).

/*convierte una altura a una escala absoluta que empieza a contar desde el la de la octava 0, que es el cero. Sólo funciona bien si alturaAbsoluta(A,N) tiene in=A tipo altura
out=N natural
*/
alturaAbsoluta(altura(numNota(N),octava(0)),N).
alturaAbsoluta(altura(numNota(N),octava(O)),A) :- O>0, O1 is O - 1, alturaAbsoluta(altura(numNota(N),octava(O1)),A2)
						,A is A2 + 12.

/*semitonosAIntervalo(S,I) : S es el numero (natural!!!!) de semitonos del intervalo I
-es biyectiva? pq sólo tiene en cuenta los intervalos simples usuales
-solo funiona bien con 
	in=S natural q indica un numero de semitonos
	out=I	tipo intervalo correpondiente
*/
semitonosAIntervalo(0, intervalo(interSimple(i),0)).
semitonosAIntervalo(1, intervalo(interSimple(bii),0)).
semitonosAIntervalo(2, intervalo(interSimple(ii),0)).
semitonosAIntervalo(3, intervalo(interSimple(biii),0)).
semitonosAIntervalo(4, intervalo(interSimple(iii),0)).
semitonosAIntervalo(5, intervalo(interSimple(iv),0)).
semitonosAIntervalo(6, intervalo(interSimple(bv),0)).
semitonosAIntervalo(7, intervalo(interSimple(v),0)).
semitonosAIntervalo(8, intervalo(interSimple(sv),0)).
semitonosAIntervalo(9, intervalo(interSimple(vi),0)).
semitonosAIntervalo(10, intervalo(interSimple(bvii),0)).
semitonosAIntervalo(11, intervalo(interSimple(vii),0)).

semitonosAIntervalo(S, intervalo(G,O)) :- S>11, S1 is S - 12, 	semitonosAIntervalo(S1, intervalo(G,O1)),O is O1 + 1.

/*el intervalo entre dos alturas A1 y A2 se obtiene con dameIntervalo(A1, A2,I). 
In =  A1 tipo altura
	A2 de tipo altura
Out = I intervalo entre ambos
Funciona para A1 más bajo q A2 y viceversa
*/
dameIntervalo(A1, A2, I) :- alturaAbsoluta(A1, AA1),alturaAbsoluta(A2, AA2),
					 IA is AA2 - AA1,	semitonosAIntervalo(IA,I),!.
dameIntervalo(A1, A2, I) :- dameIntervalo(A2, A1, I).

					
