module Escalas where
import Progresiones

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
Do, luego ya se puede trasponer el tono fácilmente con la constructora Trans del tipo Music
-}
type Escala = [Grado]
jonica :: Escala
jonica = [I,II,III,IV,V,VI,VII]
dorica :: Escala
dorica = [I,II,BIII,IV,V,VI,BVII]
frigia :: Escala
frigia = [I,BII,BIII,IV,V,BVI,BVII]
lidia :: Escala
lidia = [I,II,III,AUIV,V,VI,VII]
mixolidia :: Escala
mixolidia = [I,II,III,IV,V,VI,BVII]
eolia :: Escala
eolia = [I,II,BIII,IV,V,BVI,BVII]
locria :: Escala
locria = [I,BII,BIII,IV,BV,BVI,BVII]
{-
Para un acorde especificado con un elemento de tipo cifrado da esa informacion,
en el contexto del modo mayor
infoAcordeMayor cifrado = (tensiones, escala_del_momento, notas_a_evitar)
-}
infoAcordeMayor :: Cifrado -> ([Grado] ,Escala, [Grado])
infoAcordeMayor (I, Maj7) = ([IX,XIII],jonica,[IV])
infoAcordeMayor (II, Men7) = ([IX,XI],dorica,[VI])
infoAcordeMayor (III, Men7) = ([XI],frigia,[BII,BVI])
infoAcordeMayor (IV, Maj7) = ([IX,AUXI,XIII],lidia,[])
infoAcordeMayor (V, Sept) = ([IX,XIII],mixolidia,[IV])
infoAcordeMayor (VI, Men7) = ([IX,XI],eolia,[BVI])
infoAcordeMayor (VII, Men7B5) = ([XI,BXIII],locria,[BII])
