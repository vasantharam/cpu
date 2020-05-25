function integer clog2;
    input integer value;
    begin
        value = value-1;
        for (clog2=0; value>0; clog2=clog2+1)
            value = value>>1;
    end
endfunction

`define PLUSONE(Ptr) ((Ptr == (FIFO_DEPTH-1)) ? 0: (Ptr + 1))
`define DIFF(ptr2, ptr1) ((ptr2 >= ptr1) ? (ptr2 - ptr1): (FIFO_DEPTH - ptr1 + ptr2)) 

module fifo(readReady, writeReady, readValid, writeValid, writeData, readData, clk, rst);
    parameter FIFO_DEPTH = 255; /* keeping bit count 8 given space for pointer overflow */
    parameter FIFO_WIDTH = 8;
    input readValid, writeValid, clk, rst;
    input [FIFO_WIDTH-1:0] writeData;
    output reg readReady, writeReady;
    output reg [FIFO_WIDTH-1:0] readData;
    reg [$clog2(FIFO_DEPTH):0] readPtr;
    reg [$clog2(FIFO_DEPTH):0] writePtr;
    reg empty, full, almost_full, almost_empty;
    reg [ FIFO_WIDTH-1:0 ] array [ FIFO_DEPTH-1:0];
    assign empty = (readPtr == writePtr)?  1:0;
    assign full = ( `DIFF(writePtr, readPtr) == FIFO_DEPTH ) ? 1: 0; 
    assign almost_full = ( `DIFF(writePtr, readPtr) == FIFO_DEPTH - 1) ? 1: 0; 
    assign almost_empty = (`DIFF(writePtr, readPtr) == 1)? 1: 0; 
    reg okayToRead; 
    reg okayToWrite; 
    assign okayToRead = ((!empty&&readValid) || ( empty && writeValid && readValid && readReady && writeReady )) ? 1:0;
    assign okayToWrite = ((!full &&  writeValid) || ( full && readValid && writeValid && readReady && writeReady )) ? 1:0;


    always @(posedge clk)
    begin
        if (rst) 
        begin
            readPtr <= 0;
            writePtr <= 0;
            readReady <= 0;
            writeReady <= 1;
        end
        else
        begin
            case({okayToRead, okayToWrite})
                2'b00:
                    readData <= array[readPtr];
                2'b01:
                    begin
                    if (readPtr == writePtr) readData <= writeData;
                    else readData <= array[readPtr];
                    writePtr <= `PLUSONE(writePtr);
                    array[writePtr] <= writeData;
                    end
                2'b10:
                    begin
                    readPtr <= `PLUSONE(readPtr);
                    readData <= array[`PLUSONE(readPtr)];
                    end
                2'b11:
                    begin
                    if ((readPtr == writePtr) || (`PLUSONE(readPtr) == writePtr )) readData <= writeData;
                    else readData <= array[`PLUSONE(readPtr)];
                    readPtr <= `PLUSONE(readPtr);
                    writePtr <= `PLUSONE(writePtr);
                    array[writePtr] <= writeData; 
                    end
            endcase
            if (full || (almost_full && okayToWrite && !okayToRead)) writeReady <= 0; 
            else writeReady <= 1;
            if (almost_empty && (okayToRead && !okayToWrite)) readReady <= 0; 
            else if (empty && !okayToWrite) readReady <= 0;
            else readReady <= 1;
        end        
    end

endmodule


