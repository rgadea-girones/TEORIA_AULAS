

module 	buffer(data, enable, out);
input	[7:0]	data;
input		enable;
output	[7:0] 	out;

wire	[7:0] 	out;

assign	#1 out = (enable) ? data : 8'bz;

endmodule 
// instanciar buffer

