

module TraduceCifrados
where

import Haskore
import Progresiones
import PrologAHaskell -- de aqui solo necesito el tipo AcordeOrdenado
import Ratio
import Ritmo

-----------------------------------------------------------

type AcordeSimple = [Int]

type Inversion = Int -- 0 es el estado fundamental
type Disposicion = Int


formarAcordeSimple :: Int -> Int -> Inversion -> Disposicion -> AcordeSimple
formarAcordeSimple numNotasFund numNotasTotal inv disp = reverse (disp : anade numNotasFund (numNotasTotal - 2) [inv + 1])


anade :: Int -> Int -> [Int] -> [Int]
anade _ 0 lista = lista
anade numNotasFund notasResto (nota : lista)
	|nota == numNotasFund 	= anade numNotasFund (notasResto - 1) (1 : nota : lista)
	|otherwise			= anade numNotasFund (notasResto - 1) ((nota + 1) : nota : lista)


---------------------------------------------------

traduceDirecto :: [PitchClass] -> AcordeSimple -> [PitchClass]
traduceDirecto lpc [] = []
traduceDirecto lpc (num : resto) = (lpc !! (num - 1)) : traduceDirecto lpc resto


arreglaOctavas :: Int -> [PitchClass] -> [Pitch]
arreglaOctavas octavaIni (cabeza : resto) = (cabeza, octavaIni) : arreglaOctavasRec octavaIni cabeza resto


arreglaOctavasRec :: Int -> PitchClass -> [PitchClass] -> [Pitch]
arreglaOctavasRec _ _ [] = []
arreglaOctavasRec octava pitchAnt (cabeza : resto) 
	|pitchClass pitchAnt >= pitchClass cabeza = (cabeza, octava + 1) : arreglaOctavasRec (octava + 1) cabeza resto
	|otherwise				 		= (cabeza, octava) : arreglaOctavasRec octava cabeza resto




-------------------------------------------------------



-- TODO: PASAR ESTO A PROGRESIONES.HS

-- Estas funciones, por supuesto, solo son posibles en el modo de C mayor
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

absPitchAPitchClass :: AbsPitch -> PitchClass
absPitchAPitchClass = fst.pitch

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
	Men7B5 -> [0,0,0,0]			-- mirarme este
	Maj7 -> [0,4,7,11]
	Sept -> [0,4,7,10]
	Men7 -> [0,3,7,10]
	MenMaj7 -> [0,3,7,11]
	Au7 -> [0,4,8,10]
	Dis7 -> [0,3,6,9]			--no se si este esta bien
	

-- traduce solo a estado fundamental
traduceCifrado :: Cifrado -> [PitchClass]
traduceCifrado (grado, matricula) = map  absPitchAPitchClass (sumaVector (matriculaAVector matricula) (gradoAInt grado))


---------------------------------------------------------------------------
-- USANDO SISTEMA PARALELO
---------------------------------------------------------------------------


-- Suponemos la octava 4 como octava inicial pero se podria cambiar
-- El int es el numero de notas deseadas
traduceInvDisp :: Inversion -> Disposicion -> Int -> Cifrado -> [Pitch]
traduceInvDisp inv disp numNotasTotal cifrado 
 = arreglaOctavas 4 (traduceDirecto cifradoTraducido (formarAcordeSimple (length cifradoTraducido) numNotasTotal inv disp))
		where cifradoTraducido = traduceCifrado cifrado

traduceInvDisp2 :: Inversion -> Disposicion -> Int -> (Cifrado, Dur) -> AcordeOrdenado
traduceInvDisp2 inv disp numNotasTotal (cifrado, dur) = (traduceInvDisp inv disp numNotasTotal cifrado , dur)


traduceProgresionSistemaParalelo :: Inversion -> Disposicion -> Int -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaParalelo inv disp numNotasTotal progresion 
	= map (traduceInvDisp2 inv disp numNotasTotal) progresion



progresion :: Progresion
progresion = [((I, Maj7),1%2),((IV, Maj7),1%2),((V, Sept),1%2),((I, Maj7),1%2)]

progresion2 :: Progresion
progresion2 = [	((I, Maj7),1%2) , ((V7 IV, Sept),1%2), ((IV, Maj7),1%2) , 
			((IIM7 (V7 V), Men7),1%2), ((V7 V, Sept),1%2), ((V, Sept),1%2) , ((I, Maj7),1%2)   ]

ejemplo :: [AcordeOrdenado]
ejemplo = traduceProgresionSistemaParalelo 0 4 4 progresion2


ejemplo2 :: Music
ejemplo2 = deAcordesOrdenadosAMusica ejemplo arpegio [(100,1%16)]




