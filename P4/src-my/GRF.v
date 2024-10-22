`timescale 1ns / 1ps
module GRF(
    input clk,
    input reset,
    input [4:0] grfA1,
    input [4:0] grfA2,
    input [4:0] grfA3,
    input [31:0] grfWD,
    input grfWriteEn,
    output [31:0] grfRD1,
    output [31:0] grfRD2,

    input [31:0] pc, // for display
    input [31:0] instr // for display
    );
    reg [31:0] rf[31:0]; // register files
    integer i;
    initial begin
        for(i = 0; i < 32; i = i + 1) rf[i] = 0;
    end
    assign grfRD1 = rf[grfA1];
    assign grfRD2 = rf[grfA2];
    always @(posedge clk) begin
        if(reset) begin
            for(i = 0; i < 32; i = i + 1) rf[i] = 0;
        end
        else begin
            if(grfWriteEn) begin
               rf[grfA3] <= (grfA3 == 0) ? 0 : grfWD;
               if(grfA3 != 0) $display("@%h: $%d <= %h", pc, grfA3, grfWD);
            end
        end
    end
endmodule
