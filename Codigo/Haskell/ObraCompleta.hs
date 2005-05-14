
module ObraCompleta where

import HaskoreALilypond(Armadura, Modo(..)) 
import Haskore
import Ratio
import HaskellAHaskell
import BiblioGenaro 
import HaskoreAMidi


type Tempo = Int
type NumeroCompases = Int

type FicheroMusic = String
type Muted = Bool
type Subbloque = (NumeroCompases, FicheroMusic, Muted)

type Instrumento = String
data TipoPista = Melodia | Acompanamiento | Bateria
     deriving (Read, Show, Enum, Eq, Ord)
type InfoPista = (Instrumento, TipoPista, Muted)

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

















