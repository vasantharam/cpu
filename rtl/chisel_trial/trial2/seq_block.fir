;buildInfoPackage: chisel3, version: 3.3.1, scalaVersion: 2.12.11, sbtVersion: 1.3.10
circuit seq_block : 
  module seq_block : 
    input clock : Clock
    input reset : UInt<1>
    output io : {flip in : UInt<1>, out : UInt<12>}
    
    reg pulse_counter : UInt<12>, clock with : (reset => (reset, UInt<1>("h00"))) @[trial2.scala 12:33]
    io.out <= pulse_counter @[trial2.scala 13:12]
    when io.in : @[trial2.scala 15:5]
      node _T = add(pulse_counter, UInt<1>("h01")) @[trial2.scala 16:40]
      node _T_1 = tail(_T, 1) @[trial2.scala 16:40]
      pulse_counter <= _T_1 @[trial2.scala 16:23]
      skip @[trial2.scala 15:5]
    
