

module Ritmo 
where

import Haskore
import Ratio
--import PrologAHaskell


---------------------------------------------------------

-- como me gustaria que fuese AcordeOrdenado
type AcordeOrdenado2 = ([Pitch],Dur)

---------------------------------------------------------


-- CAMBIAR: CAMBIAR A INT QUE PARECE MAS ADECUADO
-- de 0 a 100
type Acento = Float

-- Unidad de Ritmo Horizontal
type URH = (Acento, Dur)

-- El patron ritmico horizontal se compone de una lista infinita de URH
type PatronHorizontal = [URH]

-- Constantes del ritmo horizontal

-- parte fuerte del compas
fuerte :: Acento
fuerte = 100

-- parte debil del compas
debil :: Acento
debil = 50

-- parte semifuerte del compas
semifuerte :: Acento
semifuerte = 70


-- Voz indica la voz de acorde empezando desde abajo (no es exactamente el mismo conceto de voz).
type Voz = Int -- de 1 a 5

-- Unidad de Ritmo Vertical: la lista de voces que se ejecutan a la vez y si esta ligada con otra nota consecutiva
type URV = [(Voz, Bool)]

-- Patron ritmico vertical es una lista infinita de unidades verticales
type PatronVertical = [URV]

-- El patron ritmico completo se compone de una lista con informacion vertical y horizontal
type PatronRitmico = [ ( URV, Acento, Dur )]


-- Funciones que operan con patrones
fusionaPatrones :: PatronVertical -> PatronHorizontal -> PatronRitmico
fusionaPatrones pv ph = fusionaPatrones2 (repetirInfinito pv) (repetirInfinito ph)

fusionaPatrones2 :: PatronVertical -> PatronHorizontal -> PatronRitmico
fusionaPatrones2 (urv : restoPV) ((ac, dur) : restoPH) = (urv, ac, dur) : fusionaPatrones2 restoPV restoPH


-- Algunas constantes ritmicas

arpegio :: PatronVertical  -- pensada solo para cuatro voces
arpegio = [[(1,False)],[(2,False)],[(3,False)],[(4,False)]]

acorde :: PatronVertical  -- pensada solo para cuatro voces
acorde = [[ (1,False) , (2,False) , (3,False) , (4,False) ]]

patronRitmo1 :: PatronVertical
patronRitmo1 = [ [(1,True)] , [(1,False),(2,False),(3,False),(4,False)] ]

patronRitmo2 :: PatronVertical
patronRitmo2 = [ [(1,False)] , [(3,False)] , [(2,False)] , [(4,False)]]

patronRitmo3 :: PatronVertical
patronRitmo3 = [ [(1,False)] , [(2,False)] , [(1,False)] , [(3,False)] , [(1,False)] ,[(4,False)]]

patronRitmo4 :: PatronVertical
patronRitmo4 = [[(1,False),(3,False)],[],[(2,False),(4,False)],[]]


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


escala :: PatronHorizontal -> Dur -> PatronHorizontal
escala [] _ = []
escala ((acento, dur):resto) dur2 = (acento,dur*dur2) : escala resto dur2




-- Funciones para la aplicacion de patrones ritmicos a acordes ordenados

-- Repite la lista un numero infinito de veces
repetirInfinito :: [a] -> [a]
repetirInfinito lista = aplanar [ lista | x<-[1..]]

aplanar :: [[a]] -> [a]
aplanar ll = foldr (++) [] ll



encaja :: [Pitch] -> URV -> [(Pitch, Bool)]
encaja lp [] = []
encaja lp ( (voz, ligado) : resto) = ( lp !! (voz-1), ligado) : encaja lp resto


consumeVertical :: [Pitch] -> Dur -> PatronRitmico -> [[( Music, Bool )]]
consumeVertical lp durAcorde _ 
	| durAcorde <= 0 = []
consumeVertical lp durAcorde ((urv, acento, dur) : resto) = 
	insertaAcentoYDur acento dur (encaja lp urv) : consumeVertical lp (durAcorde - dur) resto



-- IMPORTANTE: falta poner bien el acento, es decir el paso de Int a Float
insertaAcentoYDur :: Acento -> Dur -> [(Pitch, Bool)] -> [(Music, Bool)]
insertaAcentoYDur _ dur [] = [(Rest dur, False)]
insertaAcentoYDur acento dur [(pitch, ligado)] = [ ( Note pitch dur [Volume acento] , False ) ]
insertaAcentoYDur acento dur lp = insertaAcentoYDur2 acento dur lp

insertaAcentoYDur2 :: Acento -> Dur -> [(Pitch, Bool)] -> [(Music, Bool)]
insertaAcentoYDur2 acento dur [(pitch, ligado)] = [ ( Note pitch dur [Volume acento] , False ) ]
insertaAcentoYDur2 acento dur ((pitch, ligado) : resto) = 
	( Note pitch dur [Volume acento] , False ) : insertaAcentoYDur2 acento dur resto



deAcordeOrdenadoANotasLigadas :: AcordeOrdenado2 -> PatronRitmico -> [[( Music, Bool )]]
deAcordeOrdenadoANotasLigadas (lp, durAcorde) pr = consumeVertical lp durAcorde pr




-- Este predicado habria que cambiarlo para realizar la ligadura correctamente
deNotasLigadasAMusica :: [[( Music, Bool )]] -> Music
deNotasLigadasAMusica [ listaNotasLigadas ] = paraleliza listaNotasLigadas
deNotasLigadasAMusica ( listaNotasLigadas : resto ) = paraleliza listaNotasLigadas :+: deNotasLigadasAMusica resto


paraleliza :: [( Music, Bool )] -> Music
paraleliza [ ( nota, _ ) ] = nota
paraleliza (( nota, _ ):resto) = nota :=: paraleliza resto


---------------------------------
-- Ejemplos
--------------------------------


--acorde de CMaj7
cMaj7 :: [Pitch]
cMaj7 = [(C,4),(E,4),(G,4),(B,4)]

--acorde de G7
g7 :: [Pitch]
g7 = [(G,4),(B,4),(D,5),(F,5)]

--acorde de D-7
dm7 :: [Pitch]
dm7 = [(D,4),(F,4),(A,4),(C,5)]


--progresion armonica simple
prog1 :: [AcordeOrdenado2]
prog1 = [(cMaj7,1%1),(g7,1%1)]

prog2 :: [AcordeOrdenado2]
prog2 = [(cMaj7,1%2),(g7,1%2)]

prog3 :: [AcordeOrdenado2]
prog3 = [(cMaj7,6%4),(g7,6%2)]


prog4 :: AcordeOrdenado2
prog4 = (cMaj7,1%2)

prog5 :: AcordeOrdenado2
prog5 = (g7,1%2)

musica1 :: Music
musica1 = deNotasLigadasAMusica (deAcordeOrdenadoANotasLigadas (cMaj7,1%4) (fusionaPatrones arpegio (escala cuatro_cuatro (1%8) )))

musica2 :: Music
musica2 = deNotasLigadasAMusica (deAcordeOrdenadoANotasLigadas (dm7,1%4) (fusionaPatrones arpegio (escala cuatro_cuatro (1%8) )))

musica5 :: Music
musica5 = deNotasLigadasAMusica (deAcordeOrdenadoANotasLigadas prog5 (fusionaPatrones patronRitmo4 (escala cuatro_cuatro (1%4)) ))

musica6 :: Music
musica6 = deNotasLigadasAMusica (deAcordeOrdenadoANotasLigadas prog5 (fusionaPatrones acorde dos_dos ))

musica7 :: Music
musica7 = deNotasLigadasAMusica (deAcordeOrdenadoANotasLigadas prog4 (fusionaPatrones acorde dos_dos ))




