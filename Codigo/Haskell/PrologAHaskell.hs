-- PARSERS BASADOS EN EL ARTICULO: Jeroen Fokker
-- 				 Functional Parsers
--				 in: Johan Jeuring and Erik Meijer (eds.)
--				     Advanced Functional Programming
--				     Fst. Int. School on Advanced Functional Programming Techniques
--				     Tutorial Text
--				     Springer LNCS 925, pp. 1-23, 1995


module PrologAHaskell where
import Haskore
import Ratio
import Parser_library
import Parsers
import Progresiones

hazMusica :: String -> Music
hazMusica = (aplicaParser parserMusica) . quitaEspacios

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
hazProgresionOrdenadaMusic = (aplicaParser parserProgresionOrdenadaMusic) . quitaEspacios

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
hazProgresionOrdenada = (aplicaParser parserProgresionOrdenada) . quitaEspacios

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


--
--
--	PARSER DE PROGRESIONES DE ACORDES EN PROLOG
--
--
{--
lo de Prolog

es_progresion(progresion(P)) :- es_listaDeCifrados(P).

es_listaDeCifrados([]).
es_listaDeCifrados([(C, F)|Cs]) :- es_cifrado(C), es_figura(F)
       ,es_listaDeCifrados(Cs).

es_cifrado(cifrado(G,M)) :- es_grado(G), es_matricula(M).
es_matricula(matricula(M)) :- member(M, [mayor,m,au,dis,6,m6,m7b5, maj7,7,m7,mMaj7,au7,dis7]).

es_interSimple(interSimple(G)) :- member(G, [i, bii, ii, biii, iii, iv, bv, v, auv, vi, bvii, vii]).
%raros
es_interSimple(interSimple(G)) :- member(G, [bbii, bbiii, auii, biv, auiii, auiv, bbvi, bvi, auvi, bviii, auviii ]).

%GRADOS
es_grado(grado(G)) :- es_interSimple(interSimple(G)).
es_grado(grado(v7 / G)) :- es_grado(grado(G)).
es_grado(grado(iim7 / G)) :- es_grado(grado(G)).

-}
parserProgresion :: Parser Char Progresion
parserProgresion = (token "progresion") *> parenthesized(bracketed(commaList(parCifDur)))
		where parCifDur = parenthesized ((parserCifrado <* coma) <*> figura)
-- parserProgresion = bracketed(commaList(parCifDur))
--		where parCifDur = parenthesized ((parserCifrado <* coma) <*> figura)
{--
Pruebas de parserProgresion
-}
pruebaParserProgresion :: String -> IO()
pruebaParserProgresion rutaOrigen = do prog <- leeYParsea parserProgresion rutaOrigen
                                       putStr (show prog)

parserCifrado :: Parser Char Cifrado
parserCifrado = token "cifrado" *> parenthesized ((parserGrado <* coma) <*> parserMatricula)

parserGrado :: Parser Char Grado
parserGrado = token "grado" *> parserGradoAux

parserGradoAux :: Parser Char Grado
parserGradoAux = parserGradoSimpleAux
                 <|> (token "v7/" *> parserGradoAux) <@ V7
                 <|> (token "iim7/" *> parserGradoAux) <@ IIM7
                 <|> parenthesized parserGradoAux

{-
Parsea cosas del estilo "v", "vi"
-}
parserGradoSimpleAux :: Parser Char Grado
-- parserGradoSimpleAux = choice [token string <@ const grado | (string, grado) <- listaTokenGrado]
parserGradoSimpleAux = listaParesTokenDatoAParser listaTokenGrado

listaTokenGrado :: [(String, Grado)]
listaTokenGrado = [("i",I),("bii",BII),("ii",II),("biii",BIII),("iii",III),("iv",IV),("bv",BV),("v",V),
                   ("auv",AUV),("vi",VI),("bvii",BVII),("vii",VII),("bbii",BBII),("bbiii",BBIII),("auii",AUII),
                   ("biv",BIV),("auiii",AUIII),("auiv",AUIV),("bbvi",BBVI),("bvi",BVI),("auvi",AUVI),
                   ("bviii",BVIII),("auviii",AUVIII)]

parserMatricula :: Parser Char Matricula
parserMatricula = token "matricula" *> parenthesized(listaParesTokenDatoAParser listaTokenMatricula)

listaTokenMatricula :: [(String, Matricula)]
listaTokenMatricula = [("mayor",Mayor),("m",Menor),("au",Au),("dis",Dis),("6",Sexta),("m6",Men6),
                       ("m7b5",Men7B5),("maj7",Maj7),("7",Sept),("m7",Men7),("mMaj7",MenMaj7),("au7",Au7),
                       ("dis7",Dis7)]
