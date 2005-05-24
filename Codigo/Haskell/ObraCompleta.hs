
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
import GeneralMidi

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

Pistas: 2
Tempo: 100
Tonalidad: C
N 0
Bloques 1 Tipo Acompanamiento Mute 0 Instrumento 0
bloque 0
Compases 3 vacio 0 Tipo_Music 13 Music_0_0.mid FINBLOQUE
FINPISTA
N 1
Bloques 1 Tipo Acompanamiento Mute 0 Instrumento 0
bloque 0
Compases 3 vacio 0 Tipo_Music 13 Music_1_0.mid FINBLOQUE
FINPISTA
FINCANCION

-}

leeObraCompleta :: String -> IO ObraCompleta
leeObraCompleta ruta =
       do texto <- readFile ruta
          return (aplicaParser parserObraCompleta (quitaFormatoDOS texto))
{-
parserObraCompleta = USAR . quitaFormatoDOS!!!!
-}
parserObraCompleta :: Parser Char ObraCompleta
parserObraCompleta = ((ini <*> listaPistas) <* fin) <@ formatea
         where ini = ini1 *> (ini2 <*> ini3)
               ini1 = (token "Pistas: ") <*> natural <*> saltoDLinea
               ini2 = (token "Tempo: ") *> natural <* saltoDLinea
               ini3 = (token "Tonalidad: ") *> parserPicthClass <* saltoDLinea
               listaPistas = (listaSeparadaString "FINPISTA\n" parserPista) <* (token "FINPISTA\n")
               fin = token "FINCANCION\n"
               formatea ((temp, tono),l) = ((temp, (tono, Mayor)), l)

parserPicthClass :: Parser Char PitchClass
parserPicthClass = listaParesTokenDatoAParser listaPares
   where listaPares = [("Cb",Cf), ("C", C), ("C#",Cs), ("Db",Df), ("D",D), ("D#",Ds), ("Eb",Ef),("E", E),("E#", Es)
                      ,("Fb", Ff),("F", F), ("F#",Fs), ("Gb",Gf), ("G",G), ("G#",Gs), ("Ab",Af), ("A",A), ("A#",As)
                      ,("Bb", Bf),("B", B), ("B#",Bs)]

parserPista :: Parser Char Pista
parserPista = (parserInfoPista <*> subbloques) <* (token "FINBLOQUE\n")
      where subbloques = listaSeparadaString "FINBLOQUE\n" parserSubbloque
           -- type Pista = ( InfoPista , [Subbloque])

{-
data TipoPista = Melodia | Acompanamiento | Bateria | Bajo
     deriving (Read, Show, Enum, Eq, Ord)
-}
parserTipoPista :: Parser Char TipoPista
parserTipoPista = listaParesTokenDatoAParser listaPares
       where listaTipos = [Melodia, Acompanamiento,  ObraCompleta.Bateria, Bajo]
             listaPares = map (\x -> (show x, x)) listaTipos

parserInfoPista :: Parser Char InfoPista
parserInfoPista = infoPista
             where inicio = (token "N") <*> espacio <*> natural <*> saltoDLinea
                   bloques = (token "Bloques") <*> espacio <*> natural <*> espacio
                   tipo = (((token "Tipo") <*> espacio) *> parserTipoPista) <* espacio
                   muted = ((((token "Mute") <*> espacio) *> natural) <* espacio) <@ (>0)
                   instrumento = ((((token "Instrumento") <*> espacio) *> natural) <* saltoDLinea) <@ intAInst
                           where intAInst n = fst (genMidiMap !! n)
                   infoPista = ((((inicio <*> bloques) *> tipo) <*> muted) <*> instrumento) <@(\((t, m),i)->(i,t,m))

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
         print (chordSeguro musicas)
         haskoreAMidi2 (Trans (pitchClass pc) (chordSeguro musicas)) tempo fichDest
deObraCompletaAMidi _ ((_, (_, Menor) ), _) = error "No tratamos el modo menor"



deSubbloqueAMusic :: Subbloque -> IO Music
-- deSubbloqueAMusic (_, False) =
deSubbloqueAMusic (n, _, True) =
      do print (Rest (n%1))
         return (Rest (n%1))
deSubbloqueAMusic (_, ficheroMusic, False) =
      do musica <- leeMusic2 ficheroMusic
         print musica
         return musica


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

