`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:38:13 10/13/2023 
// Design Name: 
// Module Name:    BlockChecker 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define s0  16'b0000000000000001 //空串或者新读到一个串
`define s1  16'b0000000000000010
`define s2  16'b0000000000000100
`define s3  16'b0000000000001000
`define s4  16'b0000000000010000
`define s5  16'b0000000000100000 //begin
`define s6  16'b0000000001000000 //begin + space
`define s7  16'b0000000010000000
`define s8  16'b0000000100000000
`define s9  16'b0000001000000000  //end
`define s10 16'b0000010000000000 //end + space
`define s11 16'b0000100000000000 // false
`define s12 16'b0001000000000000 // else
`define s13 16'b0010000000000000 // begin + else
`define s14 16'b0100000000000000 // end + else
module BlockChecker(
    input clk,
    input reset,
    input [7:0] in,
    output reg result
    );
    reg [15:0] state;
    reg [15:0] next_state;
    reg last_result;
    reg [15:0] begin_cnt = 0;
    reg overFlag = 1'b0;

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(state, in) begin
        case(state)
            `s0:next_state = (in == "b" || in == "B") ? `s1 : (in == "e" || in == "E") ? `s7 : (in == " ") ? `s0 : `s12;
            `s1:next_state = (in == "e" || in == "E") ? `s2 : (in == " ") ? `s0 : `s12;
            `s2:next_state = (in == "g" || in == "G") ? `s3 : (in == " ") ? `s0 : `s12;
            `s3:next_state = (in == "i" || in == "I") ? `s4 : (in == " ") ? `s0 : `s12;
            `s4:next_state = (in == "n" || in == "N") ? `s5 : (in == " ") ? `s0 : `s12;
            `s5:next_state = (in == " ") ? `s6 :`s13;   
            `s6:next_state = (in == "b" || in == "B") ? `s1 : (in == "e" || in == "E") ? `s7 : (in == " ") ? `s6 : `s12;
            `s7:next_state = (in == "n" || in == "N") ? `s8 : (in == " ") ? `s0 : `s12;
            `s8:next_state = (in == "d" || in == "D") ? `s9 : (in == " ") ? `s0 : `s12;
            `s9:next_state = (in == " ") ? `s10 :`s14;
            `s10:next_state = (in == "b" || in == "B") ? `s1 : (in == "e" || in == "E") ? `s7 : (in == " ") ? `s10 : `s12;
            `s11:next_state = `s11; // seem to be useless
            `s12:next_state = (in == " ") ? `s0 : `s12;
            `s13:next_state = (in == " ") ? `s0 : `s12;
            `s14:next_state = (in == " ") ? `s0 : `s12;
            default: next_state = `s0;
        endcase
    end

    always @(reset,state,in) begin
        if(reset == 1'b1) begin
            state = `s0;
            result = 1'b1;
            begin_cnt = 16'b0;
            overFlag = 1'b0;
            last_result = 1'b1;
        end
        else if(overFlag == 1'b1) begin
            result = 1'b0;
        end
        else begin
            case(state)
                `s5: begin
                    last_result = (next_state == `s13) ? last_result : result;
                    result = 1'b0;
                end
                `s6: begin
                    result = 1'b0;
                    begin_cnt = (in == " ") ? begin_cnt : begin_cnt + 16'b1;
                end
                `s9:begin
                    last_result = (next_state == `s14) ? last_result : result;
                    result = (begin_cnt == 16'b1) ? 1'b1 : 1'b0;
                end
                `s10:begin
                    overFlag = (begin_cnt == 16'b0) ? 1'b1 : 1'b0;
                    begin_cnt = (in == " ") ? begin_cnt : (begin_cnt == 16'b0 || begin_cnt == 16'b1) ? 16'b0 : (begin_cnt - 16'b1); 
                    result = result;
                end
                `s11:begin
                    result = 1'b0;
                end
                `s13:begin
                    result = last_result;
                end
                `s14:begin
                    result = last_result;
                end
                default: result = result;
            endcase
        end
    end


endmodule
