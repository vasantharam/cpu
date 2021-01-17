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
parameter ADDR_WIDTH_MSB=10;
parameter NUM_PORTS=6;
input clk, rst;
input wr_port0_valid, wr_port1_valid;
input rd_port0_valid, rd_port1_valid, rd_port2_valid, rd_port3_valid;
input [DATA_WIDTH_MSB:0] wr_port0_data;
input [DATA_WIDTH_MSB:0] wr_port1_data;
input [ADDR_WIDTH_MSB:0] wr_port0_addr;
input [ADDR_WIDTH_MSB:0] wr_port1_addr;
input [ADDR_WIDTH_MSB:0] rd_port0_addr;
input [ADDR_WIDTH_MSB:0] rd_port1_addr;
input [ADDR_WIDTH_MSB:0] rd_port2_addr;
input [ADDR_WIDTH_MSB:0] rd_port3_addr;

output wr_port0_ready, wr_port1_ready;
output rd_port0_ready, rd_port1_ready, rd_port2_ready, rd_port3_ready;
output [DATA_WIDTH_MSB:0] rd_port0_data;
output [DATA_WIDTH_MSB:0] rd_port1_data;
output [DATA_WIDTH_MSB:0] rd_port2_data;
output [DATA_WIDTH_MSB:0] rd_port3_data;

reg [DATA_WIDTH_MSB:0] wr_data;
reg [ADDR_WIDTH_MSB:0] wr_addr;
reg [DATA_WIDTH_MSB:0] rd_data;
reg [ADDR_WIDTH_MSB:0] rd_addr;

reg grant[NUM_PORTS];
reg [ADDR_WIDTH_MSB:0] addr;
reg [DATA_WIDTH_MSB:0] din;
reg [DATA_WIDTH_MSB:0] dout;
reg ena;
reg current_state;
genvar loop;

main_ram i_ram(clk, write, addr, din, dout, ena);

                         
arbiter a( {wr_port0_valid, wr_port1_valid, rd_port0_valid, rd_port1_valid, rd_port2_valid, rd_port3_valid },
          {wr_port0_ready, wr_port1_ready, rd_port0_ready, rd_port1_ready, rd_port2_ready, rd_port3_ready },
          grant );                         

assign wr_addr = (grant[0]? wr_port0_addr: (grant[1]? wr_port1_addr: 0));
assign wr_data = (grant[0]? wr_port0_addr: (grant[1]? wr_port1_addr: 0));
assign rd_addr = (grant[2]? rd_port0_addr: (grant[3]? rd_port1_addr: (grant[4]? rd_port2_addr: (grant[5]? rd_port3_addr: 0))));
assign rd_port0_data = (grant[2]? rd_data:0);
assign rd_port1_data = (grant[3]? rd_data:0);
assign rd_port2_data = (grant[4]? rd_data:0);
assign rd_port3_data = (grant[5]? rd_data:0);

function mem_access(cur_addr, cur_data, wr, next_state);
    write<=wr;
    addr <= cur_addr; 
    din <= cur_data;
    ena <= 1;
    current_state <= next_state ;
endfunction

function set_response();
    if (rd) rd_data <= dout;
    ready <= 1;
    current_state <= `ST_NOC_IDLE;
endfunction

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
            ready <= 0;
            if (grant)
                mem_access(wr_addr, wr_data, 1, `ST_NOC_RESPOND);
          end /* `ST_NOC_IDLE */
          
     `ST_NOC_RESPOND: 
         set_response();
     endcase
     end
end

// N x 1 port splitter. In (Nx1) - N is all the IP's that need to talk to RAM and 1 is the RAM.

endmodule
