//`default_nettype none
module 	mux(a, b, f,sel);
input	a, b, sel;
output	f;

wire f2, f1, f;
wire nsel, sel;


and 	#5	g1(f1, a, nsel),
		g2(f2, b, sel);

//assign 	#5	f = ~(f1 | f2);
nor	#5	g3(f, f1, f2);
assign	#5	nsel = ~sel;

//not		g4(nsel, sel);





endmodule
