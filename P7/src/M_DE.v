`timescale 1ns/1ps
`include "def.v"

`define word           i_m_data_rdata[31:0]
`define half_word      i_m_data_rdata[(16*i_Addr[1]   + 15) -: 16]
`define byte           i_m_data_rdata[( 8*i_Addr[1:0] + 7 ) -: 8 ]
`define half_word_sign i_m_data_rdata[16*i_Addr[1]   + 15]
`define byte_sign      i_m_data_rdata[ 8*i_Addr[1:0] + 7 ]
module M_DE(
    input      [2 :0] i_deOp,
    input      [31:0] i_Addr,
    input      [31:0] i_m_data_rdata,
    output reg [31:0] or_RD,

    input      i_exc_DMOv,
    input      i_load,
    output     o_exc_AdEL
);
    wire exception_align      =  ((i_deOp == `DE_LW) && (|i_Addr[1:0])) || 
                                 ((i_deOp == `DE_LH || i_deOp == `DE_LHU) && (i_Addr[0]));
    wire exception_out_range  = !(((i_Addr >= `DM_ADDR_BEGIN ) && (i_Addr <= `DM_ADDR_END )) ||
                                  ((i_Addr >= `TC0_ADDR_BEGIN) && (i_Addr <= `TC0_ADDR_END)) ||
                                  ((i_Addr >= `TC1_ADDR_BEGIN) && (i_Addr <= `TC1_ADDR_END)));
    wire exception_timer_load =    (i_deOp != `DE_LW) && (i_Addr >= `TC0_ADDR_BEGIN);

    assign o_exc_AdEL = (i_load) && (exception_align || exception_out_range || exception_timer_load || i_exc_DMOv);

    always @(*)begin
        case(i_deOp)
            `DE_LW : or_RD = i_m_data_rdata;
            `DE_LH : or_RD = {{16{`half_word_sign}}, `half_word};
            `DE_LHU: or_RD = {16'b0, `half_word};
            `DE_LB : or_RD = {{24{`byte_sign}}, `byte};
            `DE_LBU: or_RD = {24'b0, `byte};
            default: or_RD = 32'h0;
        endcase
    end
endmodule