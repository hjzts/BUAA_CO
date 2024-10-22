`timescale 1ns/1ps
`include "def.v"

module D_CMP(
    input [31:0] i_cmpA,
    input [31:0] i_cmpB,
    input [3 :0] i_branchOp,
    output o_jumpEn_of_B
);      
    wire cmp_signed_less             = $signed(i_cmpA) <  $signed(i_cmpB);
    wire cmp_signed_less_or_equal    = $signed(i_cmpA) <= $signed(i_cmpB);
    wire cmp_signed_greater          = $signed(i_cmpA) >  $signed(i_cmpB);
    wire cmp_signed_greater_or_equal = $signed(i_cmpA) >= $signed(i_cmpB);
    assign o_jumpEn_of_B = (i_branchOp == `CMP_EQUAL                    ) ? (i_cmpA          ==         i_cmpB ) :
                           (i_branchOp == `CMP_NOT_EQUAL                ) ? (i_cmpA          !=         i_cmpB ) :
                           (i_branchOp == `CMP_SIGNED_LESS              ) ? (cmp_signed_less                   ) :
                           (i_branchOp == `CMP_SIGNED_LESS_OR_EQUAL     ) ? (cmp_signed_less_or_equal          ) :
                           (i_branchOp == `CMP_UNSIGNED_LESS            ) ? (i_cmpA          <          i_cmpB ) :
                           (i_branchOp == `CMP_UNSIGNED_LESS_OR_EQUAL   ) ? (i_cmpA          <=         i_cmpB ) :
                           (i_branchOp == `CMP_SIGNED_GREATER           ) ? (cmp_signed_greater                ) :
                           (i_branchOp == `CMP_SIGNED_GREATWER_OR_EQUAL ) ? (cmp_signed_greater_or_equal       ) :
                           (i_branchOp == `CMP_UNSIGNED_GREATER         ) ? (i_cmpA          >          i_cmpB ) :
                           (i_branchOp == `CMP_UNSIGNED_GREATWE_OR_EQUAL) ? (i_cmpA          >=         i_cmpB ) :
                                                                            0;
endmodule