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

module gray_to_bcd (gray, bcd);
    parameter MSB=3'h7;
    input [MSB:0] gray;
    output [MSB:0] bcd;
    assign  bcd[MSB] = gray[MSB];
    generate
    genvar i;
    for (i=MSB-1; i>=0 ; i=i-1)
    begin
        assign bcd[i] = gray[i] ^ bcd[i+1];
    end
    endgenerate
endmodule

module bcd_to_gray (bcd, gray);
    parameter MSB=7;
    output [MSB:0] gray;
    input [MSB:0] bcd;
    assign gray[MSB:0] = bcd[MSB:0] ^ {1'b0, bcd[MSB:1]};
endmodule

/* Write clk is faster than read clk */
module cdcfifo(readReady, writeReady, readValid, writeValid, writeData, readData, rdclk, wrclk, rst);
    parameter FIFO_DEPTH = 255; /* keeping bit count 8 given space for pointer overflow */
    parameter FIFO_WIDTH = 8;
    parameter MSB = $clog2(FIFO_DEPTH)-1;
    input readValid, writeValid, rdclk, wrclk, rst;
    input [FIFO_WIDTH-1:0] writeData;
    output reg readReady, writeReady;
    output reg [FIFO_WIDTH-1:0] readData;
    reg [MSB:0] readPtr;
    reg [MSB:0] readPtr_converted;
    reg [MSB:0] writePtr;
    wire [MSB:0] readPtr_gray;
    wire [MSB:0] writePtr_gray;
    reg empty, full, almost_full, almost_empty;
    reg empty_prev, full_prev, almost_full_prev, almost_empty_prev;
    reg [ FIFO_WIDTH-1:0 ] array [ FIFO_DEPTH-1:0];

    bcd_to_gray #(.MSB(MSB)) b2g(readPtr, readPtr_gray);
    gray_to_bcd #(.MSB(MSB)) g2b(readPtr_gray, readPtr_converted);
    /* Reader */
    always @(posedge rdclk)
    begin
        if (rst)
        begin
            readPtr <= 0;
        end
        else begin
        if (readReady && readValid)
        begin
            /* Introduces latency at low fifo occupancy to avoid metastability
               TBD: reduce latency.
             */
            if (almost_empty || almost_empty_prev || empty || empty_prev)
            begin
                readReady <= 0;
                readPtr <= `PLUSONE(readPtr);
                readData <= array [`PLUSONE(readPtr)];
            end
            else
            begin
                readReady <= 1;
                readPtr <= `PLUSONE(readPtr);
                readData <= array [`PLUSONE(readPtr)];
            end
        end
        else
        begin
            if (!empty_prev && !empty && (!(almost_empty_prev==0 && almost_empty==1)))
            begin
                /* if almost_empty_prev==0 and almost_empty==1, the data is
                 * being written to the RAM array, need to wait till next
                 * cycle. Next cycle, almost_empty_prev will also be 1 and
                 * data is in RAM. */
                readReady <= 1;
                readData <= array [readPtr];
            end
            else
            begin
                readReady <= 0;
                readData <= 0;
            end
        end
        end
    end
    /* Writer */
    always @(posedge wrclk)
    begin
        if (rst)
        begin
            writePtr <= 0;
        end
        else begin
        if (writeReady && writeValid)
        begin
            if (full) $error("assert_fail: FIFO cant be full and have writeReady !");
            if (almost_full)
            begin
                writeReady <= 0;
            end
            else writeReady <= 1;
            array [writePtr] <= writeData;
            writePtr <= `PLUSONE(writePtr) ;
        end
        else
        begin
            if (!full) writeReady <= 1;
            else writeReady <= 0;
        end
        end //rst else
    end
    /* status detection and init */
    always @(posedge wrclk)
    begin
        if (rst) 
        begin
        end
        else
        begin
            empty_prev <= empty;
            full_prev <= full;
            almost_full_prev <= almost_full;
            almost_empty_prev <= almost_empty;

            empty <= (writePtr == readPtr_converted) ? 1:0;
            almost_empty <= (`DIFF(writePtr, readPtr_converted) == 1) ? 1: 0;
            full <= ( `DIFF(writePtr, readPtr) == FIFO_DEPTH ) ? 1: 0; 
            almost_full <= ( `DIFF(writePtr, readPtr) == FIFO_DEPTH - 1) ? 1: 0; 
         
        end        
    end

endmodule



