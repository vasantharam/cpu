`include "eth_defs.vh"
module ether_tx_driver(
    tx_drv_wr_data, tx_drv_wr_valid, tx_drv_wr_ready, 
    mii_txd, mii_tx_en, mii_tx_clk, mii_tx_err,
    clk, rst);
	 parameter DATA_WIDTH_MSB=15;
	 parameter ETH_MAX_FRAME_SIZE=256;
    input [ETH_MAX_FRAME_SIZE-1:0] tx_drv_wr_data;
    input tx_drv_wr_valid;
    output tx_drv_wr_ready;
    reg tx_fifo_rd_valid, tx_fifo_rd_ready;
    reg [ETH_MAX_FRAME_SIZE-1:0] tx_fifo_rd_data;
    reg [ETH_MAX_FRAME_SIZE-1:0] frame_to_send;
    reg [$clog2(ETH_MAX_FRAME_SIZE)-1:0] nibble_counter;

    /* ports for fifo(readReady, writeReady, readValid, writeValid, writeData, readData, clk, rst); */
    /* TBD: ERROR: Replace with async fifo to read using mii_tx_clk and write using clk */

    fifo tx_driver_fifo (tx_fifo_rd_valid, tx_drv_wr_ready, tx_fifo_rd_ready, tx_drv_wr_valid, tx_drv_wr_data, tx_fifo_rd_data , mii_tx_clk, clk, rst); 

    always @(posedge mii_tx_clk)
    begin
       if (rst)
       begin
       end
       else
       begin
           case(tx_driver_state)
           `TX_DRIVER_IDLE:
               begin
                   tx_fifo_rd_valid <= 1;
                   tx_driver_state_nxt <= TX_DRIVER_WAIT_FOR_FIFO_READY;
               end
           `TX_DRIVER_WAIT_FOR_FIFO_READY:
               if (tx_fifo_rd_ready == 1) 
                   begin
                       frame_to_send <= tx_fifo_rd_data;
                       tx_driver_state_nxt <= TX_DRIVER_SEND_FRAME;
                       frame_nibble_counter <=0;
                   end
           `TX_DRIVER_SEND_FRAME:
               if (frame_nibble_counter >= `ETH_FRAME_PREAMBLE_START && frame_nibble_counter < `ETH_FRAME_PREAMBLE_END
                   && (frame_to_send[ETH_MAX_FRAME_SIZE-1-frame_nibble_counter:ETH_MAX_FRAME_SIZE-1-frame_nibble_counter-3] != 4'b1010))
                   begin
                       /* Indicate frame error in error register  - Invalid preamble*/
                       // TBD
                   end
               else if ((frame_nibble_counter == `ETH_FRAME_PREAMBLE_END) &&
                   (frame_to_send[ETH_MAX_FRAME_SIZE-1-frame_nibble_counter:ETH_MAX_FRAME_SIZE-1-frame_nibble_counter-3] != 4'b1011))
                   begin
                       /* Indicate frame error in error register - Invalid preamble */
                       // TBD
                   end
               else if ((frame_nibble_counter == `ETH_FRAME_TYPE_MSB) &&
                   (frame_to_send[ETH_MAX_FRAME_SIZE-1-frame_nibble_counter:ETH_MAX_FRAME_SIZE-1-frame_nibble_counter-7] != 8'h08))
                   begin
                       /* Indicate frame error in error register - Invalid ether type only IPv4 supported*/
                       // TBD
                   end
               else if ((frame_nibble_counter == `ETH_FRAME_TYPE_LSB) &&
                   (frame_to_send[ETH_MAX_FRAME_SIZE-1-frame_nibble_counter:ETH_MAX_FRAME_SIZE-1-frame_nibble_counter-7] != 8'h00))
                   begin
                       /* Indicate frame error in error register - Invalid ether type only IPv4 supported */
                       // TBD
                   end
               else if (frame_nibble_counter == ETHER_MAX_FRAME_SIZE * 2)
                   begin
                       // SEND COMPLETE
                       mii_tx_en <=0;
                       tx_driver_state_nxt <= TX_DRIVER_IDLE; 
                   end
               else
               begin
                   // Put the next nibble out
                   mii_txd <= frame_to_send[ETH_MAX_FRAME_SIZE-1-frame_nibble_counter:ETH_MAX_FRAME_SIZE-1-frame_nibble_counter-3];
                   mii_tx_en <= 1;
						 frame_nibble_counter <= frame_nibble_counter + 1;
               end
           endcase   
       end 
    end
endmodule
