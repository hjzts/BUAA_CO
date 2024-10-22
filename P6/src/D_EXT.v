`timescale 1ns/1ps
`include "def.v"
module D_EXT(
    input  [15:0] i_imm16,
    input  [1 :0] i_ext_Sel,
    output [31:0] o_ext_result
);
    assign o_ext_result = (i_ext_Sel == `EXT_SIGNED  ) ? {{16{i_imm16[15]}}, i_imm16} :
                          (i_ext_Sel == `EXT_LUI     ) ? {i_imm16          , 16'b0  } :
                          (i_ext_Sel == `EXT_UNSIGNED) ? {16'b0            , i_imm16} :
                                                         {16'b0            , i_imm16} ;
endmodule