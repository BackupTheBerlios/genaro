module CAHaskell where
import PatronesRitmicos
import Haskore
import Ratio
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
-- se tienen en cuenta los ligados
type Voz = Int
type Acento = Float  -- Acento: intensidad con que se ejecuta ese tiempo. Valor de 0 a 100
type Ligado = Bool
type URV = [(Voz, Acento, Ligado)]	-- Unidad de ritmo vertical
type URH = Dur 				-- Unidad de ritmo horizontal
type UPR = ( URV , URH)
type PatronRitmico = [UPR]
type AlturaPatron = Int			-- numero maximo de voces que posee el patron

-}
{- TIPOS DE DATOS QUE REPRESENTAN LO DEVUELTO POR EL ANALISIS DEL STRING CORRESPONDIENTE AL FICHERO JAVA SOBRE PATRONES
RITMICOS
-}
data FichPatronRitmicoC = FPRC Voces Cols Resolucion PatronRitmico
	deriving(Show,Eq,Ord)
type Voces = Int
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
PARSERS
-}
parserFichPatronRitmicoC :: Parser Char FichPatronRitmicoC
parserFichPatronRitmicoC = (parserVoces <*> parserCols <*> parserResolucion <*> parserCPatsMatriz) <@ formatea
			where 	parserVoces = (token "VOCES" *> (espacio *> natural)) <* saltoDLinea
				parserCols = (token "COLUMNAS" *> (espacio *> natural)) <* saltoDLinea
				parserResolucion = (token "RESOLUCION" *> (espacio *> natural)) <* saltoDLinea
                        	formatea x = FPRC (voz x) (col x) (1 % (res x)) (patronRit x)
				voz x = fst x
				col x = fst (snd x)
				res x = fst (snd (snd x))
				matriz x  = snd (snd (snd x))
                                patronRit x = matrizCAPatronRitmico (1 % (res x)) (matriz x)

matrizCAPatronRitmico :: Dur -> MatrizCPatrones -> PatronRitmico
matrizCAPatronRitmico resolucion matriz = [(procesaUPR 1 (invertir fila), resolucion) | fila <- matTraspuesta]
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
