module fsm_ones_moore_1 (data_in, clk, reset, detect);
input data_in,clk,reset;
output reg detect; //tipo reg asignado dentro de un always

//binaria natural
reg [1:0] state;

parameter [1:0] S0=2'b00, S1=2'b01, S2=2'b10, S3=2'b11;

//definimos la logica del estado siguiente
always@(posedge clk or negedge reset)
if (!reset)
	state<=S0;
else 
	case (state) //caso que el estado actual es
	S0: if (data_in==1) state<=S1; else state<=S0; //el estado siguiente sera...
	S1: if (data_in==1) state<=S2; else state<=S0;
	S2: if (data_in==1) state<=S3; else state<=S0;
	S3: if (data_in==1) state<=S3; else state<=S0;
	default: state<=S0;
	endcase



//logica de las salidas
always@(state) 
	case (state)
	S0: detect=0;
	S1: detect=0;
	S2: detect=0;
	S3: detect=1;
	default:detect=0;
	endcase


endmodule