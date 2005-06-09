module Escalas where
import Progresiones
import Basics
import BiblioGenaro
import List
import Maybe
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
data Escala = Jonica|Dorica|Frigia|Lidia|Mixolidia|Eolia|Locria|MixolidiaB13|MixolidiaB9B13AU9|Disminuida
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
dameInfoEscala Disminuida = ([], [I,BII,BIII,III,BV,AUV,VI,VII], [BII]) --Comprobar!!!

{-
Dada una escala devuelve la lista de saltos de semitonos entre cada grado de la escala y el que le sigue
, empezando por el primer grado. Es decir, devuelve su estructura intervalica como dice Enric Herrera
-}
escalaAListaSaltos :: Escala -> [Int]
escalaAListaSaltos escala = resul
              where (_,listaGradosEscala,_)  = dameInfoEscala escala
                    listaAbsGrados = map gradoAInt listaGradosEscala
                    dameSaltosRec (n1:(n2:ns)) = (n2-n1):(dameSaltosRec (n2:ns))
                    dameSaltosRec (n1:[])    = [12 - n1] -- pq se supone que son todos grados simples (no salen de la octava)
                                                       -- y tras este ultimo grado de la escala salta a la octava, que es 12 semitonos
                    resul = dameSaltosRec listaAbsGrados

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
dameDistanciaEnEscala escala tonica pitchClassAbajo pitchClassArriba
 -devuelve el numero de grados de distancia entre los dos pitchClass en la escala. No tiene pq ser
diatonicos ninguno, pero si debe ocurrir q el pitchClass primero sea mas grave o igual
q el pitchClass segundo
  -ejemplos:
    .dameDistanciaEnEscala Jonica C C, C = 0
    .dameDistanciaEnEscala Jonica C C, C = 0
    .dameDistanciaEnEscala Jonica C C, D = 1
    .dameDistanciaEnEscala Jonica C C, D = 1
    .dameDistanciaEnEscala Jonica C Cs D = 1
    .dameDistanciaEnEscala Jonica C Cs E = 2
    .dameDistanciaEnEscala Jonica C Cs Gs = 5 (1 de Cs a D, 3 de D a G y 1 de G a Gs)
    DEPRECATED, COMO DICEN LOS DE JAVA, USAR dameDistanciaEnEscalaPitch
-}
dameDistanciaEnEscala :: Escala -> PitchClass -> PitchClass -> PitchClass -> Int
dameDistanciaEnEscala escala tonica pc1 pc2
  | absPitchAbajo == absPitchArriba = 0
  | otherwise  = distancia
      where pitchAbajo = (pc1, 0)
            pitchArriba = (pc2, 0)
            absPitchAbajo = (absPitch pitchAbajo)
            absPitchArriba = (absPitch pitchArriba)
            gradoAbajoIni = dameIntervaloPitch tonica pitchAbajo
            gradoArribaIni = dameIntervaloPitch tonica pitchArriba
            gradoAbajoCorregido = dameGradoDiatonicoCercano True escala gradoAbajoIni
            gradoArribaCorregido = dameGradoDiatonicoCercano False escala gradoArribaIni
            correccionAbajo = if (gradoAbajoIni == gradoAbajoCorregido) then 0 else 1
            correccionArriba = if (gradoArribaIni == gradoArribaCorregido) then 0 else 1
            (_,gradosEscala,_)  = dameInfoEscala escala
            posGradoAbajo = fromJust (elemIndex gradoAbajoCorregido gradosEscala)
            listaGradosDesdeAbajo = drop posGradoAbajo (concat (repeat gradosEscala))
            listaGradosDesdeAbajoYArriba = takeWhile (/=gradoArribaCorregido) listaGradosDesdeAbajo
            distancia = correccionAbajo + correccionArriba + (length listaGradosDesdeAbajoYArriba)

{-
dameDistanciaEnEscalaPitch escala tonica pitchAbajo pitchArriba
 -devuelve el numero de grados de distancia entre los dos pitch en la escala. No tiene pq ser
diatonicos ninguno, ni pq ser uno mas grave que el otro!!!!
  -ejemplos:
    .dameDistanciaEnEscala Jonica C (C,0) (C,0) = 0
    .dameDistanciaEnEscala Jonica C (C,0) (C,2) = 0
    .dameDistanciaEnEscala Jonica C (C,0) (D,0) = 1
    .dameDistanciaEnEscala Jonica C (C,0) (D,1) = 1
    .dameDistanciaEnEscala Jonica C (Cs,0) (D,0) = 1
    .dameDistanciaEnEscala Jonica C (Cs,0) (E,0) = 2
    .dameDistanciaEnEscala Jonica C (Cs,0) (Gs,0) = 5 (1 de Cs a D, 3 de D a G y 1 de G a Gs)
    Escalas> dameDistanciaEnEscalaPitch Dorica D (Cs,0) (Cs,1)
    8
    Escalas> dameDistanciaEnEscalaPitch Dorica D (Cs,0) (Gs,1)
    12
    Escalas> dameDistanciaEnEscalaPitch Jonica C (B,0) (C,1)
    1
 -}

dameDistanciaEnEscalaPitch :: Escala -> PitchClass -> Pitch -> Pitch -> Int
-- LOS NOMBRES pitchAbajo/Arriba NO SON REPRESENTATIVOS
dameDistanciaEnEscalaPitch escala tonica pitchAbajo@(pcAb,oAb) pitchArriba@(pcArr,oArr)
  | absPitchAbajo == absPitchArriba = 0
  | absPitchAbajo < absPitchArriba = distanciaMenor
  | absPitchAbajo > absPitchArriba = distanciaMayor
      where absPitchAbajo = (absPitch pitchAbajo)
            absPitchArriba = (absPitch pitchArriba)
            numNotasDistancia notaOri notaDest
             | menor notaOri notaDest = 1 + sigDistancia
             | otherwise = 0
                where menor n1 n2 = (absPitch n1) < (absPitch n2)
                      sigNota = saltaIntervaloPitch escala tonica 1 notaOri
                      sigDistancia = numNotasDistancia sigNota notaDest
            distanciaMenor = numNotasDistancia pitchAbajo pitchArriba
            distanciaMayor = numNotasDistancia pitchArriba pitchAbajo

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
  | escala == Disminuida        = map (filtraNotasAEvitar notasAEvitar) (zip listaGrados (map pesoDisminuida [1..numGrados]))
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
                      -- dameInfoEscala MixolidiaB9B13AU9 = ([BIX,BXIII],[I,BII,AUII,III,IV,V,BVI,BVII],[IV])
                      -- dameInfoEscala Disminuida = ([], [I,BII,BIII,III,BV,AUV,VI,VII], [BII]) --Comprobar!!!<
                      pesoMixB9B13AU9 num
                        | num == 1             = peso7Notas 1
                        | (num==2) || (num==3) = peso7Notas 2
                        | num > 3              = peso7Notas (num-1)
                      pesoDisminuida num
                        | num < 2              = peso7Notas num
                        | (num==3) || (num==4) = peso7Notas 3
                        | num > 4              = peso7Notas (num-1)
                      filtraNotasAEvitar notasAEvitar (grado, peso)
                        | elem grado notasAEvitar = (grado, 10)
                        | otherwise = (grado, peso)


{-
valoraGrado :: Escala -> Grado -> Int
dado un grado y una escala devuelve un entero que indica la cantidad de estabilidad de ese grado en la escala
-}
valoraGrado :: Escala -> Grado -> Int
valoraGrado escala grado = resul
                where listaGradosPeso = dameNotasYPesosDeEscala escala
                      busca = find (\(g, val) -> (g == grado)) listaGradosPeso
                      resul = if (isJust busca)
                                 then (snd(fromJust busca))
                                 else 5 --tampoco hay q pasarse
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
escalaDelAcorde (_, Dis7) = Disminuida
escalaDelAcorde (BVII, Maj7) = Lidia

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
--registroSolista = union registroAgudo registroMedio
registroSolista = [5..8]

{-
Registro en al que deber� ajustarse el instrumento que haga de bajo
-}
registroDelBajo :: Registro
registroDelBajo = [2..4] -- es q no se oye bienregistroGrave

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


{-
Solo funciona con musics de tipo Note
-}
damePitch :: Music -> Pitch
damePitch (Note p _ _) = p

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
tantos grados como num, contando desde gradoPartida. HACE LO QUE INDICA dameGradoDiatonicoCercano PARA LOS CASOS
EN QUE SE PARTA DE UNA NOTA NO DIATÓNICA
- NO FUNCIONA BIEN PARA OCTAVAS NEGATIVAS PQ PITCH ES EXTRAÑA:
    Melodias> zip (map pitch [-20..20]) [-20..20]
[((E,-1),-20),((F,-1),-19),((Fs,-1),-18),((G,-1),-17),((Gs,-1),-16),((A,-1),-15),((As,-1),-14),((B,-1),-13),
((C,-1),-12),((Cs,0),-11),((D,0),-10),((Ds,0),-9),((E,0),-8),((F,0),-7),((Fs,0),-6),((G,0),-5),((Gs,0),-4),
((A,0),-3),((As,0),-2),((B,0),-1),((C,0),0),((Cs,0),1),((D,0),2),((Ds,0),3),((E,0),4),((F,0),5),((Fs,0),6),
((G,0),7),((Gs,0),8),((A,0),9),((As,0),10),((B,0),11),((C,1),12),((Cs,1),13),((D,1),14),((Ds,1),15),((E,1),16),
((F,1),17),((Fs,1),18),((G,1),19),((Gs,1),20)]
, pero da igual pq evitamos trabajar con octavas negativas
-}
saltaIntervaloPitch :: Escala -> PitchClass -> Int -> Pitch -> Pitch
saltaIntervaloPitch escala tonica num notaPartida@(clase, oct)
 | num == 0  = notaPartida
 | otherwise = pitchResul
            where (_,gradosEscala,_)  = dameInfoEscala escala
                  gradoPartida        = dameIntervaloPitch tonica notaPartida
                  pitchResul = case (elem gradoPartida gradosEscala) of
                                      True  -> saltaIntervaloPitchDiatonico escala tonica num notaPartida  --salto desde grado diatonico
                                      False -> saltaIntervaloPitchDiatonico escala tonica numAux notaAux
                                                                  where buscaGradoDiatonicoCercano arriba nota
                                                                         | pertenece = nota
                                                                         | otherwise = buscaGradoDiatonicoCercano arriba sigNota
                                                                                  where grado = dameIntervaloPitch tonica nota
                                                                                        pertenece = elem grado gradosEscala
                                                                                        sigNota = if arriba
                                                                                                     then pitch ((absPitch nota) + 1)
                                                                                                     else pitch ((absPitch nota) - 1)
                                                                        notaAux = buscaGradoDiatonicoCercano (num>0) notaPartida
                                                                        numAux = if num>0
                                                                                    then num - 1
                                                                                    else num + 1


{-
Como saltaIntervaloPitch pero suponiendo que se parte de una nota diatonica
-}
saltaIntervaloPitchDiatonico :: Escala -> PitchClass -> Int -> Pitch -> Pitch
saltaIntervaloPitchDiatonico escala tonica num notaPartida@(clase, oct)
 | num == 0  = notaPartida
 | num>0     = notaDestinoSube
 | num<0     = notaDestinoBaja
         where (_,gradosEscala,_)   = dameInfoEscala escala
               numNotasEscala       = length gradosEscala
               gradoPartida         = dameIntervaloPitch tonica notaPartida
               listaSaltos          = escalaAListaSaltos escala
               posGradoPartidaSube  = fromJust (elemIndex gradoPartida gradosEscala)
               listaSaltosInfSube   = concat (repeat listaSaltos)
               listaSaltosIniAjSube = drop posGradoPartidaSube listaSaltosInfSube
               listaSaltosDefSube   = take num listaSaltosIniAjSube
               saltoSube            = foldl1' (+) listaSaltosDefSube
               notaDestinoSube      = pitch ((absPitch notaPartida) + saltoSube)
               posGradoPartidaBaja  = numNotasEscala - posGradoPartidaSube -- en realidad
               -- es (numNotasEscala - 1) - posGradoPartidaSube + 1, pq
               -- . (numNotasEscala - 1): con -1 pq elemIndex cuenta desde cero
               -- . - posGradoPartidaSube: al hacer esto situamos el mismo elemento en la lista dada la vuelta
               -- . +1 pq ahora miramos la distancia en la otra direccion, la de bajada, por eso cambia la orientacion
               listaSaltosInfBaja   = concat (repeat (reverse listaSaltos))
               listaSaltosIniAjBaja = drop posGradoPartidaBaja listaSaltosInfBaja
               listaSaltosDefBaja   = take (abs num) listaSaltosIniAjBaja
               saltoBaja            = foldl1' (+) listaSaltosDefBaja
               notaDestinoBaja      = pitch ((absPitch notaPartida) - saltoBaja)
