
module HaskoreALilypond where

import HaskoreAMidi
import Haskore
import Ratio
import Char
import ChildSong6
import Ratio


negrasMinuto :: Int
negrasMinuto = 120


musica :: Music
musica = Trans 1 (
         ( Note (C, 4) qn [] )  :+: 
	 ( Note (C, 5) qn [] )  :+:
	 ( Note (Cf, 5) qn [] ) :+:
	 ( Rest qn )            :+:
	 ( Note (Cs, 5) qn [] ) :+:
         ( Note (D, 4) qn [] )  :+:
         ( (Note (E, 4) hn [])  :=: (Note (G, 4) qn []) ) :+: 
         ( Note (A, 4) qn [] ) :+:
         ( Note (A, 4) qn [] ) :+:
         ( Note (A, 4) qn [] ) :+:
         ( Tempo (2%3) ((Note (C, 4) qn [] )  :+: 
	               ( Note (C, 5) qn [] )  :+:
	               ( Note (Cf, 5) qn [] ))
         ))


prueba :: IO ()
prueba = haskoreAMidi2 musica negrasMinuto ".//borrame.mid"


deMusicALy :: Music -> String
deMusicALy (Note p dur _) = imprimeNota p dur
deMusicALy (Rest dur)      = "r" ++ show (denominator dur)
deMusicALy (m1 :+: m2)     = " { " ++ deMusicALy m1 ++ " " ++ deMusicALy m2 ++ " } "
deMusicALy (m1 :=: m2)     = " << " ++ deMusicALy m1 ++ " " ++ deMusicALy m2 ++ " >> " 
deMusicALy (Tempo d m)       = "\times " ++ imprimeRatio d ++ " { " ++ deMusicALy m ++ " } "
deMusicALy (Trans t m)       = deMusicALy (suma t m)  -- falta esta por hacer bien
deMusicALy (Instr _ m)       = deMusicALy m
deMusicALy (Player _ m)       = deMusicALy m
deMusicALy (Phrase _ m)       = deMusicALy m


imprimeNota :: Pitch -> Dur -> String
imprimeNota p dur = eliminaUltimos 2 (concat [imprimePitch p ++ show (denominator dur) ++ "~ " | i <- [1..numerador] ] )
	where numerador = numerator dur

imprimeRatio :: Ratio Int -> String
imprimeRatio r = show (numerator r) ++ "/" ++ show (denominator r)


imprimePitch :: Pitch -> String
imprimePitch (pC, oc) = imprimePitchClass pC ++ imprimeOctava 3 oc -- la octava referencia es la 3


imprimePitchClass :: PitchClass -> String
imprimePitchClass pC
	| elem pC [A,B,C,D,E,F,G] = map (toLower) (show pC)               -- Notas sin alteracion
	| elem pC [Af,Bf,Cf,Df,Ef,Ff,Gf] = map (toLower) (show pC1) ++ "es" -- Notas con bemoles
	| elem pC [As,Bs,Cs,Ds,Es,Fs,Gs] = map (toLower) (show pC2) ++ "is" -- Notas con sostenidos
		where   (pC1, _) = pitch (pitchClass pC + 1);
			(pC2, _) = pitch (pitchClass pC - 1)


imprimeOctava :: Int -> Octave -> String
imprimeOctava base oc
	| dif >  0 = [ ','  | i <- [1..dif] ] 
	| dif <  0 = [ '\'' | i <- [1..(-dif)] ]
	| dif == 0 = ""
		where dif = base - oc


eliminaUltimos :: Int -> [a] -> [a]
eliminaUltimos n l = reverse (drop n (reverse l))

suma :: Int -> Music -> Music
suma t (Note p dur l)  = Note pNueva dur l
	where pNueva = pitch (absPitch p + t)
suma t (Rest dur)      = Rest dur
suma t (m1 :+: m2)     = (suma t m1) :+: (suma t m2)
suma t (m1 :=: m2)     = (suma t m1) :=: (suma t m2)
suma t (Tempo d m)     = Tempo d (suma t m)
suma t (Trans t2 m)    = (suma (t+t2) m)
suma t (Instr i m)     = Instr i (suma t m)
suma t (Player pl m)   = Player pl (suma t m)
suma t (Phrase l m)    = Phrase l (suma t m)


