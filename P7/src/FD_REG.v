`timescale 1ns/1ps
`include "def.v"
module FD_REG(
    input i_clk,
    input i_reset,
    input i_en,
    input i_flush,
    input i_Req,

    input [31:0] i_pc,
    input [31:0] i_instr,
    input [4 :0] i_exc_code,
    input i_branch_delay,
    output reg [31:0] or_pc,
    output reg [31:0] or_instr,
    output reg [4 :0] or_exc_code,
    output reg or_branch_delay
);
    initial begin
        or_pc           = `PC_DEFAULT;
        or_instr        = `INSTR_DEFAULT;
        or_exc_code     = `EXC_CODE_DEFAULT;
        or_branch_delay = `BRANCH_DELAY_DEFAULT;
    end

    always @(posedge i_clk) begin
        if(i_reset || i_flush || i_Req) begin
            or_pc           <= (i_Req ? `NPC_INT : `PC_DEFAULT);
            or_instr        <= `INSTR_DEFAULT;
            or_exc_code     <= `EXC_CODE_DEFAULT;
            or_branch_delay <= `BRANCH_DELAY_DEFAULT;
        end
        else begin
            if(i_en) begin
                or_pc           <= i_pc;
                or_instr        <= i_instr;
                or_exc_code     <= i_exc_code;
                or_branch_delay <= i_branch_delay;
            end
        end
    end
endmodule