`timescale 1ns / 1ps
module cont4bits_tb;

  // Parameters

  //Ports
  reg  clk;
  reg   reseta_n;
  reg   enable;
  wire [3:0] Q;
  wire  TC;

  cont4bits  cont4bits_inst (
    .clk(clk),
    . reseta_n( reseta_n),
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
    reseta_n = 1;
    enable = 0;
    #10 reseta_n = 0;
    #10 reseta_n = 1;
    #10 enable = 1;
    #10 enable = 0;
    #10 enable = 1;
    #10 enable = 0;
    repeticion(30);   
    $finish;
end
initial begin
    $monitor("clk=%b reseta_n=%b enable=%b Q=%b TC=%b",clk,reseta_n,enable,Q,TC);
end

task repeticion;
input integer ciclos_repeticion;
begin
    repeat(ciclos_repeticion) 
    begin 
        @(posedge clk);
        enable=$random %2;
    end
end
    
endtask
endmodule