-- :load Z:/Haskore/Src/Haskore.hs
-- cambiar fromInt por fromIntegral en Src/Bitops.lhs
module Prueba where
import TestHaskore
import Haskore
import Basics
import Ratio

cancioncilla :: Music
cancioncilla = Instr "piano" (Tempo (3%1) (
	(c 4 wn [])
	:=: (qnr :+: (e 4 wn []))	
	:=: (qnr :+: qnr :+: (g 4 wn []))
	:=: (qnr :+: qnr :+: qnr :+: (b 4 wn []))
	))



prueba :: IO ()
prueba = test cancioncilla

