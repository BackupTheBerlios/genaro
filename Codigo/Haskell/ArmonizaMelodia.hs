
module ArmonizaMelodia where

import Haskore
import Progresiones
import TraduceCifrados ( traduceCifrado )
import Ratio
import Random
import BiblioGenaro ( elementoAleatorio )


type Melodia = [ HaskoreSimple ]

data HaskoreSimple = Nota Pitch Dur
                   | Silencio Dur

type NotaPrincipal = (PitchClass, Dur)

type DurMin = Dur   -- Todas las notas mayores o iguales a esa duracion se consideran como notas principales


deHaskoreSecuencialAMelodia :: Music -> Melodia
deHaskoreSecuencialAMelodia (Note p d _) = [ Nota p d ]
deHaskoreSecuencialAMelodia (Rest d)     = [ Silencio d ]
deHaskoreSecuencialAMelodia (m1:+:m2)    = deHaskoreSecuencialAMelodia m1 ++ deHaskoreSecuencialAMelodia m2
deHaskoreSecuencialAMelodia _            = error "No es un Music solo secuencial"


-- NOTA: MUY PROVISIONAL
deMelodiaANotasPrincipales :: Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales [] = []
deMelodiaANotasPrincipales ( (Nota (p, o) d) : resto ) = (p, d) : deMelodiaANotasPrincipales resto
deMelodiaANotasPrincipales ( _ : resto )               = deMelodiaANotasPrincipales resto


-- Sacar notas principales a partir de la duracion que el usuario pasa
deMelodiaANotasPrincipales2 :: DurMin -> Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales2 durMin melodia = reverse (drop 1 (deMelodiaANotasPrincipales2Rec durMin (C,0%1) (0%1) (reverse melodia) ))

-- PROBLEMA CUANDO LA MELODIA EMPIEZA EN SILENCIO
-- Dur ->  tercer parametro. duracion acumulada de todas las notas secundarias vistas desde la ultima principal. Es decir
--  todas las notas secundarias que hay entre dos notas principales (mas bien entre la ultima principal y la actual)
-- NotaPrincipal -> segundo parametro. ultima nota principal tratada. Eso arregla el problema de una melodia que empieza
--  con silencio o con una nota secundaria
{-
deMelodiaANotasPrincipales2Rec :: DurMin -> NotaPrincipal -> Dur -> Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales2Rec durMin ultNotaP durAcumulada [] = [(pc, d + durAcumulada)] -- La primera nota (ultima en la lista invertida) es siempre principal
deMelodiaANotasPrincipales2Rec durMin ultNotaP durAcumulada ( (Silencio d) : resto ) = deMelodiaANotasPrincipales2Rec durMin (durAcumulada + d) resto
deMelodiaANotasPrincipales2Rec durMin ultNotaP durAcumulada ( (Nota (pc, _) d) : resto ) 
       | d >= durMin  =  (pc, d + durAcumulada) : deMelodiaANotasPrincipales2Rec durMin (0%1) resto
       | d <  durMin  =  deMelodiaANotasPrincipales2Rec durMin (d + durAcumulada) resto
-}


deMelodiaANotasPrincipales2Rec :: DurMin -> NotaPrincipal -> Dur -> Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales2Rec durMin (pc, d) durAcumulada [] = [ (pc, d + durAcumulada) ]
deMelodiaANotasPrincipales2Rec durMin ultNotaP durAcumulada ( (Silencio d) : resto ) = deMelodiaANotasPrincipales2Rec durMin ultNotaP (durAcumulada + d) resto
deMelodiaANotasPrincipales2Rec durMin ultNotaP durAcumulada ( (Nota (pc, o) d) : resto ) 
       | d >= durMin  =  ultNotaP : deMelodiaANotasPrincipales2Rec durMin (pc, d + durAcumulada) (0%1) resto
       | d <  durMin  =  deMelodiaANotasPrincipales2Rec durMin ultNotaP (d + durAcumulada) resto


acordesDiatonicosCuatriadas :: [Cifrado]               -- REVISAR ESTO
acordesDiatonicosCuatriadas = [ (I,   Maj7),
                                (II,  Men7), 
                                (III, Men7), 
                                (IV,  Maj7), 
                                (V,   Sept), 
                                (VI,  Men7), 
                                (VII, Men7B5) ]


acordesDiatonicosTriadas :: [Cifrado]                    -- REVISAR ESTO
acordesDiatonicosTriadas = [ (I,   Mayor), 
                             (II,  Menor), 
                             (III, Menor), 
                             (IV,  Mayor), 
                             (V,   Mayor), 
                             (VI,  Menor), 
                             (VII, Dis  ) ]


acordesDiatonicos :: [Cifrado]
acordesDiatonicos = acordesDiatonicosTriadas ++ acordesDiatonicosCuatriadas


armonizaNotasPrincipales :: RandomGen g => g -> [NotaPrincipal] -> [(Cifrado, Dur)]
armonizaNotasPrincipales gen [] = []
armonizaNotasPrincipales gen (notaP : resto) = cifradoYDur : armonizaNotasPrincipales sigGen resto
           where (cifradoYDur, sigGen) = armonizaNotaPrincipal gen notaP

armonizaNotaPrincipal :: RandomGen g => g -> NotaPrincipal -> ((Cifrado, Dur), g)
armonizaNotaPrincipal gen (notaP, dur) = ((cifradoAleatorio, dur), sigGen)
           where cifradosCandidatos = buscaCifradosCandidatos notaP acordesDiatonicos
                 (cifradoAleatorio , sigGen )= elementoAleatorio gen cifradosCandidatos 



buscaCifradosCandidatos :: PitchClass -> [Cifrado] -> [Cifrado]
buscaCifradosCandidatos notaP cifrados = filter (esCandidato notaP) cifrados


-- Lo traducimos a numeros module 12 para que no haya problemas con sostenidos y bemoles
-- Si no lo hacemos no seria lo mismo Cs que Df, cosa que si que queremos que sea
esCandidato :: PitchClass -> Cifrado -> Bool
esCandidato notaP cifrado = numNotaP `elem` listaNumCifrado
         where numNotaP = (pitchClass notaP) `mod` 12 ;
               listaNumCifrado = map ((`mod` 12).pitchClass) (traduceCifrado cifrado) 


















