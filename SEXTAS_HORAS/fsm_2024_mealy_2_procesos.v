module fsm_ones_mealy_2 (data_in, clk, reset, detect);
input data_in,clk,reset;
output reg detect; //tipo reg asignado dentro de un always

//binaria natural
reg [1:0] state;
parameter [1:0] S0=2'b00, S1=2'b01, S2=2'b10, S3=2'b11;



always@(posedge clk or negedge reset)
if (!reset)
    state<=S0;
else
    case (state) //caso que el estado actual es
    S0: if (data_in==1) state<=S1; else state<=S0; //el estado siguiente sera...
    S1: if (data_in==1) state<=S2; else state<=S0;
    S2: if (data_in==1) state<=S2; else state<=S0;
    default: state<=S0;
    endcase

//logica de las salidas MEALY
always@(state, data_in)
	case (state)
	S0: detect=0;
	S1: detect=0;
	S2: if (data_in) detect=1; else detect=0;
	default:detect=0;
	endcase
	
endmodule