module JavaAHaskell where
import Ritmo
import Ratio
import Parser_library
import Parsers
import BiblioGenaro

{-
>type Acento = Float
>type URH = (Acento, Dur)
>type PatronHorizontal = [URH]

[(1,1%2),(2,2%3)]


>type Voz = Int
>type URV = [(Voz, Bool)]
>type PatronVertical = [URV]

[[(3,True),(5,False)]]
-}
{-
VOCES 3 \n
COLUMNAS 6 \n
RESOLUCION 64 \n
LIGADO LIGADO SIMPLE SILENCIO SIMPLE SIMPLE FIN \n
LIGADO LIGADO SIMPLE SILENCIO SIMPLE SILENCIO FIN \n
SIMPLE SILENCIO SIMPLE SIMPLE SILENCIO SILENCIO FIN
------------------------------------------------------------------------------------------
Los guiones no son parte del fichero, y el \n simboliza el fín de línea.
La resolución es 1/ número especificado
Ligado viene representado en el editor por el color ROJO, Simple por el color AMARILLO y Silencio por el color BLANCO
-}
data TokenJavaPatrones = Ligado|Simple|Silencio
     deriving(Enum,Read,Show,Eq,Ord,Bounded)

listaTokenJavaPatrones :: [(String, TokenJavaPatrones)]
listaTokenJavaPatrones = [("LIGADO",Ligado),("SIMPLE",Simple),("SILENCIO",Silencio)]

parserTokenJavaPats :: Parser Char TokenJavaPatrones
parserTokenJavaPats = listaParesTokenDatoAParser listaTokenJavaPatrones

{-
Se come la parte de la matriz de un fichero Java y devuelve una lista en la que cada elemento es una fila de esta matriz,
empezando por la de arriba, que será la cabeza. Cada fila será a su vez una lista de elementos de tipo TokenJavaPatrones,
claro. Pero por el formato del fichero y que es una matriz podemos suponer:
	- que todas las filas tienen el mismo numero de elementos
        -que todas las filas terminan en FIN \n, tokens que no metemos en la salida pq no nos sirven para nada
-}
parserJavaPatsMatriz :: Parser Char [[TokenJavaPatrones]]
parserJavaPatsMatriz = listaSeparadaChar '\n' parserFila
			where parserFila = (listaSeparadaChar ' ' parserTokenJavaPats) <* (token " FIN")

matrizJavaAPatVertical :: [[TokenJavaPatrones]] -> PatronVertical
matrizJavaAPatVertical matriz = [procesaURV 1 fila | fila <- matTraspuesta]
		                 where matTraspuesta = trasponer matriz
                                       procesaURV _ [] = []
                                       procesaURV n (Silencio:xs) = procesaURV (n+1) xs
                                       procesaURV n (Simple:xs) = (n, False): (procesaURV (n+1) xs)
                                       procesaURV n (Ligado:xs) = (n, True): (procesaURV (n+1) xs)

pruebaParserMatriz :: String -> IO()
-- pruebaParserMatriz rutaOrigen = do prog <- leeYParsea parserJavaPatsMatriz rutaOrigen
--                                   putStr (show prog)
pruebaParserMatriz rutaOrigen = do texto <- readFile rutaOrigen
                                   putStr ( show (head ( parserJavaPatsMatriz texto)))
pruebaParserMatriz2 :: String -> IO()
pruebaParserMatriz2 rutaOrigen = do texto <- readFile rutaOrigen
                                    putStr ( show (matrizJavaAPatVertical(snd(head ( parserJavaPatsMatriz texto)))))

{-
Parsea un string con un formato igual que el tipo PatronHorizontal para obtener
valores de este mismo tipo. Ver Parser_library.hs para ver el tipo Parser (aqui iría
un link si supiera como ponerlo)
-}
parserPatronHorizontal :: Parser Char PatronHorizontal
parserPatronHorizontal = bracketed(commaList(parserURH))
		      where parserURH = parenthesized( (float <* coma) <*> parserRatioARatio )

{-
Esta función parsea el archivo de texto especificado con la ruta que es el String que es su único parámetro
, y devuelve error si falla el análisis o el primer resultado del parseo como IO si no. Se parsea un archivo
de texto con un formato igual que el tipo PatronHorizontal para obtener valores de este mismo tipo
-}
leePatronHorizontal :: String -> IO PatronHorizontal
leePatronHorizontal = leeYParsea parserPatronHorizontal

{-
Parsea un string con un formato igual que el tipo PatronVertical para obtener
valores de este mismo tipo. Ver Parser_library.hs para ver el tipo Parser (aqui iría
un link si supiera como ponerlo)
-}
parserPatronVertical :: Parser Char PatronVertical
parserPatronVertical = bracketed(commaList(parserURV))
		      where parserURV = bracketed(commaList(parserUnidadURV))
                            parserUnidadURV = parenthesized((integer <* coma) <*> parserBool)

{-
Esta función parsea el archivo de texto especificado con la ruta que es el String que es su único parámetro
, y devuelve error si falla el análisis o el primer resultado del parseo como IO si no. Se parsea un archivo
de texto con un formato igual que el tipo PatronVertical para obtener valores de este mismo tipo
-}
leePatronVertical :: String -> IO PatronVertical
leePatronVertical = leeYParsea parserPatronVertical
