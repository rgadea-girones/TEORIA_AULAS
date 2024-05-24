module ASM_speed_moore2_2024 (
    clock,areset_n,Key2,Key1, count);

    input clock;
    input areset_n;
    input Key2;
    input Key1;
    output reg [3:0] count;



  
    (*syn_encoding="user"*)  reg [1:0] fstate;


    localparam estado0=2'b00,estado1=2'b01,estado2=2'b10,estado3=2'b11;

  always @(posedge clock or negedge areset_n)

      if (!areset_n) 
			begin
            fstate <= estado0;
				count<=4'b0000;
        end
      else 
        case (fstate)
            estado0: 
              	 if ((Key2 ^ Key1))
							if (Key1)
								if (count!=4'b1111)
									fstate<=estado1;
                else
                  fstate<=estado0;
							else
								if (count!=4'b0000)
									fstate<=estado2;
                else
                  fstate<=estado0;  

            estado1: 
            begin
            	fstate<=estado3;  
				count<=count+4'b1;
            end
            estado2: 
            begin
            	fstate<=estado3;  
				count<=count-4'b1;
            end
            estado3: 
              	if (Key2==1'b1 && Key1==1'b1)
                       fstate <= estado0;				

				default:
               fstate <= estado0;	
        endcase

endmodule // idea_kit
