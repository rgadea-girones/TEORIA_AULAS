
//tres flip flop
 module 	tres_flip_flops(clk,ES,SS);

 input 	ES;
    input 	SS;
    input 	clk;

reg d2,d1,d3,d4;
    //con un case
assign d1=ES;
    always @(posedge clk) d2=d1;
    always @(posedge clk) d3=d2;
    always @(posedge clk) d4=d3;



assign SS=d4;



endmodule
