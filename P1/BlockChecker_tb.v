`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   04:32:25 10/13/2023
// Design Name:   BlockChecker
// Module Name:   D:/CO/ISE_files/P1/BlockChecker_tb.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: BlockChecker
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module BlockChecker_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] in;

	// Outputs
	wire result;

	// Instantiate the Unit Under Test (UUT)
	BlockChecker uut (
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.result(result)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		in = 0;

		// Wait 100 ns for global reset to finish
		#5; reset = 1; in = "a";
		#10; reset = 0; in = "a";
		#10; in = " ";
		#10; in = "B";
		#10; in = "E";
		#10; in = "g";
		#10; in = "i";
		#10; in = "n";
		#10; in = " ";
		#10; in = "E";
		#10; in = "n";
		#10; in = "d";
		#10; in = "c";
		#10; in = " ";
		#10; in = "e";
		#10; in = "n";
		#10; in = "d";
		#10; in = " ";
		#10; in = "b";
		#10; in = "E";
		#10; in = "G";
		#10; in = "i";
		#10; in = "n";
		#10; in = " ";
		#10; in = " ";
		#10; in = "e";
		#10; in = "n";
		#10; in = "d";
		#10; in = " ";
		// Add stimulus here
	end
	always #5 clk = ~clk;

endmodule

