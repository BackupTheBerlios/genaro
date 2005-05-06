module Melodias where
import List
import Basics
import BiblioGenaro
import Progresiones
import Escalas
import HaskoreAMidi
import PatronesRitmicos
import Maybe
import PrologAHaskell --para pruebas
import Ratio          --para pruebas
import Directory      --para pruebas
import CAHaskell      --para pruebas solo??????????
{-
BUGS!!!!!!!!!!!!!!
    -hazCurvaMelodicaAleatAcu:el 20 es una chunguez y el 0.8 ni te cuento
    -type PuntoMelodico = (SaltoMelodico, Dur) deberï¿½a ser type PuntoMelodico = (SaltoMelodico, Dur, Acento), pq si no la melodia
no se callarï¿½ nunca. Con Acento = 0 serï¿½a callarse, lo metere con lo del ritmo
    -Hay que hacer: ritmo  y unir varios acordes
    -Ajustar los pesos por dios!!!
    -reciclar para hacer el bajo con walking = salto de 3 grados como mucho
                                               apaï¿½ar ritmo para que vaya a negras o corcheas:
                                                  .que cuadre con la dur del acorde: saltos excesivos de tempo/altura para encajar
   -hazMelodiaParaAcorde solo vale para curvas aleatorias. Reciclar en el futuro para que tb procese curvas escritas por el usuario,pero
ATENCION!!!, los dur de esas curvas se suponen a un grado de abstraccion mas elevado, deberï¿½n adaptarse para el patron ritmico concreto
-}
{-
--
-- PATRON RITMICO
--
type Voz = Int
type Acento = Float         -- Acento: intensidad con que se ejecuta ese tiempo. Valor de 0 a 100
type Ligado = Bool          -- Ligado: indica si una voz de una columna esta ligada con la se la siguiente columna
                            -- en caso de que no este dicha voz el ligado se ignora
type URV = [(Voz, Acento, Ligado)]	-- Unidad de ritmo vertical, especifica todas las filas de una unica columna
type URH = Dur 				-- Unidad de ritmo horizontal, especifica la duracion de una columna
type UPR = ( URV , URH)                 -- Unidad del patron ritmico, especifica completamente toda la informacion necesaria
                                        -- para una columna (con todas sus filas) en la matriz que representa el patron
type AlturaPatron = Int			-- numero maximo de voces que posee el patron
type MatrizRitmica = [UPR]              -- Una lista de columnas, vamos, como una matriz

type PatronRitmico = (AlturaPatron, MatrizRitmica)
-}
{-
Numero de grados que se mueve hacia arriba la melodia desde el punto anterior
-}
type SaltoMelodico = Int
{-
Numero de grados que se mueve hacia arriba la melodia desde el punto anterior
-}
type PuntoMelodico = (SaltoMelodico)
type CurvaMelodica = [PuntoMelodico]
{-
Resultado de procesar un PatronRitmico, da los acentos fuertes que se consideraran para una melodia. Para ello
calcula la lista que tiene para cada columna de un patron ritmico la media de acentos de cada voz, y la media
total de acento dentro de la matriz. Luego devuelve el resultado de procesar esa lista dejando con acento cero
las columnas que tengan acento menor que la media, y dejando igual aquellas que lo tengan mayor o igual
-}
type ListaAcentos = [(Acento, Dur)]
construyeListaAcentos :: PatronRitmico -> ListaAcentos
construyeListaAcentos (numVoces, matriz) = listaAcentos
                                    where numColumnas = length matriz
                                          matrizVertical = map fst matriz
                                          listaAcentoMedioCols =  [(foldl' (\suma -> \(_,ac,_) -> suma + ac ) 0 col) / fromIntegral numVoces |col <- matrizVertical]
                                          acentoMedio = (foldl' (+) 0 listaAcentoMedioCols) / fromIntegral numColumnas
                                          listaAcentos = zip (map (\acento -> if acento >= acentoMedio then acento else 0) listaAcentoMedioCols) (map snd matriz)

{-
Funciona como si data ModoPatronHorizontal = NoCiclico
-}
ajustaListaAcentosADur :: Dur -> ListaAcentos -> ListaAcentos
ajustaListaAcentosADur dur acentos
  | durTotalAcentos == dur = acentos
  | durTotalAcentos > dur  = acentosMenos
  | durTotalAcentos < dur  = acentosMas
                             where durTotalAcentos     = foldl' (+) 0 (map snd acentos)
                                   acentosSinUltimo    = (invertir.tail.invertir) acentos
                                   durAcentosSinUltimo = foldl' (+) 0 (map snd acentosSinUltimo)
                                   acentosMenos        = if (durAcentosSinUltimo >= dur)
                                                            then ajustaListaAcentosADur dur acentosSinUltimo
                                                            else acentosSinUltimo ++ [(acQuitado, durDif)] -- me he pasao quitando
                                                                 where durDif = dur - durAcentosSinUltimo
                                                                       acQuitado = (fst.head.invertir) acentos
                                   acentosMas           = ajustaListaAcentosADur dur (acentos ++ acentos)

pruListaAcentos :: String -> IO()
pruListaAcentos ruta = do (FPRC cols resolucion patronRitmico) <- leePatronRitmicoC ruta
                          putStr "Lista de acentos para melodia resultado\n"
                          print (construyeListaAcentos patronRitmico)
{-
dada una lista infinita de numeros enteros aleatorios entre 1 y resolucionRandom construye
una curva melodica aleatoria segun ciertos criterios
hazCurvaMelodicaAleat :: [Int] -> Int -> Int -> Int -> Dur -> (CurvaMelodica, [Int])
hazCurvaMelodicaAleat aleat saltoMax probSalto numPuntos duracionTotal = (curva, aleatSobrantes)
        .aleat         : lista infinita de numeros aleatorios entre 1 y resolucionRandom
        .saltoMax      : numero de grados que se saltara como maximo en cada punto de la curva
        .probSalto     : cuanto mayor sea mayor probabilidad habra de que la curva melodica cambie de direccion en cada punto.
                         Debe ser del orden del numero de grados, es decir, de 1 a 12 mas o menos
        .numPuntos     : numero de puntos que tendra la curva
        .duracionTotal : duracion de la curva melodica en dur
Conceptos:
  -Las notas mas largas son las notas mas estables
  -Ajustar la curva melodica al ritmo, rellenando los huecos con notas cortas de paso o de bordadura

-}
hazCurvaMelodicaAleat :: FuncAleatoria (Int, Int, Int, Dur) CurvaMelodica
hazCurvaMelodicaAleat (aleat@(a1:as), (saltoMax, probSalto, numPuntos, duracionTotal)) = (aleatSobran, puntoPartida:restoCurva) --(puntoPartida:restoCurva, aleatSobran)
                                                                                 where sube = (fromIntegral a1/ fromIntegral resolucionRandom) >= 0.5
                                                                                       puntoPartida = 0
                                                                                       (restoCurva, aleatSobran) = hazCurvaMelodicaAleatAcu as sube saltoMax probSalto (numPuntos-1) duracionTotal 0
{-
hazCurvaMelodicaAleatAcu aleat sube saltoMax probSalto numPuntos durTotal movAcumulado = (curva, aleatSobrantes)
        .aleat         : lista infinita de numeros aleatorios entre 1 y resolucionRandom
        .sube          : es cierto sii la melodia esta subiendo por la escala
        .saltoMax      : numero de grados que se saltara como maximo en cada punto de la curva
        .probSalto     : cuanto mayor sea mayor probabilidad habra de que la curva melodica cambie de direccion en cada punto.
                         Debe ser del orden del numero de grados, es decir, de 1 a 12 mas o menos
        .numPuntos     : numero de puntos que tendra la curva
        .duracionTotal : duracion de la curva melodica en dur
        .movAcumulado  : numero de grados que se llevan movidos en el sentido (ascendente o descendente) actual de la curva
-}
hazCurvaMelodicaAleatAcu :: [Int] -> Bool -> Int -> Int -> Int -> Dur -> Int -> (CurvaMelodica, [Int])
hazCurvaMelodicaAleatAcu aleat _ _ _ 0 _ _ = ([],aleat)
hazCurvaMelodicaAleatAcu aleat@(a1:a2:as) sube sm ps n durTotal movAcumulado
  | n > 0 = (nuevoPunto:restoCurva, aleatSobran)
               where salta        = (fromIntegral a1/fromIntegral resolucionRandom) <= (fromIntegral movAcumulado * fromIntegral ps/20)
                     candsNoSalto =  map (\x -> if (x /= 0) then (x,(1/ fromIntegral x)) else (x,0.8::Float)) [0..sm]
                     candsSalto   =  map (\(val,peso)-> (val,peso + fromIntegral val* fromIntegral movAcumulado)) candsNoSalto
                     (saltoAbs,_)    = if salta
                                          then dameElemAleatListaPesosFloat a2 candsSalto
                                          else dameElemAleatListaPesosFloat a2 candsNoSalto
                     nuevoSube       = if salta
                                          then (not sube)
                                          else sube
                     salto           = if nuevoSube
                                          then saltoAbs
                                          else (-1) * saltoAbs
                     nuevoPunto    = salto
                     (restoCurva,aleatSobran)    = hazCurvaMelodicaAleatAcu as nuevoSube sm ps (n-1) durTotal (movAcumulado + saltoAbs)
{-
aplicaCurvaMelodica
Conceptos:
  -Las notas mas largas son las notas mas estables
  -Ajustar la curva melodica al ritmo, rellenando los huecos con notas cortas de paso o de bordadura, para ello
      .primero carga el ritmo en un elemento type ListaAcentos = [(Acento, Dur)]
      .rellena los huecos del ritmo con notas bastante establesESTABLES; las mas de la curva!!como?,si todo es relativo???:puedo
pq se la tonica y la escala: !! si nos piden menos notas de las que hay en la lista de
acentos elegir en cuales vamos a atacar y en el resto ver si las ligamos a las anteriores o si las dejamos en silencio.ATENCION: No
rellenar todos las huecos del ritmo con notas de la curva pq serï¿½a demasiado determinista, rellenar solamente unos cuantos (al azar)
      .si todavia nos faltan notas rellenar los espacios con notas menos estables y mas cortas

-}
{-
aplicaCurvaMelodica :: PatronRitmico -> Registro -> Escala -> PitchClass -> Pitch -> CurvaMelodica ->  [Music]
--aplicaCurvaMelodica patronRit registro escala tonica pitchPartida [] = [Rest 0]
aplicaCurvaMelodica patronRit registro escala tonica pitchPartida curva =
                    where acentos = construyeListaAcentos patronRit
-}
--type ListaAcentos = [(Acento, Dur)]
{-
      .rellena los huecos del ritmo con notas bastante establesESTABLES; las mas de la curva!!como?,si todo es relativo???:puedo
pq se la tonica y la escala: !! si nos piden menos notas de las que hay en la lista de
acentos elegir en cuales vamos a atacar y en el resto ver si las ligamos a las anteriores o si las dejamos en silencio
     . la curva sin consumir representada de forma que no se pierda la posicion relativa de los puntos de la curva, como la curva
de entrada pero con menos densidad


aplicaCurvaMelodicaFase1 :: FuncAleatoria (Registro, Escala, PitchClass, Pitch, Dur, ListaAcentos, CurvaMelodica ) ([Music],ListaAcentos,[Maybe ((Grado,Pitch),Float)])
aplicaCurvaMelodicaFase1 (aleat, (registro, escala, tonica, pitchPartida, dur, acentos, curvaMelodica)) = (restoAleat4,(musica, acentosSobran, curvaSobra))
Devuelve : .musica :: [Music] : lista de notas para hacer la melodia
           .acentosSobran :: ListaAcentos: los acentos de dur -1 ya estan consumidos
           .curvaSobra :: [Maybe ((Grado,Pitch),Float)] : los Nothing son puntos de la curva consumidos
                                                          los Just son el grado y pitch correspondiente al punto de la curva
                                                          y los float su peso/estabilidad calculado con valoraGrado


-}
aplicaCurvaMelodicaFase1 :: FuncAleatoria (Registro, Escala, PitchClass, Pitch, Dur, ListaAcentos, CurvaMelodica ) ([Music],ListaAcentos,[Maybe ((Grado,Pitch),Float)])
aplicaCurvaMelodicaFase1 (aleat, (registro, escala, tonica, pitchPartida, dur, acentos, curvaMelodica)) = (restoAleat4,(musica, acentosSobran, curvaSobra))
            where acentosAjustadosADur = ajustaListaAcentosADur dur acentos
                  (restoAleat1@(ra1:restoAleat2),(curvaAjustada, acentosAjustados)) = ajustaCurvaMelodicaConListaAcentos (aleat, (curvaMelodica, acentosAjustadosADur))
                  numAcentosElegidos = if (numAux<=0)
                                            then 1
                                            else if (numAux > tamAcentos)
                                                    then tamAcentos
                                                    else numAux
                                          where numAux = round ( fromIntegral (ra1 * tamAcentos) / fromIntegral resolucionRandom)
                                                tamAcentos = length acentosAjustados
                  listaPesosAcentos = zip acentosAjustados (map fst acentosAjustados)
                  (restoAleat3, (lAcenPosElegidos, lAcenRech)) = dameSublistaAleatListaPesosTamRestoFloat (restoAleat2, (numAcentosElegidos, listaPesosAcentos))
                  --  FuncAleatoria (Int, [(a, Float)]) ([(a, Int)], [((a,Float), Int)])
                  listaGradosPitch = curvaMelodicaAGradosPitch registro escala tonica curvaAjustada pitchPartida
                  listaPesosGrados = zip listaGradosPitch (map (\(g,p)-> fromIntegral (valoraGrado escala g)) listaGradosPitch)
                  (restoAleat4, (lGradsPosElegidos, lGradsRech)) = dameSublistaAleatListaPesosTamRestoFloat (restoAleat3, (numAcentosElegidos, listaPesosGrados))
                  posAcentosElegidos = map snd lAcenPosElegidos
                  convMus (vel, dur) (grado, pitch) = (Note pitch dur [Volume vel'])
                                                        where vel' = max vel 5.0
                  musicaSuena = zip (zipWith convMus (map fst lAcenPosElegidos) (map fst lGradsPosElegidos)) posAcentosElegidos
                  musicaNoSuena = [(Rest dur,pos) | (((_, dur),_), pos) <- lAcenRech]
                  ordena x y = compare (snd x) (snd y)
                  musica = map fst listaMus
                           where listaMus = sortBy ordena (union musicaSuena musicaNoSuena)
                  --los acentos de velocity -1 se suponen ya consumidos
                  acentosSobran = map fst (sortBy ordena (union acentosNulos acentosNoNulos))
                           where acentosNulos = [((-1, dur), pos) | ((_,dur),pos) <- lAcenPosElegidos]
                                 acentosNoNulos = [((ac,dur), pos) | (((ac,dur), _), pos) <- lAcenRech]
                  curvaSobra = map fst (sortBy ordena (union puntosNulos puntosNoNulos))
                           where puntosNulos = [(Nothing, pos) |(_,pos) <- lGradsPosElegidos ]
                                 puntosNoNulos = [(Just (punto, peso),pos) |((punto, peso),pos) <- lGradsRech]

dameCandidatosFase2 :: ListaAcentos -> [Int]
dameCandidatosFase2 acentos  = sacaCandidatosPos 0 acentos
        where numAcentos = length acentos
              --formato de entrada (velocity, dur)
              sacaCandidatosPos _ []     = []
              sacaCandidatosPos _ (x:[]) = []
              sacaCandidatosPos pos ((v1,d1):(v2,d2):xs)
                | (v1 <0) && (v2 >=0) = pos : (restoCandidatos)
                | otherwise           = restoCandidatos
                              where restoCandidatos = sacaCandidatosPos (pos +1) ((v2,d2):xs)


alargaMusicaFase2 :: [Int] -> [Music] -> [Music]
alargaMusicaFase2 = alargaElemTalPos 0
    where alargaElemTalPos _ _ []      = []
          alargaElemTalPos _ [] musica = musica
          alargaElemTalPos pos1 (pos2:xs) (m1:m2:ms)
            | pos1 == pos2 = ((sumaDur (dur m2) m1):restoMusExito)
            | otherwise    = (m1:restoMusFallo)
                               where restoMusExito = alargaElemTalPos (pos1 + 2) xs ms
                                     restoMusFallo = alargaElemTalPos (pos1 + 1) (pos2:xs) (m2:ms)
                                     sumaDur dur (Note p durOri atribs) = (Note p (durOri + dur) atribs)

{-
mete una nota de paso intermedia, para ello interpola:
  -pitch: notas que esten entre dos notas, dentro de la escala!, eligiendo al azar entre los candidatos
  -ritmo: para q haya mas variacion ritmica respecto al patron ritmico siempre mete notas en el tiempo partido
por dos, pq suponemos binario, ej: entre dos notas Note (C,6) (1%2) [] y Note (E,6) (1%8) [] pondría un
Note (D,6) (1%4) [] diviendo en dos el primer do para q queden entre medias, es decir:
(Note (C,6) (1%4) []) :+: Note (D,6) (1%4) [] :+: Note (E,6) (1%8) []
-}
--aplicaCurvaMelodicaFase3 ::
{-aplicaCurvaMelodicaFase3 (aleat@(a1,restoAleat1), (registro, escala, tonica, musica)) =
                 where numNotasIn = length musica
                       listaPesosNotas = zip [0..(numNotasIn - 1)] [1| p <- [0..(numNotasIn - 1)]]
                       posElegida = dameElemAleatListaPesos a1 listaPesosNotas
                       -- al loro con el caso en que se elije la ultima nota, pq no tiene ninguna a su derecha
                       -- esto tb ocurre si solo hay una nota claro
  -}
{-
damePitchIntermedioAleatFase3 :: FuncAleatoria (Escala, PitchClass, Pitch, Pitch) Pitch
damePitchIntermedioAleatFase3 (aleat, (escala, tonica, notaIzda, notaDcha))
NO PENSAR Q LA NOTA IZDA ES MAS GRAVE PQ NO TIENE PQ!!!
-}

--aplicaCurvaMelodicaFase2 (aleat, (registro, escala, tonica, pitchPartida, dur, acentos, curvaMelodica)) = (restoAleat4,(musica, acentosSobran, curvaSobra))
--aplicaCurvaMelodicaFase2 (aleat, (acentos, curva, musica))
--se ligan las notas con el acento de su derecha para alargarlos: es un proceso que se puede repetir varias veces
--para hacer melodias con notas mas largas. La curva melodcia no se necesita
aplicaCurvaMelodicaFase2  :: FuncAleatoria (Escala, PitchClass, ListaAcentos, [Music]) [Music]
aplicaCurvaMelodicaFase2 (aleat, (escala, tonica, acentos, musica))
 | numAcentosCand <= 0 = (aleat, musica)
 | otherwise = (restoAleat1, musicaLarga)
      where posAcentosCand = dameCandidatosFase2 acentos
            numAcentosCand = length posAcentosCand
            listaPesosAcentos = zip posAcentosCand [fromIntegral (valoraGrado escala (dameIntervaloPitch tonica (damePitch(musica!!pos))))|pos <- posAcentosCand]
            --tienen mas probabilidad de alargarse las notas q corresponden a grados mas estables
            (restoAleat1, (lAcenPosElegidos, lAcenRech)) = dameSublistaAleatListaPesosRestoFloat (aleat, listaPesosAcentos)
            --FuncAleatoria [(a, Float)] ([(a, Int)], [((a,Float), Int)])
            musicaLarga = alargaMusicaFase2 (map fst lAcenPosElegidos) musica

--([Music],ListaAcentos,[Maybe ((Grado,Pitch),Float)])

pruAplicaCurvaMelodica :: String -> Int -> Dur -> IO()
pruAplicaCurvaMelodica ruta numPuntos dur = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                               (FPRC cols resolucion p) <- leePatronRitmicoC ruta
                                               putStr ("Curva melodica: " ++ (show (curvaMelodica aleat)) ++ "\n")
                                               putStr ("Lista de acentos: " ++ (show (acentos p)) ++ "\n")
                                               --putStr ("Resultado: " ++ (show (resul aleat p)) ++ "\n")
                                               putStr ("Musica fase1: "++(show (musica1 aleat p))++"\n")
                                               putStr ("Acentos sobrantes: "++(show (acentosSobran aleat p))++"\n")
                                               putStr ("Curva melodica sobrante: "++(show (curvaSobra aleat p))++"\n")
                                               haskoreAMidi (musica1 aleat p) "./pruMelodiaFase1.mid"
                                               putStr "Escrito con exito midi de prueba en ./pruMelodiaFase1.mid\n"
                                               putStr ("Musica alargada: "++(show (musicaLarga aleat p))++"\n")
                                               haskoreAMidi (musicaLarga aleat p) "./pruMelodiaFase2.mid"
                                               putStr "Escrito con exito midi alargado de prueba en ./pruMelodiaFase2.mid\n"
                                               where acentos p = construyeListaAcentos p
                                                     curvaMelodica aleat = snd (hazCurvaMelodicaAleat (aleat, (3, 6, numPuntos, (1%4))))
                                                     longCurIni aleat = length (curvaMelodica aleat)
                                                     restoAl1 aleat = fst (hazCurvaMelodicaAleat (aleat, (3, 6, numPuntos, (1%4))))
                                                     resul aleat p = snd (aplicaCurvaMelodicaFase1 ((restoAl1 aleat), (registroSolista, Jonica, C, (C,6), dur, (acentos p), curvaMelodica aleat)))
                                                     restoAl2 aleat p = fst (aplicaCurvaMelodicaFase1 ((restoAl1 aleat), (registroSolista, Jonica, C, (C,6), dur, (acentos p), curvaMelodica aleat)))
                                                     musicaLista aleat p = primero (resul aleat p)
                                                     musica1 aleat p = line (primero (resul aleat p))
                                                     acentosSobran aleat p = segundo (resul aleat p)
                                                     curvaSobra aleat p = tercero (resul aleat p)
                                                     musicaLarga aleat p = line (snd (aplicaCurvaMelodicaFase2 ((restoAl2 aleat p), (Jonica, C, (acentosSobran aleat p), ((musicaLista aleat p))))))
                                                      -- aplicaCurvaMelodicaFase2 (aleat, (escala, tonica, acentos, musica))


{-
ajustaCurvaMelodicaConListaAcentos :: FuncAleatoria (CurvaMelodica,ListaAcentos) (CurvaMelodica,ListaAcentos)
dada una pareja (CurvaMelodica,ListaAcentos) devuelve una pareja del mismo tipo que sea compatible, es decir, tenga el mismo numero de
puntos. Para ello se sigue el siguiente criterio:
    .curva con mï¿½s puntos q la lista de acentos  : se insertan en la lista de acentos puntos cortas intermedias
    .curva con menos puntos q la lista de acentos: se unen puntos del ritmo para representar notas mï¿½s largas
-}
--type ListaAcentos = [(Acento, Dur)]
--type CurvaMelodica = [Int]
ajustaCurvaMelodicaConListaAcentos :: FuncAleatoria (CurvaMelodica,ListaAcentos) (CurvaMelodica,ListaAcentos)
ajustaCurvaMelodicaConListaAcentos (aleat, (curvaMel, listaAcentos))
    | longCurva == longAcentos = (aleat, (curvaMel, listaAcentos))
    | longCurva > longAcentos = (resto1, (curvaMel, acentosDivididos))
    | longCurva < longAcentos = (resto2, (curvaMel, acentosUnidos))
                          where longCurva = length curvaMel
                                longAcentos = length listaAcentos
                                diferencia = abs (longCurva - longAcentos)
                                (resto1, acentosDivididos) = aplicaNVeces diferencia insertaAcentoIntermedio (aleat, listaAcentos)
                                (resto2, acentosUnidos) = aplicaNVeces diferencia uneDosAcentos (aleat, listaAcentos)



{-
Dada una lista de acentos devuelve el resultado de dividir en dos un acento. El acento se escoge al azar dando mayor pobabilidad
de dividirse a los acentos mas largos
-}
insertaAcentoIntermedio :: FuncAleatoria ListaAcentos ListaAcentos
insertaAcentoIntermedio (aleat@(a1:as), acentos@(p:ps)) = (as,nuevaLista)
                                          where --listaPesosAcentos = zip acentos (map fst acentos)
                                                listaPesosAcentos = zip acentos (map ((\x -> (fromIntegral (numerator x))/(fromIntegral (denominator x))).snd) acentos)
                                                ((a,dur), posAux) = dameElemAleatListaPesosFloat a1 listaPesosAcentos
                                                pos = posAux - 1 -- pq dameElemAleatListaPesosFloat cuenta posiciones desde 1
                                                nuevaDur = dur / 2
                                                nuevaLista = sustituyeSublistaPos pos [(a,nuevaDur),(a, nuevaDur)] acentos
{-
Dada una lista de acentos devuelve el resultado de juntar dos acentos en uno cuya duracion es la suma de ambos y cuya
intensidad es la media de ambos. El acento se escoge al azar dando mayor pobabilidad de unirse a los acentos mas cortos
-}
uneDosAcentos :: FuncAleatoria ListaAcentos ListaAcentos
uneDosAcentos (aleat@(a1:a2:as), acentos@(p:ps)) = (as, nuevaLista) --(nuevaLista,as)
                                          where --listaPesosAcentos = zip acentos (map fst acentos)
                                                listaPesosAcentos = zip acentos (map ((\x -> (fromIntegral (denominator x))/(fromIntegral (numerator x))).snd) acentos)
                                                ((a,dur), posAux) = dameElemAleatListaPesosFloat a1 listaPesosAcentos
                                                pos = posAux - 1 -- pq dameElemAleatListaPesosFloat cuenta posiciones desde 1
                                                posColega = if (pos == 0)
                                                                then pos + 1
                                                                else if (pos == ((length acentos) - 1))
                                                                        then pos - 1
                                                                        else if (a2 <= (resolucionRandom `div` 2))
                                                                                then pos - 1
                                                                                else pos + 1
                                                (ac, durc) = acentos !! posColega
                                                nuevoAcento = ((a + ac)/2, dur + durc)
                                                [ini, fin] = sort [pos, posColega]
                                                nuevaLista = sustituyeSublistaPosIniFin ini fin [nuevoAcento] acentos
{-
pruAjustaCurvaMelodicaConListaAcentos ruta numPuntos
   -ruta: del fichero de patron ritmico
   -numPuntos: de la curva melodica aleatoria
-}
pruAjustaCurvaMelodicaConListaAcentos :: String -> Int -> IO()
pruAjustaCurvaMelodicaConListaAcentos ruta numPuntos = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                          (FPRC cols resolucion patronRitmico) <- leePatronRitmicoC ruta
                                                          putStr ("Curva melodica: " ++ (show (curvaMelodica aleat)) ++ "\n" ++ "\tlongitud: "++(show (longCurIni aleat))++"\n")
                                                          putStr ("Lista de acentos: " ++ (show (acentos patronRitmico)) ++ "\n"++ "\tlongitud: "++(show (longAcIni patronRitmico))++"\n")
                                                          putStr ("Resultado :" ++ (show (resul aleat patronRitmico)) ++ "\n")
                                                          putStr ("\tlongitud de la curva: "++(show (longCurFin aleat patronRitmico))++"\n")
                                                          putStr ("\tlongitud de la lista de acentos: "++(show (longAcFin aleat patronRitmico))++"\n")
                                                          where acentos p = construyeListaAcentos p
                                                                longAcIni p = length (acentos p)
                                                                curvaMelodica aleat = snd (hazCurvaMelodicaAleat (aleat, (3, 6, numPuntos, (1%4))))
                                                                longCurIni aleat = length (curvaMelodica aleat)
                                                                restoAl aleat = fst (hazCurvaMelodicaAleat (aleat, (3, 6, numPuntos, (1%4))))
                                                                resul aleat p = snd (ajustaCurvaMelodicaConListaAcentos ((restoAl aleat),(curvaMelodica aleat, acentos p)))
                                                                longAcFin aleat p = length (snd (resul aleat p))
                                                                longCurFin aleat p = length (fst (resul aleat p))


{-
saltoMaxDef :: Int
Valor por defecto del salto melodico maximo en una curva melodica
-}
saltoMaxDef :: Int
saltoMaxDef = 3

{-
divisorAcentos :: Int
Cantidad por la que se dividen los acentos para duplicarlos. Se hace por dos pq es binario
-}
divisorAcentos :: Int
divisorAcentos = 2


curvaMelodicaAGradosPitch :: Registro -> Escala -> PitchClass -> CurvaMelodica -> Pitch -> [(Grado,Pitch)]
curvaMelodicaAGradosPitch registro escala tonica [] pitchPartida = []
curvaMelodicaAGradosPitch registro escala tonica (salto:pms) pitchPartida = (nuevoGrado,nuevoPitch) : restoMelodia
                    where (p,oct)   = saltaIntervaloPitch escala tonica salto pitchPartida
                          octavaDef = ajustaOctava registro oct
                          nuevoPitch = (p,octavaDef)
                          nuevoGrado = dameIntervaloPitch tonica nuevoPitch
                          restoMelodia = curvaMelodicaAGradosPitch registro escala tonica pms nuevoPitch
{-
Devuelve el resultado de truncar la octava suministrada para que se ajuste al registro especificado
-}
ajustaOctava :: Registro -> Octave -> Octave
ajustaOctava registro oct = if elem oct registro
                               then oct
                               else if oct < octavaMin
                                    then octavaMin --caso de octava mas baja que el registro
                                    else octavaMax --caso de octava mas alta que el registro
                                         where octavaMin = dameMinimizador id registro
                                               octavaMax = dameMinimizador (*(-1)) registro
{-
supone siempre que la tonica es Do
-}
{-
VIEJO
pitchDeTonicaDelAcorde = pitch (gradoAIntAbs grado + 24) -- 24 pq supone Do de tonica
tonica = fst pitchDeTonicaDelAcorde
pitchPartida = pitch (gradoAIntAbs gradoIni + absPitch pitchDeTonicaDelAcorde)
-}
{-
(tonica,_) = pitch (gradoAIntAbs grado + 0) -- 0 pq supone Do de tonica, salta desde DO a la tonica del acorde
(pcAux, octAux) = pitch (gradoAIntAbs grado + gradoAIntAbs gradoIni + 0) --grado para saltar desde el DO (0) a la tonica del acorde, gradoIni para ir al grado que sea dentro del acorde
-}
hazMelodiaParaAcorde :: [Int] -> Int -> Int -> Int -> (Cifrado, Dur) -> ([Music],[Int])
hazMelodiaParaAcorde aleat@(a1:a2:as) saltoMax probSalto numNotas (acorde@(grado,matricula), duracion) = ([Rest 0], aleat)
{-hazMelodiaParaAcorde aleat@(a1:a2:as) saltoMax probSalto numNotas (acorde@(grado,matricula), duracion) = (musica, restoAleat)
                where escala = escalaDelAcorde acorde
                      notasYPesos = dameNotasYPesosDeEscala escala
                      (gradoIni,_) = dameElemAleatListaPesos a1 notasYPesos
                      octavaCentral = (\xs -> xs !! (length xs `div` 2)) registroSolista
                      octavasYPesos = zip registroSolista  (map (\x -> 1 / fromIntegral (abs(x - octavaCentral)+1)) registroSolista)
                      (octavaDePartida,_) = dameElemAleatListaPesosFloat a2 octavasYPesos
                      (tonica,_) = pitch (gradoAIntAbs grado + 0)
                      (pcAux, octAux) = pitch (gradoAIntAbs grado + gradoAIntAbs gradoIni + 0)
                      pitchPartida = (pcAux, octavaDePartida)
                      (curvaAleat,restoAleat) = hazCurvaMelodicaAleat as saltoMax probSalto numNotas duracion
                      musica = aplicaCurvaMelodica registroSolista escala tonica curvaAleat pitchPartida
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
tantos grados como num, contando desde gradoPartida. USA dameGradoDiatonicoCercano PARA LOS CASOS EN QUE SE
PARTA DE UNA NOTA NO DIATÃ“NICA
-}
saltaIntervaloPitch :: Escala -> PitchClass -> Int -> Pitch -> Pitch
saltaIntervaloPitch escala tonica num notaPartida@(clase, oct)
 | num == 0  = notaPartida
 | otherwise = pitchResul
            where (_,gradosEscala,_)  = dameInfoEscala escala
                  gradoPartida        = dameIntervaloPitch tonica notaPartida
                  pitchResul = case (elemIndex gradoPartida gradosEscala) of
                                      Just posGradoPartida -> saltaIntervaloPitchDiatonico escala tonica num notaPartida  --salto desde grado diatonico
                                      Nothing              -> saltaIntervaloPitchDiatonico escala tonica numAux (claseCercano, octavaCercano)
                                                                  where subir = num > 0
                                                                        gradoCercano = dameGradoDiatonicoCercano subir escala gradoPartida
                                                                        claseCercano = gradoAPitchClassTonica tonica gradoCercano
                                                                        octavaCercano = if num>0
                                                                                           then if (posPartida < posCercano) -- subiendo
                                                                                                then oct     -- no ha cambiado de octava
                                                                                                else oct + 1 -- ha subido una octava
                                                                                           else if (posPartida > posCercano) -- bajando
                                                                                                then oct     -- no ha cambiado de octava
                                                                                                else oct - 1 -- ha bajado una octava
                                                                                              where posPartida = absPitch (gradoAPitchClassTonica tonica gradoPartida,0)
                                                                                                    posCercano = absPitch (gradoAPitchClassTonica tonica gradoCercano,0)
                                                                        numAux = if num>0
                                                                                    then num - 1
                                                                                    else num + 1

{-
Como saltaIntervaloPitch pero suponiendo que se parte de una nota diatonica
-}
saltaIntervaloPitchDiatonico :: Escala -> PitchClass -> Int -> Pitch -> Pitch
saltaIntervaloPitchDiatonico escala tonica num notaPartida@(clase, oct)
 | num == 0  = notaPartida
 | num > 0   = (claseResul, oct + octavaResulSube)
 | num < 0   = (claseResul, oct - octavaResulBaja)
              where (_,gradosEscala,_)  = dameInfoEscala escala
                    gradoPartida        = dameIntervaloPitch tonica notaPartida
                    gradoSalida         = saltaIntervaloGrado escala num gradoPartida
                    claseResul          = gradoAPitchClassTonica tonica gradoSalida
                    posGradoPartida     = fromJust (elemIndex gradoPartida gradosEscala)
                    posGradoSalida      = fromJust (elemIndex gradoSalida gradosEscala)
                    numGrados           = length gradosEscala
                    numOctavasPorNumGrados = div (abs num) numGrados
                    octavaResulSube = if (posGradoSalida < posGradoPartida)
                                         then numOctavasPorNumGrados + 1
                                         else numOctavasPorNumGrados
                    octavaResulBaja = if (posGradoSalida > posGradoPartida)
                                         then numOctavasPorNumGrados + 1
                                         else numOctavasPorNumGrados


{-saltaIntervaloPitch escala tonica num notaPartida@(clase, oct) = resul
                where --(_,gradosEscala,_)  = dameInfoEscala escala
                      gradoPartida        = dameIntervaloPitch tonica notaPartida
                      gradoSalida         = saltaIntervaloGrado escala num gradoPartida
                      --numGrados           = length gradosEscala
                      --salto               = (gradoAIntAbs gradoSalida) - (gradoAIntAbs gradoPartida) + (div num numGrados)*12
                      --resul               = pitch ((absPitch notaPartida) + salto)
                      claseResul            = gradoAPitchClassTonica tonica gradoSalida
                      octavaResul =           -}

pruMelAc :: IO()
pruMelAc = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
              putStr mensajeGenerandoMidi
              haskoreAMidi (musica aleat) rutaDestinoMidi
              putStr "\n Proceso terminado satisfactoriamente\n"
              where rutaDestinoMidi = "c:/hlocal/midiMeloso.mid"
                    mensajeGenerandoMidi = "\n Generando el archivo midi: " ++ rutaDestinoMidi ++ "\n"
                    musica aleat = line (fst (hazMelodiaParaAcorde aleat 4 8 4 ((I,Maj7), 2%1)))

pruMelAcArgs :: String -> Int -> Int -> Int -> Dur -> IO()
pruMelAcArgs dirTrabajo saltoMax probSalto numNotas duracion = do setCurrentDirectory dirTrabajo
                                                                  putStr (mensajeDirTrabajo dirTrabajo)
                                                                  aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                                  putStr mensajeGenerandoMidi
                                                                  haskoreAMidi (musica aleat) rutaDestinoMidi
                                                                  putStr "\n Proceso terminado satisfactoriamente\n"
                                                                  where mensajeDirTrabajo dir = "\n El directorio de trabajo es: " ++ dir ++ "\n"
                                                                        rutaDestinoMidi = "./midiMeloso.mid"
                                                                        parametros = "\n\tsaltoMaximo: " ++ (show saltoMax) ++ "\n\tpeso de cambiar de direccion: " ++ (show probSalto) ++ "\n\tnumero de notas: " ++ (show numNotas) ++ "\n\tduracion de la melodia: " ++ (show duracion) ++ "\n\tfichero destino: " ++ rutaDestinoMidi
                                                                        mensajeGenerandoMidi = "\n Generando el archivo midi de parametros: " ++ parametros ++ "\n"
                                                                        musica aleat = line (fst (hazMelodiaParaAcorde aleat saltoMax probSalto numNotas ((I,Maj7), duracion)))

pruCurvaMelAleat :: Int -> Int -> Int -> Dur -> IO()
pruCurvaMelAleat saltoMax probSalto numPuntos duracionTotal = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                                 print (zip (curvaMelodica aleat) (listaGradosPitch aleat))
                                                                 where curvaMelodica aleat = snd (hazCurvaMelodicaAleat (aleat, (saltoMax, probSalto, numPuntos, duracionTotal)))
                                                                       listaGradosPitch aleat = curvaMelodicaAGradosPitch registroSolista Jonica C (curvaMelodica aleat) (C,5)

pruFallo :: String -> Int -> IO()
pruFallo dirTrabajo num
  | num > 0   = do putStr ("\n\nFaltan " ++ (show num) ++" pruebas\n\n")
                   pruMelAcArgs dirTrabajo 5 10 10 (5%1)
                   pruFallo dirTrabajo (num - 1)
  | otherwise = do putStr "\n\nNo ha fallado, fin\n\n"
--haskoreAMidi :: Music -> String -> IO()
--hazMelodiaParaAcorde aleat@(a1:as) saltoMax numNotas (acorde@(grado,matricula), duracion) = (musica, restoAleat)
