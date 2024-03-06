module and_or_invert_1(
    input A,
    input B,
    input C,
    input D, 
    output reg TZ
    );
    reg TM, TN, TO;
    always @(A,B,C,D) begin
        TM = A & B;
        TN = C & D;
        TO = TM | TN;
        TZ = ~TO;
    end
    
endmodule
