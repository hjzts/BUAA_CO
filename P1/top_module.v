// Note the Verilog-1995 module declaration syntax here:
module top_module(
    input [7:0] in,
    input clk,
    input reset,
    output result
);
    wire isAlpha;
    wire isNum;
    wire isAlphaNum;
    wire isOp;
    wire isSpace;
    wire isEq;

    assign isAlpha = (in >= "a" && in <= "z" ) || (in >= "A" && in <= "Z");
    assign isNum = in >= "0" && in <= "9";
    assign isAlphaNum = isAlpha || isNum;
    assign isOp = (in == "+") || (in == "-") || (in == "*") || (in == "/");
    assign isSpace = in == " ";
    assign isEq = in == "=";

    reg [32-1:0] exp_cnt;


    integer state,next_state;
    parameter ill = 0, start = 1, alnum = 2, l_num = 3, l_op = 4,eq = 5;
    always @(posedge clk,posedge reset)begin
        if(reset) begin
            state <= start;
            // next_state <= start;
            exp_cnt <= 0;
        end
        else begin
            state <= next_state;
        end
    end
    
    always@(*) begin
        case(state) 
                ill: next_state = ill;
                start : begin
                    if(isAlphaNum) next_state = alnum;
                    else if(isSpace) next_state = start;
                    else next_state = ill;
                end
                alnum: begin
                    if(isOp) next_state = l_op;
                    else if(isSpace) next_state = alnum;
                    else if(isEq) begin
                        next_state = start;
                        exp_cnt = exp_cnt + 1;
                    end
                    else next_state = ill;
                end
                l_op:begin
                    if(isAlphaNum) next_state = alnum;
                    else if(isSpace) next_state = l_op;
                    else next_state = ill;
                end
                    
            endcase
    end

    assign result = (next_state == alnum) && (exp_cnt == 1);
endmodule
