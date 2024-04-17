/* test bench fsm detector de unos */

// definicion de unidad de tiempo/resolucion

`timescale 1 ns/ 100 ps

module tb_fsm_ones();
// definicion de periodo de reloj
localparam T=20;

reg CLK;
reg SECUENCIA_INPUT;
reg RST;
  
wire DETECCION_moore, DETECCION_mealy;

event DET;
always@(DET)
	$display("Caso de Test finalizado\n");

// DUV

fsm_ones_moore_2 DUV_moore
(
	.data_in(SECUENCIA_INPUT) ,	
	.clk(CLK) ,	
	.reset(RST) ,	
	.detect(DETECCION_moore) 	
);

fsm_ones_mealy_2 DUV_mealy
(
	.data_in(SECUENCIA_INPUT) ,	
	.clk(CLK) ,	
	.reset(RST) ,	
	.detect(DETECCION_mealy) 	
);


// DEFINICION DE TEST DE RESET
task RESET();
begin
// Reset de dos ciclos (asincrono)
	RST=1'b0;
	repeat(2) @(negedge CLK);
// Desactivamos el reset
	RST=1'b1;
end
endtask

// DEFINICION DEL RELOJ
always
begin
	#(T/2) CLK = ~CLK;
end



initial                                                
begin
//inicializacion de senales                                               
	CLK=0;
	SECUENCIA_INPUT=0;
	RST=0;
    $dumpfile("fsm_ones_mealy_moore.vcd");
    $dumpvars(0,tb_fsm_ones);

//casos de test
	RESET();
	CASO_1();->DET;
	repeat(5) @(negedge CLK);

	RESET();
	CASO_2();->DET;
	repeat(5) @(negedge CLK);

	RESET();
	CASO_3();->DET;
	repeat(5) @(negedge CLK);
	
	RESET();
	CASO_4();->DET;
	repeat(5) @(negedge CLK);
	
	RESET();
	CASO_5();->DET;
	repeat(5) @(negedge CLK);
	
	$display("Fin de simulacion!!");
	$stop;
end                                                    

task CASO_1();
	// se introducen tres unos seguidos
begin
repeat (3)
	begin
	@(negedge CLK);
	SECUENCIA_INPUT=1'b1;
	end
//terminamos caso poniendo entrada a cero
cero();
end
endtask

task CASO_2();
begin
	// Se introducen mas de tres unos seguidos
repeat(6)
	begin
	@(negedge CLK);
	SECUENCIA_INPUT=1'b1;
	end
	//terminamos caso poniendo entrada a cero
	cero();
end
endtask

task CASO_3();
begin
	// Se introducen 110
repeat(2)
	begin
	@(negedge CLK);
	SECUENCIA_INPUT=1'b1;
	end
@(negedge CLK);
SECUENCIA_INPUT=1'b0;

//terminamos caso poniendo entrada a cero
cero();
end
endtask

task CASO_4();
//se introducen 10101010
begin
	repeat(4)
	begin
	@(negedge CLK);
	SECUENCIA_INPUT=1'b1;
	@(negedge CLK);
	SECUENCIA_INPUT=1'b0;
	end

//terminamos caso poniendo entrada a cero
cero();

end
endtask

task CASO_5();
//introducimos 1101110110
begin
	uno();
	uno();
	cero();
	repeat(3) uno();
	cero();
	repeat(2) uno();
	cero();
end
endtask

task uno();
begin	
	@(negedge CLK);
	SECUENCIA_INPUT=1'b1;
end
endtask

task cero();
begin
	@(negedge CLK);
	SECUENCIA_INPUT=1'b0;
end
endtask

	
endmodule