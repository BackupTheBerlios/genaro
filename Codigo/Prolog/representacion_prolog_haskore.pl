
:- module(representacion_prolog_haskore,[
	es_musica/1,
	es_nota/1,
	es_silencio/1,
	es_altura/1,
	es_numNota/1,
	es_octava/1,
	es_figura/1
]).

/* Modulos de Prolog */
:- use_module(library(lists)).

/* Modulos propios */
:- use_module(biblio_genaro_fracciones).

/* Operadores infijos*/
/* composicion secuencial (asocia a dcha) */
:- op(100, xfy,[:+:]).
/* composicion paralela (asocia a dcha) */
:- op(101, xfy, [:=:]).

/**
* es_musica(+M)
* Definicion de la estructura Musica. Esta estructura es una imitacion del tipo Music de Haskore de Paul Hudak
* realizada en Haskell. Una musica es:
* una nota: cumple es_nota(M)
* un silencio: cumple es_silencio(M)
* M1 :+: M2 : cumplen es_musica(M1), es_musica(M2)
* M1 :=: M2 : cumplen es_musica(M1), es_musica(M2)
* tempo((Num, Den), M) : cumplen es_musica(M), es_fraccionNat(Num,Den)
* tras(Ent,M) : cumplen es_musica(M), integer(Ent)
* inst(Ins, M) : cumplen es_musica(M), es_instrumento(Ins)
* @param +M una musica
*/
es_musica(X) :- 
	es_nota(X).
es_musica(X) :- 
	es_silencio(X).
%composicion secuencial
es_musica(X :+: Y) :- 
	es_musica(X), 
	es_musica(Y).
%composicion paralela
es_musica(X :=: Y) :- 
	es_musica(X), 
	es_musica(Y).
%musica cuyo tempo se multiplica por F
es_musica(tempo((N, D),M)) :- 
	es_fraccionNat(N,D), 
	es_musica(M).
%musica que se subida (traspuesta) el numero de semitonos E
es_musica(tras(E,M)) :- 
	integer(E), 
	es_musica(M).
%musica tocada con un instrumento determinado
es_musica(inst(I,M)) :- 
	es_instrumento(I), 
	es_musica(M).

/**
* es_nota(+Nota)
* Definicion de la estructura Nota. Basicamente es una pareja formada por el functor nota/2 con una altura
* y una figura
* @param +Nota una nota
*/
es_nota(nota(A,F)):- es_altura(A), es_figura(F).

/**
* es_silencio(+Silencio)
* Definicion de la estructura Silencio. Basicamente es una figura con el functor silencio.
* @param +Silencio un silencio
*/
es_silencio(silencio(F)) :- es_figura(F).


/**
* es_altura(+Altura)
* Definicion de la estructura altura. Basicamente es una pareja formada por el functor altura/2 con un numNota
* y una octava
* @param +Altura una altura
*/
es_altura(altura(N,O)) :- 
	es_numNota(N), 
	es_octava(O).

/**
* es_numNota(+NumNota)
* Definicion de la estructura numNota. Representa uno de los 12 sonidos de la octava. Basicamente es un numero 
* del 0 al 11 (ambos incluidos) con el functor numNota/1.
* La correspondencia es La = 0, La# =1 , y asi.
* @param +NumNota una nota de la octava
*/
es_numNota(numNota(N)) :- 
	member(N , [0,1,2,3,4,5,6,7,8,9,10,11]).

/**
* es_octava(+Octava)
* Definicion de la estructura octava. Basicamente es un numero con la constructora octava/1. Solo vamos a considerad
* las octavas de 0 a 6-
* @param +Octava una octava
*/
es_octava(octava(O)) :- member(O,[0,1,2,3,4,5,6]).

/**
* es_figura(+Figura)
* Definicion de la estructura figura. Basicamente consisten en el functor figura/2 con dos naturales.
* @param +Figura una figura
*/
es_figura(figura(N,D)) :- 
	es_fraccionNat(N, D).

/**
* es_fraccionNat(+Num, +Den)
* Definicion de la estructura fraccionNat. Basicamente consisten en dos naturales que representan el numerador y el 
* denominador de la fraccion.
* @param +Num un natura
* @param +Den otro natura
*/
es_fraccionNat(N, D) :- 
	natural(N), 
	natural(D).

/**
* es_instrumento(+Instrumento)
* Definicion de la estructura instrumento. Basicamente consisten en el functor instrumento/1 cuyo termino puede
* ser un elemento del conjunto { mano_izquierda, bateria, mano_derecha, bajo }. Estos son los unicos intrumentos
* que vamos a considerar
* @param +Instrumento un instrumento que puede ser mano_izquierda, bateria, mano_derecha o bajo
*/
es_instrumento(instrumento(N)) :- 
	member(N, [mano_izquierda, bateria, mano_derecha, bajo]).








