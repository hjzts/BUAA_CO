`timescale 1ns / 1ps
`include"def.v"
module ALU(
    input [31:0]srcA,
    input [31:0]srcB,
    input [4:0]shamt,
    input [3:0]aluOp,
    output reg [31:0]aluResult
    );
    always @(*) begin
        case(aluOp)
            `ALU_add:aluResult = srcA + srcB;
            `ALU_sub:aluResult = srcA - srcB;
            `ALU_mul:aluResult = srcA * srcB;
            `ALU_div:aluResult = srcA / srcB;
            `ALU_and:aluResult = srcA & srcB;   
            `ALU_or:aluResult = srcA | srcB;
            `ALU_xor:aluResult = srcA ^ srcB;
            `ALU_nor:aluResult = ~(srcA | srcB);
            `ALU_sll:aluResult = srcB << shamt;
            `ALU_srl:aluResult = srcB >> shamt;
            `ALU_sra:aluResult = srcB >>> shamt;
            //`ALU_equal:aluResult = (srcA == srcB) ? 1 : 0;
            //`ALU_signed_less:aluResult = ($signed(srcA) < $signed(srcB)) ? 1 : 0;
            //`ALU_unsigned_less:aluResult = (srcA < srcB) ? 1 : 0;
            //`ALU_signed_greater:aluResult = ($signed(srcA) > $signed(srcB)) ? 1 : 0;
            //`ALU_unsigned_greater:aluResult = (srcA > srcB) ? 1 : 0;
            default: aluResult = 0;
        endcase
    end

endmodule
