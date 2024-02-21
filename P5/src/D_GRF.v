`timescale 1ns/1ps
`include "def.v"
module D_GRF(
    input i_clk,
    input i_reset,
    input  [4 :0] i_A1,
    input  [4 :0] i_A2,
    input  [4 :0] i_A3,
    input  [31:0] i_WD,
    input  i_writeEn,
    output [31:0] o_RD1,
    output [31:0] o_RD2,

    input  [31:0] i_pc,  // for display
    input  [31:0] i_instr
    );
    reg [31:0] r_rf [31:0];
    
    integer i;
    initial begin
        for(i = 0; i < 32; i = i + 1) begin
            r_rf[i] = 0;
        end
    end
// 内部转发
    wire [31:0] D_FWD_RD1, D_FWD_RD2;
    assign D_FWD_RD1 = ( i_A1 == 5'h0 ) ? 32'h0:
                       ((i_A1 == i_A3)) ? i_WD :
                                          r_rf[i_A1]; 
    assign D_FWD_RD2 = ( i_A2 == 5'h0 ) ? 32'h0:
                       ((i_A2 == i_A3)) ? i_WD :
                                          r_rf[i_A2];
    assign o_RD1 = D_FWD_RD1;
    assign o_RD2 = D_FWD_RD2;

    always @(posedge i_clk) begin
        if(i_reset) begin
            for(i = 0; i < 32; i = i + 1)begin
                r_rf[i] <= 0;
            end
        end
        else begin
            if(i_writeEn) begin
                r_rf[i_A3] <= ((i_A3 == 5'b0) ? 0 : i_WD);
                // if(i_A3 != 0) $display("%d@%h: $%d <= %h",$time, i_pc, i_A3, i_WD);
            end
        end
    end
endmodule