-- PARSER BASADO EN EL ARTICULO: Jeroen Fokker
-- 				 Functional Parsers
--				 in: Johan Jeuring and Erik Meijer (eds.)
--				     Advanced Functional Programming
--				     Fst. Int. School on Advanced Functional Programming Techniques
--				     Tutorial Text
--				     Springer LNCS 925, pp. 1-23, 1995


module PrologAMidi where
import HaskoreAMidi
import Haskore
import Ratio
-- import Parsers
import Parser_library

-- Lee un archivo de texto con una musica en nuestro formato de prolog y lo transforma en un midi (valores por
-- defecto por ahora) en la ruta destino especificada
hazArchivoMidi :: String -> String -> IO ()
hazArchivoMidi rutaOrigen rutaDestino = do texto <- readFile rutaOrigen
	   				   haskoreAMidi (hazMusica texto) rutaDestino

hazMusica :: String -> Music
hazMusica cadena = if null resultados
		      then error "esto no es una música"
		      else if null (fst resul1)
			      then snd resul1
			      else error "esto no es una música"
		   where resultados = parserMusica cadena
			 resul1     = head resultados

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

-- instrumento :: Parser Char Music
--- instrumento = (token "tras") *> parenthesized( (natural <* coma) <*> parserMusica ) <@f
--                where f = \(a,b) -> Trans a b

-- nomInstrumento :: Parser Char IName
-- nomInstrumento = token "instrumento" *> parenthesized (parToken)
--		where par

nomInstrumento :: [InstPrologAHaskell] -> Parser Char IName
nomInstrumento lista = token "instrumento" *> parenthesized (parToken)
		where parToken = choice (map f lista)
                      f (string, nombre) = token string <@ const nombre


type InstPrologAHaskell = (String, IName)

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


-- además solo funciona con parejas de naturales
parserParejaARatio :: Parser Char (Ratio Int)
parserParejaARatio = parenthesized( (natural <* coma) <*> natural ) <@ f
                     where f = \(a,b) -> a%b

open = symbol '('
close = symbol ')'
coma = symbol ','

-- auxiliar para pruebas
cancioncilla :: Music
cancioncilla = Instr "piano" (Tempo (3%1) (
	(c 4 wn [])
	:=: (qnr :+: (e 4 wn []))
	:=: (qnr :+: qnr :+: (g 4 wn []))
	:=: (qnr :+: qnr :+: qnr :+: (b 4 wn []))
	))
