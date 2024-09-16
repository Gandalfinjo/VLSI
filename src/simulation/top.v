module top;

    reg [2:0] oc_alu;
    reg [3:0] a_alu;
    reg [3:0] b_alu;
    wire [3:0] f_alu;

    alu alu1(
        .oc(oc_alu),
        .a(a_alu),
        .b(b_alu),
        .f(f_alu)
    );

    reg clk_reg, rst_n_reg;
    reg cl_reg, ld_reg;
    reg inc_reg, dec_reg;
    reg sr_reg, ir_reg;
    reg sl_reg, il_reg;
    reg [3:0] in_reg;
    wire [3:0] out_reg;

    register reg1(
        .clk(clk_reg),
        .rst_n(rst_n_reg),
        .cl(cl_reg),
        .ld(ld_reg),
        .inc(inc_reg),
        .dec(dec_reg),
        .sr(sr_reg),
        .ir(ir_reg),
        .sl(sl_reg),
        .il(il_reg),
        .in(in_reg),
        .out(out_reg)
    );

    integer i;

    initial begin
        for (i = 0; i < 2048; i = i + 1) begin
            {oc_alu, a_alu, b_alu} = i;
            #5;
        end

        #10 $stop;

        clk_reg = 1'b0;
        rst_n_reg = 1'b0;
        cl_reg = 1'b0;
        ld_reg = 1'b0;
        inc_reg = 1'b0;
        dec_reg = 1'b0;
        sr_reg = 1'b0;
        ir_reg = 1'b0;
        sl_reg = 1'b0;
        il_reg = 1'b0;
        in_reg = 4'h0;
        #2 rst_n_reg = 1'b1;
            
        repeat (1000) begin
            #5;
            clk_reg = $urandom % 2;
            rst_n_reg = $urandom % 2;
            cl_reg = $urandom % 2;
            ld_reg = $urandom % 2;
            inc_reg = $urandom % 2;
            dec_reg = $urandom % 2;
            sr_reg = $urandom % 2;
            ir_reg = $urandom % 2;
            sl_reg = $urandom % 2;
            il_reg = $urandom % 2;
            in_reg = $urandom_range(16);
        end

        #10 $finish;
    end

    always
        #5 clk_reg = ~clk_reg;

    always @(f_alu) begin
        $display("Time = %0d, oc = %3b, a = %4b, b = %4b, f = %4b", $time, oc_alu, a_alu, b_alu, f_alu);
    end

    always @(out_reg) begin
        $display(
            "Time = %0d, cl = %b, ld = %b, inc = %b, dec = %b, sr = %b, ir = %b, sl = %b, il = %b, in = %4b, out = %4b",
            $time, cl_reg, ld_reg, inc_reg, dec_reg, sr_reg, ir_reg, sl_reg, il_reg, in_reg, out_reg
        );
    end

endmodule