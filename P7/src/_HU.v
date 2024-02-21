`timescale 1ns/1ps
`include "def.v"
`define EPC 5'd14
// Hazard Ctrl Unit
module _HU(
    input  [31:0] i_D_instr,
    input  [31:0] i_E_instr,
    input  [31:0] i_M_instr,
    input  [31:0] i_W_instr,
    input  i_tb_Req,

    input  i_mdu_start,
    input  i_mdu_busy ,
    output o_stall
    // output [1:0] o_E_forward_A_Sel,
    // output [1:0] o_E_forward_B_Sel,
    // output [1:0] o_D_forward_A_Sel,
    // output [1:0] o_D_forward_B_Sel,
    // output [1:0] o_D_forward_A_jr
);
    wire [4 :0] D_rs, D_rt;
    wire [4 :0] E_rs, E_rt;
    wire [4 :0] E_rd, M_rd;
    wire [4 :0] E_grf_WA, M_grf_WA, W_grf_WA;
    // AT法
    wire D_load, D_store, D_calc_r, D_calc_i, D_lui, D_shift_s, D_shift_v, D_b_type, D_j_r,  D_j_imm26, D_link, D_md, D_mt, D_mf;
    wire D_mfc0, D_mtc0, D_eret;
    _CU _hu_D_cu(
        .i_instr(i_D_instr),

        .o_rs(D_rs),
        .o_rt(D_rt),

        .o_calc_r(D_calc_r),
        .o_calc_i(D_calc_i),
        .o_lui(D_lui),
        .o_shift_s(D_shift_s),
        .o_shift_v(D_shift_v),
        .o_load(D_load),
        .o_store(D_store),
        .o_b_type(D_b_type),
        .o_j_r(D_j_r),
        .o_j_imm26(D_j_imm26),
        .o_link(D_link),
        .o_md(D_md),
        .o_mt(D_mt),
        .o_mf(D_mf),

        .o_mfc0(D_mfc0),
        .o_mtc0(D_mtc0),
        .o_eret(D_eret)
    );

    wire [7:0] D_Tuse_rs, D_Tuse_rt;
    // lui 在ext中进行计算，更快，lui也不需要使用rs，rt
    assign D_Tuse_rs = ( D_b_type | D_j_r                                                  ) ? 8'd0 :
                       ((D_calc_r & !D_shift_s) | D_calc_i | D_load | D_store | D_md | D_mt) ? 8'd1 :
                                                                                               8'd3 ;
    assign D_Tuse_rt = (D_b_type          ) ? 8'd0 :
                       (D_calc_r | D_md   ) ? 8'd1 :
                       (D_store  | D_mtc0 ) ? 8'd2 :
                                              8'd3 ;
 
    wire E_load, E_store, E_calc_r, E_calc_i, E_lui, E_shift_s, E_shift_v, E_b_type, E_j_r, E_j_imm26, E_link, E_md, E_mt, E_mf;
    wire E_mfc0, E_mtc0, E_eret;
    _CU _hu_E_cu(
        .i_instr(i_E_instr),

        .o_rs(E_rs),
        .o_rt(E_rt),
        .o_rd(E_rd),
        .o_grf_WA(E_grf_WA),

        .o_calc_r(E_calc_r),
        .o_calc_i(E_calc_i),
        .o_load(E_load),
        .o_store(E_store),
        .o_lui(E_lui),
        .o_shift_s(E_shift_s),
        .o_shift_v(E_shift_v),
        .o_b_type(E_b_type),
        .o_j_r(E_j_r),
        .o_j_imm26(E_j_imm26),
        .o_link(E_link),
        .o_md(E_md),
        .o_mt(E_mt),
        .o_mf(E_mf),

        .o_mfc0(E_mfc0),
        .o_mtc0(E_mtc0),
        .o_eret(E_eret)
    );

    wire [7:0] E_Tnew = (E_calc_r | E_calc_i | E_mf) ? 8'd1 :
                        (E_load   | E_mfc0         ) ? 8'd2 :
                                                       8'd0 ;
    
    wire M_load, M_store, M_calc_r, M_calC_i, M_lui, M_shift_s, M_shift_v, M_b_type, M_j_r, M_j_imm26,M_link, M_md, M_mt, M_mf;
    wire M_mfc0, M_mtc0, M_eret;
    _CU _hu_M_cu(
        .i_instr(i_M_instr),

        .o_grf_WA(M_grf_WA),
        .o_rd(M_rd),

        .o_load(M_load),
        .o_store(M_store),
        .o_calc_r(M_calc_r),
        .o_calc_i(M_calc_i),
        .o_lui(M_lui),
        .o_shift_s(M_shift_s),
        .o_shift_v(M_shift_v),
        .o_b_type(M_b_type),
        .o_j_r(M_j_r),
        .o_j_imm26(M_j_imm26),
        .o_link(M_link),
        .o_md(M_md),
        .o_mt(M_mt),
        .o_mf(M_mf),

        .o_mfc0(M_mfc0),
        .o_mtc0(M_mtc0),
        .o_eret(M_eret)
    );

    wire [7:0] M_Tnew = (M_load | M_mfc0) ? 8'd1 : 
                                            8'd0 ;

    _CU _hu_W_cu(
        .i_instr(i_W_instr),
        .o_grf_WA(W_grf_WA),

        .o_grf_writeEn(W_grf_writeEn)
    );
    // 暂停
    wire stall_rs_E   = (D_Tuse_rs < E_Tnew) && (D_rs != 5'b0) && (D_rs == E_grf_WA);
    wire stall_rs_M   = (D_Tuse_rs < M_Tnew) && (D_rs != 5'b0) && (D_rs == M_grf_WA);
    wire stall_rs     = stall_rs_E | stall_rs_M;
  
    wire stall_rt_E   = (D_Tuse_rt < E_Tnew) && (D_rt != 5'b0) && (D_rt == E_grf_WA);
    wire stall_rt_M   = (D_Tuse_rt < M_Tnew) && (D_rt != 5'b0) && (D_rt == M_grf_WA);
    wire stall_rt     = stall_rt_E | stall_rt_M;
      
    wire stall_busy   = ((D_md | D_mt | D_mf) && (i_mdu_start | i_mdu_busy));  

    wire stall_eret_M = (D_eret) && ((E_mtc0 && (E_rd == `EPC)) || (M_mtc0 && (M_rd == `EPC)));

    assign o_stall = stall_rs | stall_rt | stall_busy | stall_eret_M ;

    // 旁路转发
    // ------------------采取无脑转发理论--------------------------
endmodule