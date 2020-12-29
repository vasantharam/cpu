
import chisel3._
import chisel3.util._
import chisel3.iotesters.{ChiselFlatSpec, Driver, PeekPokeTester}
import chisel3.stage.ChiselStage

class my_blackbox() extends BlackBox() with HasBlackBoxResource
{
    addResource("/my_blackbox.v")
    val io = IO(new Bundle {
      val count_me = Input(UInt(1.W))
      val rst = Input(Bool())
      val clk = Input(Clock())
      val count = Output(UInt(10.W))
    })

}

class my_blackbox_wrap() extends Module
{
    val io = IO(new Bundle {
      val count_me = Input(UInt(1.W))
      val count = Output(UInt(10.W))
    })
    val tb = Module(new my_blackbox())
    tb.io.rst := reset
    tb.io.clk := clock
    tb.io.count_me := io.count_me
    io.count := tb.io.count
}
class blackbox_tester(s: my_blackbox_wrap) extends PeekPokeTester(s)
{
    poke(s.io.count_me, 1)
    step(1)
    expect(s.io.count, 1)
    step(10)
    expect(s.io.count, 11)
}

object blackbox
{
    def main(args: Array[String])
    {
        println("BlackBox Hello World");
        val works = chisel3.iotesters.Driver ( () => new my_blackbox_wrap(), "verilator") {
            c=> new blackbox_tester(c)
        }
        assert(works)
        println("Success!!");
    }
}
