`timescale 1ns / 1ps
  module EXT(
    input [15:0] imm16,
    input extUnsignedSel,
    output [31:0] imm32
    );
    assign imm32 = extUnsignedSel ? {{16{1'b0}},imm16} : {{16{imm16[15]}},imm16};

endmodule
