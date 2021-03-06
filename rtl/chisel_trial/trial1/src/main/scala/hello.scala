import chisel3._
import chisel3.util._
import chisel3.iotesters.{ChiselFlatSpec, Driver, PeekPokeTester}
import chisel3.stage.ChiselStage

class adder(width: Int) extends Module {
    val io = IO(new Bundle {
        val a = Input (UInt(width.W))
        val b = Input (UInt(width.W))
        val res = Output(UInt(width.W))
        val  carry = Output(UInt(1.W))
    })
    val temp1 = Wire(Input(UInt((width+1).W)))
    val temp2 = Wire(Input(UInt((width+1).W)))
    temp1 := io.a
    temp2 := io.b
    io.carry := (temp1 + temp2) >> width
    io.res := (temp1 + temp2)
}

object Hello {
  
  def main(args: Array[String]) = {
    var test1="temp"
    println(test1)
    println("Hello world")
    println ((new ChiselStage).emitVerilog(new adder(4)))

    val works = Driver(() => new adder(4)) {
        a => new adder_test(a)
    }

    assert(works)
    println("SUCCESS!!")
  }
}

class adder_test(c: adder) extends PeekPokeTester(c)
{
    println("part I")
    poke (c.io.a , 15)
    poke (c.io.b , 1)
    expect (c.io.res, 0)
    expect (c.io.carry, 1)

    println("part II")
    poke (c.io.a , 13)
    poke (c.io.b , 1)
    expect (c.io.res, 14)
    expect (c.io.carry, 0)
}
