
module HaskoreALilypond ( haskoreALilypond, haskoreALilypondString, cancionDef ) where

import HaskoreAMidi
import Haskore
import Ratio
import Char
import ChildSong6
import Ratio


type Armadura = (PitchClass, Modo)
data Modo = Mayor | Menor
type Ritmo = (Int, Int)
type Instrumento = String
data Clave = Sol | Fa
type Score = (Music, Armadura, Ritmo, Instrumento, Clave)

type Titulo = String
type Compositor = String
type CancionLy = (Titulo, Compositor, [Score])

{-
Cancion con los valores por defecto, para pruebas
-}
cancionDef :: Music -> CancionLy
cancionDef m = ("Musica Genara", "Genaro", [(m, (C, Mayor), (2,4), "Piano", Sol)])

haskoreALilypond :: CancionLy -> FilePath -> IO ()
haskoreALilypond cancionLy archivo = writeFile archivo (haskoreALilypondString cancionLy)

haskoreALilypondString :: CancionLy -> String
haskoreALilypondString (titulo, compositor, scores) = cadena
	where cadenaTitulo = "\\header{ title = \"" ++ titulo ++ "\"\ncomposer = \"" ++ compositor ++ "\"}";
	      cadena = cadenaTitulo ++ deScoresALy scores


deScoresALy :: [Score] -> String
deScoresALy l = "\n<<\n" ++ concat (map ( (++ "}\n") . ("\\new Staff {\n" ++) . deScoreALy) l) ++ ">>"


deScoreALy :: Score -> String
deScoreALy (music, (pC, modo), (num, den), instrumento, clave) = 
	cadenaInstrumento ++ "\n" ++ cadenaArmadura ++ "\n" ++ cadenaRitmo ++ "\n" ++ cadenaClave ++ "\n" ++ cadenaMusic ++ "\n"
	where cadenaMusic = deMusicALy music;
	      cadenaArmadura = "\\key " ++ imprimePitchClass pC ++ " \\" ++ imprimeModo modo;
	      cadenaRitmo = "\\time " ++ show num ++ "/" ++ show den;
	      cadenaClave = "\\clef " ++ imprimeClave clave
	      cadenaInstrumento = "\\set Staff.instrument = \"" ++ instrumento ++ "\""

imprimeModo :: Modo -> String
imprimeModo Mayor = "major"
imprimeModo Menor = "minor"

imprimeClave :: Clave -> String
imprimeClave Sol = "treble"
imprimeClave Fa = "bass"


deMusicALy :: Music -> String
deMusicALy (Note p dur _) = imprimeNota p dur
deMusicALy (Rest dur)     = "r" ++ show (denominator dur)
deMusicALy (m1 :+: m2)    = " { " ++ deMusicALy m1 ++ " " ++ deMusicALy m2 ++ " } "
deMusicALy (m1 :=: m2)    = " << " ++ deMusicALy m1 ++ " " ++ deMusicALy m2 ++ " >> " 
deMusicALy (Tempo d m)    = "\\times " ++ imprimeRatio d ++ " { " ++ deMusicALy m ++ " } "
deMusicALy (Trans t m)    = deMusicALy (suma t m)  -- falta esta por hacer bien
deMusicALy (Instr _ m)    = deMusicALy m
deMusicALy (Player _ m)   = deMusicALy m
deMusicALy (Phrase _ m)   = deMusicALy m


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


-- EJEMPLO

musica :: Music
musica = Trans 0 (
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
         ( Tempo (1%1) ((Note (C, 4) qn [] )  :+: 
	               ( Note (C, 5) qn [] )  :+:
	               ( Note (Cf, 5) qn [] ))
         ))


{-
ver en el manual de lilypond \context StaffGroup
-}

ejemplo :: IO ()
ejemplo = haskoreALilypond ("Cancioncilla" , "Genaro", [(musica :+: musica :+: musica :+: musica, (C, Menor), (2,4), "Piano", Sol),(musica :+: musica :+: musica :+: musica, (C, Mayor), (2,4), "Bajo", Fa)]) "./borrame.ly"
