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
    . reset( reset),
    . enable( enable),
    .Q(Q),
    .TC(TC)
  );

always #5  clk = ! clk ;
initial //reset activo a nivel bajo y empiezo con reset desactivo
begin
    $dumpfile("cont4bits_tb.vcd");
    $dumpvars(0,cont4bits_tb);
    clk = 0;
    reset = 1;
    enable = 0;
    #10 reset = 0;
    #10 reset = 1;
    #10 enable = 1;
    #10 enable = 0;
    #10 enable = 1;
    #10 enable = 0;
    repeat(30)
    begin 
        @(negedge clk);
        enable=$random %2;
    end
    $finish;
end
initial begin
    $monitor("clk=%b reset=%b enable=%b Q=%b TC=%b",clk,reset,enable,Q,TC); 
end


endmodule