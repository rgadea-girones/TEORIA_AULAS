module solucion_moore_2024 (
    clock,areset_n,Key2,Key1, count);

    input clock;
    input areset_n;
    input Key2;
    input Key1;
    output reg [3:0] count;

    //elementos del datapath
    reg enable,updown; //señales de control
    always @(posedge clock or negedge areset_n)

        if (!areset_n) 
            begin
                count<=4'b0000;
            end
        else 
            if (enable)
                if(updown)
                    count<=count+4'b1;
                else
                    count<=count-4'b1;

    //elementos del controlador
    reg [1:0] fstate;
    parameter IDLE=2'b00,SUBIR=2'b01,BAJAR=2'b10,REPOSO=2'b11;

    always @(posedge clock or negedge areset_n)
        if (!areset_n) 
            begin
                fstate <= IDLE;
            end
        else 
            case (fstate)
                IDLE: 
                    if ((Key2 ^ Key1))
                        if (Key2)
                            if (count==4'b0000)
                                fstate<=IDLE;
                            else
                                fstate<=BAJAR;
                        else
                            if (count==4'b1111)
                                fstate<=IDLE;
                            else
                                fstate<=SUBIR;  

                SUBIR: 
                    begin
                        fstate<=REPOSO;  
                    end
                BAJAR: 
                    begin
                        fstate<=REPOSO;  
                    end
                REPOSO: 
                    if (Key2==1'b1 && Key1==1'b1)
                        fstate <= IDLE;                

                default:
                    fstate <= IDLE;    
            endcase

always@(fstate)
    begin
        case(fstate)
         
            SUBIR: begin enable=1'b1;updown=1'b1; end
            BAJAR: begin enable=1'b1;updown=1'b0; end
       
            default: begin enable=1'b0;updown=1'b0; end
        endcase
    end
endmodule // idea_kit