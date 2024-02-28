
module DFF_tb;

  // Parameters

  //Ports
  reg  clk;
  reg  d;
  reg  clear;
  wire  q;
  wire  qb;

  DFF  DFF_inst (
    .clk(clk),
    .d(d),
    .clear(clear),
    .q(q),
    .qb(qb)
  );

always #5  clk = ! clk ;

initial begin
  $dumpfile("DFF_tb.vcd");
  $dumpvars(1, DFF_tb);
  #100 $finish;
end
initial begin
  clk = 0;
  d = 1;
  clear = 1;
  #7 clear = 0;
  #10   d = 0;
  #6  clear=1;
  #17 d=1;
  #7 d=0;  
end



endmodule


