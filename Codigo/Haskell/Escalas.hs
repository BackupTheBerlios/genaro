module Escalas where
import Progresiones
import Basics
import BiblioGenaro
import List
import Ratio          --para pruebas
import Directory      --para pruebas
import HaskoreAMidi   --para pruebas
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
Una escala es una lista de grados. Todo el rato se supone implicito que el grado I corresponde a
Do, luego ya se puede trasponer el tono f�cilmente con la constructora Trans del tipo Music
-}
data Escala = Jonica|Dorica|Frigia|Lidia|Mixolidia|Eolia|Locria|MixolidiaB13|MixolidiaB9B13AU9
     deriving(Enum,Read,Show,Eq,Ord,Bounded)
{-
InfoEscala = (tensiones, lista de notas que la forman, notas a evitar)
-}
type InfoEscala = ([Grado], [Grado], [Grado])

dameInfoEscala :: Escala -> InfoEscala
dameInfoEscala Jonica = ([IX,XIII],[I,II,III,IV,V,VI,VII],[IV])
dameInfoEscala Dorica = ([IX,XI],[I,II,BIII,IV,V,VI,BVII],[VI])
dameInfoEscala Frigia = ([XI],[I,BII,BIII,IV,V,BVI,BVII],[BII,BVI])
dameInfoEscala Lidia = ([IX,AUXI,XIII],[I,II,III,AUIV,V,VI,VII],[])
dameInfoEscala Mixolidia = ([IX,XIII],[I,II,III,IV,V,VI,BVII],[IV])
dameInfoEscala Eolia = ([IX,XI],[I,II,BIII,IV,V,BVI,BVII],[BVI])
dameInfoEscala Locria = ([XI,BXIII],[I,BII,BIII,IV,BV,BVI,BVII],[BII])
dameInfoEscala MixolidiaB13 = ([BIX,IX,BXIII],[I,II,III,IV,V,BVI,BVII],[IV])
dameInfoEscala MixolidiaB9B13AU9 = ([BIX,BXIII],[I,BII,AUII,III,IV,V,BVI,BVII],[IV])


{-
dameIntervaloPitch :: PitchClass -> Pitch -> Grado
dameIntervaloPitch tonica pitch devuelve que grado es la nota indicada por pitch respecto
a tonica
-}
dameIntervaloPitch :: PitchClass -> Pitch -> Grado
dameIntervaloPitch tonica p = grado
                where absTonica = absPitch (tonica,0)
                      abs = absPitch p
                      grado = absPitchAGrado (abs - absTonica)

{-
dameGradoDiatonicoCercano subir escala gradoPartida devuelve el grado diat�nico m�s cercano al
indicado. En el caso de que haya dos grados diat�nicos a la misma distancia devuelve el superior
en el caso de q subir sea cierto y el inferior en el otro caso
-}
dameGradoDiatonicoCercano :: Bool -> Escala -> Grado -> Grado
dameGradoDiatonicoCercano subir escala gradoPartida = gradoResul
                            where (_,gradosEscala,_)  = dameInfoEscala escala
                                  distancia g1 g2 = abs ((gradoAIntAbs g1) - (gradoAIntAbs g2))
                                  gradosCandidatos = dameMinimizadores (distancia gradoPartida) gradosEscala
                                  gradoResul = if subir
                                                  then dameMinimizador (\g -> (-1)*(gradoAIntAbs g)) gradosCandidatos
                                                  else dameMinimizador gradoAIntAbs gradosCandidatos

{-
Dada una escala devuelve una lista de parejas cuya primer componente es cada uno de los grados que
conforman la escala y cuya segunda componente es un peso asociado a cada grado que indica la probabilidad
que sea la nota con la que se empiece una melodía para un acorde.
-}
dameNotasYPesosDeEscala :: Escala -> [(Grado, Int)]
dameNotasYPesosDeEscala escala
  | elem escala escalas7Notas   = map (filtraNotasAEvitar notasAEvitar) (zip listaGrados (map peso7Notas [1..numGrados]))
  | escala == MixolidiaB9B13AU9 = map (filtraNotasAEvitar notasAEvitar) (zip listaGrados (map pesoMixB9B13AU9 [1..numGrados]))
                where escalas7Notas = [Jonica,Dorica, Frigia, Lidia, Mixolidia, Eolia, Locria, MixolidiaB13]
                      (_,listaGrados,notasAEvitar) = dameInfoEscala escala
                      numGrados = length listaGrados
                      peso7Notas 1 = 100  --peso que se le dará al primer grado de una escala de 7 notas
                      peso7Notas 4 = 90
                      peso7Notas 5 = 100
                      peso7Notas 3 = 80
                      peso7Notas 6 = 65
                      peso7Notas 2 = 30
                      peso7Notas 7 = 30
                      pesoMixB9B13AU9 num
                        | num == 1             = peso7Notas 1
                        | (num==2) || (num==3) = peso7Notas 2
                        | num > 3              = peso7Notas (num-1)
                      filtraNotasAEvitar notasAEvitar (grado, peso)
                        | elem grado notasAEvitar = (grado, 10)
                        | otherwise = (grado, peso)


{-
Para un acorde especificado con un elemento de tipo cifrado devuelve su escala,
en el contexto del modo mayor
escalaDelAcorde cifrado = escala_del_momento
-}
escalaDelAcorde :: Cifrado -> Escala
escalaDelAcorde (I, Maj7) = Jonica
escalaDelAcorde (II, Men7) = Dorica
escalaDelAcorde (III, Men7) = Frigia
escalaDelAcorde (IV, Maj7) = Lidia
escalaDelAcorde (V, Sept) = Mixolidia
escalaDelAcorde (VI, Men7) = Eolia
escalaDelAcorde (VII, Men7B5) = Locria
escalaDelAcorde (V7 II, Sept) = MixolidiaB13
escalaDelAcorde (V7 III, Sept) = MixolidiaB9B13AU9
escalaDelAcorde (V7 IV, Sept) = Mixolidia
escalaDelAcorde (V7 V, Sept) = Mixolidia
escalaDelAcorde (V7 VI, Sept) = MixolidiaB9B13AU9
--el septimo grado no tendra nunca dominante secundario
escalaDelAcorde (V7 (V7 _), Sept) = Mixolidia --dominantes por extension
escalaDelAcorde (V7 (IIM7 _), Sept) = Mixolidia --dominantes por extension
escalaDelAcorde (IIM7 _, Men7) = Dorica

{-
Para un acorde especificado con un elemento de tipo cifrado da esa informacion,
en el contexto del modo mayor
infoAcordeMayor cifrado = (tensiones, grados_de_su_escala, notas_a_evitar)
-}
infoAcordeMayor :: Cifrado -> InfoEscala
infoAcordeMayor = dameInfoEscala . escalaDelAcorde

{-
Indica cuales son las octavas apropiadas para cada instrumento. Ser�n octavas consecutivas, claro
-}
type Registro = [Octave]
{-
Registro en el que debe encuadrarse cualquier composicion para ser audible (que se escuchen todas las notas, no demasiado aguda, es decir,
no despu�s de la octava 10), correcta (que haskore genere el midi sin fallos, es decir, sin octavas negativas) y agradable (que no suene
chillona ni de ultratumba, es decir, sin la octava 0 ni la 10)
-}
registroGeneral :: Registro
registroGeneral = [1..9]
{-
Parte grave del registro general
-}
registroGrave :: Registro
registroGrave = [1..3]
{-
Parte media del registro general
-}
registroMedio :: Registro
registroMedio = [4..6]
{-
Parte aguda del registro general
-}
registroAgudo :: Registro
registroAgudo = [7..9]

{-
Registro en al que deber� ajustarse el instrumento que haga la melodia
-}
registroSolista :: Registro
registroSolista = union registroAgudo registroMedio

{-
Registro en al que deber� ajustarse el instrumento que haga de bajo
-}
registroDelBajo :: Registro
registroDelBajo = registroGrave

{-
pruRegistro dirTrabajo nota octavaInferior octavaSuperior
escribe un midi en la que se reproduce la nota especificada en los registros especificados
-}
pruRegistro :: String -> PitchClass-> Int -> Int -> IO()
pruRegistro dirTrabajo nota octavaInferior octavaSuperior = do setCurrentDirectory dirTrabajo
                                                               putStr (mensajeDirTrabajo dirTrabajo)
                                                               putStr mensaje
                                                               haskoreAMidi musica rutaDestinoMidi
                                                               putStr "\n Proceso terminado satisfactoriamente\n"
                                                               where mensajeDirTrabajo dir = "\n El directorio de trabajo es: " ++ dir ++ "\n"
                                                                     rutaDestinoMidi = "./pruRegistro"++(show nota)++".mid"
                                                                     prologo = "\n\tProbando el numero de octavas soportadas por haskore\n"
                                                                     argums = "\n\tGenerando lista de "++(show nota)++"�s desde la octava "++(show octavaInferior)++" hasta la octava "++(show octavaSuperior)++"\n"
                                                                     generandoMidi = "\n\tGenerando el archivo midi: " ++ rutaDestinoMidi ++ "\n"
                                                                     mensaje = prologo ++ argums ++ generandoMidi
                                                                     musica =  line (map (\o -> Note (nota,o) (1%2) []) [octavaInferior .. octavaSuperior])

{-
prueba para comprobar el numero de octavas que soporta el haskore antes de ser estridente
pruRegistro dirTrabajo nota octavaInferior octavaSuperior
CONCLUSIONES:
    -solo se admiten octavas mayores o iguales a 0
    -las octavas por encima del 10 son inaudibles, y el 10 es desagradable
    -la octava 0 es de ultratumba
    -Por tanto: registro = [1..9]
                registroGrave = [1..3]
                registroMedio = [4..6]
                registroAgudo = [7..9]
-}
{-
escribe tres midis en los que se muestran los registros grave, medio y agudo de la nota especificada
-}
muestraRegistros :: String -> PitchClass -> IO()
muestraRegistros dirTrabajo nota = do setCurrentDirectory dirTrabajo
                                      putStr (mensajeDirTrabajo dirTrabajo)
                                      putStr mensaje
                                      haskoreAMidi musicaGrave rutaDestinoMidiGrave
                                      haskoreAMidi musicaMedia rutaDestinoMidiMedio
                                      haskoreAMidi musicaAguda rutaDestinoMidiAgudo
                                      putStr "\n Proceso terminado satisfactoriamente\n"
                                      where mensajeDirTrabajo dir = "\n El directorio de trabajo es: " ++ dir ++ "\n"
                                            rutaDestinoMidiGrave = "./pruRegistroGrave"++(show nota)++".mid"
                                            rutaDestinoMidiMedio = "./pruRegistroMedio"++(show nota)++".mid"
                                            rutaDestinoMidiAgudo = "./pruRegistroAgudo"++(show nota)++".mid"
                                            prologo = "\n\tMostrando los registros grave, medio y agudo como archivos midi\n"
                                            argums = "\n\tNota elegida "++(show nota)++"\n"
                                            generandoMidiGrave = "\n\t\t" ++ rutaDestinoMidiGrave ++ "\n"
                                            generandoMidiMedio = "\n\t\t" ++ rutaDestinoMidiMedio ++ "\n"
                                            generandoMidiAgudo = "\n\t\t" ++ rutaDestinoMidiAgudo ++ "\n"
                                            generandoMidi = "\n\tGenerando los archivo midi: \n" ++ generandoMidiGrave ++ generandoMidiMedio ++ generandoMidiAgudo
                                            mensaje = prologo ++ argums ++ generandoMidi
                                            musicaGrave =  line (map (\o -> Note (nota,o) (1%2) []) registroGrave)
                                            musicaMedia =  line (map (\o -> Note (nota,o) (1%2) []) registroMedio)
                                            musicaAguda =  line (map (\o -> Note (nota,o) (1%2) []) registroAgudo)
