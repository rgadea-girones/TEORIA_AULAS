//4 bit adder
module 	adder4bit(a, b, sum, cout); 
input 	[3:0] a, b;
output 	[3:0] sum; 
output 	cout;

wire 	c1, c2, c3;

half_adder 	FA1(a[0], b[0], sum[0], c1);
full_adder 	FA2(a[1], b[1], c1, sum[1], c2);
full_adder 	FA3(a[2], b[2], c2, sum[2], c3);
full_adder 	FA4(a[3], b[3], c3, sum[3], cout);

endmodule
//half adder    1 bit
module 	half_adder(a, b, sum, carry);   
input 	a, b;
output 	sum, carry;

assign 	sum = a ^ b;
assign 	carry = a & b;

endmodule


//full adder    1 bit
module 	full_adder(a, b, cin, sum, cout);

input 	a, b, cin;
output 	sum, cout;

wire 	c1, c2;

half_adder 	HA1(a, b, c1, sum);
half_adder 	HA2(c1, cin, sum, c2);
or 	OR1(c2, cout);

endmodule

