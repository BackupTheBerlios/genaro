\documentstyle{article}
\begin{document}
\section{Modulo Principal}
\label{principal}

\begin{verbatim}

Hay q revisar pq importa módulos de más

> module Main where
> import System
> import PrologAMidi
> import Directory
> import Progresiones
> import PatronesRitmicos
> import TraduceCifrados
> import HaskoreAMidi
> import CAHaskell
> import PrologAHaskell
> import qualified BiblioGenaro
> import Ratio	--para ejemplo
> import Basics	--para mainDtPatNum, q deberia ir en otro lado las cosas q hace
> import Parsers
> import Parser_library

\end{verbatim}

\begin{verbatim}

> rutaProgresion :: String
> rutaProgresion = "../../progresion.txt"

> rutaPatronRitmico :: String
> rutaPatronRitmico = "../../PatronesRitmicos/patron_ritmico.txt"

> rutaDestinoMidi :: String
> rutaDestinoMidi = "../../musica_genara.mid"

\end{verbatim}

\begin{verbatim}

Se suponen llamadas del estilo: runhugs main.lhs rutaAbsolutaPatronRitmico numeroRepeticiones
,el directorio de trabajo siempre es el directorio desde donde se llama a runhugs

> main :: IO()
> main = do args <- getArgs
>           mainArgumentos (rutaPatRit args) (numReps args)
>           where rutaPatRit = head
>                 numReps = (aplicaParser natural) . head . tail
>
>           --mainArgumentos (formateaArgumentos argumentos)
>           --where formateaArgumentos [ruta,numReps] = \

> paramEjemplo :: ParametrosTraduceCifrados
> paramEjemplo = Paralelo 4 0 1 4

Los argumentos son la ruta absoluta del patron ritmico y el numero de repeticiones del bulcle

> mainArgumentos :: String -> Int -> IO()
> mainArgumentos rutaPatRit numReps = do dirTrabajo <- getCurrentDirectory
>                                        putStr (mensajeDirTrabajo dirTrabajo)
>                                        putStr (mensajeProcesandoProgresion dirTrabajo)
>                                        progresion <- leeProgresion rutaProgresion
>                                        putStr mensajeProcesandoPatronRit
>                                        (FPRC cols resolucion patronRitmico) <- leePatronRitmicoC rutaPatRit
>                                        putStr (mensajeGenerandoMidi dirTrabajo)
>                                        haskoreAMidi (hazMusica progresion patronRitmico) rutaDestinoMidi
>                                        where  mensajeDirTrabajo dir = "\n El directorio de trabajo es: " ++ dir ++ "\n"
>                                               rutaAbsProgresion =  (++ "\\" ++ (tail (tail rutaProgresion)))
>                                               mensajeProcesandoProgresion dirTrabajo = "\n Procesando el archivo de progresion de acordes de Prolog: "++ (rutaAbsProgresion dirTrabajo) ++ "\n"
>                                               mensajeProcesandoPatronRit = "\n Procesando el archivo de patron ritmico de C: " ++ rutaPatRit++ "\n"
>                                               rutaAbsArchivoMidi = (++ "\\" ++ (tail (tail rutaDestinoMidi)))
>                                               mensajeGenerandoMidi dirTrabajo = "\n Generando el archivo midi: " ++ (rutaAbsArchivoMidi dirTrabajo)++ "\n"
>                                               progOrd =  traduceProgresion paramEjemplo
>                                               hazMusicaFase1 prog patRit = deAcordesOrdenadosAMusica NoCiclico (Truncar1 , Truncar2) patRit (progOrd prog)
>                                               hazMusica prog patRit = line (take numReps (repeat (hazMusicaFase1 prog patRit)))



\end{verbatim}
