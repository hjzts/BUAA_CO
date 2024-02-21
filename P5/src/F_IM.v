`timescale 1ns/1ps
`include "def.v"
module F_IM(
    input  [31:0] i_pc,
    output [31:0] o_instr
);
    reg [31:0] r_im_rom[`IM_ROM_SIZE - 1: 0];
    integer i;

    initial begin
        for(i  = 0; i < `IM_ROM_SIZE; i = i + 1) begin
            r_im_rom[i]  = 0;
        end
        $readmemh("code.txt",r_im_rom);
    end
    wire [31:0] pc_3000;
    assign pc_3000 = i_pc - `PC_DEFAULT;
    assign o_instr = r_im_rom[pc_3000[13:2]];

endmodule