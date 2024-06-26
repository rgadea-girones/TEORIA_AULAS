`timescale 1ns / 1ps
module cont4bits_tb;

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

always #5  clk = ! clk ;
initial //reset activo a nivel bajo y empiezo con reset desactivo
begin
    $dumpfile("cont4bits_tb_good2.vcd");
    $dumpvars(0,cont4bits_tb);
    clk = 0;
    reset = 1;
    enable = 0;
    @(negedge clk) reset = 0;
    @(negedge clk) reset = 1;
    random_enable(30);
    $finish;
end
initial begin
    $monitor("clk=%b reset=%b enable=%b Q=%b TC=%b",clk,reset,enable,Q,TC); 
end
task random_enable;
input integer ciclos_repeticion;
begin
    repeat(ciclos_repeticion) 
    begin 
        @(posedge clk);
        enable<=$random %2;
    end
end
endtask

endmodule