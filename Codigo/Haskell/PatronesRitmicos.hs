module PatronesRitmicos
where

import Haskore
import Ratio
import PrologAHaskell
import Haskore

--import TraduceCifrados
--import Progresiones

--
-- PATRON RITMICO
--
-- se tienen en cuenta los ligados
type Voz = Int
type Acento = Float  -- Acento: intensidad con que se ejecuta ese tiempo. Valor de 0 a 100
type Ligado = Bool
type URV = [(Voz, Acento, Ligado)]	-- Unidad de ritmo vertical
type URH = Dur 				-- Unidad de ritmo horizontal
type UPR = ( URV , URH)
type PatronRitmico = [UPR] 

type AlturaPatron = Int			-- numero maximo de voces que posee el patron



deAcordesOrdenadosAMusica :: ModoPatronHorizontal -> ModoPatronVertical -> PatronRitmico -> AlturaPatron -> [AcordeOrdenado] -> Music
deAcordesOrdenadosAMusica mH mV pR alturaP lao = 
	deNotasLigadasAMusica ( (eliminaLigaduras (deAcordesOrdenadosANotasLigadas mH mV (repetirInfinito pR) alturaP lao)))




deAcordesOrdenadosANotasLigadas :: ModoPatronHorizontal -> ModoPatronVertical -> PatronRitmico -> AlturaPatron -> [AcordeOrdenado] -> NotasLigadas
deAcordesOrdenadosANotasLigadas mH mV pR alturaP lao
	| mH == Ciclico 		= consumeVerticalCiclico mV lao pR alturaP
	| mH == NoCiclico		= foldr (++) [] (map (deAcordeOrdenadoANotasLigadas_NoCiclico mV pR alturaP) lao)



deAcordeOrdenadoANotasLigadas_NoCiclico :: ModoPatronVertical -> PatronRitmico -> AlturaPatron -> AcordeOrdenado -> NotasLigadas
deAcordeOrdenadoANotasLigadas_NoCiclico mV pR alturaP (lp, durAcorde) = consumeVerticalNoCiclico mV lp durAcorde pR alturaP


-- consumeVertical: fusiona un patron ritmico y un acorde ordenado (disgregado en alturas y duracion) en las notas ligadas
-- Cuando se acaba el acorde vuelve a empezar el patron ritmico
consumeVerticalNoCiclico :: ModoPatronVertical -> [Pitch] -> Dur -> PatronRitmico -> AlturaPatron -> NotasLigadas
consumeVerticalNoCiclico mV lp durAcorde ( (urv , durH) : restoP ) alturaP
	| durAcorde == durH = ( insertaDur durH listaPitch  , durH ) : []
	| durAcorde < durH = ( insertaDur durAcorde listaPitch  , durAcorde ) : []
	| durAcorde > durH = ( insertaDur durH listaPitch , durH) : consumeVerticalNoCiclico mV lp (durAcorde - durH) restoP alturaP 
		where listaPitch = encajaModo mV alturaP lp urv



-- insertaAcentoYDur: introduce el acento (volumen) y la duracion en la lista de alturas para formar la lista de notas
insertaDur :: Dur -> [(Pitch, Ligado, Acento)] -> [(Music, Ligado)]
insertaDur dur [] = [(Rest dur, False)]
--insertaDur dur [(pitch, ligado, acento)] = [ ( Note pitch dur [Volume acento] , ligado ) ]
insertaDur dur lp = insertaDur2 dur lp

-- en insertaDur2 la lista pasada es seguro que al menos contiene un elemento
insertaDur2 :: Dur -> [(Pitch, Ligado, Acento)] -> [(Music, Ligado)]
insertaDur2 dur [(pitch, ligado, acento)] = [ ( Note pitch dur [Volume acento] , ligado ) ]
insertaDur2 dur ((pitch, ligado, acento) : resto) = 
	( Note pitch dur [Volume acento] , ligado ) : insertaDur2 dur resto








-- Cuando se acaba el acorde no vuelve a empezar el patron ritmico sino que continua con el elemento que le toque
consumeVerticalCiclico :: ModoPatronVertical -> [AcordeOrdenado] -> PatronRitmico -> AlturaPatron -> NotasLigadas
consumeVerticalCiclico _ [] _ _ = []
consumeVerticalCiclico mV ((lp,durA) : restoA) ( (urv, durH) : restoP) alturaP 
	| durA > durH = 
		(insertaDur durH listaPitch , durH) : consumeVerticalCiclico mV ((lp,durA-durH):restoA) restoP alturaP 
	| durA == durH =  
		(insertaDur durH listaPitch , durH) : consumeVerticalCiclico mV restoA restoP alturaP 
	| durA < durH = 
		(insertaDur durA listaPitch , durA) : consumeVerticalCiclico mV restoA ((urv,durH-durA):restoP) alturaP 
		where listaPitch = encajaModo mV alturaP lp urv



---------------------------------------------------------------------------------------------------------
-- FUNCIONES ENCAJA
---------------------------------------------------------------------------------------------------------

-- Ciclico: Si un acorde se quedo en medio de un patron horizontal o en el elemento X entonces
-- el siguiente acorde empieza en el elemento X+1
-- NoCiclico: Todos los acordes empiezan en la primera columna de la matriz que representa el patron ritmico
data ModoPatronHorizontal = Ciclico | NoCiclico
	deriving (Enum, Bounded, Eq, Ord, Show, Read)

-- Para cuando A > P, donde A son las notas de los acordes y P la altura del patron ritmico
-- Truncar: las voces extra del acorde no se tocan
-- Saturar: las voces del acorde desde P+1 hasta A se ejecutan a la vez cuando se ejecuta la voz P
data ModoPatronVerticalPosibles1 = Truncar1 | Saturar1
	deriving (Enum, Bounded, Eq, Ord, Show, Read)

-- Para cuando A < P
-- Truncar: las voces entre A+1 y P no se tocan
-- Saturar: las voces del patron ritmico entre A+1 y P se toman como A
-- Ciclico: si X esta entre A+1 y P (incluidos) entonces añadimos tantas notas como sea necesario al acorde
--  aumentando la octava
-- Modulo: si X esta entre A+1 y P entonces cambiamos X por ((X-1) mod A)+1. Esto nos asegura que X cae siempre
--  entre 1 y A
data ModoPatronVerticalPosibles2 = Truncar2 | Saturar2 | Ciclico2 | Modulo2
	deriving (Enum, Bounded, Eq, Ord, Show, Read)

-- El primer valor para cuando A>P, el segundo para A<P
type ModoPatronVertical = (ModoPatronVerticalPosibles1 , ModoPatronVerticalPosibles2 )



-- Encaja un patron vertical con una [Pitch] segun algun modo
encajaModo :: ModoPatronVertical -> AlturaPatron -> [Pitch] -> URV -> [(Pitch, Ligado, Acento)]
encajaModo (m1, m2) alturaPatron lp urv 
	| alturaPatron == longitudA 			= encajaA_Mayor_P_Truncar lp urv    -- Parece que va bien
	| longitudA > alturaPatron && m1 == Truncar1 	= encajaA_Mayor_P_Truncar lp urv    -- Parece que va bien
	| longitudA > alturaPatron && m1 == Saturar1 	= encajaA_Mayor_P_Saturar alturaPatron lp urv  -- Parece que va bien
	| longitudA < alturaPatron && m2 == Truncar2 	= encajaA_Menor_P_Truncar lp urv 	-- Parece que va bien
	| longitudA < alturaPatron && m2 == Saturar2 	= encajaA_Menor_P_Saturar lp urv	-- Parece que va bien
	| longitudA < alturaPatron && m2 == Ciclico2 	= encajaA_Menor_P_Ciclico lp urv
	| longitudA < alturaPatron && m2 == Modulo2 	= encajaA_Menor_P_Modulo lp urv	-- Parece que va bien
		where longitudA = length lp -- numero de notas del acorde, es decir, de A


encajaA_Mayor_P_Truncar :: [Pitch] -> URV -> [(Pitch, Ligado, Acento)]
encajaA_Mayor_P_Truncar = encaja 

encajaA_Mayor_P_Saturar :: Int -> [Pitch] -> URV -> [(Pitch, Ligado, Acento)]
encajaA_Mayor_P_Saturar alturaPatron lp urv = encaja lp (arregla alturaPatron (length lp) urv)

-- cambiamos el patron vertical para que se cumpla el caso de A>P con saturacion.
-- Si existe algun elemento que tenga una voz igual a P entonces añadimos las notas que faltan, desde la P+1 hasta A
arregla :: Int -> Int -> URV -> URV
arregla _ _ [] = []
arregla alturaP alturaA ((voz, acento, ligado):resto) 
	| alturaP == voz 	= ((voz, acento, ligado):resto) ++ [(i, acento, ligado) | i <- [(alturaP + 1) .. alturaA]]
	| otherwise		= (voz, acento, ligado) : arregla alturaP alturaA resto


encajaA_Menor_P_Modulo :: [Pitch] -> URV -> [(Pitch, Ligado, Acento)]
encajaA_Menor_P_Modulo lp urv = encaja lp (arregla2 (length lp) urv)

-- Hacemos que todas las voces del patron sea ((Voz-1) mod A)+1 para que caigan entre 1 y A
arregla2 :: Int -> URV -> URV
arregla2 _ [] = []
arregla2 alturaA ((voz, acento, ligado):resto) = (1 + mod (voz -1) alturaA, acento, ligado) : arregla2 alturaA resto


-- igual que encaja pero en vez de usar (!!) usa dameElementoSeguro
encajaA_Menor_P_Saturar :: [Pitch] -> URV -> [(Pitch, Ligado, Acento)]
encajaA_Menor_P_Saturar lp [] = []
encajaA_Menor_P_Saturar lp ( (voz, acento, ligado) : resto) = ( dameElementoSeguro lp (voz-1), ligado, acento) : encajaA_Menor_P_Saturar lp resto


encajaA_Menor_P_Truncar :: [Pitch] -> URV -> [(Pitch, Ligado, Acento)]
encajaA_Menor_P_Truncar lp [] = []
encajaA_Menor_P_Truncar lp ( (voz, acento, ligado) : resto) 
	| longitud >= voz		= ( lp !! (voz-1), ligado, acento) : encajaA_Menor_P_Truncar lp resto
	| longitud < voz		= encajaA_Menor_P_Truncar lp resto
		where longitud = length lp


encajaA_Menor_P_Ciclico :: [Pitch] -> URV -> [(Pitch, Ligado, Acento)]
encajaA_Menor_P_Ciclico lp urv = encaja (repetirCiclico lp) urv


-- NOTA: YA PARECE QUE VA BIEN. HAY QUE PROBARLA UN POCO MAS
-- Repite infinitamente el acorde, puesto como [Pitch], aumentado la octava cada vez, de tal forma que la lista sigue
-- ordenada en altura 
repetirCiclico :: [Pitch] -> [Pitch]
repetirCiclico lp@((pc, oc) : resto)
	| absPitch (pc, oc + octavaAum) <= absPitch (pcu, ocu) = lp ++ repetirCiclico (aumentaOctava (octavaAum + 1) lp)
	| otherwise								 = lp ++ repetirCiclico (aumentaOctava octavaAum lp)
	where ultimo = last lp ;
		pcu = fst ultimo ;
		ocu = snd ultimo ;
		octavaAum = ocu - oc 


aumentaOctava :: Octave -> [Pitch] -> [Pitch]
aumentaOctava _ [] = []
aumentaOctava o ((pc, oc):resto) = (pc, oc + o) : aumentaOctava o resto


-- encaja se usa cuando sabemos que todas las voces del patron ritmico caen en alguna voz del acorde, la [Pitch]
encaja :: [Pitch] -> URV -> [(Pitch, Ligado, Acento)]
encaja lp [] = []
encaja lp ( (voz, acento, ligado) : resto) = ( lp !! (voz-1), ligado, acento) : encaja lp resto


-- dameElementoSeguro: cuando el indice esta entre 0 y la longitud-1 de la lista se comporta igual que !!
-- pero cuando se sale de dicho rango devuelve siempre el elemento mayor, es decir, el que ocupa la
-- posicion longitud-1
dameElementoSeguro :: [a] -> Int -> a
dameElementoSeguro lista indice
	| (longitud-1) >= indice && indice >= 0 = lista !! indice
	| otherwise = lista !! (longitud - 1)
		where longitud = length lista



-- repetirInfinito: Repite la lista un numero infinito de veces. Util para repetir un patron infinitas veces
repetirInfinito :: [a] -> [a]
repetirInfinito lista = aplanar [ lista | x<-[1..]]

-- Dada una lista de listas la deja es una lista
aplanar :: [[a]] -> [a]
aplanar ll = foldr (++) [] ll








-- FUNCIONES

-- fusionaPatrones: dado un patron vertical y uno horizontal los fusiona en un patron ritmico.
--fusionaPatrones :: PatronVertical -> PatronHorizontal -> PatronRitmico
--fusionaPatrones pv ph = fusionaPatrones2 (repetirInfinito pv) (repetirInfinito ph)

--fusionaPatrones2 :: PatronVertical -> PatronHorizontal -> PatronRitmico
--fusionaPatrones2 (urv : restoPV) ((ac, dur) : restoPH) = (urv, (ac, dur)) : fusionaPatrones2 restoPV restoPH




------------------------------------------------------------------------------------------------------------------
------------- NOTAS LIGADAS
------------------------------------------------------------------------------------------------------------------

-- TIPOS

-- NotasLigadasVertical: es lo mismo que AcordeOrdenado pero en el que se ha sustituido el patron ritmico en el. 
-- La lista de Music es una lista de notas que se deben interpretar a la vez. El valor booleano que las acompaña
-- indica si esa nota esta ligada a una nota posterior. De sa forma podemos realizar el efecto de una nota que
-- perdura en el tiempo mientras las otras voces del acorde se mueven
type NotasLigadasVertical = [(Music,Ligado)] 

-- NotasLigadas: es una lista de notas que se interpretan a la vez (NotasLigadasVertical) junto a una duracion.
-- En realidad dicha duracion indica cuanto debemos esperar hasta la ejecucion de las liguientes notasLigadasVerticales
type NotasLigadas = [(NotasLigadasVertical,Dur)]


-- FUNCIONES

{-
-- consumeVertical: fusiona un patron ritmico y un acorde ordenado (disgregado en alturas y duracion) en las notas ligadas
consumeVertical :: [Pitch] -> Dur -> PatronRitmico -> NotasLigadas
consumeVertical lp durAcorde _ 
	| durAcorde <= 0 = []
consumeVertical lp durAcorde ((urv, (acento, dur)) : resto) = 
	(insertaAcentoYDur acento dur (encaja lp urv), dur) : consumeVertical lp (durAcorde - dur) resto

-}






----------------------------------------------------------


-- buscaNota: busca la altura en la lista de notasLigadasVertical y devuelve su duracion si la encuentra o 0%1 si no
buscaNota :: Pitch -> NotasLigadasVertical -> Dur
buscaNota _ [] = 0%1
buscaNota pitch ((Note pitch2 dur _, _) : resto) 
	| pitch == pitch2 = dur
buscaNota pitch ( _ : resto) = buscaNota pitch resto


-- eliminaNota: busca una nota con la misma altura que pitch y la elimina de la lista
eliminaNota :: Pitch -> NotasLigadasVertical -> NotasLigadasVertical
eliminaNota _ [] = []
eliminaNota pitch ((Note pitch2 dur _, _) : resto) 
	| pitch == pitch2 = resto
eliminaNota pitch ( notaLigada : resto) = notaLigada : eliminaNota pitch resto


-- NOTA: CAMBIAR EL NOMBRE DE ESTE PREDICADO POR ARREGLA_CABEZA YA QUE ES MAS CONSECUENTE CON LO QUE HACE
-- buscaTodasNotas: a este predicado se le pasa la cabeza de la lista ya arreglada (sin ligaduras) y la lista anterior
-- de notas verticales. Lo que hace esta funcion es buscar cada nota con ligadura de la primera lista en la segunda. 
-- En caso de que la encuentre (que deberia si el patron esta bien hecho aunque no pasa nada si no lo hace) elimina la 
-- nota de la segunda lista y añade su duracion a la nota de la primera (una ligadura de las de siempre).
-- De esa forma las notas bien ligadas se van acumulando en la cabeza de la lista (en este caso el primer parametro)
buscaTodasNotas :: NotasLigadasVertical -> NotasLigadasVertical -> ( NotasLigadasVertical , NotasLigadasVertical )
buscaTodasNotas notas1 notas2 = buscaTodasNotas2 notas1 [] notas2

buscaTodasNotas2 :: NotasLigadasVertical -> NotasLigadasVertical -> NotasLigadasVertical -> (NotasLigadasVertical, NotasLigadasVertical)
buscaTodasNotas2 [] notas1 notas2 = ( notas1, notas2 )
buscaTodasNotas2 (( nota, False ) : restoPitch ) notas1 notas2  = buscaTodasNotas2 restoPitch ((nota,False):notas1) notas2
buscaTodasNotas2 (( Note pitch dur lA, True ) : restoPitch ) notas1 notas2 = 
	buscaTodasNotas2 restoPitch ((Note pitch (dur + buscaNota pitch notas2) lA, False):notas1) (eliminaNota pitch notas2)


-- notnull: devuelve falso si la lista es vacia y cierto en caso contrario
notnull :: [a] -> Bool
notnull [] = False
notnull _ = True


-- Elimina las notas ligadas de la lista notasLigadas
eliminaLigaduras :: NotasLigadas -> NotasLigadas
eliminaLigaduras [n] = [n]
eliminaLigaduras ((notasVerticales, dur) : resto) = let { 	eliminadas = eliminaLigaduras resto ;
										cabeza = head eliminadas ;
										arregladoCabeza = buscaTodasNotas notasVerticales (fst cabeza)
						}  in  (fst arregladoCabeza, dur) : (snd arregladoCabeza, snd cabeza) : tail eliminadas


-- deNotasLigadasAMusica: dada la lista de notas ligadas (ya sea bien arregladas o no) las pasa a musica Haskore
deNotasLigadasAMusica :: NotasLigadas -> Music
deNotasLigadasAMusica = deNotasLigadasAMusica2 (0%1)

-- deNotasLigadasAMusica2: es la funcion recursiva de deNotasLigadasAMusica y con acumulador.
-- El parametro dur indica la duracion que hay que dejar hasta el comiento de la cancion antes de interpretar 
-- las notas ligadas a tratar
deNotasLigadasAMusica2 :: Dur -> NotasLigadas -> Music
deNotasLigadasAMusica2 dur [(nV,_)] = Rest dur :+: paraleliza nV
deNotasLigadasAMusica2 dur ((nV,dur2):resto) = (Rest dur :+: paraleliza nV) :=: deNotasLigadasAMusica2 (dur + dur2) resto 


-- paraleliza: ejecuta en paralelo a lista de musica sin intereserse por el parametro booleano
paraleliza :: [( Music, Bool )] -> Music
paraleliza [] = Rest (0%1)
paraleliza [ ( nota, _ ) ] = nota
paraleliza (( nota, _ ):resto) = nota :=: paraleliza resto




{-




numNotas :: Int
numNotas = 10

progresion :: Progresion
progresion = [((I,Maj7),1%1),((V7 IV,Sept),1%1),((IV, Maj7),1%1),((V, Sept),1%1),((I,Mayor),1%1)]

patronH :: URH
patronH = 1%(4*numNotas)

patronV1 :: PatronRitmico
patronV1 = [ 	([(1, 100, True),(2, 100, True),(3, 100, False)] , 1%12 ), 
		([(1, 100, True),(2, 100, True),(4, 100, False)] , 1%12 ), 
		([(1, 100, False),(2, 100, False),(5, 100, False)] , 1%12 ) 
	]

patronV2 :: PatronRitmico
patronV2 = [ ( [(i, 100, False)], patronH ) | i<-[1..numNotas]]

traduccion1 :: [AcordeOrdenado]
traduccion1 = traduceProgresionSistemaContinuo numNotas progresion

musica1 :: Music
musica1 = deAcordesOrdenadosAMusica NoCiclico (Truncar1, Truncar2) patronV1 numNotas traduccion1 



-}