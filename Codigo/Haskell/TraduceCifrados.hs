
module TraduceCifrados
where

import Haskore
import Progresiones
import PrologAHaskell -- de aqui solo necesito el tipo AcordeOrdenado
import Ratio
import Ritmo -- este solo para hacer pruebas
import Random

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
	
-- Dice cuantas notas diferentes tiene el acorde en funcion de su matricula
matriculaAInt :: Matricula -> Int
matriculaAInt m 
	| elem m [Mayor, Menor] = 3
	| elem m [Au, Dis, Sexta, Men6, Men7B5, Maj7, Sept, Men7, MenMaj7, Au7, Dis7] = 4 


-- traduce solo a estado fundamental
traduceCifrado :: Cifrado -> [PitchClass]
traduceCifrado (grado, matricula) = map  absPitchAPitchClass (sumaVector (matriculaAVector matricula) (gradoAInt grado))


---------------------------------------------------------------------------
-- USANDO SISTEMA PARALELO
---------------------------------------------------------------------------


-- Suponemos la octava 4 como octava inicial pero se podria cambiar
-- El int es el numero de notas deseadas
traduceInvDisp :: Octave -> Inversion -> Disposicion -> Int -> Cifrado -> [Pitch]
traduceInvDisp octavaIni inv disp numNotasTotal cifrado =
	arreglaOctavas octavaIni (traduceDirecto cifradoTraducido (formarAcordeSimple (length cifradoTraducido) numNotasTotal inv disp))
		where cifradoTraducido = traduceCifrado cifrado

traduceInvDisp2 :: Octave -> Inversion -> Disposicion -> Int -> (Cifrado, Dur) -> AcordeOrdenado
traduceInvDisp2 octavaIni inv disp numNotasTotal (cifrado, dur) = 
	(traduceInvDisp octavaIni inv disp numNotasTotal cifrado , dur)


traduceProgresionSistemaParalelo :: Inversion -> Disposicion -> Int -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaParalelo inv disp numNotasTotal progresion 
	= map (traduceInvDisp2 4 inv disp numNotasTotal) progresion



-----------------------------------------------------------------------------
-- USANDO SISTEMA CONTINUO
-----------------------------------------------------------------------------


-- suponemos que [Pitch] tiene el mismo tamañano
-- vaya parrafada de declaracion de funcion, espero acordarme de que hace
-- [Pitch] debe estar ordenado, es decir, que las primeras notas de la lista sean las mas graves
distancia :: [Pitch] -> [Pitch] -> Int
distancia lp1 lp2 = foldr1 (+) [abs (((map absPitch lp1) !! i) - ((map absPitch lp2) !! i)) | i <- [0..(length lp1 - 1 )] ]



-- PROBLEMA CON LOS NUMEROS ALEATORIOS: VISITAR http://www.haskell.org/onlinereport/random.html

traduceProgresionSistemaContinuo :: Int -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaContinuo _ [] = []
traduceProgresionSistemaContinuo numNotasTotal ( (cifrado@(grado,matricula), dur) : resto) =
	(elegido, dur) : traduceProgresionSistemaContinuoRec elegido numNotasTotal resto
		where numNotasFund = matriculaAInt matricula ;
			listaGeneral = [traduceInvDisp oc i j numNotasTotal cifrado | i<-[0..(numNotasFund-1)] , j<-[1..numNotasFund], oc<-[3..5]];   
			elegido = listaGeneral !! 0	--TODO: AQUI HABRIA QUE PONER UN RANDOM


traduceProgresionSistemaContinuoRec :: [Pitch] -> Int -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaContinuoRec _ _ [] = []
traduceProgresionSistemaContinuoRec anterior numNotasTotal ( (cifrado@(grado,matricula), dur) : resto) =
	(elegido, dur) : traduceProgresionSistemaContinuoRec elegido numNotasTotal resto
		where numNotasFund = matriculaAInt matricula ;
			listaGeneral = [traduceInvDisp oc i j numNotasTotal cifrado | i<-[0..(numNotasFund-1)] , j<-[1..numNotasFund], oc<-[3..5]];         
			distMenor = minimum (map (distancia anterior) listaGeneral);
			listaFiltrada = filter ((distMenor<=).(distancia anterior)) listaGeneral ;
			elegido = listaFiltrada !! 0	--TODO: AQUI HABRIA QUE PONER UN RANDOM

---------------------------------------------------------------------------------------------------
-- OTRA FORMA MAS GENERAL DE HACER LA TRADUCCION POR EL METODO DE CONTINUIDAD ARMONICA
---------------------------------------------------------------------------------------------------

-- permutacion: encontrada en la pagina http://polaris.lcc.uma.es/~pacog/apuntes/pd/cap06.pdf, en la pagina 25

intercala :: a -> [a] -> [[a]]
intercala x [] = [[x]]
intercala x ls@(y:ys) = (x:ls) : map (y:) (intercala x ys)

perms :: [a] -> [[a]]
perms [] = [[]]
perms (x:xs) = concat (map (intercala x) (perms xs))


formarAcordeSimpleConPermutaciones :: Int -> Int -> Inversion -> Disposicion -> [AcordeSimple]
formarAcordeSimpleConPermutaciones numNotasFund numNotasTotal inv disp = 
	map (((inv+1):).(++[disp]).( map ((+1).(modulo numNotasFund)) )) (perms [1..(numNotasTotal-2)])


traduceInvDispConPerm :: Octave -> Inversion -> Disposicion -> Int -> Cifrado -> [[Pitch]]
traduceInvDispConPerm octavaIni inv disp numNotasTotal cifrado =
	map ((arreglaOctavas octavaIni).(traduceDirecto cifradoTraducido)) (formarAcordeSimpleConPermutaciones numNotasFund numNotasTotal inv disp)
		where cifradoTraducido = traduceCifrado cifrado ;
			numNotasFund = length cifradoTraducido


traduceProgresionSistemaContinuo2 :: Int -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaContinuo2 _ [] = []
traduceProgresionSistemaContinuo2 numNotasTotal ( (cifrado@(grado,matricula), dur) : resto) =
	(elegido, dur) : traduceProgresionSistemaContinuoRec2 elegido numNotasTotal resto
		where numNotasFund = matriculaAInt matricula ;
			listaGeneral = concat [traduceInvDispConPerm oc i j numNotasTotal cifrado | i<-[0..(numNotasFund-1)] , j<-[1..numNotasFund], oc<-[3..5]];         
			elegido = listaGeneral !! 0	--TODO: AQUI HABRIA QUE PONER UN RANDOM


traduceProgresionSistemaContinuoRec2 :: [Pitch] -> Int -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaContinuoRec2 _ _ [] = []
traduceProgresionSistemaContinuoRec2 anterior numNotasTotal ( (cifrado@(grado,matricula), dur) : resto) =
	(elegido, dur) : traduceProgresionSistemaContinuoRec2 elegido numNotasTotal resto
		where numNotasFund = matriculaAInt matricula ;
			listaGeneral = concat [traduceInvDispConPerm oc i j numNotasTotal cifrado | i<-[0..(numNotasFund-1)] , j<-[1..numNotasFund], oc<-[3..5]];         
			distMenor = minimum (map (distancia anterior) listaGeneral);
			listaFiltrada = filter ((distMenor<=).(distancia anterior)) listaGeneral ;
			elegido = listaFiltrada !! 0	--TODO: AQUI HABRIA QUE PONER UN RANDOM




--quizas esto es pueda hacer de otra forma pero necesito que los parametros de la funcion mod de cambien
modulo :: Int -> Int -> Int
modulo x y = mod y x

----------------------------------------------------------------------------------------------------


--BORRAME: SOLO SOY EJEMPLO

numNotas :: Int
numNotas = 5 -- con 8 el sistema de continuidad armonia 2 no tira

progresion :: Progresion
progresion = [((I,Mayor),1%1),((IV,Mayor),1%1),((V,Sept),1%1),((I,Maj7),1%1)]

acordesOrdenados :: [AcordeOrdenado]
acordesOrdenados = traduceProgresionSistemaContinuo numNotas progresion

arpegio2 :: PatronVertical
arpegio2 = [ [(i,False)] | i<-[1..numNotas]]

acorde2 :: PatronVertical
acorde2 = [[ (i,False) | i<-[1..numNotas]]]

ejemplo1 :: Music
ejemplo1 = deAcordesOrdenadosAMusica acordesOrdenados arpegio2 [(100,1%numNotas)]

ejemplo2 :: Music
ejemplo2 = deAcordesOrdenadosAMusica acordesOrdenados acorde2 [(100,1%1)]



acordesOrdenados2 :: [AcordeOrdenado]
acordesOrdenados2 = traduceProgresionSistemaContinuo2 numNotas progresion


ejemplo11 :: Music
ejemplo11 = deAcordesOrdenadosAMusica acordesOrdenados2 arpegio2 [(100,1%numNotas)]

ejemplo22 :: Music
ejemplo22 = deAcordesOrdenadosAMusica acordesOrdenados2 acorde2 [(100,1%1)]





