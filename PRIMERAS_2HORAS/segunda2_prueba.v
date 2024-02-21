module m7485 (G, L, a, b);
output G,L;
input [3:0] a,b;
	wire #(10,5) G = (a >b),
		 L = (a<b);
endmodule

