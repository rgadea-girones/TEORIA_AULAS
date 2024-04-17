module and_or_invert_2(
    input A,
    input B,
    input C,
    input D, 
    output reg TZ
    );
    reg TM, TN, TO;
    always @(*) begin
        TM <= A & B ;
        TN <= C & D;
        TO <= TM | TN;
        TZ <= ~TO;
    end
    
endmodule
