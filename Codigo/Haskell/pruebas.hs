-- :load Z:/Haskore/Src/Haskore.hs
-- cambiar fromInt por fromIntegral en Src/Bitops.lhs
module Prueba where
import ChildSong6
import TestHaskore

-- cancioncilla :: Music
cancioncilla = Instr "piano" (Tempo 3 1 (
	(c 4 wn)
	:=: ((qn r) :+: (e a wn))	
	:=: ((qn r) :+: (qn r) :+: (g a wn))
	:=: ((qn r) :+: (qn r) :+: (qn r) :+: (b a wn))
	))

prueba :: IO ()
--prueba = test childSong6
prueba = test cancioncilla