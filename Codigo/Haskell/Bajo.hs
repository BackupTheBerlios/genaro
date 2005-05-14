module Bajo where
--import List
import Basics
import BiblioGenaro
import Progresiones
import Escalas
import Melodias
import HaskoreAMidi
--import PatronesRitmicos
--import Maybe
--import PrologAHaskell --para pruebas
import Ratio          --para pruebas
--import Directory      --para pruebas
--import CAHaskell      --para pruebas solo??????????
--import TraduceCifrados --para pruebas

{-
hazWalkingAleatorio :: FuncAleatoria
hazWalkingAleatorio (aleat, ())
-}
{-
hazMelodiaEntreNotas :: FuncAleatoria (Int, Int, Int, Int,  Escala, Dur, Pitch, Pitch) ([Music], [Music], [Music], [Music])
hazMelodiaEntreNotas (aleat, (numMutaIntermedias, numAlarga, numMutaTrino, numDivisiones, escala, dur, pitchPrim@(tonicaPrim,_), pitchSeg@(tonicaSeg,_))) = (restoAleat1, (musicaAux1, musicaAux2, musicaAux3, musicaResul))
--hazMelodiaEntreNotas (aleat, numAlarga) = (restoAleat1, musicaResul)--(restoAleat1, (musicaAux1, musicaAux2, musicaAux3, musicaResul))
  where --(numMutaIntermedias, numMutaTrino, numDivisiones, escala, pitchPrim, pitchSeg2) = (1,1,1,Jonica, (C,0),(C,0))
        --(tonicaPrim,_) = pitch (gradoAIntAbs gPrim + 0)
        --(tonicaSeg,_) = pitch (gradoAIntAbs gSeg + 0)
        --escala = escalaDelAcorde cifPrimero
        musicaIni = [(Note pitchPrim dur [Volume 50]), (Note pitchSeg (1%4) [Volume 50])]
        repiteFase2 n (aleat, (escala, tonica, musica))
            | n<=0      = (aleat, musica)
            | otherwise = repiteFase2 (n-1) (restoAlAux, (escala, tonica, musAux))
                       where (restoAlAux, musAux) = aplicaCurvaMelodicaFase2 (aleat, (escala, tonica, musica))
        repiteFase3 n (aleat, (escala, tonica, musica))
            | n<=0      = (aleat, musica)
            | otherwise = repiteFase3 (n-1) (restoAlAux, (escala, tonica, musicaAux))
                       where (restoAlAux, musicaAux) = aplicaCurvaMelodicaFase3 (aleat ,(escala, tonica, musica))
        repiteFase4 n (aleat, (numDivisiones,escala, tonica, musica))
            | n<=0      = (aleat, musica)
            | otherwise = repiteFase4 (n-1) (restoAlAux, (numDivisiones, escala, tonica, musicaAux))
                       where (restoAlAux, musicaAux) = aplicaCurvaMelodicaFase4 (aleat ,(numDivisiones,escala, tonica, musica))
        -- aplica primero la fase 3 para poner notas en medio, luego la 2 para alargar y por ultimo la 4 para poner trinos
        (restoAleat1, musicaAux1) = repiteFase3 numMutaIntermedias (aleat, (escala, tonicaPrim, musicaIni))
        (restoAleat2, musicaAux2) = repiteFase2 numAlarga (restoAleat1,(escala, tonicaPrim, musicaAux1))
        (restoAleat3, musicaAux3) = repiteFase4 numMutaTrino (restoAleat2, (numDivisiones, escala, tonicaPrim, musicaAux2))
        musicaResul = take ((length musicaAux3) -1) musicaAux3
-}

hazMelodiaEntreNotas :: FuncAleatoria (Int, Int, Int, Int,  Escala, Dur, Pitch, Pitch) [Music]
hazMelodiaEntreNotas (aleat, (numMutaIntermedias, numAlarga, numMutaTrino, numDivisiones, escala, dur, pitchPrim@(tonicaPrim,_), pitchSeg@(tonicaSeg,_))) = (restoAleat1, musicaResul)
--hazMelodiaEntreNotas (aleat, numAlarga) = (restoAleat1, musicaResul)--(restoAleat1, (musicaAux1, musicaAux2, musicaAux3, musicaResul))
  where musicaIni = [(Note pitchPrim dur [Volume 50]), (Note pitchSeg (1%4) [Volume 50])]
        repiteMutar (aleat, (n2,n3,n4,numDivisiones,escala, tonica, musica))
            | n2==0 && n3 ==0 && n4 ==0      = (aleat, musica)
            | otherwise = repiteMutar (restoAlAux, (nn2,nn3,nn4,numDivisiones, escala, tonica, musicaAux))
                       where (restoAlAux, (musicaAux,nn2,nn3,nn4)) = mutaBajoAlMult (aleat ,(n2,n3,n4,numDivisiones,escala, tonica, musica))
        (restoAleat1, musicaAux) = repiteMutar (aleat, (numAlarga, numMutaIntermedias, numMutaTrino, numDivisiones, escala, tonicaPrim, musicaIni))
        musicaResul = take ((length musicaAux) -1) musicaAux

mutaBajoAl :: FuncAleatoria (Int, Escala, PitchClass, [Music]) [Music]
mutaBajoAl (aleat@(a1:restoAleat1), (numDivisiones, escala, tonica, musica)) = resul
  where aplicaMut 0 = aplicaCurvaMelodicaFase2 (restoAleat1, (escala, tonica, musica))
        aplicaMut 1 = aplicaCurvaMelodicaFase3 (restoAleat1, (escala, tonica, musica))
        aplicaMut 2 = aplicaCurvaMelodicaFase4 (restoAleat1, (numDivisiones, escala, tonica, musica))
        mutacion =  a1 `mod` 3
        resul = aplicaMut mutacion


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


pepeLu :: Int -> Int -> Int
pepeLu n1 n2 = case (n1, n2) of
                  (0,0) -> 2
                  (1,_) -> 4
                  (_,1) -> 3

pruHazMelodiaEntreNotas :: Int -> Int -> Int -> Int -> IO ()
pruHazMelodiaEntreNotas numMutaIntermedias numAlarga numMutaTrino numDivisiones = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                                                     putStr ("\nmusica resultado: " ++ show(musicaResul aleat)++"\n")
                                                                                     haskoreAMidi (musicaResul aleat) rutaMusResul
                                                                                     putStr ("Escrita midi de prueba en "++rutaMusResul++"\n")
                                                                                     where resAux aleat = snd (hazMelodiaEntreNotas (aleat, (numMutaIntermedias, numAlarga, numMutaTrino, numDivisiones, Jonica, (4%1), (C, 3), (E,3))))
                                                                                           musicaResul aleat = Instr "bass" (lineSeguro ((resAux aleat)))
                                                                                           rutaMus1 = "./pruBajoFase1.mid"
                                                                                           rutaMus2 = "./pruBajoFase2.mid"
                                                                                           rutaMus3 = "./pruBajoFase3.mid"
                                                                                           rutaMusResul = "./pruBajoResul.mid"
                                                                                            --(musicaAux1, musicaAux2, musicaAux3, musicaResul)

{-
pruHazMelodiaEntreNotas :: Int -> Int -> Int -> Int -> IO ()
pruHazMelodiaEntreNotas numMutaIntermedias numAlarga numMutaTrino numDivisiones = do aleat <- listaInfNumsAleatoriosIO 1 resolucionRandom
                                                                                     putStr ("\nmusica tras notas intermedias: " ++ show(musicaAux1 aleat)++"\n")
                                                                                     haskoreAMidi (musicaAux1 aleat) rutaMus1
                                                                                     putStr ("Escrita midi de prueba en "++rutaMus1++"\n")
                                                                                     putStr ("\nmusica tras alargar notas: " ++ show(musicaAux2 aleat)++"\n")
                                                                                     haskoreAMidi (musicaAux2 aleat) rutaMus2
                                                                                     putStr ("Escrita midi de prueba en "++rutaMus2++"\n")
                                                                                     putStr ("\nmusica tras meter trinos: " ++ show(musicaAux3 aleat)++"\n")
                                                                                     haskoreAMidi (musicaAux3 aleat) rutaMus3
                                                                                     putStr ("Escrita midi de prueba en "++rutaMus3++"\n")
                                                                                     putStr ("\nmusica resultado: " ++ show(musicaResul aleat)++"\n")
                                                                                     haskoreAMidi (musicaResul aleat) rutaMusResul
                                                                                     putStr ("Escrita midi de prueba en "++rutaMusResul++"\n")
                                                                                     where resAux aleat = snd (hazMelodiaEntreNotas (aleat, (numMutaIntermedias, numAlarga, numMutaTrino, numDivisiones, Jonica, (4%1), (C, 3), (E,3))))
                                                                                           musicaAux1 aleat = lineSeguro (prim4 (resAux aleat))
                                                                                           musicaAux2 aleat = lineSeguro (seg4 (resAux aleat))
                                                                                           musicaAux3 aleat = lineSeguro (terc4 (resAux aleat))
                                                                                           musicaResul aleat = Instr "bass" (lineSeguro (cuat4 (resAux aleat)))
                                                                                           rutaMus1 = "./pruBajoFase1.mid"
                                                                                           rutaMus2 = "./pruBajoFase2.mid"
                                                                                           rutaMus3 = "./pruBajoFase3.mid"
                                                                                           rutaMusResul = "./pruBajoResul.mid"
                                                                                            --(musicaAux1, musicaAux2, musicaAux3, musicaResul)
  -}
--(aleat, (numAlarga, numMutaIntermedias, numMutaTrino, (cifPrimero@(gPrim,matPrim), dPrim), (cifPrimero@(gSeg,matSeg), dSeg))) = (restoAleat1, (musicaAux1, musicaAux2, musicaAux3, musicaResul))