module 	tercera_prueba
(
    input    data1,data2,
    input		enable,
    output		out
    // Outputs
) ;


buffer 	b1(data1,enable, out);
buffer 	b2(data2,~enable, out);


endmodule


module 	buffer(data,  enable, out);
input		data;
input		enable;
output	 	out;

wire		out;

assign	#1 out = (enable) ? data : 1'bz;

endmodule 
// instanciar buffer

