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
parserMusica = foldr genTokenParens musBase [composicion]

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

genTokenParens  ::  [OpToken a] -> Parser Char a -> Parser Char a
genTokenParens ops p  =  chainr (comeParentesis p) (choice (map f ops))
       where  f (s,c) = token s <@ const c

composicion = [(":+:", (:+:)), (":=:", (:=:))]

parenthesizedONO :: Parser Char a -> Parser Char a
parenthesizedONO parser = parenthesized parser
		 <|> parser

comeParentesis :: Parser Char a -> Parser Char a
comeParentesis parser xs = [(resto, resul) | (restoPre, resulPre) <- comeParentesisAux xs
                                           ,(resto, resul) <- parser resulPre
                                           ]

-- hacer func de alto nivel luego
pepe :: Parser Char String
pepe = (open *> pepe <* close)
	<|>  notSymbolsCad ['(',')']

comeParentesisAux :: Parser Char String
comeParentesisAux xs = [("", centro)]
	 where (sinPref, numAbre) = dropWhileCuantos ((==) '(') xs
               centro = dropLast numAbre sinPref

takeWhileCuantos :: (a -> Bool) -> [a] -> ([a], Int)
takeWhileCuantos _ [] = ([], 0)
takeWhileCuantos cond (x:xs)
  | cond x	= (x:listaResul, valResul + 1)
  | otherwise = ([], 0)
  		where (listaResul, valResul) = takeWhileCuantos cond xs

dropWhileCuantos :: (a -> Bool) -> [a] -> ([a], Int)
dropWhileCuantos _ [] = ([], 0)
dropWhileCuantos cond xs@(x:xs')
  | cond x	= (listaResul, valResul + 1)
  | otherwise = (xs, 0)
  		where (listaResul, valResul) = dropWhileCuantos cond xs'

foldparens :: ((a,a) -> a) -> a -> Parser Char a
foldparens f e = p
	where p = (open *> p <* close) <*> p <@ f
        	<|> succeed e

todo :: Parser a [a]
todo xs = [(xs,xs)]

notSymbols :: Eq s  =>  [s] -> Parser s s
notSymbols ss [] = []
notSymbols ss (x:xs) = [(xs, x) | not (elem x ss)]

notSymbolsCad :: Eq s  =>  [s] -> Parser s [s]
notSymbolsCad ss [] = []
notSymbolsCad ss xs = [(resto, resul)]
                      where  resul  = takeWhile noElem xs
                             resto  = dropWhile noElem xs
                             noElem = (\x -> not (elem x ss))

takeLast :: Int -> [a] -> [a]
takeLast n = reverse . take n . reverse

dropLast :: Int -> [a] -> [a]
dropLast n = reverse . drop n . reverse

open = symbol '('
close = symbol ')'
data Tree = Nil
          | Bin (Tree, Tree)
          deriving Show

parens :: Parser Char Tree
parens = foldparens Bin Nil

musBase :: Parser Char Music
{- viejo, hace más caso a Jerome pq el Rest lo hace musBase no silencio
musBase =   silencio
            <@ Rest
            la siguiente linea mala creo
        <|> nota <*> altura <*> figura
-}
musBase =   silencio
       <|> nota

silencio :: Parser Char Music
silencio = (token "silencio" *> (parenthesized figura)) <@ Rest

--tb muy parecida a altura, se podría hacer otra de alto nivel
nota :: Parser Char Music
nota = ( (token "nota") *> parenthesized(altura <*> ((token "," ) *> figura)) ) <@ f
	where f = \(alt, fig) -> Note alt fig []

altura :: Parser Char Pitch
altura = (token "altura") *> parenthesized(numNota <*> ((token "," ) *> octava))

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
