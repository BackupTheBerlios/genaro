
module ArmonizaMelodia where

import Haskore
import Progresiones
import TraduceCifrados ( traduceCifrado )
import Ratio
import Random
import BiblioGenaro ( elementoAleatorio )
import List


type Melodia = [ HaskoreSimple ]

data HaskoreSimple = Nota Pitch Dur
                   | Silencio Dur
     deriving(Eq, Ord, Show, Read)

type NotaPrincipal = (PitchClass, Dur)

type DurMin = Dur   -- Todas las notas mayores o iguales a esa duracion se consideran como notas principales
type DurMaxA = Dur  -- Los acordes que produce tienen como duracion maxima DUrMaxA


------------------------------ FUNCIONES COMUNES ----------------------------

{-
Dado un tipo Music secuencia devuelve una lista de notas y silencios
-}
deHaskoreSecuencialAMelodia :: Music -> Melodia
deHaskoreSecuencialAMelodia (Note p d _) = [ Nota p d ]
deHaskoreSecuencialAMelodia (Rest d)     = [ Silencio d ]
deHaskoreSecuencialAMelodia (m1:+:m2)    = deHaskoreSecuencialAMelodia m1 ++ deHaskoreSecuencialAMelodia m2
deHaskoreSecuencialAMelodia _            = error "No es un Music solo secuencial"

{-
Acordes cuatriadas diatonicos de la escala
-}
acordesDiatonicosCuatriadas :: [Cifrado]               
acordesDiatonicosCuatriadas = [ (I,   Maj7),
                                (II,  Men7), 
                                (III, Men7), 
                                (IV,  Maj7), 
                                (V,   Sept), 
                                (VI,  Men7), 
                                (VII, Men7B5) ]

{-
Acordes triadas diatonicos de la escala
-}
acordesDiatonicosTriadas :: [Cifrado]                    
acordesDiatonicosTriadas = [ (I,   Mayor), 
                             (II,  Menor), 
                             (III, Menor), 
                             (IV,  Mayor), 
                             (V,   Mayor), 
                             (VI,  Menor), 
                             (VII, Dis  ) ]

{-
Dominantes secundarios de la escala. NOTA: el quinto grado del primero es un acorde diatonico y no se si ponerlo
-}
acordesDominantesSecundarios :: [Cifrado]                    
acordesDominantesSecundarios = [ (V7 II,  Sept), 
                                 (V7 III, Sept), 
                                 (V7 IV,  Sept), 
                                 (V7 V,   Sept), 
                                 (V7 VI,  Sept), 
                                 (V7 VII, Sept) ]

{-
Segundos relativos de los dominantes secundarios. NOTA: HAY ALGUNOS QUE SON DE LA TONALIDAD
-}
acordesSegundosRelativos :: [Cifrado]                    
acordesSegundosRelativos = [ (IIM7 (V7 I),   Men7),
                             (IIM7 (V7 II),  Men7), 
                             (IIM7 (V7 III), Men7), 
                             (IIM7 (V7 IV),  Men7), 
                             (IIM7 (V7 V),   Men7), 
                             (IIM7 (V7 VI),  Men7), 
                             (IIM7 (V7 VII), Men7) ]


{-
Union de los acordes cuatriadas y triadas diatonicos
-}
acordesDiatonicos :: [Cifrado]
acordesDiatonicos = acordesDiatonicosTriadas ++ acordesDiatonicosCuatriadas

{-
Todos los acordes cromaticos
-}
acordesCromaticos :: [Cifrado]
acordesCromaticos = acordesDominantesSecundarios ++ acordesDominantesSecundarios 

{-
Armoniza una lista de notas principales por separado
-}
armonizaNotasPrincipales :: RandomGen g => g -> [NotaPrincipal] -> Progresion
armonizaNotasPrincipales gen [] = []
armonizaNotasPrincipales gen (notaP : resto) = cifradoYDur : armonizaNotasPrincipales sigGen resto
           where (cifradoYDur, sigGen) = armonizaNotaPrincipal gen notaP

{-
Para cada nota principal busca todos los cifrados diatonicos que contengan a esa nota.
Luego elije uno al azar
-}
armonizaNotaPrincipal :: RandomGen g => g -> NotaPrincipal -> ((Cifrado, Dur), g)
armonizaNotaPrincipal gen (notaP, dur) = ((cifradoAleatorio, dur), sigGen)
           where cifradosCandidatos = buscaCifradosCandidatosDeCMayor notaP
                 (cifradoAleatorio , sigGen )= elementoAleatorio gen cifradosCandidatos 


{-
Busca todos los cifrados que posean a ese PitchClass de la lista dada
-}
buscaCifradosCandidatosDeCMayor :: PitchClass -> [Cifrado]
buscaCifradosCandidatosDeCMayor pc
      | elem pc [C,D,E,F,G,A,B] = buscaCifradosCandidatos pc acordesDiatonicos 
      | otherwise               = buscaCifradosCandidatos pc acordesCromaticos

buscaCifradosCandidatos :: PitchClass -> [Cifrado] -> [Cifrado]
buscaCifradosCandidatos notaP cifrados = filter (esCandidato notaP) cifrados


-- Lo traducimos a numeros module 12 para que no haya problemas con sostenidos y bemoles
-- Si no lo hacemos no seria lo mismo Cs que Df, cosa que si que queremos que sea
{-
Un sifrado es candidato si contiene a ese PitchClass
-}
esCandidato :: PitchClass -> Cifrado -> Bool
esCandidato notaP cifrado = numNotaP `elem` listaNumCifrado
         where numNotaP = (pitchClass notaP) `mod` 12 ;
               listaNumCifrado = map ((`mod` 12).pitchClass) (traduceCifrado cifrado) 


-----------------------------------------------------------------------------


----------------------------- PRIMERA FORMA DE HACERLO ----------------------
-- Solo armonizamos las notas de larga duracion

{-
Funcion principal de este modulo.
Dada un tipo Music secuencia devuelve una progresion que es una armonizacion de ese Music
CUIDADO: si la melodia no contiene notas principales devuelve lista vacia
-}
armonizaMelodia1 :: RandomGen g => g -> DurMin -> Music -> Progresion
armonizaMelodia1 gen durMin m = progresion
        where melodia = deHaskoreSecuencialAMelodia m;
              notasPrinc = deMelodiaANotasPrincipales1 durMin melodia;
              progresion = armonizaNotasPrincipales gen notasPrinc


{-
pasa de una melodia a sus notas principales. Consideramos notas principales aquellas que poseen una duracion mayor
o igual a la duracion 'DurMin' pasada como parametro. La duracion de las notas secundarias y los silencios se pasa
a la nota principal mas cercana a su izquierda. En caso de que no la hubiera (porque pueda ser el principio de la otra 
como, por ejemplo, que empiece en silencio) pasaria a la nota de la derecha. De esa forma la duracion de la progresion
es la misma que la de la melodia
-}
deMelodiaANotasPrincipales1 :: DurMin -> Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales1 durMin melodia = reverse (drop 1 (deMelodiaANotasPrincipales1Rec durMin (C,0%1) (0%1) (reverse melodia) ))


-- PROBLEMA CUANDO LA MELODIA EMPIEZA EN SILENCIO -> ya ta solucionado
-- Dur ->  tercer parametro. duracion acumulada de todas las notas secundarias vistas desde la ultima principal. Es decir
--  todas las notas secundarias que hay entre dos notas principales (mas bien entre la ultima principal y la actual)
-- NotaPrincipal -> segundo parametro. ultima nota principal tratada. Eso arregla el problema de una melodia que empieza
--  con silencio o con una nota secundaria
deMelodiaANotasPrincipales1Rec :: DurMin -> NotaPrincipal -> Dur -> Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales1Rec durMin (pc, d) durAcumulada [] = [ (pc, d + durAcumulada) ]
deMelodiaANotasPrincipales1Rec durMin ultNotaP durAcumulada ( (Silencio d) : resto ) = deMelodiaANotasPrincipales1Rec durMin ultNotaP (durAcumulada + d) resto
deMelodiaANotasPrincipales1Rec durMin ultNotaP durAcumulada ( (Nota (pc, o) d) : resto ) 
       | d >= durMin  =  ultNotaP : deMelodiaANotasPrincipales1Rec durMin (pc, d + durAcumulada) (0%1) resto
       | d <  durMin  =  deMelodiaANotasPrincipales1Rec durMin ultNotaP (d + durAcumulada) resto



---------------------- OTRA FORMA DE SACAR NOTAS PRINCIPALES -----------------------------

-- Bool indica si la nota es principal o no
deMelodiaANotasPrincipales3 :: DurMin -> Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales3 durMin melodia = reverse (drop 1 (deMelodiaANotasPrincipales3Rec durMin (C,0%1) (0%1) (reverse (catalogaNotasPrincipales3 durMin melodia)) ))


-- NOTA: MIRAR EN ENCAJE DE PATRONES DE LOS CASOS
{-
Dada una melodia en forma de notas y silencios pone una etiqueta a cada nota indicando si hay que considerarla 
como principal o no
-}
catalogaNotasPrincipales3 :: DurMin -> Melodia -> [(HaskoreSimple, Bool)]
catalogaNotasPrincipales3 _ [] = []

catalogaNotasPrincipales3 durMin (Nota (pc, o) d : resto )     -- Si es una nota de larga duracion
       | d >= durMin = ( Nota (pc, o) d, True ) : catalogaNotasPrincipales3 durMin resto

catalogaNotasPrincipales3 durMin (Nota (pc, o) d1 : Silencio d2 : resto)  -- Una nota seguida de un silencio de al menos su valor
       | d2 >= d1  = ( Nota (pc, o) d1, True ) : ( Silencio d2 , False) : catalogaNotasPrincipales3 durMin resto
--     | otherwise = ( Nota (pc, o) d1, False ) : ( Silencio d2 , False) : catalogaNotasPrincipales3 durMin resto

catalogaNotasPrincipales3 durMin (Nota (pc1, o1) d1 : Nota (pc2, o2) d2 : resto)  -- Una nota seguida otra con un salto. Suponemos salto una distancia de mas estricto de un tono
       | abs (pitchClass pc1 - pitchClass pc2) > 2 = ( Nota (pc1, o1) d1, True ) : catalogaNotasPrincipales3 durMin (Nota (pc2, o2) d2 : resto)
--     | otherwise = ( Nota (pc1, o1) d1, False ) : catalogaNotasPrincipales3 durMin (Nota (pc2, o2) d2 : resto)

-- falta poner: nota corta que resuleve en su inmediata inferior de tiempo fuerte a debil

catalogaNotasPrincipales3 durMin (Nota (pc, o) d : resto ) = (Nota (pc, o) d , False) : catalogaNotasPrincipales3 durMin resto   -- si es cualquier otra nota

catalogaNotasPrincipales3 durMin (Silencio d : resto) = (Silencio d, False) : catalogaNotasPrincipales3 durMin resto  -- Al llegar aqui creo que no falta ningun caso





{-
Se retrasaba la colocacion del elemento que sabemos que va ahi. Eso es solo para el caso en que comience con nota secundaria
o silencio
-}
deMelodiaANotasPrincipales3Rec :: DurMin -> NotaPrincipal -> Dur -> [(HaskoreSimple, Bool)] -> [NotaPrincipal]
deMelodiaANotasPrincipales3Rec durMin (pc, d) durAcumulada [] = [ (pc, d + durAcumulada) ]
deMelodiaANotasPrincipales3Rec durMin ultNotaP durAcumulada ( (Silencio d, _) : resto ) = deMelodiaANotasPrincipales3Rec durMin ultNotaP (durAcumulada + d) resto
deMelodiaANotasPrincipales3Rec durMin ultNotaP durAcumulada ( (Nota (pc, o) d, b) : resto ) 
       | b == True  =  ultNotaP : deMelodiaANotasPrincipales3Rec durMin (pc, d + durAcumulada) (0%1) resto
       | b == False =  deMelodiaANotasPrincipales3Rec durMin ultNotaP (d + durAcumulada) resto


type Resolucion = Int -- resolucion , es decir, duracion de la nota que consideremos (4 es negra, 2 blanca, etc.)

-- Dur indica la duracion de todas las notas anteriores incluida la actual.
-- Si el numerador es 1 entonces es tiempo fuerte
{-
esTiempoFuerte :: Dur -> Resolucion -> Bool
esTiempoFuerte du r = even m
       where (n, d) = ( numerator du, denominator du);
             m = n * (r / d)
-}

esTiempoFuerte :: Dur -> Resolucion -> (Int, Int)
esTiempoFuerte du r = (newN , newD)
       where (n, d) = ( numerator du, denominator du);
             newN = n * (div r d);
             newD = r



type CifradosCandidatos = [Cifrado]
type DurAcordeAcumulado = Dur

{-
Armoniza una lista de notas principales por el metodo 3
-}
armonizaNotasPrincipales3 :: RandomGen g => g -> DurMaxA -> [NotaPrincipal] -> Progresion
armonizaNotasPrincipales3 gen durMaxA [] = []
armonizaNotasPrincipales3 gen durMaxA ( (pc, d) : resto)
        | d == durMaxA  =  (cifradoAleatorio, d ) : armonizaNotasPrincipales3 newGen durMaxA resto   -- Correcto
        | d >  durMaxA  =  (cifradoAleatorio, durMaxA ) : armonizaNotasPrincipales3 newGen durMaxA ( (pc, d - durMaxA) : resto)   --Suponemos que la nota pertenece a varios acordes  CORRECTO
        | d <  durMaxA  =  armonizaNotasPrincipales3' gen durMaxA cifradosCandidatos d resto  -- CORRECTO
        where cifradosCandidatos = buscaCifradosCandidatosDeCMayor pc;
              (cifradoAleatorio, newGen) = elementoAleatorio gen cifradosCandidatos 


-- Igual que la funcion anterior pero llevamos anclado una lista de acordes candidatos y su duracion
-- NOTA: EL CASO DE newCifCan /= []  ES EL MISMO PARA TODOS PERO POR SIMPLICIDAD LO ESCRIBO A PARTE
armonizaNotasPrincipales3' :: RandomGen g => g -> DurMaxA -> CifradosCandidatos -> DurAcordeAcumulado -> [NotaPrincipal] -> Progresion

armonizaNotasPrincipales3' gen durMaxA cifCan durA [] = [(cifAlea, durA)]  -- CORRECTO
        where (cifAlea, newGen) = elementoAleatorio gen cifCan 

armonizaNotasPrincipales3' gen durMaxA cifCan durA ( (pc, d) : resto) 
        | durA == durMaxA                        = (cifAlea , durMaxA) : armonizaNotasPrincipales3 newGen durMaxA ( (pc, d) : resto )  -- CORRECTO
        | durA + d == durMaxA && newCifCan /= [] = ( newCifAlea , d + durA) : armonizaNotasPrincipales3 newGen2 durMaxA resto          -- CORRECTO
        | durA + d == durMaxA && newCifCan == [] = ( cifAlea , durA) : armonizaNotasPrincipales3 newGen durMaxA ( (pc, d) : resto)     -- CORRECTO
        | durA + d <  durMaxA && newCifCan /= [] = armonizaNotasPrincipales3' gen durMaxA newCifCan (durA + d) resto                   -- CORRECTO
        | durA + d <  durMaxA && newCifCan == [] = ( cifAlea , durA) : armonizaNotasPrincipales3 newGen durMaxA ( (pc, d) : resto)     -- CORRECTO
        | durA + d >  durMaxA && newCifCan /= [] = ( newCifAlea , durMaxA) : armonizaNotasPrincipales3 newGen2 durMaxA ( (pc, d - durMaxA + durA) : resto) -- CORRECTO , pasamos el cacho de la nota que no cabe al siguiente acorde
        | durA + d >  durMaxA && newCifCan == [] = ( cifAlea , durA) : armonizaNotasPrincipales3 newGen durMaxA ( (pc, d) : resto)     -- CORRECTO
        where newCifCan = eliminaCifradosNoValidos cifCan (buscaCifradosCandidatosDeCMayor pc);
              (cifAlea, newGen) = elementoAleatorio gen cifCan;
              (newCifAlea, newGen2) = elementoAleatorio gen newCifCan;



eliminaCifradosNoValidos :: [Cifrado] -> [Cifrado] -> [Cifrado]
eliminaCifradosNoValidos = intersect

{-
es tiempo fuerte en compas binario. El parametro Dur es el tiempo del compas que se quiere evaluar. Incluye tanto
la duracion de las canciones anteriores como la duracion del tiempo actual
-}
--esTiempoFuerte :: (Int, Int) -> Bool
--esTiempoFuerte (a,b) = odd a


armonizaMelodia3 :: RandomGen g => g -> DurMin -> DurMaxA -> Music -> Progresion
armonizaMelodia3 gen durMin durMaxA m = progresion
        where melodia = deHaskoreSecuencialAMelodia m;
              notasPrinc = deMelodiaANotasPrincipales3 durMin melodia;
              progresion = armonizaNotasPrincipales3 gen durMaxA notasPrinc


----- PRUEBAS ----------


melodiaEj :: Music
melodiaEj  = Note (C,5) (3%8) [] :+:
             Note (D,5) (1%8) [] :+:
             Note (E,5) (3%8) [] :+:
             Note (D,5) (1%16) [] :+:
             Note (C,5) (1%16) [] :+:
             Note (G,5) (1%2) [] :+:
             Note (F,5) (1%2) [] :+:
             Note (C,5) (3%8) [] :+:
             Note (D,5) (1%8) [] :+:
             Note (E,5) (3%8) [] :+:
             Note (D,5) (1%16) [] :+:
             Note (C,5) (1%16) [] :+:
             Note (G,5) (1%2) [] :+:
             Note (C,5) (1%2) []


--melodiaEj2 :: Music
--melodiaEj2 = Note (C,5) (1%1) []


notasPrinc :: [NotaPrincipal]
notasPrinc = deMelodiaANotasPrincipales3 (1%8) (deHaskoreSecuencialAMelodia melodiaBach)

notasPrinc2 :: [(HaskoreSimple, Bool)]
notasPrinc2 = catalogaNotasPrincipales3 (1%8) (deHaskoreSecuencialAMelodia melodiaBach)


progresionEj :: Progresion
progresionEj = armonizaNotasPrincipales3 (mkStdGen 10) (3%8) notasPrinc



melodiaBach :: Music
melodiaBach = Rest (1%8) :+:
              Note (C,5) (1%8) [] :+:
              Note (D,5) (1%8) [] :+:
              Note (E,5) (1%8) [] :+:
              Note (G,5) (1%8) [] :+:
              Note (F,5) (1%8) [] :+:
              Note (F,5) (1%8) [] :+:
              Note (A,5) (1%8) [] :+:
              Note (G,5) (1%8) [] :+:
              Note (G,5) (1%8) [] :+:
              Note (C,6) (1%8) [] :+:
              Note (B,5) (1%8) [] :+:
              Note (C,6) (1%8) [] :+:
              Note (G,5) (1%8) [] :+:
              Note (E,5) (1%8) [] :+:
              Note (C,5) (1%8) [] :+:
              Note (D,5) (1%8) [] :+:
              Note (E,5) (1%8) [] :+:
              Note (F,5) (1%8) [] :+:
              Note (G,5) (1%8) [] :+:
              Note (A,5) (1%8) [] :+:
              Note (G,5) (1%8) [] :+:
              Note (F,5) (1%8) [] :+:
              Note (E,5) (1%8) [] :+:
              Note (D,5) (1%8) [] :+:
              Note (E,5) (1%8) [] :+:
              Note (D,5) (1%8) [] :+:
              Note (C,5) (1%8) [] :+:
              Note (D,5) (1%8) [] :+:
              Note (E,5) (1%8) [] :+:
              Note (G,4) (1%8) [] :+:
              Note (B,4) (1%8) [] :+:
              Note (D,5) (1%8) [] :+:
              Note (F,5) (1%8) [] :+:
              Note (E,5) (1%8) [] :+:
              Note (D,5) (1%8) [] :+:
              Note (E,5) (1%8) []















