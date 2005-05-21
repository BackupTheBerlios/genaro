
module ObraCompleta where

--import HaskoreALilypond(Armadura, CancionLy, Score, Clave)
import HaskoreALilypond
import Parsers
import Parser_library
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
data TipoPista = Melodia | Acompanamiento | Bateria | Bajo
     deriving (Read, Show, Enum, Eq, Ord)
type InfoPista = (ObraCompleta.Instrumento, TipoPista, Muted)

type Pista = ( InfoPista , [Subbloque])


type InfoObraCompleta = (Tempo, Armadura)
type ObraCompleta = (InfoObraCompleta, [Pista])

----------------PARSER DE FICHEROS .GEN ---------------------------------------
{-
FICHERO DE EJEMPLO
Pistas: 2
N 0
Bloques 1 Tipo Acompanamiento Mute 0 Instrumento 0
bloque 0
Compases 9 vacio 0 Tipo_Music 13 Music_0_0.msc FINBLOQUE
FINPISTA
N 1
Bloques 1 Tipo Melodia Mute 0 Instrumento 0
bloque 0
Compases 9 vacio 0 Tipo_Music 13 Music_1_0.msc FINBLOQUE
FINPISTA
FINCANCION
-}

{-
parserObraCompleta = USAR . quitaFormatoDOS!!!!
-}

{-parserObraCompleta :: Parser Char ObraCompleta
parserObraCompleta =
         where info = (100, (C, Mayor))
-}
parserPista :: Parser Char Pista
parserPista = (parserInfoPista <*> subbloques) <* (token "FINBLOQUE\n")
      where subbloques = listaSeparadaString "FINBLOQUE\n" parserSubbloque
           -- type Pista = ( InfoPista , [Subbloque])

parserInfoPista :: Parser Char InfoPista
parserInfoPista = infoPista
             where inicio = (token "N") <*> espacio <*> natural <*> saltoDLinea
                   bloques = (token "Bloques") <*> espacio <*> natural <*> espacio
                   tipo = ((((token "Tipo") <*> espacio) *> parserAceptaTodo) <* espacio) <@ read
                   muted = ((((token "Mute") <*> espacio) *> natural) <* espacio) <@ (>0)
                   instrumento = ((((token "Instrumento") <*> espacio) *> natural) <* saltoDLinea) <@ intAInst
                           where intAInst _ = "piano"
                   infoPista = ((((inicio <*> bloques) *> tipo) <*> muted) <*> instrumento) <@(\((t, m),i)->(i,t,m))
                   --(((inicio <*> bloques) *> tipo) <*> muted <*> instrumento) -- <@ (\((t, m),i)->(i,t,m))
              -- type InfoPista = (Instrumento, TipoPista, Muted)
              -- data TipoPista = Melodia | Acompanamiento | Bateria

parserSubbloque :: Parser Char Subbloque
parserSubbloque = (((((inicio *> numComp) <*> muteo) <* intermedio) <*> nombreFich)) <@ formatea
                  where inicio = (token "bloque") <*> espacio <*> natural <*> saltoDLinea
                        numComp = (((token "Compases") <*> espacio) *> natural) <* espacio
                        muteo = (((token "vacio") <*> espacio) *> natural) <* espacio
                        intermedio = (token "Tipo_Music") <*> espacio <*> natural <*> espacio
                        nombreFich = parserNoSalto <* espacio
                        --fin = token "FINBLOQUE"
                        formatea ((nc, mute), nf) = (nc, nf, mute>0)
                        -- type Subbloque = (NumeroCompases, FicheroMusic, Muted)






deObraCompletaAMidi :: FilePath -> ObraCompleta -> IO ()
deObraCompletaAMidi fichDest ((tempo, (pc, Mayor) ), pistas) =
      do musicas <- mapM dePistaAMusic pistas
         haskoreAMidi2 (Trans (pitchClass pc) (chordSeguro musicas)) tempo fichDest
deObraCompletaAMidi _ ((_, (_, Menor) ), _) = error "No tratamos el modo menor"



deSubbloqueAMusic :: Subbloque -> IO Music
-- deSubbloqueAMusic (_, False) =
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

