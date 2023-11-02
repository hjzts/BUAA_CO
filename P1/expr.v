`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:23:36 10/12/2023 
// Design Name: 
// Module Name:    expr 
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
`define s0 3'b000
`define s1 3'b001
`define s2 3'b010
`define s3 3'b011
`define s4 3'b100
`define s5 3'b101
`define s6 3'b110
`define s7 3'b111
module expr(
    input clk,
    input clr,
    input [7:0] in,
    output reg out
    );
    reg [2:0] state;
    wire isNumber;
    assign isNumber = (in >= "0" && in <= "9") ? 1'b1 : 1'b0;
    wire isOperator;
    assign isOperator = (in == "+" || in == "*") ? 1'b1 : 1'b0;

    always @(*) begin
        if(clr == 1'b1) begin
            state = `s0;
            out = 1'b0;
        end
    end

    always @(posedge clk)begin
        if(clr == 1'b1) begin
            state <= `s0;
            out <= 1'b0;
        end
        else begin
            case(state)
            `s0: //nothing
                begin
                    if(isNumber == 1'b1) begin
                        state <= `s1;
                        out <= 1'b1;
                    end
                    else if(isOperator == 1'b1) begin
                        state <= `s2;
                        out <= 1'b0;
                    end
                    else begin
                        state <= `s7;
                        out <= 1'b0;
                    end
                end
            `s1: // a number
                begin
                    if(isNumber == 1'b1) begin
                        state <= `s3;
                        out <= 1'b0;
                    end
                    else if(isOperator == 1'b1) begin
                        state <= `s4;
                        out <= 1'b0;
                    end
                    else begin
                        state <= `s7;
                        out <= 1'b0;
                    end
                end
            `s2: // a operator
                begin
                    out <= 1'b0;
                    state <= `s2; // over
                end
            `s3:// OK with a number
                begin
                    out <= 1'b0;
                    state <= `s3; //over
                end
            `s4:// OK with a Operator
                begin
                    if(isNumber == 1'b1) begin
                        state <= `s5;
                        out <= 1'b1;
                    end
                    else if(isOperator == 1'b1) begin
                        state <= `s6;
                        out <= 1'b0;
                    end
                    else begin
                        state <= `s7;
                        out <= 1'b0;
                    end
                end
            `s5:// OK
                begin
                    if(isNumber == 1'b1) begin
                        state <= `s3;
                        out <= 1'b0;
                    end
                    else if(isOperator == 1'b1) begin
                        state <= `s4;
                        out <= 1'b0;
                    end
                    else begin
                        state <= `s7;
                        out <= 1'b0;
                    end
                end
            `s6:// OK with a Operator with a Operator
                begin
                    out <= 1'b0;
                    state <= `s6;
                end
            `s7:// false
                begin
                    out <= 1'b0;
                    state <= `s7;
                end
            default :
                begin
                    state <= `s7;
                    out <= 1'b0;
                end
        endcase
        end
    end

endmodule
