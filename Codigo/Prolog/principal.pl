%DECLARACION DEL MODULO
/**
* Este módulo carga a todos los demás y es el único que debe ser llamado por los otros
* lenguajes y programas que integran el proyecto
* */
:- module(principal,[main/1]).

%BIBLIOTECAS
:- use_module(library(system)).

%ARCHIVOS PROPIOS CONSULTADOS
:- use_module(generador_acordes_binario).

/**
* main(+DirTrabajo): establece el directorio indicado como directorio de trabajo y
* genera una progresion de acordes. Hay que expandirlo con más argumentos
* @param +DirTrabajo: formato como 'c:/hlocal'
* */
main(DirTrabajo) :- working_directory(_, DirTrabajo)
	,generador_acordes_binario:genera_acordes(8, 0, paralelo, 1).
