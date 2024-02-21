`timescale 1ns/1ps
`include "def.v"
module M_DM(
    input  i_clk,
    input  i_reset,
    input  [31:0] i_Addr,
    input  [31:0] i_writeData,
    input  i_writeEn,
    input  [2 :0] i_dmOp,
    output [31:0] o_RD,

    input  [31:0] i_pc,   // for display
    input  [31:0] i_instr 
);
    reg [31:0] dm_ram[`DM_RAM_SIZE - 1: 0];
    integer i;
    initial begin
        for(i = 0; i < `DM_RAM_SIZE; i = i + 1) begin
            dm_ram[i] = 0;
        end
    end
    assign o_RD = dm_ram[i_Addr[13:2]];
    always @(posedge i_clk)begin
        if(i_reset) begin
            for(i = 0; i < `DM_RAM_SIZE; i = i + 1)begin
                dm_ram[i] <= 0;
            end
        end
        else begin
            if(i_writeEn) begin
                case(i_dmOp)
                `DM_OP_WORD     :begin
                    dm_ram[i_Addr[13:2]] <= i_writeData;
                    $display("%d@%h: *%h <= %h",$time, i_pc, i_Addr, i_writeData);
                end
                `DM_OP_HALF_WORD:begin
                end
                `DM_OP_BYTE     :begin
                end
                default : dm_ram[i_Addr[13:2]] <= i_writeData;
                endcase
            end
        end
    end

endmodule