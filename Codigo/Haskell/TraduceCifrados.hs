
-- Este modulo contiene las funciones necesarias para convertir una lista de acordes en su representacion
-- de cifrados, es decir, como [( (Grado,Matricula), Dur )], a una lista de alturas como [Pitch]

module TraduceCifrados
where

import Haskore
import Progresiones
import PrologAHaskell -- de aqui solo necesito el tipo AcordeOrdenado
import Ratio
import Ritmo -- este solo para hacer pruebas
import Random

-----------------------------------------------------------

type AcordeSimple = [Int] -- Indica el orden de las voces en el acorde sin centrarse en que notas son

type Inversion = Int -- 0 es el estado fundamental
type Disposicion = Int
type NumNotasFund = Int -- notas del acorde pero sin repetir ninguna (ej: cuatriadas tienen cuatro notas)
type NumNotasTotal = Int -- notas total del acorde. Puede un numero mayor o igual a 2


-- Forma un acorde simple
formarAcordeSimple :: NumNotasFund -> NumNotasTotal -> Inversion -> Disposicion -> AcordeSimple
formarAcordeSimple numNotasFund numNotasTotal inv disp = reverse (disp : anade numNotasFund (numNotasTotal - 2) [inv + 1])

-- Añade notas (modulo NumNotasFund)+1, es decir, si numNotasFund = 4 y comenzamos con 2 entonces añade 3, 4, 1, 2, ...
anade :: NumNotasFund -> Int -> [Int] -> [Int]
anade _ 0 lista = lista
anade numNotasFund notasResto (nota : lista)
	|nota == numNotasFund 	= anade numNotasFund (notasResto - 1) (1 : nota : lista)
	|otherwise			= anade numNotasFund (notasResto - 1) ((nota + 1) : nota : lista)


---------------------------------------------------

traduceDirecto :: [PitchClass] -> AcordeSimple -> [PitchClass]
traduceDirecto lpc [] = []
traduceDirecto lpc (num : resto) = (lpc !! (num - 1)) : traduceDirecto lpc resto


arreglaOctavas :: Octave -> [PitchClass] -> [Pitch]
arreglaOctavas octavaIni (cabeza : resto) = (cabeza, octavaIni) : arreglaOctavasRec octavaIni cabeza resto


arreglaOctavasRec :: Octave -> PitchClass -> [PitchClass] -> [Pitch]
arreglaOctavasRec _ _ [] = []
arreglaOctavasRec octava pitchAnt (cabeza : resto) 
	|pitchClass pitchAnt >= pitchClass cabeza = (cabeza, octava + 1) : arreglaOctavasRec (octava + 1) cabeza resto
	|otherwise				 		= (cabeza, octava) : arreglaOctavasRec octava cabeza resto


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





