import chisel3._
import chisel3.util._
import chisel3.iotesters.{ChiselFlatSpec, Driver, PeekPokeTester, TesterOptionsManager }
import chisel3.stage.{ChiselStage,ChiselGeneratorAnnotation}
import scala.util.matching.Regex
import java.io.File
import java.io.PrintWriter
import java.io._
import chisel3.util.experimental.loadMemoryFromFile
import scala.util.control.Breaks._
import scala.io.Source
import java.nio.file.Path
import scala.math._
import java.io.{File, FileWriter, IOException, Writer}
import java.nio.file.{FileAlreadyExistsException, Files, Paths}
import java.nio.file.StandardCopyOption.REPLACE_EXISTING
import scala.util.DynamicVariable

class arbiter (num_ports: Int) extends Module
{
    val io = IO (new Bundle {
        val valid = Input(UInt(num_ports.W))
        val ready = Input(UInt(num_ports.W))
        val grant = Output(UInt(num_ports.W))
    })
    def clog2(x: Int): Int = { require(x > 0); ceil(log(x)/log(2)).toInt }
    var cur_port = RegInit(UInt(clog2(num_ports).W), 0.U)
    var rGrant = RegInit(UInt(num_ports.W), 0.U)
    when ( io.valid(cur_port) === 1.U)
    {
            when (io.ready(cur_port) === 1.U)
            {
                rGrant:=0.U
                when (cur_port === num_ports.U)
                {
                    cur_port:=0.U
                }.otherwise
                {
                    cur_port := cur_port + 1.U;
                }
            }
            when (io.grant(cur_port) === 0.U)
            {
                rGrant:=0.U
                rGrant:= rGrant | 1.U << (cur_port)
            }
        
    }.otherwise
    {
            when (cur_port === num_ports.U)
            {
                cur_port:=0.U
            }.otherwise
            {
                cur_port := cur_port + 1.U;
            }
    }

    io.grant:=rGrant;

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
    println("fileSize = ", fileSize)

    val mem = SyncReadMem(fileSize, UInt(data_width.W))
    loadMemoryFromFile(mem, "mem.bin")
  
    /* What is a cleaner way to assign dout on all paths? */
    when (io.ena===1.U)
    {
    
        when (io.write === 1.U) {mem.write(io.addr,  io.din); io.dout:=DontCare } .otherwise {
        when (io.write === 0.U) 
        {
            io.dout:=mem.read(io.addr)
        }.otherwise {io.dout:=DontCare}
        }

     
    }.otherwise {
    
        io.dout:=0.U(data_width.W)
    }
    
}

class noc(data_width: Int, addr_width:Int, num_ports: Int) extends BlackBox(Map("DATA_WIDTH_MSB" ->(data_width-1), "ADDR_WIDTH_MSB"->(addr_width-1), "NUM_PORTS" -> num_ports )) with HasBlackBoxResource
{
    addResource("/noc.v")
    addResource("/noc_defs.vh")
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

class noc_blackbox_wrap(data_width:Int, addr_width:Int, num_rd_ports:Int, num_wr_ports:Int) extends Module
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
    val tb = Module(new noc(data_width, addr_width, num_rd_ports+num_wr_ports))
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
class main_ram_tester(s: main_ram, data_width:Int, addr_width:Int) extends PeekPokeTester(s)
{
}

class arbiter_tester(s: arbiter, num_ports:Int ) extends PeekPokeTester(s)
{
}

class noc_blackbox_tester(s: noc_blackbox_wrap, data_width: Int, num_rd_ports:Int, num_wr_ports:Int) extends PeekPokeTester(s)
{
<<<<<<< HEAD
    def write (port:Int, addr:UInt, data:UInt): UInt = {
        var wr_port_valid = Array (peek (s.io.wr_port_valid(0)), peek(s.io.wr_port_valid(1)) )
        wr_port_valid(port) = 1
        poke (s.io.wr_port_valid, wr_port_valid)
//        poke (s.io.wr_port_addr(port), 0)
//        poke (s.io.wr_port_data(port), 0xab)
=======
    def write (port:UInt, addr:UInt, data:UInt): UInt = {
        var vec_wr_port_valid = Array.tabulate(num_wr_ports) { x=>if (port.litValue==BigInt(x)) {println(s"${x.U} ${port} - x");BigInt(1)} else {println(s"${x.U}- x ${port}"); BigInt(0)} }
        println(s"scala array to poke into vector    ${vec_wr_port_valid.mkString(",")} ${vec_wr_port_valid} ${port}")

        poke (s.io.wr_port_valid, vec_wr_port_valid)
        var vec_wr_port_addr = Array.tabulate(num_wr_ports) { x=> BigInt(0) }
        poke (s.io.wr_port_addr, vec_wr_port_addr)
        var vec_wr_port_data = Array.tabulate(num_wr_ports) { x=> BigInt(0xab) }
        poke (s.io.wr_port_data, vec_wr_port_data)
>>>>>>> 95166fa4a80a95bb02f39a1d746976edb5983d7b
        breakable { while(true)
        {
            step(1)
            var ready = peek(s.io.wr_port_ready)
            println(s"${ready.mkString(",")} - ready")
//            if (ready(port).U==1.U) break
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
    write(0, 0.U, 0xab.U) 
//    var read_data = read(0.U, 0.U)
//    assert(read_data == 0xab.U)

    // write through port1, read port2, check data matches
    write(1, 0.U, 0xec.U) 
//    read_data = read(2.U, 0.U)
//    assert(read_data == 0xec.U)
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
            println (res_key_value);
            if (res_key_value.hasNext)
            {
                val match_data = res_key_value
                
                if (match_data.hasNext == true)
                {
                    val all=match_data.next()
                    println("key is " + all + "group1" + match_data.group(1) + "group2" + match_data.group(2));
                    //assert(match_data.hasNext)
                    val key = match_data.group(1)
                    val value=match_data.group(2)

                    
                    A = A + ( key -> value)
                }
            }
            if (res_comma.hasNext)
            {
                val match_data = res_comma
                val res=match_data.next()
                arr :+ Integer.parseInt(match_data.group(1), A("memory_initialization_radix").toInt)
            }
        }
        var out = None: Option[FileOutputStream]
        var addr:Int = 0;
        var data:Int = 0;
        try 
        {
            out = Some(new FileOutputStream("mem.bin"))
            out.get.write("@%d\n".format(addr).getBytes())
            arr.foreach 
            {
                 
                a => 
                {
                    data = a.toShort
                    out.get.write("%d\n".format(data).getBytes())
                    addr = addr + 1
                }
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
        val optionsManagerVar = new DynamicVariable[Option[TesterOptionsManager]](None)

        def optionsManager = optionsManagerVar.value.getOrElse(new TesterOptionsManager)


        println("BlackBox Hello World")
        val data_width:Int = 16
        val addr_width:Int=16
        val num_rd_ports:Int = 4
        val num_wr_ports:Int=2
       
        /*(new chisel3.stage.ChiselStage).execute(
            Array("-X", "verilog"),
            Seq(ChiselGeneratorAnnotation(() => new main_ram(data_width,addr_width ))))
        (new chisel3.stage.ChiselStage).execute(
            Array("-X", "verilog"),
            Seq(ChiselGeneratorAnnotation(() => new arbiter(num_rd_ports+num_wr_ports))))
        println( (new ChiselStage).emitVerilog( new main_ram(data_width, addr_width  )) ) 
        println( (new ChiselStage).emitVerilog( new arbiter(num_rd_ports+num_wr_ports)) )  */
<<<<<<< HEAD
        val main_ram_works = chisel3.iotesters.Driver.execute(Array("--top-name","cpu", "--target-dir", "cpu",  "--backend-name", "verilator"), () => new main_ram(data_width,addr_width)  ) {
            c=> new main_ram_tester(c, data_width, addr_width)
        }

        val arbiter_works = chisel3.iotesters.Driver.execute (Array("--top-name","cpu"    , "--target-dir", "cpu",  "--backend-name", "verilator"), () => new arbiter(num_rd_ports+num_wr_ports)) {
            c=> new arbiter_tester(c, num_rd_ports + num_wr_ports)
        }

        val noc_works = chisel3.iotesters.Driver.execute (Array("--top-name","cpu"        , "--target-dir", "cpu",  "--backend-name", "verilator"), () => new noc_blackbox_wrap(data_width,addr_width,num_rd_ports,num_wr_ports) ) {
            c=> new noc_blackbox_tester(c, data_width)
=======
        val main_ram_works = chisel3.iotesters.Driver.execute(Array("--top-name","cpu", "--target-dir", "cpu_run_dir",  "--backend-name", "verilator"), () => new main_ram(data_width,addr_width)  ) {
            c=> new main_ram_tester(c, data_width, addr_width)
        }

        val arbiter_works = chisel3.iotesters.Driver.execute (Array("--top-name","cpu"    , "--target-dir", "cpu_run_dir",  "--backend-name", "verilator"), () => new arbiter(num_rd_ports+num_wr_ports)) {
            c=> new arbiter_tester(c, num_rd_ports + num_wr_ports)
        }

        val noc_works = chisel3.iotesters.Driver.execute (Array("--top-name","cpu"        , "--target-dir", "cpu_run_dir",  "--backend-name", "verilator"), () => new noc_blackbox_wrap(data_width,addr_width,num_rd_ports,num_wr_ports) ) {
            c=> new noc_blackbox_tester(c, data_width, num_rd_ports,num_wr_ports)
>>>>>>> 95166fa4a80a95bb02f39a1d746976edb5983d7b
        }
        assert(noc_works && arbiter_works && main_ram_works)
        println("Success!!")
    }
}
