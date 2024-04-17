`timescale 1ns / 1ps
module cont4bits_tb_reducido_top;

  // Parameters

  //Ports
  reg  clk;
  reg   reset;
  reg   enable;
  wire [3:0] Q;
  wire  TC;

  cont4bits  cont4bits_inst (
    .clk(clk),
    . reset_n( reset),
    . enable( enable),
    .Q(Q),
    .TC(TC)
  );
  cont4bits_tb_reducido_estimulos estimulos_inst
  (.clk(clk),
.reset(reset),
.enable(enable)

  );

initial //reset activo a nivel bajo y empiezo con reset desactivo
begin
    $dumpfile("cont4bits_tb_total.vcd");  
    $dumpvars(0,cont4bits_tb_reducido_top);
end


endmodule