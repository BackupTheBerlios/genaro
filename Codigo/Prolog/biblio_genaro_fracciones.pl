
:- module(biblio_genaro_fracciones,[
	sumarFracciones/3,
	restarFracciones/3,
	multiplicarFracciones/3,
	dividirFracciones/3,
	normalizarFraccion/2,
	maximoFracciones/3,
	mayorFracciones/2,
	igualFracciones/2,
	natural/1,
	esFraccion/1
]).

:- use_module(compat_Sicstus_SWI).

/* DEFINICION DE LA ESTRUCTURA */

/**
* esFraccion(+Fraccion).
* Una fraccion natural es simplemente un registro (functor) de dos naturales que representan, claro esta, el
* numerador y el denominador.
* @param +Fraccion termino para comprobar si es fraccion o no
*/
esFraccion( fraccion_nat(N,D) ) :-
	natural(N),
	natural(D).


/**
* natural(+N).
* Un natural es un entero mayor o igual a 0.
* @param +N término para analizar
*/
natural(N) :-
	integer(N),
	N>=0.



/* OPERACIONES CON FRACCIONES NATURALES */

/**
* maximoFracciones(+F1,+F2,-F3)
* F3 es el maximo de las fracciones F1 y F2.
* @param +F1 primera fraccion
* @param +F2 segunda fraccion
* @param -F3 maximo de F1 y F2
*/
maximoFracciones(fraccion_nat(Num1,Den1), fraccion_nat(Num2, Den2), fraccion_nat(Num1, Den1)) :-
	Aux1 is Num1*Den2,
	Aux2 is Num2*Den1,
	Aux1 >= Aux2,
	!.
maximoFracciones(fraccion_nat(_,_), fraccion_nat(Num2, Den2), fraccion_nat(Num2, Den2)).


/**
* mayorFracciones( +F1,+F2 )
* El predicado es cierto si F1 es mayor que F2 en el orden natural de los numeros fraccionarios.
* @param +F1 primera fraccion
* @param +F2 segunda fraccion
*/
mayorFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2) ) :-
	Aux1 is Num1*Den2,
	Aux2 is Num2*Den1,
	Aux1 > Aux2.


/**
* igualFracciones( +F1,+F2 )
* El predicado es cierto si la fraccion F1 es igual a F2.
* @param +F1 primera fraccion
* @param +F2 segunda fraccion
*/
igualFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2) ) :-
	Aux1 is Num1*Den2,
	Aux2 is Num2*Den1,
	Aux1 == Aux2.


/**
* restarFracciones( +F1,+F2,-F3 )
* F3 es la fraccion resultante de restar F1 con F2. F3 esta normalizada.
* @param +F1 primera fraccion o fracion positiva
* @param +F2 segunda fraccion o fraccion negativa
* @param -F3 es F1 - F2. Tambien esta normalizada
*/
restarFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2), fraccion_nat(Num, Den) ):-
	NumAux is ( (Num1*Den2) - (Num2*Den1) ),
	DenAux is Den1*Den2,
	normalizarFraccion(fraccion_nat(NumAux,DenAux), fraccion_nat(Num, Den)).


/**
* sumarFracciones( +F1,+F2,-F3 )
* F3 es la fraccion resultante de sumar F1 con F2. F3 esta normalizada.
* @param +F1 primera fraccion
* @param +F2 segunda fraccion
* @param -F3 es F1 + F2. Esta normalizada
*/
sumarFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2), fraccion_nat(Num, Den) ):-
	NumAux is ( (Num1*Den2) + (Num2*Den1) ),
	DenAux is Den1*Den2,
	normalizarFraccion(fraccion_nat(NumAux,DenAux), fraccion_nat(Num, Den)).


/**
* multiplicarFracciones( +F1,+F2,-F3 )
* F3 es la fraccion resultante de multiplicar F1 con F2. F3 esta normalizada.
* @param +F1 primera fraccion
* @param +F2 segunda fraccion
* @param -F3 es F1 * F2. Esta normalizada
*/
multiplicarFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2), fraccion_nat(Num, Den) ):-
	NumAux is Num1*Num2,
	DenAux is Den1*Den2,
	normalizarFraccion(fraccion_nat(NumAux,DenAux), fraccion_nat(Num, Den)).


/**
* dividirFracciones( +F1,+F2,-F3 )
* F3 es la fraccion resultante de dividir F1 con F2. F3 esta normalizada.
* @param +F1 primera fraccion
* @param +F2 segunda fraccion
* @param -F3 es F1 * 1/F2. Esta normalizada
*/
dividirFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2), fraccion_nat(Num, Den) ):-
	NumAux is Num1*Den2,
	DenAux is Den1*Num2,
	normalizarFraccion(fraccion_nat(NumAux,DenAux), fraccion_nat(Num, Den)).


/**
* normalizarFracciones( +F1,-F2 )
* F2 es el resultado de normalizar F1. Decimos que una fraccion es la normalizacion de otra cuando
* representan el mismo numero y tanto el denominador como el numerador no tienen factores primos comunes.
* @param +F1 fraccion para normalizar
* @param -F2 fraccion normalizada
*/
normalizarFraccion( fraccion_nat(Num1,Den1), fraccion_nat(Num2, Den2) ) :-
        gcd(Num1,Den1,Gcd),
	Num2 is Num1//Gcd,
	Den2 is Den1//Gcd.


