/* In this limited implementation `ETH_MAX_FRAME_SIZE is restricted to 256
* bits */
`define WR_STATE_IDLE 0
`define WR_STATE_FETCH_FRAME 1
`define WR_STATE_FETCH_FRAME_WAIT_FOR_READY 2
`define WR_STATE_WAIT_SEND_DONE 3

module  eth_writer 
    #(parameter DATA_WIDTH_MSB=15, parameter ETH_MAX_FRAME_SIZE=256) 
      (reg_ether_WRITE_FRAME_BASE, 
       reg_ether_WRITE_FRAME_RD_PTR, 
       reg_ether_WRITE_FRAME_WR_PTR, 
      
       write_fsm_state, 

       ram_rd_data,  ram_rd_valid,  ram_rd_addr,  ram_rd_ready,  
       
       tx_drv_wr_data,  tx_drv_wr_valid,  tx_drv_wr_ready, clk, rst )
/* reg slave internal interface */
input [DATA_WIDTH_MSB:0] reg_ether_WRITE_FRAME_BASE; 
inout [DATA_WIDTH_MSB:0]  reg_ether_WRITE_FRAME_RD_PTR;
input [DATA_WIDTH_MSB:0] reg_ether_WRITE_FRAME_WR_PTR;
output reg [3:0] write_fsm_state;

/* Ram interface */
input [DATA_WIDTH_MSB:0] ram_rd_data;
output reg ram_rd_valid; 
output reg ram_rd_addr; 
input ram_rd_ready;

/* tx_drv internal interface */
output reg [ETH_MAX_FRAME_SIZE-1:0] tx_drv_wr_data; 
output reg tx_drv_wr_valid; 
input tx_drv_wr_ready;

reg rd_ptr, wr_ptr;
reg [$clog2(ETH_MAX_FRAME_SIZE):0] frame_size_counter;
assign  reg_ether_WRITE_FRAME_RD_PTR = rd_ptr;
assign wr_ptr = reg_ether_WRITE_FRAME_WR_PTR;

always @(posedge clk)
begin
    if (rst)
    begin
        write_fsm_state <= `WR_ST_IDLE;
        ram_rd_valid <= 0;
        tx_drv_wr_valid <= 0;
    end
    else
    begin
        case (write_fsm_state)
        `WR_STATE_IDLE:
            if (rd_ptr != wr_ptr)
                write_fsm_state <= `WR_STATE_FETCH_FRAME;
        `WR_STATE_FETCH_FRAME:
            begin
                ram_rd_addr <= reg_ether_WRITE_FRAME_BASE + rd_ptr;
                ram_rd_valid <= 1;
                write_fsm_state <= `WR_STATE_FETCH_FRAME_WAIT_FOR_READY;
                frame_size_counter <= 0;
            end
        `WR_STATE_FETCH_FRAME_WAIT_FOR_READY:
            begin
                assert (ram_rd_valid) else $error("Unexpected FSM state - WAIT_FOR_READY");
                if (ram_rd_ready == 1 && ram_rd_valid == 1)
                begin
                    rd_ptr <= rd_ptr + (DATA_WIDTH_MSB+1)/8
                    tx_drv_wr_data[(ETH_MAX_FRAME_SIZE - frame_size_counter):(ETH_MAX_FRAME_SIZE - DATA_WIDTH_MSB - frame_size_counter)] <= ram_rd_data;
                
                    frame_size_counter <= frame_size_counter + (DATA_WIDTH_MSB+1)/8; 
                  
              
                    if  (frame_size_counter == ETH_MAX_FRAME_SIZE) 
                    begin
                        write_fsm_state <= `WR_STATE_WAIT_SEND_DONE;
                        tx_drv_wr_valid <=1;
                        ram_rd_valid <=0;
                    end
                    else
                    begin
                        ram_rd_addr <= reg_ether_WRITE_FRAME_BASE + rd_ptr;
                    end
            end
        `WR_STATE_WAIT_SEND_DONE:
            begin
                if (tx_drv_wr_valid && tx_drv_wr_ready)
                begin
                    tx_drv_wr_valid <= 0;
                    write_fsm_state <= `WR_STATE_IDLE;
                end
            end
    end
end

endmodule
