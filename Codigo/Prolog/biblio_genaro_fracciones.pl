sumaFracciones(fraccion_nat(N1,D1), fraccion_nat(N2,D2), F) :-
  Na is ((N1*D2) + (N2*D1)), Da is D1*D2, simpFraccion(fraccion_nat(Na,Da),F).

/* // es la division entera*/
simpFraccion(fraccion_nat(N1,D1), fraccion_nat(N2,D2)) :- Mcd is gcd(N1,D1),
	N2 is N1//Mcd, D2 is D1//Mcd.