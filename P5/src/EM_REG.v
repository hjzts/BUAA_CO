`timescale 1ns/1ps
`include "def.v"
module EM_REG(
    input  i_clk,
    input  i_reset,
    input  i_en,
    input  i_flush,
    input  [31:0] i_pc,
    input  [31:0] i_instr,
    input  [31:0] i_alu_result,
    input  [31:0] i_mdu_result,
    input  [31:0] i_mem_writeData, // sw
    input  [31:0] i_ext_result,
    output reg [31:0] or_pc,
    output reg [31:0] or_instr,
    output reg [31:0] or_mem_writeData,
    output reg [31:0] or_alu_result,
    output reg [31:0] or_mdu_result,
    output reg [31:0] or_ext_result
);
    always @(posedge i_clk) begin
        if(i_reset || i_flush) begin
            or_pc            <= `PC_DEFAULT;
            or_instr         <= `INSTR_DEFAULT;
            or_mem_writeData <= `MEM_WRITE_DATA_DEFAULT;
            or_alu_result    <= `ALU_RESULT_DEFAULT;
            or_mdu_result    <= `MDU_RESULT_DEFAULT;
            or_ext_result    <= `EXT_IMM32;
        end
        else begin
                if(i_en) begin
                or_pc            <= i_pc;
                or_instr         <= i_instr;
                or_mem_writeData <= i_mem_writeData;
                or_alu_result    <= i_alu_result;
                or_mdu_result    <= i_mdu_result;
                or_ext_result    <= i_ext_result;
                end
        end
    end
endmodule