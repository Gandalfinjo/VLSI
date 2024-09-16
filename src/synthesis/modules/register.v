module register #(
    parameter DATA_WIDTH = 16,
    parameter HIGH = DATA_WIDTH - 1
) (
    input clk, rst_n,
    input cl, ld,
    input inc, dec,
    input sr, ir,
    input sl, il,
    input [HIGH:0] in,
    output [HIGH:0] out
);

    reg [HIGH:0] out_reg, out_next;
    assign out = out_reg;

    always @(posedge clk, negedge rst_n)
        if (!rst_n)
            out_reg <= {HIGH{1'b0}};
        else
            out_reg <= out_next;

    always @(*) begin
        out_next = out_reg;

        if (cl)
            out_next = {HIGH{1'b0}};
        else if (ld)
            out_next = in;
        else if (inc)
            out_next = out_reg + 1'b1;
        else if (dec)
            out_next = out_reg - 1'b1;
        else if (sr)
            out_next = ir ? (out_reg >> 1'b1) + {1'b1, {(HIGH - 1){1'b0}}} : out_reg >> 1'b1;
        else if (sl)
            out_next = il ? (out_reg << 1'b1) + {{(HIGH - 1){1'b0}}, 1'b1} : out_reg << 1'b1;
    end

endmodule