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
    -type PuntoMelodico = (SaltoMelodico, Dur) deber�a ser type PuntoMelodico = (SaltoMelodico, Dur, Acento), pq si no la melodia
no se callar� nunca. Con Acento = 0 ser�a callarse, lo metere con lo del ritmo
    -Hay que hacer: ritmo  y unir varios acordes
    -Ajustar los pesos por dios!!!
    -reciclar para hacer el bajo con walking = salto de 3 grados como mucho
                                               apa�ar ritmo para que vaya a negras o corcheas:
                                                  .que cuadre con la dur del acorde: saltos excesivos de tempo/altura para encajar
   -hazMelodiaParaAcorde solo vale para curvas aleatorias. Reciclar en el futuro para que tb procese curvas escritas por el usuario,pero
ATENCION!!!, los dur de esas curvas se suponen a un grado de abstraccion mas elevado, deber�n adaptarse para el patron ritmico concreto
-}

{-
Numero de grados que se mueve hacia arriba la melodia desde el punto anterior
-}
type SaltoMelodico = Int
type CurvaMelodica = [SaltoMelodico]
{-
Curva melodica para cada acorde de la progresion
-}
type CurvaMelodicaProgresion = [CurvaMelodica]

{-
mutaCurvaMelodica :: FuncAleatoria (Int, CurvaMelodica) CurvaMelodica
mutaCurvaMelodica (aleat, (despMax, curva))
   -cambia un solo punto de la curva melodica elegido al azar, moviendolo entre (-despMax) y despMax,
  excepto cero, (al azar tb)
-}
mutaCurvaMelodica :: FuncAleatoria (Int, CurvaMelodica) CurvaMelodica
mutaCurvaMelodica (aleat@(a1:a2:a3:restoAleat1), (despMax, curva)) = (restoAleat1, curvaResul)
    where  tamCurva = length curva
           candidatos = zip curva (replicate tamCurva 1)
           (puntoElegido,posElegidaMasUno) = dameElemAleatListaPesos a1 candidatos
           --como minimo se desplaza una unidad
           despElegido = max 1 (round ((fromIntegral a2/(fromIntegral resolucionRandom))*(fromIntegral despMax)))
           signo = if ((fromIntegral a3) > (fromIntegral resolucionRandom)/2) then 1 else (-1)
           nuevoPunto = puntoElegido + signo*despElegido
           curvaResul = sustituyeElemPos (posElegidaMasUno-1) nuevoPunto curva

pruMutaCurvaMelodica :: [Int] ->Int ->  IO ()
pruMutaCurvaMelodica curva despMax = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                        putStr ("Curva original: "++(show curva)++"\n")
                                        putStr ("Curva mutada: "++(show (curvaMut aleat))++"\n")
                                        where curvaMut aleat = snd (mutaCurvaMelodica (aleat ,(despMax, curva)))
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
hazCurvaMelodicaAleat (aleat@(a1:as), (saltoMax, probSalto, numPuntos, duracionTotal)) = (aleatSobran, puntoPartida:restoCurva)
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


aplicaCurvaMelodica :: FuncAleatoria (Registro, Escala, PitchClass, Pitch, Dur, Int, Int, ListaAcentos, CurvaMelodica) [Music]
aplicaCurvaMelodica (aleat, (_, _, _, _, _, _, _, _, [])) = (aleat, [])
aplicaCurvaMelodica (aleat, (registro, escala, tonica, pitchPartida, dur, numAplicacionesFase2, numAplicacionesFase3,acentos , curvaMelodica@(a1:as))) = (restoAleat3, musicaFase3)
    where (restoAleat1,(musicaFase1, acentosSobranFase1, curvaSobraFase1)) = aplicaCurvaMelodicaFase1 (aleat, (registro, escala, tonica, pitchPartida, dur, acentos, curvaMelodica))
          repiteFase2 n (aleat, (escala, tonica, acentos, musica))
            | n<=0      = (aleat, musica)
            | otherwise = repiteFase2 (n-1) (restoAlAux, (escala, tonica, acentosAux, musAux))
                       where (restoAlAux, (musAux, acentosAux)) = aplicaCurvaMelodicaFase2 (aleat, (escala, tonica, acentos, musica))
          (restoAleat2, musicaFase2) = repiteFase2 numAplicacionesFase2 (restoAleat1,(escala, tonica, acentosSobranFase1, musicaFase1))
          repiteFase3 n (aleat, (escala, tonica, musica))
            | n<=0      = (aleat, musica)
            | otherwise = repiteFase3 (n-1) (restoAlAux, (escala, tonica, musicaAux))
                       where (restoAlAux, musicaAux) = aplicaCurvaMelodicaFase3 (aleat ,(escala, tonica, musica))
          (restoAleat3, musicaFase3) = repiteFase3 numAplicacionesFase3 (restoAleat2, (escala, tonica, musicaFase2))

-- aplicaCurvaMelodicaFase3 (aleat@(a1:restoAleat1), (escala, tonica, musica)) = (aleat, musicaResul)
-- aplicaCurvaMelodicaFase2 (aleat, (escala, tonica, acentos, musica)) = (aleat, (musica, acentos))
-- aplicaCurvaMelodicaFase1 (aleat, (registro, escala, tonica, pitchPartida, dur, acentos, curvaMelodica)) = (restoAleat4,(musica, acentosSobran, curvaSobra))
{-
     Hace una primera version de melodia para un solo acorde
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
{-
aplicaCurvaMelodicaFase2  :: FuncAleatoria (Escala, PitchClass, ListaAcentos, [Music]) ([Music], ListaAcentos)
aplicaCurvaMelodicaFase2 (aleat, (escala, tonica, acentos, musica))
  -se ligan las notas con el acento de su derecha para alargarlos: es un proceso que se puede repetir varias veces
para hacer melodias con notas mas largas. La curva melodcia no se necesita
  -liga varias notas, un numero aleatorio de ellas
-}
aplicaCurvaMelodicaFase2  :: FuncAleatoria (Escala, PitchClass, ListaAcentos, [Music]) ([Music], ListaAcentos)
aplicaCurvaMelodicaFase2 (aleat, (escala, tonica, acentos, musica))
 | numAcentosCand <= 0 = (aleat, (musica, acentos))
 | otherwise = (restoAleat1, (musicaLarga, acentosSobran))
      where posAcentosCand = dameCandidatosFase2 acentos
            numAcentosCand = length posAcentosCand
            listaPesosAcentos = zip posAcentosCand [fromIntegral (valoraGrado escala (dameIntervaloPitch tonica (damePitch(musica!!pos))))|pos <- posAcentosCand]
            --tienen mas probabilidad de alargarse las notas q corresponden a grados mas estables
            (restoAleat1, (lAcenPosElegidos, lAcenRech)) = dameSublistaAleatListaPesosRestoFloat (aleat, listaPesosAcentos)
            --FuncAleatoria [(a, Float)] ([(a, Int)], [((a,Float), Int)])
            ordena x y = compare (snd x) (snd y)
            acentosSobran = map fst (sortBy ordena (union acentosHechosNulos restoAcentos))
                           where posAcentosAEliminar = map (+1) (map fst lAcenPosElegidos) --pq los elegidos son los q se alargaran
                                 -- por tanto los q se usan seran los de su derecha
                                 posRestoAcentos = filter (\x -> (not (elem x posAcentosAEliminar))) [0..((length acentos) -1)]
                                 hazNulo (ac,dur) = (-1, dur)
                                 acentosHechosNulos = [(hazNulo (acentos !! pos), pos) | pos <- posAcentosAEliminar]
                                 restoAcentos = [(acentos !! pos, pos) | pos <- posRestoAcentos]
            musicaLarga = alargaMusicaFase2 (map fst lAcenPosElegidos) musica

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
por dos, pq suponemos binario, ej: entre dos notas Note (C,6) (1%2) [] y Note (E,6) (1%8) [] pondr�a un
Note (D,6) (1%4) [] diviendo en dos el primer do para q queden entre medias, es decir:
(Note (C,6) (1%4) []) :+: Note (D,6) (1%4) [] :+: Note (E,6) (1%8) []
-}

aplicaCurvaMelodicaFase3 :: FuncAleatoria (Escala, PitchClass, [Music]) [Music]
aplicaCurvaMelodicaFase3 (aleat@(a1:restoAleat1), (escala, tonica, musica))
 | numCandidatos <= 0 = (aleat, musica)
 | otherwise          = (restoAleat3, musicaResul)
                 where posCandidatos = dameCandidatosFase3 musica
                       numCandidatos = length posCandidatos
                       listaPesosNotas = zip posCandidatos (replicate numCandidatos 1)
                       posElegida = fst (dameElemAleatListaPesos a1 listaPesosNotas)
                       -- nunca se se elije la ultima nota, pq no tiene ninguna a su derecha
                       -- esto tb ocurre si solo hay una nota
                       esNotaSuena (Rest _) = False
                       esNotaSuena (Note _ _ _) = True
                       -- buscaNotaSuena pos durAcu (nota:ns), pos es la posicion durante el recorrido en la superlista
                       -- a la q pertenece la lista. durAcu es la suma de la duracion de los silencios que va encintrando
                       -- Esto devuelve el trio formado por la primera nota que suena
                       -- q encuentra desde la izquierda en la sublista, su posicion en la superlista total y la
                       -- duracion de los silencios q encuentra por el camino
                       buscaNotaSuena pos durAcu (nota:ns)
                        | esNotaSuena nota = (nota, pos, durAcu)
                        | otherwise        = buscaNotaSuena (pos + 1) (durAcu + (dur nota)) ns
                       -- notaElegida = musica !! posElegida
                       Note pEl durEl atsEl = musica !! posElegida
                       sublistaBusqueda = [musica !! i | i <- [(posElegida + 1)..((length musica)-1)] ]
                       (Note pNotaDcha durNotaDcha atsNotaDcha, posNotaDcha, durSilenciosEntre) = buscaNotaSuena (posElegida +1) 0 sublistaBusqueda
                       durTotal = (durEl) + durSilenciosEntre
                       durNotaIzdaNuevo = min durEl (durTotal/2)
                       (restoAleat2@(a2:restoAleat3), pitchIntermedio) = damePitchIntermedioAleatFase3 (restoAleat1, (escala, tonica, pEl, pNotaDcha))
                       durPosibleNotaIntermedia =  [2^n | n <- [1..(round(logBase 2 (fromIntegral (denominator (durTotal/2)))))]] --valores del denominador
                       durNotaIntermedia =  1 % (fst (dameElemAleatListaPesos a2 (zip durPosibleNotaIntermedia (replicate (length durPosibleNotaIntermedia) 1))))
                       sublistaSustituta = [Note pEl durNotaIzdaNuevo atsEl,Rest ((durTotal/2)- durNotaIzdaNuevo), Note pitchIntermedio durNotaIntermedia atsEl, Rest ((durTotal/2)- durNotaIntermedia)]
                       --CAMBIAR LOS ATRIBUTOS PARA EL VELOCITY DE LA NOTA INTERMEDIA
                       musicaResul = sustituyeSublistaPosIniFin posElegida (posNotaDcha -1) sublistaSustituta musica

{-
Los candidatos son posiciones en la lista de entrada de elementos de tipo Music correspondientes a la constructora
Note y tales q en alguna posicion a su derecha se encuentra otro elementos de tipo Music correspondiente a la
constructora Note
-}
dameCandidatosFase3 :: [Music] -> [Int]
dameCandidatosFase3 musica = buscaCandsAcu False (numNotas -1) (reverse musica)
   where numNotas = length musica
         esNotaSuena (Rest _) = False
         esNotaSuena (Note _ _ _) = True
         buscaCandsAcu _ _ [] = []
         -- el booleano indica si hemos encontrado alguna nota no silencio desde el inicio del
         -- recorrido. Como vamos de dcha a izda es falso hasta después de la nota no silencio
         -- que esta mas tarde. El resto de notas mas a la izda si son candidatas si no son silencios
         -- pq tienen alguna nota no silencio a su derecha
         buscaCandsAcu False pos (nota:ns)
           | (esNotaSuena nota) = buscaCandsAcu True (pos -1) ns -- primer no silencio de la derecha
           | otherwise          = buscaCandsAcu False (pos -1) ns
         buscaCandsAcu True pos (nota:ns)
           | (esNotaSuena nota) = pos:(buscaCandsAcu True (pos -1) ns)
           | otherwise          = buscaCandsAcu True (pos -1) ns

damePitchIntermedioAleatFase3 :: FuncAleatoria (Escala, PitchClass, Pitch, Pitch) Pitch
damePitchIntermedioAleatFase3 (aleat@(a1:restoAleat1), (escala, tonica, notaIzda@(pci,oi), notaDcha@(pcd,od)))
  | (notaIzda < notaDcha) = (restoAleat1, pitchMenor)
  | (notaIzda > notaDcha) = (restoAleat1, pitchMayor)
  | otherwise             = (aleat, notaIzda)
                      where distanciaMenor = (dameDistanciaEnEscala escala tonica notaIzda notaDcha) + 7*(od-oi)
                            listaPesosMenor = (0, pesoExtremos):((distanciaMenor,pesoExtremos):(zip [1..(distanciaMenor-1)] [1.0 | p <- [1..(distanciaMenor-1)]]))
                            saltoMenor = fst (dameElemAleatListaPesosFloat a1 listaPesosMenor)
                            pitchMenor = saltaIntervaloPitch escala tonica saltoMenor notaIzda
                            distanciaMayor = (dameDistanciaEnEscala escala tonica notaDcha notaIzda) + 7*(oi-od)
                            listaPesosMayor = (0, pesoExtremos):((distanciaMayor,pesoExtremos):(zip [1..(distanciaMayor-1)] [1.0 | p <- [1..(distanciaMayor-1)]]))
                            saltoMayor = fst (dameElemAleatListaPesosFloat a1 listaPesosMayor)
                            pitchMayor = saltaIntervaloPitch escala tonica saltoMayor notaDcha
                            pesoExtremos = 0.05


pruDamePitchIntermedioAleatFase3 :: Pitch -> Pitch -> IO()
pruDamePitchIntermedioAleatFase3 notaIzda notaDcha= do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                       putStr ("nota izquierda "++(show notaIzda) ++ " nota derecha "++(show notaDcha)++"\n")
                                                       putStr ("resultado: " ++ (show (pitch aleat)))
                                                       where pitch aleat = snd (damePitchIntermedioAleatFase3 (aleat,(Jonica, C, notaIzda, notaDcha)) )

-- NO PENSAR Q LA NOTA IZDA ES MAS GRAVE PQ NO TIENE PQ!!!
{-
dameDistanciaEnEscala :: Escala -> PitchClass -> Pitch -> Pitch -> Int
dameDistanciaEnEscala escala tonica pitchAbajo@(pc1,_) pitchArriba@(pc2,_)

saltaIntervaloPitch :: Escala -> PitchClass -> Int -> Pitch -> Pitch
saltaIntervaloPitch escala tonica num notaPartida@(clase, oct)
-}

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
                                               putStr "\nEscrito con exito midi de prueba en ./pruMelodiaFase1.mid\n"
                                               putStr ("Musica alargada: "++(show (musicaLarga aleat p))++"\n")
                                               putStr ("Acentos Sobrantes 2: "++(show (curvaSobra2 aleat p))++"\n")
                                               haskoreAMidi (musicaLarga aleat p) "./pruMelodiaFase2.mid"
                                               putStr "\nEscrito con exito midi alargado de prueba en ./pruMelodiaFase2.mid\n"
                                               putStr ("Musica con notas intermedias: "++ (show (musicaNotasIntermedias aleat p))++"\n")
                                               haskoreAMidi (musicaNotasIntermedias aleat p) "./pruMelodiaFase3.mid"
                                               putStr "\nEscrito con exito midi con notas intermedias de prueba en ./pruMelodiaFase3.mid\n"
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
                                                     musicaLargaLista aleat p = fst (snd (aplicaCurvaMelodicaFase2 ((restoAl2 aleat p), (Jonica, C, (acentosSobran aleat p), ((musicaLista aleat p))))))
                                                     curvaSobra2 aleat p = snd (snd (aplicaCurvaMelodicaFase2 ((restoAl2 aleat p), (Jonica, C, (acentosSobran aleat p), ((musicaLista aleat p))))))
                                                     musicaLarga aleat p = line (musicaLargaLista aleat p) -- line (snd (aplicaCurvaMelodicaFase2 ((restoAl2 aleat p), (Jonica, C, (acentosSobran aleat p), ((musicaLista aleat p))))))
                                                     restoAl3 aleat p = fst (aplicaCurvaMelodicaFase2 ((restoAl2 aleat p), (Jonica, C, (acentosSobran aleat p), ((musicaLista aleat p)))))
                                                     musicaNotasIntermedias aleat p = line (snd (aplicaCurvaMelodicaFase3 (restoAl3 aleat p, (Jonica, C, musicaLargaLista aleat p))))
                                                      -- aplicaCurvaMelodicaFase3 (aleat@(a1:restoAleat1), (escala, tonica, musica))


{-
ajustaCurvaMelodicaConListaAcentos :: FuncAleatoria (CurvaMelodica,ListaAcentos) (CurvaMelodica,ListaAcentos)
dada una pareja (CurvaMelodica,ListaAcentos) devuelve una pareja del mismo tipo que sea compatible, es decir, tenga el mismo numero de
puntos. Para ello se sigue el siguiente criterio:
    .curva con m�s puntos q la lista de acentos  : se insertan en la lista de acentos puntos cortas intermedias
    .curva con menos puntos q la lista de acentos: se unen puntos del ritmo para representar notas m�s largas
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
Hace la melodia para un solo acorde
-}
--type CurvaMelodicaProgresion = [CurvaMelodica]
hazMelodiaParaProgresion :: FuncAleatoria (Progresion, PatronRitmico, Int, Int, Int, Int, Int) (Music, CurvaMelodicaProgresion)
hazMelodiaParaProgresion (aleat, (progresion, patron, saltoMax, probSalto, numNotas, numApsFase2, numApsFase3)) = (restoAleat3, (musicaResul, listaDeCurvasMelodicas))
   where construyeCurvas aleat [] = (aleat, [])
         construyeCurvas aleat ((cifrado, dur):ps) = (restoAleat, curvaAux:restoDeCurvas)
                        where (restoAlAux, curvaAux) = hazCurvaMelodicaAleat (aleat, (saltoMax, probSalto, numNotas, dur))
                              (restoAleat, restoDeCurvas) = construyeCurvas restoAlAux ps
         (restoAleat1, listaDeCurvasMelodicas) = construyeCurvas aleat progresion
         acentos = construyeListaAcentos patron
         primerAcorde = fst (head progresion)
         (restoAleat2, pitchPartida) = damePitchIniAleat (restoAleat1, primerAcorde)
         buscaUltimoPitch (aleat, cif, listaMus)= buscaUltimoPitchAcu (aleat, cif, reverse listaMus)
                       where buscaUltimoPitchAcu (aleat, cif, []) = damePitchIniAleat (aleat, cif)
                             buscaUltimoPitchAcu (aleat, cif, ((Rest _):ns)) = buscaUltimoPitchAcu (aleat, cif, ns)
                             buscaUltimoPitchAcu (aleat, cif, ((Note p _ _):ns)) = (aleat, p)
         construyeMusicas aleat pitchAnterior [] = (aleat, [])
         construyeMusicas aleat pitchAnterior (((cifrado, dur),curva):ccs) = (restoAleat, musicaAux:restoDeMusicas)
                   where (restoAlAux1, musicaAux) = hazMelodiaParaAcorde (aleat, (curva, acentos, (cifrado, dur), numApsFase2, numApsFase3, pitchAnterior))
                         (restoAlAux2, ultimoPitchAux) = buscaUltimoPitch (restoAlAux1, cifrado, musicaAux)
                         (restoAleat, restoDeMusicas) = construyeMusicas restoAlAux2 ultimoPitchAux ccs
         (restoAleat3, listaDeMusicas) = construyeMusicas restoAleat2 pitchPartida (zip progresion listaDeCurvasMelodicas)
         musicaResul = line (map line listaDeMusicas)

pruHazMelodiaParaProgresion :: String -> String -> IO ()
pruHazMelodiaParaProgresion rutaProgresion rutaPatron = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                           prog <- leeProgresion rutaProgresion
                                                           (FPRC cols resolucion pat) <- leePatronRitmicoC rutaPatron
                                                           putStr ("Progresion de entrada: "++(show prog)++"\n")
                                                           putStr ("Patron ritmico de entrada: "++(show pat)++"\n")
                                                           putStr ("Curvas melodicas resultado: "++(show(curvaMelodicas aleat prog pat))++"\n")
                                                           putStr ("Musica resultado: "++(show (musica aleat prog pat)))
                                                           haskoreAMidi (musica aleat prog pat) rutaDest
                                                           putStr ("\nEscrito con exito midi con notas intermedias de prueba en "++rutaDest++"\n")
                                                           where musica aleat prog pat = fst (snd (hazMelodiaParaProgresion (aleat, (prog, pat, 3, 4, 2, 1, 3))))
                                                                 curvaMelodicas aleat prog pat = snd (snd (hazMelodiaParaProgresion (aleat, (prog, pat, 3, 4, 6, 1, 3))))
                                                                 rutaDest = "./pruMelodiaParaProgresion.mid"

correspondeANat :: Float -> Bool
correspondeANat f = (fromIntegral (floor f)) == f

dameParteDchaComa :: Float -> Float
dameParteDchaComa f = f - (fromIntegral (floor f))

--distribuyeCurvaEntreDurs :: FuncAleatoria (CurvaMelodica, [Dur]) [Float]  --CurvaMelodicaProgresion
distribuyeCurvaEntreDurs (aleat, (curva, duraciones)) = (listaPorcentajes, listaNumPuntosPrim, numPuntosDistPrimFase, numPuntosDistSegFase, candsSegFase)
    where numPuntos = length curva
          numDurs = length duraciones
          durAFloat dur = (fromIntegral (numerator dur)) / (fromIntegral (denominator dur))
          sumaDurs = durAFloat (foldl1' (+) duraciones)
          -- listaPorcentajes en su elemento i-esimo da el numero de puntos de la curva que corresponden al elemento i-esimo
          -- de duraciones, como un float. Si ese float no corresponde a un entero entonces se disputa un punto de
          -- la curva con el elemento a su derecha. Se decide la disputa aleatoriamente, dando como peso de cada elemento la
          -- parte no entera de su valor
          listaPorcentajes = map (\d -> ((durAFloat d)/ sumaDurs)*(fromIntegral numPuntos)) duraciones

          --listaNumPuntosPrim = map soloNats (zip listaPorcentajes [0 .. (numDurs -1)])
          --             where soloNats (f, pos) = if (correspondeANat f) then (f, pos) else (0.0, pos)
          listaNumPuntosPrim = zip (map floor listaPorcentajes) [0 .. (numDurs -1)]
          numPuntosDistPrimFase = foldl1' (+) (map fst listaNumPuntosPrim)
          numPuntosDistSegFase = numPuntos -  numPuntosDistPrimFase
          candsSegFase = zipWith f listaPorcentajes listaNumPuntosPrim
              where f porcOri (porcPrimFase, pos) = (pos, porcOri - (fromIntegral porcPrimFase))
          -- ([3.5,1.75,1.75],[(3,0),(1,1),(1,2)],5,2,[(0,0.5),(1,0.75),(2,0.75)])
          -- (listaPorcentajes, listaNumPuntosPrim, numPuntosDistPrimFase, numPuntosDistSegFase, candsSegFase)
          distribuyeSegFase aleat@(a1:as) n cands
            | n <= 0    = (aleat, [])
            | otherwise = (restoAleat, elemEleg:restoAsignado)
                   where (elemEleg, posEleg) = dameElemAleatListaPesosFloat a1 cands
                         nuevosCands = sustituyeSublistaPos (posEleg - 1) [] cands
                         (restoAleat, restoAsignado) = distribuyeSegFase as (n-1) nuevosCands
          (restoAleat, posAAumentarFase2) = distribuyeSegFase aleat numPuntosDistSegFase candsSegFase
          aniadeNuevosPuntos [] listaPares = listaPares
          aniadeNuevosPuntos (pos1:ps) ((val,pos2):listaPares) -- LOS PUNTOS DEBEN ESTAR ORDENADOS
            | pos1 == pos2 = (val +1, pos2):restoParesExito
            | otherwise    = (val,pos2):restoParesFallo
                  where restoParesExito = aniadeNuevosPuntos ps listaPares
                        restoParesFallo = aniadeNuevosPuntos (pos1:ps) listaPares
          paresDef = aniadeNuevosPuntos (sort posAAumentarFase2) listaNumPuntosPrim
--          construyeListaCurvas

hazMelodiaParaAcorde :: FuncAleatoria (CurvaMelodica, ListaAcentos, (Cifrado, Dur), Int, Int, Pitch) [Music]
hazMelodiaParaAcorde (aleat, (curva, acentos, (acorde@(grado,matricula), dur), numApsFase2, numApsFase3, pitchPartida)) = (restoAleat1, musicaLista)
    where --(restoAleat1, curva) = hazCurvaMelodicaAleat (aleat, (saltoMax, probSalto, numNotas, dur))
          --acentos = construyeListaAcentos patron
          (tonica,_) = pitch (gradoAIntAbs grado + 0)
          escala = escalaDelAcorde acorde
          (restoAleat1, musicaLista) = aplicaCurvaMelodica (aleat, (registroSolista, escala, tonica, pitchPartida, dur, numApsFase2, numApsFase3,acentos , curva))

damePitchIniAleat :: FuncAleatoria Cifrado Pitch
damePitchIniAleat (aleat@(a1:a2:as), (acorde@(grado,matricula))) = (as, pitchPartida)
                where escala = escalaDelAcorde acorde
                      notasYPesos = dameNotasYPesosDeEscala escala
                      (gradoIni,_) = dameElemAleatListaPesos a1 notasYPesos
                      octavaCentral = (\xs -> xs !! (length xs `div` 2)) registroSolista
                      octavasYPesos = zip registroSolista  (map (\x -> 1 / fromIntegral (abs(x - octavaCentral)+1)) registroSolista)
                      (octavaDePartida,_) = dameElemAleatListaPesosFloat a2 octavasYPesos
                      --(tonica,_) = pitch (gradoAIntAbs grado + 0)
                      (pcAux, octAux) = pitch (gradoAIntAbs grado + gradoAIntAbs gradoIni + 0)
                      pitchPartida = (pcAux, octavaDePartida)

pruDamePitchIniAleat :: Cifrado -> IO()
pruDamePitchIniAleat acorde = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                 putStr ("Acorde de entrada: "++(show acorde)++"\n")
                                 putStr ("Pitch inicial aleatorio: "++(show (pitchIni aleat))++"\n")
                                 where pitchIni aleat = snd (damePitchIniAleat (aleat, acorde))

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
PARTA DE UNA NOTA NO DIATÓNICA
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

pruCurvaMelAleat :: Int -> Int -> Int -> Dur -> IO()
pruCurvaMelAleat saltoMax probSalto numPuntos duracionTotal = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                                 print (zip (curvaMelodica aleat) (listaGradosPitch aleat))
                                                                 where curvaMelodica aleat = snd (hazCurvaMelodicaAleat (aleat, (saltoMax, probSalto, numPuntos, duracionTotal)))
                                                                       listaGradosPitch aleat = curvaMelodicaAGradosPitch registroSolista Jonica C (curvaMelodica aleat) (C,5)

