% comentarios: % o /* */
%BIBLIOTECAS
:- use_module(library(lists)).


%OPERADORES
%composicion secuencial (asocia a dcha)
:- op(100, xfy,[:+:]).
%composicion paralela (asocia a dcha)
:- op(101, xfy, [:=:]).


/*
GENARADOR DE SECUENCIAS DE ACORDES A REDONDAS EN ESCALA DE DO JONICO

-en compas de 2 por 4
-pag 61: añadir, cambiar y quitar acordes
-pag 64: colocacion de los acordes en la frase armónica
*/

natural(N) :- integer(N), N>0.

%ALTURA TONAL
% la altura de una nota es su nombre y su octava 
altura(altura(N,O)) :- numNota(N), octava(O).
%la correspondencia es la=0, la#/sib=1, si=2, ...
numNota(numNota(N)) :- member(N,[0,1,2,3,4,5,6,7,8,9,10,11]).
%el numero de octavas que consideremos, este esta puesto al azar aqui
octava(octava(O)) :- member(O,[0,1,2,3,4,5,6]).

%grados usuales
grado(grado(G)) :- member(G, [i, bii, ii, biii, iii, iv, bv, v, #v, vi, bvii, vii]).
%grados raritos
grado(grado(G)) :- member(G, [bbii, bbiii, #ii, biv, #iii, #iv, bbvi, bvi, #vi, bviii, #viii ]).

%intervalo: como par formado por un intervalo simple (q tiene los mismos nombres q un grado) y un natural
%que indica cuantas veces se ha salido de la octava: ej: 5º justa = intervalo(grado(v),0), 9ºmenor = intervalo(grado(bii),1)
%8ª = intervalo(grado(i),1)
intervalo(intervalo(G,O)) :- grado(G), natural(O).

es_tonica(grado(G)):- member(G, [i, iii, Vi]).
es_subdominante(grado(G)):- member(G, [ii, iV]).
es_dominante(grado(G)):- member(G, [v, Vii]).

%convierte una altura a una escala absoluta que empieza a contar desde el la de la octava 0, que es el cero
alturaAbsoluta(altura(numNota(N),octava(0)),N).
alturaAbsoluta(altura(numNota(N),octava(O)),A) :- O>0, O1 is O - 1, alturaAbsoluta(altura(numNota(N),octava(01)),A2)
						,A is A2 + 12.

%semitonosAIntervalo(S,I) : S es el numero (natural!!!!) de semitonos del intervalo I
%es biyectiva? pq sólo tiene en cuenta los grados usuales
semitonosAIntervalo(0, intervalo(grado(i),0)).
semitonosAIntervalo(1, intervalo(grado(bii),0)).
semitonosAIntervalo(2, intervalo(grado(ii),0)).
semitonosAIntervalo(3, intervalo(grado(biii),0)).
semitonosAIntervalo(4, intervalo(grado(iii),0)).
semitonosAIntervalo(5, intervalo(grado(iv),0)).
semitonosAIntervalo(6, intervalo(grado(bv),0)).
semitonosAIntervalo(7, intervalo(grado(v),0)).
semitonosAIntervalo(8, intervalo(grado(#v),0)).
semitonosAIntervalo(9, intervalo(grado(vi),0)).
semitonosAIntervalo(10, intervalo(grado(bvii),0)).
semitonosAIntervalo(11, intervalo(grado(vii),0)).

semitonosAIntervalo(S, intervalo(G,O)) :- S>11, S1 is s - 12, semitonosAIntervalo(S1, intervalo(G,O1))
					,O is O1 + 1.

%el intevalo entre dos alturas A1 y A2 se denota con el
dame_intevalo(A1, A2, intervalo(.....)) :- alturaAbsoluta(A1, AA1), alturaAbsoluta(A2, AA2), S is ver origen y destino
y negativos!!!!!!!!!!!!!!!!!!!!
					

poner lo del movimineto entre fundamentales pg 66