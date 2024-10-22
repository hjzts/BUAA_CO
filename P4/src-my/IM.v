`timescale 1ns / 1ps
`include "def.v"
module IM(
    input [31:0] pc,
    output [31:0] instr
    );
    wire [31:0] pc_3000;
    reg[31:0] imRom [0 : `IM_ROM_SIZE - 1];
    integer i;
    initial begin
        for(i = 0; i < `IM_ROM_SIZE; i = i + 1) imRom[i] = 0;
        $readmemh("code.txt", imRom);
    end
    // assign instr = imRom[pc[13:2]];
    assign pc_3000 = pc - `PC_pcDefault;
    assign instr = imRom[pc_3000[13:2]];
endmodule