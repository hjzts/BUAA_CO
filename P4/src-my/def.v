`timescale 1ns / 1ps
// ALU
`define ALU_add 4'b0000
`define ALU_sub 4'b0001
`define ALU_mul 4'b0010
`define ALU_div 4'b0011
`define ALU_and 4'b0100
`define ALU_or 4'b0101
`define ALU_xor 4'b0110
`define ALU_nor 4'b0111
`define ALU_sll 4'b1000
`define ALU_srl 4'b1001
`define ALU_sra 4'b1010
`define ALU_equal 4'b1011
`define ALU_signed_less 4'b1100
`define ALU_unsigned_less 4'b1101
`define ALU_signed_greater 4'b1110
`define ALU_unsigned_greater 4'b1111
//PC
`define PC_pcDefault 32'h0000_3000
//NPC
`define NPC_PC_4 2'b00
`define NPC_J 2'b01
`define NPC_B 2'b10
`define NPC_JR 2'b11
//CU
`define CU_GRF_A3_RT 2'b00
`define CU_GRF_A3_RD 2'b01
`define CU_GRF_A3_RA 2'b10
`define CU_GRF_WD_ALURESULT 2'b00
`define CU_GRF_WD_MEMRD 2'b01
`define CU_GRF_WD_PC_4 2'b10
`define CU_ALU_SRCB_GRFRD2 1'b0
`define CU_ALU_SRCB_IMM32 1'b1
`define CU_ALU_SHAMT_SEL_16 1'b0
`define CU_ALU_SHAMT_SEL_sa 1'b1
//IM
`define IM_ROM_SIZE 4096
//DM
`define DM_RAM_SIZE 3072
`define DM_WORD 2'b00
`define DM_HALF_WORD 2'b01
`define DM_BYTE 2'b10
//CMP
`define CMP_EQUAL 3'b000
`define CMP_NOT_EQUAL 3'b001
`define CMP_SIGNED_LESS 3'b010
`define CMP_SIGNED_LESS_OR_EQUAL 3'b011
`define CMP_UNSIGNED_LESS 3'b100
`define CMP_SIGNED_GREATER 3'b101
`define CMP_UNSIGNED_GREATER 3'b110
`define CMP_SIGNED_GREATER_OR_EQUAL 3'b111

