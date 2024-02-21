`timescale 1ns/1ps
`include "def.v"
module mips(
    input  clk,
    input  reset,
 
    input  [31:0] i_inst_rdata, // i_inst_addr对应的32位指令
    input  [31:0] m_data_rdata, // m_data_addr对应的32位数据
    
    output [31:0] i_inst_addr,  // 需要进行取值操作的流水线PC(一般为F级)
    output [31:0] m_data_addr,  // 数据存储器待写入地址
    output [31:0] m_data_wdata, // 数据存储器待写入数据
    output [3 :0] m_data_byteen,// 字节使能信号
    output [31:0] m_inst_addr,  // M级PC
    output        w_grf_we,     // GRF写使能信号
    output [4 :0] w_grf_addr,   // GRF中待写入寄存器编号
    output [31:0] w_grf_wdata,  // GRF中待写入数据
    output [31:0] w_inst_addr   // W级PC
);
    // 冒险解决的旁路转换模块
    // wire [1:0] D_forward_A_Sel, D_forward_B_Sel, E_forward_A_Sel, E_forward_B_Sel;
    // wire [1:0] D_forward_jr;
    wire stall, stall_PC, stall_FD, clr_DE; 
    // 各个中间寄存器的写使能端口
    wire FD_writeEn, DE_writeEn, EM_writeEn, MW_writeEn;
    // 各个中间寄存器的复位清空端口
    wire FD_flush, DE_flush, EM_flush, MW_flush;
    // 分布式控制需要用到的pc和指令
    wire [31:0] D_pc    , F_pc    , E_pc    , M_pc    , W_pc    ;
    wire [31:0] D_instr , F_instr , E_instr , M_instr , W_instr ;
    wire [4 :0] D_grf_WA, F_grf_WA, E_grf_WA, M_grf_WA, W_grf_WA;
    //------------- F need from HU ---------------
    wire F_pcEn;
    //-------------- D need from CU -------------
    wire [1 :0] D_ext_Sel;
    wire [3 :0] D_branchOp;     // for cmp operator
    wire [2 :0] D_npc_Op;
    wire [15:0] D_imm16;
    wire [25:0] D_imm26;
    //-------------- from D ------------------
    wire [31:0] D_grf_RD1, D_grf_RD2, D_ext_result, D_npc;
    //------------- D stage value ---------------
    wire [4 :0] D_rs, D_rt;
    wire D_jumpEn_of_B;         // D_NPC
    wire [31:0] D_cmpA, D_cmpB; // D_CMP
    // ***************ID/EX*******************    
    wire [31:0] E_grf_RD1, E_grf_RD2, E_ext_result;
    //-------------- E need from CU -------------
    wire [4 :0] E_aluOp, E_mduOp; 
    wire E_mdu_start;
    wire [2 :0] E_alu_srcA_Sel, E_alu_srcB_Sel, E_alu_shamt_Sel;
    wire [2 :0] E_grf_WD_Sel;
    wire [4 :0] E_rs, E_rt, E_sa;
    wire [31:0] E_aluA, E_aluB;
    //----------------- from E ------------------
    wire [31:0] E_alu_result, E_mdu_result;
    wire [31:0] E_mdu_hi, E_mdu_lo;
    wire E_mdu_busy;
    //---------------E stage value --------------
    wire [31:0] E_dm_writeData;
    // ***************EX/MEM*******************    
    wire [31:0] M_alu_result, M_mdu_result;
    //---------------M stage value --------------
    wire [31:0] M_dm_writeData;
        //----------------- from M ------------------
    wire [31:0] M_dm_RD;
    //-------------- M need from CU -------------
    wire [2 :0] M_beOp, M_deOp, M_grf_WD_Sel;
    wire M_dm_writeEn;
    //---------------M stage value --------------
    wire [31:0] M_dm_Addr, M_ext_result;
    wire [4 :0] M_rt;
    //------------- W stage value ----------------
    //------------ W need from CU ----------------
    wire [2 :0] W_grf_WD_Sel;
    wire W_grf_writeEn;
    //------------ W stage value -----------------
    wire [31:0] W_ext_result;
    wire [4 :0] W_grf_writeAddr;
    // ***************MEM/WB*******************    
    wire [31:0] W_dm_RD, W_alu_result, W_mdu_result;
    _HU _hu(
        .i_D_instr(D_instr),
        .i_E_instr(E_instr),
        .i_M_instr(M_instr),
        .i_W_instr(W_instr),
        .o_stall(stall)
    );
    assign stall_FD = stall;
    assign stall_PC = stall;
    assign clr_DE   = stall;

    assign F_pcEn     = !stall_PC;
    // 使能信号
    assign FD_writeEn = !stall_FD;
    assign DE_writeEn = 1'b1;
    assign EM_writeEn = 1'b1;
    assign MW_writeEn = 1'b1;
    // flush 清空信号
    assign FD_fulsh   = 1'b0;
    assign DE_flush   = clr_DE;
    assign EM_flush   = 1'b0;
    assign MW_flush   = 1'b0;

    wire [31:0] E_grf_writeData, M_grf_writeData, W_grf_writeData;
    assign E_grf_writeData = (E_grf_WD_Sel == `GRF_WD_PC4       ) ? (E_pc + 4)   :
                             (E_grf_WD_Sel == `GRF_WD_PC8       ) ? (E_pc + 8)   :
                             (E_grf_WD_Sel == `GRF_WD_ALU_RESULT) ? E_alu_result :
                             (E_grf_WD_Sel == `GRF_WD_MDU_RESULT) ? E_mdu_result :
                             (E_grf_WD_Sel == `GRF_WD_EXT       ) ? E_ext_result :
                             //  (E_grf_WD_Sel == `GRF_WD_MEM_RD    ) ? M_dm_RD:
                                                                    32'h0000_0000;
    assign M_grf_writeData = (M_grf_WD_Sel == `GRF_WD_PC4       ) ? (M_pc + 4  ) :
                             (M_grf_WD_Sel == `GRF_WD_PC8       ) ? (M_pc + 8  ) :
                             (M_grf_WD_Sel == `GRF_WD_ALU_RESULT) ? M_alu_result :
                             (M_grf_WD_Sel == `GRF_WD_MDU_RESULT) ? M_mdu_result :
                             (M_grf_WD_Sel == `GRF_WD_EXT       ) ? M_ext_result :
                            //  (M_grf_WD_Sel == `GRF_WD_MEM_RD    ) ? M_dm_RD :    :
                                                                    32'h0000_0000;   
    assign W_grf_writeData = (W_grf_WD_Sel == `GRF_WD_PC4       ) ? (W_pc + 4  ) :
                             (W_grf_WD_Sel == `GRF_WD_PC8       ) ? (W_pc + 8  ) :
                             (W_grf_WD_Sel == `GRF_WD_ALU_RESULT) ? W_alu_result :
                             (W_grf_WD_Sel == `GRF_WD_MDU_RESULT) ? W_mdu_result :
                             (W_grf_WD_Sel == `GRF_WD_EXT       ) ? W_ext_result :
                             (W_grf_WD_Sel == `GRF_WD_MEM_RD    ) ? W_dm_RD      :
                                                                    32'h0000_0000;                     
////////////////Instruction Fetch (IF) //////////////////////////

// @NPC:获取下一个pc，与当前指令的类型相关，同时branch类型指令还和CMP的计算结果相关(位于GRF中取值之后)    
// @PC:状态转移，在时钟上升到来时由当前pc转为下一个pc    
// @IM:从IM的ROM中获取指令    
    // F_IM _F_im(
    //     .i_pc(F_pc),
    //     .o_instr(F_instr)
    // );
// !IM外置：
    assign i_inst_addr = F_pc;
    assign F_instr     = i_inst_rdata;

    F_PC _F_pc(
        .i_clk(clk),
        .i_reset(reset),
        .i_en(F_pcEn),
        .i_npc(D_npc),  
        .or_pc(F_pc)
    );
// ***************IF/ID*******************    
// @FD_REG:IF/ID阶段的寄存器,这些寄存器用于D级流水线
    FD_REG _FD_reg(
        .i_clk(clk),
        .i_reset(reset),
        .i_en(FD_writeEn),
        .i_flush(FD_flush),

        .i_pc(F_pc),
        .i_instr(F_instr),

        .or_pc(D_pc),
        .or_instr(D_instr)
    );
////////////////Instruction Decode (ID) //////////////////////////
// 这一些是在CU部分拆分F_instr得到的，都属于F级流水线
// @CU:控制单元，得到各种控制信号，部分控制信号需要跟随流水线往下流
// @CMP:用于比如beq指令的branch类型的跳转判断
// @GRF:常用寄存器堆
// @EXT:将16位立即数符号拓展或者无符号拓展为32为立即数
    _CU _D_cu(
        .i_instr(D_instr),

        .o_rs(D_rs),
        .o_rt(D_rt),
        .o_imm16(D_imm16),
        .o_imm26(D_imm26),

        .o_ext_Sel(D_ext_Sel),
        .o_cmpOp(D_branchOp),
        .o_npcOp(D_npc_Op),
        .o_grf_WA(D_grf_WA)
    );
    D_GRF _D_grf(
        .i_clk(clk),
        .i_reset(reset),
        .i_A1(D_rs),
        .i_A2(D_rt),
        .o_RD1(D_grf_RD1),
        .o_RD2(D_grf_RD2),

        .i_A3(W_grf_WA),
        .i_WD(W_grf_writeData),         
        .i_writeEn(W_grf_writeEn),

        .i_pc(W_pc),
        .i_instr(W_instr)
    );
// !GRF中也不需要输出了
    assign w_grf_we    = W_grf_writeEn;
    assign w_grf_addr  = W_grf_WA;
    assign w_grf_wdata = W_grf_writeData;
    assign w_inst_addr = W_instr;

    D_NPC _D_npc(
        .i_F_pc(F_pc),
        .i_D_pc(D_pc),
        .i_npcOp(D_npc_Op),
        .i_jumpEn_of_B(D_jumpEn_of_B),
        .i_imm16(D_imm16),
        .i_imm26(D_imm26),
        .i_ra_of_jr(D_FWD_rs_RD1),
        .o_npc(D_npc)
    );
    wire [31:0] D_FWD_rs_RD1 = (D_rs == 5'h0    ) ? 32'h0000_0000 :
                               (D_rs == E_grf_WA) ? E_grf_writeData :
                               (D_rs == M_grf_WA) ? M_grf_writeData :
                                                    D_grf_RD1;
    wire [31:0] D_FWD_rt_RD2 = (D_rt == 5'h0    ) ? 32'h0000_0000 :
                               (D_rt == E_grf_WA) ? E_grf_writeData :
                               (D_rt == M_grf_WA) ? M_grf_writeData :
                                                    D_grf_RD2;
    assign D_cmpA = D_FWD_rs_RD1;
    assign D_cmpB = D_FWD_rt_RD2;
    D_CMP _D_cmp(
        .i_cmpA(D_cmpA),
        .i_cmpB(D_cmpB),
        .i_branchOp(D_branchOp),
        .o_jumpEn_of_B(D_jumpEn_of_B)
    );
    D_EXT _D_ext(
        .i_imm16(D_imm16),
        .i_ext_Sel(D_ext_Sel),
        .o_ext_result(D_ext_result)
    );

// ***************ID/EX*******************    
// @DE_REG: ID/EX 之间的寄存器
    DE_REG _DE_reg(
        .i_clk(clk),
        .i_reset(reset),
        .i_en(DE_writeEn),
        .i_flush(DE_flush),

        .i_pc(D_pc),
        .i_instr(D_instr),
        .or_pc(E_pc),
        .or_instr(E_instr),

        .i_grf_RD1(D_FWD_rs_RD1),
        .i_grf_RD2(D_FWD_rt_RD2),
        .i_ext_result(D_ext_result),

        .or_grf_RD1(E_grf_RD1),
        .or_grf_RD2(E_grf_RD2),
        .or_ext_result(E_ext_result)
    );
////////////////Executin (EX) //////////////////////////
// @CU:产生EX阶段的控制信号
// @ALU:algorithm logical unit
    _CU _E_cu(
        .i_instr(E_instr),
    
        .o_rs(E_rs),
        .o_rt(E_rt),

        .o_aluOp(E_aluOp),
        .o_mduOp(E_mduOp),
        .o_mdu_start(E_mdu_start),
        .o_alu_srcA_Sel(E_alu_srcA_Sel),
        .o_alu_srcB_Sel(E_alu_srcB_Sel),
        .o_alu_shamt_Sel(E_alu_shamt_Sel),
        .o_grf_WA(E_grf_WA),
        .o_grf_WD_Sel(E_grf_WD_Sel)
    );
    wire [31:0] E_FWD_rs_RD1 = (E_rs == 5'h0    ) ? 0 :
                               (E_rs == M_grf_WA) ? M_grf_writeData :
                               (E_rs == W_grf_WA) ? W_grf_writeData :
                                                    E_grf_RD1;
    wire [31:0] E_FWD_rt_RD2 = (E_rt == 5'h0    ) ? 0 :
                               (E_rt == M_grf_WA) ? M_grf_writeData :
                               (E_rt == W_grf_WA) ? W_grf_writeData :
                                                    E_grf_RD2;
    assign E_aluA =  (E_alu_srcA_Sel == `CU_ALU_SRCA_RT   ) ? E_FWD_rt_RD2 :
                                                              E_FWD_rs_RD1 ;
    assign E_aluB =  (E_alu_srcB_Sel == `CU_ALU_SRCB_IMM32) ? E_ext_result :
                                                              E_FWD_rt_RD2 ;
    assign E_dm_writeData = E_FWD_rt_RD2;   // sw, base + offset
    E_ALU _E_alu(
        .i_srcA(E_aluA),
        .i_srcB(E_aluB),
        .i_aluOp(E_aluOp),
        .i_shamt(E_sa),
        .o_result(E_alu_result)
    );
    E_MDU _E_mdu(
        .i_clk(clk),
        .i_reset(reset),
        .i_srcA(E_FWD_rs_RD1),
        .i_srcB(E_FWD_rt_RD2),
        .i_mduOp(E_mduOp),
        .i_start(E_mdu_start),
        .or_hi(E_mdu_hi),
        .or_lo(E_mdu_lo),
        .or_result(E_mdu_result),
        .or_busy(E_mdu_busy)
    );
// ***************EX/MEM*******************    
// @EM_REG: EX/MEM 之间的寄存器
    EM_REG _EM_reg(
        .i_clk(clk),
        .i_reset(reset),
        .i_en(EM_writeEn),
        .i_flush(EM_flush),

        .i_pc(E_pc),
        .i_instr(E_instr),
        .or_pc(M_pc),
        .or_instr(M_instr),

        .i_alu_result(E_alu_result),
        .i_mdu_result(E_mdu_result),
        .i_mem_writeData(E_dm_writeData),
        .i_ext_result(E_ext_result),
        .or_alu_result(M_alu_result),
        .or_mdu_result(M_mdu_result),
        .or_mem_writeData(M_dm_writeData),
        .or_ext_result(M_ext_result)
    );
////////////////Memory access (MEM)//////////////////////////
// @CU:产生M阶段的控制信号
// @DM:data memory,用于内存操作的指令
// @DE:用于处理读DM的数据
// @BE:用于处理写DM的数据
    _CU _M_cu(
        .i_instr(M_instr),

        .o_rt(M_rt),
        .o_beOp(M_beOp),
        .o_deOp(M_deOp),
        .o_dm_writeEn(M_dm_writeEn),
        .o_grf_WA(M_grf_WA),
        .o_grf_WD_Sel(M_grf_WD_Sel)
    );
    assign M_dm_Addr = M_alu_result;
    wire [31:0] M_FWD_writeData = (M_rt == 5'h0    ) ? 0 :
                                  (M_rt == W_grf_WA) ? W_grf_writeData :
                                                       M_dm_writeData  ;
    // M_DM _M_dm(
    //     .i_clk(clk),
    //     .i_reset(reset),
    //     .i_Addr(M_dm_Addr),
    //     .i_writeData(M_FWD_writeData),
    //     .i_writeEn(M_dm_writeEn),
    //     .i_dmOp(M_dmOp),
    //     .o_RD(M_dm_RD),

    //     .i_pc(M_pc),
    //     .i_instr(M_instr)
    // );
// !DM外置:
    M_DE _M_de(
        .i_deOp(M_deOp),
        .i_Addr(M_dm_Addr),
        .i_m_data_rdata(m_data_rdata),
        .or_RD(M_dm_RD)
    );

    M_BE _M_be(
        .i_writeEn(M_dm_writeEn),
        .i_beOp(M_beOp),
        .i_Addr(M_dm_Addr),
        .i_writeData(M_FWD_writeData),
        .or_m_data_byteen(m_data_byteen),
        .or_m_data_wdata(m_data_addr)
    );
// ***************MEM/WB*******************    
// @MW_REG:MEM/WB 阶段的寄存器,这些寄存器用于W级流水线
    MW_REG _MW_reg(
        .i_clk(clk),
        .i_reset(reset),
        .i_en(MW_writeEn),
        .i_flush(MW_flush),

        .i_pc(M_pc),
        .i_instr(M_instr),
        .or_pc(W_pc),
        .or_instr(W_instr),

        .i_dm_RD(M_dm_RD),
        .i_alu_result(M_alu_result),
        .i_mdu_result(M_mdu_result),
        .i_ext_result(M_ext_result),
        .or_dm_RD(W_dm_RD),
        .or_alu_result(W_alu_result),
        .or_mdu_result(W_mdu_result),
        .or_ext_result(W_ext_result)
    );
//////////////// Write Back (WB) //////////////////////////
// 同样是对GRF _grf的操作,对应操作在上面
    _CU _W_cu(
        .i_instr(W_instr),

        .o_grf_WA(W_grf_WA),
        .o_grf_writeEn(W_grf_writeEn),
        .o_grf_WD_Sel(W_grf_WD_Sel)
    );
endmodule
