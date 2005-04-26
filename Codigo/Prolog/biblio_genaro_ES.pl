%DECLARACION DEL MODULO
:- module(biblio_genaro_ES,[escribeTermino/2,leeTermino/2]).

%BIBLIOTECAS
:- ensure_loaded(library(system)).
%:- use_module(library(system)).



/**
* escribeTermino(+NombreArchivo, +Termino)
* escribe Termino en el archivo de nombre NombreArchivo (q debe ser string), dentro
* del directorio actual
* @param +NombreArchivo Es el nombre del archivo en que queremos que se guarde el termino Termino. El nombre
*  				debe ser un string, es decir, debe ir delimitado por comillas simples
* @param +Termino		Termido que se desea escribir
*/
escribeTermino(NombreArchivo, Termino) :-
	open(NombreArchivo, write,Stream, [type(text)]),
	write(Stream, Termino),
        write(Stream, '.'),
	close(Stream).


/**
* leeTermino( +NombreArchivo, -Termino)
* lee Termino en el archivo de nombre NombreArchivo (q debe ser string o un atomo), dentro
* del directorio actual.
* Importante: El termino del archivo tiene que terminar en un punto
*/
leeTermino( NombreArchivo, Termino ) :- 
         open( NombreArchivo, read, Stream, [type(text)] )
        ,read(Stream, Termino)
        ,close(Stream).


/*
DIRECTORIO DE TRABAJO:
working_directory(-Old, +New)
    Unify Old with an absolute path to the current working directory and change working directory to New.
    Use the pattern working_directory(CWD, CWD) to get the current directory.

-obtener cual es el directorio de trabajo actual:  working_directory(Wd,Wd).
-cambiar el directorio de trabajo: working_directory(_,'c:/hlocal').
*/

/**
* haz_ejecutable(+NombreArchivo,+Objetivo): salva el estado actual del programa en un ejecutable independiente
* que tendrá como objetivo el atomo especificado
* En windows hay que poner todos los archivos .dll que hay en la carpeta bin del directorio donde
* este instalado SWI pq si no funcionan los exes
* En windows no cargar el guitracer antes de hacer el exe o no funcionara
* -http://gollem.science.uva.nl/SWI-Prolog/Manual/runtime.html
* -ver que pasa con las dll
*/
haz_ejecutable(NombreArchivo,Objetivo) :-
    qsave_program(NombreArchivo, [goal(Objetivo), stand_alone(true)]).

/**
* coge_argumentos(-Args): devuelve en Args la lista de argumentos con la que se ha llamado a un posible exe de Prolog. Se esperan llamadas de la forma: ejecutable.exe arg1 arg2 ... argn
*/
coge_argumentos(Args) :- current_prolog_flag(argv, [_|Args]).
