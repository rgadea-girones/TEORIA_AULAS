`timescale 1ns / 1ps
module cont4bits_tb_reducido_estimulos

(output  reg  clk,
output reg   reset,
output reg   enable
)

;



always #5  clk = ! clk ;
initial //reset activo a nivel bajo y empiezo con reset desactivo
begin
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