
%DECLARACION DEL MODULO
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


/* DEFINICION DE LA ESTRUCTURA */

/* 
USO: esFraccion(+F).
DESCRIPCION: Una fraccion natural es simplemente un registro (functor) de dos naturales 
*/
esFraccion( fraccion_nat(N,D) ) :- 
	natural(N),
	natural(D).


/*
USO: natural(+N).
DESCRIPCION: Un natural es un entero mayor o igual a 0 
*/
natural(N) :- 
	integer(N), 
	N>=0.



/* OPERACIONES CON FRACCIONES NATURALES */

/* 
USO: maximoFracciones(+F1,+F2,-F3)
DESCRIPCION: F3 es el maximo de las fracciones F1 y F2.
 */
maximoFracciones(fraccion_nat(Num1,Den1), fraccion_nat(Num2, Den2), fraccion_nat(Num1, Den1)) :-
	Aux1 is Num1*Den2,
	Aux2 is Num2*Den1,
	Aux1 >= Aux2,
	!.
maximoFracciones(fraccion_nat(_,_), fraccion_nat(Num2, Den2), fraccion_nat(Num2, Den2)).


/*
USO: mayorFracciones( +F1,+F2 )
DESCRIPCION: El predicado es cierto si F1 es mayor que F2 en el orden natural de los numeros fraccionarios.
*/
mayorFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2) ) :-
	Aux1 is Num1*Den2,
	Aux2 is Num2*Den1,
	Aux1 > Aux2.


/*
USO: igualFracciones( +F1,+F2 )
DESCRIPCION: El predicado es cierto si la fraccion F1 es igual a F2.
*/
igualFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2) ) :-
	Aux1 is Num1*Den2,
	Aux2 is Num2*Den1,
	Aux1 == Aux2.


/*
USO: restarFracciones( +F1,+F2,-F3 )
DESCRIPCION: F3 es la fraccion resultante de restar F1 con F2. F3 esta normalizada.
*/
restarFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2), fraccion_nat(Num, Den) ):-
	NumAux is ( (Num1*Den2) - (Num2*Den1) ),
	DenAux is Den1*Den2,
	normalizarFraccion(fraccion_nat(NumAux,DenAux), fraccion_nat(Num, Den)).


/*
USO: sumarFracciones( +F1,+F2,-F3 )
DESCRIPCION: F3 es la fraccion resultante de sumar F1 con F2. F3 esta normalizada.
*/
sumarFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2), fraccion_nat(Num, Den) ):-
	NumAux is ( (Num1*Den2) + (Num2*Den1) ),
	DenAux is Den1*Den2,
	normalizarFraccion(fraccion_nat(NumAux,DenAux), fraccion_nat(Num, Den)).


/*
USO: multiplicarFracciones( +F1,+F2,-F3 )
DESCRIPCION: F3 es la fraccion resultante de multiplicar F1 con F2. F3 esta normalizada.
*/
multiplicarFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2), fraccion_nat(Num, Den) ):-
	NumAux is Num1*Num2,
	DenAux is Den1*Den2,
	normalizarFraccion(fraccion_nat(NumAux,DenAux), fraccion_nat(Num, Den)).


/*
USO: dividirFracciones( +F1,+F2,-F3 )
DESCRIPCION: F3 es la fraccion resultante de dividir F1 con F2. F3 esta normalizada.
*/
dividirFracciones( fraccion_nat(Num1,Den1), fraccion_nat(Num2,Den2), fraccion_nat(Num, Den) ):-
	NumAux is Num1*Den2,
	DenAux is Den1*Num2,
	normalizarFraccion(fraccion_nat(NumAux,DenAux), fraccion_nat(Num, Den)).


/*
USO: normalizarFracciones( +F1,-F2 )
DESCRIPCION: F2 es el resultado de normalizar F1. Decimos que una fraccion es la normalizacion de otra cuando 
representan el mismo numero y tanto el denominador como el numerador no tienen factores primos comunes. 
*/
normalizarFraccion( fraccion_nat(Num1,Den1), fraccion_nat(Num2, Den2) ) :-
	Num2 is Num1//gcd(Num1,Den1),
	Den2 is Den1//gcd(Num1,Den1).


