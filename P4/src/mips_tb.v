`timescale 1ns / 1ps

module mips_tb;

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		clk = 0;
		reset = 1;
		#10; reset = 0;
	end
    
	always #1 clk = ~clk;
endmodule

