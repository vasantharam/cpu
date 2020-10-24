`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:20:55 10/24/2020 
// Design Name: 
// Module Name:    arbiter 
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
function cyclic_shift ( var, shift);
parameter NUM_REQ_MSB=4;
    reg [(NUM_REQ_MSB+1) * 2 - 1 : 0] value;
	 value = var << shift;
	 cyclic_shift[NUM_REQ_MSB:0] = var[NUM_REQ_MSB:0] | value [ (NUM_REQ_MSB+1) * 2 -1 : NUM_REQ_MSB+1 ];

endfunction

module arbiter(
    req, grant, clk, rst
    );
parameter NUM_REQ_MSB=4;
input [NUM_REQ_MSB:0] req;
output [NUM_REQ_MSB:0] grant;
input clk;
input rst;

reg [NUM_REQ_MSB:0] cur_pointer; /* one hot */
integer i;
always @(posedge clk)
begin
    if (rst)
	 begin
	     cur_pointer <= 1; 
	 end
	 

	 
	 cur_pointer <= cyclic_shift(cur_pointer, 1);
	
	 for (i=0; i< NUM_REQ_MSB+1; i= i+1)
	 begin 
        if (req & cyclic_shift(cur_pointer, i))
	     begin
	         grant <= cyclic_shift(cur_pointer, i);
				cur_pointer <= cyclic_shift(cur_pointer, i);
				break;
        end
	 end
    	 
	 
	 
end

endmodule
