
module ObraCompleta where

import HaskoreALilypond(Armadura) 


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


{-


deObraCompletaAMidi :: ObraCompleta -> IO ()


deSubbloqueAMusic :: Subbloque -> IO Music
deSubbloqueAMusic (_, False) = 

-}