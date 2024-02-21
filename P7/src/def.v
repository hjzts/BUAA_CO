`define NPC_INT      32'h0000_4180
//************* Bridge ***********//
`define BRIDGE_IO_SEL_DM          2'b00
`define BRIDGE_IO_SEL_TC0         2'b01
`define BRIDGE_IO_SEL_TC1         2'b10
`define DM_ERROR_ADDR            32'h0000_7f20
`define DM_ERROR_BYTEEN           4'b1111
//***********Addr Range***********//
`define DM_ADDR_BEGIN            32'h0000_0000
`define DM_ADDR_END              32'h0000_2fff
`define TC0_ADDR_BEGIN           32'h0000_7f00
`define TC0_ADDR_END             32'h0000_7f0b
`define TC1_ADDR_BEGIN           32'h0000_7f10
`define TC1_ADDR_END             32'h0000_7f1b
`define TC0_COUNT_BEGIN          32'h0000_7f08
`define TC0_COUNT_END            32'h0000_7f0b
`define TC1_COUNT_BEGIN          32'h0000_7f18
`define TC1_COUNT_END            32'h0000_7f1b
//***********EXC CODE***********// Excption Code
`define EXC_INT                   5'd0      // 外部中断信号
`define EXC_ADEL                  5'd4      // 取数异常
`define EXC_ADES                  5'd5      // 存数异常
`define EXC_SYSCALL               5'd8      // 系统调用
`define EXC_RI                    5'd10     // 未知指令
`define EXC_OV                    5'd12     // 算术溢出
`define EXC_NONE                  5'd0      

`define EXC_CODE_DEFAULT          5'd0
`define BRANCH_DELAY_DEFAULT      1'b0
`define EXC_DMOV_DEFAULT          1'b0
//***********CP0***********//
`define SR_DEFAULT              32'h0000_0000
`define Cause_DEFAULT           32'h0000_0000
`define EPC_DEFAULT             32'h0000_0000
`define Prid_DEFUALT            32'h2004_1023
`define CP0_OUT_DEFAULT         32'h0000_0000
//***********C U***********//
`define CU_EXT_SIGNED            2'b00
`define CU_EXT_UNSIGNED          2'b01
`define CU_EXT_LUI               2'b10
 
`define CU_ALU_SRCA_RS           3'b000
`define CU_ALU_SRCA_RT           3'b001
 
`define CU_ALU_SRCB_RT           3'b000
`define CU_ALU_SRCB_IMM32        3'b001

`define CU_ALU_SHAMT_SEL_DEFAULT 3'b000
`define CU_ALU_SHAMT_SEL_SA      3'b001
//***********H U***********// 
//***********B E***********// 
`define BE_SW                    3'b000
`define BE_SH                    3'b001
`define BE_SB                    3'b010
`define BE_NONE                  3'b011
//***********D E***********// 
`define DE_LW                    3'b000
`define DE_LH                    3'b001
`define DE_LHU                   3'b010
`define DE_LB                    3'b011
`define DE_LBU                   3'b100
`define DE_NONE                  3'b101
//***********P C***********// 
`define PC_DEFAULT    32'h0000_3000
`define PC_BEGIN_MIN  32'h0000_3000
`define PC_END_MAX    32'h0000_6ffc
`define INSTR_DEFAULT 32'h0000_0000
//***********NPC***********//
`define NPC_PC4       3'b000
`define NPC_BRANCH    3'b001
`define NPC_J         3'b010
`define NPC_JR        3'b011

//***********I M***********//
`define IM_ROM_SIZE 4096
//***********EXT***********//
`define EXT_SIGNED    2'b00
`define EXT_UNSIGNED  2'b01
`define EXT_LUI       2'b10
// 留了两个后门,一些奇奇怪怪的拓展
//***********CMP***********//
`define CMP_EQUAL                     4'b0000
`define CMP_NOT_EQUAL                 4'b0001
`define CMP_SIGNED_LESS               4'b0010
`define CMP_SIGNED_LESS_OR_EQUAL      4'b0011
`define CMP_UNSIGNED_LESS             4'b0100
`define CMP_UNSIGNED_LESS_OR_EQUAL    4'b0101
`define CMP_SIGNED_GREATER            4'b0110
`define CMP_SIGNED_GREATWER_OR_EQUAL  4'b0111
`define CMP_UNSIGNED_GREATER          4'b1000
`define CMP_UNSIGNED_GREATWE_OR_EQUAL 4'b1001
//***********DE_REG***********//
`define GRF_RD_DEFAULT          32'h0000_0000
`define EXT_IMM32_DEFAULT       32'h0000_0000
`define GRF_WRITE_ADDR_DEFAULT   5'b00000
`define SA_DEFALUT               5'b00000

`define GRF_WD_PC4          3'b000
`define GRF_WD_PC8          3'b001
`define GRF_WD_ALU_RESULT   3'b010
`define GRF_WD_MEM_RD       3'b011
`define GRF_WD_EXT          3'b100
`define GRF_WD_MDU_RESULT   3'b101
`define GRF_WD_CP0OUT       3'b110
//***********ALU***********//
`define ALU_add       5'b00000
`define ALU_sub       5'b00001
`define ALU_mul       5'b00010
`define ALU_div       5'b00011
`define ALU_and       5'b00100
`define ALU_or        5'b00101
`define ALU_xor       5'b00110
`define ALU_nor       5'b00111
`define ALU_sll       5'b01000
`define ALU_srl       5'b01001
`define ALU_sra       5'b01010

`define ALU_slt       5'b01011
`define ALU_sltu      5'b01100

`define ALU_DEFAULT       32'h0000_0000
`define ALU_SHAMT_DEFAULT  5'b0
//***********  MDU ***********//
`define MDU_HI_DEFAULT  32'h0000_0000
`define MDU_LO_DEDAULT  32'h0000_0000
`define MDU_CACL_CYCLE  32'h0000_0000
`define MDU_BUSY_DEFAULT 1'b0
`define MDU_RES_DEFAULT 32'h0000_0000

`define MDU_DEFAULT      5'b00000
`define MDU_MULT         5'b00001
`define MDU_MULTU        5'b00010
`define MDU_DIV          5'b00011
`define MDU_DIVU         5'b00100
`define MDU_MTLO         5'b00101
`define MDU_MTHI         5'b00110
`define MDU_MFLO         5'b00111
`define MDU_MFHI         5'b01000
//***********EM_REG***********//
`define MEM_WRITE_DATA_DEFAULT 32'h0000_0000
`define ALU_RESULT_DEFAULT     32'h0000_0000
`define MDU_RESULT_DEFAULT     32'h0000_0000
`define EXT_IMM32              32'h0000_0000
//***********DM***********//
`define DM_RAM_SIZE     3072
`define DM_OP_WORD      3'b000
`define DM_OP_HALF_WORD 3'b001
`define DM_OP_BYTE      3'b010
//***********MW_REG***********//
`define DM_RD_DEFAULT 32'h0000_0000
//---------------- ------- Definition of Instrution opcode and function --------------------------------------
//*********** Ctrl  Unit ***********//
// R-TYPE 
`define OP_RTYPE   6'b000000
//算术运算 add sub  addu subu ......
`define FUN_ADD    6'b100000
`define FUN_SUB    6'b100010
`define FUN_ADDU   6'b100001
`define FUN_SUBU   6'b100011
// 逻辑运算 and or  xor nor .......
`define FUN_AND    6'b100100
`define FUN_OR     6'b100101
`define FUN_XOR    6'b100110
`define FUN_NOR    6'b100111
// slt  
`define FUN_SLT    6'b101010
`define FUN_SLTU   6'b101011
// 移位运算 sll srl sra sllv srlv srav......
// shift-s 
`define FUN_SLL    6'b000000
`define FUN_SRL    6'b000010
`define FUN_SRA    6'b000011
// shift-v  
`define FUN_SLLV   6'b000100
`define FUN_SRLV   6'b000110
`define FUN_SRAV   6'b000111
// I-TYPE 
// 算术运算 ori lui addi addiu andi xori......
`define OP_LUI     6'b001111
`define OP_ORI     6'b001101
`define OP_ADDI    6'b001000
`define OP_ADDIU   6'b001001
`define OP_ANDI    6'b001100
`define OP_XORI    6'b001110
    // slt set less then slti sltiu......
`define OP_SLTI    6'b001010
`define OP_SLTIU   6'b001011
// **************  Branch and Jump ****************
`define OP_J       6'b000010
`define OP_JAL     6'b000011
 
`define OP_JR      6'b000000
`define FUN_JR     6'b001000
 
`define OP_JALR    6'b000000
`define FUN_JALR   6'b001001
 
`define OP_BEQ     6'b000100
`define OP_BNE     6'b000101
`define OP_BNEL    6'b010101
`define OP_BLEZ    6'b000110
`define OP_BGTZ    6'b000111
`define OP_BGRTZL  6'b010111
`define OP_BLEZL   6'b010110
 
`define OP_BLTZ    6'b000001
`define RT_BLTZ    5'b00000 
`define OP_BLTZL   6'b000001
`define RT_BLTZL   5'b10010
`define OP_BLTZAL  6'b000001
`define RT_BLTZAL  5'b10000
 
`define OP_BGEZ    6'b000001
`define RT_BGEZ    5'b00001
`define OP_BGRZL   6'b000001
`define RT_BGEZL   5'b10011
`define OP_BGEZAL  6'b000001
`define RT_BGEZAL  5'b10001 
// **************  Memory ****************
`define OP_LB      6'b100000
`define OP_LBU     6'b100100
`define OP_LH      6'b100001
`define OP_LHU     6'b100101
`define OP_LW      6'b100011
`define OP_SB      6'b101000
`define OP_SH      6'b101001
`define OP_SW      6'b101011
// **************  md/mt/mf ****************
`define FUN_MULT   6'b011000
`define FUN_MULTU  6'b011001
`define FUN_DIV    6'b011010
`define FUN_DIVU   6'b011011
 
`define FUN_MTLO   6'b010011
`define FUN_MTHI   6'b010001
 
`define FUN_MFHI   6'b010000
`define FUN_MFLO   6'b010010
// **************    CP0   ****************
`define OP_MFC0    6'b010000
`define RS_MFC0    5'b00000
`define OP_MTC0    6'b010000
`define RS_MTC0    5'b00100

`define INSTR_ERET 32'b010000_1000_0000_0000_0000_0000_011000
`define FUN_SYSCALL 6'b001100

`define OP_NOP     6'b000000
`define FUN_NOP    6'b000000



