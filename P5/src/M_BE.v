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
    output reg [31:0] or_m_data_wdata    
);
    always @(*)begin
        case(i_beOp)
            `BE_SW: begin
                or_m_data_wdata = i_writeData;
            end
            `BE_SH:begin
                case(i_Addr[1])
                    1'b0: or_m_data_wdata = {16'b0, `half_word};
                    1'b1: or_m_data_wdata = {`half_word, 16'b0};
                    default: or_m_data_wdata = 32'h0;
                endcase
            end
            `BE_SB:begin
                case(i_Addr[1:0])
                    2'b00: or_m_data_wdata = {24'b0, `byte};
                    2'b01: or_m_data_wdata = {16'b0, `byte,  8'b0};
                    2'b10: or_m_data_wdata = {8'b0 , `byte, 16'b0};
                    2'b11: or_m_data_wdata = {`byte, 24'b0};
                    default: or_m_data_wdata = 32'h0;
                endcase
            end
            default:
                or_m_data_wdata = 32'h0;
        endcase
    end

    always @(*)begin
        case(i_beOp)
            `BE_SW:begin
                or_m_data_byteen = 4'b1111;
            end
            `BE_SH:begin
                case(i_Addr[1])
                    1'b0: or_m_data_byteen = 4'b0011;
                    1'b1: or_m_data_byteen = 4'b1100;
                    default: or_m_data_byteen = 4'b0000;
                endcase
            end
            `BE_SB:begin
                case(i_Addr[1:0])
                    2'b00: or_m_data_byteen = 4'b0001;
                    2'b01: or_m_data_byteen = 4'b0010;
                    2'b10: or_m_data_byteen = 4'b0100;
                    2'b11: or_m_data_byteen = 4'b1000;
                    default: or_m_data_byteen = 4'b0000;
                endcase
            end
            default:
                or_m_data_byteen = 4'b0000;
        endcase
    end
endmodule