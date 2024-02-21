`timescale 1ns/1ps
`include "def.v"
module DE_REG(
    input i_clk,
    input i_reset,
    input i_flush,
    input i_Req,
    input i_en,
    input  [31:0] i_pc,
    input  [31:0] i_instr,
    input  [31:0] i_grf_RD1,
    input  [31:0] i_grf_RD2,
    input  [31:0] i_ext_result,
    output reg [31:0] or_pc,
    output reg [31:0] or_instr,
    output reg [31:0] or_grf_RD1,
    output reg [31:0] or_grf_RD2,
    output reg [31:0] or_ext_result,

    input  [4 :0] i_sa,
    input  [4 :0] i_aluOp,
    input  [31:0] i_grf_A3_writeAddr,
    output reg [4 :0] or_grf_A3_writeAddr,
    output reg [4 :0] or_sa,
    output reg [4 :0] or_aluOp,

    input  i_branch_delay,
    input  [4 :0] i_exc_code,
    output reg or_branch_delay,
    output reg [4 :0] or_exc_code

); 
    always @(posedge i_clk)begin
        if(i_reset || i_flush || i_Req) begin
            or_pc               <= i_flush ? i_pc : (i_Req ? `NPC_INT : 32'h0000_0000);
            or_instr            <= `INSTR_DEFAULT;
            or_grf_RD1          <= `GRF_RD_DEFAULT;
            or_grf_RD2          <= `GRF_RD_DEFAULT;
            or_grf_A3_writeAddr <= `GRF_WRITE_ADDR_DEFAULT;
            or_ext_result       <= `EXT_IMM32_DEFAULT;
            or_sa               <= `SA_DEFALUT;
            or_aluOp            <= `ALU_add;
            or_branch_delay     <= i_flush ? i_branch_delay : 1'b0;
            or_exc_code         <= i_flush ? i_exc_code     : 5'h0;
        end
        else begin
            if(i_en) begin
                or_pc               <= i_pc;
                or_instr            <= i_instr;
                or_grf_RD1          <= i_grf_RD1;
                or_grf_RD2          <= i_grf_RD2;
                or_grf_A3_writeAddr <= i_grf_A3_writeAddr;
                or_ext_result       <= i_ext_result;
                or_sa               <= i_sa;
                or_aluOp            <= i_aluOp;
                or_branch_delay     <= i_branch_delay;
                or_exc_code         <= i_exc_code;
            end
        end
    end
endmodule