module DFF_2 (q,qb,clk,d,clear);
input clk,d,clear;
output q,qb;
reg q, qb; 

always @(posedge clk)
    if (clear!=0)
	begin	
	      q= #8  d;
	      qb=#1 ~q;
    end
always wait (clear==0)
begin
	#4 q=0;
	#1 qb= 1;
	wait (clear==1);
end
endmodule


