% comentarios: % o /* */
%BIBLIOTECAS
:- use_module(library(lists)).


%OPERADORES
%composicion secuencial (asocia a dcha)
:- op(100, xfy,[:+:]).
%composicion paralela (asocia a dcha)
:- op(101, xfy, [:=:]).

%MUSICA
musica(X) :- nota(X).
musica(X) :- silencio(X).
%composicion secuencial
musica(X :+: Y) :- musica(X), musica(Y).
%composicion paralela
musica(X :=: Y) :- musica(X), musica(Y).
%musica cuyo tempo se multiplica por F
musica(tempo(F, M)) :- fraccionNat(F), musica(M). 
%musica que se subida (traspuesta) el numero de semitonos E
musica(tras(E, M)) :- integer(E), musica(M).
%musica tocada con un instrumento determinado
musica(inst(I,M)) :- instrumento(I), musica(M).
	%CASOS BASE
nota(nota(A,F)):- altura(A), figura(F).
silencio(silencio(F)) :-figura(F).

%ALTURA TONAL
% la altura de una nota es su nombre y su octava 
altura(altura(N,O)) :- numNota(N), octava(O).
%la correspondencia es la=0, la#/sib=1, si=2, ...
numNota(numNota(N)) :- member(N,[0,1,2,3,4,5,6,7,8,9,10,11]).
%el numero de octavas que consideremos, este esta puesto al azar aqui
octava(octava(O)) :- member(O,[0,1,2,3,4,5,6]).

%FIGURAS
%una figura es una fracción, N es el numerador y D el denominador
figura(figura(N,D)) :- fraccionNat(N, D).
fraccionNat(N, D) :- natural(N), natural(D).
natural(N) :- integer(N), N>0.

%INSTRUMENTOS
instrumento(instrumento(N)) :- member(N, [mano_izquierda, bateria, mano_derecha, bajo]).