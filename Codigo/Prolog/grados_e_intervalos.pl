%DECLARACION DEL MODULO
:- module(grados_e_intervalos,[alturaAbsoluta/2
                              ,sumaSemitonos/3
                              ,semitonosAIntervalo/2
                              , dameIntervalo/3
                              , es_grado/1
                              ,es_intervalo/1
                              ,sumaIntervaloAGrado/3
                              ,gradoAAltura/2
                              ,gradoRelativoAAbsoluto/2
                              ,intervaloASemitonos/2]).

%BIBLIOTECAS
:- use_module(library(lists)).
:- use_module(biblio_genaro_acordes).

%INTERVALOS SIMPLES
%usuales
es_interSimple(interSimple(G)) :- member(G, [i, bii, ii, biii, iii, iv, bv, v, auv, vi, bvii, vii]).
%raros
es_interSimple(interSimple(G)) :- member(G, [bbii, bbiii, auii, biv, auiii, auiv, bbvi, bvi, auvi, bviii, auviii ]).

%GRADOS
es_grado(grado(G)) :- es_interSimple(interSimple(G)).
es_grado(grado(v7 / G)) :- es_grado(grado(G)).
es_grado(grado(iim7 / G)) :- es_grado(grado(G)).

/*intervalo: como par formado por un intervalo simple y un natural
que indica cuantas veces se ha salido de la octava: ej: 5� justa = intervalo(interSimple (v),0), 9�menor = intervalo(interSimple (bii),1)
8� = intervalo(interSimple (i),1)*/
es_intervalo(intervalo(G,O)) :- es_interSimple(G), natural(O).

/*convierte una altura a una escala absoluta que empieza a contar desde el la de la octava 0, que es el cero.
 S�lo funciona bien si alturaAbsoluta(A,N) tiene
 in=A tipo altura (cumple es_altura(A))
 out=N entero
*/
alturaAbsoluta(altura(numNota(N),octava(0)),N).
alturaAbsoluta(altura(numNota(N),octava(O)),A) :- O>0, O1 is O - 1, alturaAbsoluta(altura(numNota(N),octava(O1)),A2)
						,A is A2 + 12.
alturaAbsoluta(altura(numNota(N),octava(O)),A) :- O<0, O1 is O + 1, alturaAbsoluta(altura(numNota(N),octava(O1)),A2)
						,A is A2 - 12.

/*alturaAbsAAltura(N,A)
  Realiza la conversion opuesta a alturaAbsoluta(A,N)
  in: N entero
  out: A de tipo altura (cumple es_altura(A))
*/
alturaAbsAAltura(N, altura(numNota(N),octava(0))) :- N>=0, N<12.
alturaAbsAAltura(N, altura(numNota(M),octava(O1))):- N>=12, N1 is N - 12
	,alturaAbsAAltura(N1, altura(numNota(M),octava(O))), O1 is O + 1.
alturaAbsAAltura(N, altura(numNota(M),octava(O1))):- N<0, N1 is N + 12
	,alturaAbsAAltura(N1, altura(numNota(M),octava(O))), O1 is O - 1.

/*sumaSemitonos(Ae, N, As)
  Calcula en As la altura resultado de sumar N semitonos a la altura Ae
 in: Ae cumple es_altura(Ae)
     N es un entero
 out:As cumple es_altura(As)
*/
sumaSemitonos(Ae, N, As) :- alturaAbsoluta(Ae, Ne), Ns is N + Ne, alturaAbsAAltura(Ns, As).


/**
* sumaIntervaloAGrado(Gi, Ii, Gs) calcula en Gs el grado resultado de moverse el intervalos Ii a partir
* del grado Gi
* @param +Gi cumple es_grado(Gi)
* @param +Ii cumple es_intervalo(Ii)
* @param -Gs cumple es_grado(Gs)
*/
sumaIntervaloAGrado(Gi, Ii, Gs) :- gradoAAltura(Gi, Ai), intervaloASemitonos(Ii, Si)
			,trasponer(Ai, Si, As), alturaAGrado(As, Gs).
/**
* gradoRelativoAAbsoluto(Gi, Go) Go es un grado equivalente a Gi pero sin la notacion relativa debida
* a v7/g o iim7/G
* @param +Gi cumple es_grado(Gi)
* @param +Go cumple es_grado(Go)
*/
gradoRelativoAAbsoluto(grado(v7 / G), Go) :-
            !,gradoRelativoAAbsoluto(grado(G), Gaux),sumaIntervaloAGrado(Gaux, intervalo(interSimple(v),0), Go).
gradoRelativoAAbsoluto(grado(iim7 / G), Go) :-
            !,gradoRelativoAAbsoluto(grado(G), Gaux),sumaIntervaloAGrado(Gaux, intervalo(interSimple(ii),0), Go).
gradoRelativoAAbsoluto(Gi, Gi).

/**
* S�lamente para uso interno en este m�dulo, gradoAAltura(G,A) hace una correspondencia arbitraria entre
* grados y alturas s�lo para cuentas internas
* @param +G cumple es_grado(G)
* @param -A cumple es_altura(A)
* */
gradoAAltura(grado(i), altura(numNota(3),octava(0))).
gradoAAltura(grado(bii), altura(numNota(4),octava(0))).
gradoAAltura(grado(ii), altura(numNota(5),octava(0))).
gradoAAltura(grado(biii), altura(numNota(6),octava(0))).
gradoAAltura(grado(iii), altura(numNota(7),octava(0))).
gradoAAltura(grado(iv), altura(numNota(8),octava(0))).
gradoAAltura(grado(bv), altura(numNota(9),octava(0))).
gradoAAltura(grado(v), altura(numNota(10),octava(0))).
gradoAAltura(grado(auv), altura(numNota(11),octava(0))).
gradoAAltura(grado(vi), altura(numNota(0),octava(0))).
gradoAAltura(grado(bvii), altura(numNota(1),octava(0))).
gradoAAltura(grado(vii), altura(numNota(2),octava(0))).
gradoAAltura(grado(v7 / G), A) :- gradoAAltura(grado(G), A1), trasponer(A1, 7, A).
gradoAAltura(grado(iim7 / G), A) :- gradoAAltura(grado(G), A1), trasponer(A1, 2, A).

/**
* S�lamente para uso interno en este m�dulo, alturaAGrado(A,G) hace una correspondencia arbitraria entre
* grados y alturas s�lo para cuentas internas
* @param +A cumple es_altura(A)
* @param -G cumple es_grado(G)
* */
alturaAGrado(altura(numNota(3),_), grado(i)).
alturaAGrado(altura(numNota(4),_), grado(bii)).
alturaAGrado(altura(numNota(5),_), grado(ii)).
alturaAGrado(altura(numNota(6),_), grado(biii)).
alturaAGrado(altura(numNota(7),_), grado(iii)).
alturaAGrado(altura(numNota(8),_), grado(iv)).
alturaAGrado(altura(numNota(9),_), grado(bv)).
alturaAGrado(altura(numNota(10),_), grado(v)).
alturaAGrado(altura(numNota(11),_), grado(auv)).
alturaAGrado(altura(numNota(0),_), grado(vi)).
alturaAGrado(altura(numNota(1),_), grado(bvii)).
alturaAGrado(altura(numNota(2),_), grado(vii)).

/**
* intervaloASemitonos(I,S) devuelve en S el numero de semitonos q comprende el intervalo I
* @param +I cumple es_intervalo(I)
* @param -S es un natural
*/
intervaloASemitonos(intervalo(interSimple(i),0),0).
intervaloASemitonos(intervalo(interSimple(bii),0),1).
intervaloASemitonos(intervalo(interSimple(ii),0),2).
intervaloASemitonos(intervalo(interSimple(biii),0),3).
intervaloASemitonos(intervalo(interSimple(iii),0),4).
intervaloASemitonos(intervalo(interSimple(iv),0),5).
intervaloASemitonos(intervalo(interSimple(bv),0),6).
intervaloASemitonos(intervalo(interSimple(v),0),7).
intervaloASemitonos(intervalo(interSimple(auv),0),8).
intervaloASemitonos(intervalo(interSimple(vi),0),9).
intervaloASemitonos(intervalo(interSimple(bvii),0),10).
intervaloASemitonos(intervalo(interSimple(vii),0),11).
intervaloASemitonos(intervalo(Is,N),S) :- N>0, N1 is N - 1
		, intervaloASemitonos(intervalo(Is,N1),S1), S is S1 + 12.

/*semitonosAIntervalo(S,I) : S es el numero (natural!!!!) de semitonos del intervalo I
-es biyectiva? pq s�lo tiene en cuenta los intervalos simples usuales
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
semitonosAIntervalo(8, intervalo(interSimple(auv),0)).
semitonosAIntervalo(9, intervalo(interSimple(vi),0)).
semitonosAIntervalo(10, intervalo(interSimple(bvii),0)).
semitonosAIntervalo(11, intervalo(interSimple(vii),0)).
semitonosAIntervalo(S, intervalo(G,O)) :- S>11, S1 is S - 12, 	semitonosAIntervalo(S1, intervalo(G,O1)),O is O1 + 1.

/*el intervalo entre dos alturas A1 y A2 se obtiene con dameIntervalo(A1, A2,I).
In =  A1 tipo altura (cumple es_altura(A))
	A2 de tipo altura (cumple es_altura(A))
Out = I intervalo entre ambos
Funciona para A1 m�s bajo q A2 y viceversa
*/
dameIntervalo(A1, A2, I) :- alturaAbsoluta(A1, AA1),alturaAbsoluta(A2, AA2),
					 IA is AA2 - AA1,	semitonosAIntervalo(IA,I),!.
dameIntervalo(A1, A2, I) :- dameIntervalo(A2, A1, I).
