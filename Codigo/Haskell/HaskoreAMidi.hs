-- :load Z:/Haskore/Src/Haskore.hs
-- cambiar fromInt por fromIntegral en Src/Bitops.lhs
module HaskoreAMidi where
import OutputMidi
import HaskToMidi
import Performance

-- OutputMidi: 
-- outputMidiFile :: String -> MidiFile -> IO ()
-- outputMidiFile fn mf = writeBinaryFile fn (midiFileToString mf)

-- HaskToMidi
-- performToMidi :: Performance -> UserPatchMap -> MidiFile

-- Performance
-- perform :: PMap -> Context -> Music -> Performance
-- type PMap    = PName -> Player
-- fancyPlayer :: Player
-- fancyPlayer  = MkPlayer { pName        = "Fancy",
--                           playNote     = defPlayNote defNasHandler,
--                           interpPhrase = fancyInterpPhrase,
--                           notatePlayer = defNotatePlayer ()        }

-- copiado de TestHaskore    test:: Music -> IO ()
-- test     m = outputMidiFile "test.mid" (testMidi m)
-- testMidi :: Music -> MidiFile
-- testMidi m = performToMidi (testPerf m) defUpm
-- testPerf  :: Music -> Performance
-- testPerf m = perform defPMap defCon m
-- defPMap :: String -> Player
-- defPMap pname =
--   MkPlayer pname nf pf sf
--   where MkPlayer _ nf pf sf = fancyPlayer


-- Dada una expersion de tipo musica crea un archivo midi correspondiente a esa música en la ruta (nombre
-- incluido) especificada. Por ahora casi todo son valores por defecto, luego lo ampliaremos
haskoreAMidi :: Music -> String -> IO()
haskoreAMidi musica ruta = outputMidiFile ruta midi
			where midi = performToMidi interpretacion tablaPatchDef 
				where interpretacion = perform tablaInterpretesDef contextoDef musica

tablaInterpretesDef :: String -> Player
tablaInterpretesDef nomInterprete =
   MkPlayer nomInterprete nf pf sf
   where MkPlayer _ nf pf sf = fancyPlayer

tablaPatchDef :: UserPatchMap
tablaPatchDef = [("piano","Acoustic Grand Piano",1),
           ("vibes","Vibraphone",2),
           ("bass","Acoustic Bass",3),
           ("flute","Flute",4),
           ("sax","Tenor Sax",5),
           ("guitar","Acoustic Guitar (steel)",6),
           ("violin","Viola",7),
           ("violins","String Ensemble 1",8),
           ("drums","Acoustic Grand Piano",9)]  
             -- the GM name for drums is unimportant, only channel 9
contextoDef :: Context
contextoDef = Context { cTime   = 0,
		     cPlayer = fancyPlayer,
		     cInst   = "piano",
		     cDur    = metro 150 qn,
		     cKey    = 0,
		     cVol    = 127 }

