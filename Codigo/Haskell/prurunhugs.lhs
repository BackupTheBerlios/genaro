\documentstyle{article}
\begin{document}
\section{Modulo Principal}
\label{principal}

\begin{verbatim} 

> module Main where
> import System

\end{verbatim} 

\begin{verbatim} 

> main :: IO()
> main = do argumentos <- getArgs
>           putStr ("\nLos argumentos son: \n"++(formateaArgs argumentos)++"\n")
>           putStr "Escribiendo argumentos en archivo\n"
>           writeFile "./argumentos.txt" (formateaArgs argumentos)
>           putStr "Proceso terminado correctamente\n"

> formateaArgs :: [String] -> String
> formateaArgs = formateaArgsAcu 1
>                where formateaArgsAcu _ [] = []
>                      formateaArgsAcu n (x:xs) = (show n)++"."++x++"\n"++(formateaArgsAcu (n+1) xs)

\end{verbatim} 


