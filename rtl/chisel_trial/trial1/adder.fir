;buildInfoPackage: chisel3, version: 3.3.1, scalaVersion: 2.12.11, sbtVersion: 1.3.10
circuit adder : 
  module adder : 
    input clock : Clock
    input reset : UInt<1>
    output io : {flip a : UInt<4>, flip b : UInt<4>, res : UInt<4>, carry : UInt<1>}
    
    wire temp1 : UInt<5> @[hello.scala 13:21]
    wire temp2 : UInt<5> @[hello.scala 14:21]
    temp1 <= io.a @[hello.scala 15:11]
    temp2 <= io.b @[hello.scala 16:11]
    node _T = add(temp1, temp2) @[hello.scala 17:24]
    node _T_1 = tail(_T, 1) @[hello.scala 17:24]
    node _T_2 = shr(_T_1, 4) @[hello.scala 17:33]
    io.carry <= _T_2 @[hello.scala 17:14]
    node _T_3 = add(temp1, temp2) @[hello.scala 18:22]
    node _T_4 = tail(_T_3, 1) @[hello.scala 18:22]
    io.res <= _T_4 @[hello.scala 18:12]
    
