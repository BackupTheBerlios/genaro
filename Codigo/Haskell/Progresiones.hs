module Progresiones where
import Parsers
import Parser_library
import Haskore

{--
lo de Prolog

es_progresion(progresion(P)) :- es_listaDeCifrados(P).

es_listaDeCifrados([]).
es_listaDeCifrados([(C, F)|Cs]) :- es_cifrado(C), es_figura(F)
       ,es_listaDeCifrados(Cs).

es_cifrado(cifrado(G,M)) :- es_grado(G), es_matricula(M).
es_matricula(matricula(M)) :- member(M, [mayor,m,au,dis,6,m6,m7b5, maj7,7,m7,mMaj7,au7,dis7]).

es_interSimple(interSimple(G)) :- member(G, [i, bii, ii, biii, iii, iv, bv, v, auv, vi, bvii, vii]).
%raros
es_interSimple(interSimple(G)) :- member(G, [bbii, bbiii, auii, biv, auiii, auiv, bbvi, bvi, auvi, bviii, auviii ]).

%GRADOS
es_grado(grado(G)) :- es_interSimple(interSimple(G)).
es_grado(grado(v7 / G)) :- es_grado(grado(G)).
es_grado(grado(iim7 / G)) :- es_grado(grado(G)).

-}

data Grado = I|BII|II|BIII|III|IV|BV|V|AUV|VI|BVII|VII
             |BBII|BBIII|AUII|BIV|AUIII|AUIV|BBVI|BVI|AUVI|BVIII|AUVIII
             |BIX|IX|BX|X|BXI|XI|AUXI|BXII|XII|AUXII|BXIII|XIII|AUXIII
             |V7 Grado
             |IIM7 Grado
     deriving(Show,Eq,Ord)

data Matricula = Mayor|Menor|Au|Dis|Sexta|Men6|Men7B5|Maj7|Sept|Men7|MenMaj7|Au7|Dis7
     deriving(Enum,Read,Show,Eq,Ord,Bounded)

type Cifrado = (Grado, Matricula)

type Progresion = [(Cifrado, Dur)]

-- Estas funciones, por supuesto, solo tienen sentido en el modo de C mayor
gradoAInt :: Grado -> Int
gradoAInt (V7 grado) = mod (gradoAInt grado + 7) 12
gradoAInt (IIM7 grado) = mod (gradoAInt grado + 2) 12
gradoAInt grado = case grado of
	I -> 0
	II -> 2
	III -> 4
	IV -> 5
	V -> 7
	VI -> 9
	VII -> 11
	BII -> 1
	BIII -> 3
	BV -> 6
	AUV -> 8
	BVII -> 10
	BBII -> 1
	BBIII -> 2
	AUII -> 3
	BIV -> 4
	AUIII -> 5
	AUIV -> 10
	BBVI -> 7
	BVI -> 8
	AUVI -> 10
	BVIII -> 11
	AUVIII -> 13

-- Pasa de una altura cualquiera a su PitchClass. Ej: 0 -> C, 1 -> Cs, 12 -> C, 24 -> C
absPitchAPitchClass :: AbsPitch -> PitchClass
absPitchAPitchClass = fst.pitch

-- Pasa de un grado a su PitchClass tendiendo en cuenta que estamos en C mayor
gradoAPitchClass :: Grado -> PitchClass
gradoAPitchClass = absPitchAPitchClass.gradoAInt


-----------------------------------------------------------------------


type Vector = [Int]

sumaVector :: Vector -> Int -> Vector
sumaVector vector base = map (+ base) vector


matriculaAVector :: Matricula -> Vector
matriculaAVector m = case m of
	Mayor -> [0,4,7]
	Menor -> [0,3,7]
	Au -> [0,4,8]
	Dis -> [0,3,6]
	Sexta -> [0,4,7,9]
	Men6 -> [0,3,7,9]
	Men7B5 -> [0,3,6,10]
	Maj7 -> [0,4,7,11]
	Sept -> [0,4,7,10]
	Men7 -> [0,3,7,10]
	MenMaj7 -> [0,3,7,11]
	Au7 -> [0,4,8,10]
	Dis7 -> [0,3,6,9]


-- Dice cuantas notas diferentes tiene el acorde en funcion de su matricula
matriculaAInt :: Matricula -> Int
matriculaAInt m
	| elem m [Mayor, Menor] = 3
	| elem m [Au, Dis, Sexta, Men6, Men7B5, Maj7, Sept, Men7, MenMaj7, Au7, Dis7] = 4










