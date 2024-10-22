`timescale 1ns/1ps
`include "def.v"
module D_NPC(
    input  [31:0] i_F_pc,
    input  [31:0] i_D_pc,
    input  [2 :0] i_npcOp,
    input  i_jumpEn_of_B,
    input  [15:0] i_imm16,
    input  [25:0] i_imm26,
    input  [31:0] i_ra_of_jr,
    output [31:0] o_npc
);
    //  b,j i_F_PC or i_D_PC ? 
    assign o_npc =  (i_npcOp == `NPC_PC4                    ) ? ( i_F_pc + 4) :
                    (i_npcOp == `NPC_BRANCH && i_jumpEn_of_B) ? ( i_D_pc + 4 + {{14{i_imm16[15]}}, i_imm16, 2'b00}) : 
                    (i_npcOp == `NPC_J                      ) ? ({i_D_pc[31:28], i_imm26, 2'b00}) :
                    (i_npcOp == `NPC_JR                     ) ? ( i_ra_of_jr) :
                                                                ( i_F_pc + 4) ;
endmodule