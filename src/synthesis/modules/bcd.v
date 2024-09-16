module bcd (
    input [5:0] in,
    output reg [3:0] ones,
    output reg [3:0] tens
);
    
    always @(*) begin
        tens <= in / 4'd10 % 4'd10;
        ones <= in % 4'd10;
    end

endmodule