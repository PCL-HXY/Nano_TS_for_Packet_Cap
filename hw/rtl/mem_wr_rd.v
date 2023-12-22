
`timescale 1 ns / 1ps

module mem_wr_rd (
  // clock and resets
  input wire           clk,  
  input wire           rst,    //dsp  high-reset

   
  // AXI master data interface to DDR memory

  output  reg [3 : 0] m_axi_awid, //dsp  07/01 
  output  reg [63 : 0]   m_axi_awaddr,  //dsp  07/01
  
  // output reg [32:0]   m_axi_awaddr,  //dsp  07/01
  output reg [7:0]    m_axi_awlen,
  output reg [2:0]    m_axi_awsize,
  output reg [1:0]    m_axi_awburst,
  output reg          m_axi_awlock,
  output reg [3:0]    m_axi_awcache,
  output reg [2:0]    m_axi_awprot,
 // output reg [3:0]    m_axi_awqos,  //dsp  07/01
  output reg          m_axi_awvalid,
  input wire          m_axi_awready,
  output reg [511:0]  m_axi_wdata,
  output reg [63:0]   m_axi_wstrb,
  output reg          m_axi_wlast,
  output reg          m_axi_wvalid,
  input wire          m_axi_wready,

  input wire[3 : 0]      m_axi_bid ,  //dsp  07/02
  
  output reg          m_axi_bready,

  output  reg[3 : 0]     m_axi_arid ,  //dsp  07/01
  
  input wire [1:0]    m_axi_bresp,
  input wire          m_axi_bvalid,


  output  reg[63 : 0]    m_axi_araddr ,  //dsp  07/01
//output reg [32:0]      m_axi_araddr,   //dsp  07/01


  
  output reg [7:0]    m_axi_arlen,
  output reg [2:0]    m_axi_arsize,
  output reg [1:0]    m_axi_arburst,
  output reg          m_axi_arlock,
  output reg [3:0]    m_axi_arcache,
  output reg [2:0]    m_axi_arprot,

  output reg          m_axi_arvalid,
  input wire          m_axi_arready,

  input wire[3 : 0]   m_axi_rid ,    
  output reg          m_axi_rready,
  input wire [511:0]  m_axi_rdata,
  input wire [1:0]    m_axi_rresp,
  input wire          m_axi_rlast,
  input wire          m_axi_rvalid,

  // input FIFO signals
  input wire [511:0]  fifo_dout_i,
  input wire          fifo_empty_i,
  input wire          fifo_prog_empty_i,
  input wire [10:0]   fifo_rd_data_count_i,
  output reg          fifo_rd_en_o,

  // ring buffer address and size

  // 32'hFFFFFFFF---- 4GB 
  // 32'h7FFFFFFF---- 2GB
  input wire [63:0]   mem_range_i,  

  // ring buffer read and write pointers
  output reg [63:0]   addr_wr_o,
//input wire  [31:0]  addr_rd_i,  //dsp  06/28

  // activation signals
  //  initcomplete  signal  can connect  to  active_i;   dsp
  input wire          active_i,    //should  be  high   dsp
  
    //dsp  06/28
    input wire          flush_i,   // high ---50ms no data input 
    input wire          align_done_i, //when high then can write 
    output reg        flush_done_o,
    
    //tx 
    output reg[511:0]  fifo_din,
    output reg  fifo_wr_en,
    input wire fifo_prog_full,
    
    input   wire        [31:0]      ctrl_addr_wr,//tx wr 0514dsp
    
//    output reg  [31:0]   		rd_ms,
    output reg  [31:0]   		wr_ms ,
    
    output reg  [31:0]   		test_cnt       
 
);

  // assemble ring buffer memory address
  wire [63:0] mem_addr;
  assign mem_addr = 64'b0;

  // calculate ring buffer memory size
  wire [63:0] mem_size;
  assign mem_size = mem_range_i + 1'b1;  

always @(posedge rst or posedge clk)
 begin
    if(rst || !active_i)
        wr_ms <= 32'h0;
    else
        wr_ms <= {5'b0,addr_wr_o[32:6]};
 end
    
 parameter  ctrl_mem_addr = 64'h100000000;        
 parameter  ctrl_mem_range = 64'hFFFFFFFF;     //4G-1
 
 wire [63:0] ctrl_mem_size;
 assign ctrl_mem_size = ctrl_mem_range+ 64'b1;//Byte


reg                            test_en_r1              ;
reg                            test_en_r2              ;


reg [31:0]  ctrl_addr_wr_i;
reg [31:0]  ctrl_addr_rd_o;

 always @(posedge clk) begin
 test_en_r1 <= active_i;
 test_en_r2 <= test_en_r1;
 end

    
  // FSM states rx
  parameter   RST             = 3'b000,
              INACTIVE        = 3'b001,
              START           = 3'b010,
              WAIT_RING_BUFF  = 3'b011,
              WAIT_FIFO       = 3'b100,
              WRITE_REQ       = 3'b101,
              WRITE           = 3'b110,
              WAIT_WRITE_RESP = 3'b111;

  reg [2:0]   state, nxt_state;
  reg [63:0]  nxt_m_axi_awaddr;  //dsp  07/01

  
  reg         nxt_m_axi_awvalid;
  reg [7:0]   nxt_m_axi_awlen;
  reg         nxt_m_axi_wvalid;
  reg [7:0]   beats_cntr, nxt_beats_cntr;
  reg [63:0]  nxt_addr_wr;
 

  // FSM
  always @(posedge clk) begin
      if (rst )   //dsp
    begin
      state <= RST;
    end else begin
      state <= nxt_state;
    end

    m_axi_awid      <= 4'd0 ;  //dsp  07/01

    m_axi_awaddr <= nxt_m_axi_awaddr;
    m_axi_awlen <= nxt_m_axi_awlen;
    m_axi_awvalid <= nxt_m_axi_awvalid;
    m_axi_wvalid <= nxt_m_axi_wvalid;
    m_axi_wstrb <= 64'hFFFFFFFFFFFFFFFF; // always full 64 byte words
    m_axi_awsize <= 3'h6; // 64 bytes per beat
    m_axi_awburst <= 2'b01; // incrementing address burst
    m_axi_bready <= 1'b1; // always ready to receive responses
    m_axi_awlock <= 1'b0; // not used
    m_axi_awcache <= 4'b0011; // Xilinx recommend
    m_axi_awprot <= 3'b0; // not used
 // m_axi_awqos <= 4'b0; // not used   //dsp   07/01

    beats_cntr <= nxt_beats_cntr;
    addr_wr_o <= nxt_addr_wr;
  
  end

  // FSM
  always @(*) begin
    nxt_state = state;
    nxt_m_axi_awaddr = m_axi_awaddr;
    nxt_m_axi_awlen = m_axi_awlen;
    nxt_m_axi_awvalid = 1'b0;
    nxt_m_axi_wvalid = 1'b0;
    nxt_beats_cntr = beats_cntr;
    nxt_addr_wr = addr_wr_o;
   

    case (state)

      RST: begin
        // reset write address pointer
        nxt_addr_wr = 32'b0;

        // go to inactive state
        nxt_state = INACTIVE;
      end

      INACTIVE: begin
         // initialize AXI4 write address to memory region start address
        nxt_m_axi_awaddr = mem_addr;

        // reset write pointer
        nxt_addr_wr = 32'b0;
        if (active_i) begin
          // module has been activated
          nxt_state = START; 
          
        end else  begin
        
          nxt_state = INACTIVE;
        end
      end

      START: begin
        // initialize AXI4 write address to memory region start address
        nxt_m_axi_awaddr = mem_addr;

        // reset write pointer
        nxt_addr_wr = 32'b0;

        // go to state waiting for suffient ring buffer space to become
        // available
        nxt_state = WAIT_RING_BUFF;
      end

      WAIT_RING_BUFF: begin
        // in this state we wait for sufficient ring öbuffer space to become
        // available

        if (~active_i) begin        
          // module has been activated. go to idle state
          nxt_state = INACTIVE;
        end

        else 

         begin

            // if(~fifo_prog_empty_i )
             if(~fifo_prog_empty_i || flush_i)
                  nxt_state = WAIT_FIFO;
             else
                  nxt_state = WAIT_RING_BUFF;   //dsp  06/28     
           end
            

        
      end

      WAIT_FIFO: begin
        // to maximize axi throughput, we only write data from the FIFO to the
        // ring buffer in memory if we can fill an entire 256 beat burst.
        // However, since the incoming data may not be a multiple of 256x 512
        // bit, we perform one last write, which may have a shorter burst
        // length, when the 'flush' signal is asserted.

        // calculate burst size
       
      //  nxt_m_axi_awlen =
       //    ~fifo_prog_empty_i ? 8'hFF : (fifo_rd_data_count_i - 1);
       if(~fifo_prog_empty_i)
       begin
            if(((mem_size - m_axi_awaddr)>>6) >= 'd256)
            begin
                nxt_m_axi_awlen = 8'hFF;
            end else begin
                nxt_m_axi_awlen =  ((mem_size - m_axi_awaddr)>>6) - 1;
            end
        end else begin
            nxt_m_axi_awlen = 
            fifo_rd_data_count_i <= ((mem_size - m_axi_awaddr)>>6) ? (fifo_rd_data_count_i - 1) : (((mem_size - m_axi_awaddr)>>6) - 1);
        end
       // if(~active_i ) 
        if(~active_i & ~flush_i) 
            // module is inactive. return to INACTIVE state
            nxt_state = INACTIVE;   //active  0  and  flush  0;  dsp  07/08
        else if (active_i) 
        begin
                  // module is active. to maximize axi throughput, we only write data
                  // from the FIFO to the ring buffer if we can fill an entire 256 beat
                  // AXI burst (256x 64 byte = 16kByte). If there are more than 256 64
                  // byte entries in the FIFO, the fifo_prog_empty_i input signal is
                  // deasserted.
            if(~fifo_prog_empty_i) 
                    // at least 256 entries in the FIFO
               nxt_state = WRITE_REQ;
            else if (flush_i) 
            begin
                 if (fifo_prog_empty_i & ~fifo_empty_i) 
                 begin
                    // there are less than 256 entries in the FIFO (but FIFO is not
                    // empty
                    //wait till align done 
                        if(align_done_i) 
                        begin
                            nxt_state = WRITE_REQ;
                            if(nxt_m_axi_awlen == (fifo_rd_data_count_i - 1))
                            begin
                                flush_done_o = 1'b1;
                            end
                        end
                        else 
                            nxt_state = WAIT_FIFO;
                  end
             end
         end 
                else 
                    // nothing to be flushed, go back to inactive state
                    nxt_state = INACTIVE;
      end
              
      WRITE_REQ: begin
        // in this state we issue the AXI4 write request and wait for it to be
        // acknowledged by the memory controller

        if (m_axi_awvalid & m_axi_awready) begin
          // write request has been recognized
          nxt_state = WRITE;

          // reset burst beat counter
          nxt_beats_cntr = 8'b0;
        end else begin
          // request still pending
          nxt_m_axi_awvalid = 1'b1;
        end
      end

      WRITE: begin
        // in this state the data is read from the FIFO and written to the
        // memory

        if (m_axi_wvalid & m_axi_wready) begin
          // data word has been transfered

          // increment beats counter
          nxt_beats_cntr = beats_cntr + 1;

          // increment write address
          if (m_axi_awaddr == (mem_addr + mem_size - 'h40)) begin
            // wrap around
            nxt_m_axi_awaddr = mem_addr;
          end else begin
            nxt_m_axi_awaddr = m_axi_awaddr + 'h40;
          end

          if (beats_cntr == m_axi_awlen) begin
            // all beats of the burst have been written
            nxt_state = WAIT_WRITE_RESP;
            flush_done_o = 1'b0;
          end else begin
            // more beats to be written
            nxt_m_axi_wvalid = 1'b1;
          end
        end else begin
          // no data transfer active, keep wvalid high
          nxt_m_axi_wvalid = 1'b1;
        end
      end

      WAIT_WRITE_RESP: begin
        // wait for AXI4 write knowledgement. for now we don't do any error
        // checking here
        if (m_axi_bvalid) begin
          nxt_state = WAIT_RING_BUFF;

          // update write pointer
          if ((addr_wr_o + ((m_axi_awlen + 1) << 6)) >= mem_size) begin
            nxt_addr_wr = 0;
          end else begin
            nxt_addr_wr = addr_wr_o + ((m_axi_awlen + 1) << 6);
          end
        end
      end

    endcase
  end

  // FIFO read enable and AXI4 WDATA + WLAST signals
  always @(*) begin
    fifo_rd_en_o = m_axi_wvalid & m_axi_wready;
    
    m_axi_wdata = {fifo_dout_i[7:0], fifo_dout_i[15:8], fifo_dout_i[23:16], fifo_dout_i[31:24],
                  fifo_dout_i[39:32], fifo_dout_i[47:40], fifo_dout_i[55:48], fifo_dout_i[63:56],
                  fifo_dout_i[71:64], fifo_dout_i[79:72], fifo_dout_i[87:80], fifo_dout_i[95:88],
                  fifo_dout_i[103:96], fifo_dout_i[111:104], fifo_dout_i[119:112], fifo_dout_i[127:120],
                  fifo_dout_i[135:128], fifo_dout_i[143:136], fifo_dout_i[151:144], fifo_dout_i[159:152],
                  fifo_dout_i[167:160], fifo_dout_i[175:168], fifo_dout_i[183:176], fifo_dout_i[191:184],
                  fifo_dout_i[199:192], fifo_dout_i[207:200], fifo_dout_i[215:208], fifo_dout_i[223:216],
                  fifo_dout_i[231:224], fifo_dout_i[239:232], fifo_dout_i[247:240], fifo_dout_i[255:248],
                  fifo_dout_i[263:256], fifo_dout_i[271:264], fifo_dout_i[279:272], fifo_dout_i[287:280],
                  fifo_dout_i[295:288], fifo_dout_i[303:296], fifo_dout_i[311:304], fifo_dout_i[319:312],
                  fifo_dout_i[327:320], fifo_dout_i[335:328], fifo_dout_i[343:336], fifo_dout_i[351:344],
                  fifo_dout_i[359:352], fifo_dout_i[367:360], fifo_dout_i[375:368], fifo_dout_i[383:376],
                  fifo_dout_i[391:384], fifo_dout_i[399:392], fifo_dout_i[407:400], fifo_dout_i[415:408],
                  fifo_dout_i[423:416], fifo_dout_i[431:424], fifo_dout_i[439:432], fifo_dout_i[447:440],
                  fifo_dout_i[455:448], fifo_dout_i[463:456], fifo_dout_i[471:464], fifo_dout_i[479:472],
                  fifo_dout_i[487:480], fifo_dout_i[495:488], fifo_dout_i[503:496], fifo_dout_i[511:504]};  

    // assert WLAST if burst beat counter reached burst size
    m_axi_wlast = (beats_cntr == m_axi_awlen);
  end

// FSM states tx
  parameter IDLE = 3'b000,
            WAIT = 3'b001,
            REQ  = 3'b010,
            READ = 3'b011,
            FINI  = 3'b100;

     
  reg [2:0]   tx_state, tx_nxt_state;
  reg [63:0]  nxt_m_axi_araddr;
  reg [7:0]   nxt_m_axi_arlen;
  reg         nxt_m_axi_arvalid;
  reg [63:0]  read_byte_cntr, nxt_read_byte_cntr;
  reg [31:0]  nxt_ctrl_addr_rd;

  // FSM
  always @(posedge clk) begin
    if (rst) begin
      tx_state <= IDLE;
    end else begin
      tx_state <= tx_nxt_state;
    end

    // fixed read signals
    m_axi_arid      <= 4'd0  ;
    m_axi_arsize <= 4'h6; // 64 bytes per burst beat
    m_axi_arburst <= 2'b01; // incrementing address burst
    m_axi_arlock <= 1'b0;
    m_axi_arcache <= 4'b0011; // Xilinx recommend
    m_axi_arprot <= 3'b0;

    // always gladly accepting data! we only issue read requests when space in
    // FIFO to store entire burst is available
    m_axi_rready <= 1'b1;

    m_axi_araddr <= nxt_m_axi_araddr;
    m_axi_arlen <= nxt_m_axi_arlen;
    m_axi_arvalid <= nxt_m_axi_arvalid;
    fifo_wr_en <= m_axi_rvalid;
    read_byte_cntr <= nxt_read_byte_cntr;
    ctrl_addr_rd_o <= nxt_ctrl_addr_rd;
    
    ctrl_addr_wr_i  <=  ctrl_addr_wr[31:0]; 

    // reverse order of 64 bit words before writing data to fifo
    fifo_din <={m_axi_rdata[7:0], m_axi_rdata[15:8], m_axi_rdata[23:16], m_axi_rdata[31:24],
                m_axi_rdata[39:32], m_axi_rdata[47:40], m_axi_rdata[55:48], m_axi_rdata[63:56],
                m_axi_rdata[71:64], m_axi_rdata[79:72], m_axi_rdata[87:80], m_axi_rdata[95:88],
                m_axi_rdata[103:96], m_axi_rdata[111:104], m_axi_rdata[119:112], m_axi_rdata[127:120],
                m_axi_rdata[135:128], m_axi_rdata[143:136], m_axi_rdata[151:144], m_axi_rdata[159:152],
                m_axi_rdata[167:160], m_axi_rdata[175:168], m_axi_rdata[183:176], m_axi_rdata[191:184],
                m_axi_rdata[199:192], m_axi_rdata[207:200], m_axi_rdata[215:208], m_axi_rdata[223:216],
                m_axi_rdata[231:224], m_axi_rdata[239:232], m_axi_rdata[247:240], m_axi_rdata[255:248],
                m_axi_rdata[263:256], m_axi_rdata[271:264], m_axi_rdata[279:272], m_axi_rdata[287:280],
                m_axi_rdata[295:288], m_axi_rdata[303:296], m_axi_rdata[311:304], m_axi_rdata[319:312],
                m_axi_rdata[327:320], m_axi_rdata[335:328], m_axi_rdata[343:336], m_axi_rdata[351:344],
                m_axi_rdata[359:352], m_axi_rdata[367:360], m_axi_rdata[375:368], m_axi_rdata[383:376],
                m_axi_rdata[391:384], m_axi_rdata[399:392], m_axi_rdata[407:400], m_axi_rdata[415:408],
                m_axi_rdata[423:416], m_axi_rdata[431:424], m_axi_rdata[439:432], m_axi_rdata[447:440],
                m_axi_rdata[455:448], m_axi_rdata[463:456], m_axi_rdata[471:464], m_axi_rdata[479:472],
                m_axi_rdata[487:480], m_axi_rdata[495:488], m_axi_rdata[503:496], m_axi_rdata[511:504]}; 
                                           
                                           
  end

  always @(*) begin
    tx_nxt_state = tx_state;
    nxt_m_axi_araddr = m_axi_araddr;
    nxt_m_axi_arlen = m_axi_arlen;
    nxt_m_axi_arvalid = 1'b0;
    nxt_read_byte_cntr = read_byte_cntr;
    nxt_ctrl_addr_rd = ctrl_addr_rd_o;
    

    case (tx_state)

      IDLE: begin
        if ( test_en_r2 ) begin
          // start signal triggered -> go to next state
          tx_nxt_state = WAIT;
        end

        // init axi read address to memory region start address
        nxt_m_axi_araddr = ctrl_mem_addr;
        nxt_read_byte_cntr = 64'b0; // reset read byte counter
        nxt_ctrl_addr_rd = 32'b0; // reset read pointer
    //    test_done = 1'b0;
      end

      WAIT: begin
        if (!fifo_prog_full) 
        begin
          if (ctrl_addr_wr_i > ctrl_addr_rd_o) 
          begin
            if ((ctrl_addr_wr_i - ctrl_addr_rd_o) >= 'h4000) 
            begin
              tx_nxt_state = REQ;
              nxt_m_axi_arlen = 8'hFF;
              nxt_m_axi_arvalid = 1'b1;
            end                           
            else 
            begin
              tx_nxt_state = REQ;
              nxt_m_axi_arlen =  ((ctrl_addr_wr_i - ctrl_addr_rd_o) >> 6) - 1'b1;
              nxt_m_axi_arvalid = 1'b1;
            end 
          end 
          else
          begin   
            if ((ctrl_mem_size - ctrl_addr_rd_o) >= 'h4000) 
            begin
              tx_nxt_state = REQ;
              nxt_m_axi_arlen = 8'hFF;
              nxt_m_axi_arvalid = 1'b1;
            end
            else
            begin
              tx_nxt_state = REQ;
              nxt_m_axi_arlen = ((ctrl_mem_size - ctrl_addr_rd_o) >> 6) - 1'b1;
              nxt_m_axi_arvalid = 1'b1;
            end 
          end
        end 
      end

      REQ: begin
        if (m_axi_arvalid & m_axi_arready) begin
          // read request has been recongnized by the slave
          tx_nxt_state = READ;
        end else begin
          // read request still pending, leave arvalid high
          nxt_m_axi_arvalid = 1'b1;
        end
      end

      READ: begin
        if (m_axi_rvalid) begin
          // received a 64 byte data word
          nxt_read_byte_cntr = read_byte_cntr + 'h40;

          // increment read pointer
          if (ctrl_addr_rd_o == (ctrl_mem_size - 'h40)) begin
            // wrap around
            nxt_ctrl_addr_rd = 32'b0;
          end else begin
            nxt_ctrl_addr_rd = ctrl_addr_rd_o + 'h40;
          end

          // increment memory read address
          if (m_axi_araddr == (ctrl_mem_addr + ctrl_mem_size - 'h40)) begin
            // wrap around
            nxt_m_axi_araddr = ctrl_mem_addr;
          end else begin
            nxt_m_axi_araddr = m_axi_araddr + 'h40;
          end

          if (m_axi_rlast) begin
              tx_nxt_state = WAIT;
            end
    //      end
        end
      end
/*
    FINI: begin
    nxt_state = FINI;
    test_done = 1'b1;
    end
*/
    endcase
  end


      always @(posedge rst or posedge clk)
   begin
      if(rst)
          test_cnt <= 32'h0;
      else
          test_cnt <= {6'b0,ctrl_addr_rd_o[31:6]};
   end


endmodule
