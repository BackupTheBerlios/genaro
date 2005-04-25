module BiblioGenaro where
import Random
import Parser_library
import List
import Parsers

{-
        - cada elemento de un tipo matriz es una fila cujos elementos i-esimos son los de la
columna i-esima
        - Se supone que todas las filas deben ser igual de largas
        -Serï¿½a mï¿½s correcto usar vectores
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
dameMinimizador f lista devuelve el elemento de lista que minimiza la funciï¿½n
-}
dameMinimizador :: Ord b => (a -> b) -> [a] -> a
dameMinimizador f (x:xs) = dameMinimizadorAcu f x (f x) xs
		where dameMinimizadorAcu f x _ [] = x
                      dameMinimizadorAcu f x valMin (u:us)
                                       |(f u) < valMin = dameMinimizadorAcu f u (f u) us
                                       |otherwise = dameMinimizadorAcu f x valMin us

{-
dameMinimizadores f lista devuelve la lista de elementos de lista que minimizan la funciï¿½n
-}
dameMinimizadores :: Ord b => (a -> b) -> [a] -> [a]
dameMinimizadores f (x:xs) = dameMinimizadorAcu f [x] (f x) xs
		where dameMinimizadorAcu f elegidos _ [] = elegidos
                      dameMinimizadorAcu f elegidos@(x:xs) valMin (u:us)
                                       |nuevoVal < valMin  = dameMinimizadorAcu f [u] (f u) us
                                       |nuevoVal == valMin = dameMinimizadorAcu f (u:elegidos) valMin us
                                       |otherwise = dameMinimizadorAcu f elegidos valMin us
                                                    where nuevoVal = f u
{-
sustituyeElemPos :: Int -> a -> [a] -> [a]
sustituyeElemPos pos elem lista = nuevaLista en la que el elemento en la posicion pos (contando desde cero) se ha sustituido
por elem
-}
sustituyeElemPos :: Int -> a -> [a] -> [a]
sustituyeElemPos pos elem lista = sustituyeSublistaPos pos [elem] lista  --nuevaLista
                  --  where listaIzda = [lista !! i | i <- [0..(pos-1)]]
                  --        listaDcha = [lista !! i | i <- [(pos+1)..((length lista)-1)] ]
                  --        nuevaLista = listaIzda ++ [elem] ++ listaDcha

{-
sustituyeSublistaPos :: Int -> [a] -> [a] -> [a]
sustituyeSublistaPos pos sublista lista = nuevaLista en la que el elemento en la posicion pos (contando desde cero) se ha sustituido
por la sublista sublista
-}
sustituyeSublistaPos :: Int -> [a] -> [a] -> [a]
sustituyeSublistaPos pos sublista lista = nuevaLista
                    where listaIzda = [lista !! i | i <- [0..(pos-1)]]
                          listaDcha = [lista !! i | i <- [(pos+1)..((length lista)-1)] ]
                          nuevaLista = listaIzda ++ sublista ++ listaDcha

{-
sustituyeSublistaPosIniFin :: Int -> Int -> [a] -> [a] -> [a]
sustituyeSublistaPosIniFin ini fin sublista lista = nuevaLista en la que se han eliminado

-}
sustituyeSublistaPosIniFin :: Int -> Int -> [a] -> [a] -> [a]
sustituyeSublistaPosIniFin ini fin sublista lista = nuevaLista
                    where listaIzda = [lista !! i | i <- [0..(ini-1)]]
                          listaDcha = [lista !! i | i <- [(fin+1)..((length lista)-1)] ]
                          nuevaLista = listaIzda ++ sublista ++ listaDcha

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
resolucionRandom valor que se tomara de resolucion de los cï¿½lculos aleatorios. Por ejemplo
, si resolucionRandom vale 100 los random de harï¿½n de 1 a 100
-}
resolucionRandom :: Int
resolucionRandom = 1000

{-
Tipo que representa las funciones que emplean numeros aleatorios. type FuncAleatoria a b = [Int] -> a -> (b, [Int]), es decir,
se espera que reciba una lista infinita de numeros enteros entre 1 y resolucionRandom, que se supone que son numeros aleatorios.
 Por lo demás es una función de tipo (a->b),y devuelve la pareja (b,restoAleat) que es el resultado de la funcion si no fuera aleatorio,
 y el resto de la lista infinita de numeros aleatorios que no ha consumido
-}
type FuncAleatoria a b = [Int] -> a -> (b, [Int])

{-
Dada una lista de parejas (termino, peso), donde los pesos son naturales, devuelve en Elem un elemento
(es decir, primer componente de una de las parejas que forman la lista de entrada) elegido al azar entre
de los de la lista asignando a cada elemento/pareja una probabilidad de ser elegida igual a (peso/sumaPesos)
, donde suma pesos es la suma de los pesos de todos los elementos de la lista. Para ello se le debe suministrar un
numero aleatorio entre 1 y resolucionRandom. Se devuelve el elemento elegido y su posicion
-dameElemAleatListaPesos aleat listaParejas
-}
dameElemAleatListaPesos :: Int -> [(a, Int)] -> (a, Int)
dameElemAleatListaPesos aleat listaParejas = aplicaAleat aleatNorm listaParejas 0 1
        where listaPesos = map snd listaParejas
              sumaPesos = foldl1' (+) listaPesos
              aleatNorm = round ( fromIntegral (aleat * sumaPesos) / fromIntegral resolucionRandom)
              aplicaAleat _ ((term,peso):[]) _ posEnLista = (term, posEnLista)
              aplicaAleat porcentaje ((term,peso):y:xs) posEnRecta posEnLista
                  | porcentaje < extDcho  && porcentaje >= posEnRecta = (term, posEnLista)
                  | otherwise                                         = aplicaAleat porcentaje (y:xs) (posEnRecta + peso) (posEnLista + 1)
                                                                        where extDcho = posEnRecta + peso

pruDameElemAleatListaPesos :: IO ()
pruDameElemAleatListaPesos = do putStr "Prueba de dameElemAleatListaPesos de naturales\n"
                                putStr ("Datos de entrada " ++ (show listaParejas) ++ "\n")
                                putStr ("Resultados obtenidos (valor, frecuencia absoluta, frecuencia relativa): \n")
                                putStr ("\t" ++ (show estadisticasReales) ++ "\n")
                                putStr ("Resultados esperados (valor, frecuencia relativa): \n")
                                putStr ("\t" ++ (show estadisticasEsperadas) ++ "\n")
                                where listaParejas = [('a',33),('b',50),('c',100),('d',50),('e',33)]
                                      listaValores = map fst listaParejas
                                      sumaPesos = foldl1' (+) (map snd listaParejas)
                                      listaAleat = [1..resolucionRandom]
                                      tamListaAleat = length listaAleat
                                      prueba =  zip listaAleat (map (\x -> dameElemAleatListaPesos x listaParejas) listaAleat)
                                      tamPrueba = length prueba
                                      estadsAux = map (\valor -> (valor, length (filter (\(aleat, (valor2, pos)) -> valor2 == valor) prueba))) listaValores
                                      estadisticasReales = map (\(val,fAbs) -> (val, fAbs, fromIntegral fAbs / fromIntegral tamPrueba)) estadsAux
                                      estadisticasEsperadas = map (\(val,peso) -> (val,fromIntegral peso / fromIntegral sumaPesos)) listaParejas

{-
como dameElemAleatListaPesos pero con pesos de tipo Float
-}
dameElemAleatListaPesosFloat :: Int -> [(a, Float)] -> (a, Int)
dameElemAleatListaPesosFloat aleat listaParejas = aplicaAleat aleatNorm listaParejas 0.0 1
        where listaPesos = map snd listaParejas
              sumaPesos = foldl1' (+) listaPesos
              aleatNorm = (fromIntegral aleat) * sumaPesos / (fromIntegral resolucionRandom)
              aplicaAleat _ ((term,peso):[]) _ posEnLista = (term, posEnLista)
              aplicaAleat porcentaje ((term,peso):y:xs) posEnRecta posEnLista
                  | porcentaje < extDcho && porcentaje >= posEnRecta = (term, posEnLista)
                  | otherwise                                        = aplicaAleat porcentaje (y:xs) (posEnRecta + peso) (posEnLista + 1)
                                                                       where extDcho = posEnRecta + peso

pruDameElemAleatListaPesosFloat :: IO ()
pruDameElemAleatListaPesosFloat = do putStr "Prueba de dameElemAleatListaPesosFloat\n"
                                     putStr ("Datos de entrada " ++ (show listaParejas) ++ "\n")
                                     putStr ("Resultados obtenidos (valor, frecuencia absoluta, frecuencia relativa): \n")
                                     putStr ("\t" ++ (show estadisticasReales) ++ "\n")
                                     putStr ("Resultados esperados (valor, frecuencia relativa): \n")
                                     putStr ("\t" ++ (show estadisticasEsperadas) ++ "\n")
                                     where listaParejas = [('a',0.33333),('b',0.5),('c',1.0),('d',0.5),('e',0.333333)]
                                           listaValores = map fst listaParejas
                                           sumaPesos = foldl1' (+) (map snd listaParejas)
                                           listaAleat = [1..resolucionRandom]
                                           tamListaAleat = length listaAleat
                                           prueba =  zip listaAleat (map (\x -> dameElemAleatListaPesosFloat x listaParejas) listaAleat)
                                           tamPrueba = length prueba
                                           estadsAux = map (\valor -> (valor, length (filter (\(aleat, (valor2, pos)) -> valor2 == valor) prueba))) listaValores
                                           estadisticasReales = map (\(val,fAbs) -> (val, fAbs, fromIntegral fAbs / fromIntegral tamPrueba)) estadsAux
                                           estadisticasEsperadas = map (\(val,peso) -> (val, peso / sumaPesos)) listaParejas
{-
como dameElemAleatListaPesos pero con pesos de tipo Float y devolviendo también la lista de entrada menos el elemento escogido
-}
dameElemAleatListaPesosRestoFloat :: Int -> [(a, Float)] -> (a, Int, [(a, Float)])
dameElemAleatListaPesosRestoFloat aleat listaParejas = (elem, pos, restoInv)
        where listaPesos = map snd listaParejas
              sumaPesos = foldl1' (+) listaPesos
              aleatNorm = (fromIntegral aleat) * sumaPesos / (fromIntegral resolucionRandom)
              aplicaAleat _ ((term,peso):[]) listaConsumida _ posEnLista = (term, posEnLista, listaConsumida)
              aplicaAleat porcentaje ((term,peso):y:xs) listaConsumida posEnRecta posEnLista
                  | porcentaje < extDcho && porcentaje >= posEnRecta = (term, posEnLista, listaConsumida ++ (y:xs))
                  | otherwise                                        = aplicaAleat porcentaje (y:xs) (listaConsumida ++ [(term,peso)])(posEnRecta + peso) (posEnLista + 1)
                                                                       where extDcho = posEnRecta + peso
              (elem, pos, restoInv) = aplicaAleat aleatNorm listaParejas [] 0.0 1


pruDameElemAleatListaPesosRestoFloat :: IO ()
pruDameElemAleatListaPesosRestoFloat = do putStr "Prueba de dameElemAleatListaPesosRestoFloat\n"
                                          putStr ("Datos de entrada " ++ (show listaParejas) ++ "\n")
                                          putStr ("Resultados obtenidos (valor, frecuencia absoluta, frecuencia relativa): \n")
                                          putStr ("\t" ++ (show estadisticasReales) ++ "\n")
                                          putStr ("Resultados esperados (valor, frecuencia relativa): \n")
                                          putStr ("\t" ++ (show estadisticasEsperadas) ++ "\n")
                                          where listaParejas = [('a',0.33333),('b',0.5),('c',1.0),('d',0.5),('e',0.333333)]
                                                listaValores = map fst listaParejas
                                                sumaPesos = foldl1' (+) (map snd listaParejas)
                                                listaAleat = [1..resolucionRandom]
                                                tamListaAleat = length listaAleat
                                                prueba =  zip listaAleat (map (\x -> dameElemAleatListaPesosRestoFloat x listaParejas) listaAleat)
                                                tamPrueba = length prueba
                                                estadsAux = map (\valor -> (valor, length (filter (\(aleat, (valor2, pos,resto)) -> valor2 == valor) prueba))) listaValores
                                                estadisticasReales = map (\(val,fAbs) -> (val, fAbs, fromIntegral fAbs / fromIntegral tamPrueba)) estadsAux
                                                estadisticasEsperadas = map (\(val,peso) -> (val, peso / sumaPesos)) listaParejas

{-
dameSublistaAleatListaPesosFloat :: [Int] -> [(a, Float)] -> ([(a, Int)], [Int])
dameSublistaAleatListaPesosFloat aleat listaPesos = (sublistaValor_Posicion, restoAleat)
   -dada una lista de elementos con un peso asociado a cada uno, devuelve una sublista de tamaño aleatorio
   de elementos de la lista inicial elegidos segun sus pesos
   -el tamaño de la sublista resultado será mayor que 1 y menor o igual al tamaño de la lista de entrada
-}
--dameSublistaAleatListaPesosFloat :: [Int] -> [(a, Float)] -> ([(a, Int)], [Int])
dameSublistaAleatListaPesosFloat :: FuncAleatoria [(a, Float)] [(a, Int)]
dameSublistaAleatListaPesosFloat aleat@(a1:as) listaPesos = dameSublistaAleatListaPesosTamFloat as tamDestino listaPesos
                       where tamOri = length listaPesos
                             tamDestino = if (tamAux>0) then tamAux else 1
                                          where tamAux = round ( fromIntegral (a1 * tamOri) / fromIntegral resolucionRandom)

{-
dameSublistaAleatListaPesosRestoFloat :: [Int] -> [(a, Float)] -> ([(a, Int)], [(a, Int)], [Int])
dameSublistaAleatListaPesosRestoFloat aleat listaPesos = (sublistaValor_Posicion, sublista_no_elegida, restoAleat)
   -como dameSublistaAleatListaPesosFloat pero devolviendo tb la sublista no elegida, ed, la lista de entrada menos
la sublista elegida
-}
dameSublistaAleatListaPesosRestoFloat :: [Int] -> [(a, Float)] -> ([(a, Int)], [((a,Float), Int)], [Int])
dameSublistaAleatListaPesosRestoFloat aleat@(a1:as) listaPesos = dameSublistaAleatListaPesosTamRestoFloat as tamDestino listaPesos
                       where tamOri = length listaPesos
                             tamDestino = if (tamAux>0) then tamAux else 1
                                          where tamAux = round ( fromIntegral (a1 * tamOri) / fromIntegral resolucionRandom)

{-
dameSublistaAleatListaPesosTamRestoFloat :: [Int] -> Int -> [(a, Float)] -> ([(a, Int)], [((a,Float), Int)], [Int])
dameSublistaAleatListaPesosTamRestoFloat aleat cuantos listaPesos = (sublistaValor_Posicion, sublista_no_elegida, restoAleat)
   -como dameSublistaAleatListaPesosTamFloat pero devolviendo tb la sublista no elegida, ed, la lista de entrada menos
la sublista elegida
-}
dameSublistaAleatListaPesosTamRestoFloat :: [Int] -> Int -> [(a, Float)] -> ([(a, Int)], [((a,Float), Int)], [Int])
dameSublistaAleatListaPesosTamRestoFloat aleat cuantos listaPesos = (elemsElegidos, elemsRechazados, restoAleat)
                       where construyeSublista aleat2@(a1:as) n listaPesos
                                | n > 0     = ((elem, pos):restoElegido, restoNoElegido, restoAleat)
                                | otherwise = ([], listaPesos, aleat2)
                                               where (elem, pos, restoPesos) = dameElemAleatListaPesosRestoFloat a1 listaPesos
                                                     (restoElegido, restoNoElegido, restoAleat) = construyeSublista as (n-1) restoPesos
                             construyeListaPos _ [] = []
                             construyeListaPos pos ((val,peso):xs) = (pos, peso):(construyeListaPos (pos+1) xs)
                             listaPosiciones = construyeListaPos 0 listaPesos
                             (posElegidasAux, posRechazadasAux, restoAleat) = construyeSublista aleat cuantos listaPosiciones
                             posElegidas = sort (map fst posElegidasAux)
                             posRechazadas = sort (map fst posRechazadasAux)
                             elemsElegidos = [((fst (listaPesos!!pos)),pos)| pos <- posElegidas]
                             elemsRechazados = [((listaPesos!!pos),pos)| pos <- posRechazadas]

pruDameSublistaAleatListaPesosRestoFloat :: IO()
pruDameSublistaAleatListaPesosRestoFloat = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                              putStr ("Prueba con los valores :"++ (show listaParejas) ++ "\n")
                                              putStr ("Lista elegida: " ++ show(sublistaElegida aleat) ++ "\n")
                                              putStr ("Lista rechazada: " ++ show(sublistaRechazada aleat) ++ "\n")
                                              where listaParejas   = [('a',0.33333),('b',0.5),('c',1.0),('d',0.5),('e',0.333333)]
                                                    sublistaElegida aleat = primero (dameSublistaAleatListaPesosRestoFloat aleat listaParejas)
                                                    sublistaRechazada aleat = segundo (dameSublistaAleatListaPesosRestoFloat aleat listaParejas)


{-
dameSublistaAleatListaPesosTamFloat :: [Int] -> Int -> [(a, Float)] -> ([(a, Int)], [Int])
dameSublistaAleatListaPesosTamFloat aleat@(a1:as) cuantos listaPesos = (resul,restoAleat)
   -dada una lista de elementos con un peso asociado a cada uno, devuelve una sublista del tamaño especificado
   ,de elementos de la lista inicial elegidos segun sus pesos
-}

dameSublistaAleatListaPesosTamFloat :: [Int] -> Int -> [(a, Float)] -> ([(a, Int)], [Int])
dameSublistaAleatListaPesosTamFloat aleat cuantos listaPesos = (resul,restoAleat)
                       where construyeSublista aleat2@(a1:as) n listaPesos
                                | n > 0     = ((elem, pos):restoSublista, restoAleat)
                                | otherwise = ([], aleat2)
                                               where (elem, pos, restoPesos) = dameElemAleatListaPesosRestoFloat a1 listaPesos
                                                     (restoSublista, restoAleat) = construyeSublista as (n-1) restoPesos
                             construyeListaPos _ [] = []
                             construyeListaPos pos ((val,peso):xs) = (pos, peso):(construyeListaPos (pos+1) xs)
                             listaPosiciones = construyeListaPos 0 listaPesos
                             (posElegidasAux, restoAleat) = construyeSublista aleat cuantos listaPosiciones
                             posElegidas = sort (map fst posElegidasAux)
                             resul = [((fst (listaPesos!!pos)),pos)| pos <- posElegidas]

pruDameSublistaAleatListaPesosFloat :: IO()
pruDameSublistaAleatListaPesosFloat = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                         putStr ("Prueba con los valores :"++ (show listaParejas) ++ "\n")
                                         print (sublista aleat)
                                         where listaParejas   = [('a',0.33333),('b',0.5),('c',1.0),('d',0.5),('e',0.333333)]
                                               sublista aleat = fst (dameSublistaAleatListaPesosFloat aleat listaParejas)
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
Muestra un mensaje de pedidad y lee un entero de la entrada estï¿½ndar hasta que realmente sea un entero. Si no el usuario no ha escrito un
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
ejemploInteraccion = ("ï¿½Con cual de estos tipos quieres cenar esta noche?"
                      ,[(mensajeManolo, accionManolo),(mensajeAntonio, accionAntonio)])

mensajeManolo = "Manolo es un tipo duro, de los fuertes y callados"
accionManolo = do {putStrLn "Hola wapa, ï¿½te vienes a matar humanos?"}
mensajeAntonio = "Antonio es un hombre sensible, le encantan las flores y los cuadros de Manet"
accionAntonio = do {putStrLn "Hola, ï¿½te vienes a ver cuadros?"}

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
-La extensiï¿½n se deberï¿½ indicar sin el punto, por ejemplo "mid", NO ".mid" (que pondrï¿½a dos puntos, lo que
esta bien si es lo que se quiere)
-Si la ruta de entrada no tiene extension se aï¿½adirï¿½ la extensiï¿½n con un punto sin quitar nada, por ejemplo
cambiaExtension "txt" "pepe" = pepe.txt
-}
cambiaExtension :: String -> String -> String
cambiaExtension nuevaExtension ruta
  |pos == Nothing = ruta ++ "." ++ nuevaExtension
  |otherwise      = (invertir  (dropWhile (/='.') (invertir ruta))) ++ nuevaExtension
               where pos = elemIndex '.' ruta


{-
'elementoAleatorio' dada un generador de numeros aleatorios y una lista devuelve un elemento
aleatorio de la lista y el siguiente generador que hay que usar
-}
elementoAleatorio :: RandomGen b => b -> [a] -> (a,b)
elementoAleatorio g l = (l !! pos, sigg)
	where longitud = length l;
		(pos, sigg) = randomR (0, longitud - 1) g

