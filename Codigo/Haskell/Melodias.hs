module Melodias where
import List
import Basics
import BiblioGenaro
import Progresiones
import Escalas
import HaskoreAMidi
import PrologAHaskell --para pruebas
import Ratio          --para pruebas
import Directory      --para pruebas
{-
BUGS!!!!!!!!!!!!!!
    -hazCurvaMelodicaAleatAcu:el 20 es una chunguez
    -De vez en cuando da un error de chr out of range: sospecho que lo que ocurre es
que me paso de octava y me salgo del numero de octavas que permite el haskore. Depurar
    -Hay que hacer: ritmo  y unir varios acordes
    -Ajustar los pesos por dios!!!
    -reciclar para hacer el bajo con walking = salto de 3 grados como mucho
                                               apañar ritmo para que vaya a negras o corcheas:
                                                  .que cuadre con la dur del acorde: saltos excesivos de tempo/altura para encajar
-}

{-
del modulo Progresiones:
data Grado = I|BII|II|BIII|III|IV|BV|V|AUV|VI|BVII|VII
             |BBII|BBIII|AUII|BIV|AUIII|AUIV|BBVI|BVI|AUVI|BVIII|AUVIII
             |BIX|IX|BX|X|BXI|XI|AUXI|BXII|XII|AUXII|BXIII|XIII|AUXIII
             |V7 Grado
             |IIM7 Grado
     deriving(Show,Eq,Ord)

data Matricula = Mayor|Menor|Au|Dis|Sexta|Men6|Men7B5|Maj7|Sept|Men7|MenMaj7|Au7|Dis7
     deriving(Enum,Read,Show,Eq,Ord,Bounded)

type Cifrado = (Grado, Matricula)

type Progresion = [(Cifrado, Dur)]
-}
{-
del modulo Escalas:
{-
Una escala es una lista de grados. Todo el rato se supone implicito que el grado I corresponde a
Do, luego ya se puede trasponer el tono fï¿½cilmente con la constructora Trans del tipo Music
-}
type Escala = [Grado]

-}

{-
Numero de grados que se mueve hacia arriba la melodia desde el punto anterior
-}
type SaltoMelodico = Int
{-
Numero de grados que se mueve hacia arriba la melodia desde el punto anterior, y duraciÃ³n de
este punto
-}
type PuntoMelodico = (SaltoMelodico, Dur)
type CurvaMelodica = [PuntoMelodico]


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
               where dur          = 1%4 --esta funcion solo deberia dar los pitch, el ritmo se ajusta luego
                     salta        = (fromIntegral a1/fromIntegral resolucionRandom) <= (fromIntegral movAcumulado * fromIntegral ps/20)
                     candsNoSalto =  map (\x -> (x,(1/ fromIntegral x))) [1..sm]
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
                     nuevoPunto    = (salto, dur)
                     (restoCurva,aleatSobran)    = hazCurvaMelodicaAleatAcu as nuevoSube sm ps (n-1) durTotal (movAcumulado + saltoAbs)
{-
aplicaCurvaMelodica registro escala tonica curva pitchPartida
-}
aplicaCurvaMelodica :: Registro -> Escala -> PitchClass -> CurvaMelodica -> Pitch -> [Music]
aplicaCurvaMelodica registro escala tonica [] pitchPartida = [Rest 0]
aplicaCurvaMelodica registro escala tonica ((salto,dur):pms) pitchPartida = nuevaNota : restoMelodia
                    where (p,oct)   = saltaIntervaloPitch escala tonica salto pitchPartida
                          octavaDef = if elem oct registro
                                         then oct
                                         else if oct < octavaMin
                                                then octavaMin --caso de octava mas baja que el registro
                                                else octavaMax --caso de octava mas alta que el registro
                                                   where octavaMin = dameMinimizador id registro
                                                         octavaMax = dameMinimizador (*(-1)) registro
                          nuevoPitch = (p,octavaDef)
                          nuevaNota    = Note nuevoPitch dur []
                          restoMelodia = aplicaCurvaMelodica registro escala tonica pms nuevoPitch

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
hazMelodiaParaAcorde aleat@(a1:a2:as) saltoMax probSalto numNotas (acorde@(grado,matricula), duracion) = (musica, restoAleat)
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
                                                                 print (fst (hazCurvaMelodicaAleat aleat saltoMax probSalto numPuntos duracionTotal))
{-
prueba para comprobar el numero de octavas que soporta el haskore antes de ser estridente
pruRegistro dirTrabajo nota octavaInferior octavaSuperior
CONCLUSIONES:
    -solo se admiten octavas mayores o iguales a 0
    -las octavas por encima del 10 son inuadibles, y el 10 es desagradable
    -la octava 0 es de ultratumba
    -Por tanto: registro = [1..9]
                registroGrave = [1..3]
                registroMedio = [4..6]
                registroAgudo = [7..9]

-}

--haskoreAMidi :: Music -> String -> IO()
--hazMelodiaParaAcorde aleat@(a1:as) saltoMax numNotas (acorde@(grado,matricula), duracion) = (musica, restoAleat)
