module JavaAHaskell where
import Ritmo
import Haskore
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
VOCES 3\n
COLUMNAS 6\n
RESOLUCION 64\n
LIGADO LIGADO SIMPLE SILENCIO SIMPLE SIMPLE FIN\n
LIGADO LIGADO SIMPLE SILENCIO SIMPLE SILENCIO FIN\n
SIMPLE SILENCIO SIMPLE SIMPLE SILENCIO SILENCIO FIN
------------------------------------------------------------------------------------------
Los guiones no son parte del fichero, y el \n simboliza el fín de línea.
La resolución es 1/ número especificado
Ligado viene representado en el editor por el color ROJO, Simple por el color AMARILLO y Silencio por el color BLANCO
-}
{- TIPOS DE DATOS QUE REPRESENTAN LO DEVUELTO POR EL ANALISIS DEL STRING CORRESPONDIENTE AL FICHERO JAVA SOBRE PATRONES
RITMICOS
-}
data FichPatronRitmicoJava = FPRJ Voces Cols Resolucion PatronHorizontal PatronVertical
	deriving(Show,Eq,Ord)
type Voces = Int
type Cols = Int
type Resolucion = Dur

parserFichPatronRitmicoJava :: Parser Char FichPatronRitmicoJava
parserFichPatronRitmicoJava = (parserVoces <*> parserCols <*> parserResolucion <*> parserJavaPatsMatriz) <@ formatea
			where 	parserVoces = (token "VOCES" *> (espacio *> natural)) <* saltoDLinea
				parserCols = (token "COLUMNAS" *> (espacio *> natural)) <* saltoDLinea
				parserResolucion = (token "RESOLUCION" *> (espacio *> natural)) <* saltoDLinea
                        	formatea x = FPRJ (voz x) (col x) (1 % (res x)) (patHori x) (patVert x)
				voz x = fst x
				col x = fst (snd x)
				res x = fst (snd (snd x))
				matriz x  = snd (snd (snd x))
				patHori x = matrizJavaAPatHorizontal (1 % (res x)) (matriz x)
				patVert x = matrizJavaAPatVertical (matriz x)

{-
TIPOS DE DATOS PARA MANIPULAR LA PARTE DE MATRIZ PURA DEL FICHERO JAVA SOBRE PATRONES RITMICOS
-}
data TokenJavaPatrones = Ligado|Simple|Silencio
     deriving(Enum,Read,Show,Eq,Ord,Bounded)
type MatrizJavaPatrones = [[TokenJavaPatrones]]

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
parserJavaPatsMatriz :: Parser Char MatrizJavaPatrones
parserJavaPatsMatriz = listaSeparadaChar '\n' parserFila
			where parserFila = (listaSeparadaChar ' ' parserTokenJavaPats) <* (espacio <*> token "FIN")

matrizJavaAPatVertical :: MatrizJavaPatrones -> PatronVertical
matrizJavaAPatVertical matriz = [procesaURV 1 fila | fila <- matTraspuesta]
		                 where matTraspuesta = trasponer matriz
                                       procesaURV _ [] = []
                                       procesaURV n (Silencio:xs) = procesaURV (n+1) xs
                                       procesaURV n (Simple:xs) = (n, False): (procesaURV (n+1) xs)
                                       procesaURV n (Ligado:xs) = (n, True): (procesaURV (n+1) xs)

{-
por ahora da a cada columna el valor fuerte de intensidad, en una ampliacion futura la matriz podría dar valores
de fuerza/velocity: ahora mismo siempre hace lo mismo sin importar la matriz, pero dejo este esquema para hacer más
faciles las ampliaciones en el futuro
	- el parametro Dur indica la resolucion de la matriz
-}
matrizJavaAPatHorizontal :: Dur -> MatrizJavaPatrones -> PatronHorizontal
matrizJavaAPatHorizontal resolucion matriz = [procesaURH fila | fila <- matTraspuesta]
				   where matTraspuesta = trasponer matriz
                                   	 procesaURH _ = (fuerte, resolucion)
--PRUEBAS
pruebaParserMatriz :: String -> IO()
-- pruebaParserMatriz rutaOrigen = do prog <- leeYParsea parserJavaPatsMatriz rutaOrigen
--                                   putStr (show prog)
pruebaParserMatriz rutaOrigen = do texto <- readFile rutaOrigen
                                   putStr ( show (head ( parserJavaPatsMatriz texto)))
pruebaParserMatrizVertical :: String -> IO()
pruebaParserMatrizVertical rutaOrigen = do texto <- readFile rutaOrigen
                                           putStr ( show (matrizJavaAPatVertical(snd(head ( parserJavaPatsMatriz texto)))))

pruebaParserMatrizHorizontal :: String -> IO()
pruebaParserMatrizHorizontal rutaOrigen = do texto <- readFile rutaOrigen
                                             putStr ( show (matrizJavaAPatHorizontal qn (snd(head ( parserJavaPatsMatriz texto)))))

pruebaParserFichPatronRitJava :: String -> IO()
pruebaParserFichPatronRitJava rutaOrigen = do texto <- readFile rutaOrigen
                                              putStr ( show ( head (parserFichPatronRitmicoJava texto)))

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
----------ABAJO PARSER VIEJO DE STRINGS CON EL MISMO FORMATO EXACTO QUE LOS TIPOS PatronHorizontal Y PatronVertical------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
{-
Parsea un string con un formato igual que el tipo PatronHorizontal para obtener
valores de este mismo tipo. Ver Parser_library.hs para ver el tipo Parser (aqui iría
un link si supiera como ponerlo)
-}
parserPatronHorizontal :: Parser Char PatronHorizontal
parserPatronHorizontal = bracketed(commaList(parserURH))
		      where parserURH = parenthesized( (Parser_library.float <* coma) <*> parserRatioARatio )

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
