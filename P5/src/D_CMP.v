`timescale 1ns/1ps
`include "def.v"

module D_CMP(
    input [31:0] i_cmpA,
    input [31:0] i_cmpB,
    input [3 :0] i_branchOp,
    output o_jumpEn_of_B
);
    wire   signed_cmpA, signed_cmpB;
    assign signed_cmpA = $signed(i_cmpA);
    assign signed_cmpB = $signed(i_cmpB);         
    assign o_jumpEn_of_B = (i_branchOp == `CMP_EQUAL                    ) ? (i_cmpA        == i_cmpB       ) :
                           (i_branchOp == `CMP_NOT_EQUAL                ) ? (i_cmpA        != i_cmpB       ) :
                           (i_branchOp == `CMP_SIGNED_LESS              ) ? (signed_cmpA   <  signed_cmpB  ) :
                           (i_branchOp == `CMP_SIGNED_LESS_OR_EQUAL     ) ? (signed_cmpA   <= signed_cmpB  ) :
                           (i_branchOp == `CMP_UNSIGNED_LESS            ) ? (i_cmpA        <  i_cmpB       ) :
                           (i_branchOp == `CMP_UNSIGNED_LESS_OR_EQUAL   ) ? (i_cmpA        <= i_cmpB       ) :
                           (i_branchOp == `CMP_SIGNED_GREETER           ) ? (signed_cmpA   >  signed_cmpB  ) :
                           (i_branchOp == `CMP_SIGNED_GREETWER_OR_EQUAL ) ? (signed_cmpA   >= signed_cmpB  ) :
                           (i_branchOp == `CMP_UNSIGNED_GREETER         ) ? (i_cmpA        >  i_cmpB       ) :
                           (i_branchOp == `CMP_UNSIGNED_GREETWE_OR_EQUAL) ? (i_cmpA        >= i_cmpB       ) :
                                                                            0;
endmodule