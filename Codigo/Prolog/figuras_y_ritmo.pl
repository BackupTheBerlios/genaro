%DECLARACION DEL MODULO
:- module(figuras_y_ritmo,
			[divideFigura/3
			, fuerzaEnElCompas/4
			, sumaFiguras/3]).

%ARCHIVOS PROPIOS CONSULTADOS
:- use_module(biblio_genaro_fracciones).

/*divideFigura(Fe, N, Fs)
divide la figura Fi por el natural N
in: Fe figura a dividir, cumple es_figura(Fe)
    N natural que dividirá a la figura, cumple natural(N)
out: Fs resultado de la division, cumple es_figura(Fs)
*/
/* // es la division entera*/
divideFigura(figura(Ne, De), N, figura(Ns, Ds)) :- natural(N), DAux is De*N
                       ,normalizarFraccion(fraccion_nat(Ne, DAux), fraccion_nat(Ns, Ds)).

/*sumaFiguras(Fs1, Fs2, Fresul)*/
sumaFiguras(figura(N1,D1), figura(N2,D2), figura(Nr, Dr)):- 
	sumarFracciones(fraccion_nat(N1,D1), fraccion_nat(N2,D2), fraccion_nat(Nr, Dr)).

/**
* fuerzaEnElCompas(Nn,Nd, Tipo, Fuerza) en un compas del tipo especificado en Tipo tenemos un acorde al
* que le precede una sucesión de acordes en el cual la suma de las figuras de los acordes que lo forman 
* es Nn/Nd. Fuerza indica si el acorde que sigue está en tiempo fuerte, débil o semifuerte. Por ahora
* sóli implementado para compases binarios
* @param +Num de tipo float
* @param +Tipo del compás, pertenece a {binario, ternario, cuaternario}. Por ahora sólo
* implementado para binario!!!!
* @param -Fuerza pertenece a {fuerte, debil, semifuerte}
*/
fuerzaEnElCompas(Nn, _, binario, fuerte) :- 0 is Nn mod 2,!.
fuerzaEnElCompas(_, _, binario, debil).
