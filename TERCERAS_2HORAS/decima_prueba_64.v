module shift_register
(input clk,
input reset,
input datain,
output dataout);
reg [3:0] shift;
always @(posedge clk)
  if (!reset)
     shift<=0;
  else
     begin
        shift[3]<= datain;
        shift[2]<=shift[3];
        shift[1]<=shift[2];
        shift[0]<=shift[1];
     end
assign dataout=shift[0];     
endmodule

