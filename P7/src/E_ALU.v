`timescale 1ns/1ps
`include "def.v"
module E_ALU(
    input i_alu_DMOv,
    input i_alu_AriOv,

    input  [31:0]  i_srcA,
    input  [31:0]  i_srcB,
    input  [4 :0]  i_shamt,
    input  [4 :0]  i_aluOp,
    output [31:0]  o_result,

    output o_exc_DMOv,
    output o_exc_AriOv
);  
    wire [32:0] ext_srcA = {i_srcA[31], i_srcA};
    wire [32:0] ext_srcB = {i_srcB[31], i_srcB};
    wire [32:0] ext_add, ext_sub;
    assign ext_add = ext_srcA + ext_srcB;
    assign ext_sub = ext_srcA - ext_srcB;

    wire add_overFlow  = (i_aluOp == `ALU_add) && (ext_add[32] != ext_add[31]);
    wire sub_overFlow  = (i_aluOp == `ALU_sub) && (ext_sub[32] != ext_sub[31]);
    assign o_exc_DMOv  = (i_alu_DMOv ) && (add_overFlow || sub_overFlow);
    assign o_exc_AriOv = (i_alu_AriOv) && (add_overFlow || sub_overFlow);


    wire alu_sra = $signed(i_srcB) >>> $signed(i_shamt);
    wire alu_slt = $signed(i_srcA) <   $signed(i_srcB );
    assign o_result = (i_aluOp == `ALU_add ) ? (  i_srcA + i_srcB   ) :
                      (i_aluOp == `ALU_sub ) ? (  i_srcA - i_srcB   ) :
                      (i_aluOp == `ALU_mul ) ? (  i_srcA * i_srcB   ) :
                      (i_aluOp == `ALU_div ) ? (  i_srcA / i_srcB   ) :
                      (i_aluOp == `ALU_and ) ? (  i_srcA & i_srcB   ) :
                      (i_aluOp == `ALU_or  ) ? (  i_srcA | i_srcB   ) :
                      (i_aluOp == `ALU_xor ) ? (  i_srcA ^ i_srcB   ) :
                      (i_aluOp == `ALU_nor ) ? (~(i_srcA | i_srcB)  ) :
                      (i_aluOp == `ALU_sll ) ? (  i_srcB << i_shamt ) :
                      (i_aluOp == `ALU_srl ) ? (  i_srcB >> i_shamt ) :
                      (i_aluOp == `ALU_sra ) ? (  alu_sra           ) :
                      (i_aluOp == `ALU_slt ) ? (  alu_slt           ) :
                      (i_aluOp == `ALU_sltu) ? (  i_srcA < i_srcB   ) : 
                                                 `ALU_DEFAULT;

endmodule