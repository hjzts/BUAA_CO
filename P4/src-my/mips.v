`timescale 1ns / 1ps
module mips(
    input clk,
    input reset
    );
    wire [5:0] opcode;
    wire [5:0] func;
    wire [1:0] npcOp;
    wire [1:0] writeRegSel;
    wire grfWriteEn;
    wire [1:0] writeRegDataSel;
    wire extUnsignedSel;
    wire aluSrcSel;
    wire shamtSel;
    wire [3:0] aluOp;
    wire dmWriteEn;
    wire [1:0] dmOp;
    wire [2:0] branchOp;

    DataPath _datapath(
        .clk(clk),
        .reset(reset),
        .npcOp(npcOp),
        .writeRegSel(writeRegSel),
        .grfWriteEn(grfWriteEn),
        .writeRegDataSel(writeRegDataSel),
        .extUnsignedSel(extUnsignedSel),
        .aluSrcSel(aluSrcSel),
        .shamtSel(shamtSel),
        .aluOp(aluOp),
        .dmWriteEn(dmWriteEn),
        .dmOp(dmOp),
        .branchOp(branchOp),
        .opcode(opcode),
        .func(func)
    );
    CU _cu(
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .func(func),
        .npcOp(npcOp),
        .writeRegSel(writeRegSel),
        .grfWriteEn(grfWriteEn),
        .writeRegDataSel(writeRegDataSel),
        .extUnsignedSel(extUnsignedSel),
        .aluSrcSel(aluSrcSel),
        .shamtSel(shamtSel),
        .aluOp(aluOp),
        .dmWriteEn(dmWriteEn),
        .dmOp(dmOp),
        .branchOp(branchOp)
    );
endmodule
