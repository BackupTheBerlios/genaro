module JavaAHaskell where
import Ritmo
import Ratio
import Parser_library
import Parsers

{-
>type Acento = Float
>type URH = (Acento, Dur)
>type PatronHorizontal = [URH]

[(1,1%2),(2,2%3)]


>type Voz = Int
>type Ligado = Bool
>type URV = [(Voz, Bool)]
>type PatronVertical = [URV]

[[(3,True),(5,False)]]
-}
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
