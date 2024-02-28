
module DFF_tb_1;

  // Parameters

  //Ports
  reg  clk;
  reg  d;
  reg  clear;
  wire  q;
  wire  qb;

  DFF_1  DFF_inst (
    .clk(clk),
    .d(d),
    .clear(clear),
    .q(q),
    .qb(qb)
  );

always #5  clk = ! clk ;

initial begin
  $dumpfile("DFF_tb_1.vcd");
  $dumpvars(0,DFF_tb_1);
  clk = 0;
  d = 0;
  clear = 1;
    #10 d = 1;
    #10 d = 0;
    #10 d = 1;
    #10 d = 0;
    #10 d = 1;
#10 clear = 0;
#10 clear = 1;   
#100 $finish;
end

  //Initializations
  initial begin
    $monitor("clk=%b d=%b clear=%b q=%b qb=%b",clk,d,clear,q,qb); 
end
endmodule