module Melodias where
import Basics
import Progresiones
import Escalas
import PrologAHaskell --para pruebas
import Ratio          --para pruebas
import List


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
aplicaCurvaMelodica escala tonica curva pitchPartida
-}
aplicaCurvaMelodica :: Escala -> PitchClass -> CurvaMelodica -> Pitch -> [Music]
aplicaCurvaMelodica escala tonica [] pitchPartida = []
aplicaCurvaMelodica escala tonica ((salto,dur):pms) pitchPartida = nuevaNota:restoMelodia
                    where nuevoPitch   = saltaIntervaloPitch escala tonica salto pitchPartida
                          nuevaNota    = Note nuevoPitch dur []
                          restoMelodia = aplicaCurvaMelodica escala tonica pms nuevoPitch

hazMelodiaParaAcorde :: Cifrado -> Music
hazMelodiaParaAcorde = line . hazMelodiaParaAcordeLista

hazMelodiaParaAcordeLista :: Cifrado -> [Music]
hazMelodiaParaAcordeLista _ = [Rest 0]

{-
Dado un acorde devuelve una lista de alturas de notas que se usarán para formar una melodia sobre
ese acorde. El ritmo todavia no interviene
daListaNotasDeMelodiaSobreAcorde listaAleat cifrado:
- listaAleat es una lista infinita de numeros enteros
aleatorios entre 1 y resolucionRandom
- cifrado es el acorde sobre el que se hace la melodia
-devuelve (Notas, listaAleat2):
  -Notas: lista de pitch que forman la melodia
  -listaAleat2: lista de entrada al quitarle los numeros aleatorios empleados

-}
{-
--daListaNotasDeMelodiaSobreAcorde :: Cifrado -> [Pitch]
daListaNotasDeMelodiaSobreAcorde :: [Int] -> Cifrado -> ([Pitch], [Int])
daListaNotasDeMelodiaSobreAcorde (n1:n2:ns) acorde =
                                         where numMaxNotas = 8 --luego será parametro, o saldrá con la duración del cifrado?
                                               numNotas = round (fromIntegral n1*numMaxNotas/resolucionRandom)
                                               escala = escalaDelAcorde acorde
                                               notasYPesos = dameNotasYPesosDeEscala escala
                                               (gradoIni,_) = dameElemAleatListaPesos n2 notasYPesos

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

{- Pleister -}
pruProg1 :: String -> IO()
pruProg1 rutaProg = do prog <- leeProgresion rutaProg
                       putStr (menAcs prog)
                       putStr (menEcs prog)
                       putStr (menInfoEcs prog)
                       where menAcs prog = "\nAcordes: "++ (show prog) ++"\n"
                             menEcs prog = "\nEscalas del momento: " ++  (show (map escalaDelAcorde (map fst prog))) ++ "\n"
                             menInfoEcs prog = "\nInfo de escalas del momento: " ++  (show (map infoAcordeMayor (map fst prog))) ++ "\n"
