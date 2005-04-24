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

mainArgumentos2 :- 
        current_prolog_flag(argv, [ _ , DirTrabajo | ListaArg ] )
       ,working_directory(_, DirTrabajo)
       ,trataArgs(ListaArg)
       ,halt(0).

/**
* trataArgs( +ListaArg ): en funcion de la lista de argumentos hace las acciones que se le pide
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
        atom_to_term(Comando, muta_progresion_multiple, _)
       ,trataArgsMutaMultiple( RestoArgs ).

/**
* trataArgsCrea( +ListaArg ): trata los argumentos en el supuesto de que estemos en el caso de crear una progresion
*/
trataArgsCrea( [ Ruta_dest, N_compases | Arg_Mut] ) :-
        generador_acordes_binario:pasa_args_a_tipo_mutacion(Arg_Mut, Tipo_Mutacion)
       ,atom_number(N_compases, NC)
       ,generador_acordes_binario:haz_progresion2(NC, 1, Tipo_Mutacion, Prog)
       ,generador_acordes_binario:escribeTermino(Ruta_dest, Prog).

/**
* trataArgsMuta( +ListaArg ): trata los argumentos en el supuesto de que estemos en el caso de mutar una progresion
*/
trataArgsMuta( [ Ruta_origen, Ruta_dest | Arg_Mut] ) :-  % NOTA: N_COMPASES NO TIENE SENTIDO AQUI
        generador_acordes_binario:pasa_args_a_tipo_mutacion(Arg_Mut, Tipo_Mutacion)
       ,generador_acordes_binario:leeTermino( Ruta_origen, Prog1 )
       ,generador_acordes_binario:modifica_prog2( Prog1, Tipo_Mutacion, Prog2 )
       ,generador_acordes_binario:escribeTermino( Ruta_dest, Prog2).

/**
* trataArgsMutaAcorde( +ListaArg ): trata los argumentos en el supuesto de que estemos en el caso de 
* mutar un solo acorde de la progresion
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
* trataArgsMutaMultiple( +ListaArg ): trata los argumentos en el supuesto de que estemos en el caso de 
* crear una progresion a partir de una semilla dada
*/
trataArgsMutaMultiple( [ Ruta_origen, Ruta_dest, N_compases | Arg_Mut ] ) :-
        generador_acordes_binario:pasa_args_a_tipo_mutacion(Arg_Mut, Tipo_Mutacion)
       ,generador_acordes_binario:leeTermino( Ruta_origen, Prog_Semilla )
       ,atom_number(N_compases, NC)
       ,generador_acordes_binario:haz_progresion2_con_semilla( NC, Prog_Semilla, Tipo_Mutacion, Prog)
       ,generador_acordes_binario:escribeTermino( Ruta_dest, Prog ).



ejemplo :- trataArgs( [ 'crea_progresion', './hola.txt', 3, mt, 1 ] ).





