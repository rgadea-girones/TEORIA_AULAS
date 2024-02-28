
module 	muxt(in0, in1, sel, out);
// Declaración Inputs y Outputs
input [7:0]	 in0, in1;
input	      sel;
output [7:0]	 out;
// Descripción de los nodos internos
wire [7:0]	 y0;
// Conexionado por orden
mux_always mux0(in0, in1, sel, y0);
// Conexionado por nombre
mux_assign mux1(.y(out), .b(in1), .a(y0), .sl(sel));
endmodule

module     mux_always
(
    input	[7:0]	a, b,
    input		sl,
    output reg 	[7:0]	y
) ;
always @(a or b or sl)
	if (sl == 1)
		y = a;
	else
		y = b;

endmodule
module     mux_assign
(
    input	[7:0]	a, b,
    input		sl,
    output 	[7:0]	y
) ;

assign #1 y = (sl) ? a : b;
endmodule


