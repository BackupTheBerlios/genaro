\documentstyle{article}
\begin{document}
\section{Modulo que pasa de un fichero de patron ritmico de C a un midi por defecto}
\label{patronesRitmicosAMidi}

\begin{verbatim}

> module Main where
> import System
> import CAHaskell
> import BiblioGenaro
> import HaskoreAMidi

\end{verbatim}

\begin{verbatim}

Se llama pasando unicamente la ruta absoluta de un fichero de patron ritmico de C y crea un fichero
midi por defecto correspondiente a ese patron ritmico, de mismo nombre que el fichero de patron ritmico
pero con la extensión .mid

> main :: IO()
> main = do [ruta] <- getArgs
>           fichPatRitAMidi ruta


Dada la ruta donde se encuentra un fichero de patron ritmico de C, lo lee y construye un elemento
de tipo Music resultado de asociar a cada fila/voz del patron rítmico correspondiente una nota, empezando
por asociar a la primera voz el Do y siguiendo construyendo la triada de Do mayor, subiendo una octava con cada nota repetida.
A este acorde se le aplica el patron rítmico y se produce la musica, que luego se pasa a midi y se escribe en un archivo con el
mismo nombre que el de partida salvo que su extensión se cambia para que sea .mid

> fichPatRitAMidi :: String -> IO()
> fichPatRitAMidi ruta = do putStr mensajeProcesandoPatronRit
>                           ficheroPatron <- leePatronRitmicoC ruta
>                           putStr mensajeGenerandoMidi
>                           haskoreAMidi (fichPatRitAMusic ficheroPatron) rutaDestinoMidi
>                           where rutaDestinoMidi = cambiaExtension "mid" ruta
>                                 mensajeProcesandoPatronRit = "\n Procesando el archivo de patron ritmico de C: " ++ ruta ++ "\n"
>                                 mensajeGenerandoMidi = "\n Generando el archivo midi: " ++ rutaDestinoMidi ++ "\n"

\end{verbatim}
