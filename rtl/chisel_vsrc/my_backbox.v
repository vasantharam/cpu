module my_blackbox (clk , count_me, rst, count);
    input clk, count_me, rst;
    output reg [10:0] count;
    always @(posedge clk)
    begin
            if (rst) count <=0;
            else if (count_me) count <= count + 1;
    end
endmodule
