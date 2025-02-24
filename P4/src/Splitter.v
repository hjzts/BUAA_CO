`timescale 1ns / 1ps
module Splitter(
    input [31:0] instr,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [5:0] opcode,
    output [5:0] func,
    output [4:0] base,
    output [4:0] sa,
    output [25:0] imm26,
    output [15:0] imm16
    );
    assign rs = instr[25:21];
    assign rt = instr[20:16];
    assign rd = instr[15:11];
    assign opcode = instr[31:26];
    assign func = instr[5:0];
    assign base = instr[25:21];
    assign sa = instr[10:6];
    assign imm26 = instr[25:0];
    assign imm16 = instr[15:0];

endmodule
