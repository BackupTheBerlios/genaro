%DECLARACION DEL MODULO
:- module(pru,[main/0]).

%BIBLIOTECAS
:- use_module(biblio_genaro_ES).


/*main :- escribeTermino('./paco.txt', mellamopaco),halt.*/
/*main :- current_prolog_flag(argv, Argv)
       ,escribeTermino('./argumentos.txt',Argv)
       ,halt(0).*/

main :- current_prolog_flag(argv, [_|Args])
       ,escribeTermino('./argumentos.txt',Args)
       ,halt(0).

mainTrabajo :- working_directory(Wd,Wd)
      ,escribeTermino('./dirTrabajo.txt',Wd)
      ,halt(0).
