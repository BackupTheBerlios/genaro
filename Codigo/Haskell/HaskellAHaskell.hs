 -- PARSERS BASADOS EN EL ARTICULO: Jeroen Fokker
-- 				 Functional Parsers
--				 in: Johan Jeuring and Erik Meijer (eds.)
--				     Advanced Functional Programming
--				     Fst. Int. School on Advanced Functional Programming Techniques
--				     Tutorial Text
--				     Springer LNCS 925, pp. 1-23, 1995
module HaskellAHaskell where
import Ratio
import Basics
import Parser_library
import Parsers
import BiblioGenaro
import List
import Maybe
import Haskore
import Progresiones      -- Solo para prueba
import PatronesRitmicos      -- Solo para prueba
import TraduceCifrados      -- Solo para prueba
import HaskoreAMidi      -- Solo para prueba

{-
Esta es la funci�n que deben llamar otros modulos, dada una ruta lee el fichero en ella y realiza todo el
analisis
-}
leeMusic :: String -> IO Music
leeMusic ruta = do texto <- readFile ruta
                   return (((aplicaParser parserMusic) . quitaEspacios) texto)

depLeeMusic :: IO()
depLeeMusic = do putStrLn ("Leyendo musica de "++rutaPruMus)
                 texto <- readFile rutaPruMus
                 putStrLn ("Musica leida: "++(show (r texto)))
                 where r texto = parserMusic (quitaEspacios texto)

pruLeeMusic :: IO()
pruLeeMusic = do putStrLn ("Leyendo musica de "++rutaPruMus)
                 musica <- (leeMusic rutaPruMus)
                 putStrLn ("Musica leida: "++(show musica))

rutaPruMus :: String
rutaPruMus = "./musPru.txt"

pruEscribeMusic :: IO()
pruEscribeMusic = do writeFile rutaPruMus (show (musica))
                     where musica = Instr "Piano" (Rest (1 % 2))

pruPitchClass :: IO PitchClass
pruPitchClass = do putStrLn "Dame un pitch class"
                   pcStr <- getLine
                   pc <- readIO pcStr
                   putStrLn ("El pitch class era: " ++ (show pc))
                   return pc

-- type Parser symbol result  =  [symbol] -> [([symbol],result)]

{-
FALTAN Player Y Phrase
-}
parserMusic :: Parser Char Music
parserMusic = foldr genToken parserMusicaBase [composicion]

type OpToken a = (String, a->a->a)
genToken  ::  [OpToken a] -> Parser Char a -> Parser Char a
genToken ops p  =  chainr p (choice (map f ops))
       where  f (s,c) = token s <@ const c

composicion = [(":+:", (:+:)), (":=:", (:=:))]

{-
FALTAN Player Y Phrase
-}
parserMusicaBase :: Parser Char Music
parserMusicaBase =  parserRest
                <|> parserNote
                <|> parserTempo
                <|> parserTrans
                <|> parserInstr
                <|> parenthesized parserMusic

parserInstr :: Parser Char Music
parserInstr = (((token "Instr") *> (token "\"") *> parserAceptaTodo <* (token "\""))  <*> parserMusic)  <@f
       where f (n, m) = Instr n m

parserTrans :: Parser Char Music
parserTrans = ((token "Trans") *> intRec <*> parserMusic) <@f
       where f (s,m) = Trans s m
             intRec = integer
                  <|> parenthesized (intRec)

parserTempo :: Parser Char Music
parserTempo = ((token "Tempo") *> parserDur <*> parserMusic) <@f
       where f (d,m) = Tempo d m

parserRest :: Parser Char Music
parserRest = ((token "Rest") *> parserDur) <@ Rest

parserNote :: Parser Char Music
parserNote = ((token "Note") *> parserPitch <*> parserDur <*> parserListaNoteAttribute) <@f
       where f (p,(d,l)) = Note p d l

parserListaNoteAttribute :: Parser Char [NoteAttribute]
parserListaNoteAttribute = bracketed(commaList(parserNoteAttribute))
{-
CUIDADO QUE SOLO ESTA EL ATRIBUTO VOLUME
-}
parserNoteAttribute :: Parser Char NoteAttribute
parserNoteAttribute = ((token "Volume") *> Parser_library.float) <@ Volume


parserDur :: Parser Char Dur
parserDur = parserRatioARatio
        <|> parenthesized (parserDur)

parserPitch :: Parser Char Pitch
parserPitch = parenthesized(parserPitchClass <*> ((token "," ) *> parserOctava))
          <|> parenthesized (parserPitch)
-- parserAltura = (token "altura") *> parenthesized(numNota <*> ((token "," ) *> octava))

parserOctava :: Parser Char Octave
parserOctava = natural

parserPitchClass :: Parser Char PitchClass
parserPitchClass [str] = retorno
      where listaTokens = map show pitchClassDisponibles
            cand1 = [str]
            resto1 = []
            resul1 = stringAPitchClass cand1
            busca1 = elemIndex cand1 listaTokens
            retorno = if (isJust busca1) --coincide con un token corto
                         then [(resto1, resul1)]
                         else []

parserPitchClass str@(s1:s2:ss) = retorno
      where listaTokens = map show pitchClassDisponibles
            cand1 = take 1 str
            resto1 = drop 1 str
            resul1 = stringAPitchClass cand1
            busca1 = elemIndex cand1 listaTokens
            cand2 = take 2 str
            resto2 = drop 2 str
            resul2 = stringAPitchClass cand2
            busca2 = elemIndex cand2 listaTokens
            retorno = if (isJust busca2)
                         then -- coincide con un token largo => tb con el corto pq es lo mismo sin el "f" o el "s"
                              [(resto2, resul2), (resto1, resul1)]
                         else if (isJust busca1) --coincide con un token corto
                                 then [(resto1, resul1)]
                                 else []

stringAPitchClass :: String -> PitchClass
{-stringAPitchClass str = pitchClassDisponibles !! pos
            where listaTokens = map show pitchClassDisponibles
                  pos = fromJust (elemIndex str listaTokens)
-}
stringAPitchClass "Cf" = Cf
stringAPitchClass "C"  = C
stringAPitchClass "Cs" = Cs
stringAPitchClass "Df" = Df
stringAPitchClass "D"  = D
stringAPitchClass "Ds" = Ds
stringAPitchClass "Ef" = Ef
stringAPitchClass "E"  = E
stringAPitchClass "Es" = Es
stringAPitchClass "Ff" = Ff
stringAPitchClass "F"  = F
stringAPitchClass "Fs" = Fs
stringAPitchClass "Gf" = Gf
stringAPitchClass "G"  = G
stringAPitchClass "Gs" = Gs
stringAPitchClass "Af" = Af
stringAPitchClass "A"  = A
stringAPitchClass "As" = As
stringAPitchClass "Bf" = Bf
stringAPitchClass "B"  = B
stringAPitchClass "Bs" = Bs

pitchClassDisponibles :: [PitchClass]
pitchClassDisponibles = [Cf, C, Cs, Df, D, Ds, Ef, E, Es, Ff, F, Fs, Gf, G, Gs, Af, A, As, Bf, B, Bs]



--- NUEVO CODIGO PARA HACER LEER MUSIC DE UN ARCHIVO MIDI ---------------

leeMusic2 :: FilePath -> IO Music
leeMusic2 fich =
      do midiFile <- loadMidiFile fich
         return (eliminarPrimerInstr (musica midiFile))
         where primer (a, _, _) = a
               musica midiFile = primer (readMidi midiFile)

leeMusic3 :: FilePath -> IO (Music, Context, UserPatchMap)
leeMusic3 fich =
      do midiFile <- loadMidiFile fich
         return (readMidi midiFile)

eliminarPrimerInstr :: Music -> Music
eliminarPrimerInstr (Instr i m) = m
eliminarPrimerInstr m = m



-------- PRUEBA PARA COMPROBAR QUE LA LECTURA MIDI ES CORRECTA -------

progresion :: Progresion
progresion = [((I,Maj7),1%2),((IV,Maj7),1%2),((V,Sept),1%2),((I,Maj7),1%2)]


patronR :: PatronRitmico
patronR = (4, [([(i,100,False) | i<-[1..4]],1%8)])


acordesOrdenados :: [AcordeOrdenado]
acordesOrdenados = traduceProgresion False (Continuo 10 3 4) progresion 

musicaPru :: Music
musicaPru = deAcordesOrdenadosAMusica NoCiclico (Truncar1, Truncar2) patronR acordesOrdenados


laHoraDeLaVerdad :: IO ()
laHoraDeLaVerdad = 
       do haskoreAMidi2 (Tempo 1 (Instr "piano" musicaPru)) 107 "prueba1.mid"
          musicaPru2 <- leeMusic2 "prueba1.mid"
          haskoreAMidi2 (Tempo 1 (Instr "piano" musicaPru2)) 120 "prueba2.mid"
          putStrLn "Primer Music"
          putStrLn (show musicaPru)
          putStrLn "Segundo Music"
          putStrLn (show musicaPru2)
          putStrLn "Son iguales?"
          putStrLn (show (musicaPru==musicaPru2))


laHoraDeLaVerdad2 :: IO ()
laHoraDeLaVerdad2 = 
       do haskoreAMidi2 (Rest (1%4)) 120 "prueba1.mid"
          musicaPru2 <- leeMusic2 "prueba1.mid"
          haskoreAMidi2 musicaPru2 120 "prueba2.mid"
          putStrLn "Primer Music"
          putStrLn ( show (Rest (1%4)) )
          putStrLn "Segundo Music"
          putStrLn (show musicaPru2)
          putStrLn "Son iguales?"
          putStrLn (show ((Rest (1%4))==musicaPru2))








