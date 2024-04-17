
module pepito(GNT_n);

parameter masters = 4;
input [(masters-1):0] GNT_n;
integer aux;
integer i;

always @( GNT_n )
	begin
	aux = 0;
	i = 0;
	for(i = 0; i < masters; i = i + 1)
		begin
		if (GNT_n[i] == 1) aux = aux+1;
		end	
	if (aux > 1)
		begin
		$display("Error en asercion: Más de un master toma el bus");
		$display($time);
		$stop;
		end	
	end
endmodule 