/** @package 

        contador_generico.v
        
        Copyright(c) DIE 2000
        
        Author: RAFAEL GADEA GIRONES
        Created on: 25/02/2004 15:48:49
	Last change: raf 25/02/2004 18:10:04
*/
module contador_variable(clock,reset,variable,enable,entrada,cuenta, fin_cuenta);
 

parameter modulo=16;
localparam  width_counter = clogb2(modulo-1);
localparam  [width_counter-1:0] modulo_good= modulo-1;

input clock; //señal de reloj
input reset; //reset asincrono

input enable;
input variable;
input [width_counter-1:0] entrada;
output reg[width_counter-1:0] cuenta;
output fin_cuenta;





wire [width_counter-1:0] cuenta_fin=(variable)?entrada:modulo_good;
assign fin_cuenta=(cuenta==cuenta_fin)?1'b1:1'b0;
always @(posedge clock or negedge reset)
if (!reset)
        cuenta<=0;
else
	if (enable)
		if (cuenta==cuenta_fin)
			cuenta<=0;
		else
			cuenta<=(cuenta+1'b1);


function integer clogb2 ;
input [31:0] value ; 

for (clogb2=0; value > 0; clogb2=clogb2+1) 
value = value >> 1 ; 
endfunction 
endmodule