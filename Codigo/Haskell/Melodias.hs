module Melodias where
import List
import Basics
import BiblioGenaro
import Progresiones
import Escalas
import HaskoreAMidi
import PrologAHaskell --para pruebas
import Ratio          --para pruebas
import Directory         --para pruebas
{-
BUGS!!!!!!!!!!!!!!
    -De vez en cuando da un error de chr out of range: sospecho que lo que ocurre es
que me paso de octava y me salgo del numero de octavas que permite el haskore. Depurar
    -Hay que hacer: ritmo  y unir varios acordes
    -Ajustar los pesos por dios!!!
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
Do, luego ya se puede trasponer el tono f�cilmente con la constructora Trans del tipo Music
-}
type Escala = [Grado]

-}

{-
Numero de grados que se mueve hacia arriba la melodia desde el punto anterior
-}
type SaltoMelodico = Int
{-
Numero de grados que se mueve hacia arriba la melodia desde el punto anterior, y duración de
este punto
-}
type PuntoMelodico = (SaltoMelodico, Dur)
type CurvaMelodica = [PuntoMelodico]


{-
dada una lista infinita de numeros enteros aleatorios entre 1 y resolucionRandom construye
una curva melodica aleatoria segun ciertos criterios
contruyeCurvaMelodicaAleat aleat numPuntos duracionTotal = (curva, aleatSobrantes)
-}
hazCurvaMelodicaAleat :: [Int] -> Int -> Int -> Dur -> (CurvaMelodica, [Int])
hazCurvaMelodicaAleat aleat saltoMax numPuntos duracionTotal = hazCurvaMelodicaAleatAcu aleat saltoMax numPuntos duracionTotal 0

hazCurvaMelodicaAleatAcu :: [Int] -> Int -> Int -> Dur -> Int -> (CurvaMelodica, [Int])
hazCurvaMelodicaAleatAcu aleat _ 0 _ _ = ([],aleat)
hazCurvaMelodicaAleatAcu aleat@(a1:a2:as) sm n durTotal movAcumulado
  | n > 0 = (nuevoPunto:restoCurva, aleatSobran)
               where dur          = 1%4 --esta funcion solo deberia dar los pitch, el ritmo se ajusta luego
                     salta        = (fromIntegral a1/fromIntegral resolucionRandom) >= (fromIntegral movAcumulado/fromIntegral sm)
                     candsNoSalto =  map (\x -> (x,(1/ fromIntegral x))) [1..sm]
                     candsSalto   =  map (\(val,peso)-> (val,peso + fromIntegral val* fromIntegral movAcumulado)) candsNoSalto
                     (salto,_)    = if salta
                                       then dameElemAleatListaPesosFloat a2 candsSalto
                                       else dameElemAleatListaPesosFloat a2 candsNoSalto
                     nuevoPunto    = (salto, dur)
                     (restoCurva,aleatSobran)    = hazCurvaMelodicaAleatAcu as sm (n-1) durTotal (movAcumulado + salto)
{-
pepe :: Int -> Int -> Int -> Bool
pepe x y z = (fromIntegral x/ fromIntegral resolucionRandom) >= (fromIntegral y / fromIntegral z)

loli :: Int -> [(Int, Float)]
loli sm = map (\x -> (x,(1/ fromIntegral x))) [1..sm]
-}
{-
aplicaCurvaMelodica escala tonica curva pitchPartida
-}
aplicaCurvaMelodica :: Escala -> PitchClass -> CurvaMelodica -> Pitch -> Music
aplicaCurvaMelodica escala tonica [] pitchPartida = Rest 0
aplicaCurvaMelodica escala tonica ((salto,dur):pms) pitchPartida = nuevaNota :+: restoMelodia
                    where nuevoPitch   = saltaIntervaloPitch escala tonica salto pitchPartida
                          nuevaNota    = Note nuevoPitch dur []
                          restoMelodia = aplicaCurvaMelodica escala tonica pms nuevoPitch

{-
supone siempre que la tonica es Do
-}
hazMelodiaParaAcorde :: [Int] -> Int -> Int -> (Cifrado, Dur) -> (Music,[Int])
hazMelodiaParaAcorde aleat@(a1:as) saltoMax numNotas (acorde@(grado,matricula), duracion) = (musica, restoAleat)
		where escala = escalaDelAcorde acorde
                      notasYPesos = dameNotasYPesosDeEscala escala
                      (gradoIni,_) = dameElemAleatListaPesos a1 notasYPesos
                      pitchDeTonicaDelAcorde = pitch (gradoAIntAbs grado + 24) -- 24 pq supone Do de tonica
                      tonica = fst pitchDeTonicaDelAcorde
                      pitchPartida = pitch (gradoAIntAbs gradoIni + absPitch pitchDeTonicaDelAcorde)
                      (curvaAleat,restoAleat) = hazCurvaMelodicaAleat as saltoMax numNotas duracion
                      musica = aplicaCurvaMelodica escala tonica curvaAleat pitchPartida

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

{- Pleister -}
pruMelAc :: IO()
pruMelAc = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
              putStr mensajeGenerandoMidi
              haskoreAMidi (musica aleat) rutaDestinoMidi
              putStr "\n Proceso terminado satisfactoriamente\n"
              where rutaDestinoMidi = "c:/hlocal/midiMeloso.mid"
                    mensajeGenerandoMidi = "\n Generando el archivo midi: " ++ rutaDestinoMidi ++ "\n"
                    musica aleat = fst (hazMelodiaParaAcorde aleat 4 8 ((I,Maj7), 2%1))

pruMelAcArgs :: String -> Int -> Int -> Dur -> IO()
pruMelAcArgs dirTrabajo saltoMax numNotas duracion = do setCurrentDirectory dirTrabajo
                                                        putStr (mensajeDirTrabajo dirTrabajo)
                                                        aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                        putStr mensajeGenerandoMidi
                                                        haskoreAMidi (musica aleat) rutaDestinoMidi
                                                        putStr "\n Proceso terminado satisfactoriamente\n"
                                                        where mensajeDirTrabajo dir = "\n El directorio de trabajo es: " ++ dir ++ "\n"
                                                              rutaDestinoMidi = "c:/hlocal/midiMeloso.mid"
                                                              parametros = "\n\tsaltoMaximo: " ++ (show saltoMax) ++ "\n\tnumero de notas: " ++ (show numNotas) ++ "\n\tduracion de la melodia: " ++ (show duracion) ++ "\n\tfichero destino: " ++ rutaDestinoMidi
                                                              mensajeGenerandoMidi = "\n Generando el archivo midi de parametros: " ++ parametros ++ "\n"
                                                              musica aleat = fst (hazMelodiaParaAcorde aleat saltoMax numNotas ((I,Maj7), duracion))

--hazMelodiaParaAcorde aleat@(a1:as) saltoMax numNotas (acorde@(grado,matricula), duracion) = (musica, restoAleat)
