\documentstyle{article}
\begin{document}
\section{Modulo Principal}
\label{principal}

\begin{verbatim} 

> module Main where
> import System
> import BiblioGenaro

\end{verbatim} 

\begin{verbatim} 

> main :: IO()
> main = do argumentos <- getArgs
>           putStr ("\nLos argumentos son: \n"++(formateaArgs argumentos)++"\n")
>           putStr "Escribiendo argumentos en archivo\n"
>           writeFile "./argumentos.txt" (formateaArgs argumentos)
>           putStr "Procesando los argumentos: \n\n" 
>           procesaArgumentos argumentos              
>           putStr "\nProceso terminado correctamente\n"

> formateaArgs :: [String] -> String
> formateaArgs = formateaArgsAcu 1
>                where formateaArgsAcu _ [] = []
>                      formateaArgsAcu n (x:xs) = (show n)++"."++x++"\n"++(formateaArgsAcu (n+1) xs)


> procesaArgumentos :: [String] -> IO()
> procesaArgumentos [nombre] = putStr ("mi tia Pepa se llamaba " ++ nombre ++"\n")
> procesaArgumentos [tia, perro] = putStr ("mi tia Pepa se llamaba " ++ tia ++ ", y su perro se llamaba " ++ perro ++ "\n")
> procesaArgumentos invitados
>       | (length invitados) >= 3 = putStr ("A la fiesta vinieron: \n" ++ (formatInvitados invitados) ++ "\n")
>                                   where formatInvitados = juntaCon "\n"


\end{verbatim} 


