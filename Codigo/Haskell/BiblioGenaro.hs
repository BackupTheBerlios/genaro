module BiblioGenaro where
import Random

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
genera un numero aleatorio en el intervalo [min, max]
-}
numAleatorioIO :: Int -> Int -> IO Int
numAleatorioIO min max
	|min <= max = getStdRandom (randomR (min,max))

pruNumAleatorioIO :: Int -> Int -> IO()
pruNumAleatorioIO min max = do num <- numAleatorioIO min max
                               putStr (show num)

{-
genera una lista de 'cuantos' numeros aleatorios en el intervalo [min, max]
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
