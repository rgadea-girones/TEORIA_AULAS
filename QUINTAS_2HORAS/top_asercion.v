`define VERIFICACION
// Activado el proceso de verificacion

module top ;

reg [3:0] GNT_n;

initial begin
GNT_n = 4'b0000;
#5 GNT_n = 4'b0001;
#5 GNT_n = 4'b0010;
#5 GNT_n = 4'b0100;
#5 GNT_n = 4'b1000;
#5 GNT_n = 4'b1111;
#5 $finish;
end
	`ifdef VERIFICACION

pepito #(4) VERIF_1(GNT_n);


	`endif 



endmodule


