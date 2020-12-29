import chisel3._
import chisel3.util._
import chisel3.iotesters.{ChiselFlatSpec, Driver, PeekPokeTester}
import chisel3.stage.ChiselStage

class seq_block(width:Int) extends Module
{
    val io= IO(new Bundle {
        val in = Input(Bool())
        val out = Output(UInt(width.W))
    })
    val pulse_counter =  RegInit(UInt(width.W), 0.U)
    io.out := pulse_counter
    when (io.in)
    {
        pulse_counter := pulse_counter + 1.U
    }
}

class counter_tester(s: seq_block) extends PeekPokeTester(s)
{
    poke(s.io.in, true.B)
    step(1)
    expect(s.io.out, 1);
    poke(s.io.in, false.B)
    step(1)
    expect(s.io.out, 1);
    poke(s.io.in, true.B)
    step(1)
    expect(s.io.out, 2);
}
object trial2
{
    def main(args: Array[String])
    {
        println ("trial2 hello")
        println( (new ChiselStage).emitVerilog( new seq_block(12)) ) 
        val works = chisel3.iotesters.Driver( () => new seq_block(10), "verilator") {
            c=> new counter_tester( c )
        }
        assert(works)
        println("Success!!");
    }
}
