module top_alarma (
    clock,areset_n,intruso,inicio, sirena);
    
    input clock;
    input areset_n;
    input inicio;
    input intruso;
    output reg sirena;



    //elementos del data-path
    
    wire [4:0] count;
    wire resetear_count; //senal de control


    contador_basico contador_basico_inst (
        .clock(clock),
        .areset_n(areset_n),
        .clear_n(resetear_count),
        .count(count)
    );

    wire temporizador=  (count==5'b11101); //señal de estado

    //elementos del controlador

    reg [2:0] fstate;
    parameter INICIAL=3'b000,ESPERA=3'b001,ACTIVADA=3'b010, INTRUSO=3'b011, AUN_INTRUSO=3'b100;

    always @ (posedge clock or negedge areset_n)
        if (!areset_n) 
                fstate <= INICIAL;

        else
            case (fstate)
                INICIAL: 
                    if (!inicio)
                        fstate <= INICIAL;
                    else
                        fstate <= ESPERA;
                ESPERA: 
                    if (!inicio)
                        fstate <= INICIAL;
                    else
                        if (temporizador)
                            fstate <= ACTIVADA;
                        else
                            fstate <= ESPERA;
                ACTIVADA: 
                    if (!inicio)
                        fstate <= INICIAL;
                    else
                        if (intruso)
                            fstate <= INTRUSO;
                        else
                            fstate <= ACTIVADA;
                INTRUSO: 
                    if (!inicio)
                        fstate <= INICIAL;
                    else
                        if (temporizador)
                            if (intruso)
                                fstate <= AUN_INTRUSO;
                            else
                                fstate <= ACTIVADA;
                        else
                            fstate <= INTRUSO;
                AUN_INTRUSO: 
                    if (!inicio)
                        fstate <= INICIAL;
                    else
                        if (intruso)
                            fstate <= AUN_INTRUSO;
                        else
                            fstate <= ACTIVADA;
                default:
                    fstate <= INICIAL;	
            endcase
//determinacion de la salida de control
always@(fstate or temporizador or intruso or inicio)
    case (fstate)
        INICIAL: 
            sirena <= 1'b0;
        ESPERA: 
            sirena <= 1'b0;
        ACTIVADA: 
            sirena <= intruso==1'b1 && inicio==1'b1;
        INTRUSO: 
            sirena <= 1'b1;
        AUN_INTRUSO: 
            sirena <= 1'b1;
        default:
            sirena <= 1'b0;
    endcase

//determinacion de la señal de control           
assign resetear_count=(fstate==INICIAL || fstate==ACTIVADA)?1'b0:1'b1;

endmodule