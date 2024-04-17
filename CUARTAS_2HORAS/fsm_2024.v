module fsm_ones_3 (data_in, clk, reset, detect);
input data_in,clk,reset;
output reg detect; //tipo reg asignado dentro de un always

// definicion de estados: hay que decidir una sola.
//binaria natural
reg [1:0] state, next_state;
parameter [1:0] S0=2'b00, S1=2'b01, S2=2'b10, S3=2'b11;

//gray
//reg [1:0] state;
//parameter [1:0] S0=2'b00, S1=2'b10, S2=2'b11, S3=2'b01;

////one-hot
//reg [2:0] state;
//parameter [2:0] S0=3'b000, S1=2'b001, S2=2'b010, S3=2'b100;

////decimal (binaria natural truncando)
//reg [1:0] state;
//parameter [1:0] S0=0, S1=1, S2=2, S3=3;

//definimos la memoria de estado
always@(posedge clk or negedge reset)
if (!reset)
	state<=S0;
else 
	state<=next_state;

//definimos la logica del estado siguiente
always@(data_in, state)
	case (state) //caso que el estado actual es
	S0: if (data_in==1) next_state<=S1; else next_state<=S0; //el estado siguiente sera...
	S1: if (data_in==1) next_state<=S2; else next_state<=S0;
	S2: if (data_in==1) next_state<=S3; else next_state<=S0;
	S3: if (data_in==1) next_state<=S3; else next_state<=S0;
	default: next_state<=S0;
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