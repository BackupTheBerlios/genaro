
:- module(figuras_y_ritmo,
			[divideFigura/3
                        , multiplicaFigura/3
			, fuerzaEnElCompas/4
			, sumaFiguras/3]).

/* Modulos propios usados */
:- use_module(biblio_genaro_fracciones).

/* // es la division entera*/

/**
* divideFigura(+Fe, +N, -Fs)
* divide la figura Fe por el natural N y lo devuelve en Fs
* @param +Fe figura a dividir, cumple es_figura(Fe)
* @param +N natural que dividirá a la figura, cumple natural(N)
* @param -Fs resultado de la division, cumple es_figura(Fs)
*/
divideFigura(figura(Ne, De), N, figura(Ns, Ds)) :-
	natural(N),
	DAux is De * N,
	normalizarFraccion(fraccion_nat(Ne, DAux), fraccion_nat(Ns, Ds)).

/**
* multiplicaFigura(+Fe, +N, -Fs)
* multiplica la figura Fe por el natural N y lo devuelve en Fs
* @param +Fe figura a multiplicar, cumple es_figura(Fe)
* @param +N natural que multiplicará a la figura, cumple natural(N)
* @param -Fs resultado de la multiplicacion, cumple es_figura(Fs)
*/
multiplicaFigura(figura(Ne, De), N, figura(Ns, Ds)) :-
	natural(N),
	NAux is Ne * N,
	normalizarFraccion(fraccion_nat(NAux, De), fraccion_nat(Ns, Ds)).


/**
* sumaFiguras(+Fs1, +Fs2, -Fresul)
* Suma las figuras Fs1 y Fs2 como si fueran fracciones
* @param +Fs1 primera figura
* @param +Fs2 segunda figura
* @param -Fresul figura resultado de sumar Fs1 y Fs2, cumple es_figura(Fresul)
*/
sumaFiguras(figura(N1,D1), figura(N2,D2), figura(Nr, Dr)):-
	sumarFracciones(fraccion_nat(N1,D1),
	fraccion_nat(N2,D2),
	fraccion_nat(Nr, Dr)).

listaFigurasAListaNat([],[]).
listaFigurasAListaNat([figura(N,D)|Fo],[]) :-

/**
* fuerzaEnElCompas(Nn, Nd, Tipo, Fuerza)
* en un compas del tipo especificado en Tipo. Tenemos un acorde al
* que le precede una sucesión de acordes en el cual la suma de las figuras de los acordes que lo forman
* es Nn/Nd. Fuerza indica si el acorde que sigue está en tiempo fuerte, débil o semifuerte. Por ahora
* sólo está implementado para compases binarios
* @param +Nn numerado de la fraccion
* @param +Nd denominador de la fraccion
* @param +Tipo del compás, pertenece a {binario, ternario, cuaternario}. Por ahora sólo
* 		implementado para binario!!!!
* @param -Fuerza pertenece a {fuerte, debil, semifuerte}
*/
fuerzaEnElCompas(Nn, _, binario, fuerte) :-
	0 is Nn mod 2,
	!.
fuerzaEnElCompas(_, _, binario, debil).







