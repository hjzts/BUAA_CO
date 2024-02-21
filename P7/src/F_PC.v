`timescale 1ns/1ps
`include "def.v"
module F_PC(
    input  i_clk,
    input  i_reset,
    input  i_en,
    input  i_Req,
    input  [31:0] i_npc,
    output reg [31:0] or_pc
);
    initial or_pc = `PC_DEFAULT;

    always @(posedge i_clk) begin
        if(i_reset) begin
            or_pc <= `PC_DEFAULT;
        end
        else begin
            if(i_en | i_Req)
                or_pc <= i_npc;
        end
    end

endmodule