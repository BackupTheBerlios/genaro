module BiblioGenaro where
import Random
import Parser_library
import List

import Parsers

{-
        - cada elemento de un tipo matriz es una fila cujos elementos i-esimos son los de la
columna i-esima
        - Se supone que todas las filas deben ser igual de largas
        -Ser�a m�s correcto usar vectores
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
Dada una lista devuelve el resultado de darle la vuelta, por ejemplo invertir [1,2,3] = [3,2,1]
-}
invertir :: [a] -> [a]
--invertir [] = []
--invertir (x:xs) = (invertir xs) ++ [x]
invertir = invertirAcu []
invertirAcu acu [] = acu
invertirAcu acu (x:xs) = invertirAcu (x:acu) xs

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

{-
dameMinimizador f lista devuelve el elemento de lista que minimiza la funci�n
-}
dameMinimizador :: Ord b => (a -> b) -> [a] -> a
dameMinimizador f (x:xs) = dameMinimizadorAcu f x (f x) xs
		where dameMinimizadorAcu f x _ [] = x
                      dameMinimizadorAcu f x valMin (u:us)
                                       |(f u) < valMin = dameMinimizadorAcu f u (f u) us
                                       |otherwise = dameMinimizadorAcu f x valMin us

{-
dameMinimizadores f lista devuelve la lista de elementos de lista que minimizan la funci�n
-}
dameMinimizadores :: Ord b => (a -> b) -> [a] -> [a]
dameMinimizadores f (x:xs) = dameMinimizadorAcu f [x] (f x) xs
		where dameMinimizadorAcu f elegidos _ [] = elegidos
                      dameMinimizadorAcu f elegidos@(x:xs) valMin (u:us)
                                       |nuevoVal < valMin  = dameMinimizadorAcu f [u] (f u) us
                                       |nuevoVal == valMin = dameMinimizadorAcu f (u:elegidos) valMin us
                                       |otherwise = dameMinimizadorAcu f elegidos valMin us
                                                    where nuevoVal = f u

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
genera una lista infinita de numeros aleatorios enteros en el intervalo [min, max]
-}
listaInfNumsAleatoriosIO :: Int -> Int -> IO [Int]
listaInfNumsAleatoriosIO min max  = do semilla <-  numAleatorioIO min max
                                       return (numsAleatoriosSemilla semilla min max)

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
resolucionRandom valor que se tomara de resolucion de los c�lculos aleatorios. Por ejemplo
, si resolucionRandom vale 100 los random de har�n de 1 a 100
-}
resolucionRandom :: Int
resolucionRandom = 1000
{-
Dada una lista de parejas (termino, peso), donde los pesos son naturales, devuelve en Elem un elemento
(es decir, primer componente de una de las parejas que forman la lista de entrada) elegido al azar entre
de los de la lista asignando a cada elemento/pareja una probabilidad de ser elegida igual a (peso/sumaPesos)
, donde suma pesos es la suma de los pesos de todos los elementos de la lista. Para ello se le debe suministrar un
numero aleatorio entre 1 y resolucionRandom. Se devuelve el elemento elegido y su posicion
-dameElemAleatListaPesos aleat listaParejas
-}
dameElemAleatListaPesos :: Int -> [(a, Int)] -> (a, Int)
dameElemAleatListaPesos aleat listaParejas = aplicaAleat aleatNorm listaParejas 1 1
        where listaPesos = map snd listaParejas
              sumaPesos = foldl1' (+) listaPesos
              aleatNorm = round ( fromIntegral (aleat * sumaPesos) / fromIntegral resolucionRandom)
              aplicaAleat _ ((term,peso):[]) _ posEnLista = (term, posEnLista)
              aplicaAleat porcentaje ((term,peso):_:xs) posEnRecta posEnLista
                  | porcentaje <= extDcho  = (term, posEnLista)
                  | otherwise              = aplicaAleat porcentaje xs (posEnRecta + peso) (posEnLista + 1)
                                             where extDcho = posEnRecta + peso - 1

{-
como dameElemAleatListaPesos pero con pesos de tipo Float
-}
dameElemAleatListaPesosFloat :: Int -> [(a, Float)] -> (a, Int)
dameElemAleatListaPesosFloat aleat listaParejas = aplicaAleat aleatNorm listaParejas 1.0 1
        where listaPesos = map snd listaParejas
              sumaPesos = foldl1' (+) listaPesos
              aleatNorm = (fromIntegral aleat) * sumaPesos / (fromIntegral resolucionRandom)
              aplicaAleat _ ((term,peso):[]) _ posEnLista = (term, posEnLista)
              aplicaAleat porcentaje ((term,peso):_:xs) posEnRecta posEnLista
                  | porcentaje <= extDcho  = (term, posEnLista)
                  | otherwise              = aplicaAleat porcentaje xs (posEnRecta + peso) (posEnLista + 1)
                                             where extDcho = posEnRecta + peso - 1

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

{-
Muestra un mensaje de pedidad y lee un entero de la entrada est�ndar hasta que realmente sea un entero. Si no el usuario no ha escrito un
 entero muestra el mensaje de error especificado. No escribe los mensajes con saltos de linea forzados
-}
pideIntMensajeError :: String -> String -> IO Int
pideIntMensajeError mensajePedida mensajeError = do putStr mensajePedida
                                                    cadenaNum <- getLine
                                                    if (esIntString cadenaNum)
                                                       then do num <- readIO cadenaNum
                                                               return num
                                                       else do putStr mensajeError
                                                               pideIntMensajeError mensajePedida mensajeError
{-
recursion final de listas con acumulador impaciente
-}
foldl' :: (b -> a -> b) -> b -> [a] -> b
foldl' f e []     = e
foldl' f e (x:xs) = (foldl' f $! f e x) xs

{-
recursion final de listas no vacias con acumulador impaciente. Se toma el primer elemento de
la lista como acumulador inicial
-}
foldl1' :: (a -> a -> a) -> [a] -> a
foldl1' f (x:xs) = foldl' f x xs

{-
Dada una lista de listas y un separador del mismo tipo que las elementos de la superlista devuelve
la lista resultado de concatenar las listas de la superlista separandolas con el separador
-}
juntaCon :: [a] -> [[a]] -> [a]
juntaCon separador = foldl1' (\xs-> \ys ->xs++separador++ys )

type FuncionInteraccion = IO()
type Mensaje = String
type DatosInteraccion = (Mensaje, [(Mensaje, FuncionInteraccion)])

ejemploInteraccion :: DatosInteraccion
ejemploInteraccion = ("�Con cual de estos tipos quieres cenar esta noche?"
                      ,[(mensajeManolo, accionManolo),(mensajeAntonio, accionAntonio)])

mensajeManolo = "Manolo es un tipo duro, de los fuertes y callados"
accionManolo = do {putStrLn "Hola wapa, �te vienes a matar humanos?"}
mensajeAntonio = "Antonio es un hombre sensible, le encantan las flores y los cuadros de Manet"
accionAntonio = do {putStrLn "Hola, �te vienes a ver cuadros?"}

hazInteraccion :: DatosInteraccion -> IO()
hazInteraccion (mensajeBienvenida, listaOpciones) = do putStrLn mensajeBienvenida
                                                       putStrLn mensajeOpciones
                                                       opcion <- pideOpcion
                                                       if (opcion >=1 && opcion <= (length listaOpciones))
                                                           then do putStrLn ""
                                                                   listaAcciones !! (opcion - 1)
                                                           else do putStrLn mensajeError
                                                                   hazInteraccion (mensajeBienvenida, listaOpciones)
                                                       where mensajeOpciones = "\n" ++ formateaOpciones (map fst listaOpciones)
                                                             mensajePedida   = ""
                                                             mensajeError    = "\nDebes introducir un entero correspondiente a una de las opciones\n"
                                                             pideOpcion      = pideIntMensajeError  mensajePedida mensajeError
                                                             listaAcciones   = map snd listaOpciones
{-
Muestra las opciones de la lista en formato numero.opcion salto_de_linea, donde numero empieza a contar desde uno
-}
formateaOpciones :: [Mensaje] -> Mensaje
formateaOpciones mensajes = formateaOpcionesAcu 1 mensajes
                            where formateaOpcionesAcu _ [] = []
                                  formateaOpcionesAcu n (m:ms) = (show n) ++ "."++ m ++ "\n" ++ formateaOpcionesAcu (n+1) ms

{-
cambiaExtension nuevaExtension ruta
devuelve una ruta igual a la de entrada salvo que la extension se ha cambiado para que sea la indicada.
-La extensi�n se deber� indicar sin el punto, por ejemplo "mid", NO ".mid" (que pondr�a dos puntos, lo que
esta bien si es lo que se quiere)
-Si la ruta de entrada no tiene extension se a�adir� la extensi�n con un punto sin quitar nada, por ejemplo
cambiaExtension "txt" "pepe" = pepe.txt
-}
cambiaExtension :: String -> String -> String
cambiaExtension nuevaExtension ruta
  |pos == Nothing = ruta ++ "." ++ nuevaExtension
  |otherwise      = (invertir  (dropWhile (/='.') (invertir ruta))) ++ nuevaExtension
               where pos = elemIndex '.' ruta

main = do putStrLn "me mola la coca-cola"
lola =  do x <- getStdGen
           print (next x)
	   newStdGen
	   x <- getStdGen
	   print (next x)
	   newStdGen
	   x <- getStdGen
	   print (next x)


{-
'elementoAleatorio' dada un generador de numeros aleatorios y una lista devuelve un elemento
aleatorio de la lista y el siguiente generador que hay que usar
-}
elementoAleatorio :: RandomGen b => b -> [a] -> (a,b)
elementoAleatorio g l = (l !! pos, sigg)
	where longitud = length l;
		(pos, sigg) = randomR (0, longitud - 1) g

