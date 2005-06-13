module Bajo where
import Basics
import BiblioGenaro
import Progresiones
import Escalas
import Melodias
import HaskoreAMidi
import PrologAHaskell --para pruebas
import Ratio          --para pruebas


data TipoBajista = Aphex | Walking
     deriving(Enum,Read,Show,Eq,Ord,Bounded)


hazWalkingParaProgresion :: FuncAleatoria (Progresion, Int, Int, Int) Music
hazWalkingParaProgresion (aleat@(a1:restoAleat1), (prog, _, _, _)) = ([1], musica) --(listaCifrados, listaEscalas, listaTonicas, octavaIni)
         where listaCifrados = map fst prog
               listaDurs = map snd prog
               listaGrados = map fst listaCifrados
               listaEscalas = map escalaDelAcorde listaCifrados
               listaTonicas = map (\g -> fst (pitch (gradoAIntAbs g + 0))) listaGrados
               octavaIni = fst (dameElemAleatListaPesos a1 (zip registroDelBajo (replicate (length registroDelBajo) 1)))
               {- construyeListaLineas n (aleat, (tonicas@(t1:t2:ts), octavaActual, nn2,nn3,nn4,ndivs, escala@(e1:es), durs@(d1:ds)))
                | n<=0      = [[Rest 0]]
                | otherwise = musAux:(construyeListaLineas (n-1) (restoAlAux, ((t2:ts),nuevaOctava,nn2,nn3,nn4,ndivs, es, ds)))
                       where (restoAlAux, musAux) = hazMelodiaEntreNotas (aleat, (nn2,nn3,nn4,ndivs, e1, d1, (t1,octavaActual), (t2,octavaActual)))
                             buscaPrimerPitch ((Note p _ _):_) = p
                             buscaPrimerPitch ((Rest _): ms) = buscaPrimerPitch ms
                             ultimoPitch = buscaPrimerPitch (reverse musAux)
                             (ultimaTonica, ultimaOctava) = ultimoPitch
                             nuevaOctava = if (absPitch (ultimaTonica, 0)) <= (absPitch (t2, 0))
                                               then ultimaOctava
                                               else ultimaOctava +1
               numAcs = length prog
               -}
               --construyeListaLineas tonicas durs
               construyeListaLineas [] _ = [[(Rest 0)]]
               construyeListaLineas (t1:ts) (d1:ds) = ([Note (t1,2) d1 []]) : restoMus
                         where restoMus = construyeListaLineas ts ds
               musica = lineSeguro (concat (construyeListaLineas listaTonicas listaDurs))
               -- musica = lineSeguro (concat (construyeListaLineas numAcs (aleat, (listaTonicas, octavaIni, 2,2,2,2, listaEscalas, listaDurs))))



distribuyeNumEntreDurs :: FuncAleatoria (Int, [Dur]) [Int]
distribuyeNumEntreDurs (aleat, (cantidad, duraciones)) = (restoAleat, listaResul)
	where listaInt                    = (replicate cantidad 1)
              (restoAleat, listaListaInt) = distribuyeCurvaEntreDurs (aleat, (listaInt, duraciones))
              listaResul = map length listaListaInt

pruDistribuyeNumEntreDurs :: Int -> [Dur] -> IO ()
pruDistribuyeNumEntreDurs ent duraciones = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                              putStrLn (show (resul aleat))
                                              putStr ""
                                              where resul aleat = snd (distribuyeNumEntreDurs (aleat, (ent, duraciones)))

construyeListaLineasWalking :: FuncAleatoria ([(PitchClass,Dur,Int,Int,Int,Escala)],Dur ,Int,Int,Int,Pitch) [[Music]]
construyeListaLineasWalking (aleat, ([], _, _, _, _, _)) = (aleat, [[Rest 0]])
construyeListaLineasWalking (aleat, ([(ton1, durTotal, numAlarga, numInter, numTrina, escala)], durNotas, despCurva, numDivisiones, octavaPartida, primerPitch)) = (restoAleat1, [musAux])
    where p1 = (ton1, octavaPartida)
          (restoAleat1, musAux) = hazMelodiaEntreNotasWalking (aleat, (durNotas, despCurva, numAlarga, numInter, numTrina, numDivisiones, escala, durTotal, p1, primerPitch))
construyeListaLineasWalking (aleat, (listaMutsDursTonicas@((ton1, durTotal, numAlarga, numInter, numTrina, escala):(ton2,d,nA,nI,nT,e):ls), durNotas, despCurva, numDivisiones, octavaPartida, primerPitch))= (restoAleat3, musAux:restoMus)
    where p1 = (ton1, octavaPartida)
          (restoAleat1, oct2) = dameOctavaIniAleat registroDelBajo aleat
          p2 = (ton2, oct2)
          (restoAleat2, musAux) = hazMelodiaEntreNotasWalking (restoAleat1, (durNotas, despCurva, numAlarga, numInter, numTrina, numDivisiones, escala, durTotal, p1, p2))
          (restoAleat3, restoMus) = construyeListaLineasWalking (restoAleat2, (((ton2,d,nA,nI,nT,e):ls), durNotas, despCurva, numDivisiones, oct2, primerPitch) )

construyeListaLineasAphex :: FuncAleatoria ([(PitchClass,Dur,Int,Int,Int,Escala)],Int ,Int,Pitch) [[Music]]
construyeListaLineasAphex (aleat, ([], _, _, _ )) = (aleat, [[Rest 0]])
construyeListaLineasAphex (aleat, ([(ton1, durTotal, numAlarga, numInter, numTrina, escala)], numDivisiones, octavaPartida, primerPitch)) = (restoAleat1, [musAux])
    where p1 = (ton1, octavaPartida)
          (restoAleat1, musAux) = hazMelodiaEntreNotasAphex (aleat, (numInter, numAlarga, numTrina, numDivisiones, escala, durTotal, p1, primerPitch))
construyeListaLineasAphex (aleat, (listaMutsDursTonicas@((ton1, durTotal, numAlarga, numInter, numTrina, escala):(ton2,d,nA,nI,nT,e):ls), numDivisiones, octavaPartida, primerPitch))= (restoAleat3, musAux:restoMus)
    where p1 = (ton1, octavaPartida)
          (restoAleat1, oct2) = dameOctavaIniAleat registroDelBajo aleat
          p2 = (ton2, oct2)
          (restoAleat2, musAux) = hazMelodiaEntreNotasAphex (restoAleat1, (numInter, numAlarga, numTrina, numDivisiones, escala, durTotal, p1, p2))
          (restoAleat3, restoMus) = construyeListaLineasAphex (restoAleat2, (((ton2,d,nA,nI,nT,e):ls), numDivisiones, oct2, primerPitch) )

{-
version buena del walking
-}

hazWalkingParaProgresion2 :: FuncAleatoria (TipoBajista, Progresion, Dur, Int, Int, Int, Int, Int) Music
hazWalkingParaProgresion2 (aleat, (bajista, prog, durNotas, despCurva, numAlarga, numInter, numTrina, numDivisiones)) = (restoAleat6, musica) --(listaCifrados, listaEscalas, listaTonicas, octavaIni)
         where listaCifrados = map fst prog
               listaDurs = map snd prog
               listaGrados = map fst listaCifrados
               listaEscalas = map escalaDelAcorde listaCifrados
               listaTonicas = map (\g -> fst (pitch (gradoAIntAbs g + 0))) listaGrados
               (restoAleat1, octavaIni) = dameOctavaIniAleat registroDelBajo aleat
               (restoAleat2, listaDistAlarga) = distribuyeNumEntreDurs (restoAleat1, (numAlarga, listaDurs))
               (restoAleat3, listaDistInter) = distribuyeNumEntreDurs (restoAleat2, (numInter, listaDurs))
               (restoAleat4, listaDistTrina) = distribuyeNumEntreDurs (restoAleat3, (numTrina, listaDurs))
               listaDatosWalk = map (\(((((x,y),z),k),l),m) -> (x,y,z,k,l,m)) (zip (zip (zip (zip (zip listaTonicas listaDurs) listaDistAlarga) listaDistInter) listaDistTrina) listaEscalas)
               (restoAleat5, octavaPartida) = dameOctavaIniAleat registroDelBajo restoAleat4
               primerPitch = (head listaTonicas, octavaPartida)
               (restoAleat6, lineas) = case bajista of
                          Walking -> construyeListaLineasWalking (restoAleat5, (listaDatosWalk, durNotas, despCurva, numDivisiones, octavaPartida, primerPitch))
                          Aphex -> construyeListaLineasAphex (restoAleat5, (listaDatosWalk, numDivisiones, octavaPartida, primerPitch))
               musica = lineSeguro (concat (lineas))
               --musica = lineSeguro (concat (construyeListaLineas listaTonicas listaDurs))

pruHazWalkingParaProgresion2 :: TipoBajista -> String -> IO ()
pruHazWalkingParaProgresion2 bajista rutaProg = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                   prog <- leeProgresion rutaProg
                                                   putStr ("\nProgresion de entrada: "++(show prog)++"\n")
                                                   putStr ("\nmusica resultado(sin repeticiones): " ++ show(resAux aleat prog)++"\n")
                                                   --putStr ("\nResultado: "++(show (resul aleat prog))++"\n")
                                                   haskoreAMidi (musicaResul aleat prog) rutaBajo
                                                   putStr ("Escrito midi en "++ rutaBajo ++ "\n")
                                                   where -- resAux aleat prog = snd (hazWalkingParaProgresion (aleat, (Walking,prog, (1%8),2,6,4,2,2)))
                                                         resAux aleat prog = snd (hazWalkingParaProgresion2 (aleat, (bajista,prog, (1%8),2,3,6,5,2)))
                                                         preMus aleat prog = lineSeguro (replicate 3 (resAux aleat prog))
                                                         rutaBajo = "./pruWalkingTotal.mid"
                                                         musicaResul aleat prog = Instr "bass" ((preMus aleat prog))

{-
Muy similar a Melodias.aplicaCurvaMelodicaFase2, lo que hace es alargar UNA SOLA NOTA elegida al azar, sin importar
si tiene un silencio a la derecha o no. Si la nota alargada tuviera una nota no silencio a su derecha entonces DICHA NOTA
NO SILENCIO DESAPARECERIA, "donando" su duracion a la nota alargada
-}
alargaNotasDestructivo  :: FuncAleatoria (Escala, PitchClass, [Music]) [Music]
alargaNotasDestructivo (aleat@(a1:restoAleat1), (escala, tonica, musicaIn))
 | numCand <= 0 = (aleat, musica)
 | otherwise = (restoAleat1, musicaLarga)
      where musica =  limpiaMusica musicaIn
            posCand = dameCandsAlargaNotasDestructivo musica
            numCand = length posCand
            listaPesos = zip posCand [(valoraGrado escala (dameIntervaloPitch tonica (damePitch(musica!!pos))))|pos <- posCand]
            --tienen mas probabilidad de alargarse las notas q corresponden a grados mas estables
            (posElegida, _) = dameElemAleatListaPesos a1 listaPesos
            musicaLarga = alargaMusicaFase2 [posElegida] musica

{-
Dado un music devuelve la lista de posiciones de las notas candidatas a alargarse, contando desde cero en
la lista de musica de entrada. Estas notas candidatas son las que no son silencios sino Note (cumplen esNotaSuena)
-}
dameCandsAlargaNotasDestructivo :: [Music] -> [Int]
dameCandsAlargaNotasDestructivo musica = sacaCandidatosPos 0 musica
        where sacaCandidatosPos _ []     = []
              sacaCandidatosPos _ []     = []
              sacaCandidatosPos _ (_:[]) = [] -- no es candidato pq no tiene ninguna nota a su derecha!!
              sacaCandidatosPos pos (m1:m2:ms)
                | esNotaSuena m1      = pos : (restoCandidatos)
                | otherwise           = restoCandidatos
                              where restoCandidatos = sacaCandidatosPos (pos +1) (m2:ms)



hazMelodiaEntreNotasWalking :: FuncAleatoria (Dur, Int, Int, Int, Int, Int, Escala, Dur, Pitch, Pitch) ([Music])
hazMelodiaEntreNotasWalking (aleat, (durNotas, despCurva, numAlarga, numInter, numTrina, numDivisiones, escala, durTotal, p1@(pc1,o1), p2)) = (restoAleat4, musicaFase4)
    where  aP1 = (absPitch p1)
           aP2 = (absPitch p2)
           distanciaAbs = dameDistanciaEnEscalaPitch escala pc1 p1 p2
           distancia =  if (aP1<= aP2)
                           then distanciaAbs
                           else negate (distanciaAbs)
           curvaIni = [distancia]
           n1 = floor (valorDeFraccion (durTotal/durNotas))
           (numPuntos, caso)  = if durTotal <= durNotas
                                       then (1, 1)
                                       else if ((fromIntegral n1)*durNotas < durTotal)
                                            then (n1 + 1, 2)
                                            else (n1, 3)  -- n1*durNotas == durTotal
           aplicaMutaCurva aleat c n
             | n <= 0 = (aleat, c)
             | otherwise = aplicaMutaCurva restoAlAux curvaAux (n-1)
                             where (restoAlAux, curvaAux) = mutaCurvaMelodica2 (aleat, (despCurva, c))
           (a1:restoAleat1, curvaAux) = aplicaMutaCurva aleat curvaIni (numPuntos - 1)
           curvaDef =  0:(take ((length curvaAux) -1) curvaAux)
           listaGradosPitch = curvaMelodicaAGradosPitch registroDelBajo escala pc1 curvaDef p1
           listaPitch = map snd listaGradosPitch
           listaDurs = case caso of
                          1 -> [durTotal]
                          2 -> listaResul
                               where nuevaDur = durTotal - ((fromIntegral n1)*durNotas)
                                     listaIni = replicate n1 durNotas
                                     candidatos = zip listaIni (replicate n1 1)
                                     (_,posElegidaMasUno) = dameElemAleatListaPesos a1 candidatos
                                     listaResul = insertaSublista (posElegidaMasUno -1) [nuevaDur] listaIni
                          3 -> replicate numPuntos durNotas
           listaNotasIni = zipWith (\p -> \d -> Note p d []) listaPitch listaDurs
           -- y ahora simplemente muta
           tonica = pc1
           repiteAlarga n (aleat, (escala, tonica, musica))
            | n<=0      = (aleat, musica)
            | otherwise = repiteAlarga (n-1) (restoAlAux, (escala, tonica, musAux))
                       where (restoAlAux, musAux) = alargaNotasDestructivo (aleat, (escala, tonica, musica))
           (restoAleat2, musicaFase2) = repiteAlarga numAlarga (restoAleat1,(escala, tonica, listaNotasIni))
           repiteFase3 n (aleat, (escala, tonica, musica))
            | n<=0      = (aleat, musica)
            | otherwise = repiteFase3 (n-1) (restoAlAux, (escala, tonica, musicaAux))
                       where (restoAlAux, musicaAux) = aplicaCurvaMelodicaFase3 (aleat ,(escala, tonica, musica))
           (restoAleat3, musicaFase3) = repiteFase3 numInter (restoAleat2, (escala, tonica, musicaFase2))
           repiteFase4 n (aleat, (numDivisiones,escala, tonica, musica))
            | n<=0      = (aleat, musica)
            | otherwise = repiteFase4 (n-1) (restoAlAux, (numDivisiones, escala, tonica, musicaAux))
                       where (restoAlAux, musicaAux) = aplicaCurvaMelodicaFase4 (aleat ,(numDivisiones,escala, tonica, musica))
           (restoAleat4, musicaFase4) = repiteFase4 numTrina (restoAleat3, (numDivisiones, escala, tonica, musicaFase3))



pruHazMelodiaEntreNotasWalking :: Dur -> Dur -> Int -> Int -> Int -> Int -> Int ->IO ()
pruHazMelodiaEntreNotasWalking durTotal durNotas desp numAlarga numInter numTrina numDivisiones = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                                                                     putStr ("\nmusica resultado(sin repeticiones): " ++ show(resAux aleat)++"\n")
                                                                                                     haskoreAMidi (musicaResul aleat) rutaMusResul
                                                                                                     putStr ("Escrita midi de prueba en "++rutaMusResul++"\n")
                                                                                                     where resAux aleat = snd (hazMelodiaEntreNotasWalking (aleat, (durNotas, desp, numAlarga, numInter, numTrina, numDivisiones, Dorica, durTotal, (D,2), (B,2))))
                                                                                                           preMus aleat = concat (take 4 (repeat (resAux aleat)))
                                                                                                           musicaResul aleat = Instr "bass" (lineSeguro (preMus aleat))
                                                                                                           rutaMusResul = "./pruBajoWalk.mid"




hazMelodiaEntreNotasAphex :: FuncAleatoria (Int, Int, Int, Int,  Escala, Dur, Pitch, Pitch) [Music]
hazMelodiaEntreNotasAphex (aleat, (numMutaIntermedias, numAlarga, numMutaTrino, numDivisiones, escala, dur, pitchPrim@(tonicaPrim,_), pitchSeg@(tonicaSeg,_))) = (restoAleat1, musicaResul)
  where musicaIni = [(Note pitchPrim dur [Volume 50]), (Note pitchSeg (1%4) [Volume 50])] -- la segudna nota es solo
        -- para interpolar alturas, luego se quita y su duracion no importa
        repiteMutar (aleat, (n2,n3,n4,numDivisiones,escala, tonica, musica))
            | n2==0 && n3 ==0 && n4 ==0      = (aleat, musica)
            | otherwise = repiteMutar (restoAlAux, (nn2,nn3,nn4,numDivisiones, escala, tonica, musicaAux))
                       where (restoAlAux, (musicaAux,nn2,nn3,nn4)) = mutaBajoAlMult (aleat ,(n2,n3,n4,numDivisiones,escala, tonica, musica))
        (restoAleat1, musicaAux) = repiteMutar (aleat, (numAlarga, numMutaIntermedias, numMutaTrino, numDivisiones, escala, tonicaPrim, musicaIni))
        musicaResul = take ((length musicaAux) -1) musicaAux

mutaBajoAlMult :: FuncAleatoria (Int,Int,Int,Int, Escala, PitchClass, [Music]) ([Music],Int,Int,Int)
mutaBajoAlMult (aleat@(a1:restoAleat1), (n2,n3,n4,numDivisiones, escala, tonica, musica)) = (restoAl, (musicaMut, nn2,nn3,nn4) )
  where aplicaMut 2 = aplicaCurvaMelodicaFase2 (restoAleat1, (escala, tonica, musica))
        aplicaMut 3 = aplicaCurvaMelodicaFase3 (restoAleat1, (escala, tonica, musica))
        aplicaMut 4 = aplicaCurvaMelodicaFase4 (restoAleat1, (numDivisiones, escala, tonica, musica))
        mayZ x = if (x >0) then 1 else 0
        al3 = a1 `mod` 3
        al2 = a1 `mod` 2
        entradaFormat = (mayZ n2)*100 + (mayZ n3)*10 + (mayZ n4)
        (restoAl, (musicaMut, nn2,nn3,nn4)) = case entradaFormat of
                                              000 -> (aleat, (musica, 0,0,0))
                                              001 -> (fst(aplicaMut 4), (snd(aplicaMut 4), 0,0,n4-1))
                                              010 -> (fst(aplicaMut 3), (snd(aplicaMut 3), 0,n3-1,0))
                                              011 -> case al2 of
                                                        0 -> (fst(aplicaMut 3), (snd(aplicaMut 3), 0,n3-1,0))
                                                        1 -> (fst(aplicaMut 4), (snd(aplicaMut 4), 0,0,n4-1))
                                              100 -> (fst(aplicaMut 2), (snd(aplicaMut 2), n2-1,0,0))
                                              101 -> case al2 of
                                                        0 -> (fst(aplicaMut 2), (snd(aplicaMut 2), n2-1,0,0))
                                                        1 -> (fst(aplicaMut 4), (snd(aplicaMut 4), 0,0,n4-1))
                                              110 -> case al2 of
                                                        0 -> (fst(aplicaMut 2), (snd(aplicaMut 2), n2-1,0,0))
                                                        1 -> (fst(aplicaMut 3), (snd(aplicaMut 3), 0,n3-1,0))
                                              111 -> case al3 of
                                                        0 -> (fst(aplicaMut 2), (snd(aplicaMut 2), n2-1,0,0))
                                                        1 -> (fst(aplicaMut 3), (snd(aplicaMut 3), 0,n3-1,0))
                                                        2 -> (fst(aplicaMut 4), (snd(aplicaMut 4), 0,0,n4-1))

pruHazMelodiaEntreNotasAphex :: Int -> Int -> Int -> Int -> IO ()
pruHazMelodiaEntreNotasAphex numMutaIntermedias numAlarga numMutaTrino numDivisiones = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                                                          --putStr ("\nmusica resultado: " ++ show(musicaResul aleat)++"\n")
                                                                                          putStr ("\nmusica resultado(sin repeticiones): " ++ show(resAux aleat)++"\n")
                                                                                          haskoreAMidi (musicaResul aleat) rutaMusResul
                                                                                          putStr ("Escrita midi de prueba en "++rutaMusResul++"\n")
                                                                                          where resAux aleat = snd (hazMelodiaEntreNotasAphex (aleat, (numMutaIntermedias, numAlarga, numMutaTrino, numDivisiones, Dorica, (4%1), (D, 3), (A,3))))
                                                                                                preMus aleat = concat (take 4 (repeat (resAux aleat)))
                                                                                                -- musicaResul aleat = Instr "bass" (lineSeguro ((resAux aleat)))
                                                                                                musicaResul aleat = Instr "bass" (lineSeguro (preMus aleat))
                                                                                                rutaMus1 = "./pruBajoFase1.mid"
                                                                                                rutaMus2 = "./pruBajoFase2.mid"
                                                                                                rutaMus3 = "./pruBajoFase3.mid"
                                                                                                rutaMusResul = "./pruBajoResul.mid"
                                                                                                --(musicaAux1, musicaAux2, musicaAux3, musicaResul)
