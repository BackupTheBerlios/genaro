\documentstyle{article}
\begin{document}
\section{Modulo Principal}
\label{principal}

\begin{verbatim}

Hay q revisar pq importa módulos de más

> module Main where
> import System
> import Directory
> import PatronesRitmicos
> import Progresiones
> import TraduceCifrados
> import HaskoreAMidi
> import CAHaskell
> import PrologAHaskell
> import Basics
> import Parsers
> import Parser_library
> import HaskoreALilypond
> import BiblioGenaro
> import Ratio
> import HaskellAHaskell
> import Melodias
> import ObraCompleta
> import Bateria
> import Bajo


\end{verbatim}

\begin{verbatim}

> rutaProgresion :: String
> rutaProgresion = "./progresion.txt"

> rutaDestinoMidi :: String
> rutaDestinoMidi = "./musica_genara.mid"

> rutaDestinoPartitura :: String
> rutaDestinoPartitura = "./musica_genara.ly"

\end{verbatim}

\begin{verbatim}

Se suponen llamadas del estilo: runhugs main.lhs directorioDeTrabajo rutaPatronRitmico numeroRepeticiones

> main :: IO()
> main = do args <- getArgs
>           mainArgumentos args


> paramEjemplo :: ParametrosTraduceCifrados
> paramEjemplo = Paralelo 4 0 1 4


> {-
> Dada una lista de archivos lee el music que contiene y los pone en secuencia
> -}
> generaPista :: [String] -> IO Music
> generaPista listaArchivos = 
>        do listaMusic <- mapM (leeMusic) listaArchivos
>           return (lineSeguro listaMusic)


Los argumentos son la ruta del patron ritmico (abosoluta o relativa) y el numero de repeticiones del bulcle

> mainArgumentos :: [String] -> IO()
> mainArgumentos (dirTrabajo : restoArgumentos) =
>          do setCurrentDirectory dirTrabajo
>             diferenciaComandos restoArgumentos


> diferenciaComandos :: [String] -> IO()
> diferenciaComandos ( "previsualizaPatron" : restoArgumentos ) = previsualizaPatron restoArgumentos
> diferenciaComandos ( "generaSubbloqueAcompanamiento" : restoArgumentos ) = generaSubbloqueAcompanamiento restoArgumentos
> diferenciaComandos ( "generaSubbloqueSilencio" : restoArgumentos ) = generaSubbloqueSilencio restoArgumentos
> diferenciaComandos ( "generaCurvaMelAleaYMusic" : restoArgumentos ) = generaCurvaMelAleaYMusic restoArgumentos
> diferenciaComandos ( "generaCurvaMelAlea" : restoArgumentos ) = generaCurvaMelAlea restoArgumentos
> diferenciaComandos ( "generaMusicConCurva" : restoArgumentos ) = generaMusicConCurva restoArgumentos
> diferenciaComandos ( "mutaCurva" : restoArgumentos ) = mutaCurva restoArgumentos
> diferenciaComandos ( "mutaCUrvaYMusic" : restoArgumentos ) = mutaCurvaYMusic restoArgumentos
> diferenciaComandos ( "generaObraCompleta" : restoArgumentos ) = generaObraCompleta restoArgumentos
> diferenciaComandos ( "generaLilypond" : restoArgumentos ) = generaLilypond restoArgumentos
> diferenciaComandos ( "generaBateria" : restoArgumentos ) = generaBateria restoArgumentos
> diferenciaComandos _ = errorGenaro "comando erroneo en diferenciaCommandos"



> ------------------------------ PREVISUALIZA PATRON ----------------------------

> previsualizaPatron :: [String] -> IO()
> previsualizaPatron [ rutaPatronRitmico, negras_min, rutaMidiDest ] =
>         do mensajeGenaro "Comienzo lectura de patron"
>            fichPatron <- leePatronRitmicoC rutaPatronRitmico
>            mensajeGenaro "Fin lectura de patron"
>            mensajeGenaro "Comienzo transformacion de subbloque a Midi"
>            haskoreAMidi2 (fichPatRitAMusic fichPatron) negras_min_int rutaMidiDest
>            mensajeGenaro "Fin transformacion de subbloque a Midi"
>            mensajeGenaro "Completado previsualizaPatron"
>            where negras_min_int = aplicaParser integer negras_min
> previsualizaPatron _ = errorGenaro "error de encaje de patrones en previsualizaPatron"             

> ------------------------------ GENERA SUBBLOQUE ACOMPANAMIENTO ----------------------------
> -- NOTA: FALTA DARLE UN VALOR CORRECTO AL FALSE DEL TRADUCE CIFRADO DE ESTA FUNCION
> generaSubbloqueAcompanamiento :: [String] -> IO()
> generaSubbloqueAcompanamiento [rutaProgresion, rutaPatron, "octava", octavaIni, "numero_notas", numNotas, "sistema", "paralelo", "inversion", inversion, "disposicion", disposicion, "horizontal", horizontal, "vertical_mayor", verticalMayor, "vertical_menor", verticalMenor, rutaDest] =
>         do mensajeGenaro "Comienzo lectura progresion"
>            progresion <- leeProgresion rutaProgresion
>            mensajeGenaro "Fin lectura progresion"
>            mensajeGenaro "Comienzo lectura patron"
>            patronR <- leePatronRitmicoC2 rutaPatron
>            mensajeGenaro "Fin lectura patron"
>            --mensajeGenaro "Comienzo escritura del music"
>            --writeFile rutaDest (show (musica progresion patronR))
>            --mensajeGenaro "Fin escritura del music"
>            mensajeGenaro "Comienzo escritura del midi"
>            haskoreAMidi2  (musica progresion patronR) 120 rutaDest
>            mensajeGenaro "Fin escritura del midi"
>            mensajeGenaro "Completado generaSubbloqueAcompanamiento"
>            where octavaIniInt = aplicaParser integer octavaIni 
>                  numNotasInt = aplicaParser integer numNotas
>                  inversionInt = toInversion inversion
>                  disposicionInt = toDisposicion disposicion
>                  ao prog = traduceProgresion False (Paralelo octavaIniInt inversionInt disposicionInt numNotasInt) prog
>                  musica prog patron= deAcordesOrdenadosAMusica (read horizontal) (read verticalMayor, read verticalMenor) (patron) (ao prog)
> generaSubbloqueAcompanamiento [rutaProgresion, rutaPatron, "octava", octavaIni, "numero_notas", numNotas, "sistema", "continuo", "semilla", semilla, "horizontal", horizontal, "vertical_mayor", verticalMayor, "vertical_menor", verticalMenor, rutaDest] = 
>         do mensajeGenaro "Comienzo lectura progresion"
>            progresion <- leeProgresion rutaProgresion
>            mensajeGenaro "Fin lectura progresion"
>            mensajeGenaro "Comienzo lectura patron"
>            patronR <- leePatronRitmicoC2 rutaPatron
>            mensajeGenaro "Fin lectura patron"
>            --mensajeGenaro "Comienzo escritura del music"
>            --writeFile rutaDest (show (musica progresion patronR))
>            --mensajeGenaro "Fin escritura del music"
>            mensajeGenaro "Comienzo escritura del midi"
>            haskoreAMidi2  (musica progresion patronR) 120 rutaDest
>            mensajeGenaro "Fin escritura del midi"
>            mensajeGenaro "Completado generaSubbloqueAcompanamiento "
>            where octavaIniInt = aplicaParser integer octavaIni 
>                  numNotasInt = aplicaParser integer numNotas
>                  semillaInt = aplicaParser integer semilla
>                  ao prog = traduceProgresion False (Continuo semillaInt octavaIniInt numNotasInt) prog
>                  musica prog patron= deAcordesOrdenadosAMusica (read horizontal) (read verticalMayor, read verticalMenor) (patron) (ao prog)
> generaSubbloqueAcompanamiento [rutaProgresion, rutaPatron, "octava", octavaIni, "numero_notas", numNotas, "sistema", "continuo", "nosemilla", "horizontal", horizontal, "vertical_mayor", verticalMayor, "vertical_menor", verticalMenor, rutaDest] = 
>         do mensajeGenaro "Comienzo lectura progresion"
>            progresion <- leeProgresion rutaProgresion
>            mensajeGenaro "Fin lectura progresion"
>            mensajeGenaro "Comienzo lectura patron"
>            patronR <- leePatronRitmicoC2 rutaPatron
>            mensajeGenaro "Fin lectura patron"
>            mensajeGenaro "Comienzo generacion semilla"
>            semillaInt <- numAleatorioIO 1 100        -- No se que numero poner de maximo
>            mensajeGenaro "Fin generacion semilla"
>            --mensajeGenaro "Comienzo escritura del music"
>            --writeFile rutaDest (show (musica progresion patronR semillaInt))
>            --mensajeGenaro "Fin escritura del music"
>            mensajeGenaro "Comienzo escritura del midi"
>            haskoreAMidi2  (musica progresion patronR semillaInt) 120 rutaDest
>            mensajeGenaro "Fin escritura del midi"
>            mensajeGenaro "Completado generaSubbloqueAcompanamiento "
>            where octavaIniInt = aplicaParser integer octavaIni 
>                  numNotasInt = aplicaParser integer numNotas
>                  ao semilla prog = traduceProgresion False (Continuo semilla octavaIniInt numNotasInt) prog
>                  musica prog patron semilla= deAcordesOrdenadosAMusica (read horizontal) (read verticalMayor, read verticalMenor) (patron) (ao semilla prog)
> generaSubbloqueAcompanamiento _ = errorGenaro "error de encaje de patrones en generaSubbloqueAcompanamiento"

> toInversion :: String -> Inversion
> toInversion "Fundamental" = 0
> toInversion "1Inversion" = 1
> toInversion "2Inversion" = 2
> toInversion "3Inversion" = 3

> toDisposicion :: String -> Disposicion
> toDisposicion "1Disposicion" = 1
> toDisposicion "2Disposicion" = 2
> toDisposicion "3Disposicion" = 3
> toDisposicion "4Disposicion" = 4



> ------------------------------ GENERA SUBBLOQUE SILENCIO ---------------------------------
> --DE MOMENTO ESTO NO USAR

> generaSubbloqueSilencio :: [String] -> IO ()
> generaSubbloqueSilencio ["numero_compases", num_comp, "ruta_destino", ruta_dest] = 
>        do mensajeGenaro "Comienzo escritura del music"
>           writeFile ruta_dest (show musica)
>           mensajeGenaro "Fin escritura del music"
>           where num_comp_int = aplicaParser integer num_comp
>                 musica = Rest (num_comp_int % 1)
> generaSubbloqueSilencio _ = errorGenaro "error de encaje de patrones en generaSubbloqueSilencio"



> ------------------------------ DE PISTA A MIDI ---------------------------------

> dePistaAMidi :: [String] -> IO ()
> dePistaAMidi ("ruta_destino" : ruta_dest : "negras_por_minuto" : negras_min : "Instrumento" : i : "lista_de_subbloques" : lista_archivo) =
>       do mensajeGenaro "Comienzo generacion de pistas"
>          musica <- generaPista lista_archivo
>          mensajeGenaro "Fin generacion de pistas"
>          haskoreAMidi2 (Instr i musica) negras_min_int ruta_dest
>          where negras_min_int = aplicaParser integer negras_min
> dePistaAMidi _ = errorGenaro "error de encaje de patrones en dePistaAMidi"



> ------------------------------ GENERA CURVA MELODIA ALEATORIAMENTE ---------------------------------

> generaCurvaMelAlea :: [String] -> IO ()
> generaCurvaMelAlea ["parametros_curva", saltoMax, probSalto, numNotas, "ruta_dest_curva", ruta_dest_curva ] = 
>       do mensajeGenaro "Comienzo generacion de numeros aleatorios"
>          alea <- listaInfNumsAleatoriosIO 1 resolucionRandom
>          mensajeGenaro "Fin generacion de numeros aleatorios"
>          mensajeGenaro "Comienzo escritura del curva"
>          writeFile ruta_dest_curva (show (curva alea))
>          mensajeGenaro "Fin escritura del music"
>          mensajeGenaro "Fin de generacion curva melodia aleatoria"
>          where saltoMax_int = aplicaParser integer saltoMax
>                probSalto_int = aplicaParser integer probSalto
>                numNotas_int = aplicaParser integer numNotas
>                curvaYAlea alea = hazCurvaMelodicaAleat (alea, (saltoMax_int, probSalto_int, numNotas_int))
>                curva alea = snd(curvaYAlea alea)
> generaCurvaMelAlea _ = errorGenaro "error de encaje de patrones en generaCurvaMelAlea"



> ------------------------------ GENERA CURVA MELODIA ALEATORIAMENTE Y MUSIC ---------------------------------

> generaCurvaMelAleaYMusic :: [String] -> IO ()
> generaCurvaMelAleaYMusic ["ruta_progresion", ruta_prog, "ruta_patron" , ruta_patron, "parametros_curva", saltoMax, probSalto, numNotas, numDivisiones, numApsFase2, numApsFase3, numApsFase4, "ruta_dest_music", ruta_dest_music, "ruta_dest_curva", ruta_dest_curva ] = 
>       do mensajeGenaro "Comienzo lectura de progresion"
>          progresion <- leeProgresion ruta_prog
>          mensajeGenaro "Fin lectura progresion"
>          mensajeGenaro "Comienzo lectura patron"
>          patron <- leePatronRitmicoC2 ruta_patron
>          mensajeGenaro "Fin lectura patron"
>          mensajeGenaro "Comienzo generacion de numeros aleatorios"
>          alea <- listaInfNumsAleatoriosIO 1 resolucionRandom
>          mensajeGenaro "Fin generacion de numeros aleatorios"
>          --mensajeGenaro "Comienzo escritura del music"
>          --writeFile ruta_dest_music (show (musica progresion patron alea))
>          --mensajeGenaro "Fin escritura del music"
>          mensajeGenaro "Comienzo escritura del curva"
>          writeFile ruta_dest_curva ((show.concat) (curva progresion patron alea))
>          mensajeGenaro "Fin escritura del music"
>          mensajeGenaro "Comienzo escritura del midi"
>          haskoreAMidi2  (musica progresion patron alea) 120 ruta_dest_music
>          mensajeGenaro "Fin escritura del midi"
>          mensajeGenaro "Fin de generacion curva melodia aleatoria"
>          where saltoMax_int = aplicaParser integer saltoMax
>                probSalto_int = aplicaParser integer probSalto
>                numNotas_int = aplicaParser integer numNotas
>                numDivisiones_int = aplicaParser integer numDivisiones
>                numApsFase2_int = aplicaParser integer numApsFase2
>                numApsFase3_int = aplicaParser integer numApsFase3
>                numApsFase4_int = aplicaParser integer numApsFase4
>                musicYCurvaYAlea prog patron alea = hazMelodiaParaProgresion (alea, (prog, patron, saltoMax_int, probSalto_int, numNotas_int, numDivisiones_int, numApsFase2_int, numApsFase3_int, numApsFase4_int))
>                musicYCurva prog patron alea = snd (musicYCurvaYAlea prog patron alea)
>                musica prog patron alea = fst (musicYCurva prog patron alea)
>                curva prog patron alea = snd (musicYCurva prog patron alea)
> generaCurvaMelAleaYMusic _ = errorGenaro "error de encaje de patrones en generaCurvaMelAleaYMusic"

> ------------------------------ GENERA MUSIC A PARTIR DE CURVA ---------------------------------

> generaMusicConCurva :: [String] -> IO()
> generaMusicConCurva ["ruta_curva", ruta_curva, "ruta_progresion", ruta_prog, "ruta_patron" , ruta_patron, "parametros_curva", numDivisiones, numApsFase2, numApsFase3, numApsFase4, "ruta_dest_music", ruta_dest_music ] = 
>       do mensajeGenaro "Comienzo lectura curva"
>          cadena <- readFile ruta_curva
>          mensajeGenaro "Fin lectura curva"
>          mensajeGenaro "Comienzo lectura progresion"
>          progresion <- leeProgresion ruta_prog
>          mensajeGenaro "Fin lectura progresion"
>          mensajeGenaro "Comienzo lectura patron"
>          patron <- leePatronRitmicoC2 ruta_patron
>          mensajeGenaro "Fin lectura patron"
>          mensajeGenaro "Comienzo creacion numeros aleatorios"
>          alea <- listaInfNumsAleatoriosIO 1 resolucionRandom
>          mensajeGenaro "Fin creacion numeros aleatorios"
>          --mensajeGenaro "Comienzo escritura del music"
>          --writeFile ruta_dest_music (show (musica progresion patron alea cadena))
>          --mensajeGenaro "Fin escritura del music"
>          mensajeGenaro "Comienzo escritura del midi"
>          haskoreAMidi2  (musica progresion patron alea cadena) 120 ruta_dest_music
>          mensajeGenaro "Fin escritura del midi"
>          mensajeGenaro "Fin generacion music con curva"
>          where numDivisiones_int = aplicaParser integer numDivisiones
>                numApsFase2_int = aplicaParser integer numApsFase2
>                numApsFase3_int = aplicaParser integer numApsFase3
>                numApsFase4_int = aplicaParser integer numApsFase4
>                musicYCurvaYAlea prog patron alea cadena = hazMelodiaParaProgresionCurva (alea, (read cadena, prog, patron, numDivisiones_int, numApsFase2_int, numApsFase3_int, numApsFase4_int))
>                musicYCurva prog patron alea cadena = snd (musicYCurvaYAlea prog patron alea cadena)
>                musica prog patron alea cadena = fst (musicYCurva prog patron alea cadena)
>                curva prog patron alea cadena = snd (musicYCurva prog patron alea cadena)
> generaMusicConCurva _ = errorGenaro "error de encaje de patrones en generaMusicConCurva"



> ---------------------------- MUTA UNA CURVA ------------------------------------------------

> mutaCurva :: [String] -> IO ()
> mutaCurva ["ruta_curva", ruta_curva, "numero_mutaciones", num_mut, "desplazamiendo_maximo", desp_max, "ruta_dest", ruta_dest] = 
>       do alea <- listaInfNumsAleatoriosIO 1 resolucionRandom
>          cadena <- readFile ruta_curva
>          writeFile ruta_dest (show (curvaMut cadena alea))
>          where desp_max_int = aplicaParser integer desp_max
>                num_mut_int = aplicaParser integer num_mut
>                curvaMut cadenaCurva alea = mutaCurvaMelodicaNVeces num_mut_int desp_max_int alea (read cadenaCurva)
> mutaCurva _ = errorGenaro "error de encaje de patrones en mutaCurva"

> mutaCurvaMelodicaNVeces :: Int -> Int -> [Int] -> CurvaMelodica -> CurvaMelodica
> mutaCurvaMelodicaNVeces 0 _ _ curva = curva
> mutaCurvaMelodicaNVeces n despMax alea curva = mutaCurvaMelodicaNVeces (n-1) despMax alea2 cabeza
>        where (alea2, cabeza) = mutaCurvaMelodica (alea, (despMax, curva))



> ---------------------------- MUTA CURVA Y ESCRIBE EL MUSIC ------------------------------------------------


> mutaCurvaYMusic :: [String] -> IO ()
> mutaCurvaYMusic ["ruta_curva", ruta_curva, "ruta_prog", ruta_prog, "ruta_patron", ruta_patron, "numero_mutaciones", num_mut, "parametros", numDivisiones, desp_max, numApsFase2, numApsFase3, numApsFase4, "ruta_dest_curva", ruta_dest_curva, "ruta_dest_music", ruta_dest_music] =
>       do alea <- listaInfNumsAleatoriosIO 1 resolucionRandom
>          cadena <- readFile ruta_curva
>          progresion <- leeProgresion ruta_prog
>          patron <- leePatronRitmicoC2 ruta_patron
>          writeFile ruta_dest_curva (show (curvaMut cadena alea))
>          --writeFile ruta_dest_music (show (musica progresion patron alea cadena) )
>          haskoreAMidi2  (musica progresion patron alea cadena) 120 ruta_dest_music
>          where desp_max_int = aplicaParser integer desp_max
>                num_mut_int = aplicaParser integer num_mut
>                numDivisiones_int = aplicaParser integer numDivisiones
>                numApsFase2_int = aplicaParser integer numApsFase2
>                numApsFase3_int = aplicaParser integer numApsFase3
>                numApsFase4_int = aplicaParser integer numApsFase4
>                curvaMut cadenaCurva alea = mutaCurvaMelodicaNVeces num_mut_int desp_max_int alea (read cadenaCurva)
>                musicYCurvaYAlea prog patron alea cadena = hazMelodiaParaProgresionCurva (alea, (read cadena, prog, patron, numDivisiones_int, numApsFase2_int, numApsFase3_int, numApsFase4_int))
>                musicYCurva prog patron alea cadena = snd (musicYCurvaYAlea prog patron alea cadena)
>                musica prog patron alea cadena = fst (musicYCurva prog patron alea cadena)
>                curva prog patron alea cadena = snd (musicYCurva prog patron alea cadena)
> mutaCurvaYMusic _ = errorGenaro "error de encaje de patrones en mutaCurvaYMusic"


> ----------------------- PASA LA OBRA COMPLETA A MIDI --------------------------------

> generaObraCompleta :: [String] -> IO ()
> generaObraCompleta ["archivoGen", archivoGen, "ruta_midi", ruta_dest_midi] =
>        do mensajeGenaro "Comienzo lectura de obra completa"
>           obraCompleta <- leeObraCompleta archivoGen
>           print obraCompleta
>           mensajeGenaro "Fin lectura de obra completa"
>           mensajeGenaro "Comienzo escritura de midi"
>           deObraCompletaAMidi ruta_dest_midi obraCompleta
>           mensajeGenaro "Fin escritura de midi"
> generaObraCompleta _ = errorGenaro "error de encaje de patrones en generaObraCompleta"



> ----------------------- PASA LA OBRA COMPLETA A LILYPOND --------------------------------

> generaLilypond :: [String] -> IO ()
> generaLilypond ["archivoGen", archivoGen, "ruta_ly", ruta_dest_ly] =
>        do mensajeGenaro "Comienzo lectura de obra completa"
>           obraCompleta <- leeObraCompleta archivoGen
>           mensajeGenaro "Fin lectura de obra completa"
>           mensajeGenaro "Comienzo generacion de tipo cancionLy"
>           ly <- deObraCompletaALy "Obra Genara" "Genaro" obraCompleta
>           mensajeGenaro "Fin generacion de tipo cancionLy"
>           mensajeGenaro "Comienzo escritura de partitura lilypond"
>           haskoreALilypond ly ruta_dest_ly
>           mensajeGenaro "Fin escritura de partitura lilypond"
> generaLilypond _ = errorGenaro "error de encaje de patrones en generaObraCompleta"



> ----------------------- GENERA BATERIA --------------------------------------

> generaBateria :: [String] -> IO ()
> generaBateria ["num_compases", num_compases, "patron_ritmico", ruta_patron, "ruta_midi", ruta_dest_midi] = 
>        do mensajeGenaro "Comienzo lectura patron"
>           patron <- leePatronRitmicoC2 ruta_patron
>           mensajeGenaro "Fin lectura patron"
>           mensajeGenaro "Comienzo escritura midi"
>           haskoreAMidi2  (musica patron) 120 ruta_dest_midi
>           mensajeGenaro "Fin escritura midi"
>           where num_compases_int = aplicaParser integer num_compases
>                 musica patron = Instr "Drums" (encajaBateria (num_compases_int%1) patron)
> generaBateria _ = errorGenaro "error de encaje de patrones en generaBateria"


> generaBajo :: [String] -> IO ()
> generaBajo ["progresion", ruta_prog, "parametros", entero1, entero2, entero3, "ruta_midi", ruta_dest_midi] = 
>        do mensajeGenaro "Comienzo lectura progresion"
>           progresion <- leeProgresion ruta_prog
>           mensajeGenaro "Fin lectura progresion"
>           mensajeGenaro "Comienzo generacion numero aleatorios"
>           alea <- listaInfNumsAleatoriosIO 1 resolucionRandom
>           mensajeGenaro "Fin generacion numero aleatorios"
>           mensajeGenaro "Comienzo generacion walking"
>           haskoreAMidi2  (musica progresion int1 int2 int3 alea) 120 ruta_dest_midi
>           mensajeGenaro "Fin generacion walking"
>           mensajeGenaro "Fin de generacion del Bajo"
>           where int1 = aplicaParser integer entero1
>                 int2 = aplicaParser integer entero2
>                 int3 = aplicaParser integer entero3
>                 musica prog int1 int2 int3 alea = snd ( hazWalkingParaProgresion (alea,(prog, int1, int2, int3)) )


> -- BORRAME: PRUEBA LY
> borrame1 :: IO ()
> borrame1 = do setCurrentDirectory "C:/SuperGenaro"
>               generaLilypond ["archivoGen", "C:/SuperGenaro/Fichero_Indice.gen", "ruta_ly", "C:/SuperGenaro/Fichero_Indice.ly"]
> -- BORRAME: PRUEBA BATERIA
> borrame2 :: IO ()
> borrame2 = do setCurrentDirectory "C:/SuperGenaro"
>               generaBateria ["num_compases", "1", "patron_ritmico", "C:/SuperGenaro/PatronesRitmicos/arpegio_6_voces_corcheas.txt", "ruta_midi", "C:/SuperGenaro/Fichero_Indice.mid"]


> {-
> mainArgumentos :: [String] -> IO()
> mainArgumentos [dirTrabajo,rutaPatRit,numReps] = do setCurrentDirectory dirTrabajo
>                                                     putStr (mensajeDirTrabajo dirTrabajo)
>                                                     putStr (mensajeProcesandoProgresion dirTrabajo)
>                                                     progresion <- leeProgresion rutaProgresion
>                                                     putStr mensajeProcesandoPatronRit
>                                                     (FPRC cols resolucion patronRitmico) <- leePatronRitmicoC rutaPatRit
>                                                     putStr (mensajeGenerandoMidi dirTrabajo)
>                                                     putStr (mensajeGenerandoPartitura dirTrabajo)
>                                                     hazMusicaYPartitura ((aplicaParser natural) numReps) progresion patronRitmico
>                                                     where mensajeDirTrabajo dir = "\n El directorio de trabajo es: " ++ dir ++ "\n"
>                                                           rutaAbsProgresion =  (++ "\\" ++ (tail (tail rutaProgresion)))
>                                                           mensajeProcesandoProgresion dirTrabajo = "\n Procesando el archivo de progresion de acordes de Prolog: "++ (rutaAbsProgresion dirTrabajo) ++ "\n"
>                                                           mensajeProcesandoPatronRit = "\n Procesando el archivo de patron ritmico de C: " ++ rutaPatRit++ "\n"
>                                                           rutaAbsArchivoMidi = (++ "\\" ++ (tail (tail rutaDestinoMidi)))
>                                                           mensajeGenerandoMidi dirTrabajo = "\n Generando el archivo midi: " ++ (rutaAbsArchivoMidi dirTrabajo)++ "\n"
>                                                           rutaAbsArchivoPartitura = (++ "\\" ++ (tail (tail rutaDestinoPartitura)))
>                                                           mensajeGenerandoPartitura dirTrabajo = "\n Generando el archivo de partitura lilypond: " ++ (rutaAbsArchivoPartitura dirTrabajo)++ "\n"
> -}


> hazMusicaYPartitura :: Int -> Progresion -> PatronRitmico -> IO()
> hazMusicaYPartitura numReps prog patRit = do haskoreAMidi musica rutaDestinoMidi
>                                              writeFile rutaDestinoPartitura partitura
>                                              where progOrd =  traduceProgresion False paramEjemplo
>                                                    hazMusicaFase1 prog patRit = deAcordesOrdenadosAMusica NoCiclico (Truncar1 , Truncar2) patRit (progOrd prog)
>                                                    hazMusica prog patRit = line (take numReps (repeat (hazMusicaFase1 prog patRit)))
>                                                    musica = hazMusica prog patRit
>                                                    partitura = haskoreALilypondString (cancionDef musica)

\end{verbatim}
