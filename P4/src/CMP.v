`timescale 1ns / 1ps
`include "def.v"
module CMP(
    input [31:0] cmpA,
    input [31:0] cmpB,
    input [2:0] branchOp,
    output jumpEn
    );

    assign jumpEn = (branchOp == `CMP_EQUAL)                   ? (cmpA == cmpB) :
                    (branchOp == `CMP_NOT_EQUAL)               ? (cmpA != cmpB) :
                    (branchOp == `CMP_SIGNED_LESS)             ? (cmpA < cmpB) :
                    (branchOp == `CMP_SIGNED_LESS_OR_EQUAL)    ? (cmpA <= cmpB) :
                    (branchOp == `CMP_UNSIGNED_LESS)           ? (cmpA < cmpB) :
                    (branchOp == `CMP_SIGNED_GREATER)          ? (cmpA > cmpB) :
                    (branchOp == `CMP_UNSIGNED_GREATER)        ? (cmpA > cmpB) :
                    (branchOp == `CMP_SIGNED_GREATER_OR_EQUAL) ? (cmpA >= cmpB) :
                    1'b0;
endmodule
