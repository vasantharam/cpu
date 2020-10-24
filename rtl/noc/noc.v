`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:52:38 10/20/2020 
// Design Name: 
// Module Name:    noc 
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
/* 
Ports
   starting with 2 writer ports, 3 read ports. 
	
   ether_writer, ether_reader, lcd reader, i$reader, d$reader, d$writer
*/

/* SV interfaces could have been handy. */

`include "noc_defs.vh"

module noc(clk, 
        wr_port0_valid, wr_port0_ready, wr_port0_data, wr_port0_addr,
		  wr_port1_valid, wr_port1_ready, wr_port1_data, wr_port1_addr,
		  
		  rd_port0_valid, rd_port0_ready, rd_port0_data, rd_port0_addr,
		  rd_port1_valid, rd_port1_ready, rd_port1_data, rd_port1_addr,
		  rd_port2_valid, rd_port2_ready, rd_port2_data, rd_port2_addr,
		  rd_port3_valid, rd_port3_ready, rd_port3_data, rd_port3_addr, clk, rst		  
    );
parameter DATA_WIDTH_MSB=15;
parameter NUM_PORTS=5;
input clk, rst;
input wr_port0_valid, wr_port1_valid;
input rd_port0_valid, rd_port1_valid, rd_port2_valid;
input [DATA_WIDTH_MSB:0] wr_port0_data;
input [DATA_WIDTH_MSB:0] wr_port1_data;
input [ADDR_WIDTH_MSB:0] wr_port0_addr;
input [ADDR_WIDTH_MSB:0] wr_port1_addr;
input [ADDR_WIDTH_MSB:0] rd_port0_addr;
input [ADDR_WIDTH_MSB:0] rd_port1_addr;
input [ADDR_WIDTH_MSB:0] rd_port0_addr;

output wr_port0_ready, wr_port1_ready;
output rd_port0_ready, rd_port1_ready, rd_port2_ready;
output [DATA_WIDTH_MSB:0] rd_port0_data;
output [DATA_WIDTH_MSB:0] rd_port1_data;
output [DATA_WIDTH_MSB:0] rd_port2_data;

reg grant[NUM_PORTS];
reg [ADDR_WIDTH_MSB:0] addr;
reg [DATA_WIDTH_MSB:0] din;
reg [DATA_WIDTH_MSB:0] dout;
reg ena;
reg current_state;
genvar loop;

main_ram i_ram(clk, write, addr, din, dout, ena);

						 
arbiter ( {wr_port0_valid, wr_port1_valid, rd_port0_valid, rd_port1_valid, rd_port2_valid },
          grant );						 

always @(posedge clk)
begin
    if (rst)
	 begin
	     current_state <= `ST_NOC_IDLE;
	 end
    else
	 begin
	 ena<=0;
	 
	 switch(current_state);
	 case(current_state)
	 `ST_NOC_IDLE:
        begin		  
	     if (grant[0])
		  begin
		      write<=1;
				addr <= wr_port0_addr;
				din <= wr_port0_data;
				ena <= 1;
				current_state <= `ST_NOC_WR_PORT0_RESPOND;
        end
		  if (grant[1])
		  begin
		      write<=1;
				addr <= wr_port1_addr;
				din <= wr_port1_data;
				ena <= 1;
				current_state <= `ST_NOC_WR_PORT1_RESPOND;
        end
		  if (grant[2])
		  begin
		      write<=0;
				addr <= rd_port0_addr;
				ena <= 1;
				current_state <= `ST_NOC_RD_PORT0_RESPOND;
        end
		  if (grant[3])
		  begin
		      write<=0;
				addr <= rd_port1_addr;
				ena <= 1;
				current_state <= `ST_NOC_RD_PORT1_RESPOND;
        end
		  if (grant[4])
		  begin
		  		write<=0;
				addr <= rd_port2_addr;
				ena <= 1;
				current_state <= `ST_NOC_RD_PORT2_RESPOND;
        end
		  end /* `ST_NOC_IDLE */
		  
		  endcase
	 end
end

// N x 1 port splitter. In (Nx1) - N is all the IP's that need to talk to RAM and 1 is the RAM.

endmodule
