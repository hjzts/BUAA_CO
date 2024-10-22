`timescale 1ns/1ps
`include "def.v"
module _CU(
    input [31:0]  i_instr,
    // Splitter funct
    output [4 :0] o_rs,
    output [4 :0] o_rt,
    output [4 :0] o_rd,
    output [4 :0] o_sa,
    output [15:0] o_imm16,
    output [25:0] o_imm26,
    // 指令分类
    output o_calc_r,
    output o_calc_i,
    output o_lui,

    output o_shift_s,
    output o_shift_v,

    output o_load,
    output o_store,

    output o_b_type,
    output o_j_r,
    output o_j_imm26,
    output o_link,

    output o_md,
    output o_mt,
    output o_mf,
    // ID
    output [3 :0] o_cmpOp,
    output [1 :0] o_ext_Sel,
    output [2 :0] o_npcOp,
    // EX
    output [4 :0] o_aluOp,
    output [4 :0] o_mduOp,
    output        o_mdu_start,
    output [2: 0] o_alu_srcA_Sel,
    output [2 :0] o_alu_srcB_Sel,
    output [2 :0] o_alu_shamt_Sel,
    // MEM 
    output [2 :0] o_beOp,
    output [2 :0] o_deOp,
    output o_dm_writeEn,
    // WB
    output o_grf_writeEn,
    output [4 :0] o_grf_WA,
    output [2 :0] o_grf_WD_Sel
);
// Splliter,译码部分
    wire [5:0] opcode, func;
    assign opcode   = i_instr[31:26];
    assign func     = i_instr[5 :0 ];
    assign o_rs     = i_instr[25:21];
    assign o_rt     = i_instr[20:16];
    assign o_rd     = i_instr[15:11];
    assign o_sa     = i_instr[10:6 ];    
    assign o_imm16  = i_instr[15:0 ];
    assign o_imm26  = i_instr[25:0 ];
// 指令控制！处理指令部分
    //R类型指令,除去jr jalr md/mt/mf
    wire Rtype  = (opcode == `OP_RTYPE);
    wire add    = Rtype && (func == `FUN_ADD );
    wire sub    = Rtype && (func == `FUN_SUB );
    wire addu   = Rtype && (func == `FUN_ADDU);
    wire subu   = Rtype && (func == `FUN_SUBU);
    // logical op
    wire And    = Rtype && (func == `FUN_AND );
    wire Or     = Rtype && (func == `FUN_OR  );
    wire Xor    = Rtype && (func == `FUN_XOR );
    wire Nor    = Rtype && (func == `FUN_NOR );
    // slt op 
    wire slt    = Rtype && (func == `FUN_SLT );
    wire sltu   = Rtype && (func == `FUN_SLTU);
    //shift-s op
    wire sll    = Rtype && (func == `FUN_SLL );
    wire srl    = Rtype && (func == `FUN_SRL );
    wire sra    = Rtype && (func == `FUN_SRA );
    //shift-v op
    wire sllv   = Rtype && (func == `FUN_SLLV);
    wire srlv   = Rtype && (func == `FUN_SRLV);
    wire srav   = Rtype && (func == `FUN_SRAV);
    //I类型指令(不包括内存load与store),除去lui
    wire addi   = (opcode == `OP_ADDI);
    wire andi   = (opcode == `OP_ANDI);
    wire ori    = (opcode == `OP_ORI );
    wire xori   = (opcode == `OP_XORI);
    // lui,这里将lui单独提出来是考虑到lui无需使用到后面的alu，在D级即可出现结果，和大多数I型指令无关
    wire lui    = (opcode == `OP_LUI ); 
    // load,内存操作指令 
    wire lb     = (opcode == `OP_LB  );
    wire lbu    = (opcode == `OP_LBU );
    wire lh     = (opcode == `OP_LH  );
    wire lhu    = (opcode == `OP_LHU );
    wire lw     = (opcode == `OP_LW  );
    // store,内存操作指令 
    wire sb     = (opcode == `OP_SB  );
    wire sh     = (opcode == `OP_SH  );
    wire sw     = (opcode == `OP_SW  );
    //branch跳转型指令,条件跳转 
    wire beq    = (opcode == `OP_BEQ   );
    wire bne    = (opcode == `OP_BNE   );
    wire bnel   = (opcode == `OP_BNEL  );
    wire blez   = (opcode == `OP_BLEZ  );
    wire bgtz   = (opcode == `OP_BGTZ  );
    wire bgrtzl = (opcode == `OP_BGRTZL);  
    // j_r,跳转到寄存器的地址数据 
    // j_aadr,跳转到立即数对应的地址
    // j_l: jal , jalr,这两个是需要link的
    wire j      = (opcode == `OP_J   );
    wire jal    = (opcode == `OP_JAL );
    wire jr     = (opcode == `OP_JR  ) && (func == `FUN_JR );
    wire jalr   = (opcode == `OP_JALR) && (func ==`FUN_JALR);
    // md 
    wire mult   = Rtype && (func == `FUN_MULT );
    wire multu  = Rtype && (func == `FUN_MULTU);
    wire div    = Rtype && (func == `FUN_DIV  );
    wire divu   = Rtype && (func == `FUN_DIVU );
    // mt  
    wire mtlo   = Rtype && (func == `FUN_MTLO );
    wire mthi   = Rtype && (func == `FUN_MTHI );
    // mf 
    wire mflo   = Rtype && (func == `FUN_MFLO );
    wire mfhi   = Rtype && (func == `FUN_MFHI );

// load 和 store可归类,仅load和store是`CU_EXT_SIGNED
// 大多数为`ALU_add
    assign o_cmpOp            = (beq    ) ? `CMP_EQUAL    :
                                (bne    ) ? `CMP_NOT_EQUAL:
                                            `CMP_EQUAL    ;
    assign o_ext_Sel          = (ori  | andi | xori) ? `CU_EXT_UNSIGNED :
                                (lui               ) ? `CU_EXT_LUI      :
                                                       `CU_EXT_SIGNED   ;
    assign o_npcOp            = (o_b_type ) ? `NPC_BRANCH :
                                (o_j_imm26) ? `NPC_J  :
                                (o_j_r    ) ? `NPC_JR :
                                              `NPC_PC4;
    assign o_aluOp            = (sub | subu) ? `ALU_sub :
                                (And | andi) ? `ALU_and :
                                (Xor       ) ? `ALU_xor :
                                (Nor       ) ? `ALU_nor :
                                (slt       ) ? `ALU_slt :
                                (sltu      ) ? `ALU_sltu:
                                (Or  | ori ) ? `ALU_or  :
                                (sll       ) ? `ALU_sll :
                                (srl       ) ? `ALU_srl :
                                (sra       ) ? `ALU_sra :
                                               `ALU_add ;
    assign o_mduOp            = (mult ) ? `MDU_MULT :
                                (multu) ? `MDU_MULTU:
                                (div  ) ? `MDU_DIV  :
                                (divu ) ? `MDU_DIVU :
                                (mtlo ) ? `MDU_MTLO :
                                (mthi ) ? `MDU_MTHI :
                                (mflo ) ? `MDU_MFLO :
                                (mfhi ) ? `MDU_MFHI :
                                          `MDU_DEFAULT;
    assign o_mdu_start        =  o_md;
    assign o_alu_srcA_Sel     = `CU_ALU_SRCA_RS;
    assign o_alu_srcB_Sel     = (o_calc_r                   ) ? `CU_ALU_SRCB_RT   :
                                (o_calc_i | o_load | o_store) ? `CU_ALU_SRCB_IMM32:
                                                                `CU_ALU_SRCB_RT   ;
    assign o_alu_shamt_Sel    = (o_shift_s) ? `CU_ALU_SHAMT_SEL_SA :
                                              `CU_ALU_SHAMT_SEL_DEFAULT ;
    assign o_beOp             = (sw ) ? `BE_SW :
                                (sh ) ? `BE_SH :
                                (sb ) ? `BE_SB :
                                        `BE_NONE ;
    assign o_deOp             = (lw ) ? `DE_LW :
                                (lh ) ? `DE_LH :
                                (lhu) ? `DE_LHU:
                                (lb ) ? `DE_LB :
                                (lbu) ? `DE_LBU:
                                        `DE_NONE ;  
    assign o_dm_writeEn       = (o_store) ? 1'b1 :
                                            1'b0 ;
    // 在外部处理写入地址为0的情况，在里面处理也行
    assign o_grf_writeEn      = (o_calc_r | o_calc_i | o_lui | o_load | o_link | o_mf ) ? 1'b1 :
                                                                                                      1'b0 ;
    assign o_grf_WA           = (o_calc_r | jalr  | o_mf  ) ? o_rd :
                                (o_calc_i | o_lui | o_load) ? o_rt :
                                (o_link                   ) ? 5'd31:
                                                              0;
    assign o_grf_WD_Sel       = (o_load             ) ? `GRF_WD_MEM_RD     :
                                (o_calc_r | o_calc_i) ? `GRF_WD_ALU_RESULT :
                                (o_mf               ) ? `GRF_WD_MDU_RESULT :
                                (o_link             ) ? `GRF_WD_PC8        :
                                (o_lui              ) ? `GRF_WD_EXT        : 
                                                        `GRF_WD_ALU_RESULT ;
// 对指令进行归类处理！！
    assign o_calc_r  = add  | sub  | addu | subu | 
                       And  | Or   | Xor  | Nor  |
                       slt  | sltu | 
                       sll  | srl  | sra  |
                       sllv | srlv | srav ;
    assign o_calc_i  = addi | andi | ori;
    assign o_lui     = lui;

    assign o_shift_s = sll  | srl  | sra;
    assign o_shift_v = sllv | srlv | srav;
    assign o_load    = lb | lh | lw | lhu | lbu;
    assign o_store   = sb | sh | sw;

    assign o_b_type  = beq | bne;
    assign o_j_r     = jr   | jalr;
    assign o_j_imm26 = j    | jal;
    assign o_link    = jal  | jalr ;
    assign o_md      = mult | multu | div | divu;
    assign o_mt      = mtlo | mthi;
    assign o_mf      = mflo | mfhi;
endmodule
