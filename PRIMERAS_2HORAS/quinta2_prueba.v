module     quinta2_prueba
(
    input		a, b,
    input		sel,
    output reg		y
    // Outputs
) ;
always @(a or b or sel)
  begin //Sobra en este caso
	if (sel == 1)
		y = a;
	else
		y = b;
  end //


endmodule

