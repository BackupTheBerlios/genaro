module Escalas where
import Progresiones
import Basics

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

