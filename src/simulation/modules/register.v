module register (
    clk, rst_n, cl, ld, inc, dec, sr, ir, sl, il, in, out
);

    input clk, rst_n;
    input cl, ld;
    input inc, dec;
    input sr, ir;
    input sl, il;
    input [3:0] in;
    output reg [3:0] out;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            out = 4'h0;
        else begin
            if (cl)
                out = 4'h0;
            else if (ld)
                out = in;
            else if (inc)
                out = out + 4'b0001;
            else if (dec)
                out = out - 4'b0001;
            else if (sr)
                out = ir ? (out >> 1'b1) + 4'b1000 : out >> 1'b1;
            else if (sl)
                out = il ? (out << 1'b1) + 4'b0001 : out << 1'b1;
        end 
    end

endmodule