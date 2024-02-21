`timescale 1ns/1ps
`include "def.v"
module mips_CPU(
    input  clk,
    input  reset,

    input  [5 :0] i_HWInt,          // 来自timer和HW的中断信号
    
    input  [31:0] i_inst_rdata,     // i_inst_addr对应的32位指令
    input  [31:0] m_data_rdata,     // m_data_addr对应的32位数据

    output [31:0] i_inst_addr,      // 需要进行取值操作的流水线PC(一般为F级)
    output [31:0] m_data_addr,      // 数据存储器待写入地址
    output [31:0] m_data_wdata,     // 数据存储器待写入数据
    output [3 :0] m_data_byteen,    // 字节使能信号
    output [31:0] m_inst_addr,      // M级PC

    output        w_grf_we,         // GRF写使能信号
    output [4 :0] w_grf_addr,       // GRF中待写入寄存器编号
    output [31:0] w_grf_wdata,      // GRF中待写入数据
    output [31:0] w_inst_addr,      // W级PC

    output [31:0] o_macroscopic_pc, //宏观PC 
    output o_tb_Req
);
    // 冒险解决的旁路转换模块
    // wire [1:0] D_forward_A_Sel, D_forward_B_Sel, E_forward_A_Sel, E_forward_B_Sel;
    // wire [1:0] D_forward_jr;
    wire stall;
    wire stall_PC;
    wire stall_FD;
    wire clr_DE; 
    // 各个中间寄存器的写使能端口
    wire FD_writeEn;
    wire DE_writeEn;
    wire EM_writeEn;
    wire MW_writeEn;
    // 各个中间寄存器的复位清空端口
    wire FD_flush;
    wire DE_flush;
    wire EM_flush;
    wire MW_flush;
    // 分布式控制需要用到的pc和指令
    wire [31:0] D_pc;
    wire [31:0] F_pc;
    wire [31:0] E_pc;
    wire [31:0] M_pc;
    wire [31:0] W_pc;
    wire [31:0] D_instr;
    wire [31:0] F_instr;
    wire [31:0] E_instr;
    wire [31:0] M_instr;
    wire [31:0] W_instr;
    wire [4 :0] D_grf_WA;
    wire [4 :0] F_grf_WA;
    wire [4 :0] E_grf_WA;
    wire [4 :0] M_grf_WA;
    wire [4 :0] W_grf_WA;

    // 各级是否为处于延时槽中的指令
    wire F_branch_delay;
    wire D_branch_delay;
    wire E_branch_delay;
    wire M_branch_delay;
    wire W_branch_delay;
    // 各级的异常信息
    wire [4 :0] F_exc_code;
    wire [4 :0] D_exc_code;
    wire [4 :0] E_exc_code;
    wire [4 :0] M_exc_code;
    wire [4 :0] D_old_exc_code;
    wire [4 :0] E_old_exc_code;
    wire [4 :0] M_old_exc_code;
    // 各级的异常指示信息
    // todo:
    // F级异常，取指未字对齐或PC地址不在0x0000_3000-0x0000_6ffc
    wire F_exc_AdEL;
    // D级异常，未知的指令码
    wire D_exc_RI;
    wire D_exc_syscall;
    // E级异常，取数异常，存数异常
    wire E_exc_AriOv;
    wire E_exc_DMOv;
    // M级异常，取数异常，存数异常
    wire M_exc_AdEL;
    wire M_exc_AdES;
    // 各级eret信号
    wire D_eret;
    wire E_eret;
    wire M_eret;
    // EPC 和 Req来自于外部，于是所有流水都是同一组数据
    wire [31:0] EPC;
    wire Req;

    //------------- F need from HU ---------------
    wire F_pcEn;
    //-------------- D need from CU -------------
    wire [1 :0] D_ext_Sel;
    wire [3 :0] D_branchOp;     // for cmp operator
    wire [2 :0] D_npc_Op;
    wire [15:0] D_imm16;
    wire [25:0] D_imm26;
    //-------------- from D ------------------
    wire [31:0] D_grf_RD1;
    wire [31:0] D_grf_RD2;
    wire [31:0] D_ext_result;
    wire [31:0] D_npc;
    //------------- D stage value ---------------
    wire [4 :0] D_rs;
    wire [4 :0] D_rt;
    wire D_jumpEn_of_B;         // D_NPC
    wire [31:0] D_cmpA;
    wire [31:0] D_cmpB; // D_CMP
    // ***************ID/EX*******************    
    wire [31:0] E_grf_RD1;
    wire [31:0] E_grf_RD2;
    wire [31:0] E_ext_result;
    //-------------- E need from CU -------------
    wire [4 :0] E_aluOp;
    wire [4 :0] E_mduOp; 
    wire E_mdu_start;
    wire [2 :0] E_alu_srcA_Sel;
    wire [2 :0] E_alu_srcB_Sel;
    wire [2 :0] E_alu_shamt_Sel;
    wire [2 :0] E_grf_WD_Sel;
    wire [4 :0] E_rs;
    wire [4 :0] E_rt;
    wire [4 :0] E_sa;
    wire [31:0] E_aluA;
    wire [31:0] E_aluB;
    wire E_alu_DMOv;
    wire E_alu_AriOv;
    //----------------- from E ------------------
    wire [31:0] E_alu_result;
    wire [31:0] E_mdu_result;
    wire [31:0] E_mdu_hi;
    wire [31:0] E_mdu_lo;
    wire E_mdu_busy;
    //---------------E stage value --------------
    wire [31:0] E_dm_writeData;
    // ***************EX/MEM*******************    
    wire [31:0] M_alu_result;
    wire [31:0] M_mdu_result;
    //---------------M stage value --------------
    wire [31:0] M_dm_writeData;
        //----------------- from M ------------------
    wire [31:0] M_dm_RD;
    //-------------- M need from CU -------------
    wire [2 :0] M_beOp;
    wire [2 :0] M_deOp;
    wire [2 :0] M_grf_WD_Sel;
    wire M_dm_writeEn;
    wire M_CP0En;
    wire M_load;
    wire M_store;
    //---------------M stage value --------------
    wire [31:0] M_dm_Addr;
    wire [31:0] M_ext_result;
    wire [4 :0] M_rt;
    wire [4 :0] M_rd;
    wire [31:0] M_CP0Out;
    //------------- W stage value ----------------
    //------------ W need from CU ----------------
    wire [2 :0] W_grf_WD_Sel;
    wire W_grf_writeEn;
    //------------ W stage value -----------------
    wire [31:0] W_ext_result;
    wire [31:0] W_CP0Out;
    // ***************MEM/WB*******************    
    wire [31:0] W_dm_RD;
    wire [31:0] W_alu_result;
    wire [31:0] W_mdu_result;


    _HU _hu(
        .i_D_instr(D_instr),
        .i_E_instr(E_instr),
        .i_M_instr(M_instr),
        .i_W_instr(W_instr),
        .i_mdu_start(E_mdu_start),
        .i_mdu_busy(E_mdu_busy),
        .i_tb_Req(o_tb_Req),
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

    wire [31:0] E_grf_writeData;
    wire [31:0] M_grf_writeData;
    wire [31:0] W_grf_writeData;

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
                             (W_grf_WD_Sel == `GRF_WD_CP0OUT    ) ? W_CP0Out     :
                                                                    32'h0000_0000;   
// `define EXC_INT                   5'd0      // 外部中断信号
// `define EXC_ADEL                  5'd4      // 取数异常
// `define EXC_ADES                  5'd5      // 存数异常
// `define EXC_SYSCALL               5'd8      // 系统调用
// `define EXC_RI                    5'd10     // 未知指令
// `define EXC_OV                    5'd12     // 算术溢出
    assign F_exc_code     = F_exc_AdEL ? `EXC_ADEL : `EXC_NONE;
    assign F_branch_delay =(D_npc_Op  != `NPC_PC4);                
    assign D_exc_code     = D_old_exc_code ? D_old_exc_code :
                            D_exc_syscall  ? `EXC_SYSCALL   :
                            D_exc_RI       ? `EXC_RI        :
                            `EXC_NONE;
    // D_branch_delay 在FD_REG中参与流水
    // 其余branch_delay信号："俺也一样"
    assign E_exc_code     = E_old_exc_code ? E_old_exc_code :
                            E_exc_AriOv    ? `EXC_OV        :
                            `EXC_NONE;
    assign M_exc_code     = M_old_exc_code ? M_old_exc_code :
                            M_exc_AdES     ? `EXC_ADES      :
                            M_exc_AdEL     ? `EXC_ADEL      :
                            `EXC_NONE;
////////////////Instruction Fetch (IF) //////////////////////////

// @NPC:获取下一个pc，与当前指令的类型相关，同时branch类型指令还和CMP的计算结果相关(位于GRF中取值之后)    
// @PC:状态转移，在时钟上升到来时由当前pc转为下一个pc    
// @IM:从IM的ROM中获取指令    
// !IM外置：
    wire   [31 :0] F_old_pc;
    assign F_pc = D_eret ? EPC : F_old_pc;
    assign i_inst_addr = F_pc;

    assign F_exc_AdEL  = (( |F_pc[1:0]) | (F_pc < `PC_BEGIN_MIN) | (F_pc > `PC_END_MAX)) && !D_eret;
    assign F_instr     = F_exc_AdEL ? `INSTR_DEFAULT : i_inst_rdata;    // 32'h0000_0000

    F_PC _F_pc(
        .i_clk(clk),
        .i_reset(reset),
        .i_Req(Req),
        .i_en(F_pcEn),
        .i_npc(D_npc),  
        .or_pc(F_old_pc)
    );
// ***************IF/ID*******************    
// @FD_REG:IF/ID阶段的寄存器,这些寄存器用于D级流水线
    FD_REG _FD_reg(
        .i_clk(clk),
        .i_reset(reset),
        .i_en(FD_writeEn),
        .i_flush(FD_flush),
        .i_Req(Req),

        .i_pc(F_pc),
        .i_instr(F_instr),
        .i_branch_delay(F_branch_delay),
        .i_exc_code(F_exc_code),

        .or_pc(D_pc),
        .or_instr(D_instr),
        .or_branch_delay(D_branch_delay),
        .or_exc_code(D_old_exc_code)
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
        .o_grf_WA(D_grf_WA),    

        .o_eret(D_eret),
        .o_exc_RI(D_exc_RI),
        .o_syscall(D_exc_syscall)
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
    assign w_grf_we    =  W_grf_writeEn;
    assign w_grf_addr  =  W_grf_WA;
    assign w_grf_wdata =  W_grf_writeData;
    assign w_inst_addr =  W_pc;


    wire [31:0] D_FWD_rs_RD1 = (D_rs == 5'h0    ) ? 32'h0000_0000 :
                               (D_rs == E_grf_WA) ? E_grf_writeData :
                               (D_rs == M_grf_WA) ? M_grf_writeData :
                                                    D_grf_RD1;
    wire [31:0] D_FWD_rt_RD2 = (D_rt == 5'h0    ) ? 32'h0000_0000 :
                               (D_rt == E_grf_WA) ? E_grf_writeData :
                               (D_rt == M_grf_WA) ? M_grf_writeData :
                                                    D_grf_RD2;
    D_NPC _D_npc(
        .i_Req(Req),
        .i_tb_Req(o_tb_Req),
        .i_eret(D_eret),
        .i_EPC(EPC),
        .i_F_pc(F_pc),
        .i_D_pc(D_pc),
        .i_npcOp(D_npc_Op),
        .i_jumpEn_of_B(D_jumpEn_of_B),
        .i_imm16(D_imm16),
        .i_imm26(D_imm26),
        .i_ra_of_jr(D_FWD_rs_RD1),
        .o_npc(D_npc)
    );
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
        .i_Req(Req),

        .i_pc(D_pc),
        .i_instr(D_exc_RI ? 32'd0 : D_instr),
        .or_pc(E_pc),
        .or_instr(E_instr),

        .i_grf_RD1(D_FWD_rs_RD1),
        .i_grf_RD2(D_FWD_rt_RD2),
        .i_ext_result(D_ext_result),
        .or_grf_RD1(E_grf_RD1),
        .or_grf_RD2(E_grf_RD2),
        .or_ext_result(E_ext_result),

        .i_branch_delay(D_branch_delay),
        .i_exc_code(D_exc_code),
        .or_branch_delay(E_branch_delay),
        .or_exc_code(E_old_exc_code)
    );
////////////////Executin (EX) //////////////////////////
// @CU:产生EX阶段的控制信号
// @ALU:algorithm logical unit
    _CU _E_cu(
        .i_instr(E_instr),
    
        .o_rs(E_rs),
        .o_rt(E_rt),
        .o_sa(E_sa),

        .o_aluOp(E_aluOp),
        .o_alu_srcA_Sel(E_alu_srcA_Sel),
        .o_alu_srcB_Sel(E_alu_srcB_Sel),
        .o_alu_shamt_Sel(E_alu_shamt_Sel),
        .o_grf_WA(E_grf_WA),
        .o_grf_WD_Sel(E_grf_WD_Sel),

        .o_mduOp(E_mduOp),
        .o_mdu_start(E_mdu_start),

        .o_alu_DMOv(E_alu_DMOv),
        .o_alu_AriOv(E_alu_AriOv),
        .o_eret(E_eret)
    );
    wire [31:0] E_FWD_rs_RD1 = (E_rs == 5'h0    ) ? 0 :
                               (E_rs == M_grf_WA) ? M_grf_writeData :
                               (E_rs == W_grf_WA) ? W_grf_writeData :
                                                    E_grf_RD1;
    wire [31:0] E_FWD_rt_RD2 = (E_rt == 5'h0    ) ? 0 :
                               (E_rt == M_grf_WA) ? M_grf_writeData :
                               (E_rt == W_grf_WA) ? W_grf_writeData :
                                                    E_grf_RD2;
    assign E_aluA =  (E_alu_srcA_Sel  == `CU_ALU_SRCA_RT     )  ? E_FWD_rt_RD2 :
                                                                  E_FWD_rs_RD1 ;
    assign E_aluB =  (E_alu_srcB_Sel  == `CU_ALU_SRCB_IMM32  )  ? E_ext_result :
                                                                  E_FWD_rt_RD2 ;
    assign E_shamt = (E_alu_shamt_Sel == `CU_ALU_SHAMT_SEL_SA) ? E_sa :
                                         `ALU_SHAMT_DEFAULT;
    assign E_dm_writeData = E_FWD_rt_RD2;   // sw, base + offset
    E_ALU _E_alu(
        .i_srcA(E_aluA),
        .i_srcB(E_aluB),
        .i_aluOp(E_aluOp),
        .i_shamt(E_sa),
        .o_result(E_alu_result),
        .i_alu_DMOv(E_alu_DMOv),
        .i_alu_AriOv(E_alu_AriOv),
        .o_exc_DMOv(E_exc_DMOv),
        .o_exc_AriOv(E_exc_AriOv)
    );

    E_MDU _E_mdu(
        .i_clk(clk),
        .i_reset(reset),
        .i_Req(Req),

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
        .i_Req(Req),

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
        .or_ext_result(M_ext_result),

        .i_branch_delay(E_branch_delay),
        .i_exc_code(E_exc_code),
        .i_exc_DMOv(E_exc_DMOv),
        .or_branch_delay(M_branch_delay),
        .or_exc_code(M_old_exc_code),
        .or_exc_DMOv(M_exc_DMOv)
    );
////////////////Memory access (MEM)//////////////////////////
// @CU:产生M阶段的控制信号
// @DM:data memory,用于内存操作的指令
// @DE:用于处理读DM的数据
// @BE:用于处理写DM的数据
    _CU _M_cu(
        .i_instr(M_instr),

        .o_load(M_load),
        .o_store(M_store),
        .o_eret(M_eret),

        .o_rt(M_rt),
        .o_rd(M_rd),
        .o_beOp(M_beOp),
        .o_deOp(M_deOp),
        .o_dm_writeEn(M_dm_writeEn),
        .o_grf_WA(M_grf_WA),
        .o_grf_WD_Sel(M_grf_WD_Sel),

        .o_CP0En(M_CP0En)
    );
    assign M_dm_Addr = M_alu_result;
    wire [31:0] M_FWD_writeData = (M_rt == 5'h0    ) ? 0 :
                                  (M_rt == W_grf_WA) ? W_grf_writeData :
                                                       M_dm_writeData  ;
// !DM外置:
    assign m_inst_addr = M_pc;
    assign m_data_addr = M_dm_Addr;
    // load
    M_DE _M_de(
        .i_deOp(M_deOp),
        .i_Addr(M_dm_Addr),
        .i_m_data_rdata(m_data_rdata),
        .or_RD(M_dm_RD),

        .i_load(M_load),
        .i_exc_DMOv(M_exc_DMOv),
        .o_exc_AdEL(M_exc_AdEL)
    );
    // store
    M_BE _M_be(
        .i_writeEn(M_dm_writeEn && (!Req)),
        .i_beOp(M_beOp),
        .i_Addr(M_dm_Addr),
        .i_writeData(M_FWD_writeData),
        .or_m_data_byteen(m_data_byteen),
        .or_m_data_wdata(m_data_wdata),

        .i_store(M_store),
        .i_exc_DMOv(M_exc_DMOv),
        .o_exc_AdES(M_exc_AdES)
    );
    // coprocessor0
    
    assign o_macroscopic_pc = M_pc;

    mips_CP0 _mips_cp0(
        .i_clk(clk),
        .i_reset(reset),
        .i_en(M_CP0En),

        .i_CP0Addr(M_rd),
        .i_CP0In(M_FWD_writeData),
        .i_VPC(M_pc),
        .i_BDIn(M_branch_delay),
        .i_ExcCodeIn(M_exc_code),
        .i_HWInt(i_HWInt),
        .i_EXLClr(M_eret),
        .o_CP0Out(M_CP0Out),
        .o_EPCOut(EPC),
        .o_Req(Req),
        .o_tb_Req(o_tb_Req)
    );
// ***************MEM/WB*******************    
// @MW_REG:MEM/WB 阶段的寄存器,这些寄存器用于W级流水线
    MW_REG _MW_reg(
        .i_clk(clk),
        .i_reset(reset),
        .i_en(MW_writeEn),
        .i_flush(MW_flush),
        .i_Req(Req),

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
        .or_ext_result(W_ext_result),

        .i_CP0Out(M_CP0Out),
        .or_CP0Out(W_CP0Out)
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
