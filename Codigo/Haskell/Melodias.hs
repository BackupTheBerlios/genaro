module Melodias where
import List
import Basics
import BiblioGenaro
import Progresiones
import Escalas
import HaskoreAMidi
import PatronesRitmicos
import PrologAHaskell --para pruebas
import Ratio          --para pruebas
import Directory      --para pruebas
import CAHaskell      --para pruebas solo??????????
{-
BUGS!!!!!!!!!!!!!!
    -hazCurvaMelodicaAleatAcu:el 20 es una chunguez y el 0.8 ni te cuento
    -type PuntoMelodico = (SaltoMelodico, Dur) debería ser type PuntoMelodico = (SaltoMelodico, Dur, Acento), pq si no la melodia
no se callará nunca. Con Acento = 0 sería callarse, lo metere con lo del ritmo
    -Hay que hacer: ritmo  y unir varios acordes
    -Ajustar los pesos por dios!!!
    -reciclar para hacer el bajo con walking = salto de 3 grados como mucho
                                               apañar ritmo para que vaya a negras o corcheas:
                                                  .que cuadre con la dur del acorde: saltos excesivos de tempo/altura para encajar
   -hazMelodiaParaAcorde solo vale para curvas aleatorias. Reciclar en el futuro para que tb procese curvas escritas por el usuario,pero
ATENCION!!!, los dur de esas curvas se suponen a un grado de abstraccion mas elevado, deberán adaptarse para el patron ritmico concreto
-}
{-
--
-- PATRON RITMICO
--
type Voz = Int
type Acento = Float         -- Acento: intensidad con que se ejecuta ese tiempo. Valor de 0 a 100
type Ligado = Bool          -- Ligado: indica si una voz de una columna esta ligada con la se la siguiente columna
                            -- en caso de que no este dicha voz el ligado se ignora
type URV = [(Voz, Acento, Ligado)]	-- Unidad de ritmo vertical, especifica todas las filas de una unica columna
type URH = Dur 				-- Unidad de ritmo horizontal, especifica la duracion de una columna
type UPR = ( URV , URH)                 -- Unidad del patron ritmico, especifica completamente toda la informacion necesaria
                                        -- para una columna (con todas sus filas) en la matriz que representa el patron
type AlturaPatron = Int			-- numero maximo de voces que posee el patron
type MatrizRitmica = [UPR]              -- Una lista de columnas, vamos, como una matriz

type PatronRitmico = (AlturaPatron, MatrizRitmica)
-}
{-
Numero de grados que se mueve hacia arriba la melodia desde el punto anterior
-}
type SaltoMelodico = Int
{-
Numero de grados que se mueve hacia arriba la melodia desde el punto anterior
-}
type PuntoMelodico = (SaltoMelodico)
type CurvaMelodica = [PuntoMelodico]
{-
Resultado de procesar un PatronRitmico, da los acentos fuertes que se consideraran para una melodia. Para ello
calcula la lista que tiene para cada columna de un patron ritmico la media de acentos de cada voz, y la media
total de acento dentro de la matriz. Luego devuelve el resultado de procesar esa lista dejando con acento cero
las columnas que tengan acento menor que la media, y dejando igual aquellas que lo tengan mayor o igual
-}
type ListaAcentos = [(Acento, Dur)]
construyeListaAcentos :: PatronRitmico -> ListaAcentos
construyeListaAcentos (numVoces, matriz) = listaAcentos
                                    where numColumnas = length matriz
                                          matrizVertical = map fst matriz
                                          listaAcentoMedioCols =  [(foldl' (\suma -> \(_,ac,_) -> suma + ac ) 0 col) / fromIntegral numVoces |col <- matrizVertical]
                                          acentoMedio = (foldl' (+) 0 listaAcentoMedioCols) / fromIntegral numColumnas
                                          listaAcentos = zip (map (\acento -> if acento >= acentoMedio then acento else 0) listaAcentoMedioCols) (map snd matriz)

pruListaAcentos :: String -> IO()
pruListaAcentos ruta = do (FPRC cols resolucion patronRitmico) <- leePatronRitmicoC ruta
                          putStr "Lista de acentos para melodia resultado\n"
                          print (construyeListaAcentos patronRitmico)
{-
dada una lista infinita de numeros enteros aleatorios entre 1 y resolucionRandom construye
una curva melodica aleatoria segun ciertos criterios
hazCurvaMelodicaAleat aleat saltoMax probSalto numPuntos duracionTotal = (curva, aleatSobrantes)
        .aleat         : lista infinita de numeros aleatorios entre 1 y resolucionRandom
        .saltoMax      : numero de grados que se saltara como maximo en cada punto de la curva
        .probSalto     : cuanto mayor sea mayor probabilidad habra de que la curva melodica cambie de direccion en cada punto.
                         Debe ser del orden del numero de grados, es decir, de 1 a 12 mas o menos
        .numPuntos     : numero de puntos que tendra la curva
        .duracionTotal : duracion de la curva melodica en dur
Conceptos:
  -Las notas mas largas son las notas mas estables
  -Ajustar la curva melodica al ritmo, rellenando los huecos con notas cortas de paso o de bordadura

-}
hazCurvaMelodicaAleat :: [Int] -> Int -> Int -> Int -> Dur -> (CurvaMelodica, [Int])
hazCurvaMelodicaAleat aleat@(a1:as) saltoMax probSalto numPuntos duracionTotal = hazCurvaMelodicaAleatAcu as sube saltoMax probSalto numPuntos duracionTotal 0
                                                                                 where sube = (fromIntegral a1/ fromIntegral resolucionRandom) >= 0.5

{-
hazCurvaMelodicaAleatAcu aleat sube saltoMax probSalto numPuntos durTotal movAcumulado = (curva, aleatSobrantes)
        .aleat         : lista infinita de numeros aleatorios entre 1 y resolucionRandom
        .sube          : es cierto sii la melodia esta subiendo por la escala
        .saltoMax      : numero de grados que se saltara como maximo en cada punto de la curva
        .probSalto     : cuanto mayor sea mayor probabilidad habra de que la curva melodica cambie de direccion en cada punto.
                         Debe ser del orden del numero de grados, es decir, de 1 a 12 mas o menos
        .numPuntos     : numero de puntos que tendra la curva
        .duracionTotal : duracion de la curva melodica en dur
        .movAcumulado  : numero de grados que se llevan movidos en el sentido (ascendente o descendente) actual de la curva
-}
hazCurvaMelodicaAleatAcu :: [Int] -> Bool -> Int -> Int -> Int -> Dur -> Int -> (CurvaMelodica, [Int])
hazCurvaMelodicaAleatAcu aleat _ _ _ 0 _ _ = ([],aleat)
hazCurvaMelodicaAleatAcu aleat@(a1:a2:as) sube sm ps n durTotal movAcumulado
  | n > 0 = (nuevoPunto:restoCurva, aleatSobran)
               where salta        = (fromIntegral a1/fromIntegral resolucionRandom) <= (fromIntegral movAcumulado * fromIntegral ps/20)
                     candsNoSalto =  map (\x -> if (x /= 0) then (x,(1/ fromIntegral x)) else (x,0.8::Float)) [0..sm]
                     candsSalto   =  map (\(val,peso)-> (val,peso + fromIntegral val* fromIntegral movAcumulado)) candsNoSalto
                     (saltoAbs,_)    = if salta
                                          then dameElemAleatListaPesosFloat a2 candsSalto
                                          else dameElemAleatListaPesosFloat a2 candsNoSalto
                     nuevoSube       = if salta
                                          then (not sube)
                                          else sube
                     salto           = if nuevoSube
                                          then saltoAbs
                                          else (-1) * saltoAbs
                     nuevoPunto    = salto
                     (restoCurva,aleatSobran)    = hazCurvaMelodicaAleatAcu as nuevoSube sm ps (n-1) durTotal (movAcumulado + saltoAbs)
{-
aplicaCurvaMelodica
Conceptos:
  -Las notas mas largas son las notas mas estables
  -Ajustar la curva melodica al ritmo, rellenando los huecos con notas cortas de paso o de bordadura, para ello
      .primero carga el ritmo en un elemento type ListaAcentos = [(Acento, Dur)]
      .rellena los huecos del ritmo con notas bastante establesESTABLES; las mas de la curva!!como?,si todo es relativo???:puedo
pq se la tonica y la escala: !! si nos piden menos notas de las que hay en la lista de
acentos elegir en cuales vamos a atacar y en el resto ver si las ligamos a las anteriores o si las dejamos en silencio
      .si todavia nos faltan notas rellenar los espacios con notas menos estables y mas cortas

-}
{-
aplicaCurvaMelodica :: PatronRitmico -> Registro -> Escala -> PitchClass -> Pitch -> CurvaMelodica ->  [Music]
--aplicaCurvaMelodica patronRit registro escala tonica pitchPartida [] = [Rest 0]
aplicaCurvaMelodica patronRit registro escala tonica pitchPartida curva =
                    where acentos = construyeListaAcentos patronRit
-}
--type ListaAcentos = [(Acento, Dur)]
{-
      .rellena los huecos del ritmo con notas bastante establesESTABLES; las mas de la curva!!como?,si todo es relativo???:puedo
pq se la tonica y la escala: !! si nos piden menos notas de las que hay en la lista de
acentos elegir en cuales vamos a atacar y en el resto ver si las ligamos a las anteriores o si las dejamos en silencio
     . la curva sin consumir representada de forma que no se pierda la posicion relativa de los puntos de la curva, como la curva
de entrada pero con menos densidad

aplicaCurvaMelodicaAListaAcentos :: [Int] -> Registro -> Escala -> PitchClass -> Pitch -> ListaAcentos -> CurvaMelodica -> (([Music],CurvaMelodicaEspacios), Int)
aplicaCurvaMelodicaAListaAcentos listaAleat registro escala tonica pitchPartida listaAcentos CurvaMelodica = ((musica,curvaSinConsumir), restoAleat)
-}
type CurvaMelodicaEspacios = [Maybe PuntoMelodico]
curvaMelodicaAGradosPicth :: Registro -> Escala -> PitchClass -> CurvaMelodica -> Pitch -> [(Grado,Pitch)]
curvaMelodicaAGradosPicth registro escala tonica [] pitchPartida = []
curvaMelodicaAGradosPicth registro escala tonica (salto:pms) pitchPartida = (nuevoGrado,nuevoPitch) : restoMelodia
                    where (p,oct)   = saltaIntervaloPitch escala tonica salto pitchPartida
                          octavaDef = ajustaOctava registro oct
                          nuevoPitch = (p,octavaDef)
                          nuevoGrado = dameIntervaloPitch tonica nuevoPitch
                          restoMelodia = curvaMelodicaAGradosPicth registro escala tonica pms nuevoPitch
{-
Devuelve el resultado de truncar la octava suministrada para que se ajuste al registro especificado
-}
ajustaOctava :: Registro -> Octave -> Octave
ajustaOctava registro oct = if elem oct registro
                               then oct
                               else if oct < octavaMin
                                    then octavaMin --caso de octava mas baja que el registro
                                    else octavaMax --caso de octava mas alta que el registro
                                         where octavaMin = dameMinimizador id registro
                                               octavaMax = dameMinimizador (*(-1)) registro
{-
supone siempre que la tonica es Do
-}
{-
VIEJO
pitchDeTonicaDelAcorde = pitch (gradoAIntAbs grado + 24) -- 24 pq supone Do de tonica
tonica = fst pitchDeTonicaDelAcorde
pitchPartida = pitch (gradoAIntAbs gradoIni + absPitch pitchDeTonicaDelAcorde)
-}
{-
(tonica,_) = pitch (gradoAIntAbs grado + 0) -- 0 pq supone Do de tonica, salta desde DO a la tonica del acorde
(pcAux, octAux) = pitch (gradoAIntAbs grado + gradoAIntAbs gradoIni + 0) --grado para saltar desde el DO (0) a la tonica del acorde, gradoIni para ir al grado que sea dentro del acorde
-}
hazMelodiaParaAcorde :: [Int] -> Int -> Int -> Int -> (Cifrado, Dur) -> ([Music],[Int])
hazMelodiaParaAcorde aleat@(a1:a2:as) saltoMax probSalto numNotas (acorde@(grado,matricula), duracion) = ([Rest 0], aleat)
{-hazMelodiaParaAcorde aleat@(a1:a2:as) saltoMax probSalto numNotas (acorde@(grado,matricula), duracion) = (musica, restoAleat)
                where escala = escalaDelAcorde acorde
                      notasYPesos = dameNotasYPesosDeEscala escala
                      (gradoIni,_) = dameElemAleatListaPesos a1 notasYPesos
                      octavaCentral = (\xs -> xs !! (length xs `div` 2)) registroSolista
                      octavasYPesos = zip registroSolista  (map (\x -> 1 / fromIntegral (abs(x - octavaCentral)+1)) registroSolista)
                      (octavaDePartida,_) = dameElemAleatListaPesosFloat a2 octavasYPesos
                      (tonica,_) = pitch (gradoAIntAbs grado + 0)
                      (pcAux, octAux) = pitch (gradoAIntAbs grado + gradoAIntAbs gradoIni + 0)
                      pitchPartida = (pcAux, octavaDePartida)
                      (curvaAleat,restoAleat) = hazCurvaMelodicaAleat as saltoMax probSalto numNotas duracion
                      musica = aplicaCurvaMelodica registroSolista escala tonica curvaAleat pitchPartida
-}
{-
saltaIntervaloGrado escala num gradoPartida, devuelve el grado correspondiente a saltar en la escala indicada
tantos grados como num, sin contar desde gradoPartida. Por ejemplo:
  -saltaIntervalo jonica 1 I devuelve II
  -saltaIntervalo jonica (-1) I devuelve VII
  -saltaIntervalo jonica 0 I devuelve I
-}
saltaIntervaloGrado :: Escala -> Int -> Grado -> Grado
saltaIntervaloGrado escala num gradoPartida
  | num == 0 = gradoPartida
  | otherwise = gradoDestino
            where (_,gradosEscala,_)  = dameInfoEscala escala
                  gradoDestino = case (elemIndex gradoPartida gradosEscala) of
                                      Just posGradoPartida -> gradoSalida
                                                                  where numGrados      = length gradosEscala
                                                                        posGradoSalida = (posGradoPartida + num) `mod` numGrados
                                                                        gradoSalida    = gradosEscala !! posGradoSalida
                                      Nothing              -> saltaIntervaloGrado escala numAux gradoCercano
                                                                  where subir = num > 0
                                                                        gradoCercano = dameGradoDiatonicoCercano subir escala gradoPartida
                                                                        numAux = if num>0
                                                                                    then num - 1
                                                                                    else num + 1

{-
saltaIntervaloPitch escala num gradoPartida, devuelve el Pitch correspondiente a saltar en la escala indicada
tantos grados como num, contando desde gradoPartida
-}
saltaIntervaloPitch :: Escala -> PitchClass -> Int -> Pitch -> Pitch
saltaIntervaloPitch escala tonica num notaPartida = resul
                where (_,gradosEscala,_)  = dameInfoEscala escala
                      gradoPartida        = dameIntervaloPitch tonica notaPartida
                      gradoSalida         = saltaIntervaloGrado escala num gradoPartida
                      numGrados           = length gradosEscala
                      salto               = (gradoAIntAbs gradoSalida) - (gradoAIntAbs gradoPartida) + (div num numGrados)*12
                      resul               = pitch ((absPitch notaPartida) + salto)

pruMelAc :: IO()
pruMelAc = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
              putStr mensajeGenerandoMidi
              haskoreAMidi (musica aleat) rutaDestinoMidi
              putStr "\n Proceso terminado satisfactoriamente\n"
              where rutaDestinoMidi = "c:/hlocal/midiMeloso.mid"
                    mensajeGenerandoMidi = "\n Generando el archivo midi: " ++ rutaDestinoMidi ++ "\n"
                    musica aleat = line (fst (hazMelodiaParaAcorde aleat 4 8 4 ((I,Maj7), 2%1)))

pruMelAcArgs :: String -> Int -> Int -> Int -> Dur -> IO()
pruMelAcArgs dirTrabajo saltoMax probSalto numNotas duracion = do setCurrentDirectory dirTrabajo
                                                                  putStr (mensajeDirTrabajo dirTrabajo)
                                                                  aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                                  putStr mensajeGenerandoMidi
                                                                  haskoreAMidi (musica aleat) rutaDestinoMidi
                                                                  putStr "\n Proceso terminado satisfactoriamente\n"
                                                                  where mensajeDirTrabajo dir = "\n El directorio de trabajo es: " ++ dir ++ "\n"
                                                                        rutaDestinoMidi = "./midiMeloso.mid"
                                                                        parametros = "\n\tsaltoMaximo: " ++ (show saltoMax) ++ "\n\tpeso de cambiar de direccion: " ++ (show probSalto) ++ "\n\tnumero de notas: " ++ (show numNotas) ++ "\n\tduracion de la melodia: " ++ (show duracion) ++ "\n\tfichero destino: " ++ rutaDestinoMidi
                                                                        mensajeGenerandoMidi = "\n Generando el archivo midi de parametros: " ++ parametros ++ "\n"
                                                                        musica aleat = line (fst (hazMelodiaParaAcorde aleat saltoMax probSalto numNotas ((I,Maj7), duracion)))

pruCurvaMelAleat :: Int -> Int -> Int -> Dur -> IO()
pruCurvaMelAleat saltoMax probSalto numPuntos duracionTotal = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                                 --print (salidaFormat aleat)
                                                                 print (zip (curvaMelodica aleat) (listaGradosPitch aleat))
                                                                 where curvaMelodica aleat = fst (hazCurvaMelodicaAleat aleat saltoMax probSalto numPuntos duracionTotal)
                                                                       listaGradosPitch aleat = curvaMelodicaAGradosPicth registroSolista Jonica C (curvaMelodica aleat) (C,5)
                                                                     --  salida aleat = zip (curvaMelodica aleat) (listaGradosPitch aleat)
                                                                     -- salidaFormat aleat = zip (salida aleat) ['\n' | x<- [1..(length (salida aleat))]]

pruFallo :: String -> Int -> IO()
pruFallo dirTrabajo num
  | num > 0   = do putStr ("\n\nFaltan " ++ (show num) ++" pruebas\n\n")
                   pruMelAcArgs dirTrabajo 5 10 10 (5%1)
                   pruFallo dirTrabajo (num - 1)
  | otherwise = do putStr "\n\nNo ha fallado, fin\n\n"
--haskoreAMidi :: Music -> String -> IO()
--hazMelodiaParaAcorde aleat@(a1:as) saltoMax numNotas (acorde@(grado,matricula), duracion) = (musica, restoAleat)
