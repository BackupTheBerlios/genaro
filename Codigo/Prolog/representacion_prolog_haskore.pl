% comentarios: % o /* */
%BIBLIOTECAS
:- use_module(library(lists)).


%OPERADORES
%composicion secuencial (asocia a dcha)
:- op(100, xfy,[:+:]).
%composicion paralela (asocia a dcha)
:- op(101, xfy, [:=:]).

%MUSICA
es_musica(X) :- es_nota(X).
es_musica(X) :- es_silencio(X).
%composicion secuencial
es_musica(X :+: Y) :- es_musica(X), es_musica(Y).
%composicion paralela
es_musica(X :=: Y) :- es_musica(X), es_musica(Y).
%musica cuyo tempo se multiplica por F
es_musica(tempo(F, M)) :- es_fraccionNat(F), es_musica(M). 
%musica que se subida (traspuesta) el numero de semitonos E
es_musica(tras(E, M)) :- integer(E), es_musica(M).
%musica tocada con un instrumento determinado
es_musica(inst(I,M)) :- es_instrumento(I), es_musica(M).
	%CASOS BASE
es_nota(nota(A,F)):- es_altura(A), es_figura(F).
es_silencio(silencio(F)) :- es_figura(F).

%ALTURA TONAL
% la altura de una nota es su nombre y su octava 
es_altura(altura(N,O)) :- es_numNota(N), es_octava(O).
%la correspondencia es la=0, la#/sib=1, si=2, ...
es_numNota(numNota(N)) :- member(N,[0,1,2,3,4,5,6,7,8,9,10,11]).
%el numero de octavas que consideremos, este esta puesto al azar aqui
es_octava(octava(O)) :- member(O,[0,1,2,3,4,5,6]).

%FIGURAS
%una figura es una fracción, N es el numerador y D el denominador
es_figura(figura(N,D)) :- es_fraccionNat(N, D).
es_fraccionNat(N, D) :- natural(N), natural(D).
natural(N) :- integer(N), N>=0.

%INSTRUMENTOS
es_instrumento(instrumento(N)) :- member(N, [mano_izquierda, bateria, mano_derecha, bajo]).
