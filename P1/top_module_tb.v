`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:12:13 10/16/2023
// Design Name:   top_module
// Module Name:   D:/CO/ISE_files/P1/top_module_tb.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_module
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_module_tb;

	// Inputs
	reg [7:0] in;
	reg clk;
	reg reset;

	// Outputs
	wire result;

	// Instantiate the Unit Under Test (UUT)
	top_module uut (
		.in(in), 
		.clk(clk), 
		.reset(reset), 
		.result(result)
	);

	reg [0:1023] s = "5+6=4+4";
	initial begin
		// Initialize Inputs
		in = " ";
		clk = 0;
		reset = 1;
		#10; reset = 0;
		
		while(!s[0:7]) s = s << 8;
		for(; s[0:7]; s = s << 8) begin
			$display("%s",s);
			in = s[0:7];
			#10;
		end

		// Wait 100 ns for global reset to finish
        
		// Add stimulus here

	end
	always #5 clk = ~clk;
      
endmodule

