`timescale 1ns / 1ps
`include "def.v"
module NPC(
    input [1:0] npcOp,
    input [31:0] pc,
    input [15:0] imm16,
    input [25:0] imm26,
    input [31:0] regAddr,
    input jumpEn,
    output [31:0] pc_4, // pc + 4
    output reg [31:0] npc
    );
    assign pc_4 = pc + 4;
/*	 assign npc = (npcOp == `NPC_PC_4) ? (pc + 4) :
					  (npcOp == `NPC_J) ? {pc[31:28], imm26, 2'b00} :
					  (npcOp == `NPC_B) ? (jumpEn ? (pc + 4 + {{14{imm16[15]}}, imm16, 2'b00}) : (pc + 4)) :
					  (npcOp == `NPC_JR) ? regAddr :
					  (pc + 4);*/
    always @(*) begin
        case(npcOp)
            `NPC_PC_4:npc = pc + 4;
            `NPC_J:npc = {pc[31:28], imm26, 2'b00};
            `NPC_B:npc = jumpEn ? (pc + 4 + {{14{imm16[15]}}, imm16, 2'b00}) : (pc + 4);
            `NPC_JR:npc = regAddr;
			default: npc = pc + 4;
    endcase
    end
endmodule
