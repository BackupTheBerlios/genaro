:- module(compat_Sicstus_SWI,[
	random/3,
        gcd/3
]).

/*
SWI:random(+Int)
Evaluates to a random integer i for which 0 =< i < Int. The seed of this random
 generator is determined by the system clock when SWI-Prolog was started.
Sicstus:random(+Lower, +Upper, -Number)
Binds Number to a random integer in the interval [Lower,Upper) if Lower and Upper
 are integers. Otherwise, Number is bound to a random float between Lower and Upper.
 Upper will never be generated.
*/
random(LimiteIzdo, LimiteDcho, Num) :-
    Rango is LimiteDcho - LimiteIzdo,
    Azar is random(Rango),
    Num is LimiteIzdo + Azar.

/**
* gcd(X, Y, D) D es el m�ximo com�n divisor de X e Y
* @param +X
* @param +Y
* @param -D
*/
gcd(X, X, X).
gcd(X, Y, D) :- X < Y, !, Y1 is Y-X, gcd(X, Y1, D).
gcd(X, Y, D) :- Y < X, gcd(Y, X, D).