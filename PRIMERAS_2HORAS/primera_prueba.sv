
// `default_nettype none
module mux
(input a, b, sel,
output f);



wire f2, f1, nsel;
and 	#5	g1(f1, a, nsel),
		g2(f2, b, sel);
or	#5	g3(f, f1, f2);

not		g4(nsel, sel);






endmodule
