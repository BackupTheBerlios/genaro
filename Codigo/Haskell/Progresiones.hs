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

data Grado = I|BII|II|BIII|III|IV|BV|V|AUV|VI|BVII|VII|VIII
             |BBII|BBIII|AUII|BIV|AUIII|AUIV|BBVI|BVI|AUVI|BVIII|AUVIII
             |BIX|IX|BX|X|BXI|XI|AUXI|BXII|XII|AUXII|BXIII|XIII|AUXIII
             |V7 Grado
             |IIM7 Grado
     deriving(Show,Ord)

instance Eq Grado where
  g1 == g2 = (gradoAInt g1::Int) == (gradoAInt g2::Int)

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
	BBII -> 0
	BBIII -> 2
	AUII -> 3
	BIV -> 4
	AUIII -> 5
	AUIV -> 6
	BBVI -> 7
	BVI -> 8
	AUVI -> 10
	BVIII -> 11
        VIII -> 12
	AUVIII -> gradoAInt BII
        BIX -> gradoAInt BII
        IX -> gradoAInt II
        BX -> gradoAInt BIII
        X -> gradoAInt III
        BXI -> gradoAInt BIV
        XI -> gradoAInt IV
        AUXI -> gradoAInt AUIV
        BXII -> gradoAInt BV
        XII -> gradoAInt V
        AUXII -> gradoAInt AUV
        BXIII -> gradoAInt BVI
        XIII -> gradoAInt VI
        AUXIII -> gradoAInt AUVI


{-
Esta funcion solo tienen sentido en el modo de C mayor. Da un valor por defecto a
un AbsPitch

-}
absPitchAGrado :: Int -> Grado
absPitchAGrado absP
  | absP ==  0  = I
  | absP ==  1  = BII
  | absP ==  2  = II
  | absP ==  3  = BIII
  | absP ==  4  = III
  | absP ==  5  = IV
  | absP ==  6  = BV
  | absP ==  7  = V
  | absP ==  8  = AUV
  | absP ==  9  = VI
  | absP ==  10 = BVII
  | absP ==  11 = VII
  | absP >= 12  = absPitchAGrado (absP `mod` 12)
  | absP <0     = absPitchAGrado (absP `mod` 12)


{-Como gradoAInt pero sin el modulo-}
gradoAIntAbs :: Grado -> Int
gradoAIntAbs (V7 grado) = gradoAInt grado + 7
gradoAIntAbs (IIM7 grado) = gradoAInt grado + 2
gradoAIntAbs grado = case grado of
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
	AUIV -> 6
	BBVI -> 7
	BVI -> 8
	AUVI -> 10
	BVIII -> 11
        VIII -> 12
	AUVIII -> 13
        BIX -> 13
        IX -> 14
        BX -> 15
        X -> 16
        BXI -> 16
        XI -> 17
        AUXI -> 18
        BXII -> 18
        XII -> 19
        AUXII -> 20
        BXIII -> 20
        XIII -> 21
        AUXIII -> 22



-- Pasa de una altura cualquiera a su PitchClass. Ej: 0 -> C, 1 -> Cs, 12 -> C, 24 -> C
absPitchAPitchClass :: AbsPitch -> PitchClass
absPitchAPitchClass = fst.pitch

-- Pasa de un grado a su PitchClass tendiendo en cuenta que estamos en C mayor
gradoAPitchClass :: Grado -> PitchClass
gradoAPitchClass = absPitchAPitchClass.gradoAInt

gradoAPitchClassTonica :: PitchClass -> Grado -> PitchClass
gradoAPitchClassTonica tonica grado = fst (pitch ((gradoAInt grado) + absPitch (tonica,0)))

-----------------------------------------------------------------------


type Vector = [Int]

sumaVector :: Vector -> Int -> Vector
sumaVector vector base = map (+ base) vector


matriculaAVector :: Matricula -> Vector
matriculaAVector m = case m of
        -- Triadas
	Mayor -> [0,4,7]
	Menor -> [0,3,7]
	Au -> [0,4,8]
	Dis -> [0,3,6]
        -- Cuatriadas
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
matriculaAInt = length.matriculaAVector


{-
deCuatriadaATriada: dada una matricula de una cuatriada te la conviernte en una triada
-}
deCuatriadaATriada :: Matricula -> Matricula
deCuatriadaATriada m
    | elem m [Sexta, Maj7, Sept] = Mayor
    | elem m [Men6, Men7, MenMaj7] = Menor
    | elem m [Au7] = Au
    | elem m [Men7B5, Dis7] = Dis








