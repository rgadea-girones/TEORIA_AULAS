primitive     my_mux (y,sel,a,b) ;
output 		y;
input		sel,a, b;


/*
always @(a or b or sel)
  begin //Sobra en este caso
	if (sel == 1)
		y = a;
	else
		y = b;
  end //
  */
table

 // sel a  b   y

 0   0  0 :  0;
 0   0  1 :  1;
 0   1  0 :  0;
 0   1  1 :  1;
 1   0  0 :  0;
 1   0  1 :  0;
 1   1  0 :  1;
 1   1  1 :  1;
endtable
endprimitive



