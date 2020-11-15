module adder(
  input        clock,
  input        reset,
  input  [3:0] io_a,
  input  [3:0] io_b,
  output [3:0] io_res,
  output       io_carry
);
  wire [4:0] temp1 = {{1'd0}, io_a}; // @[hello.scala 13:21 hello.scala 15:11]
  wire [4:0] temp2 = {{1'd0}, io_b}; // @[hello.scala 14:21 hello.scala 16:11]
  wire [4:0] _T_1 = temp1 + temp2; // @[hello.scala 17:24]
  assign io_res = _T_1[3:0]; // @[hello.scala 18:12]
  assign io_carry = _T_1[4]; // @[hello.scala 17:14]
endmodule
