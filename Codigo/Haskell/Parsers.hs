module Parsers where

-- analiza una lista de elementos de tipo simbolo y devuelve una lista de parejas de la forma 
-- (resto, resultado), donde resto es lo que queda por analizar de la entrada y resultado es el resultado del
-- analisis. Es una lista porque es posible que el analisis no sea univoco
type Parser simbolo resul  = [simbolo] -> [([simbolo], resul)]

-- dados dos parsers p1 y p2 el parser  <*> es un parser equivalente a la composicion secuencial de p1 y p2,
-- es decir, que aplica la entrada a p1 y luego el resto de esta aplicacion a p2
infixr 6 <*>
(<*>) :: Parser s a -> Parser s b -> Parser s (a,b)
(p1 <*> p2) xs = [(xs2, (v1,v2)) | (xs1,v1) <- p1 xs, (xs2, v2) <- p2 xs1]

-- es como <*> pero descartando el resultado del segundo parser
infixr 6 <*
(<*) :: Parser s a -> Parser s b -> Parser s a
p <* q = p <*> q <@ fst

-- es como <*> pero descartando el resultado del primer parser
infixr 6 *>
(*>) :: Parser s a -> Parser s b -> Parser s b
p *> q = p <*> q <@ snd


-- dados dos parsers p1 y p2 el parser  <*> es un parser equivalente a la composicion paralela de p1 y p2,
-- es decir, que aplica la entrada a p1 y a p2 y junta luego los resultados de ambos
infixr 4 <|>
(<|>) :: Parser s a -> Parser s a -> Parser s a
(p1 <|> p2) xs = p1 xs ++ p2 xs


-- dado un parser p y una funcion f, el operador <@ devuelve un parser que hace lo mismo que p pero q aplica
-- tambien f al resultado del parsing
infixr 5 <@
(<@) :: Parser s a -> (a -> b) -> Parser s b
(p <@ f) xs = [(ys, f v) | (ys, v) <- p xs]

-- epsilon es una funcion q reconoce la cadena vacia o construccion landa, por tanto no consume
-- entrada y devuelve siempre el arbol vacio
epsilon :: Parser s ()
epsilon xs = [(xs, ())]

-- parser q siempre tiene exito y no consume entrada, como epsilon pero especificando la salida
succed :: r -> Parser s r
succed v xs = [(xs, v)]

-- option transforma un parser de entrada en otro en que cada entrada reconocida es expresada con una 
-- lista unitaria
option :: Parser s a -> Parser s [a]
option p =     p <@ (\x -> [x]) 
	   <|> epsilon <@ (\x -> [])

--symbol reconoce un simbolo concreto
symbol :: Eq s => s -> Parser s s
symbol a []	= []
symbol a (x:xs) 
 | a == x 	= [(xs,x)]
 | otherwise    = []

-- token reconoce una cadena concreta
-- token :: String -> Parser Char String
token :: Eq [s] => [s] -> Parser s [s]
token k xs
 | k==take n xs = [(drop n xs, k)]
 | otherwise = []
	where n = length k

-- (resto, token) = dameSigToken Cadena : 
-- cadena es la entrada del analizador
-- resto es lo que queda de cadena por analizar tras emparejar un token de la entrada
-- token es el token que se queria emparejar
-- dameSigToken :: String -> [(String, String)]
dameSigToken :: Eq [s] => [[s]] -> [[s]] -> Parser s [s]
dameSigToken listaBlancos listaTokens cadena = if not (null blancos)
		      			       then dameSigToken listaBlancos listaTokens restoBlancos
		      			       else dameSigTokenAcu cadena listaTokens
				where blancos = dameSigTokenAcu cadena listaBlancos
		      		      restoBlancos = fst (head blancos)
--dameSigToken = concat [token t cadena | t <- listaTokens]

-- dameSigTokenAcu :: String -> [String] ->[(String, String)]
dameSigTokenAcu :: Eq [s] => [s] -> [[s]] ->[([s], [s])]
dameSigTokenAcu _ [] = []
dameSigTokenAcu cadena (t:ts) = if null resul
                                then dameSigTokenAcu cadena ts
				else resul
			where resul = token t cadena


-- ejemplo de parser de expresiones aritmeticas
data Expr = Con Int
	  | Var String
	  | Fun String [Expr]
	  | Expr :+: Expr
	  | Expr :-: Expr
	  | Expr :/: Expr
	  | Expr :*: Expr

-- ejemplo de parser de parentesis
data Tree = Nil
	  | Bin (Tree, Tree)

open = symbol '('
close = symbol ')'

parens :: Parser Char Tree
parens = (open *> parens <* close) <*> parens <@ Bin
	<|> succed Nil
