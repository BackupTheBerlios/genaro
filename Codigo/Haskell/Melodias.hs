module Melodias where
import Basics
import Progresiones
import Escalas
import PrologAHaskell --para pruebas


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
hazMelodiaParaAcorde :: Cifrado -> Music
hazMelodiaParaAcorde = line . hazMelodiaParaAcordeLista

hazMelodiaParaAcordeLista :: Cifrado -> [Music]
hazMelodiaParaAcordeLista _ = [Rest 0]

{-
saltaIntervalo escala num gradoPartida, devuelve el grado correspondiente a saltar en la escala indicada
tantos grados como num, contando desde gradoPartida. Por ejemplo saltaIntervalo jonica 2 I devuelve II
-}
saltaIntervalo :: Escala -> Int -> Grado -> Grado
saltaIntervalo

