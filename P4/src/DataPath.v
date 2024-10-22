`timescale 1ns / 1ps
`include "def.v"
module DataPath(
    input clk,
    input reset,
    input [1:0] npcOp,
    input [1:0] writeRegSel,
    input grfWriteEn,
    input [1:0] writeRegDataSel,
    input extUnsignedSel,
    input aluSrcSel,
    input shamtSel,
    input [3:0] aluOp,
    input dmWriteEn,
    input [1:0] dmOp,
    input [2:0] branchOp,
    output [5:0] opcode,
    output [5:0] func
    );
    wire [31:0] npc;
    wire [31:0] pc;
    wire jumpEn;
    wire [15:0] imm16;
    wire [25:0] imm26;
    wire [31:0] regAddr;
    wire [31:0] pc_4;
    wire [31:0] instr;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] sa;
    wire [31:0] memRD;
    wire [31:0] grfRD1;
    wire [31:0] grfRD2;
    wire [31:0] imm32;
    wire [31:0] aluResult;
    PC _pc(
		.clk(clk),
		.reset(reset),
        .npc(npc),
        .pc(pc)
    );
    NPC _npc(
        .pc(pc),
        .npcOp(npcOp),
        .imm16(imm16),
        .imm26(imm26),
        .regAddr(grfRD1),
        .jumpEn(jumpEn),
        .pc_4(pc_4),
        .npc(npc)
    );
    IM _im(
        .pc(pc),
        .instr(instr)
    );
    Splitter _splitter(
        .instr(instr),
        .opcode(opcode),
        .func(func),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .sa(sa),
        .imm16(imm16),
        .imm26(imm26)
    );
    GRF _grf(
        .clk(clk),
        .reset(reset),
        .grfWriteEn(grfWriteEn),
        .grfA1(rs),
        .grfA2(rt),
        .grfA3((writeRegSel == `CU_GRF_A3_RT) ? rt : (writeRegSel == `CU_GRF_A3_RD) ? rd : (writeRegSel == `CU_GRF_A3_RA) ? 5'b11111 : `CU_GRF_A3_RD),
        .grfRD1(grfRD1),
        .grfRD2(grfRD2),
        .grfWD((writeRegDataSel == `CU_GRF_WD_ALURESULT) ? aluResult : (writeRegDataSel == `CU_GRF_WD_MEMRD) ? memRD : (writeRegDataSel == `CU_GRF_WD_PC_4) ? pc_4 : 32'h0000_0000),
        .pc(pc),
        .instr(instr)
    );
    EXT _ext(
        .imm16(imm16),
        .imm32(imm32),
        .extUnsignedSel(extUnsignedSel)
    );
    ALU _alu(
        .srcA(grfRD1),
        .srcB((aluSrcSel == `CU_ALU_SRCB_GRFRD2) ? grfRD2 : (aluSrcSel == `CU_ALU_SRCB_IMM32) ? imm32 : 32'h0000_0000),
        .shamt((shamtSel == `CU_ALU_SHAMT_SEL_16) ? 5'b10000 : (shamtSel == `CU_ALU_SHAMT_SEL_sa) ? sa : 5'b00000),
        .aluOp(aluOp),
        .aluResult(aluResult)
    );
    CMP _cmp(
        .cmpA(grfRD1),
        .cmpB(grfRD2),
        .branchOp(branchOp),
        .jumpEn(jumpEn)
    );
    DM _dm(
        .clk(clk),
        .reset(reset),
        .dmMemAddr(aluResult),
        .dmWD(grfRD2),
        .dmRD(memRD),
        .dmWriteEn(dmWriteEn),
        .dmOp(dmOp),
		.pc(pc)
    );



endmodule
