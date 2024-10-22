`timescale 1ns / 1ps
`include "def.v"
module CU(
    input clk,
    input reset,
    input [5:0] opcode,
    input [5:0] func,
    output [1:0] npcOp,
    output [1:0] writeRegSel,
    output grfWriteEn,
    output [1:0] writeRegDataSel,
    output extUnsignedSel,
    output aluSrcSel,
    output shamtSel,
    output [3:0] aluOp,
    output dmWriteEn,
    output [1:0] dmOp,
    output [2:0] branchOp
    );
    wire add, sub, ori, beq, lui, sll, lw, sw, jal, j;
    wire bne, bge, ble, blt, bgt;
    assign add = (opcode == 6'b000000) && (func == 6'b100000);
    assign sub = (opcode == 6'b000000) && (func == 6'b100010);
    assign sll = (opcode == 6'b000000) && (func == 6'b000000);
    assign ori = (opcode == 6'b001101);
    assign lui = (opcode == 6'b001111);
    assign lw =  (opcode == 6'b100011);
    assign sw =  (opcode == 6'b101011);
    assign jal = (opcode == 6'b000011);
    assign j =   (opcode == 6'b000010);
    assign jr =  (opcode == 6'b000000) && (func == 6'b001000);
    assign beq = (opcode == 6'b000100);
    assign bne = (opcode == 6'b000101);
    assign bge = (opcode == 6'b000001);
    assign ble = (opcode == 6'b000110);
    assign blt = (opcode == 6'b000111);
    assign bgt = (opcode == 6'b000001);
    
    assign lb  = (opcode == 6'b100000);
    assign sb  = (opcode == 6'b101000);
    assign lh  = (opcode == 6'b100001);
    assign sh  = (opcode == 6'b101001);
    assign lhu = (opcode == 6'b100101);
    assign shu = (opcode == 6'b101001);
/*    always @(*) begin
        if(opcode == 0) begin
            case(func) 
                6'b100000 : begin
                    npcOp == `NPC_PC_4;
                    writeRegSel == `CU_GRF_A3_RD;
                    grfWriteEn == 1'b1;
                end
            endcase
        end
        else begin      
            case (opcode):
                `CU_add_OP : begin
                
            end
        endcase
                end
    end*/
    assign npcOp = (beq)     ? `NPC_B :
                   (j | jal) ? `NPC_J :
                   (jr)      ? `NPC_JR:
                               `NPC_PC_4;
    assign writeRegSel = (add | sub | sll)                                      ? `CU_GRF_A3_RD :
                         (ori | lw  | sw | lui | lb | sb | lh | sh | lhu | shu) ? `CU_GRF_A3_RT :
                         (jal)                                                  ? `CU_GRF_A3_RA :
                                                                                  `CU_GRF_A3_RD ;
    assign grfWriteEn = (add | sub | ori | lui | sll | jal | lw | lb | lh | lhu) ?  1'b1 : 1'b0;
    assign writeRegDataSel = (add | sub | ori | lui | sll) ? `CU_GRF_WD_ALURESULT :
                             (lw  | lh  | lhu )            ? `CU_GRF_WD_MEMRD :
                             (jal)                         ? `CU_GRF_WD_PC_4 :
                                                             `CU_GRF_WD_ALURESULT;
    assign extUnsignedSel = (ori | lui) ? 1'b1 : 1'b0;
    assign aluSrcSel = (add | sub | beq | sll)                                 ? `CU_ALU_SRCB_GRFRD2 :
                       (ori | lui | lw | sw | lb | sb | lh | sh | lhu | shu)   ? `CU_ALU_SRCB_IMM32  :
                                                                                 `CU_ALU_SRCB_GRFRD2 ;
    assign shamtSel = (lui) ? `CU_ALU_SHAMT_SEL_16 :
                      (sll) ? `CU_ALU_SHAMT_SEL_sa :
                              `CU_ALU_SHAMT_SEL_sa;
    assign aluOp = (add | lw | sw | lb | sb | lh | sh | lhu | shu) ? `ALU_add :
                   (sub)                                           ? `ALU_sub :
                   (ori)                                           ? `ALU_or  :
                   (lui | sll)                                     ? `ALU_sll :
                                                                     `ALU_add;
    assign dmWriteEn = (sw | sb | sh | shu) ? 1'b1 : 1'b0;
    assign dmOp = (lw | sw)             ? `DM_WORD :
                  (lh | sh | lhu | shu) ? `DM_HALF_WORD :
                  (lb | sb)             ? `DM_BYTE :
                                          `DM_WORD ;
    assign branchOp = (beq) ? `CMP_EQUAL :
                      (bne) ? `CMP_NOT_EQUAL :
                      (bge) ? `CMP_SIGNED_GREATER_OR_EQUAL :
                      (ble) ? `CMP_SIGNED_LESS_OR_EQUAL :
                      (blt) ? `CMP_SIGNED_LESS :
                      (bgt) ? `CMP_SIGNED_GREATER :
                              `CMP_EQUAL;
endmodule
