module SHIFTER2D
  (	input wire	clk,reset,enable,
   input [7:0] ES,
   output wire [7:0] SS);
  
  
  reg [3:0][7:0] SHIFT;


  
always @(negedge reset, posedge clk)
if (!reset)
  SHIFT <= {4{8'h00}};
  else if (enable)
    begin
      // SHIFT<={ES,SHIFT[3:1]};
      SHIFT[3]<=ES;
      SHIFT[2]<=SHIFT[3];
      SHIFT[1]<=SHIFT[2];
      SHIFT[0]<=SHIFT[1];
    end

  assign SS=SHIFT[0];


tercera_prueba_despazamiento: assert property (@(posedge clk) disable iff(reset!==1'b1 ) enable[->4]  |=> SS==$past(ES,4,enable) ) else $info("AUTOCHEQUEO1: SS funciona incorrectamente");    


 
  
  endmodule
