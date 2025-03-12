module DFF (q,qb,clk,d,clear);
input clk;
input d;
input wire clear;//!activo a nivel bajo
output q;
output qb;
reg q;
wire qb; 

always @(posedge clk, negedge clear)
    if (clear==1'b0)
    begin
        #4 q= 1'b0;
                

    end
    else
        begin	
            #8 q=d;

        end
assign qb = ~q;

endmodule


