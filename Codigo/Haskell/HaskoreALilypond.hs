
module HaskoreALilypond ( haskoreALilypond, haskoreALilypondString, cancionDef ) where

import HaskoreAMidi
import Haskore
import Ratio
import Char
import Ratio

-- 'Armadura': especifica la armadura que pondra Lilypond al principio del pentagrama
type Armadura = (PitchClass, Modo)

-- 'Modo': indica si la armadura y la obra esta en modo mayor o menor
data Modo = Mayor | Menor

-- 'Ritmo': ritmo de la obra.
type Ritmo = (Int  -- Numero de notas del compas
             ,Int  -- Resolucion del compas
             )

-- 'Instrumento': Nombre del instrumento que aparecera al principio y a la izquierda de cada pentagrama
type Instrumento = String

-- 'Clave': Clave del pentagrama
data Clave = Sol   -- Clave de 'Sol'
             | Fa  -- Clave de 'Fa'

-- 'Score': Todo lo necesario para definir una linea de pentagrama en Lilypond
type Score = (Music, Armadura, Ritmo, Instrumento, Clave)

-- 'Titulo' de la obra completa
type Titulo = String

-- 'Compositor' de la obra
type Compositor = String

-- 'CancionLy': todo lo necesario para especificar una partitura completa de una obra musica
type CancionLy = (Titulo, Compositor, [Score])

{-
    Cancion con los valores por defecto, para pruebas
-}
cancionDef :: Music -> CancionLy
cancionDef m = ("Musica Genara", "Genaro", [(m, (C, Mayor), (2,4), "Piano", Sol)])

{-
    Escribe una 'CancionLy' en formato de Lilypond en un archivo de texto especificado por 'FilePath'
-}
haskoreALilypond :: CancionLy    -- Cancion a convertir en partitura
                    -> FilePath  -- Ruta del archivo de salida
                    -> IO ()
haskoreALilypond cancionLy archivo = writeFile archivo (haskoreALilypondString cancionLy)


{-
    Traduce una 'CancionLy' a un 'String' en formato Lilypond
-}
haskoreALilypondString :: CancionLy -> String
haskoreALilypondString (titulo, compositor, scores) = cadena
	where cadenaTitulo = "\\header{ title = \"" ++ titulo ++ "\"\ncomposer = \"" ++ compositor ++ "\"}";
	      cadena = cadenaTitulo ++ deScoresALy scores

{-
    Traduce una lista de 'Score' a formato de Lilypond. Se supone que dichos 'Score' son interpretados
    por diferentes instrumentos y todos ellos en paralelo.
-}
deScoresALy :: [Score] -> String
deScoresALy l = "\n<<\n" ++ concat (map ( (++ "}\n") . ("\\new Staff {\n" ++) . deScoreALy) l) ++ ">>"

{-
    Traduce un 'Score' a Lilypond
-}
deScoreALy :: Score -> String
deScoreALy (music, (pC, modo), (num, den), instrumento, clave) = 
	cadenaInstrumento ++ "\n" ++ cadenaArmadura ++ "\n" ++ cadenaRitmo ++ "\n" ++ cadenaClave ++ "\n" ++ cadenaMusic ++ "\n"
	where cadenaMusic       = deMusicALy music;
	      cadenaArmadura    = "\\key " ++ imprimePitchClass pC ++ " \\" ++ imprimeModo modo;
	      cadenaRitmo       = "\\time " ++ show num ++ "/" ++ show den;
	      cadenaClave       = "\\clef " ++ imprimeClave clave
	      cadenaInstrumento = "\\set Staff.instrument = \"" ++ instrumento ++ "\""

{-
    Escribe el 'Modo' en Lilypond
-}
imprimeModo :: Modo -> String
imprimeModo Mayor = "major"
imprimeModo Menor = "minor"

{-
    Escribe la 'Clave'
-}
imprimeClave :: Clave -> String
imprimeClave Sol = "treble"
imprimeClave Fa = "bass"

{-
    Funcion central de la traduccion
-}
deMusicALy :: Music -> String
deMusicALy (Note p dur _) = imprimeNota p dur
deMusicALy (Rest dur)     = "r" ++ show (denominator dur)
--   Cambia el operador secuencia de Haskore por el secuencia de Lilypond
deMusicALy (m1 :+: m2)    = " { " ++ deMusicALy m1 ++ " " ++ deMusicALy m2 ++ " } "
--   Cambia el operador paralelo de Haskore por el paralelo de Lilypond
deMusicALy (m1 :=: m2)    = " << " ++ deMusicALy m1 ++ " " ++ deMusicALy m2 ++ " >> " 
deMusicALy (Tempo d m)    = "\\times " ++ imprimeRatio d ++ " { " ++ deMusicALy m ++ " } "
--   Elimina la constructora 'Trans'
deMusicALy (Trans t m)    = deMusicALy (suma t m)
--   El resto de las constructoras son ignoradas
deMusicALy (Instr _ m)    = deMusicALy m
deMusicALy (Player _ m)   = deMusicALy m
deMusicALy (Phrase _ m)   = deMusicALy m

{-
    'imprimeNota' es cribe una nota en formato Lilypond. En caso de que la duracion de la nota no coincida
    exactamente con una nota simple (una negra, una redonda, etc.) se escriben tantas notas ligadas como 
    hagan falta.
    En realidad, si la duracion de la nota es una fraccion (Ratio Int) escribimos tantas notas ligadas como
    indique el numerador, cada una de ellas de duracion lo que indique el denominador.
-}
imprimeNota :: Pitch -> Dur -> String
imprimeNota p dur = eliminaUltimos 2 (concat [imprimePitch p ++ show (denominator dur) ++ "~ " | i <- [1..numerador] ] )
	where numerador = numerator dur


{-
    Muestra el Ratio Int con el simbolo / en vez del simbolo %
-}
imprimeRatio :: Ratio Int -> String
imprimeRatio r = show (numerator r) ++ "/" ++ show (denominator r)

{-
    Escribe un 'Pitch' teniendo en cuenta la relatividad de Lilypond a la hora de poner las octavas.
    La octava base por defecto de la 3
-}
imprimePitch :: Pitch -> String
imprimePitch (pC, oc) = imprimePitchClass pC ++ imprimeOctava 3 oc -- la octava referencia es la 3

{-
    Imprime una 'PitchClass'.
    El nombre de la nora es la misma que en Haskore pero en minuscula.
    Las alteraciones son "es" para bemol y "is" para sostenidos
-}
imprimePitchClass :: PitchClass -> String
imprimePitchClass pC
	| elem pC [A,B,C,D,E,F,G] = map (toLower) (show pC)               -- Notas sin alteracion
	| elem pC [Af,Bf,Cf,Df,Ef,Ff,Gf] = map (toLower) (show pC1) ++ "es" -- Notas con bemoles
	| elem pC [As,Bs,Cs,Ds,Es,Fs,Gs] = map (toLower) (show pC2) ++ "is" -- Notas con sostenidos
		where   (pC1, _) = pitch (pitchClass pC + 1);
			(pC2, _) = pitch (pitchClass pC - 1)

{-
    Escribe la 'Octave' teniendo en cuenta la octava de referencia (u octava base) pasada como 'Int'
    El simbolo , (coma) indica el numero de octavas por debajo de la base
    El simbolo ' (apostrofe) indice el numero de octavas por encima de la base
    Por defecto la octava base es la 3 (una octava por debajo de la octava del C central)
-}
imprimeOctava :: Int -> Octave -> String
imprimeOctava base oc
	| dif >  0 = [ ','  | i <- [1..dif] ] 
	| dif <  0 = [ '\'' | i <- [1..(-dif)] ]
	| dif == 0 = ""
		where dif = base - oc


{-
    Elimina los n ultimos elementos de una lista
-}
eliminaUltimos :: Int -> [a] -> [a]
eliminaUltimos n l = reverse (drop n (reverse l))


{-
    'suma' suma un numero de semitonos a todas las notas del tipo Music.
    Es util cuando queremos eliminar la constructora 'Trans'
-}
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


-- EJEMPLO: BORRAME EN UN FUTURO NO MUY LEJANO

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

{-
ejemplo :: IO ()
<<<<<<< HaskoreALilypond.hs
ejemplo = haskoreALilypond ("Cancioncilla" , "Genaro", [(musica :+: musica :+: musica :+: musica, (C, Menor), (2,4), "Piano", Sol),(musica :+: musica :+: musica :+: musica, (C, Mayor), (2,4), "Bajo", Fa)]) "./borrame.ly"

ejemplo2 :: IO ()
ejemplo2 = haskoreALilypond ("Cancioncilla" , "Genaro", [(mainVoice, (C, Mayor), (2,4), "Pianillo", Sol)]) "./borrame.ly"=======
ejemplo = haskoreALilypond ("Cancioncilla" , "Genaro", [(musica :+: musica :+: musica :+: musica, (C, Menor), (2,4), "Piano", Sol),(musica :+: musica :+: musica :+: musica, (C, Mayor), (2,4), "Bajo", Fa)]) "./borrame.ly"
>>>>>>> 1.3
-}