
-- Este modulo contiene las funciones necesarias para convertir una lista de acordes en su representacion
-- de cifrados, es decir, como [( (Grado,Matricula), Dur )], a una lista de alturas como ([Pitch],Dur)

module TraduceCifrados
where

import Haskore
import Progresiones
import Ratio
import Random
import BiblioGenaro


type AcordeOrdenado = ([Pitch],Dur)


-----------------------------------------------------------
-- FUNCION QUE EXPORTA
-----------------------------------------------------------

{-
Existe dos tipos de traduccion de los cifrados a notas: sistema paralelo y continuo. Cada
uno tiene diferentes parametros. Este tipo construido junto con la funcion 'traduceProgresion'
engloba los parametros de ambas traducciones
-}
data ParametrosTraduceCifrados =
	  Paralelo OctaveIni Inversion Disposicion NumNotasTotal
	| Continuo SemillaInt OctaveIni NumNotasTotal

{-
Traduce una progresion de cifrados a una lista de acordes ordenados.
Bool indica si queremos triadas o, por contra, las cuatriadas que ya tenemos
-}
traduceProgresion :: Bool -> ParametrosTraduceCifrados -> Progresion -> [AcordeOrdenado]
traduceProgresion b (Paralelo ocIni inv disp numNotasT ) prog = traduceProgresionSistemaParalelo ocIni inv disp numNotasT (f b prog)
      where f2 ((g,matri),d) = ((g,deCuatriadaATriada matri),d)
            f False p = p
            f True p = map f2 p
traduceProgresion b (Continuo semilla ocIni numNotasT )  prog = traduceProgresionSistemaContinuo2 semilla ocIni numNotasT (f b prog)
      where f2 ((g,matri),d) = ((g,deCuatriadaATriada matri),d)
            f False p = p
            f True p = map f2 p

-----------------------------------------------------------

type AcordeSimple = [Int] -- Indica el orden de las voces en el acorde sin centrarse en que notas son
                          -- Dicho de otra forma, cada numero de la lista es un indice sobre las notas
                          -- del cifrado

type Inversion = Int    -- Inversion del acorde. 0 es el estado fundamental
type Disposicion = Int  -- Disposicion del acorde
type NumNotasFund = Int -- Notas del acorde pero sin repetir ninguna (ej: cuatriadas tienen cuatro notas)
type NumNotasTotal = Int -- Notas total del acorde. Puede ser un numero mayor o igual a 2

type OctaveIni = Octave -- octava inicial: a partir de este numero se empieza a dar valor a las octavas
				-- dicho de otra forma, la nota mas baja de cada acorde tiene esta octava y las
				-- siguientes mas agudas tienen un valor para la octava igual o superior

type SemillaInt = Int	-- valor entero que sera usado para crear un generador de numeros aleatorios


-- Forma un acorde simple en funcion del numero de notas del acorde, el numero de notas que se desea que tenga,
-- una inversion y una disposicion
formarAcordeSimple :: NumNotasFund -> NumNotasTotal -> Inversion -> Disposicion -> AcordeSimple
formarAcordeSimple numNotasFund numNotasTotal inv disp = reverse (disp : anadeAcordeSimple numNotasFund (numNotasTotal - 2) [inv + 1])


-- A�ade notas (modulo NumNotasFund)+1, es decir, si numNotasFund = 4 y comenzamos con 2 entonces a�ade 3, 4, 1, 2, ...
anadeAcordeSimple :: NumNotasFund -> Int -> [Int] -> [Int]
anadeAcordeSimple _ 0 lista = lista
anadeAcordeSimple numNotasFund notasResto (nota : lista)
	|nota == numNotasFund 	= anadeAcordeSimple numNotasFund (notasResto - 1) (1 : nota : lista)
	|otherwise			= anadeAcordeSimple numNotasFund (notasResto - 1) ((nota + 1) : nota : lista)


---------------------------------------------------

-- 'encajaAcordeSimple' transforma un acorde simple en una lista de PitchClass teniendo en cuenta
-- que los numeros del acorde simple son indices sobre la lista pasada como primer parametros
encajaAcordeSimple :: [PitchClass] -> AcordeSimple -> [PitchClass]
encajaAcordeSimple lpc [] = []
encajaAcordeSimple lpc (num : resto) = (lpc !! (num - 1)) : encajaAcordeSimple lpc resto


arreglaOctavasAsc :: OctaveIni -> [PitchClass] -> [Pitch]
arreglaOctavasAsc octavaIni (cabeza : resto) = (cabeza, octavaIni) : arreglaOctavasAscRec octavaIni cabeza resto

arreglaOctavasAscRec :: OctaveIni -> PitchClass -> [PitchClass] -> [Pitch]
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
	|otherwise				  = (cabeza, octava) : arreglaOctavasDesRec octava cabeza resto



-- traduce solo a estado fundamental
traduceCifrado :: Cifrado -> [PitchClass]
traduceCifrado (grado, matricula) = map  absPitchAPitchClass (sumaVector (matriculaAVector matricula) (gradoAInt grado))


---------------------------------------------------------------------------
-- USANDO SISTEMA PARALELO
---------------------------------------------------------------------------


-- 'traduceInvDisp' traduce un unico cifrado a una lista de 'Pitch' en una disposicion e inversion dada
traduceInvDisp :: OctaveIni -> Inversion -> Disposicion -> NumNotasTotal -> Cifrado -> [Pitch]
traduceInvDisp octavaIni inv disp numNotasTotal cifrado =
	arreglaOctavasAsc octavaIni (encajaAcordeSimple cifradoTraducido (formarAcordeSimple (length cifradoTraducido) numNotasTotal inv disp))
		where cifradoTraducido = traduceCifrado cifrado

-- 'traduceInvDisp2' hace algo parecido a 'traduceInvDisp' pero teniendo en cuenta la duracion
traduceInvDisp2 :: OctaveIni -> Inversion -> Disposicion -> NumNotasTotal -> (Cifrado, Dur) -> AcordeOrdenado
traduceInvDisp2 octavaIni inv disp numNotasTotal (cifrado, dur) = 
	(traduceInvDisp octavaIni inv disp numNotasTotal cifrado , dur)

{-
Traduce toda una progresion a una lista de acordes ordenados usando el sistema paralelo
-}
traduceProgresionSistemaParalelo :: OctaveIni -> Inversion -> Disposicion -> NumNotasTotal -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaParalelo octaveIni inv disp numNotasTotal progresion 
	= map (traduceInvDisp2 octaveIni inv disp numNotasTotal) progresion



-----------------------------------------------------------------------------
-- USANDO SISTEMA CONTINUO
-----------------------------------------------------------------------------

-- Numero de PitchClass iguales en las mismas posiciones en ambas listas
coincidencias :: [PitchClass] -> [PitchClass] -> Int
coincidencias lp1 lp2 = foldr1 (+) (map fromEnum [(lp1 !! i) == (lp2 !! i) | i <- [0..(longMen - 1 )]])
	where longMen = min (length lp1) (length lp2)

{-
	esta funcion creo que ya no la uso
-}
inversion :: Inversion -> [a] -> [a]
inversion n lista = (drop n lista) ++ (take n lista)

{-
	Distancia entre dos listas de PitchClass
-}
distancia :: [PitchClass] -> [PitchClass] -> Int
distancia lp1 lp2 = foldr1 (+) [abs ( ((map pitchClass lp1) !! i) - ((map pitchClass lp2) !! i) ) | i <- [0..(longMen - 1 )] ]
	where longMen = min (length lp1) (length lp2)


-- NOTA: SI NUNCA HAY COINCIDENCIAS USAR LA INVERSION CON MENOS DISTANCIA
-- CREO QUE LA NOTA YA ESTA SUBSANADA
{-
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
-}
				
masCoincidente :: RandomGen a => a -> [PitchClass] -> [PitchClass] -> ( [PitchClass], a )
masCoincidente gen referencia aInvertir = (elegido, sigGen)
	where	listaPerm = perms aInvertir ;
		coincidenciasMayor = maximum (map (coincidencias referencia) listaPerm) ;
		listaFiltrada = filter ((coincidenciasMayor==).(coincidencias referencia)) listaPerm ;
		distanciaMenor = minimum (map (distancia referencia) listaPerm) ;
		listaFiltrada2 = filter ((distanciaMenor==).(distancia referencia)) listaFiltrada ;
		(elegido, sigGen) = elementoAleatorio gen listaFiltrada2

-- Igual que traduceSistemaContinuo pero esta vez la semilla se pasa como un numero entero.
traduceProgresionSistemaContinuo2 :: SemillaInt -> OctaveIni -> NumNotasTotal -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaContinuo2 semillaInt octaveIni = traduceProgresionSistemaContinuo (mkStdGen semillaInt) octaveIni

{-
traduce una progresion a una lista de acordes ordenados usando el sistema paralelo
-}
traduceProgresionSistemaContinuo :: RandomGen a => a -> OctaveIni -> NumNotasTotal -> Progresion -> [AcordeOrdenado]
traduceProgresionSistemaContinuo gen octaveIni numNotasTotal progresion 
	= zip (arreglaTodos octaveIni (map2 encajaAcordeSimple (organizar gen (map traduceCifrado cifrados)) listaAcordesSimples)) duraciones
		where desabrochar = unzip progresion ;
			cifrados = fst desabrochar ;
			duraciones = snd desabrochar ;
			listaAcordesSimples = map reverse [anadeAcordeSimple (matriculaAInt ((map snd cifrados)!!i)) (numNotasTotal-1) [1] | i <- [0..(length cifrados-1)] ]

-- pone la octava en todos los acordes que son [PitchClass]. El primero le empieza en la octavaIni
-- y los siguientes se las arregla para que las notas coincidentes tengan la misma octava que la [Pitch] anterior
arreglaTodos :: OctaveIni -> [[PitchClass]] -> [[Pitch]]
arreglaTodos octaveIni (pc : resto) = cabezaTratada : arreglaTodosRec cabeza resto
	where 	cabeza = arreglaOctavasAsc octaveIni pc;
			cabezaTratada = eliminaOctavasErroneas cabeza		-- CUIDADO : ESTO ES PARA ARREGLAR EL PROBLEMA DE LAS OCTAVAS NEGATIVAS
												-- DE MOMENTO ESTA HECHO MUY SIMPLE Y CHAPUCERO

{-
Elimina las octavas erroneas que hayan podido aparecer en la traduccion continua
Se consideran octavas erroneas aquellas menores de 0 y mayores que 21. Se arreglan
poniendo las menores que 0 a 0 y las mayores que 21 a 21
-} 
eliminaOctavasErroneas :: [Pitch] -> [Pitch]
eliminaOctavasErroneas [] = []
eliminaOctavasErroneas ((pitchClass, octave) : resto)
	| octave < 0	= (pitchClass, 0) : eliminaOctavasErroneas resto
	| octave > 21	= (pitchClass, 21) : eliminaOctavasErroneas resto   -- EL LIMITE POR ARRIBA ES 21
	| otherwise	= (pitchClass, octave) : eliminaOctavasErroneas resto


{-
Inserta la octava en todas las lista de PitchClass teniendo en cuenta la lista de Pitch anterior
para que, de esa forma, dos notas con el mismo nombre en la misma posicion tenga la misma octava
-}
arreglaTodosRec :: [Pitch] -> [[PitchClass]] -> [[Pitch]]
arreglaTodosRec _ [] = []
arreglaTodosRec ant (pc : resto) = cabezaTratada : arreglaTodosRec cabeza resto
	where 	cabeza = arreglaUno ant pc;
		      cabezaTratada = eliminaOctavasErroneas cabeza		-- CUIDADO : ESTO ES PARA ARREGLAR EL PROBLEMA DE LAS OCTAVAS NEGATIVAS
									            -- DE MOMENTO ESTA HECHO MUY SIMPLE Y CHAPUCERO


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
organizar :: RandomGen a => a -> [[PitchClass]] -> [[PitchClass]]
organizar gen (x:xs) = elegido : organizarRec sigGen elegido xs
	where 	lista = [inversion i x | i <- [0..(length x - 1 )]];      --TODO: PONER AQUI UN RANDOM
		(elegido, sigGen) = elementoAleatorio gen lista
		

organizarRec :: RandomGen a => a -> [PitchClass] -> [[PitchClass]] -> [[PitchClass]]
organizarRec _ _ [] = []
organizarRec gen referencia (x:xs) = nuevaRef : organizarRec sigGen nuevaRef xs
	where 	(nuevaRef, sigGen) = masCoincidente gen referencia x



