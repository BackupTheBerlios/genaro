-- PARSERS BASADOS EN EL ARTICULO: Jeroen Fokker
-- 				 Functional Parsers
--				 in: Johan Jeuring and Erik Meijer (eds.)
--				     Advanced Functional Programming
--				     Fst. Int. School on Advanced Functional Programming Techniques
--				     Tutorial Text
--				     Springer LNCS 925, pp. 1-23, 1995

module Parsers where
import Parser_library
import Ratio


open = symbol '('
close = symbol ')'
coma = symbol ','
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
de tipo Ratio Int. Ver Parser_library.hs para ver el tipo Parser (aqui iría
un link si supiera como ponerlo)
-}
parserParejaARatio :: Parser Char (Ratio Int)
parserParejaARatio = parenthesized( (natural <* coma) <*> natural ) <@ f
                     where f = \(a,b) -> a%b

{-
Parsea un string con el formato "a%b" con a y b strings correspondientes a ENTEROS y para obtener valores
de tipo Ratio Int. Ver Parser_library.hs para ver el tipo Parser (aqui iría
un link si supiera como ponerlo)
-}
parserRatioARatio :: Parser Char (Ratio Int)
parserRatioARatio =  (integer <* tantoPorCien) <*> integer  <@ f
                     where f = \(a,b) -> a%b
{-
Dado una funcion/parser de tipo Parser Char a devuelve la función que aplica este parser, es decir,
una funcion de tipo String -> a que devuelve el primer resultado del parseo o error si falla el
análisis
-}
aplicaParser :: (Parser Char a) -> (String -> a)
aplicaParser parser cadena = if null resultados
                                then error "el parser no reconoció ningún símbolo de la entrada"
                                else if null (fst resul1)
                                        then snd resul1
                                        else error "el parser no reconoció la entrada completamente"
		              where resultados = parser cadena
                                    resul1     = head resultados
{-
Dado una funcion/parser de tipo Parser Char a devuelve la función que aplica este parser sobre un archivo de
texto concreto especificado como una ruta en formato String, es decir, que devuelve el primer resultado del
parseo o error si falla el análisis
-}
leeYParsea :: Parser Char a -> String -> IO a
leeYParsea parser rutaOrigen = do texto <- readFile rutaOrigen
                                  return ((aplicaParser parser) texto)
{-
Dada un lista de pares (token, dato) esta funcion devuelve un parser tal que para cada pareja token es el lexema
cuyo análisis devuelve dato
-}
listaParesTokenDatoAParser :: [(String, a)] -> Parser Char a
listaParesTokenDatoAParser lista = choice [token string <@ const dato | (string, dato) <- lista]
