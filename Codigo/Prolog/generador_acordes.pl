%DESCRIPCION
/**
* Modulo que agrupa predicados utilizados por todos los modulos que generan secuencias
* de acordes expresadas por términos que cumplen el predicado es_progresion_ordenada
*/

%DECLARACION DEL MODULO
%%:- module(generador_acordes).
:- module(generador_acordes
              , [menosEstable/2
                ,fichero_destinoGenAc_prog/1
                ,fichero_destinoGenAc_prog_depura/1
                ,fichero_destinoGenAc_prog_semilla/1
                ,dame_grado_funcTonal_equiv/2
                ,dame_grado_funcTonal_equiv2/2
                ,dame_cuat_funcTonal_equiv/2
                ,dame_cuat_funcTonal_equiv2/2
                ,quita_grados_relativos/2
                ,multiplica_duracion/3
                ,busca_acordes_afines/2
                ,numCompases/2]).

%BIBLIOTECAS
:- use_module(compat_Sicstus_SWI).
:- ensure_loaded(library(lists)).
%%:- use_module(library(lists)).
%%:- use_module(library(random)).

%ARCHIVOS PROPIOS CONSULTADOS
:- use_module(generador_acordes_binario).
:- use_module(grados_e_intervalos).
:- use_module(biblio_genaro_acordes).
:- use_module(biblio_genaro_listas).
:- use_module(biblio_genaro_fracciones).
:- use_module(figuras_y_ritmo).

%:- use_module(representacion_prolog_haskore).
%:- use_module(biblio_genaro_listas).
%:- use_module(biblio_genaro_fracciones).
%:- use_module(biblio_genaro_ES).
%:- use_module(generador_notas_del_acorde_con_sistema_paralelo).
%:- use_module(generador_notas_del_acorde_con_continuidad_armonica).

%PREDICADOS

	%RUTAS DE LOS PROCESOS DE E/S
fichero_destinoGenAc_prog('../../progresion.txt').
fichero_destinoGenAc_prog_depura('../../progresion_dep.txt').
fichero_destinoGenAc_prog_semilla('../../progresion_semilla.txt').

	%TIPOS Y ESTRUCTURAS
/**
* es_progresion(+P)
* Se cumple si P es un termino con la estructura que se le exige a una progresion,
* es decir, si es la aplicacion de la constructora progresion a una lista de parejas formadas por
* un cifrado y una figura. Esta lista expresa la estructura de un acompañamiento rítmico en el que
* se suceden los acordes expresados por las parejas que forman la lista empezando por el correspondiente a la
* cabeza de la lista y avanzando hasta el final de esta. Cada pareja especifica un acorde siguiendo la notacion
* del cifrado americano en su primer componente, y el espacio de tiempo durante el cual se ejecutará dicho acorde
* , en su segundo componente. Notese que no se indica nada sobre como se ejecutara cada acorde, ni en cuanto al
* patrón ritmico ni en cuanto a la fuerza del ataque, etc...
* Ver generador_acordes:es_cifrado y representacion_prolog_haskore:es_figura
* @param +P termino cuya estructura se quiere analizar para ver si corresponde con la deseada
* */
es_progresion(progresion(P)) :- es_listaDeCifrados(P).
es_listaDeCifrados([]).
es_listaDeCifrados([(C, F)|Cs]) :- es_cifrado(C), es_figura(F)
       ,es_listaDeCifrados(Cs).

/**
* es_cifrado(+C)
* Se cumple si C es un termino con la estructura que se le exige a un cifrado, es decir, si
* es la aplicacion de la constructora cifrado a un termino con estructura de grado y a otro con estructura
* de matricula. Un termino que cumple es_cifrado especifica un acorde expresado en notacion de cifrado americano
* Ver grados_e_intervalos:es_grado y generador_acordes:es_matricula
* @param +C termino cuya estructura se quiere analizar para ver si corresponde con la deseada
* */
es_cifrado(cifrado(G,M)) :- es_grado(G), es_matricula(M).

/**
* es_matricula(+M)
* Se cumple si M es un termino con la estructura que se le exige a una matricula, es decir, si
* es la aplicacion de la constructora matricula a un elemento del conjunto {mayor,m,au,dis,6,m6,m7b5, maj7,7,
* m7,mMaj7,au7,dis7}. Asi que una matricula especifica la parte de un cifrado americano que no es la que expresa
* la fundamental del acorde
* Notas:
* - dis7 es la matricula del disminuido, es decir, de º7
* - en el futuro se añadiran los cifrados que sea necesario
* @param +M termino cuya estructura se quiere analizar para ver si corresponde con la deseada
* */
es_matricula(matricula(M)) :- member(M, [mayor,m,au,dis,6,m6,m7b5, maj7,7,m7,mMaj7,au7,dis7]).

	%PREDICADOS AUXILIARES
		%FUNCIONES TONALES
/**
* menosEstable(F1,F2) se cumple si la función tonal F1 es menos estable que la funcion tonal F2
* @param +F1 pertenece a {tonica, subdominante, dominante}
* @param +F2 pertenece a {tonica, subdominante, dominante}
*/
menosEstable(dominante,tonica).
menosEstable(dominante,subdominante).
menosEstable(subdominante,tonica).

/*funciona para grados*/
mismaFuncionTonal(G1,G2) :- dameFuncionTonal(G1, F), dameFuncionTonal(G2, F).
mismaFuncionTonalCifrado(G1,G2) :- dameFuncionTonalCifrado(G1, F), dameFuncionTonalCifrado(G2, F).

/*dameFuncionTonal(G, Ft): Ft es la función tonal del grado G
in: G cumple es_grado(G)
out: Ft pertenece a {tonica, subdominante, dominante}
*/
dameFuncionTonal(grado(G), tonica) :- member(G, [i, iii, vi]).
dameFuncionTonal(grado(G), subdominante) :- member(G, [ii, iv]).
dameFuncionTonal(grado(iim7 / _), subdominante).
dameFuncionTonal(grado(G), dominante) :- member(G, [v, vii]).
dameFuncionTonal(grado(v7 / _), dominante).

/*dameFuncionTonalCifrado(C, Ft): Ft es la función tonal del cifrado C
in: C cumple es_cifrado(C)
out: Ft pertenece a {tonica, subdominante, dominante}
*/
dameFuncionTonalCifrado(cifrado(G,_), Ft) :- dameFuncionTonal(G, Ft).

/*dame_grado_funcTonal_equiv(GradoOrigen, GradoDestino)
devuelve en GradoDestino un grado diatónico!!! que tiene la misma función tonal que GradoOrigen y que además es distinto
a este
in: GradoOrigen hace cierto es_grado(GradoOrigen)
out: GradoDestino hace cierto es_grado(GradoDestino)
*/
dame_grado_funcTonal_equiv(Go, Gd) :- setof(Gc,(mismaFuncionTonal(Go,Gc), \+(Gc = Go)
											, \+(Gc = grado(v7 / _))
											, \+(Gc = grado(iim7 / _))
											), Lc)
                                    ,dame_elemento_aleatorio(Lc, Gd).

/*dame_grado_funcTonal_equiv2(GradoOrigen, GradoDestino)
devuelve en GradoDestino un grado diatónico!!! que tiene la misma función tonal que GradoOrigen y que no tiene
por que ser distinto a GradoOrigen a este
in: GradoOrigen hace cierto es_grado(GradoOrigen)
out: GradoDestino hace cierto es_grado(GradoDestino)
*/
dame_grado_funcTonal_equiv2(Go, Gd) :- setof(Gc,(mismaFuncionTonal(Go,Gc)
											, \+(Gc = grado(v7 / _))
											, \+(Gc = grado(iim7 / _))
											), Lc)
                                    ,dame_elemento_aleatorio(Lc, Gd).

/*dame_cuat_funcTonal_equiv(CifOri,CuatDest)
devuelve en CuatDestino la cuatriada de un grado que tiene la misma función tonal que el correspondiente a
CifOrigen y que además es distinto a este
in: CifOrigen hace cierto es_cifrado(CifOrigen)
out: CuatDestino hace cierto es_cifrado(CuatDestino)
*/
dame_cuat_funcTonal_equiv(cifrado(GradoElegido,_),CuatDest) :- dame_grado_funcTonal_equiv(GradoElegido, GradoSustituto)
			,hazCuatriada(GradoSustituto, CuatDest).

/*dame_cuat_funcTonal_equiv2(CifOri,CuatDest)
devuelve en CuatDestino la cuatriada de un grado que tiene la misma función tonal que el correspondiente a
CifOrigen y que no tiene por que ser distinto a este
in: CifOrigen hace cierto es_cifrado(CifOrigen)
out: CuatDestino hace cierto es_cifrado(CuatDestino)
*/
dame_cuat_funcTonal_equiv2(cifrado(GradoElegido,_),CuatDest) :- dame_grado_funcTonal_equiv2(GradoElegido, GradoSustituto)
			,hazCuatriada(GradoSustituto, CuatDest).

/**
* numAcordes(+P,-N)
* Indica en N el numero de acordes que hay en la progresión P. Podemos definir que una progresión
* está en forma normal cuando no existen dos acordes adyacentes en el tiempo/ lista que tengan el mismo cifrado.
* Por ejemplo la progresión [(C-7, 1/2), (C-7 , 1/2), (Amaj7,1/1)] quedaría en forma normal como
* [(C-7, 1/1), (Amaj7,1/1)]. Sería deseable que todas las progresiones generadas por haz_progresion y sus predicados
* auxiliares generaran progresiones en forma normal (estos comentarios hay q estructurarlos luego). numAcordes(P,N)
* da el numero de elementos de la lista ListaAcordes si la forma normal de P es progresion(ListaAcordes)
* @param +P progresion sobre cuya progresion equivalente en forma normal se va a realizar el conteo de acordes
* @parm -N es un entero
*/
numAcordes(progresion(Lc), N) :- numAcordesLista(Lc,ninguno,N).
/**
* numAcordesLista(+Lc, +Uc, -N): Uc es el cifrado del acorde anterior
* funcion auxiliar privada para el conteo de acordes
* */
numAcordesLista([], _ ,0).
numAcordesLista([C|Cs], C, N) :- numAcordesLista(Cs, C, N).
numAcordesLista([C|Cs], Uc, N1) :- \+(C = Uc), numAcordesLista(Cs, C, N), N1 is N + 1.

/**
* numCompases(P,S) indica en S el numero de compases que dura la progresión P
* @param +P que cumple es_progresion(P)
* @param -S float que indica el numero de compases que ocupa la progresión P
*/
numCompases(progresion(L),M) :- numCompasesLista(L, fraccion_nat(N,D)), M is N/D.
numCompasesLista([], fraccion_nat(0,1)).
numCompasesLista([(_,figura(N,D))|Cs], F) :- numCompasesLista(Cs, Fl), 	sumarFracciones(fraccion_nat(N,D), Fl, F).

/**
* numCompases(P,SN,SD) indica en SN/SD el numero de compases que dura la progresión P
* @param +P que cumple es_progresion(P)
* @param -SN natural que es el numerador de la fraccion que indica numero de compases que ocupa la progresión P
* @param -SD float que es el denominador de la fraccion que indica el numero de compases que ocupa la progresión P
*/
numCompases(progresion(L),N,D) :- numCompasesLista(L, fraccion_nat(N,D)).

		%QUITA GRADOS RELATIVOS
/**
* quita_grados_relativos(Po, Pd) Pd es una progresion equivalente a Po en la que se han eliminado las referencias indirectas
* a grados causadas por v7/G y iim7/G
* @param +Po cumple es_progresion(Po)
* @param -Pd cumple es_progresion(Pd)
* */
quita_grados_relativos(progresion(Po), progresion(Pd)) :- quita_grados_relativos_lista(Po, Pd).
quita_grados_relativos_lista([], []).
quita_grados_relativos_lista([(cifrado(Gi,M), F)|Li], [(cifrado(Go,M), F)|Lo]):-
               gradoRelativoAAbsoluto(Gi, Go),quita_grados_relativos_lista(Li, Lo).

               %BUSCA ACORDES AFINES
/**
* busca_acordes_afines(Lacords, Lpos) busca en la lista de cifrados Lacords parejas de acordes diatónicos!!
* tales que tengan la misma función tonal y sean adyacentes en la lista, y devuelve en Lpos la lista de posisiones dentro
* de Lacords (nunerando empezando por 1) de los primeros elementos de dichas parejas, es decir que se cumple
* setof( Pos, (  nth( Pos,Lacords,(A1,_) ), PosS is Pos + 1, nth( PosS,Lacords,(A2,_) ),
* mismaFuncionTonalCifrado(A1, A2)  ), Lpos).
* @param +Lacords cumple es_listaDeCifrados(Lacords)
* @param -Lpos es una lista de enteros que pertenecen al intervalo [1,longitud de Lacords)
**/
busca_acordes_afines(Lacords, Lpos):-busca_acordes_afines_acu(Lacords, 1, ninguno, Lpos).
/*
busca_acordes_afines_acu(Lacords, PosActual, AcordeAnterior, ListaPos)
SOLO PARA DOCUMENTACION INTERNA, POR ESO NO TIENE doble *
@param +Lacords cumple es_listaDeCifrados(Lacords), lista de cifrados cuya cabeza se está examinando
@param +PosActual natural que indica la posicion de la cabeza de Lacords respecto a la lista más grande sobre
la que se está haciendo esta recursión
@param +AcordeAnterior acorde anterior a la cabeza de Lacords respecto a la lista más grande sobre
la que se está haciendo esta recursión
@param -ListaPos lista de posiones de Lacords que cumple busca_acordes_afines(Lacords, LposAux)
, Lpos is LposAux + PosActual - 1
*/
busca_acordes_afines_acu([], _, _, []).
busca_acordes_afines_acu([(cifrado(GAct,MAct),_)|La], PosAct, AcAnterior, [PosAniadir|Lp]):-
	listaGradosNoDiatonicos(jonico,ListaGrados),\+(member(GAct, ListaGrados))
	,mismaFuncionTonalCifrado(cifrado(GAct,MAct), AcAnterior),!, PosAniadir is PosAct - 1, PosSig is PosAct + 1
	%%mismaFuncionTonalCifrado(AcAct, AcAnterior),!, PosAniadir is PosAct - 1, PosSig is PosAct + 1
	,busca_acordes_afines_acu(La, PosSig, cifrado(GAct,MAct), Lp).

busca_acordes_afines_acu([(AcAct,_)|La], PosAct, _, Lp):-
	 PosSig is PosAct + 1,busca_acordes_afines_acu(La, PosSig, AcAct, Lp).

		%PREDICADOS QUE AÑADEN MAS COMPASES A LA PROGRESION
/**
* multiplica_duracion(+Po, +N, -Pd). Pd es el resultado de multiplicar por N la duración de cada uno de sus acordes
* @param +Po cumple es_progresion(Po)
* @param +N es un natural
* @param -Pd cumple es_progresion(Pd)
* */
multiplica_duracion(progresion(Lo), N, progresion(Ld)) :- multiplica_duracionLista(Lo, N, Ld).
multiplica_duracionLista([], _, []).
multiplica_duracionLista([(Cif, F)|Los], N, [(Cif, FMul)|Lds])
     :- multiplicaFigura(F, N, FMul), multiplica_duracionLista(Los, N, Lds).
