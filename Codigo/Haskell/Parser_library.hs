module Parser_library where
import Char

type Parser symbol result  =  [symbol] -> [([symbol],result)]

{- A parser that yields just one solution and no rest-string
   is called a deterministic parser:
-}

type DetPars symbol result  =  [symbol] -> result

------------------------------------------------------------
-- Priorities of operators

infixr 6  <*> , <*   ,  *> , <:*>
infixl 5  <@  , <?@
infixr 4  <|>


------------------------------------------------------------
-- Auxiliary functions

list (x,xs)  =  x:xs
single x     =  [x]

ap2 (op,y)   = (`op` y)
ap1 (x,op)   = (x `op`)

ap  (f,x)    = f x
ap' (x,f)    = f x


------------------------------------------------------------
-- Trivial parsers

p_fail    ::  Parser s r
p_fail xs  =  []

succeed       ::  r -> Parser s r
succeed v xs   =  [ (xs,v) ]

epsilon  ::  Parser s ()
epsilon   =  succeed ()

------------------------------------------------------------
-- Elementary parsers

satisfy  ::  (s->Bool) -> Parser s s
satisfy p []     =  []
satisfy p (x:xs) =  [ (xs,x) | p x ]

symbol  ::  Eq s  =>  s -> Parser s s
symbol   =  satisfy . (==)

symbol' a []      =  []
symbol' a (x:xs)  =  [ (xs,x) | a==x ]

symbol'' a []                    =  []
symbol'' a (x:xs)  |  a==x       =  [ (xs,x) ]
                   |  otherwise  =  []

token  ::  Eq s  =>  [s] -> Parser s [s]
-- token :: String -> Parser Char String
token   =  p_sequence . map symbol


token' k xs  |  k==take n xs  =  [ (drop n xs, k) ]
             |  otherwise     =  []
                          where  n = length k

------------------------------------------------------------
-- Parser combinators

(<*>)          ::  Parser s a -> Parser s b -> Parser s (a,b)
(p1 <*> p2) xs  =  [  (xs2,(v1,v2))
                   |  (xs1, v1) <- p1 xs
                   ,  (xs2, v2) <- p2 xs1
                   ]

(<|>)          ::  Parser s a -> Parser s a -> Parser s a
(p1 <|> p2) xs  =  p1 xs ++ p2 xs

(<@)          ::  Parser s a -> (a->b) -> Parser s b
(p <@ f) xs   =   [ (ys, f v)
                  | (ys,   v) <- p xs
                  ]

option   ::  Parser s a -> Parser s [a]
option p  =  p  <@  single
             <|> succeed []

many     ::  Parser s a  -> Parser s [a]
many p    =  p <:*> (many p)  <|>  succeed []

many1    ::  Parser s a -> Parser s [a]
many1 p   =  p <:*> many p


-----------------------------------------------------------
-- Determinsm


determ :: Parser a b -> Parser a b
determ p xs  |  null r     =  []
             |  otherwise  =  [head r]
                     where r = p xs

compulsion = determ . option

greedy = determ . many

greedy1 = determ . many1


------------------------------------------------------------
-- Abbreviations

(<*)         ::  Parser s a -> Parser s b -> Parser s a
p <* q        =  p <*> q  <@  fst

(*>)         ::  Parser s a -> Parser s b -> Parser s b
p *> q        =  p <*> q  <@  snd

(<:*>)       ::  Parser s a -> Parser s [a] -> Parser s [a]
p <:*> q      =  p <*> q  <@  list

(<?@)        ::  Parser s [a] -> (b,a->b) -> Parser s b
p <?@ (n,y)   =  p <@ f
          where  f []  = n
                 f [h] = y h


pack         ::  Parser s a -> Parser s b -> Parser s c -> Parser s b
pack s1 p s2  =  s1 *> p <* s2

listOf       ::  Parser s a -> Parser s b -> Parser s [a]
listOf p s    =  p <:*> many (s *> p)  <|>  succeed []

chainl       ::  Parser s a -> Parser s (a->a->a) -> Parser s a
chainl p s    =  p <*> many (s <*> p)  <@  uncurry (foldl (flip ap2))


chainr       ::  Parser s a -> Parser s (a->a->a) -> Parser s a
chainr p s    =  many (p <*> s) <*> p  <@  uncurry (flip (foldr ap1))

p_sequence     ::  [Parser s a] -> Parser s [a]
p_sequence      =  foldr (<:*>) (succeed [])

choice       ::  [Parser s a] -> Parser s a
choice        =  foldr (<|>) p_fail

chainl' p s   =  q
          where  q = (option (q <*> s) <?@ (id,ap1) ) <*> p <@ ap

chainr' p s   =  q
          where  q = p <*> (option (s <*> q) <?@ (id,ap2) ) <@ ap'

------------------------------------------------------------
-- Parser transformators


just      ::  Parser s a -> Parser s a
just p  =  filter (null.fst) . p

just' p xs  =  [ ([],v)
               | (ys,v) <- p xs
               , null ys
               ]

some   ::  Parser s a -> DetPars s a
some p  =  snd . head . just p


------------------------------------------------------------
-- Some common special cases

-- conversion

isAlphanum = isAlphaNum

identifier  ::  Parser Char String
identifier   =  satisfy isAlpha <:*> greedy (satisfy isAlphanum)

digit       ::  Parser Char Int
digit        =  satisfy isDigit  <@  f
         where  f c = ord c - ord '0'


natural     ::  Parser Char Int
natural      =  greedy1 digit  <@  foldl f 0
        where  f a b = a*10 + b

integer     ::  Parser Char Int
integer      =  option (symbol '-') <*> natural  <@  f
         where  f ([],n) =  n
                f (_ ,n) =  -n

integer'    ::  Parser Char Int
integer'     =  (option (symbol '-') <?@ (id,const negate)) <*> natural  <@ ap

fixed       ::  Parser Char Float
fixed        =  -- (integer <@ fromInteger)
                (integer <@ fromIntegral)
                <*>
                (option (symbol '.' *> fractpart)  <?@  (0.0,id))
                <@  uncurry (+)

fractpart   ::  Parser Char Float
fractpart    =  greedy digit  <@  foldr f 0.0
         where  f d n = (n + fromIntegral d)/10.0
                -- f d n = (n + fromInteger d)/10.0


float       ::  Parser Char Float
float        =  fixed
                <*>
                (option (symbol 'E' *> integer) <?@ (0,id) )
                <@ f
         where  f (m,e)  =  m * power e
                power e | e<0       = 1.0 / power (-e)
                        | otherwise = fromIntegral(10^e)
                        -- | otherwise = fromInteger(10^e)

sp  ::  Parser Char a -> Parser Char a
sp   =  (greedy (satisfy isSpace) *> )

sp'  =  ( . (dropWhile isSpace))


sptoken  ::  String -> Parser Char String
sptoken   =  sp . token

spsymbol ::  Char -> Parser Char Char
spsymbol  =  sp . symbol

spident  ::  Parser Char String
spident   =  sp identifier



parenthesized, bracketed,
 braced, angled, quoted   :: Parser Char a -> Parser Char a
parenthesized p = pack (spsymbol '(')  p (spsymbol ')')
bracketed p     = pack (spsymbol '[')  p (spsymbol ']')
braced p        = pack (spsymbol '{')  p (spsymbol '}')
angled p        = pack (spsymbol '<')  p (spsymbol '>')
quoted p        = pack (spsymbol '"')  p (spsymbol '"')
stropped p      = pack (spsymbol '\'') p (spsymbol '\'')

commaList, semicList  ::  Parser Char a -> Parser Char [a]
commaList p  =  listOf p (spsymbol ',')
semicList p  =  listOf p (spsymbol ';')

twopass ::  Parser a b -> Parser b c -> Parser a c
twopass lex synt xs = [ (rest,tree)
                      | (rest,tokens) <- many lex xs
                      , (_,tree)      <- just synt tokens
                      ]
---------------------------------------------------------------------
-- written by:
-- Jeroen Fokker                                 |  jeroen@cs.ruu.nl
-- dept.of Computer Science, Utrecht University  |  tel.+31-30-2534129
-- PObox 80089, 3508TB Utrecht, the Netherlands  |  fax.+31-30-2513791



