/*Contador 4 bits, reset asincrono*/
module 	cont4bits(clk, reset_n, enable,updown, Q, TC);
input	 clk, reset_n, enable, updown;
output reg [3:0] Q;
output	       TC;
wire final_cuenta;
always @(posedge clk or negedge reset_n)
begin
  
   if (reset_n==1'b0)
     Q <= 4'b0000;
  else
    if (enable)
      if (updown)
        Q <= Q + 1'b1;
      else
        Q <= Q - 1'b1;
    	
end
//terminal count

assign final_cuenta = (Q == 4'b1111);
assign TC = final_cuenta&enable;
endmodule
