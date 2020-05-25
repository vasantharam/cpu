
module fifo_checker(readReady, writeReady, readValid, writeValid, writeData, readData, clk, rst);
    parameter FIFO_WIDTH=8;
    input readReady, writeReady, readValid, writeValid, clk, rst;
    input [FIFO_WIDTH-1:0] readData;
    input [FIFO_WIDTH-1:0] writeData;
    int write_tag=0, read_tag=0;
    property data_not_x;
        @(posedge clk)  disable iff(rst)
        ( readReady  && readValid ) |-> (!$isunknown(readData));
    endproperty
    assert property (data_not_x);

    property rd_ready_follows_write;
        @(posedge clk) disable iff(rst)
        (writeReady && writeValid) |-> ##[0:1] readReady;
    endproperty
    assert property (rd_ready_follows_write);

    property written_data_was_eventually_readout;
        logic [FIFO_WIDTH-1:0] writtenData;
        @(posedge clk) disable iff (rst)
        ( writeReady  && writeValid  , writtenData = writeData) |-> ##[1:$] (readReady && readValid && readData==writtenData);
    endproperty 
    assert property ( written_data_was_eventually_readout);

    function inc_write_tag();
        write_tag = write_tag + 1;
    endfunction;
    
    function inc_read_tag();
        read_tag = read_tag + 1;
    endfunction;

    property data_is_seen_in_same_order;
        logic [FIFO_WIDTH-1:0] write1 ;
        int tag;
        @(posedge clk) disable iff (rst)
        ( ((writeReady && writeValid) , tag=write_tag, inc_write_tag(), write1 = writeData)   |-> (##[1:$] (readReady && readValid && tag==read_tag, inc_read_tag)) ##0 (readData == write1) );
    endproperty
    assert property (data_is_seen_in_same_order);
endmodule;

bind fifo fifo_checker fifo_checker(.*);

