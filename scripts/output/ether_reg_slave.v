/* Note: This is a auto-generated file. 
 * Do not modify directly. 
 * Current Working Directory : C:\work\ise\scripts 
 * Generation command line: reg_gen.py ../defs/ether.csv
*/



 
module %s_reg_slave ( input [15:0] addr, input [15:0] wdata, output reg [15:0] rdata, input write_valid, input read_valid, output reg read_ready, output reg wrsp_slverr, output reg rrsp_slverr, input clk, input rst, output reg [15:0] reg_ether_COMMAND, output reg [15:0] reg_ether_READ_FRAME_BASE, output reg [15:0] reg_ether_READ_FRAME_RD_PTR, output reg [15:0] reg_ether_READ_FRAME_WR_PTR, output reg [15:0] reg_ether_READ_FRAME_SIZE, output reg [15:0] reg_ether_WRITE_FRAME_BASE, output reg [15:0] reg_ether_WRITE_FRAME_RD_PTR, output reg [15:0] reg_ether_WRITE_FRAME_WR_PTR, output reg [15:0] reg_ether_WRITE_FRAME_SIZE, output reg [15:0] reg_ether_STATUS, )

always @(posedge clk)
begin
    if (rst)
    begin
    /* reset value assignments */
        reg_ether_COMMAND <= 0
        reg_ether_READ_FRAME_BASE <= 0
        reg_ether_READ_FRAME_RD_PTR <= 0
        reg_ether_READ_FRAME_WR_PTR <= 0
        reg_ether_READ_FRAME_SIZE <= 0
        reg_ether_WRITE_FRAME_BASE <= 0
        reg_ether_WRITE_FRAME_RD_PTR <= 0
        reg_ether_WRITE_FRAME_WR_PTR <= 0
        reg_ether_WRITE_FRAME_SIZE <= 0
        reg_ether_STATUS <= 0

    end
    else
    begin
        if (write_valid)
        begin
            case (addr)
                /*offset:
                    reg_name <= wdata;
                    wrsp_slverr <= 0;  */
                8'd0: 
                    reg_ether_COMMAND <= wdata;
                    wrsp_slverr <= 0;
                8'd1: 
                    reg_ether_READ_FRAME_BASE <= wdata;
                    wrsp_slverr <= 0;
                8'd2: 
                    reg_ether_READ_FRAME_RD_PTR <= wdata;
                    wrsp_slverr <= 0;
                8'd3: 
                    reg_ether_READ_FRAME_WR_PTR <= wdata;
                    wrsp_slverr <= 0;
                8'd4: 
                    reg_ether_READ_FRAME_SIZE <= wdata;
                    wrsp_slverr <= 0;
                8'd5: 
                    reg_ether_WRITE_FRAME_BASE <= wdata;
                    wrsp_slverr <= 0;
                8'd6: 
                    reg_ether_WRITE_FRAME_RD_PTR <= wdata;
                    wrsp_slverr <= 0;
                8'd7: 
                    reg_ether_WRITE_FRAME_WR_PTR <= wdata;
                    wrsp_slverr <= 0;
                8'd8: 
                    reg_ether_WRITE_FRAME_SIZE <= wdata;
                    wrsp_slverr <= 0;
                8'd9: 
                    reg_ether_STATUS <= wdata;
                    wrsp_slverr <= 0;

                default:
                    wrsp_slverr <= 1;
            endcase
        end
        if (read_valid)
        begin
            case (addr)
                /*offset:
                    rdata <= reg_name ;
                    rrsp_slverr <= 0;
                    read_ready <= 1; */
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;

                default:
                    rrsp_slverr <= 1;
                    read_ready <= 1;
            endcase
        end
        else read_ready <= 0;
    end  
end

endmodule;
