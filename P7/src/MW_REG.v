`timescale 1ns/1ps
`include "def.v"
module MW_REG(
    input i_clk,
    input i_reset,
    input i_en,
    input i_flush,
    input i_Req,
    input [31:0] i_pc,
    input [31:0] i_instr,
    input [31:0] i_dm_RD,
    input [31:0] i_alu_result,
    input [31:0] i_mdu_result,
    input [31:0] i_ext_result,
    input [31:0] i_CP0Out,
    output reg [31:0] or_pc,
    output reg [31:0] or_instr,
    output reg [31:0] or_dm_RD,
    output reg [31:0] or_alu_result,
    output reg [31:0] or_mdu_result,
    output reg [31:0] or_ext_result,
    output reg [31:0] or_CP0Out
);
    always @(posedge i_clk) begin
        if(i_reset || i_flush || i_Req) begin
            or_pc         <= i_Req ? `NPC_INT : `PC_DEFAULT;
            or_instr      <= `INSTR_DEFAULT;
            or_dm_RD      <= `DM_RD_DEFAULT;
            or_alu_result <= `ALU_RESULT_DEFAULT;
            or_mdu_result <= `MDU_RESULT_DEFAULT;
            or_ext_result <= `EXT_IMM32_DEFAULT ;
            or_CP0Out     <= `CP0_OUT_DEFAULT;
        end
        else begin
            if(i_en)begin
                or_pc         <= i_pc;
                or_instr      <= i_instr;
                or_dm_RD      <= i_dm_RD;
                or_alu_result <= i_alu_result; 
                or_mdu_result <= i_mdu_result; 
                or_ext_result <= i_ext_result;
                or_CP0Out     <= i_CP0Out;
            end
        end
    end
endmodule