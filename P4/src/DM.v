`timescale 1ns / 1ps
`include "def.v"
module DM(
    input clk,
    input reset,
    input [31:0] dmMemAddr,
    input [1:0] dmOp,
    input dmWriteEn,
    input [31:0] dmWD,
    output [31:0] dmRD,
	 
	 input [31:0] pc // for display
    );
    reg [31:0] dmRam [0 : `DM_RAM_SIZE - 1 ];
    integer i;
    initial begin
        for(i = 0; i < `DM_RAM_SIZE; i = i + 1)
            dmRam[i] = 0;
    end
    assign dmRD = dmRam[dmMemAddr[13:2]];
    always @(posedge clk) begin
        if(reset) begin
            for(i = 0; i < `DM_RAM_SIZE; i = i + 1)
                dmRam[i] = 0;
        end
        else begin
            if(dmWriteEn) begin
                case(dmOp)
                `DM_WORD : begin
                    dmRam[dmMemAddr[13:2]] <= dmWD;
                    $display("@%h: *%h <= %h", pc, dmMemAddr, dmWD);
                end
                `DM_BYTE : begin
                    dmRam[dmMemAddr[13:2]][dmMemAddr[1:0]*8 +: 8] <= dmWD[7:0];
                    case(dmMemAddr[1:0])
                        2'b00: $display("@%h: *%h <= %h", pc, dmMemAddr, {dmRam[dmMemAddr[13:2]][dmMemAddr[31:8]],dmWD[7:0]});
                        2'b01: $display("@%h: *%h <= %h", pc, dmMemAddr, {dmRam[dmMemAddr[13:2]][dmMemAddr[31:16]],dmWD[7:0],dmRam[dmMemAddr[13:2]][dmMemAddr[7:0]]});
                        2'b10: $display("@%h: *%h <= %h", pc, dmMemAddr, {dmRam[dmMemAddr[13:2]][dmMemAddr[31:24]],dmWD[7:0],dmRam[dmMemAddr[13:2]][dmMemAddr[15:0]]});
                        2'b11: $display("@%h: *%h <= %h", pc, dmMemAddr, {dmWD[7:0],dmRam[dmMemAddr[13:2]][dmMemAddr[23:0]]});
                    endcase
                end
                `DM_HALF_WORD : begin
                    dmRam[dmMemAddr[13:2]][dmMemAddr[1:0]*8 +: 16] <= dmWD[15:0];
                    case(dmMemAddr[1])
                    1'b0: $display("@%h: *%h <= %h", pc, dmMemAddr, {dmRam[dmMemAddr[13:2]][dmMemAddr[31:16]],dmWD[15:0]});
                    1'b1: $display("@%h: *%h <= %h", pc, dmMemAddr, {dmWD[15:0],dmRam[dmMemAddr[13:2]][dmMemAddr[15:0]]});
                    endcase
                end
                endcase
            end
        end
    end
    
endmodule
