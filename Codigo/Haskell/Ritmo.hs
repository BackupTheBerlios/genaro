

module Ritmo 
where

import Haskore
import Ratio
import PrologAHaskell


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
type PatronRitmico = [ ( URV, Acento, Dur )]


-- FUNCIONES

-- fusionaPatrones: dado un patron vertical y uno horizontal los fusiona en un patron ritmico.
fusionaPatrones :: PatronVertical -> PatronHorizontal -> PatronRitmico
fusionaPatrones pv ph = fusionaPatrones2 (repetirInfinito pv) (repetirInfinito ph)

fusionaPatrones2 :: PatronVertical -> PatronHorizontal -> PatronRitmico
fusionaPatrones2 (urv : restoPV) ((ac, dur) : restoPH) = (urv, ac, dur) : fusionaPatrones2 restoPV restoPH


-- encaja: encaja una lista de alturas con una unidad de ritmo vertical.
-- El resultado es una lista en el que se ha filtrado las alturas en funcion de URV y el valor booleano
-- que indica la ligadura con una nota posterior
encaja :: [Pitch] -> URV -> [(Pitch, Bool)]
encaja lp [] = []
encaja lp ( (voz, ligado) : resto) = ( lp !! (voz-1), ligado) : encaja lp resto


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
-- La lista de Music es una lista de notas que se deben interpretar a la vez. El valor booleano que las acompaña
-- indica si esa nota esta ligada a una nota posterior. De sa forma podemos realizar el efecto de una nota que
-- perdura en el tiempo mientras las otras voces del acorde se mueven
type NotasLigadasVertical = [(Music,Bool)]

-- NotasLigadas: es una lista de notas que se interpretan a la vez (NotasLigadasVertical) junto a una duracion.
-- En realidad dicha duracion indica cuanto debemos esperar hasta la ejecucion de las liguientes notasLigadasVerticales
type NotasLigadas = [(NotasLigadasVertical,Dur)]


-- FUNCIONES

-- consumeVertical: fusiona un patron ritmico y un acorde ordenado (disgregado en alturas y duracion) en las notas ligadas
consumeVertical :: [Pitch] -> Dur -> PatronRitmico -> NotasLigadas
consumeVertical lp durAcorde _ 
	| durAcorde <= 0 = []
consumeVertical lp durAcorde ((urv, acento, dur) : resto) = 
	(insertaAcentoYDur acento dur (encaja lp urv), dur) : consumeVertical lp (durAcorde - dur) resto


-- insertaAcentoYDur: introduce el acento (volumen) y la duracion en la lista de alturas para formar la lista de notas
insertaAcentoYDur :: Acento -> Dur -> [(Pitch, Bool)] -> [(Music, Bool)]
insertaAcentoYDur _ dur [] = [(Rest dur, False)]
insertaAcentoYDur acento dur [(pitch, ligado)] = [ ( Note pitch dur [Volume acento] , ligado ) ]
insertaAcentoYDur acento dur lp = insertaAcentoYDur2 acento dur lp

insertaAcentoYDur2 :: Acento -> Dur -> [(Pitch, Bool)] -> [(Music, Bool)]
insertaAcentoYDur2 acento dur [(pitch, ligado)] = [ ( Note pitch dur [Volume acento] , ligado ) ]
insertaAcentoYDur2 acento dur ((pitch, ligado) : resto) = 
	( Note pitch dur [Volume acento] , ligado ) : insertaAcentoYDur2 acento dur resto


-- deAcordeOrdenadoANotasLigadas: junta un acorde ordenado y un patron ritmico en notas ligadas
deAcordeOrdenadoANotasLigadas :: PatronRitmico -> AcordeOrdenado -> NotasLigadas
deAcordeOrdenadoANotasLigadas pr (lp, durAcorde) = consumeVertical lp durAcorde pr

-- deAcordesOrdenadosANotasLigadas: junta una lista de acordes ordenados y un patron ritmico en notas ligadas
deAcordesOrdenadosANotasLigadas :: PatronRitmico -> [AcordeOrdenado] -> NotasLigadas
deAcordesOrdenadosANotasLigadas pr lao = foldr (++) [] (map (deAcordeOrdenadoANotasLigadas pr) lao)

-- deAcordesOrdenadosANotasLigadas2: junta una lista de acordes ordenados y un patron ritmico
-- en forma de patron vertical y horizontal en notas ligadas
deAcordesOrdenadosANotasLigadas2 :: PatronVertical -> PatronHorizontal -> [AcordeOrdenado] -> NotasLigadas
deAcordesOrdenadosANotasLigadas2 pV pH lao = foldr (++) [] (map (deAcordeOrdenadoANotasLigadas (fusionaPatrones pV pH)) lao)

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



-- Usando todas las funciones anterior pasa una lista de acordes ordenados con los patrones a Haskore
deAcordesOrdenadosAMusica :: [AcordeOrdenado] -> PatronVertical -> PatronHorizontal -> Music
deAcordesOrdenadosAMusica lao pV pH = deNotasLigadasAMusica (  (eliminaLigaduras (deAcordesOrdenadosANotasLigadas2 pV pH lao)))




