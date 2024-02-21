`timescale 1ns/1ps
`include "def.v"

`define IM       SR[15:10]    //  Interrupt Mask分别对应六个外部中断，只能通过mtc0这个指令进行修改
                              // 相应位置置 1 表示允许中断，置 0 表示禁止中断
`define EXL      SR[1]        // Exception Level
                              // 任何异常发生时置 1 ,强制进入核心态,并禁止中断
`define IE       SR[0]        // Interrupt Enable 全局中断使能
                              // 为 1 表示允许中断，为 0 表示禁止中断
`define BD       Cause[31]    // Branch Delay
                              // 当置 1 时EPC指向分支指令，为 0 时指向当前指令
`define IP       Cause[15:10] // Interrupt Priority, 为6位待决的中断位, 分别对应 6 个外部中断
                              // 相应位置为 1 表示有中断，置 0 表示无中断
`define ExcCode  Cause[6 : 2] // Exception code 异常编码
// 判断接收到的中断和异常是否允许其发生

module mips_CP0(
    input  i_clk,
    input  i_reset,
    input  i_en,                    // CP0 寄存器写使能 执行mtc0时产生
    input  [4 :0] i_CP0Addr,        // 读写 CP0 寄存器编号，执行mfc0,mtc0产生的CP0地址信号
    input  [31:0] i_CP0In,          // CP0写入数据, 执行 mtc0 指令时发生
    input  [31:0] i_VPC,            // Victim PC 受害PC，中断/异常时的 PC
    input  i_BDIn,                  // Branch delayed Input 是否是延时槽指令
    input  [4 :0] i_ExcCodeIn,      // 记录中断/异常类型
    input  [5 :0] i_HWInt,          // Handware interrupt
    input  i_EXLClr,                // Exception clear,用来复位exl
    output [31:0] o_EPCOut,         // EPC的值, 将EPC寄存器的值输出至 NPC
    output [31:0] o_CP0Out,         // CP0读出数据, 执行 mfc0 指令时发生
    output o_Req,                   // Require 进入处理程序请求， 中断请求，由 CP0 模块确认响应是否发生
    output o_tb_Req                 // 有外部中断请求产生
);
    reg [31:0] SR;      // State Register
    reg [31:0] Cause;   
    reg [31:0] EPC;     // EPC寄存器负责保存中断/异常时的PC值
    reg [31:0] Prid;    // Processer ID 通常存入处理器ID，可以实现个性的编码

    // for test
    assign o_tb_Req       = (!`EXL) && (`IE) &&  (i_HWInt[2] & SR[12]); 
    wire ExceptionRequest = (!`EXL) && (| i_ExcCodeIn);                 // 允许当前中断 且 不在中断异常中 且 允许中断发生
    wire InterruptRequest = (!`EXL) && (`IE) && (|(i_HWInt & `IM));     // 存在异常 且 不在中断中
    // assign o_tb_Req = InterruptRequest;
    assign o_Req    = (ExceptionRequest) | (InterruptRequest);


    initial begin
        SR    <= `SR_DEFAULT;
        Cause <= `Cause_DEFAULT;
        EPC   <= `EPC_DEFAULT;
        Prid  <= `Prid_DEFUALT;     // 32'h2004_1023
    end
    // 如果发生了中断就要更新EPC，否则保持原值
    wire [31:0] temp_EPC = (o_Req) ? (i_BDIn ? (i_VPC - 32'd4) : i_VPC):
                           (EPC  ) ;

    always @(posedge i_clk or posedge i_reset)begin
        if(i_reset)begin
            SR    <= `SR_DEFAULT;
            Cause <= `Cause_DEFAULT;
            EPC   <= `EPC_DEFAULT;
            Prid  <= `Prid_DEFUALT;
        end else begin
            if(i_EXLClr) `EXL <= 1'b0;
            if(o_Req) begin
                `ExcCode <= (InterruptRequest ? 5'd0 : i_ExcCodeIn);
                `EXL     <= 1'b1;
                 EPC     <= temp_EPC;
                `BD      <= i_BDIn;
            end else if(i_en)begin
                if     (i_CP0Addr == 5'd12) SR    <= i_CP0In;
                // read only
                else if(i_CP0Addr == 5'd13) Cause <= i_CP0In;
                else if(i_CP0Addr == 5'd14) EPC   <= i_CP0In;
                // else if(I_CP0Addr == 5'd15) Prid  <= i_CP0In;
            end
            `IP <= i_HWInt;
        end
    end


    assign o_EPCOut = temp_EPC;

    assign o_CP0Out = (i_CP0Addr == 5'd12) ? SR      :
                      (i_CP0Addr == 5'd13) ? Cause   :
                      (i_CP0Addr == 5'd14) ? temp_EPC:
                      (i_CP0Addr == 5'd15) ? Prid    :
                      `CP0_OUT_DEFAULT;             
endmodule