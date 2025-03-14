`timescale 1ns / 1ps
module cont4bits_tb_reducido;

  // Parameters

  //Ports
  reg  clk; //!puerto de reloj
  reg   reset;
  reg   enable;
  wire [3:0] Q;
  wire  TC;

  cont4bits2  cont4bits_inst (
    .clk(clk),
    . reset_n( reset),
    . enable( enable),
   // .updown(1'b1),
    .Q(Q),
    .TC(TC)
  );

always #5  clk = ! clk ;
initial //reset activo a nivel bajo y empiezo con reset desactivo
begin
    $dumpfile("cont4bits_tb_bad5.vcd");
    $dumpvars(0,cont4bits_tb_reducido);
    clk = 0;
    reset = 1;
    enable = 0;
    @(negedge clk) reset = 0;
    @(negedge clk) reset = 1;
    repeat(10) 
    begin 
        @(posedge clk);
        enable=$random %2;
    end
    $finish;
end


endmodule