
module ObraCompleta where

import HaskoreALilypond(Armadura, Modo(..)) 
import Haskore
import Ratio
import HaskellAHaskell
import BiblioGenaro 
import HaskoreAMidi
import HaskoreALilypond


type Tempo = Int
type NumeroCompases = Int

type FicheroMusic = String
type Muted = Bool
type Subbloque = (NumeroCompases, FicheroMusic, Muted)

type Instrumento = String
data TipoPista = Melodia | Acompanamiento | Bateria | Bajo
     deriving (Read, Show, Enum, Eq, Ord)
type InfoPista = (ObraCompleta.Instrumento, TipoPista, Muted)

type Pista = ( InfoPista , [Subbloque])


type InfoObraCompleta = (Tempo, Armadura)
type ObraCompleta = (InfoObraCompleta, [Pista])







deObraCompletaAMidi :: FilePath -> ObraCompleta -> IO ()
deObraCompletaAMidi fichDest ((tempo, (pc, Mayor) ), pistas) =
      do musicas <- mapM dePistaAMusic pistas
         haskoreAMidi2 (Trans (pitchClass pc) (chordSeguro musicas)) tempo fichDest
deObraCompletaAMidi _ ((_, (_, Menor) ), _) = error "No tratamos el modo menor"



deSubbloqueAMusic :: Subbloque -> IO Music
deSubbloqueAMusic (n, _, True) = return (Rest (n%1))
deSubbloqueAMusic (_, ficheroMusic, False) = 
      do music <- leeMusic ficheroMusic
         return music


dePistaAMusic :: Pista -> IO Music
dePistaAMusic ((_ , _, True), subbloques) = 
      do musicas <- mapM deSubbloqueAMusic subbloques
         return (Rest (d musicas))
         where d lista = dur (lineSeguro lista)
dePistaAMusic ((instr , _, False), subbloques) =
      do musicas <- mapM deSubbloqueAMusic subbloques
         return (Instr instr (lineSeguro musicas))




{-
Pasa del tipo ObraCompleta a una partitura de lylipond. De momento esta hecho muy por encima
suponiendo ciertos parametros.
-}
deObraCompletaALy :: String -> String -> ObraCompleta -> IO CancionLy
deObraCompletaALy titulo compositor ((_, armadura), pistas) =
      do scores <- mapM (dePistasAScore armadura) pistas
         return (titulo, compositor, scores)

dePistasAScore :: Armadura -> Pista -> IO Score
dePistasAScore armadura pista@((inst, tipo, muted), subbloques) =
     do musica <- dePistaAMusic pista
        return (musica, armadura, (2,4), inst, f tipo)
        where f Melodia = Sol
              f Acompanamiento = Sol
              f Bajo = Fa
              f ObraCompleta.Bateria = HaskoreALilypond.Bateria






-- Ejemplo de Obra completa

obraCompleta :: ObraCompleta
obraCompleta = ((120, (C, Mayor)), [(("piano",Acompanamiento,False),[(9, "./Music_0_0.msc", False)]),
                                    (("violin",Acompanamiento,False),[(9, "./Music_1_0.msc", False)])] )














