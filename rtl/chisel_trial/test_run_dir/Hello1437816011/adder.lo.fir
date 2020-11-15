circuit adder :
  module adder :
    input clock : Clock
    input reset : UInt<1>
    input io_a : UInt<4>
    input io_b : UInt<4>
    output io_res : UInt<4>
    output io_carry : UInt<1>
  
    node temp1 = pad(io_a, 5) @[hello.scala 13:21 hello.scala 15:11]
    node temp2 = pad(io_b, 5) @[hello.scala 14:21 hello.scala 16:11]
    node _T = add(temp1, temp2) @[hello.scala 17:24]
    node _T_1 = tail(_T, 1) @[hello.scala 17:24]
    node _T_2 = shr(_T_1, 4) @[hello.scala 17:33]
    node _T_3 = add(temp1, temp2) @[hello.scala 18:22]
    node _T_4 = tail(_T_3, 1) @[hello.scala 18:22]
    io_res <= bits(_T_4, 3, 0) @[hello.scala 18:12]
    io_carry <= _T_2 @[hello.scala 17:14]
