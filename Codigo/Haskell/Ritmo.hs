

-- Codigo super cutre y sin terminar, a espera de mejora y de organizacion
-- Lo unico que sirve son los ejemplos del final

module Ritmo 
where

import Haskore
import Ratio
import PrologAHaskell

type Acento = Int  -- de 0 a 100

type Golpe = (Acento, Dur)

-- Unidad de Ritmo Horizontal
data URH = 	Binario URH URH
		| Ternario URH URH URH
		| Duracion Dur
	deriving (Eq, Show)


escalar :: Dur -> URH -> URH
escalar dur1 (Duracion dur2) = Duracion (dur1*dur2)
escalar dur (Binario urh1 urh2) = Binario (escalar dur urh1) (escalar dur urh2)
escalar dur (Ternario urh1 urh2 urh3) = Ternario (escalar dur urh1) (escalar dur urh2) (escalar dur urh3)


-- es como perfonmance
serializarRitmo :: URH -> [Golpe]
serializarRitmo = serializarRitmoRec fuerte

serializarRitmoRec :: Acento -> URH -> [Golpe]
serializarRitmoRec a (Binario urh1 urh2) = serializarRitmoRec fuerte urh1 ++ serializarRitmoRec debil urh2
serializarRitmoRec a (Ternario urh1 urh2 urh3) = 
		serializarRitmoRec fuerte urh1 ++ serializarRitmoRec debil urh2 ++ serializarRitmoRec debil urh3
serializarRitmoRec a (Duracion dur) = [(a,dur)]


--Constantes

-- ritmo 2/2
dos_dos :: URH
dos_dos = Binario (Duracion (1%2)) (Duracion (1%2))

-- ritmo 3/2
tres_dos :: URH
tres_dos = Ternario (Duracion (1%2)) (Duracion (1%2)) (Duracion (1%2))

-- ritmo 4/4
cuatro_cuatro :: URH
cuatro_cuatro = Binario (Binario (Duracion (1%4)) (Duracion (1%4))) (Binario (Duracion (1%4)) (Duracion (1%4)))


-- parte fuerte del compas
fuerte :: Acento
fuerte = 80

-- parte debil del compas
debil :: Acento
debil = 50

-- parte semifuerte del compas
semifuerte :: Acento
semifuerte = 70



---------------------------------------------------------

-- como me gustaria que fuese AcordeOrdenado
type AcordeOrdenado2 = ([Pitch],Dur)



-- Voz del acorde: entre 1 y 5
type Voz = Int

-- pareja de Voz y Bool, que indica si esta ligada con la siguiente nota (este parametro todavia no se usa)
type ElementoPatronRitmo = (Voz, Bool)
type PatronRitmo = [[ElementoPatronRitmo]]

arpegio :: PatronRitmo
arpegio = [ [(1,False)] , [(2,False)] , [(3,False)] , [(4,False)]]

acorde :: PatronRitmo
acorde = [ [(1,False),(2,False),(3,False),(4,False)] ]

patronRitmo1 :: PatronRitmo
patronRitmo1 = [ [(1,True)] , [(1,False),(2,False),(3,False),(4,False)] ]

patronRitmo2 :: PatronRitmo
patronRitmo2 = [ [(1,False)] , [(3,False)] , [(2,False)] , [(4,False)]]

patronRitmo3 :: PatronRitmo
patronRitmo3 = [ [(1,False)] , [(2,False)] , [(1,False)] , [(3,False)] , [(1,False)] ,[(4,False)]]

aplicaPatronRitmo :: [AcordeOrdenado2] -> PatronRitmo -> [Golpe] -> Music
aplicaPatronRitmo ao pr lg = aplicaPatronRitmo2 ao (repetirInfinito pr ) (repetirInfinito lg)


aplicaPatronRitmo2 :: [AcordeOrdenado2] -> PatronRitmo -> [Golpe] -> Music
aplicaPatronRitmo2 [(listaPitch,durAcorde)] pr lg = fusionar listaPitch durAcorde pr lg 
aplicaPatronRitmo2 ((listaPitch,durAcorde):resto) pr lg = 
	fusionar listaPitch durAcorde pr lg  :+: aplicaPatronRitmo2 (resto) pr lg


repetirInfinito :: [a] -> [a]
repetirInfinito lista = aplanar [ lista | x<-[1..]]

aplanar :: [[a]] -> [a]
aplanar ll = foldr (++) [] ll


fusionar :: [Pitch] -> Dur -> PatronRitmo -> [Golpe] -> Music
fusionar listaPitch durAcorde (listaVoces:restoPatronRitmo) ((acento,dur):restoGolpes) 
	| durAcorde <= dur = (dameNotasDeVoces listaPitch dur listaVoces)
	| durAcorde > dur = (dameNotasDeVoces listaPitch dur listaVoces) :+: (fusionar listaPitch (durAcorde-dur) restoPatronRitmo restoGolpes)


dameNotasDeVoces :: [Pitch] -> Dur -> [ElementoPatronRitmo] -> Music
dameNotasDeVoces ao dur epr = foldr (:=:) (Rest (0%1)) (dameNotasDeVocesRec ao dur epr)


dameNotasDeVocesRec :: [Pitch] -> Dur -> [ElementoPatronRitmo] -> [Music]
dameNotasDeVocesRec _ dur [] = []
dameNotasDeVocesRec ao dur ((voz,_):resto) = ( Note (ao!!(voz-1)) dur [] ) : dameNotasDeVocesRec ao dur resto



---------------------------------
-- Ejemplos
--------------------------------


--acorde de CMaj7
cMaj7 :: [Pitch]
cMaj7 = [(C,4),(E,4),(G,4),(B,4)]

--acorde de G7
g7 :: [Pitch]
g7 = [(G,4),(B,4),(D,5),(F,5)]

--progresion armonica simple
prog1 :: [AcordeOrdenado2]
prog1 = [(cMaj7,1%1),(g7,1%1)]

prog2 :: [AcordeOrdenado2]
prog2 = [(cMaj7,1%2),(g7,1%2)]

prog3 :: [AcordeOrdenado2]
prog3 = [(cMaj7,6%4),(g7,6%2)]


--Ritmo simple
ritmo1 :: [Golpe]
ritmo1 = serializarRitmo cuatro_cuatro

--Ritmo cañero
ritmo2 :: [Golpe]
ritmo2 = serializarRitmo (escalar (4%32) cuatro_cuatro)


--resultado en haskore con arpegio
musica1 :: Music
musica1 = aplicaPatronRitmo prog1 arpegio ritmo1

--resultado en haskore con acorde
musica2 :: Music
musica2 = aplicaPatronRitmo prog1 acorde ritmo1

--resultado en haskore con patronRitmo1
musica3 :: Music
musica3 = aplicaPatronRitmo prog1 patronRitmo1 ritmo1


--resultado en haskore con patron acorde y ritmo cañero
musica4 :: Music
musica4 = aplicaPatronRitmo prog1 acorde ritmo2

--resultado en haskore con patron acorde y ritmo cañero
musica5 :: Music
musica5 = aplicaPatronRitmo prog1 arpegio ritmo2


--resultado en haskore de mezclar varios patrones ritmicos
musica6 :: Music
musica6 = aplicaPatronRitmo prog1 acorde ritmo1 :+: aplicaPatronRitmo prog1 arpegio ritmo1 :+: aplicaPatronRitmo prog1 patronRitmo2 ritmo1


-- Cancioncilla chachi
ritmo3 :: [Golpe]
ritmo3 = serializarRitmo (escalar (3%12) tres_dos)

musica7 :: Music
musica7 = aplicaPatronRitmo prog3 patronRitmo3 ritmo3


