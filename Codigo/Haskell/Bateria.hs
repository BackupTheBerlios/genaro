module Bateria where

import Ix
import Haskore
import List
import TraduceCifrados
import Maybe
import PatronesRitmicos

data PercusionGenaro = Bombo | CajaFuerte | CajaSuave | CharlesPisado | CharlesAbierto
                       | CharlesCerrado | TimbalAgudo | TimbalGrave | Ride | Crash
     deriving (Show, Read, Eq, Ord, Enum, Ix)


bateriaGenaro :: [PercusionGenaro]
bateriaGenaro = [ toEnum i | i <- [0..9] ]  --NOTA: NO SE SI EMPEZAR EN 0 O EN 1


bateriaHaskore :: [PercussionSound]
bateriaHaskore = map de_PercusionGenaro_a_PercusionHaskore bateriaGenaro


-- ESPERO QUE ESTA FUNCION SEA CORRECTA
asociacionPercusion :: [(PercusionGenaro, PercussionSound)]
asociacionPercusion = [(Bombo, BassDrum1),
                       (CajaFuerte, LowMidTom ),
                       (CajaSuave, HiMidTom ),
                       (CharlesPisado, PedalHiHat ),
                       (CharlesAbierto, OpenHiHat ),
                       (CharlesCerrado, ClosedHiHat ),
                       (TimbalAgudo, LowTimbale ),
                       (TimbalGrave, HighTimbale ),
                       (Ride, RideCymbal1 ),
                       (Crash, CrashCymbal1 )]



de_PercusionGenaro_a_PercusionHaskore :: PercusionGenaro -> PercussionSound
de_PercusionGenaro_a_PercusionHaskore pg = ph
      where (lpg, lph) = unzip asociacionPercusion;
            Just ind = elemIndex pg lpg;
            ph = lph !! ind


de_PercusionHaskore_a_PercusionHaskore :: PercussionSound -> PercusionGenaro
de_PercusionHaskore_a_PercusionHaskore ph 
      | isJust quizas_ind    = lpg !! (fromJust quizas_ind)
      | isNothing quizas_ind = error ("de_persucionHaskore_a_PercusionHaskore " ++ show ph ++ ":No se puede traducir a PercusionGenaro")
      where (lpg, lph) = unzip asociacionPercusion;
            quizas_ind = elemIndex ph lph



acordeOrdenadoBateria :: Dur -> AcordeOrdenado
acordeOrdenadoBateria d = (map f bateriaHaskore,d)
       where f = pitch.(+35).fromEnum


acordeOrdenadoBateria' :: Dur -> [AcordeOrdenado]
acordeOrdenadoBateria' d = [acordeOrdenadoBateria d]


-- Los parametros de encaje no importan (si el patron ritmico es de bateria, claro) pero algo hay que poner
encajaBateria :: Dur -> PatronRitmico -> Music
encajaBateria d pr = deAcordesOrdenadosAMusica Ciclico (Truncar1, Truncar2) pr (acordeOrdenadoBateria' d)


-- EJEMPLO -----------

{-
bateriaMusic :: Music
bateriaMusic = Instr "Drums" (encajaBateria (2%1) patronR)

patronR :: PatronRitmico
patronR = (10,[([(1,100,False),(4,100,False),(10,100,False),(2,100,False)],1%8),
               ([(3,100,False)],1%8),
               ([(4,100,False),(2,100,False)],1%8),
               ([(3,100,False)],1%8),
               ([(4,100,False),(2,100,False)],1%8),
               ([(3,100,False)],1%8),
               ([(4,100,False),(2,100,False)],1%8),
               ([(3,100,False)],1%8),
               ([(1,100,False),(4,100,False),(9,100,False),(2,100,False)],1%8),
               ([(3,100,False)],1%8),
               ([(4,100,False),(2,100,False)],1%8),
               ([(3,100,False)],1%8),
               ([(4,100,False),(2,100,False)],1%8),
               ([(3,100,False)],1%8),
               ([(4,100,False),(2,100,False)],1%8),
               ([(3,100,False)],1%8)] )

-}