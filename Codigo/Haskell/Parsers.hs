-- PARSERS BASADOS EN EL ARTICULO: Jeroen Fokker
--                  Functional Parsers
--                 in: Johan Jeuring and Erik Meijer (eds.)
--                     Advanced Functional Programming
--                     Fst. Int. School on Advanced Functional Programming Techniques
--                     Tutorial Text
--                     Springer LNCS 925, pp. 1-23, 1995

module Parsers where
import Parser_library
import Ratio
import List

open = symbol '('
close = symbol ')'
coma = symbol ','
espacio = symbol ' '
saltoDLinea = symbol '\n'
tantoPorCien = symbol '%'
parentesisONO :: Parser Char a -> Parser Char a
parentesisONO p = parenthesized p
                  <|> p

parserBool :: Parser Char Bool
parserBool = (token "True" <|> token "False") <@ f
              where f "True" = True
                    f "False" = False
{-
Parsea un string con el formato "(a,b)" con a y b strings correspondientes a NATURALES y para obtener valores
de tipo Ratio Int. Ver Parser_library.hs para ver el tipo Parser (aqui ir�a
un link si supiera como ponerlo)
-}
parserParejaARatio :: Parser Char (Ratio Int)
parserParejaARatio = parenthesized( (natural <* coma) <*> natural ) <@ f
                     where f = \(a,b) -> a%b

{-
Parsea un string con el formato "a%b" con a y b strings correspondientes a ENTEROS y para obtener valores
de tipo Ratio Int. Ver Parser_library.hs para ver el tipo Parser (aqui ir�a
un link si supiera como ponerlo)
-}
parserRatioARatio :: Parser Char (Ratio Int)
parserRatioARatio =  (integer <* tantoPorCien) <*> integer  <@ f
                     where f = \(a,b) -> a%b

{-
Hace una prueba de un parser cualquiera mostrando por consola la salida del analisis
-}
pruParser :: Show a => (Parser Char a) -> String -> IO ()
pruParser parser ruta = do texto <- readFile ruta
                           print (parser texto)
{-
Dada una funcion/parser de tipo Parser Char a devuelve la funci�n que aplica este parser, es decir,
una funcion de tipo String -> a que devuelve el primer resultado del parseo o error si falla el
analisis
-}
aplicaParser :: (Parser Char a) -> (String -> a)
aplicaParser parser cadena = if null resultados
                                then error "el parser no reconocio ningun simbolo de la entrada"
                                else if null (resultadosOK)
                                        then error "el parser no reconocio la entrada completamente"
                                        else resulOK
                               where resultados    = parser cadena
                                     resultadosOK  = filter (null . fst) resultados
                                     resulOK       = (snd . head) resultadosOK
{-aplicaParser parser cadena = if null resultados
                                then error "el parser no reconoci� ning�n s�mbolo de la entrada"
                                else if null (fst resul1)
                                        then snd resul1
                                        else error "el parser no reconoci� la entrada completamente"
                               where resultados = parser cadena
                                     resul1     = head resultados
-}

{-
Dado una funcion/parser de tipo Parser Char a devuelve y un string devuelve cierto si el parseo fue exitoso,
es decir, si la cadena se ajusta a la estructura sintactica especificada por el parser; y falso en otro caso
-}
parseoExitoso :: (Parser Char a) -> (String -> Bool)
parseoExitoso parser cadena = if null resultados
                                then False
                                else if null (resultadosOK)
                                        then False
                                        else True
                               where resultados    = parser cadena
                                     resultadosOK  = filter (null . fst) resultados
{-parseoExitoso parser cadena = if null resultados
                                 then False
                                 else if null (fst resul1)
                                         then True
                                         else False
                              where resultados = parser cadena
                                    resul1     = head resultados
-}
{-
Dado una funcion/parser de tipo Parser Char a devuelve la funci�n que aplica este parser sobre un archivo de
texto concreto especificado como una ruta en formato String, es decir, que devuelve el primer resultado del
parseo o error si falla el analisis
-}
leeYParsea :: Parser Char a -> String -> IO a
leeYParsea parser rutaOrigen = do texto <- readFile rutaOrigen
                                  return ((aplicaParser parser) texto)
{-
Dada un lista de pares (token, dato) esta funcion devuelve un parser tal que para cada pareja token es el lexema
cuyo analisis devuelve dato
-}
listaParesTokenDatoAParser :: [(String, a)] -> Parser Char a
listaParesTokenDatoAParser lista = choice [token string <@ const dato | (string, dato) <- lista]


{-
Dado un parser de Char a un tipo t devuelve un parser que procesa una cadena de char formada por cadenas correspondientes
a elementos de tipo t separadas por espacios y devuelve la lista de elementos de tipo t correspondiente
-}
listaEspacios :: Parser Char a -> Parser Char [a]
-- listaEspacios parser = listOf parser (symbol ' ')
listaEspacios = listaSeparadaChar ' '

{-
Dado un caracter separador y un parser que procesa un String y devuelve un elemento de un tipo t devuelve un parser que procesa
un string formado por varios strings correspondientes a elementos tipo t separados por el separador especificado, y devuelve la
lista de elementos de tipo t correspondiente.NO se lo traga si hay 1 espacio delante del separador correspondiente
-}
listaSeparadaChar :: Char -> Parser Char a -> Parser Char [a]
listaSeparadaChar separador parser = listOf parser (symbol separador)

{-
como listaSeparadaChar pero especificando el separador como un string en vez de como un char
-}
listaSeparadaString :: String -> Parser Char a -> Parser Char [a]
listaSeparadaString separador parser = listOf parser (token separador)


{-
devuelve el string correspondiente a quitar los espacios del string de entrada
-}
quitaEspacios :: String -> String
quitaEspacios =  filter noEsEspacio
              where noEsEspacio c = (c/= ' ') && (c/= '\t') && (c/= '\n')

{-
devuelve el string correspondiente a quitar los caracteres de retorno de carro \r de DOS, del string de entrada
-}
quitaFormatoDOS :: String -> String
quitaFormatoDOS = filter (/= '\r')

-- type Parser symbol result  =  [symbol] -> [([symbol],result)]
parserAceptaTodo :: Parser Char String
--parserAceptaTodo str = reverse (map (\(a,b) -> (b,a)) [(divideListaPos div str) | div <- [(-1)..((length str) -1)]])
parserAceptaTodo str = [(drop n str, take n str)| n <- (reverse [0..(length str)])]

parserNoSalto :: Parser Char String
parserNoSalto str = [(resto ++ sobra, resul) |(resto, resul) <- parserAceptaTodo (takeWhile (/= '\n') str)]
                where sobra = (dropWhile (/= '\n') str)

{-
divideListaPos :: Int -> [a] -> ([a], [a])
divideListaPos pos xs = (listaIzda, listaDcha)
  -devuelve una pareja de listas, la primera con los elementos desde el 0 al pos-esimo inclusive, y la
  segunda con los elementos desde el (pos+1)-esimo al ultimo
-}
divideListaPos :: Int -> [a] -> ([a], [a])
divideListaPos pos xs = (listaIzda, listaDcha)
            where listaIzda = [xs !! i | i <- [0..pos]]
                  listaDcha = [xs !! i | i <- [(pos+1)..((length xs)-1)] ]
