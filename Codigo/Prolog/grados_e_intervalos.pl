%INTERVALOS SIMPLES
%usuales
es_interSimple(interSimple(G)) :- member(G, [i, bii, ii, biii, iii, iv, bv, v, auv, vi, bvii, vii]).
%raros
es_interSimple(interSimple(G)) :- member(G, [bbii, bbiii, auii, biv, auiii, auiv, bbvi, bvi, auvi, bviii, auviii ]).

%GRADOS
es_grado(grado(G)) :- es_interSimple(interSimple(G)).


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
