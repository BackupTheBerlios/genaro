module CAHaskell where
import PatronesRitmicos
import Haskore
import Ratio
import Basics
import HaskoreAMidi
import Parser_library
import Parsers
import BiblioGenaro

{-
  VOCES 3\n
  COLUMNAS 6\n
  RESOLUCION 64\n
  LIGADO 12 LIGADO 12 SIMPLE 23 SILENCIO SIMPLE 34 SIMPLE 243 FIN\n
  LIGADO 12 LIGADO 12 SIMPLE 23 SILENCIO SIMPLE 23 SILENCIO FIN\n
  SIMPLE 12 SILENCIO SIMPLE 43 SIMPLE 34 SILENCIO SILENCIO FIN
------------------------------------------------------------------------------------------
la voz numero 1 es la de abajo, la 2 la de mas a rriba etc
Los guiones no son parte del fichero, y el \n simboliza el fín de línea.
La resolución es 1/ número especificado
Ligado viene representado en el editor por el color ROJO, Simple por el color AMARILLO y Silencio por el color BLANCO
-}
{-
--
-- PATRON RITMICO
--
type Voz = Int
type Acento = Float         -- Acento: intensidad con que se ejecuta ese tiempo. Valor de 0 a 100
type Ligado = Bool          -- Ligado: indica si una voz de una columna esta ligada con la se la siguiente columna
                            -- en caso de que no este dicha voz el ligado se ignora
type URV = [(Voz, Acento, Ligado)]	-- Unidad de ritmo vertical, especifica todas las filas de una unica columna
type URH = Dur 				-- Unidad de ritmo horizontal, especifica la duracion de una columna
type UPR = ( URV , URH)                 -- Unidad del patron ritmico, especifica completamente toda la informacion necesaria
                                        -- para una columna (con todas sus filas) en la matriz que representa el patron
type AlturaPatron = Int			-- numero maximo de voces que posee el patron
type MatrizRitmica = [UPR]              -- Una lista de columnas, vamos, como una matriz

type PatronRitmico = (AlturaPatron, MatrizRitmica)
-}
{- TIPOS DE DATOS QUE REPRESENTAN LO DEVUELTO POR EL ANALISIS DEL STRING CORRESPONDIENTE AL FICHERO JAVA SOBRE PATRONES
RITMICOS
-}
data FichPatronRitmicoC = FPRC Cols Resolucion PatronRitmico
	deriving(Show,Eq,Ord)
type Cols = Int
type Resolucion = Dur

{-
TIPOS DE DATOS PARA MANIPULAR LA PARTE DE MATRIZ PURA DEL FICHERO JAVA SOBRE PATRONES RITMICOS
-}
data TokenCPatrones = Ligado Acento
                     |Simple Acento
                     |Silencio
                deriving(Show,Eq,Ord)
type MatrizCPatrones = [[TokenCPatrones]]

{-
Dado un elemento de tipo FichPatronRitmicoC devuelve un music correspondiente a asociar a cada fila/voz
del patron rítmico correspondiente una nota, empezando por asociar a la primera voz el Do y siguiendo por
semitonos. A este acorde se le aplica el patron rítmico y se produce la musica
-}
fichPatRitAMusic :: FichPatronRitmicoC -> Music
fichPatRitAMusic (FPRC cols res patron@(altura, matriz)) = Trans 36 (deAcordesOrdenadosAMusica NoCiclico (Truncar1 , Truncar2) patron [acordeOrd])
                                               where duracionAcorde = (fromIntegral cols) * res
                                                     triada 0 = (C,0)
                                                     triada 1 = (E,0)
                                                     triada 2 = (G,0)
                                                     triada n
                                                      | n>2 = pitch (12 + (absPitch (triada (n-3))))
                                                     listaPitch = map triada [0..(altura - 1)]
                                                     --listaPitch = map pitch [0..(altura - 1)]
                                                     acordeOrd = (listaPitch, duracionAcorde)

fichPatRitAMidi :: String -> IO()
fichPatRitAMidi ruta = do putStr mensajeProcesandoPatronRit
                          ficheroPatron <- leePatronRitmicoC ruta
                          putStr mensajeGenerandoMidi
                          haskoreAMidi (fichPatRitAMusic ficheroPatron) rutaDestinoMidi
                          where rutaDestinoMidi = (invertir (tail (dropWhile (/='.') (invertir ruta)))) ++ ".mid"
                                mensajeProcesandoPatronRit = "\n Procesando el archivo de patron ritmico de C: " ++ ruta ++ "\n"
                                mensajeGenerandoMidi = "\n Generando el archivo midi: " ++ rutaDestinoMidi ++ "\n"

{-
PARSERS
-}
parserFichPatronRitmicoC :: Parser Char FichPatronRitmicoC
parserFichPatronRitmicoC = ((parserVoces <*> parserCols <*> parserResolucion <*> parserCPatsMatriz) <@ formatea) . quitaFormatoDOS
			where 	parserVoces = (token "VOCES" *> (espacio *> natural)) <* saltoDLinea
				parserCols = (token "COLUMNAS" *> (espacio *> natural)) <* saltoDLinea
				parserResolucion = (token "RESOLUCION" *> (espacio *> natural)) <* saltoDLinea
                        	formatea x = FPRC (col x) (1 % (res x)) (patronRit x)
				voz x = fst x
				col x = fst (snd x)
				res x = fst (snd (snd x))
				matrizIn x  = snd (snd (snd x))
                                matrizRitmica x = matrizCAMatrizRitmica (1 % (res x)) (matrizIn x)
                                patronRit x = (voz x, matrizRitmica x)

matrizCAMatrizRitmica :: Dur -> MatrizCPatrones -> MatrizRitmica
matrizCAMatrizRitmica resolucion matriz = [(procesaUPR 1 (invertir fila), resolucion) | fila <- matTraspuesta]
		                 where matTraspuesta = trasponer matriz
                                       procesaUPR _ [] = []
                                       procesaUPR pos (Silencio:xs) = procesaUPR (pos+1) xs
                                       procesaUPR pos ((Simple acento):xs) = (pos, acento, False): (procesaUPR (pos+1) xs)
                                       procesaUPR pos ((Ligado acento):xs) = (pos, acento, True): (procesaUPR (pos+1) xs)

{-
Se come la parte de la matriz de un fichero C y devuelve una lista en la que cada elemento es una fila de esta matriz,
empezando por la de arriba, que será la cabeza. Cada fila será a su vez una lista de elementos de tipo TokenCPatrones,
claro. Pero por el formato del fichero y que es una matriz podemos suponer:
	- que todas las filas tienen el mismo numero de elementos
        -que todas las filas terminan en FIN \n, tokens que no metemos en la salida pq no nos sirven para nada
-}
parserCPatsMatriz :: Parser Char MatrizCPatrones
parserCPatsMatriz = listaSeparadaChar '\n' parserFila
			where parserFila = (listaSeparadaChar ' ' parserTokenCPats) <* (espacio <*> token "FIN")

parserTokenCPats :: Parser Char TokenCPatrones
parserTokenCPats = token "SILENCIO" <@ const Silencio
                <|> ((token "LIGADO" <* espacio) <*> integer ) <@ (\(t,i)-> Ligado (fromIntegral i))
                <|> ((token "SIMPLE" <* espacio) <*> integer ) <@ (\(t,i)-> Simple (fromIntegral i))

{-
PRUEBAS
-}
pruebaParserMatriz :: String -> IO()
pruebaParserMatriz rutaOrigen = do texto <- readFile rutaOrigen
                                   putStr ( show (head ( parserCPatsMatriz texto)))


pruebaParserFichPatronRitmicoC :: String -> IO()
pruebaParserFichPatronRitmicoC rutaOrigen = do texto <- readFile rutaOrigen
                                               putStr ( show (head ( parserFichPatronRitmicoC texto)))

{-
Esta es la función que deben llamar otros modulos, dada una ruta lee el fichero en ella y realiza todo el
analisis
-}
leePatronRitmicoC :: String -> IO FichPatronRitmicoC
leePatronRitmicoC ruta = do texto <- readFile ruta
                            return ((aplicaParser parserFichPatronRitmicoC) texto)
