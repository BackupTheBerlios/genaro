%DECLARACION DEL MODULO
/**
* Este módulo carga a todos los demás y es el único que debe ser llamado por los otros
* lenguajes y programas que integran el proyecto
* */
:- module(principal,[main/1,mainArgumentos/0]).

%BIBLIOTECAS
%:- use_module(library(system)).
:- ensure_loaded(library(system)).
:- ensure_loaded(library(lists)).

%ARCHIVOS PROPIOS CONSULTADOS
%:- use_module(generador_acordes_binario).
%:- use_module(biblio_genaro_ES).
:- consult(generador_acordes_binario).
:- consult(biblio_genaro_ES).
:- consult(representacion_prolog_haskore).
:- consult(grados_e_intervalos).
:- consult(generador_notas_del_acorde_con_sistema_paralelo).
:- consult(generador_notas_del_acorde_con_continuidad_armonica).
:- consult(generador_acordes_semillas).
:- consult(generador_acordes).
:- consult(figuras_y_ritmo).
:- consult(compat_Sicstus_SWI).
:- consult(biblio_genaro_listas).
:- consult(biblio_genaro_fracciones).
:- consult(biblio_genaro_acordes).

/**
* main(+DirTrabajo): establece el directorio indicado como directorio de trabajo y
* genera una progresion de acordes. Hay que expandirlo con más argumentos
* @param +DirTrabajo: formato como 'c:/hlocal'
* */
main(DirTrabajo) :- working_directory(_, DirTrabajo)
	,generador_acordes_binario:genera_acordes(8, 0, paralelo, 1).

/**
* mainArgumentos: este predicado esta pensado para ser compilado en un exe siguiendo este
* procedimiento:
* -iniciar SWI-Prolog
* -consultar solamente este modulo
* -llamar al objetivo: biblio_genaro_ES:haz_ejecutable('ruta_relativa/mainArgs.exe',principal:mainArgumentos)
* Una vez construido el ejecutable mainArgs.exe su directorio de trabajo al ejecutarlo será el directorio
* desde donde se le llame, asi que sería recomendable situarlo en C:/hlocal o el directorio que se use para
* la comunicacion de archivos que corresponda. para que luego Haskell pueda encontrar los archivos
* Por consola esto se debe llamar sin poner "-" delante de los argumentos, por ejemplo con ./mainArgs.exe 8 0
* En windows hay que poner todos los archivos .dll que hay en la carpeta bin del directorio donde
* este instalado SWI pq si no funcionan los exes
* En windows no cargar el guitracer antes de hacer el exe o no funcionara
*/
mainArgumentos :- current_prolog_flag(argv, [_,DirTrabajo,NumCompases, NumMutaciones])
       ,atom_number(NumCompases,NC),atom_number(NumMutaciones,NM)
       ,working_directory(_, DirTrabajo)
       ,generador_acordes_binario:genera_acordes(NC, NM, paralelo, 1)
       ,halt(0).









