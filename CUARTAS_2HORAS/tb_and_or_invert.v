`timescale 1ns / 1ps
module and_or_invert_1_tb;

  // Parameters

  //Ports
  reg  A;
  reg  B;
  reg  C;
  reg  D;
  wire  TZ1, TZ2;


  and_or_invert_1  and_or_invert_1_inst (
    .A(A),
    .B(B),
    .C(C),
    .D(D),
    .TZ(TZ1)
  );

  and_or_invert_2  and_or_invert_2_inst (
    .A(A),
    .B(B),
    .C(C),
    .D(D),
    .TZ(TZ2)
  );
//crear combinaciones de A,B,C,D
    initial begin
        A = 0;
        B = 0;
        C = 0;
        D = 0;
        #5  A = 1;
        #5  B = 1;
        #5  C = 1;
        #5  D = 1;
        #5  A = 0;
        #5  B = 0;
        #5  C = 0;
        #5  D = 0;
        #5  $finish;
    end 
    initial begin
        $dumpfile("and_or_invert_1_tb.vcd");
        $dumpvars(0, and_or_invert_1_tb);
    end
//always #5  clk = ! clk ;
    //initial para monitorizar
    initial begin
        $monitor("A=%b B=%b C=%b D=%b TZ1=%b TZ2=%b", A, B, C, D, TZ1, TZ2); 
    end 

always 
//display time
    begin: monitor
        wait(TZ1!==TZ2);
        $display("Error las salidas son diferentes en tiempo %0t ns: TZ1=%b TZ2=%b", $realtime/1e3,TZ1, TZ2);
        @(TZ1,TZ2);
    end

endmodule