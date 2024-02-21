`timescale 1ns/1ps
`include "def.v"
module E_MDU(
    input i_clk,
    input i_reset,
    input i_Req,
    
    input [31:0] i_srcA,
    input [31:0] i_srcB,
    input [4 :0] i_mduOp,
    input i_start,

    output reg [31:0] or_hi,
    output reg [31:0] or_lo,
    output     [31:0] or_result,
    output reg or_busy
);
    reg [31:0] mdu_calc_cycle, temp_hi, temp_lo;
    initial begin
        or_busy        = `MDU_BUSY_DEFAULT; 
        mdu_calc_cycle = `MDU_CACL_CYCLE;
        or_hi          = `MDU_HI_DEFAULT;
        or_lo          = `MDU_LO_DEDAULT;
        temp_hi        = `MDU_HI_DEFAULT;
        temp_lo        = `MDU_LO_DEDAULT;
    end
    assign or_result = (i_mduOp == `MDU_MFHI) ? or_hi :
                       (i_mduOp == `MDU_MFLO) ? or_lo :
                        `MDU_RES_DEFAULT;

    always @(posedge i_clk) begin
        if     (i_mduOp == `MDU_MTHI && !i_Req) or_hi <= i_srcA;
        else if(i_mduOp == `MDU_MTLO && !i_Req) or_lo <= i_srcA;
    end

    always @(posedge i_clk)begin
        if(i_reset) begin
            or_busy        = `MDU_BUSY_DEFAULT; 
            mdu_calc_cycle = `MDU_CACL_CYCLE;
            or_hi          = `MDU_HI_DEFAULT;
            or_lo          = `MDU_LO_DEDAULT;
            temp_hi        = `MDU_HI_DEFAULT;
            temp_lo        = `MDU_LO_DEDAULT;
        end else if(!i_Req) begin
            if(mdu_calc_cycle == 0)begin
                if(i_start) begin
                    or_busy <= 1;

                    // mdu_calc_cycle表示目前的计算周期数
                    if     (i_mduOp == `MDU_MULT || i_mduOp == `MDU_MULTU) mdu_calc_cycle <= 5;
                    else if(i_mduOp == `MDU_DIV  || i_mduOp == `MDU_DIVU ) mdu_calc_cycle <= 10;
                    
                    // 计算hi，lo的值
                    if     (i_mduOp == `MDU_MULT ) begin
                        {temp_hi, temp_lo} <= $signed(i_srcA) * $signed(i_srcB);
                    end
                    else if(i_mduOp == `MDU_MULTU) begin
                        {temp_hi, temp_lo} <= i_srcA * i_srcB;
                    end
                    else if(i_mduOp == `MDU_DIV  ) begin
                        temp_lo <= $signed(i_srcA) / $signed(i_srcB);
                        temp_hi <= $signed(i_srcA) % $signed(i_srcB);
                    end
                    else if(i_mduOp == `MDU_DIVU )begin
                        temp_lo <= i_srcA / i_srcB;
                        temp_hi <= i_srcA % i_srcB;
                    end
                end else begin
                    mdu_calc_cycle <= 0; // 没有start，运算周期为0    
                end
            end else begin
                if(mdu_calc_cycle == 1)begin
                    or_hi          <= temp_hi;
                    or_lo          <= temp_lo;
                    or_busy        <= 1'b0;
                    mdu_calc_cycle <= 1'b0;
                end else 
                    mdu_calc_cycle <= mdu_calc_cycle - 1;
            end
        end


    end
endmodule