%DECLARACION DEL MODULO
:- module(figuras_y_ritmo,[divideFigura/3, sumaFiguras/3]).

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
