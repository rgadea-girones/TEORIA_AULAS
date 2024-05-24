/** @package 

        contador_generico.v
        
        Copyright(c) DIE 2000
        
        Author: RAFAEL GADEA GIRONES
        Created on: 25/02/2004 15:48:49
	Last change: raf 25/02/2004 18:10:04
*/
module contador_generico(clock,reset,enable, fin_cuenta);


parameter modulo=16;
localparam  width_counter = clogb2(modulo-1);
localparam  [width_counter-1:0] modulo_good= modulo-1;

input clock; //señal de reloj
input reset; //reset asincrono

input enable;
output fin_cuenta;


reg [width_counter-1:0] cuenta;

assign fin_cuenta=(cuenta==modulo_good)?1'b1:1'b0;
always @(posedge clock or negedge reset)
if (!reset)
        cuenta<=0;
else
	if (enable)
		if (cuenta==modulo_good)
			cuenta<=0;
		else
			cuenta<=(cuenta+1'b1);


function integer clogb2 ;
input [31:0] value ; 

for (clogb2=0; value > 0; clogb2=clogb2+1) 
value = value >> 1 ; 
endfunction 
endmodule