
-- Este modulo contiene las funciones necesarias para convertir una lista de acordes en su representacion
-- de cifrados, es decir, como [( (Grado,Matricula), Dur )], a una lista de alturas como [Pitch]

module TraduceCifrados
where

import Haskore
import Progresiones
import PrologAHaskell -- de aqui solo necesito el tipo AcordeOrdenado
import Ratio
import Random

-----------------------------------------------------------

type AcordeSimple = [Int] -- Indica el orden de las voces en el acorde sin centrarse en que notas son

type Inversion = Int -- 0 es el estado fundamental
type Disposicion = Int
type NumNotasFund = Int -- notas del acorde pero sin repetir ninguna (ej: cuatriadas tienen cuatro notas)
type NumNotasTotal = Int -- notas total del acorde. Puede un numero mayor o igual a 2


-- Forma un acorde simple
formarAcordeSimple :: NumNotasFund -> NumNotasTotal -> Inversion -> Disposicion -> AcordeSimple
formarAcordeSimple numNotasFund numNotasTotal inv disp = reverse (disp : anadeAcordeSimple numNotasFund (numNotasTotal - 2) [inv + 1])

-- A�ade notas (modulo NumNotasFund)+1, es decir, si numNotasFund = 4 y comenzamos con 2 entonces a�ade 3, 4, 1, 2, ...
anadeAcordeSimple :: NumNotasFund -> Int -> [Int] -> [Int]
anadeAcordeSimple _ 0 lista = lista
anadeAcordeSimple numNotasFund notasResto (nota : lista)
	|nota == numNotasFund 	= anadeAcordeSimple numNotasFund (notasResto - 1) (1 : nota : lista)
	|otherwise			= anadeAcordeSimple numNotasFund (notasResto - 1) ((nota + 1) : nota : lista)


---------------------------------------------------

encajaAcordeSimple :: [PitchClass] -> AcordeSimple -> [PitchClass]
encajaAcordeSimple lpc [] = []
encajaAcordeSimple lpc (num : resto) = (lpc !! (num - 1)) : encajaAcordeSimple lpc resto


arreglaOctavasAsc :: Octave -> [PitchClass] -> [Pitch]
arreglaOctavasAsc octavaIni (cabeza : resto) = (cabeza, octavaIni) : arreglaOctavasAscRec octavaIni cabeza resto

arreglaOctavasAscRec :: Octave -> PitchClass -> [PitchClass] -> [Pitch]
arreglaOctavasAscRec _ _ [] = []
arreglaOctavasAscRec octava pitchAnt (cabeza : resto) 
	|pitchClass pitchAnt >= pitchClass cabeza = (cabeza, octava + 1) : arreglaOctavasAscRec (octava + 1) cabeza resto
	|otherwise				 		= (cabeza, octava) : arreglaOctavasAscRec octava cabeza resto

arreglaOctavasDes :: Octave -> [PitchClass] -> [Pitch]
arreglaOctavasDes octavaIni (cabeza : resto) = (cabeza, octavaIni) : arreglaOctavasDesRec octavaIni cabeza resto

arreglaOctavasDesRec :: Octave -> PitchClass -> [PitchClass] -> [Pitch]
arreglaOctavasDesRec _ _ [] = []
arreglaOctavasDesRec octava pitchAnt (cabeza : resto) 
	|pitchClass pitchAnt <= pitchClass cabeza = (cabeza, octava - 1) : arreglaOctavasDesRec (octava - 1) cabeza resto
	|otherwise				 		= (cabeza, octava) : arreglaOctavasDesRec octava cabeza resto



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
	arreglaOctavasAsc octavaIni (encajaAcordeSimple cifradoTraducido (formarAcordeSimple (length cifradoTraducido) numNotasTotal inv disp))
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

-- Numero de PitchClass iguales en las mismas posiciones en ambas listas
coincidencias :: [PitchClass] -> [PitchClass] -> Int
coincidencias lp1 lp2 = foldr1 (+) (map fromEnum [(lp1 !! i) == (lp2 !! i) | i <- [0..(longMen - 1 )]])
	where longMen = min (length lp1) (length lp2)


inversion :: Inversion -> [a] -> [a]
inversion n lista = (drop n lista) ++ (take n lista)


distancia :: [PitchClass] -> [PitchClass] -> Int
distancia lp1 lp2 = foldr1 (+) [abs ( ((map pitchClass lp1) !! i) - ((map pitchClass lp2) !! i) ) | i <- [0..(longMen - 1 )] ]
	where longMen = min (length lp1) (length lp2)


-- NOTA: SI NUNCA HAY COINCIDENCIAS USAR LA INVERSION CON MENOS DISTANCIA
-- CREO QUE LA NOTA YA ESTA SUBSANADA
masCoincidente :: [PitchClass] -> [PitchClass] -> [PitchClass]
masCoincidente referencia aInvertir 
	| coincidenciasMayor > 0	= elegido
	| coincidenciasMayor == 0	= elegido2
	where	listaInv = [inversion i aInvertir | i <- [0..(length aInvertir - 1 )]] ;
		coincidenciasMayor = maximum (map (coincidencias referencia) listaInv) ;
		listaFiltrada = filter ((coincidenciasMayor==).(coincidencias referencia)) listaInv ;
		elegido = listaFiltrada !! 0 ;    --TODO: HACER UN RANDOM CON EL NUMERO DE ELEMENTOS
		distanciaMayor = maximum (map (distancia referencia) listaInv) ;
		listaFiltrada2 = filter ((distanciaMayor==).(distancia referencia)) listaInv ;
		elegido2 = listaFiltrada2 !! 0 ;    --TODO: HACER UN RANDOM CON EL NUMERO DE ELEMENTOS
				


traduceProgresionSistemaContinuo :: NumNotasTotal -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaContinuo numNotasTotal progresion 
	= zip (arreglaTodos (map2 encajaAcordeSimple (organizar (map traduceCifrado cifrados)) listaAcordesSimples)) duraciones
		where desabrochar = unzip progresion ;
			cifrados = fst desabrochar ;
			duraciones = snd desabrochar ;
			listaAcordesSimples = map reverse [anadeAcordeSimple (matriculaAInt ((map snd cifrados)!!i)) (numNotasTotal-1) [1] | i <- [0..(length cifrados-1)] ]

-- pone la octava en todos los acordes que son [PitchClass]. El primero le empieza en la octava 4
-- y los siguientes se las arregla para que las notas coincidentes tengan la misma octava que la [Pitch] anterior
arreglaTodos :: [[PitchClass]] -> [[Pitch]]
arreglaTodos (pc : resto) = cabeza : arreglaTodosRec cabeza resto
	where cabeza = arreglaOctavasAsc 4 pc

arreglaTodosRec :: [Pitch] -> [[PitchClass]] -> [[Pitch]]
arreglaTodosRec _ [] = []
arreglaTodosRec ant (pc : resto) = cabeza : arreglaTodosRec cabeza resto
	where cabeza = arreglaUno ant pc


primero :: (a,b,c) -> a
primero (a1,b1,c1) = a1

segundo :: (a,b,c) -> b
segundo (a,b,c) = b

tercero :: (a,b,c) -> c
tercero (a,b,c) = c


-- Pone la octava en [PitchClass] de tal forma que las notas coincidentes tengan la misma octava
-- que el acordes anterior, pasado como parametro
arreglaUno :: [Pitch] -> [PitchClass] -> [Pitch]
arreglaUno lp lpc = reverse (drop 1 (arreglaOctavasDes oc seg)) ++ arreglaOctavasAsc oc pri 
	where tupla = divide lp lpc ;
		pri = primero tupla ;
		seg = segundo tupla ;
		oc = tercero tupla


-- Divide el segundo parametro en dos partes para que sea mas facil a�adir la octava. Ademas tambien
-- devuelve la octava de la primera coincidencia, que es por la que tiene que empezar a a�adir
divide :: [Pitch] -> [PitchClass] -> ([PitchClass],[PitchClass],Octave)
divide = divideR []

divideR :: [PitchClass] -> [Pitch] -> [PitchClass] -> ([PitchClass],[PitchClass],Octave)
divideR acu [(pc,oc)] [pc2] = ([pc2], pc2:acu, oc)
divideR acu ((x,oc):xs) (y:ys)
	| x == y	= (y:ys, y:acu, oc)
	| otherwise	= divideR (y:acu) xs ys


-- Variante de la funcion map. No se si ya esta implementada en el propio Haskell. 
-- Su funcion es que c[i] = f a[i] b[i] 
map2 :: (a->b->c) -> [a] -> [b] -> [c]
map2 f la lb = map (uncurry f) (zip la lb)


-- Modifica la lista de [PitchClass] para que el numero de coicidencias entre acordes consecutivos
-- sea la maxima (solo en la misma posicion). El primero le elige al azar y el resto en funcion de ellos
organizar :: [[PitchClass]] -> [[PitchClass]]
organizar (x:xs) = elegido : organizarRec elegido xs
	where elegido = [inversion i x | i <- [0..(length x - 1 )]] !! 0 --TODO: PONER AQUI UN RANDOM

organizarRec :: [PitchClass] -> [[PitchClass]] -> [[PitchClass]]
organizarRec _ [] = []
organizarRec referencia (x:xs) = nuevaRef : organizarRec nuevaRef xs
	where nuevaRef = masCoincidente referencia x



-- BORRAME: EJEMPLOS DE RANDOM

{-
aleatorio :: Int -> [Int]
aleatorio n = aleatorioRec n (mkStdGen 1)

aleatorioRec :: RandomGen g => Int -> g -> [Int]
aleatorioRec 0 _ = []
aleatorioRec n g = (fst aleatorio) : aleatorioRec (n-1) (snd aleatorio)
	where aleatorio = randomR (0,10) g

rollDice :: IO Int
rollDice = getStdRandom (randomR (1,6))


dado :: IO Int
dado = do{	x <- rollDice;
		return x
	}

dado2 :: Int
dado2 = dado
-}


-- BORRAME: EJEMPLOS DE PRUEBA

{-
progresion1 :: Progresion
progresion1 = [((I, Maj7),1%1),((VI, Men7),1%1),((II, Men7),1%1),((V7 I, Sept),1%1)]

progresion2 :: Progresion
progresion2 = [((I, Maj7),1%1),((VI, Men7),1%1),((II, Men7),1%1),((V, Sept),1%1),((I, Maj7),1%1)]

numNotas :: Int
numNotas = 4

acordes :: [AcordeOrdenado]
acordes = traduceProgresionSistemaContinuo numNotas progresion2

patronH1 :: PatronHorizontal
patronH1 = [(100,1%8)]

patronV1 :: PatronVertical
patronV1 = [[(i,False)] | i<-[1..numNotas]]

patronH2 :: PatronHorizontal
patronH2 = [(100,1%1)]

patronV2 :: PatronVertical
patronV2 = [ [(i,False) | i<-[1..numNotas]] ]


musica1 :: Music
musica1 = deAcordesOrdenadosAMusica acordes patronV1 patronH1

musica2 :: Music
musica2 = deAcordesOrdenadosAMusica acordes patronV2 patronH2
-}

{-

numNotas :: Int
numNotas = 4

progresion :: Progresion
progresion = [((I,Mayor),1%2),((V,Mayor),1%2),((I,Mayor),1%1)]

patronH :: PatronHorizontal
patronH = [(100,1%4)]

patronV1 :: PatronVertical
patronV1 = [[(i,False) | i<-[1..numNotas]] , [(1,False)]]

patronV2 :: PatronVertical
patronV2 = [[(i,False)] | i<-[1..numNotas]]

traduccion1 :: [AcordeOrdenado]
traduccion1 = traduceProgresionSistemaContinuo numNotas progresion

musica1 :: Music
musica1 = deAcordesOrdenadosAMusica traduccion1 patronV2 patronH 

-}