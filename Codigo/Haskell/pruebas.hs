-- :load Z:/Haskore/Src/Haskore.hs
-- cambiar fromInt por fromIntegral en Src/Bitops.lhs
module Prueba where
import ChildSong6
import TestHaskore
import Haskore

cancioncilla :: Music
cancioncilla = Instr "piano" (Tempo (3%1) (
	(c 4 wn)
	:=: ((qnr) :+: (e a wn))	
	:=: ((qnr) :+: (qnr) :+: (g a wn))
	:=: ((qnr) :+: (qnr) :+: (qnr) :+: (b a wn))
	))

prueba :: IO ()
--prueba = test childSong6
prueba = test cancioncilla

