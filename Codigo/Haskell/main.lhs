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

Los argumentos son la ruta del patron ritmico (abosoluta o relativa) y el numero de repeticiones del bulcle

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



> hazMusicaYPartitura :: Int -> Progresion -> PatronRitmico -> IO()
> hazMusicaYPartitura numReps prog patRit = do haskoreAMidi musica rutaDestinoMidi
>                                              writeFile rutaDestinoPartitura partitura
>                                              where progOrd =  traduceProgresion paramEjemplo
>                                                    hazMusicaFase1 prog patRit = deAcordesOrdenadosAMusica NoCiclico (Truncar1 , Truncar2) patRit (progOrd prog)
>                                                    hazMusica prog patRit = line (take numReps (repeat (hazMusicaFase1 prog patRit)))
>                                                    musica = hazMusica prog patRit
>                                                    partitura = haskoreALilypondString (cancionDef musica)

\end{verbatim}
