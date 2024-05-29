module contador_basico (
    clock,areset_n,clear_n, count);

    input clock;
    input areset_n;
    input clear_n;
    output reg [4:0] count;

always @ (posedge clock or negedge areset_n)
    if (!areset_n) 
        begin
            count <= 5'b00000;
        end
    else
        if (clear_n)
            count <= count + 5'b1;
        else
            count <= 5'b00000;
endmodule