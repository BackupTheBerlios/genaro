%DECLARACION DEL MODULO
:- module(biblio_genaro_ES,[escribeTermino/3,escribeTermino/2,existeArchivo/1]).

%BIBLIOTECAS
:- use_module(library(system)).


% use_module(library(system),[]),system:working_directory(_,'C:/hlocal').
%?- open('lala.txt', read,Str, [type(text)]), close(Str).
%open('lala.txt', write,Str, [type(text)]),write(Str, [4,5,6]), close(Str).
%directorioTrabajo('C:/hlocal').

/**
* escribeTermino(+NombreArchivo, +Directorio, +Termino)
* escribe Termino en el archivo de nombre NombreArchivo (q debe ser string), dentro
* del directorio especificado
* @param +NombreArchivo Es el nombre del archivo en que queremos que se guarde el termino Termino. El nombre
*  				debe ser un string, es decir, debe ir delimitado por comillas simples
* @param +Directorio 	Directorio en que queremos que se guarde el archivo. Tambien es un strin y debe ir
*				deliminato por comillas simeples. Tambien valen rutas relativas
* @param +Termino		Termido que se desea escribir
*/
escribeTermino(NombreArchivo, Directorio, Termino) :- 
	system:working_directory(_,Directorio),
	open(NombreArchivo, write,Str, [type(text)]),
	write(Str, Termino),
	close(Str).


%tb va bien si ruta con////!!!!!!!!!!
%ampliar luego a crear tb el dir

/**
* escribeTermino(+NombreArchivo, +Termino)
* escribe Termino en el archivo de nombre NombreArchivo (q debe ser string), dentro
* del directorio actual
* @param +NombreArchivo Es el nombre del archivo en que queremos que se guarde el termino Termino. El nombre
*  				debe ser un string, es decir, debe ir delimitado por comillas simples
* @param +Termino		Termido que se desea escribir
*/
escribeTermino(NombreArchivo, Termino) :- 
	open(NombreArchivo, write,Str, [type(text)]),
	write(Str, Termino),
	close(Str).

/**
* existeArchivo(+NombreArchivo)
* Este predicado tiene exito si existe un archivo de nombre NombreArchivo en el directorio actual
* @param +NombreArchivo nombre del archivo que se desea saber si existe
*/
existeArchivo(NombreArchivo) :-  
	nofileerrors,
	open(NombreArchivo, read, Str, [type(text)]),
	close(Str),
	filerrors.


/*
| ?- save_program(File).
| ?- save_program(File, start).
| ?- restore(File).
| ?- compile(Files), save_files(Files, Object).
predicates save_files/2, save_modules/2,
and save_predicates/2*/