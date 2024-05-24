// Quartus II Verilog Template
// 4-State Moore state machine

// A Moore machine's outputs are dependent only on the current state.
// The output is written only when the state changes.  (State
// transitions are synchronous.)


module top_semaforo_ltm_DE2115
(
	input	CLOCK_50,
	input PS2_CLK,
	input PS2_DAT,
	input [3:0] KEY,
	input [17:0] SW,
	output  VGA_CLK, 
	output  VGA_BLANK,
	output  VGA_HS,
	output  VGA_VS,
	output  VGA_SYNC,
	output reg [7:0] VGA_B,
	output reg [7:0] VGA_G,
	output  reg [7:0] VGA_R,
	output  [17:0] LEDR,
	output  [8:0] LEDG,
	output  [6:0] HEX7,
	output  [6:0] HEX6,
	output  [6:0] HEX5,
	output  [6:0] HEX4,
	output  [6:0] HEX3,
	output  [6:0] HEX2,
	output  [6:0] HEX1,
	output  [6:0] HEX0,
	//importante 
	 output TD_RESET, // TV Decoder Reset para habilitar reloj de 27MHZ
	 input CLOCK_27,
	 
	 
	 //para LTM nuevo
	 
	 	//HMSC, HSMC connect to MTLC
	//MTL
output		     [7:0]		LCD_B,
output		          		LCD_DCLK,
output		     [7:0]		LCD_G,
output		          		LCD_HSD,
output		          		TOUCH_I2C_SCL,
inout 		          		TOUCH_I2C_SDA,
input 		          		TOUCH_INT_n,
output		     [7:0]		LCD_R,
output		          		LCD_VSD,

output                     LCD_DITH,
output                     LCD_MODE,
output                     LCD_POWER_CTL,
output                     LCD_UPDN,
output                     LCD_RSTB,
output                     LCD_DE,
output                     LCD_SHLR,
output                     LCD_DIM,
	  // Audio CODEC
  output/*inout*/ AUD_ADCLRCK, // Audio CODEC ADC LR Clock
  input	 AUD_ADCDAT,  // Audio CODEC ADC Data
  output /*inout*/  AUD_DACLRCK, // Audio CODEC DAC LR Clock
  output AUD_DACDAT,  // Audio CODEC DAC Data
  inout	 AUD_BCLK,    // Audio CODEC Bit-Stream Clock
  output AUD_XCK,     // Audio CODEC Chip Clock
	inout [35:0] GPIO_0
);
//parte de conversion de bmp
localparam cruzar="semaforo_cruzar_red.bmp";//input file name
localparam parar="semaforo_parar_red.bmp";//input file name
localparam esperar="semaforo__esperar_red.bmp";//input file name
parameter [7:0] INTENSITY=100;//0-255


//PARTE DE VISUALIZACION

//cuentas de zonas activas de visualizadores

wire [clogb2(479)-1:0]		   pixel_row_vga;
wire [clogb2(639)-1:0]	      pixel_column_vga;

wire [clogb2(479)-1:0]			pixel_row_lcd;
wire  [clogb2(799)-1:0]		pixel_column_lcd;	

wire  [clogb2(96000-1)-1:0]	posicion_memorias;
wire  [clogb2(307200-1)-1:0]	posicion_memorias_vga;

wire [3:0] a_cruzar,a_esperar,a_parar, a_vga;

wire [7:0] caracter;
wire [8:0] direccion_character;
wire [7:0] caracter_vga;
wire [8:0] direccion_character_vga;
reg [5:0] frase;
wire salida;
reg [5:0] frase_vga;
wire salida_vga;
reg [7:0]          ltm_r;
reg [7:0]          ltm_g;
reg [7:0]          ltm_b;

wire preVGA_HS, preVGA_VS;

wire	[2:0]		MASCARA_ZONA3_R;
wire	[2:0]		MASCARA_ZONA3_G;
wire	[2:0]		MASCARA_ZONA3_O;
wire	[2:0]		MASCARA_ZONA2_R;
wire	[2:0]		MASCARA_ZONA2_G;
wire	[2:0]		MASCARA_ZONA2_O;
wire	[2:0]		MASCARA_ZONA1_R;
wire	[2:0]		MASCARA_ZONA1_G;
wire	[2:0]		MASCARA_ZONA1_B;
wire [11:0]		X_COORD;
wire [11:0]		Y_COORD;
wire [8:0]			display_mode;
wire [8:0] 		valor;
wire  sombreado_FSM;
wire [5:0] cuenta;

wire video_on;


//para audio hago un reset 
wire DLY_RST;
Reset_Delay r0(	.iCLK(CLOCK_50),.oRESET(DLY_RST) );



assign activacion_hex 	=8'h77;
assign adc_penirq_n   	=GPIO_0[0];
assign adc_dout       	=GPIO_0[1];
assign adc_busy     		=GPIO_0[2];
assign GPIO_0[3]	 		=adc_din;
assign GPIO_0[4]	 		=adc_ltm_sclk;

assign GPIO_0[9]			=ltm_nclk;
assign GPIO_0[10]			=ltm_den;
assign GPIO_0[11]			=ltm_hd;
assign GPIO_0[12]			=ltm_vd;

assign GPIO_0[16:13]		=ltm_b[7:4];
assign GPIO_0[5]	 		=ltm_b[3];
assign GPIO_0[6]	 		=ltm_b[2];
assign GPIO_0[7]	 		=ltm_b[1];
assign GPIO_0[8]	 		=ltm_b[0];
assign GPIO_0[24:17]		=ltm_g[7:0];
assign GPIO_0[32:25]		=ltm_r[7:0];

assign GPIO_0[33]			=ltm_grst;
assign GPIO_0[34]			=ltm_scen;
assign GPIO_0[35]			=ltm_sda;

assign adc_ltm_sclk	= ( adc_dclk & ltm_3wirebusy_n )  |  ( ~ltm_3wirebusy_n & ltm_sclk );
assign ltm_nclk 		= reloj_25; // 25 Mhz
assign ltm_grst 		= KEY[0];


reg [7:0] VGA_B_data;
reg [7:0] VGA_G_data;
reg [7:0] VGA_R_data;


assign VGA_CLK		= reloj_25;
//assign VGA_SYNC	= ~video_on; //primer gran cambio otra alternativa es 1'b0

//assign VGA_BLANK  =VGA_HS & VGA_VS; //alternativa 1 1'b1 otra alternativa 

/*
assign VGA_SYNC	= 1'b0; //primer gran cambio otra alternativa es 1'b0

assign VGA_BLANK  =1'b1; //alternativa 1 1'b1 otra alternativa 

assign VGA_HS=~preVGA_HS;
assign VGA_VS=~preVGA_VS;
*/
assign MASCARA_ZONA3_R	={3{~out[0]}};
assign MASCARA_ZONA3_G  ={3{out[0]}};
assign MASCARA_ZONA3_O  ={3{~^out[1:0]==1'b1 & cuenta_unidades[0]==1'b1}};
assign MASCARA_ZONA2_R	={3{~out[1]}};
assign MASCARA_ZONA2_G  ={3{out[1]}};
assign MASCARA_ZONA2_O  ={3{~^out[1:0]==1'b1 & cuenta_unidades[0]==1'b1}};
assign MASCARA_ZONA1_R  ={3{^out[1:0]}};
assign MASCARA_ZONA1_G  ={3{~^out[1:0]}};
assign MASCARA_ZONA1_B	={3{display_mode[0]}};


assign posicion_memorias= pixel_column_lcd[clogb2(799)-1:1]+ pixel_row_lcd[clogb2(479)-1:1]*(400);

assign posicion_memorias_vga= pixel_column_vga[clogb2(639)-1:1]+ (239-pixel_row_vga[clogb2(479)-1:1])*(320); //239



rom_asincr #(.contenido_inicial("semaforo_cruzar_400_240.txt"),.posicion_final(95999),.posicion_inicial(0),.d_width(4)) mem_cruzar  (.address(posicion_memorias),

	.dout(a_cruzar));
	
rom_asincr #(.contenido_inicial("semaforo_parar_400_240.txt"),.posicion_final(95999),.posicion_inicial(0),.d_width(4)) mem_parar  (.address(posicion_memorias),

	.dout(a_parar));	
rom_asincr #(.contenido_inicial("semaforo_esperar_400_240.txt"),.posicion_final(95999),.posicion_inicial(0),.d_width(4)) mem_esperar  (.address(posicion_memorias),

	.dout(a_esperar));	

rom_asincr #(.contenido_inicial("Problema_2_1_240_320_def1.txt"),.posicion_final(76799),.posicion_inicial(0),.d_width(4)) mem_vga  (.address(posicion_memorias_vga),

 .dout(a_vga));	
	
rom_asincr #(.contenido_inicial("char_rom.dua"),.posicion_final(511),.posicion_inicial(0),.d_width(8)) mem_caracteres  (.address(direccion_character),
	
	.dout(caracter));
rom_asincr #(.contenido_inicial("char_rom.dua"),.posicion_final(511),.posicion_inicial(0),.d_width(8)) mem_caracteres_vga  (.address(direccion_character_vga),
	
	.dout(caracter_vga));	
	
//	prueba_maxima (
//	.address(posicion_memorias_vga),
//	.clock(reloj_25),
//	.q(a_vga);

assign direccion_character	={frase,pixel_column_lcd[5:3]};
assign salida=caracter[7-pixel_row_lcd[5:3]];
assign direccion_character_vga	={frase_vga,pixel_row_vga[4:2]};
assign salida_vga=~caracter_vga[7-pixel_column_vga[4:2]];//negado para escribir en negro	
//assign salida_vga=1'b1;
//assign A_vga=4'b1111;
/*parar_red mem2 (.address(posicion_memorias),
	.clock(reloj_25),
	.q(a_parar));
cruzar_red mem3 (.address(posicion_memorias),
	.clock(reloj_25),
	.q(a_cruzar));	
*/
//always @(*) 
//begin
//	VGA_R[9:0] = {10{1'b0}};
//	VGA_G[9:0] = {10{1'b0}};
//	VGA_B[9:0] = {10{1'b0}};
//	if (pixel_column_vga>420) //semaforo NS
//			if (pixel_row_vga>320)
//			begin
//				VGA_R[9:7] =MASCARA_ZONA3_R;
//				VGA_G[9:7] =3'b000;
//				VGA_B[9:7] =3'b000;
//			end
//			else if ((pixel_row_vga>160))
//			begin
//				VGA_R[9:7] =MASCARA_ZONA3_O;
//				VGA_G[9:7] =3'b100 & MASCARA_ZONA3_O;
//				VGA_B[9:7] =3'b000;
//			end
//			else
//			begin
//				VGA_R[9:7] =3'b000;
//				VGA_G[9:7] =MASCARA_ZONA3_G;
//				VGA_B[9:7] =3'b000;
//			end
//
//	else if (pixel_column_vga>210)//semaforo EO
//			if (pixel_row_vga>320)
//			begin
//				VGA_R[9:7] =MASCARA_ZONA2_R;
//				VGA_G[9:7] =3'b000;
//				VGA_B[9:7] =3'b000;
//			end
//			else if ((pixel_row_vga>160))
//			begin
//				VGA_R[9:7] =MASCARA_ZONA2_O;
//				VGA_G[9:7] =3'b100&MASCARA_ZONA2_O;
//				VGA_B[9:7] =3'b000;
//			end
//			else
//			begin
//				VGA_R[9:7] =3'b000;
//				VGA_G[9:7] =MASCARA_ZONA2_G;
//				VGA_B[9:7] =3'b000;
//			end
//	else//semaforo peatones
//			if (pixel_row_vga>320)
//			begin
//				VGA_R[9:7] =MASCARA_ZONA1_R;
//				VGA_G[9:7] =3'b000;
//				VGA_B[9:7] =3'b000;
//			end
//			else if ((pixel_row_vga>160))
//			begin
//				VGA_R[9:7] =3'b000;
//				VGA_G[9:7] =3'b000;
//				VGA_B[9:7] =3'b000;
//			end
//			else
//			begin
//				VGA_R[9:7] =3'b000;
//				VGA_G[9:7] =MASCARA_ZONA1_G;
//				VGA_B[9:7] =3'b000;
//			end
//end 
//
//always @(*) 
//begin
//	VGA_R[9:0] = {10{salida_vga}};
//	VGA_G[9:0] = {10{salida_vga}};
//	VGA_B[9:0] = {10{salida_vga}};
//	//semaforo NS
//			if ((pixel_row_vga-400)**2+(pixel_column_vga-533)**2< 6000)
//			begin
//				VGA_R[9:7] =MASCARA_ZONA3_R;
//				VGA_G[9:7] =3'b000;
//				VGA_B[9:7] =3'b000;
//			end
////			if ((pixel_row_vga-240)**2+(pixel_column_vga-533)**2< 6000)
////			begin
////				VGA_R[9:7] =MASCARA_ZONA3_O;
////				VGA_G[9:7] =3'b100 & MASCARA_ZONA3_O;
////				VGA_B[9:7] =3'b000;
////			end
//			if ((pixel_row_vga-80)**2+(pixel_column_vga-533)**2< 6000)
//			begin
//				VGA_R[9:7] =3'b000;
//				VGA_G[9:7] =MASCARA_ZONA3_G;
//				VGA_B[9:7] =3'b000;
//			end
//
//			//semaforo EO
//			if ((pixel_row_vga-400)**2+(pixel_column_vga-320)**2< 6000)
//			begin
//				VGA_R[9:7] =MASCARA_ZONA2_R;
//				VGA_G[9:7] =3'b000;
//				VGA_B[9:7] =3'b000;
//			end
////			if ((pixel_row_vga-240)**2+(pixel_column_vga-320)**2< 6000)
////			begin
////				VGA_R[9:7] =MASCARA_ZONA2_O;
////				VGA_G[9:7] =3'b100&MASCARA_ZONA2_O;
////				VGA_B[9:7] =3'b000;
////			end
//			if ((pixel_row_vga-80)**2+(pixel_column_vga-320)**2< 6000)
//			begin
//				VGA_R[9:7] =3'b000;
//				VGA_G[9:7] =MASCARA_ZONA2_G;
//				VGA_B[9:7] =3'b000;
//			end
//	//semaforo peatones
//			if ((pixel_row_vga-400)**2+(pixel_column_vga-107)**2< 6000)
//			begin
//				VGA_R[9:7] =MASCARA_ZONA1_R;
//				VGA_G[9:7] =3'b000;
//				VGA_B[9:7] =3'b000;
//			end
////			if ((pixel_row_vga-240)**2+(pixel_column_vga-107)**2< 6000)
////			begin
////				VGA_R[9:7] =3'b000;
////				VGA_G[9:7] =3'b000;
////				VGA_B[9:7] =3'b000;
////			end
//			if ((pixel_row_vga-80)**2+(pixel_column_vga-107)**2< 6000)
//			begin
//				VGA_R[9:7] =3'b000;
//				VGA_G[9:7] =MASCARA_ZONA1_G;
//				VGA_B[9:7] =3'b000;
//			end
//end 

always_comb
begin
   	frase_vga=6'b100000; //por defecto tengo la salida a 1 y por tanto dejo pasar imagen bmp

		VGA_R_data[7:0] ={8{a_vga[3]}}& {8{salida_vga}};
		VGA_G_data[7:0] = {a_vga[2],{7{a_vga[1]}}}& {8{salida_vga}}; 
		VGA_B_data[7:0] = {8{a_vga[0]}}& {8{salida_vga}}&{8{sombreado_FSM}};
	/*	
		VGA_R[7:0] ={8{1'b1}}& {8{salida_vga}};
		VGA_G[7:0] = {1'b1,{7{1'b1}}}& {8{salida_vga}}; 
		VGA_B[7:0] = {8{1'b1}}& {8{salida_vga}}&{8{sombreado_FSM}};
		*/
          //solo aqui filtro para escribir en negro

				if ( out[0]==1'b1)//semaforo en verde el norte sur
				begin
					if (pixel_row_vga[clogb2(479)-1:5]>=12 & pixel_row_vga[clogb2(479)-1:5]<13)
							case (pixel_column_vga[clogb2(639)-1:5])
								1:frase_vga={2'b11,temporizacion-cuenta_decenas};//O
								2:frase_vga={2'b11,4'b1001-cuenta_unidades};//T
							endcase
					if ((pixel_row_vga-300)**2+(pixel_column_vga-207)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end
					if ((pixel_row_vga-221)**2+(pixel_column_vga-127)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b11111111;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end	
					if ((pixel_row_vga-300)**2+(pixel_column_vga-127)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end				
					if ((pixel_row_vga-221)**2+(pixel_column_vga-42)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end					
					if ((pixel_row_vga-300)**2+(pixel_column_vga-42)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b11111111;
						VGA_B_data[7:0] =8'b00000000;
					end					
				end 
				else  if ( out[1]==1'b1) //semaforo en verde el EO
				begin
					if (pixel_row_vga[clogb2(479)-1:5]>=12 & pixel_row_vga[clogb2(479)-1:5]<13)
							case (pixel_column_vga[clogb2(639)-1:5])
								3:frase_vga={2'b11,temporizacion-cuenta_decenas};//O
								4:frase_vga={2'b11,4'b1001-cuenta_unidades};//T
							endcase
					if ((pixel_row_vga-300)**2+(pixel_column_vga-207)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end
					if ((pixel_row_vga-221)**2+(pixel_column_vga-127)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end	
					if ((pixel_row_vga-300)**2+(pixel_column_vga-127)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b11111111;
						VGA_B_data[7:0] =8'b00000000;
					end				
					if ((pixel_row_vga-221)**2+(pixel_column_vga-42)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b11111111;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end					
					if ((pixel_row_vga-300)**2+(pixel_column_vga-42)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end		
		      end			
				else if ( out[1:0]==2'b00) //semaforo en verde el peatones
				begin
					if (pixel_row_vga[clogb2(479)-1:5]>=12 & pixel_row_vga[clogb2(479)-1:5]<13)
							case (pixel_column_vga[clogb2(639)-1:5])
								6:frase_vga={2'b11,temporizacion-cuenta_decenas};//O
								7:frase_vga={2'b11,4'b1001-cuenta_unidades};//T
							endcase
					if ((pixel_row_vga-221)**2+(pixel_column_vga-207)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end
					if ((pixel_row_vga-221)**2+(pixel_column_vga-127)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b11111111;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end	
					if ((pixel_row_vga-300)**2+(pixel_column_vga-127)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end				
					if ((pixel_row_vga-221)**2+(pixel_column_vga-42)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b11111111;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end					
					if ((pixel_row_vga-300)**2+(pixel_column_vga-42)**2< 1000)
					begin
						VGA_R_data[7:0] =8'b00000000;
						VGA_G_data[7:0] =8'b00000000;
						VGA_B_data[7:0] =8'b00000000;
					end				

				end	

				
end 

always @(*) //para sombrear los estados de amarillo
begin
//por defecto tengo la salida a 1 y por tanto dejo pasar imagen bmp
				sombreado_FSM=1'b1; //por defecto no bloque el azul, si bloqueo aparecera el amarillo

          //solo aqui filtro para escribir en negro

	
				case (state)
					NS:
					if ((pixel_row_vga-209)**2+(pixel_column_vga-360)**2< 1000)
						sombreado_FSM = 1'b0;
					EO:
					if ((pixel_row_vga-209)**2+(pixel_column_vga-550)**2< 1000)
						sombreado_FSM = 1'b0;
					PNS:
					if ((pixel_row_vga-442)**2+(pixel_column_vga-360)**2< 1000)
						sombreado_FSM = 1'b0;
					PEO:
					if ((pixel_row_vga-442)**2+(pixel_column_vga-550)**2< 1000)
						sombreado_FSM = 1'b0;
					ESPNS:
					if ((pixel_row_vga-330)**2+(pixel_column_vga-360)**2< 1000)
						sombreado_FSM = 1'b0;
					ESPEO:
					if ((pixel_row_vga-330)**2+(pixel_column_vga-550)**2< 1000)
						sombreado_FSM = 1'b0;		
					default:
						sombreado_FSM = 1'b1; 
				endcase
				
end 


always @(posedge reloj_25)
begin
	ltm_r[7:0] = {8{1'b0}};
	ltm_g[7:0] = {8{1'b0}};
	ltm_b[7:0] = {8{1'b0}};
	if (pixel_column_lcd[clogb2(799)-1:5]<15)
		if (^out[1:0]==1'b0)
				begin
					ltm_r ={8{a_cruzar[3]}};
					ltm_g ={a_cruzar[2],{7{a_cruzar[1]}}};
					ltm_b ={8{a_cruzar[0]}};
				end
		else 	
				if (  out[2]==1'b1)
				begin
					ltm_r ={8{a_esperar[3]}};
					ltm_g ={a_esperar[2],{7{a_esperar[1]}}};
					ltm_b ={8{a_esperar[0]}};
				end
				else 
				begin
					ltm_r ={8{a_parar[3]}};
					ltm_g ={a_parar[2],{7{a_parar[1]}}};
					ltm_b ={8{a_parar[0]}};
				end
	else
		begin
					ltm_r ={8{salida}};
					ltm_g ={8{salida}};
					ltm_b ={8{salida}};	
					if (out[2]==1'b0 & ^out[1:0]==1'b1 & cuenta_unidades[0]==1'b1)
						begin
						if ((pixel_row_lcd[clogb2(479)-1:6]>0 & pixel_row_lcd[clogb2(479)-1:6]<6)&(pixel_column_lcd[clogb2(799)-1:5]==19 | pixel_column_lcd[clogb2(799)-1:5]==22))
							begin
									ltm_r ={8{1'b1}};
									ltm_g ={8{1'b0}};
									ltm_b ={8{1'b0}};	
							end
						if ((pixel_row_lcd[clogb2(479)-1:5]==1 | pixel_row_lcd[clogb2(479)-1:5]==12)&pixel_column_lcd[clogb2(799)-1:5]>=19 & pixel_column_lcd[clogb2(799)-1:5]<=22)
							begin
									ltm_r ={8{1'b1}};
									ltm_g ={8{1'b0}};
									ltm_b ={8{1'b0}};	
							end
						end
		end

end 

//control de caracteres
always @(*)
	begin
	frase=6'b100000;
	if (pixel_column_lcd[clogb2(799)-1:5]>=16 & pixel_column_lcd[clogb2(799)-1:5]<18)
		if (^out[1:0]==1'b0)
			case (pixel_row_lcd[clogb2(479)-1:6])
				1: frase=6'o03;//C
				2: frase=6'o22;//R
				3: frase=6'o25;//U
				4: frase=6'o32;//Z
				5: frase=6'o01;//A
				6: frase=6'o22;//R
			endcase
		else if (out[2]==1'b1)
			case (pixel_row_lcd[clogb2(479)-1:6])
				0: frase=6'o05;//E
				1: frase=6'o23;//S
				2: frase=6'o20;//P
				3: frase=6'o05;//E
				4: frase=6'o22;//R
				5: frase=6'o01;//A
				6: frase=6'o22;//R
	
			endcase				
		else
			case (pixel_row_lcd[clogb2(479)-1:6])
				1: frase=6'o20;//P
				2: frase=6'o25;//U
				3: frase=6'o14;//L
				4: frase=6'o23;//S
				5: frase=6'o01;//A
				6: frase=6'o22;//R	

			endcase
	if (pixel_column_lcd[clogb2(799)-1:5]>=20 & pixel_column_lcd[clogb2(799)-1:5]<22)
			
		if (out[2]==1'b1)
			case (pixel_row_lcd[clogb2(479)-1:6])

				1: frase=6'o26;//V
				2: frase=6'o05;//E
				3: frase=6'o22;//R
				4: frase=6'o04;//D
				5: frase=6'o05;//E		
			endcase
		else			if (^out[1:0]==1'b1)
			case (pixel_row_lcd[clogb2(479)-1:6])
			  // 0: frase=6'o33;//reborde
				1: frase=6'o02;//B
				2: frase=6'o17;//O
				3: frase=6'o24;//T
				4: frase=6'o17;//O
				5: frase=6'o16;//N
			//	6: frase=6'o35;
			endcase	
		else
			case (pixel_row_lcd[clogb2(479)-1:6])

				3: frase={2'b11,temporizacion-cuenta_decenas};//O
				4: frase={2'b11,4'b1001-cuenta_unidades};//T

			endcase	
	end		


					//control de caracteres
//always @(*)
//	begin
//	frase_vga=6'b100000;
//		if (pixel_row_vga[clogb2(479)-1:5]>=7 & pixel_row_vga[clogb2(479)-1:5]<8)
//			case (pixel_column_vga[clogb2(639)-1:5])
//				15: frase_vga=6'o05;//E
//				16: frase_vga=6'o17;//O
//				9: frase_vga=6'o16;//N
//				10: frase_vga=6'o23;//S
//				2: frase_vga=6'o20;//P
//				3: frase_vga=6'o24;//T
//			endcase
//	if (pixel_row_vga[clogb2(479)-1:5]>=8 & pixel_row_vga[clogb2(479)-1:5]<9)	
//
//				if ( pixel_column_vga>426 &&out[0]==1'b1)
//							case (pixel_column_vga[clogb2(479)-1:5])
//								15:frase_vga={2'b11,temporizacion-cuenta_decenas};//O
//								16:frase_vga={2'b11,4'b1001-cuenta_unidades};//T
//							endcase
//					else  if ( pixel_column_vga>213 &&out[1]==1'b1)
//							case (pixel_column_vga[clogb2(479)-1:5])
//								9:frase_vga={2'b11,temporizacion-cuenta_decenas};//O
//								10:frase_vga={2'b11,4'b1001-cuenta_unidades};//T
//							endcase
//					else if ( pixel_column_vga<213 &&out[1:0]==2'b00)
//							case (pixel_column_vga[clogb2(479)-1:5])
//								2:frase_vga={2'b11,temporizacion-cuenta_decenas};//O
//								3:frase_vga={2'b11,4'b1001-cuenta_unidades};//T
//							endcase
//
//			
//	end		
//relojes
pll_LTM_VGA generador_relojes
					(
					.inclk0(CLOCK_50),
					.c0(reloj_25));

//bloques de sincronismos de selaes de visualizacion

/*
LTM_SYNC_BASE 
					#(
					.H_SYNC_CYC(96),//96
					.H_SYNC_BACK(48),//44
					.H_SYNC_ACT(640),//640
					.H_SYNC_FRONT(16), //20
					.H_SYNC_TOTAL(800),//800
					.V_SYNC_CYC(2),
					.V_SYNC_BACK(33),//35
					.V_SYNC_ACT(480),
					.V_SYNC_FRONT(10),//16
					.V_SYNC_TOTAL(525)) visualizador1
					(
					.clock_25Mhz(reloj_25),
					.horiz_sync_out(preVGA_HS),
					.vert_sync_out(preVGA_VS),
					.video_on(video_on),
					.pixel_row(pixel_row_vga), 
					.pixel_column(pixel_column_vga));
*/

LTM_SYNC_BASE 
					#(
					.H_SYNC_CYC(1),
					.H_SYNC_BACK(216),
					.H_SYNC_ACT(800),
					.H_SYNC_FRONT(39),
					.H_SYNC_TOTAL(1056),
					.V_SYNC_CYC(1),
					.V_SYNC_BACK(34),
					.V_SYNC_ACT(480),
					.V_SYNC_FRONT(10),
					.V_SYNC_TOTAL(525)) visualizador2
					(
					.clock_25Mhz(reloj_25),
					.horiz_sync_out(ltm_hd),
					.vert_sync_out(ltm_vd),
					.video_on(ltm_den),
					.pixel_row(pixel_row_lcd), 
					.pixel_column(pixel_column_lcd));


wire iRST_n		=	KEY[0];

//configuraci�n spi de chips del lcd y convertidor ADC del touch
lcd_spi_cotroller  config_LTM
					(	
					//Host Side
					.iCLK(CLOCK_50),
					.iRST_n(iRST_n),
					//	I2C Side
					.o3WIRE_SCLK(ltm_sclk),
					.io3WIRE_SDAT(ltm_sda),
					.o3WIRE_SCEN(ltm_scen),
					.o3WIRE_BUSY_n(ltm_3wirebusy_n));
							
adc_spi_controller		config_ADC_TOUCH
					
					(
					.iCLK(CLOCK_50),
					.iRST_n(iRST_n),
					.oADC_DIN(adc_din),
					.oADC_DCLK(adc_dclk),
					.oADC_CS(adc_cs),
					.iADC_DOUT(adc_dout),
					.iADC_BUSY(adc_busy),
					.iADC_PENIRQ_n(adc_penirq_n),
					.oTOUCH_IRQ(touch_irq),
					.oX_COORD(X_COORD),
					.oY_COORD(Y_COORD),
					.oNEW_COORD(new_coord));							
//control de que gacer con el punto capturado						
touch_irq_detector	detector_tactil	

					(
					.iCLK(CLOCK_50),
					.iRST_n(iRST_n),
					.reset_boton(reset_boton),
					.iTOUCH_IRQ(touch_irq),
					.iX_COORD(X_COORD),
					.iY_COORD(Y_COORD),
					.iNEW_COORD(new_coord),
					.boton_pulsado(boton_pulsado),
					.oDISPLAY_MODE(display_mode),
					.ovalor(valor)	);
/*parte de audio con cosas interesantes*/					
//parte completa de audio 
assign	TD_RESET = 1'b1;  // Enable 27 MHz

Audio_PLL_good2 	p1 (	
	.areset(~DLY_RST),
	.inclk0(CLOCK_27),
	.c0(AUD_CTRL_CLK)

);

I2C_AV_Config u3(	
//	Host Side
  .iCLK(CLOCK_50),
  .iRST_N(KEY[0]),
//	I2C Side
  .I2C_SCLK(I2C_SCLK),
  .I2C_SDAT(I2C_SDAT)	
);

assign	AUD_ADCLRCK	=	AUD_DACLRCK;
assign	AUD_XCK		=	AUD_CTRL_CLK;

audio_clock u4(	
//	Audio Side
   .oAUD_BCK(AUD_BCLK),
   .oAUD_LRCK(AUD_DACLRCK),
//	Control Signals
  .iCLK_18_4(AUD_CTRL_CLK),
   .iRST_N(DLY_RST)	
);

audio_converter u5(
	// Audio side
	.AUD_BCK(AUD_BCLK),       // Audio bit clock
	.AUD_LRCK(AUD_DACLRCK), // left-right clock
	.AUD_ADCDAT(AUD_ADCDAT),
	.AUD_DATA(AUD_DACDAT),
	// Controller side
	.iRST_N(DLY_RST),  // reset
	.AUD_outL(audio_outL),
	.AUD_outR(audio_outR),
	.AUD_inL(audio_inL),
	.AUD_inR(audio_inR)
);

wire [15:0] audio_inL, audio_inR;
wire [15:0] audio_outL, audio_outR, audio_outR_pre;
wire [15:0] signal;
					

//set up DDS frequency
//Use switches to set freq
wire [31:0] dds_incr;
wire [31:0] freq = SW[3:0]+10*SW[7:4]+100*{cuenta_unidades[0],3'b000}+1000*{2'b00,2'b10};//+10000*SW[17:16];
assign dds_incr = freq * 89590 ; //91626 = 2^32/46875 so SW is in Hz

reg [31:0] dds_phase;

always @(negedge AUD_DACLRCK or negedge DLY_RST)
	if (!DLY_RST) dds_phase <= 0;
	else dds_phase <= dds_phase + dds_incr;

wire [7:0] index = dds_phase[31:24];

 
sine_table sig1(
	.index(index),
	.signal(audio_outR_pre)
);

	//audio_outR <= audio_inR;

//always @(posedge AUD_DACLRCK)
assign audio_outL = 15'h0000;
assign audio_outR =  ^out[1:0]?15'h0000:audio_outR_pre;
				
					
/*parte de control general FSM t�pica*/
// PARTE DE MAQUINA DE ESTADOS DE SEMAFORO
	(*syn_encoding="user,safe"*) reg		[5:0]state,next_state;
	reg [2:0] out;//NS EO 
	// Declare states
	parameter NS = 0, EO = 1, PNS = 3, PEO = 5, ESPNS=9  , ESPEO=16;
	wire reset=KEY[0];
	wire clk=CLOCK_50;
	wire enable=SW[0]; //ENABLE GENERAL TEMPORIZADOR
	wire [3:0] temporizacion;//CONTROL DE TEMPORIZACIONES DESDE EL USUARIO
	wire [3:0] cuenta_unidades, cuenta_decenas;
	wire en_final,en_segundos,en_decenas;
	wire boton_pulsado;
	wire TC=en_final&enable&en_segundos&en_decenas;//ENTRADA DE TEMPORIZACI�N fsm
	wire P=(~KEY[3])|boton_pulsado; //ENTRADA DE PEATONES fsm
	wire reset_boton=^out[1:0]; //reset del boton activo a nivel bajo

	assign LEDG[8]=out[1];
	assign LEDR[11]=~out[1]; //SEMAFORO EO
	
	assign LEDG[7]=out[0];
	assign LEDR[0]=~out[0];	//SEMAFORO NS

	// Output depends only on the state
	always @ (state) begin
		case (state)
			NS:
				out = 3'b001;
			EO:
				out = 3'b010;
			PNS:
				out = 3'b000;
			PEO:
				out = 3'b000;
			ESPNS:
				out = 3'b101;
			ESPEO:
				out = 3'b110;				
			default:
				out = 3'b000; //si hay un espureo ponemos los sem�foros en rojo
		endcase
	end

	// Determine the next state
	always @ (posedge clk or negedge reset) 
		if (!reset)
			state <= PNS;
		else
		  if (LOAD)
			state=cuenta;
		  else
			case (state)
				NS: if (TC) 
						begin
							if(!P)
								state = EO;
							else
								state=PNS;		
						end
					 else
						if (P) state=ESPNS;
				EO:if (TC)
						if(!P)
							state = NS;
						else
							state=PEO;
							
					 else
						if (P) state=ESPEO;
				PNS:
					if (TC)
						state = EO;
				PEO:
					if (TC)
						state = NS;						

				ESPEO:
					if (TC)
						state = PEO;
				ESPNS:
					if (TC)
						state = PNS;
			endcase

  
  
// // Determine the next state
//	always @ (posedge clk or negedge reset) 
//		if (!reset)
//			state <= PNS;
//		else
//		  if (LOAD)
//			state=cuenta;
//		  else
//		  state<=next_state;
//
//		always @ (state, P,TC) begin
//		   next_state=state;
//			case (state)
//				NS: if (TC) 
//						begin
//							if(!P)
//								next_state = EO;
//							else
//								next_state=PNS;		
//						end
//					 else
//						if (P) next_state=ESPNS;
//				EO:if (TC)
//						if(!P)
//							next_state = NS;
//						else
//							next_state=PEO;
//							
//					 else
//						if (P) next_state=ESPEO;
//				PNS:
//					if (TC)
//						next_state = EO;
//				PEO:
//					if (TC)
//						next_state = NS;						
//
//				ESPEO:
//					if (TC)
//						next_state = PEO;
//				ESPNS:
//					if (TC)
//						next_state = PNS;
//				default:
//				   next_state=6'bxxx;
//			endcase
//  end 
//  
//PARTE DE TEMPORIZACION DE SEMAFORo: maquinas FSM secundarias
contador_generico #(.modulo(50000000)) divisor (
.clock(clk),.reset(reset),.enable(enable), .fin_cuenta(en_segundos));

contador_variable #(.modulo(10)) unidades (
.clock(clk),
.reset(reset),
.variable(1'b0),
.enable(en_segundos&enable),
.cuenta(cuenta_unidades),
.fin_cuenta(en_decenas));


assign temporizacion=(^out[1:0]==1'b0)? SW[4:1]: ((out[1]==1'b1)?SW[17:14]:SW[10:7]);
contador_variable #(.modulo(16)) decenas (
.clock(clk),
.reset(reset),
.variable(1'b1), 
.entrada(temporizacion), 
.enable(enable&en_segundos&en_decenas),
.cuenta(cuenta_decenas), 
.fin_cuenta(en_final));


//para generar estados espureos
contador_up_down #(.modulo(64)) u2(.clock (CLOCK_50), .cuenta(cuenta),.enable(ENABLE),.up_down(UP_DOWN),.reset(reset));
//maquina de estados speed
reg Q; //variable de estado
wire D; //estado siguiente
wire ENABLE,UP_DOWN,LOAD; //salidas
wire A=KEY[2];
wire B=KEY[1];
assign LEDG[5:0]=cuenta;
assign LEDR[17:12]=state;

always @(posedge CLOCK_50, negedge reset)
begin
if (!reset)
	Q=1'b0;
else
	Q=D;
end
assign D=(A^B);
assign ENABLE=(A^B)&~Q;
assign UP_DOWN=~A;
assign LOAD=A&B&Q;
/*algo de visualizacion*/
//VISUALIZADORES TEMPORIZACION DIRECCION NS	
SEG7_LUT	ver_unidades_NS( 
	.iDIG(cuenta_unidades),
	.oSEG(HEX6),
	.ON_OFF(out[1]));
SEG7_LUT	ver_decenas_NS( 
	.iDIG(cuenta_decenas),
	.oSEG(HEX7),
	.ON_OFF(out[1]));
//VISUALIZADORES TEMPORIZACION DIRECION EO	
SEG7_LUT	ver_unidades_EO( 
	.iDIG(cuenta_unidades),
	.oSEG(HEX4),
	.ON_OFF(out[0]));
SEG7_LUT	ver_decenas_EO( 
	.iDIG(cuenta_decenas),
	.oSEG(HEX5),
	.ON_OFF(out[0]));	
//VISUALIZADORES TEMPORIZACION PEATONES	
SEG7_LUT	ver_unidades_peatones( 
	.iDIG(cuenta_unidades),
	.oSEG(HEX0),
	.ON_OFF(~^out[1:0]));
SEG7_LUT	ver_decenas_peatones( 
	.iDIG(cuenta_decenas),
	.oSEG(HEX1),
	.ON_OFF(~^out[1:0]));		
//APAGAR VISUALIZADORES NO USADOS
SEG7_LUT	apagar2( 
	.iDIG(cuenta_unidades),
	.oSEG(HEX2),
	.ON_OFF(1'b0));
SEG7_LUT	apagar3( 
	.iDIG(cuenta_decenas),
	.oSEG(HEX3),
	.ON_OFF(1'b0));	

/* funciones utilizadas */
function integer clogb2 ;
input [31:0] value ; 

for (clogb2=0; value > 0; clogb2=clogb2+1) 
value = value >> 1 ; 
endfunction 	
parameter H_ACTIVE 						= 640;
parameter H_FRONT_PORCH					=  16;
parameter H_SYNC							=  96;
parameter H_BACK_PORCH 					=  48;
parameter H_TOTAL 						= 800;

/* Number of lines */
parameter V_ACTIVE 						= 480;
parameter V_FRONT_PORCH					=  10;
parameter V_SYNC							=   2;
parameter V_BACK_PORCH 					=  33;
parameter V_TOTAL							= 525;

parameter LW								= 10;
parameter LINE_COUNTER_INCREMENT		= 10'h001;

parameter PW								= 10;
parameter PIXEL_COUNTER_INCREMENT	= 10'h001;


wire						vga_blank_sync;
wire						vga_c_sync;
wire						vga_h_sync;
wire						vga_v_sync;
wire						vga_data_enable;
wire			[7: 0]	vga_red;
wire			[7: 0]	vga_green;
wire			[7: 0]	vga_blue;


always @(posedge reloj_25)
begin
	VGA_BLANK	<= vga_blank_sync;
	VGA_SYNC		<= 1'b0;
	VGA_HS		<= vga_h_sync;
	VGA_VS		<= vga_v_sync;
	VGA_R			<= vga_red;
	VGA_G			<= vga_green;
	VGA_B			<= vga_blue;
end
/*
always @(posedge reloj_25)
begin
	VGA_BLANK	<= 1'b1;
	VGA_SYNC		<= 1'b0;
	VGA_HS		<= ~preVGA_HS;
	VGA_VS		<= ~preVGA_HS;
	VGA_R			<= VGA_R_datap;
	VGA_G			<= VGA_G_datap;
	VGA_B			<= VGA_B_datap;
end

*/

logic [7:0] VGA_B_datap;
logic [7:0] VGA_G_datap;
logic [7:0] VGA_R_datap;
always_comb
begin
		VGA_R_datap[7:0] ={8{a_vga[3]}}& {8{salida_vga}};
		VGA_G_datap[7:0] = {a_vga[2],{7{a_vga[1]}}}& {8{salida_vga}}; 
		VGA_B_datap[7:0] = {8{a_vga[0]}}& {8{salida_vga}}&{8{sombreado_FSM}};
end
altera_up_avalon_video_vga_timing_rafa VGA_Timing (
	// Inputs
	.clk							(reloj_25),
	.reset						(!reset),

	.red_to_vga_display		(VGA_R_data),
	.green_to_vga_display	(VGA_G_data),
	.blue_to_vga_display		(VGA_B_data),
/*	
	.red_to_vga_display		(8'b00000000),
	.green_to_vga_display	(8'b11111111),
	.blue_to_vga_display		(8'b00000000),
*/
//	.data_valid					(1'b1),

	// Bidirectionals

	// Outputs
	.read_enable				(read_enable),

	.end_of_active_frame		(end_of_active_frame),
	.end_of_frame				(), // (end_of_frame),

	// dac pins
	.pixel_counter				(pixel_column_vga),
	.line_counter				(pixel_row_vga),
	.vga_blank					(vga_blank_sync),
	.vga_c_sync					(vga_c_sync),
	.vga_h_sync					(vga_h_sync),
	.vga_v_sync					(vga_v_sync),
	.vga_data_enable			(vga_data_enable),
	.vga_red						(vga_red),
	.vga_green					(vga_green),
	.vga_blue					(vga_blue),

);
defparam
	VGA_Timing.CW 									= 7,

	VGA_Timing.H_ACTIVE 							= H_ACTIVE,
	VGA_Timing.H_FRONT_PORCH					= H_FRONT_PORCH,
	VGA_Timing.H_SYNC								= H_SYNC,
	VGA_Timing.H_BACK_PORCH 					= H_BACK_PORCH,
	VGA_Timing.H_TOTAL 							= H_TOTAL,

	VGA_Timing.V_ACTIVE 							= V_ACTIVE,
	VGA_Timing.V_FRONT_PORCH					= V_FRONT_PORCH,
	VGA_Timing.V_SYNC								= V_SYNC,
	VGA_Timing.V_BACK_PORCH		 				= V_BACK_PORCH,
	VGA_Timing.V_TOTAL							= V_TOTAL,

	VGA_Timing.LW									= LW,
	VGA_Timing.LINE_COUNTER_INCREMENT		= LINE_COUNTER_INCREMENT,

	VGA_Timing.PW									= PW,
	VGA_Timing.PIXEL_COUNTER_INCREMENT		= PIXEL_COUNTER_INCREMENT;



endmodule
