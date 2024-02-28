

module     mux_assign  
(
    a, b,
    sl,
    y,
     y2
) ;
input    [7:0]	a, b;
input		sl;
output 	[7:0]	y;
output y2;

assign #1 y = (sl) ? a & b: a| b;

assign y2=|y;

endmodule


