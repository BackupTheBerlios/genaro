-- PARSER BASADO EN EL ARTICULO: Jeroen Fokker
-- 				 Functional Parsers
--				 in: Johan Jeuring and Erik Meijer (eds.)
--				     Advanced Functional Programming
--				     Fst. Int. School on Advanced Functional Programming Techniques
--				     Tutorial Text
--				     Springer LNCS 925, pp. 1-23, 1995 


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

-- dado un parser p , many p es el parser q reconoce o mas apariciones de las cadenas reconocidas por p
many :: Parser s a -> Parser s [a]
many p = p <*> many p <@ (\(x,xs) -> x:xs)
	 <|> epsilon  <@ (\_      -> []  ) 

-- option transforma un parser de entrada en otro en que cada entrada reconocida es expresada con una 
-- lista unitaria
option :: Parser s a -> Parser s [a]
option p =     p <@ (\x -> [x]) 
	   <|> epsilon <@ (\x -> [])

-- chainl procesa una lista de operadores asociativos a la izquierda
chainl :: Parser s a -> Parser s (a->a->a) -> Parser s a
chainl p pf = p <*> many (pf <*> p)
	      <@ uncurry (foldl (flip ap2))
	where ap2 (op,y) = (`op` y)

-- chainr procesa una lista de operadores asociativos a la derecha
chainr :: Parser s a -> Parser s (a->a->a) -> Parser s a
chainr p pf = many (p <*> pf) <*> p
	      <@ uncurry (flip (foldr ap1))
	where ap1 (x, op) = (x `op`)

-- parser fallo

parserFallo    ::  Parser s r
parserFallo xs  =  []

--
choice       ::  [Parser s a] -> Parser s a
choice        =  foldr (<|>) parserFallo
--
type Op a = (Char, a->a->a)
gen :: [Op a] -> Parser Char a -> Parser Char a 
gen ops p = chainr p (choice (map f ops))
	where f (s,c) = symbol s <@ const c

-- dado un parser para un token de apertura, un cuerpo y un token de cierre pack hace un parser para el 
-- cuerpo encerrado entre esos dos tokens
pack :: Parser s a -> Parser s b -> Parser s c -> Parser s b
pack s1 p s2 = s1 *> p <* s2


parenthesized :: Parser Char a -> Parser Char a
parenthesized p = pack (symbol '(')  p (symbol ')')

--symbol reconoce un simbolo concreto
symbol :: Eq s => s -> Parser s s
symbol a []	= []
symbol a (x:xs) 
 | a == x 	= [(xs,x)]
 | otherwise    = []

-- token reconoce una cadena concreta
token :: String -> Parser Char String
-- token :: (Eq ([s])) => [s] -> Parser s [s]
token k xs
 | k==take n xs = [(drop n xs, k)]
 | otherwise = []
	where n = length k

-- (resto, token) = dameSigToken Cadena : 
-- cadena es la entrada del analizador
-- resto es lo que queda de cadena por analizar tras emparejar un token de la entrada
-- token es el token que se queria emparejar
dameSigToken :: [String] -> [String] -> Parser Char String
-- dameSigToken :: Eq [s] => [[s]] -> [[s]] -> Parser s [s]
dameSigToken listaBlancos listaTokens cadena = if not (null blancos)
		      			       then dameSigToken listaBlancos listaTokens restoBlancos
		      			       else dameSigTokenAcu cadena listaTokens
				where blancos = dameSigTokenAcu cadena listaBlancos
		      		      restoBlancos = fst (head blancos)
--dameSigToken = concat [token t cadena | t <- listaTokens]

dameSigTokenAcu :: String -> [String] ->[(String, String)]
-- dameSigTokenAcu :: Eq [s] => [s] -> [[s]] ->[([s], [s])]
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
	deriving (Show, Eq)

open = symbol '('
close = symbol ')'

parens :: Parser Char Tree
parens = (((open *> (parens <* close)) <*> parens) <@ Bin)
	<|> (succed Nil)

fact :: Parser Char Expr
fact =     integer 
            <@ Con
        <|> identifier 
            <*> (option (parenthesized (commaList expr)) <?@ (Var,flip Fun))
            <@ ap2
        <|> parenthesized expr

ap  (f,x)    = f x
ap2 (x,f)    = f x

(<?@)        ::  Parser s [a] -> (b,a->b) -> Parser s b
p <?@ (n,y)   =  p <@ f
          where  f []  = n
                 f [h] = y h

expr :: Parser Char Expr
expr  =  foldr gen fact [addis, multis]

multis  =  [ ('*',(:*:)), ('/',(:/:)) ]
addis   =  [ ('+',(:+:)), ('-',(:-:)) ]

