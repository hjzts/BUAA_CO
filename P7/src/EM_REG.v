`timescale 1ns/1ps
`include "def.v"
module EM_REG(
    input  i_clk,
    input  i_reset,
    input  i_en,
    input  i_flush,
    input  i_Req,
    input  [31:0] i_pc,
    input  [31:0] i_instr,
    input  [31:0] i_alu_result,
    input  [31:0] i_mdu_result,
    input  [31:0] i_mem_writeData, // sw
    input  [31:0] i_ext_result,
    input  [4 :0] i_exc_code,
    input  i_branch_delay,
    input  i_exc_DMOv,
    output reg [31:0] or_pc,
    output reg [31:0] or_instr,
    output reg [31:0] or_mem_writeData,
    output reg [31:0] or_alu_result,
    output reg [31:0] or_mdu_result,
    output reg [31:0] or_ext_result,
    output reg [4 :0] or_exc_code,
    output reg or_branch_delay,
    output reg or_exc_DMOv
);
    initial begin
        or_pc            <= `PC_DEFAULT;
        or_instr         <= `INSTR_DEFAULT;
        or_mem_writeData <= `MEM_WRITE_DATA_DEFAULT;
        or_alu_result    <= `ALU_RESULT_DEFAULT;
        or_mdu_result    <= `MDU_RESULT_DEFAULT;
        or_ext_result    <= `EXT_IMM32;
        or_branch_delay  <= `BRANCH_DELAY_DEFAULT;
        or_exc_code      <= `EXC_CODE_DEFAULT;
        or_exc_DMOv      <= `EXC_DMOV_DEFAULT;
    end
    always @(posedge i_clk) begin
        if(i_reset || i_flush || i_Req) begin
            or_pc            <= (i_Req ? `NPC_INT : `PC_DEFAULT);
            or_instr         <= `INSTR_DEFAULT;
            or_mem_writeData <= `MEM_WRITE_DATA_DEFAULT;
            or_alu_result    <= `ALU_RESULT_DEFAULT;
            or_mdu_result    <= `MDU_RESULT_DEFAULT;
            or_ext_result    <= `EXT_IMM32;
            or_branch_delay  <= (i_Req ? i_branch_delay : `BRANCH_DELAY_DEFAULT);
            or_exc_code      <= `EXC_CODE_DEFAULT;
            or_exc_DMOv      <= `EXC_DMOV_DEFAULT;
        end
        else begin
            if(i_en) begin
                or_pc            <= i_pc;
                or_instr         <= i_instr;
                or_mem_writeData <= i_mem_writeData;
                or_alu_result    <= i_alu_result;
                or_mdu_result    <= i_mdu_result;
                or_ext_result    <= i_ext_result;
                or_branch_delay  <= i_branch_delay;
                or_exc_code      <= i_exc_code;
                or_exc_DMOv      <= i_exc_DMOv;
            end
        end
    end
endmodule