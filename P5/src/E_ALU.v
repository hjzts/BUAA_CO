`timescale 1ns/1ps
`include "def.v"
module E_ALU(
    input  [31:0]  i_srcA,
    input  [31:0]  i_srcB,
    input  [4 :0]  i_shamt,
    input  [4 :0]  i_aluOp,
    output [31:0]  o_result
);
    wire [31:0] signed_srcB;
    assign signed_srcB = $signed(i_srcB);
    assign o_result = (i_aluOp == `ALU_add) ? (  i_srcA + i_srcB   ) :
                      (i_aluOp == `ALU_sub) ? (  i_srcA - i_srcB   ) :
                      (i_aluOp == `ALU_mul) ? (  i_srcA * i_srcB   ) :
                      (i_aluOp == `ALU_div) ? (  i_srcA / i_srcB   ) :
                      (i_aluOp == `ALU_and) ? (  i_srcA & i_srcB   ) :
                      (i_aluOp == `ALU_or ) ? (  i_srcA | i_srcB   ) :
                      (i_aluOp == `ALU_xor) ? (  i_srcA ^ i_srcB   ) :
                      (i_aluOp == `ALU_nor) ? (~(i_srcA | i_srcB)  ) :
                      (i_aluOp == `ALU_sll) ? (  i_srcB << i_shamt ) :
                      (i_aluOp == `ALU_srl) ? (  i_srcB >> i_shamt ) :
                      (i_aluOp == `ALU_sra) ? (  signed_srcB >>> $signed(i_shamt)) :
                                                 `ALU_DEFAULT;

endmodule