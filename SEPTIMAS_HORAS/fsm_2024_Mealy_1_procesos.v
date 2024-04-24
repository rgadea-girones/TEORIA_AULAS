module fsm_ones_mealy_1 (data_in, clk, reset, detect);
input data_in,clk,reset;
output reg detect; //tipo reg asignado dentro de un always

//binaria natural
reg [1:0] state;
parameter [1:0] S0=2'b00, S1=2'b01, S2=2'b10, S3=2'b11;



always@(posedge clk or negedge reset)
if (!reset)
begin
    state<=S0;
    detect<=0;
end
else
    begin
        detect<=0;
        case (state) //caso que el estado actual es
        S0: if (data_in==1) state<=S1; else state<=S0; //el estado siguiente sera...
        S1: if (data_in==1) state<=S2; else state<=S0;
        S2: if (data_in==1) begin state<=S2;detect<=1; end else state<=S0;
        default: state<=S0;
        endcase
    end


	
endmodule