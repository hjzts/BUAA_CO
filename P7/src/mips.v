`timescale 1ns/1ps
`include "def.v"
module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    input  [31:0] i_inst_rdata,   // IM 读取数据
    input  [31:0] m_data_rdata,   // DM 读取数据

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    output [31:0] m_data_addr,    // DM 读写地址
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号
    output [31:0] m_inst_addr,    // M 级 PC

    output        w_grf_we,       // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据
    output [31:0] w_inst_addr,     // W 级 PC

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen    // 中断发生器字节使能信号
);
    // temp var
    wire [31:0] temp_m_data_rdata;
    wire [31:0] temp_m_data_addr;
    wire [31:0] temp_m_data_wdata;
    wire [3 :0] temp_m_data_byteen;
    wire [31:0] temp_m_inst_addr;
    // bridge temp var
    wire [31:0] bridge_m_data_addr;
    wire [3 :0] bridge_m_data_byteen;

    // TC0 var
    wire [31:0] TC0_Addr;
    wire [31:0] TC0_Din;
    wire [31:0] TC0_Dout;
    wire TC0_WE;
    wire TC0_IRQ;
    // TC1 var
    wire [31:0] TC1_Addr;
    wire [31:0] TC1_Din;
    wire [31:0] TC1_Dout;
    wire TC1_WE;
    wire TC1_IRQ;

    wire tb_Req;

    mips_CPU _mips_cpu(
        .clk(clk),
        .reset(reset),
        .i_HWInt(HWInt),
        .i_inst_rdata(i_inst_rdata),
        .i_inst_addr(i_inst_addr),

        .m_data_rdata(temp_m_data_rdata),

        .m_data_addr(temp_m_data_addr),
        .m_data_wdata(temp_m_data_wdata),
        .m_data_byteen(temp_m_data_byteen),
        .m_inst_addr(temp_m_inst_addr),

        .w_grf_we(w_grf_we),
        .w_grf_addr(w_grf_addr),
        .w_grf_wdata(w_grf_wdata),
        .w_inst_addr(w_inst_addr),
        .o_macroscopic_pc(macroscopic_pc),
        .o_tb_Req(tb_Req)
    );
    
    mips_Bridge _mips_bridge(
        .i_m_data_rdata(m_data_rdata),
        .o_m_data_addr(bridge_m_data_addr),
        .o_m_data_wdata(m_data_wdata),
        .o_m_data_byteen(bridge_m_data_byteen),
        .o_m_inst_addr(m_inst_addr),

        .o_temp_m_data_rdata(temp_m_data_rdata),
        .i_temp_m_data_addr(temp_m_data_addr),
        .i_temp_m_data_wdata(temp_m_data_wdata),
        .i_temp_m_data_byteen(temp_m_data_byteen),
        .i_temp_m_inst_addr(temp_m_inst_addr),

        .o_TC0_Addr(TC0_Addr),
        .o_TC0_WE(TC0_WE),
        .o_TC0_Din(TC0_Din),
        .i_TC0_Dout(TC0_Dout),

        .o_TC1_Addr(TC1_Addr),
        .o_TC1_WE(TC1_WE),
        .o_TC1_Din(TC1_Din),
        .i_TC1_Dout(TC1_Dout)
    );

    wire [5 :0] HWInt = {3'b0, interrupt, TC1_IRQ, TC0_IRQ}; 
    TC _tc0(
        .clk(clk),
        .reset(reset),
        .Addr(TC0_Addr[31:2]),
        .WE(TC0_WE),
        .Din(TC0_Din),
        .Dout(TC0_Dout),
        .IRQ(TC0_IRQ)
    );

    TC _tc1(
        .clk(clk),
        .reset(reset),
        .Addr(TC1_Addr[31:2]),
        .WE(TC1_WE),
        .Din(TC1_Din),
        .Dout(TC1_Dout),
        .IRQ(TC1_IRQ)
    );
    assign m_data_addr      = bridge_m_data_addr;
    assign m_data_byteen    = bridge_m_data_byteen;

    assign m_int_addr       = (tb_Req && interrupt) ? `DM_ERROR_ADDR   : m_data_addr;
    assign m_int_byteen     = (tb_Req && interrupt) ? `DM_ERROR_BYTEEN : m_data_byteen;

    // assign m_data_addr   = (tb_Req && interrupt) ? `DM_ERROR_ADDR   : bridge_m_data_addr;       // `define DM_ERROR_ADDR   32'h0000_7f20
    // assign m_data_byteen = (tb_Req && interrupt) ? `DM_ERROR_BYTEEN : bridge_m_data_byteen;     // `define DM_ERROR_BYTEEN  4'b1111

    // assign m_int_byteen = m_data_byteen;
    // assign m_int_addr   = macroscopic_pc;
    // 连错线了，晕

endmodule