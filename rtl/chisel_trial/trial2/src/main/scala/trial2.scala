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

object trial2
{
    def main(args: Array[String])
    {
        println ("trial2 hello")
        println( (new ChiselStage).emitVerilog( new seq_block(12)) ) 
    }
}
