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
import Parsers


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
