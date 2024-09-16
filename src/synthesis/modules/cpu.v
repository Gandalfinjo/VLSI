module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk, rst_n,
    input [DATA_WIDTH - 1 : 0] mem_in,
    input [DATA_WIDTH - 1 : 0] in,
    output reg mem_we,
    output reg [ADDR_WIDTH - 1 : 0] mem_addr,
    output reg [DATA_WIDTH - 1 : 0] mem_data,
    output [DATA_WIDTH - 1 : 0] out,
    output [ADDR_WIDTH - 1 : 0] pc,
    output [ADDR_WIDTH - 1 : 0] sp
);

    localparam FETCH = 3'b000;
    localparam DECODE = 3'b001;
    localparam EXECUTE = 3'b010;

    localparam MOV = 4'b0000;
    localparam IN = 4'b0001;
    localparam OUT = 4'b0010;
    localparam ADD = 4'b0011;
    localparam SUB = 4'b0100;
    localparam MUL = 4'b0101;
    localparam DIV = 4'b0110;
    localparam STOP = 4'b1111;

    reg pcCL, pcLD, pcINC, pcDEC, pcSR, pcIR, pcSL, pcIL;
    reg [ADDR_WIDTH - 1 : 0] pcIN;
    wire [ADDR_WIDTH - 1 : 0] pcOUT;
    reg spCL, spLD, spINC, spDEC, spSR, spIR, spSL, spIL;
    reg [ADDR_WIDTH - 1 : 0] spIN;
    wire [ADDR_WIDTH - 1 : 0] spOUT;
    reg irCL, irLD, irINC, irDEC, irSR, irIR, irSL, irIL;
    reg [2 * DATA_WIDTH - 1 : 0] irIN;
    wire [2 * DATA_WIDTH - 1 : 0] irOUT;
    reg marCL, marLD, marINC, marDEC, marSR, marIR, marSL, marIL;
    reg [ADDR_WIDTH - 1 : 0] marIN;
    wire [ADDR_WIDTH - 1 : 0] marOUT;
    reg mdrCL, mdrLD, mdrINC, mdrDEC, mdrSR, mdrIR, mdrSL, mdrIL;
    reg [DATA_WIDTH - 1 : 0] mdrIN;
    wire [DATA_WIDTH - 1 : 0] mdrOUT;
    reg aCL, aLD, aINC, aDEC, aSR, aIR, aSL, aIL;
    reg [DATA_WIDTH - 1 : 0] aIN;
    wire [DATA_WIDTH - 1 : 0] aOUT;

    register #(
        .DATA_WIDTH(ADDR_WIDTH)
    ) PC (.clk(clk), .rst_n(rst_n), .cl(pcCL), .ld(pcLD), .inc(pcINC), .dec(pcDEC), .sr(pcSR), .ir(pcIR), .sl(pcSL), .il(pcIL));

    register #(
        .DATA_WIDTH(ADDR_WIDTH)
    ) SP (.clk(clk), .rst_n(rst_n), .cl(spCL), .ld(spLD), .inc(spINC), .dec(spDEC), .sr(spSR), .ir(spIR), .sl(spSL), .il(spIL));

    register #(
        .DATA_WIDTH(2 * DATA_WIDTH)
    ) IR (.clk(clk), .rst_n(rst_n), .cl(irCL), .ld(irLD), .inc(irINC), .dec(irDEC), .sr(irSR), .ir(irIR), .sl(irSL), .il(irIL));

    register #(
        .DATA_WIDTH(ADDR_WIDTH)
    ) MAR (.clk(clk), .rst_n(rst_n), .cl(marCL), .ld(marLD), .inc(marINC), .dec(marDEC), .sr(marSR), .ir(marIR), .sl(marSL), .il(marIL));

    register #(
        .DATA_WIDTH(DATA_WIDTH)
    ) MDR (.clk(clk), .rst_n(rst_n), .cl(mdrCL), .ld(mdrLD), .inc(mdrINC), .dec(mdrDEC), .sr(mdrSR), .ir(mdrIR), .sl(mdrSL), .il(mdrIL));

    register #(
        .DATA_WIDTH(DATA_WIDTH)
    ) A (.clk(clk), .rst_n(rst_n), .cl(aCL), .ld(aLD), .inc(aINC), .dec(aDEC), .sr(aSR), .ir(aIR), .sl(aSL), .il(aIL));
    
    // reg [ADDR_WIDTH - 1 : 0] PC, SP;
    // reg [31:0] IR;
    // reg [DATA_WIDTH - 1 : 0] MDR;
    // reg [DATA_WIDTH - 1 : 0] A;
    reg [3:0] opcode;
    reg addr_mode1, addr_mode2, addr_mode3;
    reg [2:0] operand1, operand2, operand3;
    reg [DATA_WIDTH - 1 : 0] constant;

    reg [2:0] state_reg, state_next;
    reg [DATA_WIDTH - 1 : 0] out_reg, out_next;
    assign out = out_reg;
    assign pc = PC;
    assign sp = SP;
    // assign mem_addr = MAR;
    // assign mem_data = MDR;

    // memory #(
    //     .ADDR_WIDTH(ADDR_WIDTH),
    //     .DATA_WIDTH(DATA_WIDTH)
    // ) mem_inst (
    //     .clk(clk),
    //     .we(mem_we),
    //     .addr(mem_addr),
    //     .data(mem_data),
    //     .out(mem_in)
    // )

    always @(posedge clk, negedge rst_n)
        if (!rst_n)
            state_reg <= FETCH;
            out_reg <= {DATA_WIDTH{1'b0}};
            PC <= ADDR_WIDTH'd8;
        else
            state_reg <= state_next;
            out_reg <= out_next;

    always @(*) begin
        state_next = state_reg;
        out_next = out_reg;

        case (state_reg)
            FETCH: begin
                mem_we = 0;

                MAR = PC;
                PC = PC + 1;
                MDR = mem_in;
                IR[31:16] = MDR;

                if (IR[31:28] == MOV) begin
                    MAR = PC;
                    PC = PC + 1;
                    MDR = mem_in;
                    IR[15:0] = MDR;
                end

                state_next = DECODE;
            end
            DECODE: begin
                opcode = IR[31:28];
                addr_mode1 = IR[27];
                addr_mode2 = IR[23];
                addr_mode3 = IR[19];
                operand1 = IR[26:24];
                operand2 = IR[22:20];
                operand3 = IR[18:16];
                constant = IR[15:0];
                state_next = EXECUTE;
            end
            EXECUTE: begin
                case (opcode)
                    MOV: begin
                        mem_we = 0;
                        marLD = 1;
                        mdrLD = 1;

                        marIN = operand3;
                        mem_addr = marOUT;
                        mdrIN = mem_in;

                        if (mdrOUT == 4'b0000) begin
                            marIN = operand2;
                            mem_addr = marOUT;
                            mdrIN = mem_in;

                            if (addr_mode2 == 1'b1) begin
                                marIN = mdrOUT[ADDR_WIDTH - 1 : 0];
                                mem_addr = marOUT
                                mdrIN = mem_in;
                            end

                            mem_we = 1;
                            marIN = operand1;
                            mem_addr = marOUT;
                            mem_data = mdrOUT;
                        end
                        else if (mdrOUT == 4'b1000) begin
                            mem_we = 1;
                            marIN = operand1;
                            mem_addr = marOUT;
                            mem_data = constant;
                        end

                        marLD = 0;
                        mdrLD = 0;
                    end
                    IN: begin
                        mem_we = 1;
                        marLD = 1;
                        mdrLD = 1;

                        marIN = operand1;
                        mem_addr = marOUT;
                        mdrIN = in;
                        mem_data = mdrOUT;

                        marLD = 0;
                        mdrLD = 0;
                    end
                    OUT: begin
                        mew_we = 0;
                        marLD = 1;
                        mdrLD = 1;

                        marIN = operand1;
                        mem_addr = marOUT;
                        mdrIN = mem_in;

                        if (addr_mode1 == 1'b1) begin
                            marIN = mdrOUT[ADDR_WIDTH - 1 : 0];
                            mem_addr = marOUT;
                            mdrIN = mem_in;
                        end

                        out_next = mdrOUT;
                        marLD = 0;
                        mdrLD = 0;
                    end
                    ADD, SUB, MUL, DIV: begin
                        alu alu_inst(
                            .oc(opcode[2:0] - 3'b001),
                            .a(mem_in[operand2]),
                            .b(mem_in[operand3]),
                            .f(A)
                        );
                        mem_addr = mem_in[operand1];
                        mem_we = 1;
                        mem_data = A;
                    end
                    STOP: begin
                        mem_we = 0;
                        if (operand1 != 4'b0000) begin
                            marLD = 1;
                            marIN = operand1;
                            mem_addr = marOUT;
                            mdrLD = 1;
                            mdrIN = mem_in;
                            out_next = mdrOUT;
                        end
                        else if (operand2 != 4'b0000) begin
                            marLD = 1;
                            marIN = operand2;
                            mem_addr = marOUT;
                            mdrLD = 1;
                            mdrIN = mem_in;
                            out_next = mdrOUT;
                        end
                        else if (operand3 != 4'b0000) begin
                            marLD = 1;
                            marIN = operand3;
                            mem_addr = marOUT;
                            mdrLD = 1;
                            mdrIN = mem_in;
                            out_next = mdrOUT;
                        end
                        marLD = 0;
                        mdrLD = 0;
                        pcCL = 1;
                    end
                    default: 
                endcase
                state_next = FETCH;
            end
            default: state_next = FETCH;
        endcase
    end    
endmodule