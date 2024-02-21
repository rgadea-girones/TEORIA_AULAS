module 	sumador(a, b, cin, sum, cout);
input	[3:0]	a, b;
input		cin;
output	[3:0] 	sum;
output	 	cout;

wire	[3:0] 	a,b;
wire		cout;
wire	[3:0] 	sum;





assign	#1 {cout, sum} = a + b + cin;

endmodule
