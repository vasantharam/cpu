/* In this limited implementation `ETH_MAX_FRAME_SIZE is restricted to 256
* bits */

`include "eth_defs.vh" 
module  eth_reader 
    #(parameter DATA_WIDTH_MSB=15, parameter ETH_MAX_FRAME_SIZE=256, parameter ADDR_WIDTH_MSB=15) 
      (reg_ether_READ_FRAME_BASE, 
       reg_ether_READ_FRAME_RD_PTR, 
       reg_ether_READ_FRAME_WR_PTR, 
      
       read_fsm_state, 

       ram_wr_data,  ram_wr_valid,  ram_wr_addr,  ram_wr_ready,  
       
       rx_drv_rd_data,  rx_drv_rd_valid,  rx_drv_rd_ready, clk, rst );
/* reg slave internal interface */
input [DATA_WIDTH_MSB:0] reg_ether_READ_FRAME_BASE; 
inout [DATA_WIDTH_MSB:0]  reg_ether_READ_FRAME_RD_PTR;
input [DATA_WIDTH_MSB:0] reg_ether_READ_FRAME_WR_PTR;
output reg [3:0] read_fsm_state;

/* Ram interface */
output reg [DATA_WIDTH_MSB:0] ram_wr_data;
output reg ram_wr_valid; 
output reg [ADDR_WIDTH_MSB:0] ram_wr_addr; 
input ram_wr_ready;

/* rx_drv internal interface */
input [ETH_MAX_FRAME_SIZE-1:0] rx_drv_rd_data; 
output reg rx_drv_rd_valid; 
input rx_drv_rd_ready;

reg rd_ptr, wr_ptr;
reg [$clog2(ETH_MAX_FRAME_SIZE):0] frame_size_counter;
reg [ETH_MAX_FRAME_SIZE-1:0] read_frame;
assign reg_ether_READ_FRAME_WR_PTR = wr_ptr;
assign rd_ptr = reg_ether_READ_FRAME_RD_PTR;

always @(posedge clk)
begin
    if (rst)
    begin
        read_fsm_state <= `RD_STATE_IDLE;
        ram_wr_valid <= 0;
        rx_drv_rd_valid <= 0;
    end
    else
    begin
        case (read_fsm_state)
        `RD_STATE_IDLE:
		      begin
                rx_drv_rd_valid <= 1;
                read_fsm_state <= `RD_STATE_WAIT_FOR_RXDATA;
				end
        `RD_STATE_WAIT_FOR_RXDATA:
            begin
//            assert (rx_drv_rd_valid) else $error ("Unexpected FSM state WAIT_FOR_RXDATA");
            if (rx_drv_rd_ready && rx_drv_rd_valid)
            begin
                read_frame <= rx_drv_rd_data;
                rx_drv_rd_valid <= 0;

                ram_wr_addr <= reg_ether_READ_FRAME_BASE + wr_ptr;
                ram_wr_valid <= 1;
                ram_wr_data <= rx_drv_rd_data[(ETH_MAX_FRAME_SIZE - frame_size_counter):(ETH_MAX_FRAME_SIZE - DATA_WIDTH_MSB - frame_size_counter)];
                read_fsm_state <= `RD_STATE_WRITE_FRAME_TO_RAM;
                frame_size_counter <= 0;
            end
				end
        `RD_STATE_WRITE_FRAME_TO_RAM:
            begin
                if (ram_wr_ready == 1 && ram_wr_valid == 1)
                begin
                    wr_ptr <= wr_ptr + (DATA_WIDTH_MSB+1)/8;
                    ram_wr_data <= rx_drv_rd_data[(ETH_MAX_FRAME_SIZE - frame_size_counter):(ETH_MAX_FRAME_SIZE - DATA_WIDTH_MSB - frame_size_counter)];
                
                    frame_size_counter <= frame_size_counter + (DATA_WIDTH_MSB+1)/8; 
                  
              
                    if  (frame_size_counter == ETH_MAX_FRAME_SIZE) 
                    begin
                        read_fsm_state <= `RD_STATE_WAIT_LAST_WRITE;
                    end
                    ram_wr_addr <= reg_ether_READ_FRAME_BASE + wr_ptr;
				    end
            end
        `RD_STATE_WAIT_LAST_WRITE:
            begin
                if (ram_wr_ready && ram_wr_valid)
                begin
                    ram_wr_valid <= 0;
                    read_fsm_state <= `RD_STATE_IDLE;
                end
            end
        endcase
	 end
end

endmodule
