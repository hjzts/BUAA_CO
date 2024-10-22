`timescale 1ns / 1ps
`include "def.v"
module PC(
    input clk,
    input reset,
    input [31:0] npc,
    output reg [31:0] pc
    );
    initial begin
        pc = `PC_pcDefault;
    end
    always @(posedge clk) begin
        if(reset) pc <= `PC_pcDefault;
        else pc <= npc;
    end
endmodule