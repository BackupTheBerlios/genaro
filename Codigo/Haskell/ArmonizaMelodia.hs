
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
type DurMaxA = Dur  -- Los acordes que produce tienen como duracion maxima DurMaxA

------- OPCIONES DE ARMONIZACION ---------------

-- Todos los parametros juntos
type TipoArmonizacion = (ModoAcordes, TipoNotasPrincipales, TipoAsignaAcordes)


-- Los acordes que usa
data ModoAcordes = Triadas            -- Solo usa triadas para las notas diatonicas
                 | TriadasYCuatriadas -- Usa todos los acordes
     deriving (Eq, Ord, Enum, Show, Read)

-- Como encuentra las notas principales o notas del acorde
data TipoNotasPrincipales = SoloNotasLargas DurMin  -- Usa solamente las notas largas (mayores de DurMin) como notas principales
                          | MasRefinado DurMin      -- Es el metodo que usa Enric Herrera en la pagina 72
     deriving (Eq, Ord)

-- Como asigna los acordes a las notas principales
data TipoAsignaAcordes = UnoPorNotaPrinc         -- A cada nota principal le asigna un acorde
                       | MasLargoPosible DurMaxA -- Asigna acordes a series de notas tan largos como sea posible sin que exceda de DurMaxA

------------- FUNCIONES GENERALES --------------------------------

armonizaMusicSecuencial :: RandomGen g => g -> TipoArmonizacion -> Music -> Progresion
armonizaMusicSecuencial gen (ma, tnp, taa) music = progresion
         where melodia    = deHaskoreSecuencialAMelodia music;
               notasPrinc = deMelodiaANotasPrincipales tnp melodia;
               progresion = armonizaNotasPrincipales gen taa ma notasPrinc 


{-
Dado un tipo Music secuencia devuelve una lista de notas y silencios
-}
deHaskoreSecuencialAMelodia :: Music -> Melodia
deHaskoreSecuencialAMelodia (Note p d _) = [ Nota p d ]
deHaskoreSecuencialAMelodia (Rest d)     = [ Silencio d ]
deHaskoreSecuencialAMelodia (m1:+:m2)    = deHaskoreSecuencialAMelodia m1 ++ deHaskoreSecuencialAMelodia m2
deHaskoreSecuencialAMelodia _            = error "No es un Music solo secuencial"






------------- TODOS LOS CIFRADOS QUE VAMOS A USAR ----------------


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


------------ ENCONTRAR ACORDES CANDIDATOS -----------------


{-
Busca todos los cifrados que posean a ese PitchClass de la lista dada
-}
buscaCifradosCandidatosDeCMayor :: ModoAcordes -> PitchClass -> [Cifrado]
buscaCifradosCandidatosDeCMayor Triadas pc
      | elem pc [C,D,E,F,G,A,B] = buscaCifradosCandidatos pc acordesDiatonicosTriadas 
      | otherwise               = buscaCifradosCandidatos pc acordesCromaticos
buscaCifradosCandidatosDeCMayor TriadasYCuatriadas pc
      | elem pc [C,D,E,F,G,A,B] = buscaCifradosCandidatos pc acordesDiatonicos 
      | otherwise               = buscaCifradosCandidatos pc acordesCromaticos


{-
Dado una nota y una lista de acordes devuelve la lista de acordes que poseen una nota comun con dicha nota
-}
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


---------------- ELECCION DE NOTAS PRINCIPALES -----------------------

{-
Para evitar que no devuelva una lista de notas principales vacia hacemos un retoque para que
devuelva aunque solo sea una, que elegimos como la primera.
-}
deMelodiaANotasPrincipales :: TipoNotasPrincipales -> Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales (SoloNotasLargas durMin) melodia
       | notasP1 == []  = [primeraNota melodia]
       | otherwise      = notasP1
         where notasP1 = deMelodiaANotasPrincipales1 durMin melodia
deMelodiaANotasPrincipales (MasRefinado durMin) melodia 
       | notasP2 == []  = [primeraNota melodia]
       | otherwise      = notasP2
         where notasP2 = deMelodiaANotasPrincipales3 durMin melodia

primeraNota :: Melodia -> NotaPrincipal
primeraNota melodia = primeraNotaRec (0%1) melodia

primeraNotaRec :: Dur -> Melodia -> NotaPrincipal
primeraNotaRec d (Nota (pc, o) dn : resto) = (pc, d + dn + duracionMelodia resto) -- caso en que hemos encontrado la primera nota
primeraNotaRec d [] = (C,d)                                -- Caso en que no hay ninguna nota en la melodia por ser todos silencios o ser lista vacia
primeraNotaRec d (Silencio ds : resto) = primeraNotaRec (d + ds) resto -- caso en que nos saltamos el silencio

duracionMelodia :: Melodia -> Dur
duracionMelodia []                        = (0%1)
duracionMelodia (Nota (_ , _) dn : resto) = dn + duracionMelodia resto
duracionMelodia (Silencio ds : resto)     = ds + duracionMelodia resto


{-
Pasa de una melodia a sus notas principales. Consideramos notas principales aquellas que poseen una duracion mayor
o igual a la duracion 'DurMin' pasada como parametro. La duracion de las notas secundarias y los silencios se pasa
a la nota principal mas cercana a su izquierda. En caso de que no la hubiera (porque pueda ser el principio de la otra 
como, por ejemplo, que empiece en silencio) pasaria a la nota de la derecha. De esa forma la duracion de la progresion
es la misma que la de la melodia
-}
deMelodiaANotasPrincipales1 :: DurMin -> Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales1 durMin melodia = reverse (drop 1 (deMelodiaANotasPrincipales1Rec durMin (C,0%1) (0%1) (reverse melodia) ))


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



-- Bool indica si la nota es principal o no
deMelodiaANotasPrincipales3 :: DurMin -> Melodia -> [NotaPrincipal]
deMelodiaANotasPrincipales3 durMin melodia = reverse (drop 1 (deMelodiaANotasPrincipales3Rec durMin (C,0%1) (0%1) (reverse (catalogaNotasPrincipales3 (0%1) durMin melodia)) ))


type DurAnt = Dur -- duracion de todas las notas anteriores, es decir, duracion de la cancion anterior


{-
Dada una melodia en forma de notas y silencios pone una etiqueta a cada nota indicando si hay que considerarla 
como principal o no
-}
catalogaNotasPrincipales3 :: DurAnt -> DurMin -> Melodia -> [(HaskoreSimple, Bool)]
catalogaNotasPrincipales3 _ _ [] = []

catalogaNotasPrincipales3 durAnt durMin (Nota (pc, o) d : resto )     -- Si es una nota de larga duracion
       | d >= durMin = ( Nota (pc, o) d, True ) : catalogaNotasPrincipales3 (durAnt+d) durMin resto

catalogaNotasPrincipales3 durAnt durMin (Nota (pc, o) d1 : Silencio d2 : resto)  -- Una nota seguida de un silencio de al menos su valor
       | d2 >= d1  = ( Nota (pc, o) d1, True ) : ( Silencio d2 , False) : catalogaNotasPrincipales3 (durAnt+d1+d2) durMin resto

catalogaNotasPrincipales3 durAnt durMin (Nota (pc1, o1) d1 : Nota (pc2, o2) d2 : resto)  -- Una nota seguida otra con un salto. Suponemos salto una distancia de mas estricto de un tono
       | abs (pitchClass pc1 - pitchClass pc2) > 2 = ( Nota (pc1, o1) d1, True ) : catalogaNotasPrincipales3 (durAnt+d1) durMin (Nota (pc2, o2) d2 : resto)

catalogaNotasPrincipales3 durAnt durMin (Nota (pc1, o1) d1 : Nota (pc2, o2) d2 : resto)  -- nota corta que resuleve en su inmediata inferior de tiempo fuerte a debil
       | esTiempoFuerte (durAnt + d1) (denominator d1) && ((dist == 1) || (dist == 2)) = ( Nota (pc1, o1) d1, True ) : catalogaNotasPrincipales3 (durAnt+d1) durMin (Nota (pc2, o2) d2 : resto)
       where dist = (pitchClass pc1 - pitchClass pc2)

catalogaNotasPrincipales3 durAnt durMin (Nota (pc, o) d : resto ) = (Nota (pc, o) d , False) : catalogaNotasPrincipales3 (durAnt+d) durMin resto   -- si es cualquier otra nota

catalogaNotasPrincipales3 durAnt durMin (Silencio d : resto) = (Silencio d, False) : catalogaNotasPrincipales3 (durAnt+d) durMin resto  -- Al llegar aqui creo que no falta ningun caso



type Resolucion = Int -- resolucion , es decir, duracion de la nota que consideremos (4 es negra, 2 blanca, etc.)

{-
Dur indica la duracion de todas las notas anteriores incluida la actual.
Si el numerador es 1 entonces es tiempo fuerte
-}
esTiempoFuerte :: Dur -> Resolucion -> Bool
esTiempoFuerte du r = even num
       where (num, den) = cambiaResolucion du r


{-
Solo funciona cuando 'Dur' tiene como denominador una potencia de 2 y 'Resolucion' tambien, es decir, tal y como son
las notas en musica (ej: negra = 1/4).
'cambiaResolucion' devuele la fraccion pasada, que posiblemente este simplificada, en forma de pareja de enteros
de forma que el denominador es la 'Resolucion' y la fraccion devuelta es la misma que la fraccion pasada.
-}
cambiaResolucion :: Dur -> Resolucion -> (Int, Int)
cambiaResolucion du r = (newN , newD)
       where (n, d) = ( numerator du, denominator du);
             newN = n * (div r d);
             newD = r



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


---------------------- ARMONIZACION -----------------------------


{-
-}
armonizaNotasPrincipales :: RandomGen g => g -> TipoAsignaAcordes -> ModoAcordes -> [NotaPrincipal] -> Progresion
armonizaNotasPrincipales gen UnoPorNotaPrinc ma lnp           = armonizaNotasPrincipales1 gen ma lnp
armonizaNotasPrincipales gen (MasLargoPosible durMaxA) ma lnp = armonizaNotasPrincipales3 gen ma durMaxA lnp



{-
Armoniza una lista de notas principales por separado
-}
armonizaNotasPrincipales1 :: RandomGen g => g -> ModoAcordes -> [NotaPrincipal] -> Progresion
armonizaNotasPrincipales1 _   _  [] = []
armonizaNotasPrincipales1 gen ma (notaP : resto) = cifradoYDur : armonizaNotasPrincipales1 sigGen ma resto
           where (cifradoYDur, sigGen) = armonizaNotaPrincipal1 gen ma notaP

{-
Para cada nota principal busca todos los cifrados diatonicos que contengan a esa nota.
Luego elije uno al azar
-}
armonizaNotaPrincipal1 :: RandomGen g => g -> ModoAcordes -> NotaPrincipal -> ((Cifrado, Dur), g)
armonizaNotaPrincipal1 gen ma (notaP, dur) = ((cifradoAleatorio, dur), sigGen)
           where cifradosCandidatos = buscaCifradosCandidatosDeCMayor ma notaP
                 (cifradoAleatorio , sigGen )= elementoAleatorio gen cifradosCandidatos 




type CifradosCandidatos = [Cifrado]
type DurAcordeAcumulado = Dur

{-
Armoniza una lista de notas principales por el metodo 3
-}
armonizaNotasPrincipales3 :: RandomGen g => g -> ModoAcordes -> DurMaxA -> [NotaPrincipal] -> Progresion
armonizaNotasPrincipales3 _  _ durMaxA [] = []
armonizaNotasPrincipales3 gen ma durMaxA ( (pc, d) : resto)
        | d == durMaxA  =  (cifradoAleatorio, d ) : armonizaNotasPrincipales3 newGen ma durMaxA resto   -- Correcto
        | d >  durMaxA  =  (cifradoAleatorio, durMaxA ) : armonizaNotasPrincipales3 newGen ma durMaxA ( (pc, d - durMaxA) : resto)   --Suponemos que la nota pertenece a varios acordes  CORRECTO
        | d <  durMaxA  =  armonizaNotasPrincipales3' gen ma durMaxA cifradosCandidatos d resto  -- CORRECTO
        where cifradosCandidatos = buscaCifradosCandidatosDeCMayor ma pc;
              (cifradoAleatorio, newGen) = elementoAleatorio gen cifradosCandidatos 


-- Igual que la funcion anterior pero llevamos anclado una lista de acordes candidatos y su duracion
-- NOTA: EL CASO DE newCifCan /= []  ES EL MISMO PARA TODOS PERO POR SIMPLICIDAD LO ESCRIBO A PARTE
armonizaNotasPrincipales3' :: RandomGen g => g -> ModoAcordes -> DurMaxA -> CifradosCandidatos -> DurAcordeAcumulado -> [NotaPrincipal] -> Progresion

armonizaNotasPrincipales3' gen ma durMaxA cifCan durA [] = [(cifAlea, durA)]  -- CORRECTO
        where (cifAlea, newGen) = elementoAleatorio gen cifCan 

armonizaNotasPrincipales3' gen ma durMaxA cifCan durA ( (pc, d) : resto) 
        | durA == durMaxA                        = (cifAlea , durMaxA) : armonizaNotasPrincipales3 newGen ma durMaxA ( (pc, d) : resto )  -- CORRECTO
        | durA + d == durMaxA && newCifCan /= [] = ( newCifAlea , d + durA) : armonizaNotasPrincipales3 newGen2 ma durMaxA resto          -- CORRECTO
        | durA + d == durMaxA && newCifCan == [] = ( cifAlea , durA) : armonizaNotasPrincipales3 newGen ma durMaxA ( (pc, d) : resto)     -- CORRECTO
        | durA + d <  durMaxA && newCifCan /= [] = armonizaNotasPrincipales3' gen ma durMaxA newCifCan (durA + d) resto                   -- CORRECTO
        | durA + d <  durMaxA && newCifCan == [] = ( cifAlea , durA) : armonizaNotasPrincipales3 newGen ma durMaxA ( (pc, d) : resto)     -- CORRECTO
        | durA + d >  durMaxA && newCifCan /= [] = ( newCifAlea , durMaxA) : armonizaNotasPrincipales3 newGen2 ma durMaxA ( (pc, d - durMaxA + durA) : resto) -- CORRECTO , pasamos el cacho de la nota que no cabe al siguiente acorde
        | durA + d >  durMaxA && newCifCan == [] = ( cifAlea , durA) : armonizaNotasPrincipales3 newGen ma durMaxA ( (pc, d) : resto)     -- CORRECTO
        where newCifCan = eliminaCifradosNoValidos cifCan (buscaCifradosCandidatosDeCMayor ma pc);
              (cifAlea, newGen) = elementoAleatorio gen cifCan;
              (newCifAlea, newGen2) = elementoAleatorio gen newCifCan;



eliminaCifradosNoValidos :: [Cifrado] -> [Cifrado] -> [Cifrado]
eliminaCifradosNoValidos = intersect










