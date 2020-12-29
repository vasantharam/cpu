import chisel3._
import chisel3.util._
import chisel3.iotesters.{ChiselFlatSpec, Driver, PeekPokeTester}
import chisel3.stage.ChiselStage
import scala.util.matching.Regex
import java.io.File
import java.io.PrintWriter
import java.io._
import chisel3.util.experimental.loadMemoryFromFile
import scala.util.control.Breaks._
import scala.io.Source

class arbiter (num_ports: Int) extends Module
{
    val io = IO (new Bundle {
        val valid = Input(UInt(num_ports.W))
        val ready = Input(UInt(num_ports.W))
        val grant = Output(UInt(num_ports.W))
    })
    val cur_port = RegInit(UInt(num_ports.W), 0.U)
    if ((io.valid(cur_port)==1.U) && (io.ready(cur_port)==1.U)) 
    {
        io.grant(cur_port):=0.U
        cur_port := cur_port + 1.U;
    }
    if ((io.valid(cur_port)==1.U) && (io.grant(cur_port)==0.U))
    {
        io.grant(cur_port):=1.U;
    }


}

class main_ram(data_width:Int, addr_width:Int ) extends Module
{
    val io = IO(new Bundle {
        val write = Input(UInt(1.W))
        val addr = Input(UInt(addr_width.W))
        val din = Input(UInt(data_width.W))
        val dout = Output(UInt(data_width.W))
        val ena = Input(UInt(1.W))
    })

    val memFile = new File("mem.bin")
    val fileSize = memFile.length

    val mem = SyncReadMem(fileSize, UInt(data_width.W))
    loadMemoryFromFile(mem, "mem.bin")

    if ((io.ena==1.U) && (io.write==1.U))
    {
        mem.write(io.addr,  io.din)
    }
    if ((io.ena==1.U) && (io.write == 0.U))
    {
        io.dout := mem.read(io.addr, io.ena.toBool)
    }
}

class noc_blackbox(data_width: Int, addr_width:Int, num_ports: Int) extends BlackBox(Map("DATA_WIDTH_MSB" ->(data_width-1), "ADDR_WIDTH_MSB"->(addr_width-1), "NUM_PORTS" -> num_ports )) with HasBlackBoxResource
{
    addResource("/noc.v")
    val io = IO(new Bundle {
      val wr_port0_valid = Input(UInt(1.W))
      val wr_port1_valid = Input(UInt(1.W))
      val rd_port0_valid = Input(UInt(1.W))
      val rd_port1_valid = Input(UInt(1.W))
      val rd_port2_valid = Input(UInt(1.W))
      val rd_port3_valid = Input(UInt(1.W))

      val wr_port0_ready = Output(UInt(1.W))
      val wr_port1_ready = Output(UInt(1.W))
      val rd_port0_ready = Output(UInt(1.W))
      val rd_port1_ready = Output(UInt(1.W))
      val rd_port2_ready = Output(UInt(1.W))
      val rd_port3_ready = Output(UInt(1.W))

      val wr_port0_addr = Input(UInt(addr_width.W))
      val wr_port1_addr = Input(UInt(addr_width.W))
      val rd_port0_addr = Input(UInt(addr_width.W))
      val rd_port1_addr = Input(UInt(addr_width.W))
      val rd_port2_addr = Input(UInt(addr_width.W))
      val rd_port3_addr = Input(UInt(addr_width.W))

      val wr_port0_data = Input(UInt(data_width.W))
      val wr_port1_data = Input(UInt(data_width.W))
      val rd_port0_data = Output(UInt(data_width.W))
      val rd_port1_data = Output(UInt(data_width.W))
      val rd_port2_data = Output(UInt(data_width.W))
      val rd_port3_data = Output(UInt(data_width.W))
      val rst = Input(Bool())
      val clk = Input(Clock())
    })

}

class noc_blackbox_wrap(data_width:Int, addr_width:Int, num_wr_ports:Int, num_rd_ports:Int) extends Module
{
    val io = IO(new Bundle { 
        val wr_port_valid =Vec(num_wr_ports, Input(UInt(1.W)))
        val rd_port_valid =Vec(num_rd_ports, Input(UInt(1.W)))
        val wr_port_ready =Vec(num_wr_ports, Output(UInt(1.W)))
        val rd_port_ready =Vec(num_rd_ports, Output(UInt(1.W)))
        val wr_port_addr =Vec(num_wr_ports, Input(UInt(addr_width.W)))
        val rd_port_addr= Vec(num_rd_ports, Input(UInt(addr_width.W)))
        val wr_port_data= Vec(num_wr_ports, Input(UInt(data_width.W)))
        val rd_port_data= Vec(num_rd_ports, Output(UInt(data_width.W)))
    })
    val tb = Module(new noc_blackbox(data_width, addr_width, num_rd_ports+num_wr_ports))
    tb.io.rst := reset
    tb.io.clk := clock
    /* Inputs */
    //tb.io.<blah> = io.<blah>

      tb.io.wr_port0_valid := io.wr_port_valid(0) 
      tb.io.wr_port1_valid := io.wr_port_valid(1)
      tb.io.rd_port0_valid := io.rd_port_valid(0)
      tb.io.rd_port1_valid := io.rd_port_valid(1)
      tb.io.rd_port2_valid := io.rd_port_valid(2)
      tb.io.rd_port3_valid := io.rd_port_valid(3)


      tb.io.wr_port0_addr := io.wr_port_addr(0)
      tb.io.wr_port1_addr := io.wr_port_addr(1)
      tb.io.rd_port0_addr := io.rd_port_addr(0)
      tb.io.rd_port1_addr := io.rd_port_addr(1)
      tb.io.rd_port2_addr := io.rd_port_addr(2)
      tb.io.rd_port3_addr := io.rd_port_addr(3)

      tb.io.wr_port0_data := io.wr_port_data(0)
      tb.io.wr_port1_data := io.wr_port_data(1)
    /* Outputs */
    //io.<blah> = tb.io.<blah>
      io.wr_port_ready(0) :=  tb.io.wr_port0_ready 
      io.wr_port_ready(1) :=  tb.io.wr_port1_ready 
      io.rd_port_ready(0) :=  tb.io.rd_port0_ready 
      io.rd_port_ready(1) :=  tb.io.rd_port1_ready 
      io.rd_port_ready(2) :=  tb.io.rd_port2_ready 
      io.rd_port_ready(3) :=  tb.io.rd_port3_ready 

      io.rd_port_data(0) := tb.io.rd_port0_data
      io.rd_port_data(1) := tb.io.rd_port1_data
      io.rd_port_data(2) := tb.io.rd_port2_data
      io.rd_port_data(3) := tb.io.rd_port3_data
}
class noc_blackbox_tester(s: noc_blackbox_wrap, data_width: Int) extends PeekPokeTester(s)
{
    def write (port:UInt, addr:UInt, data:UInt): UInt = {
        poke (s.io.wr_port_valid(port), 1)
        poke (s.io.wr_port_addr(port), 0)
        poke (s.io.wr_port_data(port), 0xab)
        breakable { while(true)
        {
            step(1)
            val ready = peek(s.io.wr_port_ready(port))
            if (ready.U==1.U) break
        } }
        return 0.U
    }
    def read(port:UInt, addr:UInt) : UInt = 
    {
        poke (s.io.rd_port_valid(port), 1.U)
        poke (s.io.rd_port_addr(port), 0.U)
        step(1)
        breakable {while(true)
        {
            step(1)
            val ready = peek(s.io.rd_port_ready(port))
            if (ready.U == 1.U) break
        }}
        val read_data = peek(s.io.rd_port_data(port))
        
        return read_data.asUInt
 
    }
    // write same address through port0, read through port0 check data matches
    // TODO: loop it up with a rand for addr. 
    // randomize data pattern
    write(0.U, 0.U, 0xab.U) 
    var read_data = read(0.U, 0.U)
    assert(read_data == 0xab.U)

    // write through port1, read port2, check data matches
    write(1.U, 0.U, 0xec.U) 
    read_data = read(2.U, 0.U)
    assert(read_data == 0xec.U)
    // sweep write pattern, sweep read pattern check.
    //TBD
}

object blackbox
{
    def main(args: Array[String])
    {
        val lines = Source.fromResource("init_mem.coe").getLines() 
        val regex_key_val= new Regex("(.*)=(.*);")
        val regex_comma = new Regex("(.*),")
        val regex_key_only = new Regex(".*=$")
        val i: String = ""
        var A : Map[String, String] = Map()
        var arr : Array[BigInt] = Array[BigInt](0)
        for (i <- lines)
        {
            val res_key_value = regex_key_val findAllIn i
            val res_comma = regex_comma findAllIn i
            val res_key_only = regex_key_only findAllIn i
            if (res_key_value.length == 1)
            {
                val iter = res_key_value
                val match_data = iter.matchData
                assert (match_data.length == 1) 
                val res=match_data.next()
                A = A + ( res.group(1) -> res.group(2))
            }
            if (res_comma.length == 1)
            {
                val iter = res_comma
                val match_data = iter.matchData
                assert (match_data.length == 1) 
                val res=match_data.next()
                arr :+ Integer.parseInt(res.group(1),A("memory_initialization_radix").toInt)
            }
        }
        var out = None: Option[FileOutputStream]
        try 
        {
            out = Some(new FileOutputStream("mem.bin"))
            arr.foreach 
            {
                a => out.get.write(a.toShort)
            }
        }
        catch
        {
            case e: IOException => e.printStackTrace
        }
        finally
        {
            if(out.isDefined) out.get.close
        }

        println("BlackBox Hello World")
        val data_width:Int = 16
        val addr_width:Int=16
        val num_rd_ports:Int = 16
        val num_wr_ports:Int=16
        val works = chisel3.iotesters.Driver ( () => new noc_blackbox_wrap(data_width,addr_width,num_rd_ports,num_wr_ports), "verilator") {
            c=> new noc_blackbox_tester(c, data_width)
        }
        assert(works)
        println("Success!!")
    }
}