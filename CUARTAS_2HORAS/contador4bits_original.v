/*Contador 4 bits, reset asincrono*/
module 	cont4bits(clk, reseta_n, enable, Q, TC);
input	 clk, reseta_n, enable;
output reg [3:0] Q;
output	       TC;
wire final_cuenta;
always @(posedge clk or negedge reseta_n)
  if (!reseta_n)
     Q <= 4'b0000;
  else
    if (enable == 1'b1)

	    Q <= Q + 1'b1;


assign final_cuenta = (Q == 4'b1111);
assign TC =  final_cuenta;
endmodule
