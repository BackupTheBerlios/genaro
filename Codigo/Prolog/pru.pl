%DECLARACION DEL MODULO
:- module(pru,[main/0]).

%BIBLIOTECAS
:- use_module(biblio_genaro_ES).


/*main :- escribeTermino('c:/hlocal/paco.txt', mellamopaco),halt.*/
/*main :- current_prolog_flag(argv, Argv)
       ,escribeTermino('c:/hlocal/argumentos.txt',Argv)
       ,halt(0).*/

main :- current_prolog_flag(argv, [_|Args])
       ,escribeTermino('c:/hlocal/argumentos.txt',Args)
       ,halt(0).
