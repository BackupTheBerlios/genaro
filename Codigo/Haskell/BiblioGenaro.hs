module BiblioGenaro where
import Random
import Parser_library
import Parsers

{-
        - cada elemento de un tipo matriz es una fila cujos elementos i-esimos son los de la
columna i-esima
        - Se supone que todas las filas deben ser igual de largas
        -Sería más correcto usar vectores
-}
type Matriz a = [[a]]

{-
Dada una matriz devuelve su traspuesta, pej pasa de [[a,b], [c,d]] a [[a,c],[b,d]]
 -}
trasponer :: Matriz a -> Matriz a
trasponer matriz = [[fila !! (n-1) | fila <- matriz] | n <- [1..(length (head matriz))] ]
-- trasponer matriz = [dameColumna n matriz| n <- [1..(length (head matriz))] ], mas eficiente lo otro
-- pq no comprueba los limites de dameColumna ya que sabe q son buenos

{-
Dado un entero y una matriz devuelve la columna indicada por el entero.El entero n si vale de 1 a el numero de columnas
devuelve la columna correspondiente y si vale otra cosa devuelve []
-}
dameColumna :: Int -> Matriz a -> [a]
dameColumna n matriz
	| n <= 0 = []
	| n > length (head matriz) = []
	|otherwise = [fila !! (n-1) | fila <- matriz]

{-
Dada un elemento y una lista de elementos del mismo tipo devuelve una lista formada por todos los elementos de la lista
de entrada que son distintos al elemento especificado
-}
eliminaApariciones :: Eq a => a -> [a] -> [a]
eliminaApariciones _ [] = []
eliminaApariciones elem (x:xs)
	| x == elem = eliminaApariciones elem xs
	| otherwise = x : (eliminaApariciones elem xs)

eliminaApariciones2 elem = filter (/=elem)
eliminaApariciones3 elem xs = [x | x <- xs, x /= elem]


-- permutacion: encontrada en la pagina http://polaris.lcc.uma.es/~pacog/apuntes/pd/cap06.pdf, en la pagina 25
{-
Inserta un elemento en todas las posiciones posiblesde una lista.
Ej: 
intercala 4 [1,2,3] = [[4,1,2,3],[1,4,2,3],[1,2,4,3],[1,2,3,4]]
-}
intercala :: a -> [a] -> [[a]]
intercala x [] = [[x]]
intercala x ls@(y:ys) = (x:ls) : map (y:) (intercala x ys)

{-
Calcula todas las permutaciones de una lista de elementos
-}
perms :: [a] -> [[a]]
perms [] = [[]]
perms (x:xs) = concat (map (intercala x) (perms xs))


{-
	Primer elemento, segundo y tercero de una tupla
-}
primero :: (a,b,c) -> a
primero (a1,b1,c1) = a1

segundo :: (a,b,c) -> b
segundo (a,b,c) = b

tercero :: (a,b,c) -> c
tercero (a,b,c) = c


{-
Generacion de numeros aleatorios
-}
{-
CORREGIR COMENTARIOS PARA Q HABLEN DE PROCESOS
-}

rollDice :: IO Int
rollDice = getStdRandom (randomR (1,6))

{-
genera un numero aleatorio entero en el intervalo [min, max]
-}
numAleatorioIO :: Int -> Int -> IO Int
numAleatorioIO min max
	|min <= max = getStdRandom (randomR (min,max))
        |otherwise = error "numAleatorioIO: el limite izquierdo debe ser menor o igual que el derecho"

pruNumAleatorioIO :: Int -> Int -> IO()
pruNumAleatorioIO min max = do num <- numAleatorioIO min max
                               putStr (show num)

{-
genera un numero aleatorio de tipo float en el intervalo [min, max]
-}
numAleatorioIOFloat :: Float -> Float -> IO Float
numAleatorioIOFloat min max
	|min <= max = getStdRandom (randomR (min,max))
        |otherwise = error "numAleatorioIO: el limite izquierdo debe ser menor o igual que el derecho"

pruNumAleatorioIOFloat :: Float -> Float -> IO ()
pruNumAleatorioIOFloat min max = do num <- numAleatorioIOFloat min max
                                    print num

{-
genera una lista de 'cuantos' numeros aleatorios de tipo float en el intervalo [min, max]
-}

listaNumAleatorioIOFloat :: Float -> Float -> Int -> IO [Float]
listaNumAleatorioIOFloat min max cuantos = do if (cuantos <=0)
                                                  then return []
                                                  else do f <- numAleatorioIOFloat min max
                                                          fs <- listaNumAleatorioIOFloat min max (cuantos - 1)
                                                          return (f:fs)

pruListaNumAleatorioIOFloat :: Float -> Float -> Int -> IO ()
pruListaNumAleatorioIOFloat min max cuantos = do
    lista <- listaNumAleatorioIOFloat min max cuantos
    print lista

{-
genera una lista de 'cuantos' numeros aleatorios enteros en el intervalo [min, max]
-}
listaNumsAleatoriosIO :: Int -> Int -> Int -> IO [Int]
listaNumsAleatoriosIO min max cuantos  = do semilla <-  numAleatorioIO min max
                                            return (take cuantos (numsAleatoriosSemilla semilla min max))

pruListaNumsAleatoriosIO :: Int -> Int -> Int -> IO()
pruListaNumsAleatoriosIO min max cuantos = do lista <- listaNumsAleatoriosIO min max cuantos
                                              print lista

{-
genera una lista infinita de enteros generados a partir de un entero semilla por medio de una
funcion determinista que ditribuye los numeros del intervalo [min, max] de forma homogenea y
les asigna posiciones en la lista resultado en funcion de semilla. La cosa es generar la semilla
de forma aleatoria (con numAleatorioIO) luego usar esta funcion para obtener los numeros aleatorios 
que queramos
-}
numsAleatoriosSemilla :: Int -> Int -> Int -> [Int]
numsAleatoriosSemilla semilla min max 
	|min <= max = itera (mkStdGen semilla)
		      where itera g = x:itera g1
				      where (x,g1) = randomR (min,max) g

{-
Devuelve True si el string de entrada representa a un entero.
   -Por tanto devuelve False para la cadena vacia
   -Haskell se traga que le pongas 000 o 0001 0 -023, y asi lo hace tb esta funcion
-}
esIntString :: String -> Bool
esIntString = parseoExitoso integer

{-
Devuelve True si el string de entrada representa a un natural.
   -Por tanto devuelve False para la cadena vacia
   -Haskell se traga que le pongas 000 o 0001 0 -023, y asi lo hace tb esta funcion
-}
esNaturalString :: String -> Bool
esNaturalString = parseoExitoso natural

{-
Devuelve True si el string de entrada representa a un float.
   -Por tanto devuelve False para la cadena vacia
   -Haskell se traga que le pongas 000 o 0001 0 -023, y asi lo hace tb esta funcion
-}
esFloatString :: String -> Bool
esFloatString = parseoExitoso float

pideFloat :: String -> IO Float
pideFloat mensaje = do putStrLn mensaje
                       cadenaNum <- getLine
                       if (esFloatString cadenaNum)
                          then do num <- readIO cadenaNum
                                  return num
                          else do putStrLn "dato con formato incorrecto, vuelva a introducir el dato: "
                                  pideFloat mensaje
pruPideFloat :: IO ()
pruPideFloat = do f <- pideFloat "dame un Float"
                  putStr "el float era: "
                  print f

pideInt :: String -> IO Int
pideInt mensaje = do putStrLn mensaje
                     cadenaNum <- getLine
                     if (esIntString cadenaNum)
                        then do num <- readIO cadenaNum
                                return num
                        else do putStrLn "dato con formato incorrecto, vuelva a introducir el dato: "
                                pideInt mensaje

main = do putStrLn "me mola la coca-cola"

lola =  do x <- getStdGen
           print (next x)
	   newStdGen
	   x <- getStdGen
	   print (next x)
	   newStdGen
	   x <- getStdGen
	   print (next x)
