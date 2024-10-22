`timescale 1ns/1ps
`include "def.v"
module FD_REG(
    input i_clk,
    input i_reset,
    input i_en,
    input i_flush,
    input [31:0] i_pc,
    input [31:0] i_instr,
    output reg [31:0] or_pc,
    output reg [31:0] or_instr
);
    always @(posedge i_clk) begin
        if(i_reset || i_flush) begin
            or_pc    <= `PC_DEFAULT;
            or_instr <= `INSTR_DEFAULT;
        end
        else begin
            if(i_en) begin
                or_pc    <= i_pc;
                or_instr <= i_instr;
            end
        end
    end
endmodule