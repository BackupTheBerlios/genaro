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
import Parser_library
import PrologAHaskell

-- Lee un archivo de texto con una musica en nuestro formato de prolog y lo transforma en un midi (valores por
-- defecto por ahora) en la ruta destino especificada
hazArchivoMidi :: String -> String -> IO ()
hazArchivoMidi rutaOrigen rutaDestino = do texto <- readFile rutaOrigen
	   				   haskoreAMidi (hazMusica texto) rutaDestino


-- solo para pruebas, no hay patrones ritmicos aun
progresionPrologAMidi :: String -> String -> IO ()
progresionPrologAMidi rutaOrigen rutaDestino = do texto <- readFile rutaOrigen
                                                  haskoreAMidi (stringProgresionAMusic texto) rutaDestino

stringProgresionAMusic :: String -> Music
stringProgresionAMusic texto = line (map chord listaAcordes)
                               where listaAcordes = hazProgresionOrdenadaMusic texto

-- solo para pruebas, no hay patrones ritmicos aun
progresionPrologAMidi2 :: String -> String -> IO ()
progresionPrologAMidi2 rutaOrigen rutaDestino = do texto <- readFile rutaOrigen
                                                   haskoreAMidi (stringProgresionAMusic2 texto) rutaDestino

stringProgresionAMusic2 :: String -> Music
stringProgresionAMusic2 texto = Tempo 4 (line (map line listaAcordes))
                               where listaAcordes = hazProgresionOrdenadaMusic texto

