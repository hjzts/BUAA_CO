`timescale 1ns/1ps
`include "def.v"
module mips_Bridge(
    input  [31:0] i_m_data_rdata,
    output [31:0] o_m_data_addr,
    output [31:0] o_m_data_wdata,
    output [3 :0] o_m_data_byteen,
    output [31:0] o_m_inst_addr,
    
    output [31:0] o_temp_m_data_rdata,
    input  [31:0] i_temp_m_data_addr,
    input  [31:0] i_temp_m_data_wdata,
    input  [3 :0] i_temp_m_data_byteen,
    input  [31:0] i_temp_m_inst_addr,

    output [31:0] o_TC0_Addr,
    output o_TC0_WE,
    output [31:0] o_TC0_Din,
    input  [31:0] i_TC0_Dout,

    output [31:0] o_TC1_Addr,
    output o_TC1_WE,
    output [31:0] o_TC1_Din,
    input  [31:0] i_TC1_Dout
);
    wire  [1 :0] IO_Sel = ((i_temp_m_data_addr >= `TC0_ADDR_BEGIN) && (i_temp_m_data_addr <= `TC0_ADDR_END)) ? `BRIDGE_IO_SEL_TC0 :
                          ((i_temp_m_data_addr >= `TC1_ADDR_BEGIN) && (i_temp_m_data_addr <= `TC1_ADDR_END)) ? `BRIDGE_IO_SEL_TC1 :
                            `BRIDGE_IO_SEL_DM;
    // load  和 store
    // assign o_temp_m_data_rdata = i_m_data_rdata;
    assign o_m_data_addr       = i_temp_m_data_addr;       
    assign o_m_data_wdata      = i_temp_m_data_wdata;
    // assign o_m_data_byteen     = i_temp_m_data_byteen;
    assign o_m_inst_addr       = i_temp_m_inst_addr;

    assign o_TC0_Addr          = i_temp_m_data_addr;
    assign o_TC0_Din           = i_temp_m_data_wdata;
    assign o_TC1_Addr          = i_temp_m_data_addr;
    assign o_TC1_Din           = i_temp_m_data_wdata;

    wire WE = ( | i_temp_m_data_byteen);
    assign o_TC0_WE = WE && (IO_Sel == `BRIDGE_IO_SEL_TC0);
    assign o_TC1_WE = WE && (IO_Sel == `BRIDGE_IO_SEL_TC1);

    assign o_m_data_byteen     = (IO_Sel == `BRIDGE_IO_SEL_TC0 || IO_Sel == `BRIDGE_IO_SEL_TC1) ? 4'd0 :
                                  i_temp_m_data_byteen;
    assign o_temp_m_data_rdata = (IO_Sel == `BRIDGE_IO_SEL_TC0) ? i_TC0_Dout :
                                 (IO_Sel == `BRIDGE_IO_SEL_TC1) ? i_TC1_Dout :
                                  i_m_data_rdata;  
endmodule