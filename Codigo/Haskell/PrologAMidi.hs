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
parserMusica _ = [([], cancioncilla)]


-- lista de todos de los tokens de la entrada
listaTokens :: [String]
listaTokens = ["nota", "altura"]

listaBlancos :: [String]
listaBlancos =["\n", "\t", " "]


-- hazMusica _ = cancioncilla
-- auxiliar para pruebas
cancioncilla :: Music
cancioncilla = Instr "piano" (Tempo (3%1) (
	(c 4 wn [])
	:=: (qnr :+: (e 4 wn []))
	:=: (qnr :+: qnr :+: (g 4 wn []))
	:=: (qnr :+: qnr :+: qnr :+: (b 4 wn []))
	))

type Op a = (Char, a->a->a)
gen  ::  [Op a] -> Parser Char a -> Parser Char a
gen ops p  =  chainr p (choice (map f ops))
       where  f (s,c) = symbol s <@ const c

{-
musBase :: Parser Char Music
musBase =   silencio
            <@ Rest
        <|> nota <*> altura <*> figura
-}
silencio :: Parser Char Music
silencio = token "silencio" <*> (parenthesized figura)

figura :: Parser Char (Ratio Int)
figura = token "figura" *> parAFrac

parAFrac :: Parser Char (Ratio Int)
parAFrac = (parenthesized natural <* (token ",") *> parenthesized natural)
            <@ (uncurry(%))

-- cutrez
{-
-- Type-definition for parsetree

data Expr = Con Int
          | Var String
          | Fun String [Expr]
          | Expr :+: Expr
          | Expr :-: Expr
          | Expr :*: Expr
          | Expr :/: Expr

-------------------------------------------------------------
-- Parser for expressions with aribitrary many priorities

type Op a = (Char, a->a->a)

fact' :: Parser Char Expr
fact' =     integer
            <@ Con
        <|> identifier
            <*> (option (parenthesized (commaList expr')) <?@ (Var,flip Fun))
            <@ ap'
        <|> parenthesized expr'

gen  ::  [Op a] -> Parser Char a -> Parser Char a
gen ops p  =  chainr p (choice (map f ops))
       where  f (s,c) = symbol s <@ const c

expr' :: Parser Char Expr
expr'  =  foldr gen fact' [addis, multis]

multis  =  [ ('*',(:*:)), ('/',(:/:)) ]
addis   =  [ ('+',(:+:)), ('-',(:-:)) ]

-}
---------------------------------------------------------------------
-- written by:
-- Jeroen Fokker                                 |  jeroen@cs.ruu.nl
-- dept.of Computer Science, Utrecht University  |  tel.+31-30-2534129
-- PObox 80089, 3508TB Utrecht, the Netherlands  |  fax.+31-30-2513791