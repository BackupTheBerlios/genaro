

module Ritmo 
where

import Haskore
import Ratio
import PrologAHaskell
import Progresiones
--import TraduceCifrados

------------------------------------------------------------------------------------------------------------------
------------- MODOS DE APLICACION DEL PATRON RITMICO
------------------------------------------------------------------------------------------------------------------

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
-- Ciclico: si X esta entre A+1 y P (incluidos) entonces a�adimos tantas notas como sea necesario al acorde
--  aumentando la octava
-- Modulo: si X esta entre A+1 y P entonces cambiamos X por ((X-1) mod A)+1. Esto nos asegura que X cae siempre
--  entre 1 y A
data ModoPatronVerticalPosibles2 = Truncar2 | Saturar2 | Ciclico2 | Modulo2
	deriving (Enum, Bounded, Eq, Ord, Show, Read)

-- El primer valor para cuando A>P, el segundo para A<P
type ModoPatronVertical = (ModoPatronVerticalPosibles1 , ModoPatronVerticalPosibles2 )

------------------------------------------------------------------------------------------------------------------
------------- PATRON HORIZONTAL
------------------------------------------------------------------------------------------------------------------

-- TIPOS

-- Acento: intensidad con que se ejecuta ese tiempo. Valor de 0 a 100
type Acento = Float

-- Unidad de Ritmo Horizontal: division que hacemos de la linea temporal o linea horizontal
type URH = (Acento, Dur)

-- El patron ritmico horizontal se compone de una lista infinita de URH
type PatronHorizontal = [URH]


-- CONSTANTES

-- parte fuerte del compas
fuerte :: Acento
fuerte = 100

-- parte debil del compas
debil :: Acento
debil = 50

-- parte semifuerte del compas
semifuerte :: Acento
semifuerte = 70

dos_dos :: PatronHorizontal
dos_dos = [(fuerte, 1%2),(debil, 1%2)]

tres_dos :: PatronHorizontal
tres_dos = [(fuerte, 1%2),(debil, 1%2),(debil, 1%2)]

cuatro_cuatro :: PatronHorizontal
cuatro_cuatro = [(fuerte, 1%4),(debil, 1%4),(semifuerte, 1%4),(debil, 1%4)]

tres_cuatro :: PatronHorizontal
tres_cuatro = [(fuerte, 1%4),(debil, 1%4),(debil, 1%4)]

seis_cuatro :: PatronHorizontal
seis_cuatro = [(fuerte, 1%4),(debil, 1%4),(debil, 1%4),(semifuerte, 1%4),(debil, 1%4),(debil, 1%4)]


-- FUNCIONES

escala :: PatronHorizontal -> Dur -> PatronHorizontal
escala [] _ = []
escala ((acento, dur):resto) dur2 = (acento,dur*dur2) : escala resto dur2


------------------------------------------------------------------------------------------------------------------
------------- PATRON VERTICAL
------------------------------------------------------------------------------------------------------------------

-- TIPOS

-- Voz: indica la voz de acorde empezando desde abajo (no es exactamente el mismo conceto de voz de musica).
type Voz = Int  -- de 1 a 5

-- Unidad de Ritmo Vertical: la lista de voces que se ejecutan a la vez y si esta ligada con otra nota consecutiva
type URV = [(Voz, Bool)]

-- Patron ritmico vertical es una lista infinita de unidades verticales
type PatronVertical = [URV]



------------------------------------------------------------------------------------------------------------------
------------- PATRON RITMICO
------------------------------------------------------------------------------------------------------------------

--TIPOS

-- El patron ritmico completo se compone de una lista con informacion vertical y horizontal
-- Para que sea coherente con el resto del programa un PatronRitmico es una lista infinita que encaja
-- con la informacion de los acordes ordenados para formar las notas. Cuando se encaja con los acordes
-- ordenados (que es una lista finita) el patron ritmico se trunca.
type PatronRitmico = [ (URV, URH)]


-- FUNCIONES

-- fusionaPatrones: dado un patron vertical y uno horizontal los fusiona en un patron ritmico.
fusionaPatrones :: PatronVertical -> PatronHorizontal -> PatronRitmico
fusionaPatrones pv ph = fusionaPatrones2 (repetirInfinito pv) (repetirInfinito ph)

fusionaPatrones2 :: PatronVertical -> PatronHorizontal -> PatronRitmico
fusionaPatrones2 (urv : restoPV) ((ac, dur) : restoPH) = (urv, (ac, dur)) : fusionaPatrones2 restoPV restoPH


-- Encaja un patron vertical con una [Pitch] segun algun modo
encajaModo :: ModoPatronVertical -> Int -> [Pitch] -> URV -> [(Pitch, Bool)]
encajaModo (m1, m2) alturaPatron lp urv 
	| alturaPatron == longitud 				= encajaA_Mayor_P_Truncar lp urv
	| alturaPatron > longitud && m1 == Truncar1 	= encajaA_Mayor_P_Truncar lp urv
	| alturaPatron > longitud && m1 == Saturar1 	= encajaA_Mayor_P_Saturar alturaPatron lp urv
	| alturaPatron < longitud && m2 == Truncar2 	= encajaA_Menor_P_Truncar lp urv
	| alturaPatron < longitud && m2 == Saturar2 	= encajaA_Menor_P_Saturar lp urv
	| alturaPatron < longitud && m2 == Ciclico2 	= encajaA_Menor_P_Ciclico lp urv
	| alturaPatron < longitud && m2 == Modulo2 	= encajaA_Menor_P_Modulo lp urv
		where longitud = length lp


encajaA_Mayor_P_Truncar :: [Pitch] -> URV -> [(Pitch, Bool)]
encajaA_Mayor_P_Truncar = encaja 

encajaA_Mayor_P_Saturar :: Int -> [Pitch] -> URV -> [(Pitch, Bool)]
encajaA_Mayor_P_Saturar alturaPatron lp urv = encaja lp (arregla alturaPatron (length lp) urv)

-- cambiamos el patron vertical para que se cumpla el caso de A>P con saturacion.
-- Si existe algun elemento que tenga una voz igual a P entonces a�adimos las notas que faltan, desde la P+1 hasta A
arregla :: Int -> Int -> URV -> URV
arregla _ _ [] = []
arregla alturaP alturaA ((voz,ligado):resto) 
	| alturaP == voz 	= ((voz,ligado):resto) ++ [(i, ligado) | i <- [(alturaP + 1) .. alturaA]]
	| otherwise		= (voz,ligado) : arregla alturaP alturaA resto


encajaA_Menor_P_Modulo :: [Pitch] -> URV -> [(Pitch, Bool)]
encajaA_Menor_P_Modulo lp urv = encaja lp (arregla2 (length lp) urv)

-- Hacemos que todas las voces del patron sea ((Voz-1) mod A)+1 para que caigan entre 1 y A
arregla2 :: Int -> URV -> URV
arregla2 _ [] = []
arregla2 alturaA ((voz,ligado):resto) = (1 + mod (voz -1) alturaA, ligado) : arregla2 alturaA resto


-- igual que encaja pero en vez de usar (!!) usa dameElementoSeguro
encajaA_Menor_P_Saturar :: [Pitch] -> URV -> [(Pitch, Bool)]
encajaA_Menor_P_Saturar lp [] = []
encajaA_Menor_P_Saturar lp ( (voz, ligado) : resto) = ( dameElementoSeguro lp (voz-1), ligado) : encajaA_Menor_P_Saturar lp resto


encajaA_Menor_P_Truncar :: [Pitch] -> URV -> [(Pitch, Bool)]
encajaA_Menor_P_Truncar lp [] = []
encajaA_Menor_P_Truncar lp ( (voz, ligado) : resto) 
	| longitud >= voz		= ( lp !! (voz-1), ligado) : encajaA_Menor_P_Truncar lp resto
	| longitud < voz		= encajaA_Menor_P_Truncar lp resto
		where longitud = length lp


encajaA_Menor_P_Ciclico :: [Pitch] -> URV -> [(Pitch, Bool)]
encajaA_Menor_P_Ciclico lp urv = encaja (repetirCiclico lp) urv


-- NOTA: VA MAL, IDEA: HACER ALGO PARECIDO A LO DE ARREGLA_OCTAVA
-- Repite infinitamente el acorde, puesto como [Pitch], aumentado la octava cada vez
repetirCiclico :: [Pitch] -> [Pitch]
repetirCiclico lp@((pc, oc) : resto)
	| pc <= pcu	= lp ++ repetirCiclico (aumentaOctava (oc +1) lp)
	| pc > pcu	= lp ++ repetirCiclico (aumentaOctava oc lp)
	where ultimo = last lp ;
		pcu = fst ultimo ;
		ocu = snd ultimo 

aumentaOctava :: Octave -> [Pitch] -> [Pitch]
aumentaOctava _ [] = []
aumentaOctava o ((pc, oc):resto) = (pc, oc + o) : aumentaOctava o resto


-- encaja se usa cuando sabemos que todas las voces del patron ritmico caen en alguna voz del acorde, la [Pitch]
encaja :: [Pitch] -> URV -> [(Pitch, Bool)]
encaja lp [] = []
encaja lp ( (voz, ligado) : resto) = ( lp !! (voz-1), ligado) : encaja lp resto


-- dameElementoSeguro: cuando el indice esta entre 0 y la longitud-1 de la lista se comporta igual que !!
-- pero cuando se sale de dicho rango devuelve siempre el elemento mayor, es decir, el que ocupa la
-- posicion longitud-1
dameElementoSeguro :: [a] -> Int -> a
dameElementoSeguro lista indice
	| (longitud-1) >= indice && indice >= 0 = lista !! indice
	| otherwise = lista !! (longitud - 1)
		where longitud = length lista



-- CONSTANTES

-- Algunos patrones verticales (pensados solo para cuatro voces)

arpegio :: PatronVertical
arpegio = [[(1,False)],[(2,False)],[(3,False)],[(4,False)]]

acorde :: PatronVertical
acorde = [[ (1,False) , (2,False) , (3,False) , (4,False) ]]

patronRitmo1 :: PatronVertical
patronRitmo1 = [ [(1,True)] , [(1,False),(2,False),(3,False),(4,False)] ]

patronRitmo2 :: PatronVertical
patronRitmo2 = [ [(1,False)] , [(3,False)] , [(2,False)] , [(4,False)]]

patronRitmo3 :: PatronVertical
patronRitmo3 = [ [(1,False)] , [(2,False)] , [(1,False)] , [(3,False)] , [(1,False)] ,[(4,False)]]

patronRitmo4 :: PatronVertical
patronRitmo4 = [[(1,False),(3,False)],[],[(2,False),(4,False)],[]]

patronRitmo5 :: PatronVertical
patronRitmo5 = [[(1,True)],[(1,True),(2,True)],[(1,True),(2,True),(3,True)],[(1,False),(2,False),(3,False),(4,False)]]

patronRitmo6 :: PatronVertical
patronRitmo6 = [[(1,True)],[(1,True)],[(1,True)],[(1,False)]]

patronRitmo7 :: PatronVertical
patronRitmo7 = [[(1,True),(2, False)] , [(1,True),(3,False)] , [(1,False),(4,False)]]



-- FUNCIONES AUXILIARES

-- repetirInfinito: Repite la lista un numero infinito de veces. Util para repetir un patron infinitas veces
repetirInfinito :: [a] -> [a]
repetirInfinito lista = aplanar [ lista | x<-[1..]]

-- Dada una lista de listas la deja es una lista
aplanar :: [[a]] -> [a]
aplanar ll = foldr (++) [] ll


------------------------------------------------------------------------------------------------------------------
------------- NOTAS LIGADAS
------------------------------------------------------------------------------------------------------------------

-- TIPOS

-- NotasLigadasVertical: es lo mismo que AcordeOrdenado pero en el que se ha sustituido el patron ritmico en el. 
-- La lista de Music es una lista de notas que se deben interpretar a la vez. El valor booleano que las acompa�a
-- indica si esa nota esta ligada a una nota posterior. De sa forma podemos realizar el efecto de una nota que
-- perdura en el tiempo mientras las otras voces del acorde se mueven
type NotasLigadasVertical = [(Music,Bool)]

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


-- insertaAcentoYDur: introduce el acento (volumen) y la duracion en la lista de alturas para formar la lista de notas
insertaAcentoYDur :: Acento -> Dur -> [(Pitch, Bool)] -> [(Music, Bool)]
insertaAcentoYDur _ dur [] = [(Rest dur, False)]
insertaAcentoYDur acento dur [(pitch, ligado)] = [ ( Note pitch dur [Volume acento] , ligado ) ]
insertaAcentoYDur acento dur lp = insertaAcentoYDur2 acento dur lp

insertaAcentoYDur2 :: Acento -> Dur -> [(Pitch, Bool)] -> [(Music, Bool)]
insertaAcentoYDur2 acento dur [(pitch, ligado)] = [ ( Note pitch dur [Volume acento] , ligado ) ]
insertaAcentoYDur2 acento dur ((pitch, ligado) : resto) = 
	( Note pitch dur [Volume acento] , ligado ) : insertaAcentoYDur2 acento dur resto



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
-- nota de la segunda lista y a�ade su duracion a la nota de la primera (una ligadura de las de siempre).
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




------------------------------------------------------------------------------------------------------
-- DIFINITIVO
------------------------------------------------------------------------------------------------------


deAcordesOrdenadosAMusica :: ModoPatronHorizontal -> ModoPatronVertical -> PatronVertical -> PatronHorizontal -> Int -> [AcordeOrdenado] -> Music
deAcordesOrdenadosAMusica mH mV pV pH alturaP lao = 
	deNotasLigadasAMusica ( (eliminaLigaduras (deAcordesOrdenadosANotasLigadas mH mV (fusionaPatrones pV pH) alturaP lao)))


deAcordesOrdenadosAMusica2 :: ModoPatronHorizontal -> ModoPatronVertical -> PatronRitmico -> Int -> [AcordeOrdenado] -> Music
deAcordesOrdenadosAMusica2 mH mV pR alturaP lao = 
	deNotasLigadasAMusica ( (eliminaLigaduras (deAcordesOrdenadosANotasLigadas mH mV pR alturaP lao)))



deAcordesOrdenadosANotasLigadas :: ModoPatronHorizontal -> ModoPatronVertical -> PatronRitmico -> Int -> [AcordeOrdenado] -> NotasLigadas
deAcordesOrdenadosANotasLigadas mH mV pR alturaP lao
	| mH == Ciclico 		= consumeVerticalCiclico mV lao pR alturaP
	| mH == NoCiclico		= foldr (++) [] (map (deAcordeOrdenadoANotasLigadasNoCiclico mV pR alturaP) lao)


-- deAcordeOrdenadoANotasLigadasNoCiclico: junta un acorde ordenado y un patron ritmico en notas ligadas
deAcordeOrdenadoANotasLigadasNoCiclico :: ModoPatronVertical -> PatronRitmico -> Int -> AcordeOrdenado -> NotasLigadas
deAcordeOrdenadoANotasLigadasNoCiclico mV pR alturaP (lp, durAcorde) = consumeVerticalNoCiclico mV lp durAcorde pR alturaP


-- consumeVertical: fusiona un patron ritmico y un acorde ordenado (disgregado en alturas y duracion) en las notas ligadas
-- Cuando se acaba el acorde vuelve a empezar el patron ritmico
consumeVerticalNoCiclico :: ModoPatronVertical -> [Pitch] -> Dur -> PatronRitmico -> Int -> NotasLigadas
consumeVerticalNoCiclico mV lp durAcorde ((urv, (acento, durH)) : resto) alturaP
	| durAcorde == durH = ( insertaAcentoYDur acento durH (encajaModo mV alturaP lp urv) , durH ) : []
	| durAcorde < durH = ( insertaAcentoYDur acento durAcorde (encajaModo mV alturaP lp urv) , durAcorde ) : []
	| durAcorde > durH = (insertaAcentoYDur acento durH (encajaModo mV alturaP lp urv), durH) : consumeVerticalNoCiclico mV lp (durAcorde - durH) resto alturaP 


-- Cuando se acaba el acorde no vuelve a empezar el patron ritmico sino que continua con el elemento que le toque
consumeVerticalCiclico :: ModoPatronVertical -> [AcordeOrdenado] -> PatronRitmico -> Int -> NotasLigadas
consumeVerticalCiclico _ [] _ _ = []
consumeVerticalCiclico mV ((lp,durA) : restoA) ( (urv, (acento, durH)) : restoH) alturaP 
	| durA > durH = 
		(insertaAcentoYDur acento durH (encajaModo mV alturaP lp urv), durH) : consumeVerticalCiclico mV ((lp,durA-durH):restoA) restoH alturaP 
	| durA == durH =  
		(insertaAcentoYDur acento durH (encajaModo mV alturaP lp urv), durH) : consumeVerticalCiclico mV restoA restoH alturaP 
	| durA < durH = 
		(insertaAcentoYDur acento durA (encajaModo mV alturaP lp urv), durA) : consumeVerticalCiclico mV restoA ((urv,(acento,durH-durA)):restoH) alturaP 


-----------BORRAME YA---------------

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
musica1 = deAcordesOrdenadosAMusica Ciclico (Truncar1, Truncar2) patronV2 patronH numNotas traduccion1 

-}










