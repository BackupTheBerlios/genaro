-- PARSER BASADO EN EL ARTICULO: Jeroen Fokker
-- 				 Functional Parsers
--				 in: Johan Jeuring and Erik Meijer (eds.)
--				     Advanced Functional Programming
--				     Fst. Int. School on Advanced Functional Programming Techniques
--				     Tutorial Text
--				     Springer LNCS 925, pp. 1-23, 1995


module PrologAHaskell where
-- import HaskoreAMidi
import Haskore
import Basics
import Ratio
import Parser_library
import Parsers

hazMusica :: String -> Music
hazMusica = aplicaParser parserMusica

-- parserMusica :: String -> [(String, Music)]
parserMusica :: Parser Char Music
-- [(resto, musica)] = parserMusica cadena :
-- cadena es la entrada del analizador
-- resto es lo que queda de cadena por analizar
-- musica es el resultado del analisis
parserMusica = foldr genToken musBase [composicion]

type OpToken a = (String, a->a->a)
genToken  ::  [OpToken a] -> Parser Char a -> Parser Char a
genToken ops p  =  chainr p (choice (map f ops))
       where  f (s,c) = token s <@ const c

composicion = [(":+:", (:+:)), (":=:", (:=:))]

musBase :: Parser Char Music
{- viejo, hace más caso a Jerome pq el Rest lo hace musBase no silencio
musBase =   silencio
            <@ Rest
            la siguiente linea mala creo
        <|> nota <*> altura <*> figura
-}
musBase =  silencio
       <|> nota
       <|> tempo
       <|> trasposicion
       <|> instrumento
       <|> parenthesized parserMusica

silencio :: Parser Char Music
silencio = (token "silencio" *> (parenthesized figura)) <@ Rest

--tb muy parecida a altura, se podría hacer otra de alto nivel
nota :: Parser Char Music
nota = ( (token "nota") *> parenthesized(altura <*> ((token "," ) *> figura)) ) <@ f
	where f = \(alt, fig) -> Note alt fig []

altura :: Parser Char Pitch
altura = (token "altura") *> parenthesized(numNota <*> ((token "," ) *> octava))

-- en el futuro hacer func de alto nivel pq todo es similar
tempo :: Parser Char Music
tempo = ( (token "tempo") *> parenthesized( (parserParejaARatio <* coma) <*> parserMusica ) ) <@ f
        where f = \(a,b) -> Tempo a b

trasposicion :: Parser Char Music
trasposicion = (token "tras") *> parenthesized( (natural <* coma) <*> parserMusica ) <@f
                where f = \(a,b) -> Trans a b

instrumento :: Parser Char Music
instrumento = (token "inst") *> parenthesized( ((nomInstrumento nuestrosInstrumentos) <* coma) <*> parserMusica ) <@f
               where f = \(a,b) -> Instr a b

nomInstrumento :: [InstPrologAHaskell] -> Parser Char IName
nomInstrumento lista = token "instrumento" *> parenthesized (parToken)
		where parToken = choice [token string <@ const nombre | (string, nombre) <- lista]


lala :: (String, IName) -> Parser Char IName
lala (s, n) = token s <@ const n

lalaList :: [(String, IName)] -> Parser Char IName
lalaList xs = choice [token s <@ const n | (s,n) <- xs]

type InstPrologAHaskell = (String, IName)
-- en realidad esta correspondencia es poco importante pq luego en Timidity asignaremos
-- a cada instrumento midi la fuente que nos parezca
nuestrosInstrumentos :: [InstPrologAHaskell]
nuestrosInstrumentos = [("mano_izquierda", "AcousticGrandPiano")
                      , ("mano_derecha", "AcousticGrandPiano")
                      , ("bajo", "FretlessBass")
                      , ("bateria", "Percussion")
                      ]

-- no uso la funcion pitch :: Int -> Pitch pq Haskore cuenta 0 como C y nosotros 0 como A
numNota :: Parser Char PitchClass
numNota = ( (token "numNota") *> parenthesized(natural) ) <@ numAPitchClass

-- en caso de entrada no valida devuelve Cf como marca de error = cutrez!HACER TODO
-- CON MAYBE MAS TARDE!!!!!!!!!!!! Eleccion arbitraria entre las notas enarmónicas
-- TB EN EL FUTURO HACER FUNC DE ORDEN SUPERIOR PARA PARSER SIMILARES COMO numNota, octava, silencio..
numAPitchClass :: Int -> PitchClass
numAPitchClass n
        | n == 0    = A
        | n == 1    = As
        | n == 2    = B
        | n == 3    = C
        | n == 4    = Cs
        | n == 5    = D
        | n == 6    = Ds
        | n == 7    = E
        | n == 8    = F
        | n == 9    = Fs
        | n == 10    = G
        | n == 11    = Gs
        | otherwise = Cf

octava :: Parser Char Octave
octava = (token "octava") *> parenthesized(natural)

figura :: Parser Char Dur
figura = (token "figura") *> parserParejaARatio

-- auxiliar para pruebas
cancioncilla :: Music
cancioncilla = Instr "piano" (Tempo (3%1) (
	(c 4 wn [])
	:=: (qnr :+: (e 4 wn []))
	:=: (qnr :+: qnr :+: (g 4 wn []))
	:=: (qnr :+: qnr :+: qnr :+: (b 4 wn []))
	))

--
-- PARSER VIEJO PARA EL RITMO
--

-- version vieja
type AcordeOrdenadoMusic = [Music]

hazProgresionOrdenadaMusic :: String -> [AcordeOrdenadoMusic]
hazProgresionOrdenadaMusic = aplicaParser parserProgresionOrdenadaMusic

-- coge un String en el formato especificado en biblio_genaro_acordes:es_lista_orden_acordes
-- y devuelve la lista de acordes ordenados correspondiente, es decir, de acordes con sus voces
-- ya elegidas
parserProgresionOrdenadaMusic :: Parser Char [AcordeOrdenadoMusic]
parserProgresionOrdenadaMusic = (token "progOrdenada") *> parenthesized(parserListaOrdenAcsMusic)

-- coge un String en el formato especificado en biblio_genaro_acordes:es_lista_orden_acordes
-- y devuelve la lista de acordes ordenados correspondiente, es decir, de acordes con sus voces
-- ya elegidas
parserListaOrdenAcsMusic :: Parser Char [AcordeOrdenadoMusic]
parserListaOrdenAcsMusic = bracketed(commaList(parserParAcordeFigura)) <@ daFiguraAListaAcordes
		      where parserParAcordeFigura = parenthesized( (parserAcordeOrdMusic <* coma) <*> figura)
                            daFiguraAListaAcordes = map daFiguraAAcorde
                            daFiguraAAcorde (acorde, figura) = map (\(Note a _ l) -> (Note a figura l)) acorde


-- lee un String q corresponde a un termino Prolog T que cumple biblio_genaro_acorde:es_acorde(T)
-- y devuelve  un valor de tipo AcordeOrdenado asignando por defecto la duracion de redonda a todas
-- las notas
parserAcordeOrdMusic :: Parser Char AcordeOrdenadoMusic
parserAcordeOrdMusic = (token "acorde") *> parenthesized(bracketed(commaList(altura))) <@f
                where f = map (\altura -> Note altura wn [])

--
--
-- PARSER DEFINITIVO PARA EL RITMO
--

-- version definitiva empleada en Ritmo.hs, lo suyo sería terminar importándolo
type AcordeOrdenado = ([Pitch],Dur)

hazProgresionOrdenada :: String -> [AcordeOrdenado]
hazProgresionOrdenada = aplicaParser parserProgresionOrdenada

-- coge un String en el formato especificado en biblio_genaro_acordes:es_lista_orden_acordes
-- y devuelve la lista de acordes ordenados correspondiente, es decir, de acordes con sus voces
-- ya elegidas
parserProgresionOrdenada :: Parser Char [AcordeOrdenado]
parserProgresionOrdenada = (token "progOrdenada") *> parenthesized(parserListaOrdenAcs)


-- coge un String en el formato especificado en biblio_genaro_acordes:es_lista_orden_acordes
-- y devuelve la lista de acordes ordenados correspondiente, es decir, de acordes con sus voces
-- ya elegidas
parserListaOrdenAcs :: Parser Char [AcordeOrdenado]
parserListaOrdenAcs = bracketed(commaList(parserParAcordeFigura))
		      where parserParAcordeFigura = parenthesized( (parserAcordeOrd <* coma) <*> figura )


-- lee un String q corresponde a un termino Prolog T que cumple biblio_genaro_acorde:es_acorde(T)
-- y devuelve  un valor de tipo AcordeOrdenado asignando por defecto la duracion de redonda a todas
-- las notas
parserAcordeOrd :: Parser Char [Pitch]
parserAcordeOrd = (token "acorde") *> parenthesized(bracketed(commaList(altura)))
