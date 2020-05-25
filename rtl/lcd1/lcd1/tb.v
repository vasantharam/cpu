`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:52:54 04/09/2020
// Design Name:   hello
// Module Name:   C:/work/ise/lcd1/lcd1/tb.v
// Project Name:  lcd1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: hello
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb;

	// Inputs
	reg BTN_NORTH;
	reg BTN_SOUTH;
	reg BTN_WEST;
	reg BTN_EAST;
    reg clk;

	// Outputs
	wire LED_F12;
	wire LCD_E;
	wire LCD_RS;
	wire LCD_RW;
	wire [3:0] DB;
	wire SF_CE0;

	// Instantiate the Unit Under Test (UUT)
	hello uut (
		.clk(clk), 
		.LED_F12(LED_F12), 
		.LCD_E(LCD_E), 
		.LCD_RS(LCD_RS), 
		.LCD_RW(LCD_RW), 
		.DB(DB), 
		.SF_CE0(SF_CE0), 
		.BTN_NORTH(BTN_NORTH), 
		.BTN_SOUTH(BTN_SOUTH), 
		.BTN_WEST(BTN_WEST), 
		.BTN_EAST(BTN_EAST)
	);

	initial begin
		// Initialize Inputs
		BTN_NORTH = 0;
		BTN_SOUTH = 0;
		BTN_WEST = 0;
		BTN_EAST = 0;
        clk = 0;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
    always 
    begin
        #10 clk <= ~clk;
    end

    initial
    begin
        #2000000 BTN_WEST <= 1;
        #2004000 BTN_WEST <= 0;
        #4000000 BTN_WEST <= 1;
        #4004000 BTN_WEST <= 0;

    end
      
endmodule

