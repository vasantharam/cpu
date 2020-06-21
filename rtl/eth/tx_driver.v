module ether_tx_driver(
    #(parameter DATA_WIDTH_MSB=15, parameter ETH_MAX_FRAME_SIZE=256) 
    tx_drv_wr_data, tx_drv_wr_valid, tx_drv_wr_ready, 
    mii_txd, mii_tx_en, mii_tx_clk,
    clk, rst);
    input [ETH_MAX_FRAME_SIZE-1:0] tx_drv_wr_data;
    input tx_drv_wr_valid;
    output tx_drv_wr_ready;


    fifo tx_driver_fifo (<TBD>, tx_drv_wr_ready, <TBD>, tx_drv_wr_valid, tx_drv_wr_data, <tbd> , clk, rst); 

endmodule
