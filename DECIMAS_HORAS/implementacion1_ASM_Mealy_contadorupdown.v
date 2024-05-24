module solucion_mealy_2024 (
    clock,areset_n,Key2, count);

    input clock;
    input areset_n;
    input Key2;
    output reg [3:0] count;

reg [1:0] fstate;
parameter IDLE1=2'b00,IDLE2=2'b01,REPOSO1=2'b10,REPOSO2=2'b11;

always @ (posedge clock or negedge areset_n)
    if (!areset_n) 
        begin
            fstate <= 2'b00;
            count <= 4'b0000;
        end
    else
        case (fstate)
            IDLE1: 
                if (Key2)
                    if (count==4'b1111)
                    begin
                        fstate <= REPOSO2;
                        count <= count - 4'b1;
                    end
                    else
                    begin
                        fstate <= REPOSO1;
                        count <= count + 4'b1;
                    end

            IDLE2: 
                if (Key2)
                    if (count==4'b0000)
                    begin
                        fstate <= REPOSO1;
                        count <= count + 4'b1;
                    end
                    else
                    begin
                        fstate <= REPOSO2;
                        count <= count - 4'b1;
                    end
            REPOSO1: 
                if (Key2)
                    fstate <= IDLE1;  
            REPOSO2:        
                if (Key2)
                    fstate <= IDLE2;
				
            default:
                fstate <= IDLE1;	
        endcase

endmodule // idea_kit