//codificador de 4 a 2 con prioridad
/*
module 	encoder4to3(a, y);


    input 	[3:0] a;
    output 	[1:0] y;

    assign 	y = (a[3]) ? 2'b11 :
                (a[2]) ? 2'b10 :
                (a[1]) ? 2'b01 :
                 2'b00 ;

// lo mismo con un always

//     always @(*)
//     begin
//         if(a[3] == 1)
//             y = 2'b11;
//         else if(a[2] == 1)
//             y = 2'b10;
//         else if(a[1] == 1)
//             y = 2'b01;
//         else
//             y = 2'b00;
//     end
endmodule


//codificador de 4 a 2 con prioridad
module 	encoder4to2(a, y);

input 	[3:0] a;
   output reg	[1:0] y;

   //con un case

   always @(*)
   begin
       case(a)
           4'b1000: y = 2'b11;
           4'b0100: y = 2'b10; 
           4'b0010: y = 2'b01;           
           4'b0001: y = 2'b00;
           default: y = 2'b00;
       endcase
   end

endmodule
*/
//codificador de 4 a 2 con prioridad
 module 	encoder4to2_3(a, y);

 input 	[3:0] a;
    output reg	[1:0] y;

    //con un case

    always @(*)
    begin
        case(1'b1)
            a[3]: y = 2'b11;
            a[2]: y = 2'b10; 
            a[1]: y = 2'b01;           
            a[0]: y = 2'b00;
            default: y = 2'b00;
        endcase
    end

endmodule
