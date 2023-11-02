`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   04:55:00 10/12/2023
// Design Name:   alu
// Module Name:   D:/CO/ISE_files/P1/alu_tb.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alu_tb;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;
	reg [2:0] ALUOp;

	// Outputs
	wire [31:0] C;

	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.A(A), 
		.B(B), 
		.ALUOp(ALUOp), 
		.C(C)
	);

	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		ALUOp = 0;

		#5; ALUOp = 0;A = 1; B = 1;
		#5; ALUOp = 1;A = 1; B = 1;
		#5; ALUOp = 2;A = 1; B = 3;
		#5; ALUOp = 3;A = 1; B = 2;
		#5; ALUOp = 4;A = 5; B = 2;
		#5; ALUOp = 6;A = 5; B = 2;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

