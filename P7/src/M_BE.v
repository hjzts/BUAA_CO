`timescale 1ns/1ps
`include "def.v"
`define word      i_writeData[31:0]
`define half_word i_writeData[15:0]
`define byte      i_writeData[7 :0]

module M_BE(
    input      i_writeEn,
    input      [2 :0] i_beOp,
    input      [31:0] i_Addr,
    input      [31:0] i_writeData,
    output reg [3 :0] or_m_data_byteen,
    output reg [31:0] or_m_data_wdata,

    input      i_store,
    input      i_exc_DMOv,
    output     o_exc_AdES
);
// `define DM_ADDR_BEGIN            32'h0000_0000
// `define DM_ADDR_END              32'h0000_2fff

// `define TC0_ADDR_BEGIN           32'h0000_7f00
// `define TC0_ADDR_END             32'h0000_7f0b

// `define TC1_ADDR_BEGIN           32'h0000_7f10
// `define TC1_ADDR_END             32'h0000_7f1b

// `define TC0_COUNT_BEGIN          32'h0000_7f08
// `define TC0_COUNT_END            32'h0000_7f0b

// `define TC1_COUNT_BEGIN          32'h0000_7f18
// `define TC1_COUNT_END            32'h0000_7f1b
    wire exception_align        =   ((i_beOp == `BE_SW) && (|i_Addr[1:0])) ||
                                    ((i_beOp == `BE_SH) && ( i_Addr[0]  ));
    wire exception_out_range    = !(((i_Addr >= `DM_ADDR_BEGIN  ) && (i_Addr <= `DM_ADDR_END  )) ||
                                    ((i_Addr >= `TC0_ADDR_BEGIN ) && (i_Addr <= `TC0_ADDR_END )) ||
                                    ((i_Addr >= `TC1_ADDR_BEGIN ) && (i_Addr <= `TC1_ADDR_END )));
    // 向计时器的Count寄存器存值
    wire exception_timer_count  =    
                                     (i_Addr >= `TC0_COUNT_BEGIN  &&  i_Addr <= `TC0_COUNT_END)  ||
                                     (i_Addr >= `TC1_COUNT_BEGIN  &&  i_Addr <= `TC1_COUNT_END)  ;
    // sh sb存timer寄存器的值
    wire exception_timer_store  =   ((i_beOp != `BE_SW) && ((i_Addr >= `TC0_ADDR_BEGIN) && (i_Addr <= `TC1_ADDR_END)));  
    assign o_exc_AdES           =   ((i_store) && (exception_align || exception_out_range || exception_timer_count || exception_timer_store || i_exc_DMOv));

    always @(*)begin
        case(i_beOp)
            `BE_SW: begin
                or_m_data_wdata = i_writeData;
            end
            `BE_SH:begin
                case(i_Addr[1])
                    1'b0:    or_m_data_wdata = {16'b0, `half_word};
                    1'b1:    or_m_data_wdata = {`half_word, 16'b0};
                    default: or_m_data_wdata = 32'h0;
                endcase
            end
            `BE_SB:begin
                case(i_Addr[1:0])
                    2'b00:   or_m_data_wdata = {24'b0, `byte};
                    2'b01:   or_m_data_wdata = {16'b0, `byte,  8'b0};
                    2'b10:   or_m_data_wdata = {8'b0 , `byte, 16'b0};
                    2'b11:   or_m_data_wdata = {`byte, 24'b0};
                    default: or_m_data_wdata = 32'h0;
                endcase
            end
            default:
                or_m_data_wdata = 32'h0;
        endcase
    end

    always @(*)begin
        if(i_writeEn)begin
            case(i_beOp)
                `BE_SW:begin
                    or_m_data_byteen = 4'b1111;
                end
                `BE_SH:begin
                    case(i_Addr[1])
                        1'b0:    or_m_data_byteen = 4'b0011;
                        1'b1:    or_m_data_byteen = 4'b1100;
                        default: or_m_data_byteen = 4'b0000;
                    endcase
                end
                `BE_SB:begin
                    case(i_Addr[1:0])
                        2'b00:   or_m_data_byteen = 4'b0001;
                        2'b01:   or_m_data_byteen = 4'b0010;
                        2'b10:   or_m_data_byteen = 4'b0100;
                        2'b11:   or_m_data_byteen = 4'b1000;
                        default: or_m_data_byteen = 4'b0000;
                    endcase
                end
                default:
                    or_m_data_byteen = 4'b0000;
            endcase
        end else begin
            or_m_data_byteen = 4'b0000;
        end
    end
endmodule