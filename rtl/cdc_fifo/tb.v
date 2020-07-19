module top;
    parameter FIFO_WIDTH=8;
    parameter FIFO_DEPTH=255;
    reg readValid, writeValid, wrclk, rdclk, rst;
    reg  [FIFO_WIDTH-1:0] writeData;
    reg  [FIFO_WIDTH-1:0] readData;
    reg readReady, writeReady;
    reg readPending, writePending;
    integer readFrequency, writeFrequency;
    cdcfifo # (.FIFO_DEPTH(255), .FIFO_WIDTH(8)) my_fifo (readReady, writeReady, readValid, writeValid, writeData, readData,rdclk, wrclk, rst);
    initial 
    begin
        wrclk <= 0;
        rdclk <= 0;
        rst <= 1;
        readPending <= 0;
        writePending <= 1;
        if (!$value$plusargs("readFrequency=%d", readFrequency)) readFrequency <= 3;
        if (!$value$plusargs("writeFrequency=%d", writeFrequency)) writeFrequency <= 5;
        $display("readFrequency = %d", readFrequency);
        $display("writeFrequency = %d", writeFrequency);
    #30 rst <= 0;
    end
    always 
    begin
        #10 rdclk <= ~rdclk;
        #10 wrclk <= ~wrclk;
    end

    always @(posedge wrclk)
    begin
        reg writing_this_cycle;
        
        writing_this_cycle <= (($urandom % writeFrequency) ==0)?1:0;
        $display("%x: writing_this_cycle = %d", $time(), writing_this_cycle);
        if (!rst)
        begin
        if (!writePending) begin
            if (writing_this_cycle) begin
                writeData <= $urandom % (256);    
                writeValid <= 1;
            end
            else writeValid <= 0;
        end
        if (writeReady) writePending <=0;
        else if (!writePending && writing_this_cycle) writePending <= 1;

        if (writeReady == 1 && writeValid == 1) $display ("%x: Write Data:  %x ", $time(), writeData);
        end
    end
    always @(posedge rdclk)
    begin
        if (!rst)
        begin
        if (readReady == 1 && readValid == 1) $display ("%x: Read Data:  %x ", $time(), readData);
        if (!readPending) begin
            if (($urandom%readFrequency) == 0) begin
                readValid <= 1;
                if (readReady) readPending <=0;
                else readPending <= 1;
            end
            else readValid <= 0;
        end //!readPending
        end //!rst
    end 
endmodule
