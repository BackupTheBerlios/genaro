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
		      then error "esto no es una m�sica"
		      else if null (fst resul1)
			      then snd resul1
			      else error "esto no es una m�sica"
		   where resultados = parserMusica cadena
			 resul1     = head resultados

-- parserMusica :: String -> [(String, Music)]
parserMusica :: Parser Char Music
-- [(resto, musica)] = parserMusica cadena :
-- cadena es la entrada del analizador
-- resto es lo que queda de cadena por analizar
-- musica es el resultado del analisis
parserMusica = foldr genToken musBase [composicion]

-- auxiliar para pruebas
cancioncilla :: Music
cancioncilla = Instr "piano" (Tempo (3%1) (
	(c 4 wn [])
	:=: (qnr :+: (e 4 wn []))
	:=: (qnr :+: qnr :+: (g 4 wn []))
	:=: (qnr :+: qnr :+: qnr :+: (b 4 wn []))
	))

type OpToken a = (String, a->a->a)
genToken  ::  [OpToken a] -> Parser Char a -> Parser Char a
genToken ops p  =  chainr p (choice (map f ops))
       where  f (s,c) = token s <@ const c

composicion = [(":+:", (:+:)), (":=:", (:=:))]

parenthesizedONO :: Parser Char a -> Parser Char a
parenthesizedONO parser = parenthesized parser
		 <|> parser

comeParentesis :: Parser Char a -> Parser Char a
-- comeParentesis parser = foldparens fst parser
-- comeParentesis parser = (foldparens fst ()) *> parser
{-comeParentesis parser = p1 *> parser
	where p1 = (open *> p1 <* close) <*> p1 <@ fst
        	<|> todo -}

comeParentesis parser = p1 *> parser
	where p1 = (open *> p1 <* close)
        	<|> todo

pepe :: Parser Char String
pepe = (open *> pepe <* close)
	<|>  notSymbols ['(',')']


foldparens :: ((a,a) -> a) -> a -> Parser Char a
foldparens f e = p
	where p = (open *> p <* close) <*> p <@ f
        	<|> succeed e

todo :: Parser a [a]
todo xs = [(xs,xs)]

-- notSymbols :: Eq s  =>  [s] -> Parser s s
-- notSymbols :: String -> Parser Char Char
notSymbols :: String -> Parser Char String
notSymbols ss [] = []
notSymbols ss (x:xs) = [(x:xs, x:xs) | not (elem x ss)]


open = symbol '('
close = symbol ')'
data Tree = Nil
          | Bin (Tree, Tree)
          deriving Show

parens :: Parser Char Tree
parens = foldparens Bin Nil

musBase :: Parser Char Music
{- viejo, hace m�s caso a Jerome pq el Rest lo hace musBase no silencio
musBase =   silencio
            <@ Rest
            la siguiente linea mala creo
        <|> nota <*> altura <*> figura
-}
musBase =   silencio
       <|> nota

silencio :: Parser Char Music
silencio = (token "silencio" *> (parenthesized figura)) <@ Rest

--tb muy parecida a altura, se podr�a hacer otra de alto nivel
nota :: Parser Char Music
nota = ( (token "nota") *> parenthesized(altura <*> ((token "," ) *> figura)) ) <@ f
	where f = \(alt, fig) -> Note alt fig []

altura :: Parser Char Pitch
altura = (token "altura") *> parenthesized(numNota <*> ((token "," ) *> octava))

-- no uso la funcion pitch :: Int -> Pitch pq Haskore cuenta 0 como C y nosotros 0 como A
numNota :: Parser Char PitchClass
numNota = ( (token "numNota") *> parenthesized(natural) ) <@ numAPitchClass

-- en caso de entrada no valida devuelve Cf como marca de error = cutrez!HACER TODO
-- CON MAYBE MAS TARDE!!!!!!!!!!!! Eleccion arbitraria entre las notas enarm�nicas
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
figura = ((token "figura") *> parenthesized(commaList natural)) <@ parejaARatio

parejaARatio :: [Int] -> (Ratio Int)
parejaARatio [] = 0%1
parejaARatio [_] = 0%1
parejaARatio [a,b] = a%b
parejaARatio (_:_:xs) = 0%1

---------------------------------------------------------------------
-- written by:
-- Jeroen Fokker                                 |  jeroen@cs.ruu.nl
-- dept.of Computer Science, Utrecht University  |  tel.+31-30-2534129
-- PObox 80089, 3508TB Utrecht, the Netherlands  |  fax.+31-30-2513791
