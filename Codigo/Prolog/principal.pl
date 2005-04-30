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
	,generador_acordes_binario:haz_progresion(8, 0, 1, _).

/**
* mainArgumentos: este predicado esta pensado para ser compilado en un exe siguiendo este
* procedimiento:
* -iniciar SWI-Prolog
* -consultar solamente este modulo
* -llamar al objetivo: biblio_genaro_ES:haz_ejecutable('ruta_relativa/mainArgs.exe',principal:mainArgumentos)
* Una vez construido el ejecutable mainArgs.exe su directorio de trabajo al ejecutarlo será el directorio
* desde donde se le llame, asi que sería recomendable situarlo en C:/hlocal o el directorio que se use para
* la comunicacion de archivos que corresponda. para que luego Haskell pueda encontrar los archivos
* Por consola esto se debe llamar sin poner "-" delante de los argumentos, por ejemplo con ./mainArgs.exe d:/cvsrepo 8 0
* En windows hay que poner todos los archivos .dll que hay en la carpeta bin del directorio donde
* este instalado SWI pq si no funcionan los exes
* En windows no cargar el guitracer antes de hacer el exe o no funcionara
*/
mainArgumentos :- current_prolog_flag(argv, [_,DirTrabajo,NumCompases, NumMutaciones])
       ,atom_number(NumCompases,NC),atom_number(NumMutaciones,NM)
       ,working_directory(_, DirTrabajo)
       ,generador_acordes_binario:haz_progresion(NC, NM, 1, _)
       ,halt(0).
/*mainArgumentos :- current_prolog_flag(argv, [_,NumCompases, NumMutaciones])
       ,atom_number(NumCompases,NC),atom_number(NumMutaciones,NM)
       ,generador_acordes_binario:haz_progresion(NC, NM, 1, _)
       ,halt(0).*/


/************** CODIGO DE ROBERTO ****************************/

/**
* mainArgumentos2
* Este predicado tiene las mismas funciones que mainArgumentos pero se ha cambiado el numero de parametros que se le pasa
* La especificacion de los parametros se encuentra en el acta de reunion del dia 12-4-2005. Aqui detallamos algunos ejemplos
* 
* crea_progresion: Crea una progresión. Ejemplos:
* MainArgs Directorio_Trabajo crea_progresión Ruta_Destino N_Compases ta 3 tb 2
* MainArgs Directorio_Trabajo crea_progresión Ruta_Destino N_Compases ta 3 t4 1 t5 1
* MainArgs Directorio_Trabajo crea_progresión Ruta_Destino N_Compases t1 3 t2 2 t3 0 t4 0 t5 7
* MainArgs Directorio_Trabajo crea_progresión Ruta_Destino N_Compases mt 12
* MainArgs Directorio_Trabajo crea_progresión Ruta_Destino N_Compases t1 3 t2 2 t3 8 tb 2
* 
* muta_progresion: Muta una progresión ya existente.
* MainArgs Directorio_Trabajo muta_progresión Ruta_Origen Ruta_Destino N_Compases ta 3 tb 2
* 
* muta_progresion_acorde: Muta la progresión en el acorde especificado
* MainArgs Directorio_Trabajo muta_progresion_Acorde Ruta_Origen Ruta_Destino N_Compases N_Acorde mt 33
* 
* crea_con_semilla: Crea una progresión cogiendo al semilla de la progresión origen
* MainArgs Directorio_Trabajo crea_con_semilla Ruta_Origen Ruta_Destino N_Compases ta 3 tb 2
*/
mainArgumentos2 :- 
        current_prolog_flag(argv, [ _ , DirTrabajo | ListaArg ] )
       ,working_directory(_, DirTrabajo)
       ,trataArgs(ListaArg)
       ,halt(0).

/**
* trataArgs( +ListaArg )
* En funcion de la lista de argumentos hace las acciones que se le pide
* @param +ListaArg lista de atomos que representan loa argumentos
*/
% CREA PROGRESION
trataArgs( [Comando | RestoArgs] ) :-
        atom_to_term(Comando, crea_progresion, _)
       ,trataArgsCrea( RestoArgs ).
% MUTA PROGRESION
trataArgs( [Comando | RestoArgs] ) :-
        atom_to_term(Comando, muta_progresion, _)
       ,trataArgsMuta( RestoArgs ).
% MUTA PROGRESION EN UN ACORDE ESPECIFICADO
trataArgs( [Comando | RestoArgs] ) :-
        atom_to_term(Comando, muta_progresion_acorde, _)
       ,trataArgsMutaAcorde( RestoArgs ).
% CREA UNA PROGRESION A PARTIR DE UNA SEMILLA DADA
trataArgs( [Comando | RestoArgs] ) :-
        atom_to_term(Comando, crea_con_semilla, _)
       ,trataArgsCreaConSemilla( RestoArgs ).

/**
* trataArgsCrea( +ListaArg )
* Trata los argumentos en el supuesto de que estemos en el caso de crear una progresion
* @param +ListaArg lista de argumentos de crea_progresion
*/
trataArgsCrea( [ Ruta_dest, N_compases | Arg_Mut] ) :-
        generador_acordes_binario:pasa_args_a_tipo_mutacion(Arg_Mut, Tipo_Mutacion)
       ,atom_number(N_compases, NC)
       ,generador_acordes_binario:haz_progresion2(NC, 1, Tipo_Mutacion, Prog)
       ,generador_acordes_binario:escribeTermino(Ruta_dest, Prog).

/**
* trataArgsMuta( +ListaArg )
* Trata los argumentos en el supuesto de que estemos en el caso de mutar una progresion
* @param +ListaArg lista de argumentos de muta_progresion
*/
trataArgsMuta( [ Ruta_origen, Ruta_dest | Arg_Mut] ) :-  % NOTA: N_COMPASES NO TIENE SENTIDO AQUI
        generador_acordes_binario:pasa_args_a_tipo_mutacion(Arg_Mut, Tipo_Mutacion)
       ,generador_acordes_binario:leeTermino( Ruta_origen, Prog1 )
       ,generador_acordes_binario:modifica_prog2( Prog1, Tipo_Mutacion, Prog2 )
       ,generador_acordes_binario:escribeTermino( Ruta_dest, Prog2).

/**
* trataArgsMutaAcorde( +ListaArg )
* Trata los argumentos en el supuesto de que estemos en el caso de mutar un solo acorde de la progresion
* @param +ListaArg lista de argumentos de muta_progresion_acorde
*/
trataArgsMutaAcorde( [Ruta_origen, Ruta_dest, N_compas | Arg_Mut] ) :-
        generador_acordes_binario:pasa_args_a_tipo_mutacion(Arg_Mut, Tipo_Mutacion)
       ,generador_acordes_binario:leeTermino( Ruta_origen, progresion(LC) )
       ,atom_number(N_compas, NC)
       ,nth(NC, LC, Cif_a_Mutar)
       ,generador_acordes_binario:modifica_prog2( progresion([Cif_a_Mutar]) , Tipo_Mutacion, progresion(LMutada) )
       ,biblio_genaro_listas:sustituye(LC, NC, LMutada, Laux)
       ,flatten(Laux, Laux2)
       ,generador_acordes_binario:escribeTermino( Ruta_dest, progresion(Laux2) ).

/**
* trataArgsCreaConSemilla( +ListaArg )
* Trata los argumentos en el supuesto de que estemos en el caso de crear una progresion a partir de una semilla dada
* @param +ListaArg lista de argumentos de crea_con_semilla
*/
trataArgsCreaConSemilla( [ Ruta_origen, Ruta_dest, N_compases | Arg_Mut ] ) :-
        generador_acordes_binario:pasa_args_a_tipo_mutacion(Arg_Mut, Tipo_Mutacion)
       ,generador_acordes_binario:leeTermino( Ruta_origen, Prog_Semilla )
       ,atom_number(N_compases, NC)
       ,generador_acordes_binario:haz_progresion2_con_semilla( NC, Prog_Semilla, Tipo_Mutacion, Prog) 
       ,generador_acordes_binario:escribeTermino( Ruta_dest, Prog ).


/*
ejemplo :- 
        working_directory(_, 'D:/CVS/Proyecto musica/Codigo/Prolog')
       ,trataArgs(['crea_con_semilla', './semilla.txt', './destino.txt', '11', 'mt', '20']).



ejemplo2:-
        working_directory(_, 'D:/CVS/Proyecto musica/Codigo/Prolog')
       ,biblio_genaro_ES:leeTermino('./destino.txt', P)
       ,generador_acordes_binario:duracionProg(P, N)
       ,write(N).
*/
