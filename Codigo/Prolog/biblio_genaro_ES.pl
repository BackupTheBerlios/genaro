%BIBLIOTECAS
:- use_module(library(system)).


% use_module(library(system),[]),system:working_directory(_,'C:/hlocal').
%?- open('lala.txt', read,Str, [type(text)]), close(Str).
%open('lala.txt', write,Str, [type(text)]),write(Str, [4,5,6]), close(Str).
%directorioTrabajo('C:/hlocal').
/*escribeTermino(NombreArchivo, Directorio, Termino)
escribe Termino en el archivo de nombre NombreArchivo (q debe ser string), dentro
del directorio especificado
*/
escribeTermino(NombreArchivo, Directorio, Termino) :- system:working_directory(_,Directorio)
	,open(NombreArchivo, write,Str, [type(text)]), write(Str, Termino), close(Str).

%tb va bien si ruta con////!!!!!!!!!!
%ampliar luego a crear tb el dir
escribeTermino(NombreArchivo, Termino) :- open(NombreArchivo, write,Str, [type(text)])
	, write(Str, Termino), close(Str).

existeArchivo(NombreArchivo) :-  nofileerrors
	,open(NombreArchivo, read, Str, [type(text)]), close(Str)
	,filerrors.

