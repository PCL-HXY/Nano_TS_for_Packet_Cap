
module top_user
(

  
  input  wire                  sys_rst_n              ,
  input  wire                  sys_rst                ,                                                     
  input  wire                  clk50m                 ,
  input  wire                  clk100m                ,
  input  wire                  clk200m                ,
  input  wire                  clk300m                ,
  input  wire                  clk400m                , 
  output wire                  clk156,

  
  input  wire                  los0                   , 
  input  wire                  present0               , 
  input  wire                  los1                   , 
  input  wire                  present1               , 
                                                      
  output wire                  act0                   ,
  output wire                  act1                   ,
  output wire                  link0                  ,
  output wire                  link1                  ,
	
  input  wire                  pcie_aclk              ,
  input  wire                  pcie_aresetn           ,
  input  wire                  pcie_link_up           ,
  input  wire   [15:0]         test_irq_req           ,
  output wire   [15:0]         test_irq_clr           , 
  output wire   [15:0]         usr_irq_req            ,
  input  wire   [15:0]         usr_irq_ack            , 
  
  input  wire                  fiber0_refclk_p        ,
  input  wire                  fiber0_refclk_n        ,
  input  wire                  fiber1_refclk_p        ,
  input  wire                  fiber1_refclk_n        ,
                                                       
  input  wire  [0:0]           fiber_tsc0_rdp         , 
  input  wire  [0:0]           fiber_tsc0_rdn         ,
  output wire  [0:0]           fiber_tsc0_tdp         ,
  output wire  [0:0]           fiber_tsc0_tdn         ,
  input  wire  [0:0]           fiber_tsc1_rdp         ,
  input  wire  [0:0]           fiber_tsc1_rdn         ,
  output wire  [0:0]           fiber_tsc1_tdp         ,
  output wire  [0:0]           fiber_tsc1_tdn         ,


  output  wire                 ETH0_LINK             ,
  output  wire                 ETH1_LINK             ,
           
  input wire                   ETH0_RxEN             ,
  input wire                   ETH1_RxEN             ,
  input wire                   ETH2_RxEN             ,
  input wire                   ETH3_RxEN             ,
  input wire                   ETH4_RxEN             ,
  input wire                   ETH5_RxEN             ,
  input wire                   ETH6_RxEN             ,
  input wire                   ETH7_RxEN             ,
           
  input wire                   ETH0_TxEN             ,
  input wire                   ETH1_TxEN             ,
  input wire                   ETH2_TxEN             ,
  input wire                   ETH3_TxEN             ,
  input wire                   ETH4_TxEN             ,
  input wire                   ETH5_TxEN             ,
  input wire                   ETH6_TxEN             ,
  input wire                   ETH7_TxEN             ,
           
  input wire [1 : 0]           ETH0_LOOP             ,
  input wire [1 : 0]           ETH1_LOOP             ,
  input wire [1 : 0]           ETH2_LOOP             ,
  input wire [1 : 0]           ETH3_LOOP             ,
  input wire [1 : 0]           ETH4_LOOP             ,
  input wire [1 : 0]           ETH5_LOOP             ,
  input wire [1 : 0]           ETH6_LOOP             ,
  input wire [1 : 0]           ETH7_LOOP             ,
    
  input  wire                  c0_init_calib_complete , 
  input  wire                  c0_ddr4_ui_clk         ,
  input  wire                  c0_ddr4_ui_clk_sync_rst,  
  input  wire                  c1_init_calib_complete , 
  input  wire                  c1_ddr4_ui_clk         ,
  input  wire                  c1_ddr4_ui_clk_sync_rst,  
  input  wire                  c2_init_calib_complete , 
  input  wire                  c2_ddr4_ui_clk         ,
  input  wire                  c2_ddr4_ui_clk_sync_rst,
  input  wire                  c3_init_calib_complete , 
  input  wire                  c3_ddr4_ui_clk         ,
  input  wire                  c3_ddr4_ui_clk_sync_rst,
                                                        
  input  wire      [31 : 0]      s_axil_dynamic_awaddr   ,      
  input  wire      [2 : 0]       s_axil_dynamic_awprot   ,
  input  wire                    s_axil_dynamic_awvalid  ,
  output wire                    s_axil_dynamic_awready  ,
  input  wire      [31 : 0]      s_axil_dynamic_wdata    ,
  input  wire      [3 : 0]       s_axil_dynamic_wstrb    ,
  input  wire                    s_axil_dynamic_wvalid   ,
  output wire                    s_axil_dynamic_wready   ,
  output wire                    s_axil_dynamic_bvalid   ,
  output wire      [1 : 0]       s_axil_dynamic_bresp    ,
  input  wire                    s_axil_dynamic_bready   ,
  input  wire      [31 : 0]      s_axil_dynamic_araddr   ,
  input  wire      [2 : 0]       s_axil_dynamic_arprot   ,
  input  wire                    s_axil_dynamic_arvalid  ,
  output wire                    s_axil_dynamic_arready  ,
  output wire      [31 : 0]      s_axil_dynamic_rdata    ,
  output wire      [1 : 0]       s_axil_dynamic_rresp    ,
  output wire                    s_axil_dynamic_rvalid   ,
  input  wire                    s_axil_dynamic_rready   ,   
    
  input  wire [63:0]             s_axi_xdma_araddr       ,
  input  wire [1:0]              s_axi_xdma_arburst      ,
  input  wire [3:0]              s_axi_xdma_arcache      ,
  input  wire [4:0]              s_axi_xdma_arid         ,
  input  wire [7:0]              s_axi_xdma_arlen        ,
  input  wire [0:0]              s_axi_xdma_arlock       ,
  input  wire [2:0]              s_axi_xdma_arprot       ,
  input  wire [3:0]              s_axi_xdma_arqos        ,
  output wire                    s_axi_xdma_arready      ,
  input  wire [3:0]              s_axi_xdma_arregion     ,
  input  wire [2:0]              s_axi_xdma_arsize       ,
  input  wire                    s_axi_xdma_arvalid      ,
  input  wire [63:0]             s_axi_xdma_awaddr       ,
  input  wire [1:0]              s_axi_xdma_awburst      ,
  input  wire [3:0]              s_axi_xdma_awcache      ,
  input  wire [4:0]              s_axi_xdma_awid         ,
  input  wire [7:0]              s_axi_xdma_awlen        ,
  input  wire [0:0]              s_axi_xdma_awlock       ,
  input  wire [2:0]              s_axi_xdma_awprot       ,
  input  wire [3:0]              s_axi_xdma_awqos        ,
  output wire                    s_axi_xdma_awready      ,
  input  wire [3:0]              s_axi_xdma_awregion     ,
  input  wire [2:0]              s_axi_xdma_awsize       ,
  input  wire                    s_axi_xdma_awvalid      ,
  output wire  [4:0]             s_axi_xdma_bid          ,
  input  wire                    s_axi_xdma_bready       ,
  output wire  [1:0]             s_axi_xdma_bresp        ,
  output wire                    s_axi_xdma_bvalid       ,
  output wire  [511:0]           s_axi_xdma_rdata        ,
  output wire  [4:0]             s_axi_xdma_rid          ,
  output wire                    s_axi_xdma_rlast        ,
  input  wire                    s_axi_xdma_rready       ,
  output wire  [1:0]             s_axi_xdma_rresp        ,
  output wire                    s_axi_xdma_rvalid       ,
  input  wire [511:0]            s_axi_xdma_wdata        ,
  input  wire                    s_axi_xdma_wlast        ,
  output wire                    s_axi_xdma_wready       ,
  input  wire [63:0]             s_axi_xdma_wstrb        ,
  input  wire                    s_axi_xdma_wvalid       ,
  
     output  wire[3 : 0]    c0_test_axi_awid         ,      
     output  wire[63 : 0]   c0_test_axi_awaddr       ,
     output  wire[7 : 0]    c0_test_axi_awlen        ,
     output  wire[2 : 0]    c0_test_axi_awsize       ,
     output  wire[1 : 0]    c0_test_axi_awburst      ,
     output  wire           c0_test_axi_awlock       ,
     output  wire[3 : 0]    c0_test_axi_awcache      ,
     output  wire[2 : 0]    c0_test_axi_awprot       ,
     output  wire           c0_test_axi_awvalid      ,
     input  wire            c0_test_axi_awready      ,
     output  wire[511 : 0]  c0_test_axi_wdata        ,
     output  wire[63 : 0]   c0_test_axi_wstrb        ,
     output  wire           c0_test_axi_wlast        ,
     output  wire           c0_test_axi_wvalid       ,
     input   wire           c0_test_axi_wready       ,
     input   wire[3 : 0]    c0_test_axi_bid          ,
     input   wire[1 : 0]    c0_test_axi_bresp        ,
     input   wire           c0_test_axi_bvalid       ,
     output  wire           c0_test_axi_bready       ,
     output  wire[3 : 0]    c0_test_axi_arid         ,
     output  wire[63 : 0]   c0_test_axi_araddr       ,
     output  wire[7 : 0]    c0_test_axi_arlen        ,
     output  wire[2 : 0]    c0_test_axi_arsize       ,
     output  wire[1 : 0]    c0_test_axi_arburst      ,
     output  wire           c0_test_axi_arlock       ,
     output  wire[3 : 0]    c0_test_axi_arcache      ,
     output  wire[2 : 0]    c0_test_axi_arprot       ,
     output  wire           c0_test_axi_arvalid      ,
     input   wire           c0_test_axi_arready      ,
     input   wire[3 : 0]    c0_test_axi_rid          ,
     input   wire[511 : 0]  c0_test_axi_rdata        ,
     input   wire[1 : 0]    c0_test_axi_rresp        ,
     input   wire           c0_test_axi_rlast        ,
     input   wire           c0_test_axi_rvalid       ,
     output  wire           c0_test_axi_rready       ,
     
     output  wire[3 : 0]    c1_test_axi_awid         ,      
     output  wire[63 : 0]   c1_test_axi_awaddr       ,
     output  wire[7 : 0]    c1_test_axi_awlen        ,
     output  wire[2 : 0]    c1_test_axi_awsize       ,
     output  wire[1 : 0]    c1_test_axi_awburst      ,
     output  wire           c1_test_axi_awlock       ,
     output  wire[3 : 0]    c1_test_axi_awcache      ,
     output  wire[2 : 0]    c1_test_axi_awprot       ,
     output  wire           c1_test_axi_awvalid      ,
     input  wire            c1_test_axi_awready      ,
     output  wire[511 : 0]  c1_test_axi_wdata        ,
     output  wire[63 : 0]   c1_test_axi_wstrb        ,
     output  wire           c1_test_axi_wlast        ,
     output  wire           c1_test_axi_wvalid       ,
     input   wire           c1_test_axi_wready       ,
     input   wire[3 : 0]    c1_test_axi_bid          ,
     input   wire[1 : 0]    c1_test_axi_bresp        ,
     input   wire           c1_test_axi_bvalid       ,
     output  wire           c1_test_axi_bready       ,
     output  wire[3 : 0]    c1_test_axi_arid         ,
     output  wire[63 : 0]   c1_test_axi_araddr       ,
     output  wire[7 : 0]    c1_test_axi_arlen        ,
     output  wire[2 : 0]    c1_test_axi_arsize       ,
     output  wire[1 : 0]    c1_test_axi_arburst      ,
     output  wire           c1_test_axi_arlock       ,
     output  wire[3 : 0]    c1_test_axi_arcache      ,
     output  wire[2 : 0]    c1_test_axi_arprot       ,
     output  wire           c1_test_axi_arvalid      ,
     input   wire           c1_test_axi_arready      ,
     input   wire[3 : 0]    c1_test_axi_rid          ,
     input   wire[511 : 0]  c1_test_axi_rdata        ,
     input   wire[1 : 0]    c1_test_axi_rresp        ,
     input   wire           c1_test_axi_rlast        ,
     input   wire           c1_test_axi_rvalid       ,
     output  wire           c1_test_axi_rready       ,
     
     output  wire[3 : 0]    c2_test_axi_awid         ,      
     output  wire[63 : 0]   c2_test_axi_awaddr       ,
     output  wire[7 : 0]    c2_test_axi_awlen        ,
     output  wire[2 : 0]    c2_test_axi_awsize       ,
     output  wire[1 : 0]    c2_test_axi_awburst      ,
     output  wire           c2_test_axi_awlock       ,
     output  wire[3 : 0]    c2_test_axi_awcache      ,
     output  wire[2 : 0]    c2_test_axi_awprot       ,
     output  wire           c2_test_axi_awvalid      ,
     input  wire            c2_test_axi_awready      ,
     output  wire[511 : 0]  c2_test_axi_wdata        ,
     output  wire[63 : 0]   c2_test_axi_wstrb        ,
     output  wire           c2_test_axi_wlast        ,
     output  wire           c2_test_axi_wvalid       ,
     input   wire           c2_test_axi_wready       ,
     input   wire[3 : 0]    c2_test_axi_bid          ,
     input   wire[1 : 0]    c2_test_axi_bresp        ,
     input   wire           c2_test_axi_bvalid       ,
     output  wire           c2_test_axi_bready       ,
     output  wire[3 : 0]    c2_test_axi_arid         ,
     output  wire[63 : 0]   c2_test_axi_araddr       ,
     output  wire[7 : 0]    c2_test_axi_arlen        ,
     output  wire[2 : 0]    c2_test_axi_arsize       ,
     output  wire[1 : 0]    c2_test_axi_arburst      ,
     output  wire           c2_test_axi_arlock       ,
     output  wire[3 : 0]    c2_test_axi_arcache      ,
     output  wire[2 : 0]    c2_test_axi_arprot       ,
     output  wire           c2_test_axi_arvalid      ,
     input   wire           c2_test_axi_arready      ,
     input   wire[3 : 0]    c2_test_axi_rid          ,
     input   wire[511 : 0]  c2_test_axi_rdata        ,
     input   wire[1 : 0]    c2_test_axi_rresp        ,
     input   wire           c2_test_axi_rlast        ,
     input   wire           c2_test_axi_rvalid       ,
     output  wire           c2_test_axi_rready       ,
     
     output  wire[3 : 0]    c3_test_axi_awid         ,      
     output  wire[63 : 0]   c3_test_axi_awaddr       ,
     output  wire[7 : 0]    c3_test_axi_awlen        ,
     output  wire[2 : 0]    c3_test_axi_awsize       ,
     output  wire[1 : 0]    c3_test_axi_awburst      ,
     output  wire           c3_test_axi_awlock       ,
     output  wire[3 : 0]    c3_test_axi_awcache      ,
     output  wire[2 : 0]    c3_test_axi_awprot       ,
     output  wire           c3_test_axi_awvalid      ,
     input  wire            c3_test_axi_awready      ,
     output  wire[511 : 0]  c3_test_axi_wdata        ,
     output  wire[63 : 0]   c3_test_axi_wstrb        ,
     output  wire           c3_test_axi_wlast        ,
     output  wire           c3_test_axi_wvalid       ,
     input   wire           c3_test_axi_wready       ,
     input   wire[3 : 0]    c3_test_axi_bid          ,
     input   wire[1 : 0]    c3_test_axi_bresp        ,
     input   wire           c3_test_axi_bvalid       ,
     output  wire           c3_test_axi_bready       ,
     output  wire[3 : 0]    c3_test_axi_arid         ,
     output  wire[63 : 0]   c3_test_axi_araddr       ,
     output  wire[7 : 0]    c3_test_axi_arlen        ,
     output  wire[2 : 0]    c3_test_axi_arsize       ,
     output  wire[1 : 0]    c3_test_axi_arburst      ,
     output  wire           c3_test_axi_arlock       ,
     output  wire[3 : 0]    c3_test_axi_arcache      ,
     output  wire[2 : 0]    c3_test_axi_arprot       ,
     output  wire           c3_test_axi_arvalid      ,
     input   wire           c3_test_axi_arready      ,
     input   wire[3 : 0]    c3_test_axi_rid          ,
     input   wire[511 : 0]  c3_test_axi_rdata        ,
     input   wire[1 : 0]    c3_test_axi_rresp        ,
     input   wire           c3_test_axi_rlast        ,
     input   wire           c3_test_axi_rvalid       ,
     output  wire           c3_test_axi_rready                        

);

    wire  [31 : 0]       s_axi_dynamic_ip0_awaddr  ;
    wire  [2 : 0]        s_axi_dynamic_ip0_awprot  ;
    wire                 s_axi_dynamic_ip0_awvalid ;
    wire                 s_axi_dynamic_ip0_awready ;
    wire  [31 : 0]       s_axi_dynamic_ip0_wdata   ;
    wire  [3 : 0]        s_axi_dynamic_ip0_wstrb   ;
    wire                 s_axi_dynamic_ip0_wvalid  ;
    wire                 s_axi_dynamic_ip0_wready  ;
    wire                 s_axi_dynamic_ip0_bvalid  ;
    wire[1 : 0]          s_axi_dynamic_ip0_bresp   ;
    wire                 s_axi_dynamic_ip0_bready  ;
    wire  [31 : 0]       s_axi_dynamic_ip0_araddr  ;
    wire  [2 : 0]        s_axi_dynamic_ip0_arprot  ;
    wire                 s_axi_dynamic_ip0_arvalid ;
    wire                 s_axi_dynamic_ip0_arready ;
    wire[31 : 0]         s_axi_dynamic_ip0_rdata   ;
    wire[1 : 0]          s_axi_dynamic_ip0_rresp   ;
    wire                 s_axi_dynamic_ip0_rvalid  ;
    wire                 s_axi_dynamic_ip0_rready  ;
        
    wire  [31 : 0]       s_axi_dynamic_ip1_awaddr  ;
    wire  [2 : 0]        s_axi_dynamic_ip1_awprot  ;
    wire                 s_axi_dynamic_ip1_awvalid ;
    wire                 s_axi_dynamic_ip1_awready ;
    wire  [31 : 0]       s_axi_dynamic_ip1_wdata   ;
    wire  [3 : 0]        s_axi_dynamic_ip1_wstrb   ;
    wire                 s_axi_dynamic_ip1_wvalid  ;
    wire                 s_axi_dynamic_ip1_wready  ;
    wire                 s_axi_dynamic_ip1_bvalid  ;
    wire[1 : 0]          s_axi_dynamic_ip1_bresp   ;
    wire                 s_axi_dynamic_ip1_bready  ;
    wire  [31 : 0]       s_axi_dynamic_ip1_araddr  ;
    wire  [2 : 0]        s_axi_dynamic_ip1_arprot  ;
    wire                 s_axi_dynamic_ip1_arvalid ;
    wire                 s_axi_dynamic_ip1_arready ;
    wire[31 : 0]         s_axi_dynamic_ip1_rdata   ;
    wire[1 : 0]          s_axi_dynamic_ip1_rresp   ;
    wire                 s_axi_dynamic_ip1_rvalid  ;
    wire                 s_axi_dynamic_ip1_rready  ;

    wire  [31 : 0]       s_axi_dynamic_ip2_awaddr  ;
    wire  [2 : 0]        s_axi_dynamic_ip2_awprot  ;
    wire                 s_axi_dynamic_ip2_awvalid ;
    wire                 s_axi_dynamic_ip2_awready ;
    wire  [31 : 0]       s_axi_dynamic_ip2_wdata   ;
    wire  [3 : 0]        s_axi_dynamic_ip2_wstrb   ;
    wire                 s_axi_dynamic_ip2_wvalid  ;
    wire                 s_axi_dynamic_ip2_wready  ;
    wire                 s_axi_dynamic_ip2_bvalid  ;
    wire[1 : 0]          s_axi_dynamic_ip2_bresp   ;
    wire                 s_axi_dynamic_ip2_bready  ;
    wire  [31 : 0]       s_axi_dynamic_ip2_araddr  ;
    wire  [2 : 0]        s_axi_dynamic_ip2_arprot  ;
    wire                 s_axi_dynamic_ip2_arvalid ;
    wire                 s_axi_dynamic_ip2_arready ;
    wire[31 : 0]         s_axi_dynamic_ip2_rdata   ;
    wire[1 : 0]          s_axi_dynamic_ip2_rresp   ;
    wire                 s_axi_dynamic_ip2_rvalid  ;
    wire                 s_axi_dynamic_ip2_rready  ;
    
    wire  [31 : 0]       s_axi_dynamic_ip3_awaddr  ;
    wire  [2 : 0]        s_axi_dynamic_ip3_awprot  ;
    wire                 s_axi_dynamic_ip3_awvalid ;
    wire                 s_axi_dynamic_ip3_awready ;
    wire  [31 : 0]       s_axi_dynamic_ip3_wdata   ;
    wire  [3 : 0]        s_axi_dynamic_ip3_wstrb   ;
    wire                 s_axi_dynamic_ip3_wvalid  ;
    wire                 s_axi_dynamic_ip3_wready  ;
    wire                 s_axi_dynamic_ip3_bvalid  ;
    wire[1 : 0]          s_axi_dynamic_ip3_bresp   ;
    wire                 s_axi_dynamic_ip3_bready  ;
    wire  [31 : 0]       s_axi_dynamic_ip3_araddr  ;
    wire  [2 : 0]        s_axi_dynamic_ip3_arprot  ;
    wire                 s_axi_dynamic_ip3_arvalid ;
    wire                 s_axi_dynamic_ip3_arready ;
    wire[31 : 0]         s_axi_dynamic_ip3_rdata   ;
    wire[1 : 0]          s_axi_dynamic_ip3_rresp   ;
    wire                 s_axi_dynamic_ip3_rvalid  ;
    wire                 s_axi_dynamic_ip3_rready  ;
      
//fifo
    wire wr_en,rd_en;
    wire full,empty,prog_empty;
    wire [511:0] dout;	
    //
    wire  WRDDR_enble;  //dsp  04/25
    wire [511:0] WRDDR_Data; //dsp  04/25
    wire Read_eth0_fifo_enable;//hxy 
    //eth
    wire ch0_wenb_loop;
    wire[63:0] ch0_wdat_loop;
    
    wire ch0_wenb_clk;
        wire[63:0] ch0_wdat_clk;
        wire ch0_wsop_clk;
            wire ch0_weop_clk;
    //
    wire flush_i, align_done;
    wire [10:0] rd_data_count;
    
    wire flush_done;
    
    //fifo1
        wire wr_en_1,rd_en_1;
        wire full_1,empty_1,prog_empty_1;
        wire [511:0] dout_1;    
        //
        wire  WRDDR_enble_1;  //dsp  04/25
        wire [511:0] WRDDR_Data_1; //dsp  04/25
        wire Read_eth0_fifo_enable_1;//hxy 
        //eth
        wire ch0_wenb_loop_1;
        wire[63:0] ch0_wdat_loop_1;
        
        wire ch0_wenb_clk_1;
            wire[63:0] ch0_wdat_clk_1;
            wire ch0_wsop_clk_1;
                wire ch0_weop_clk_1;
        //
        wire flush_i_1, align_done_1;
        wire [10:0] rd_data_count_1;
        
        wire flush_done_1;
        wire group0_test_en;
        wire group0_timeset_done;
        
        wire [511:0] fifo_dout,fifo_dout_1;
        wire fifo_wr_en,fifo_wr_en_1;
        wire fifo_rd_en,fifo_rd_en_1;
         wire [10:0]   fifo_rd_data_count,fifo_rd_data_count_1;
        wire          fifo_empty,fifo_empty_1,fifo_prog_empty,fifo_prog_empty_1;

           wire[511:0]  tx_data;
           wire tx_enable;
           wire output_enable;
           wire[63:0]  xgmii_txd;
           wire[7:0]   xgmii_txc;   

           wire[511:0]  tx_data_1;
           wire tx_enable_1;
           wire output_enable_1;
           wire[63:0]  xgmii_txd_1;
           wire[7:0]   xgmii_txc_1;   
interconnect_uram_wrapper u_interconnect_uram_data
   (
    .ACLK               (pcie_aclk          ), 
    .ARESETN            (pcie_aresetn       ),
    .S00_AXI_araddr     (s_axi_xdma_araddr  ),
    .S00_AXI_arburst    (s_axi_xdma_arburst ),
    .S00_AXI_arcache    (s_axi_xdma_arcache ),
    .S00_AXI_arid       (s_axi_xdma_arid    ),
    .S00_AXI_arlen      (s_axi_xdma_arlen   ),
    .S00_AXI_arlock     (s_axi_xdma_arlock  ),
    .S00_AXI_arprot     (s_axi_xdma_arprot  ),
    .S00_AXI_arqos      (s_axi_xdma_arqos   ),
    .S00_AXI_arready    (s_axi_xdma_arready ),
    .S00_AXI_arregion   (s_axi_xdma_arregion),
    .S00_AXI_arsize     (s_axi_xdma_arsize  ),
    .S00_AXI_arvalid    (s_axi_xdma_arvalid ),
    .S00_AXI_awaddr     (s_axi_xdma_awaddr  ),
    .S00_AXI_awburst    (s_axi_xdma_awburst ),
    .S00_AXI_awcache    (s_axi_xdma_awcache ),
    .S00_AXI_awid       (s_axi_xdma_awid    ),
    .S00_AXI_awlen      (s_axi_xdma_awlen   ),
    .S00_AXI_awlock     (s_axi_xdma_awlock  ),
    .S00_AXI_awprot     (s_axi_xdma_awprot  ),
    .S00_AXI_awqos      (s_axi_xdma_awqos   ),
    .S00_AXI_awready    (s_axi_xdma_awready ),
    .S00_AXI_awregion   (s_axi_xdma_awregion),
    .S00_AXI_awsize     (s_axi_xdma_awsize  ),
    .S00_AXI_awvalid    (s_axi_xdma_awvalid ),
    .S00_AXI_bid        (s_axi_xdma_bid     ),
    .S00_AXI_bready     (s_axi_xdma_bready  ),
    .S00_AXI_bresp      (s_axi_xdma_bresp   ),
    .S00_AXI_bvalid     (s_axi_xdma_bvalid  ),
    .S00_AXI_rdata      (s_axi_xdma_rdata   ),
    .S00_AXI_rid        (s_axi_xdma_rid     ),
    .S00_AXI_rlast      (s_axi_xdma_rlast   ),
    .S00_AXI_rready     (s_axi_xdma_rready  ),
    .S00_AXI_rresp      (s_axi_xdma_rresp   ),
    .S00_AXI_rvalid     (s_axi_xdma_rvalid  ),
    .S00_AXI_wdata      (s_axi_xdma_wdata   ),
    .S00_AXI_wlast      (s_axi_xdma_wlast   ),
    .S00_AXI_wready     (s_axi_xdma_wready  ),
    .S00_AXI_wstrb      (s_axi_xdma_wstrb   ),
    .S00_AXI_wvalid     (s_axi_xdma_wvalid  )
    );

bram_inf_ip U_bram_inf_ip
(
    //// test IP REG////
    .pcie_link_up           (pcie_link_up              ),
    .s_axil_test_aclk       (clk50m                    ),
    .s_axil_test_aresetn    (sys_rst_n                 ),
    .s_axil_test_awaddr     (s_axi_dynamic_ip0_awaddr  ),
    .s_axil_test_awprot     (s_axi_dynamic_ip0_awprot  ),
    .s_axil_test_awvalid    (s_axi_dynamic_ip0_awvalid ),
    .s_axil_test_awready    (s_axi_dynamic_ip0_awready ),
    .s_axil_test_wdata      (s_axi_dynamic_ip0_wdata   ),
    .s_axil_test_wstrb      (s_axi_dynamic_ip0_wstrb   ),
    .s_axil_test_wvalid     (s_axi_dynamic_ip0_wvalid  ),
    .s_axil_test_wready     (s_axi_dynamic_ip0_wready  ),
    .s_axil_test_bvalid     (s_axi_dynamic_ip0_bvalid  ),
    .s_axil_test_bresp      (s_axi_dynamic_ip0_bresp   ),
    .s_axil_test_bready     (s_axi_dynamic_ip0_bready  ),
    .s_axil_test_araddr     (s_axi_dynamic_ip0_araddr  ),
    .s_axil_test_arprot     (s_axi_dynamic_ip0_arprot  ),
    .s_axil_test_arvalid    (s_axi_dynamic_ip0_arvalid ),
    .s_axil_test_arready    (s_axi_dynamic_ip0_arready ),
    .s_axil_test_rdata      (s_axi_dynamic_ip0_rdata   ),
    .s_axil_test_rresp      (s_axi_dynamic_ip0_rresp   ),
    .s_axil_test_rvalid     (s_axi_dynamic_ip0_rvalid  ),
    .s_axil_test_rready     (s_axi_dynamic_ip0_rready  ),
    ////////////
    .sys_rst                (sys_rst                   )
);

ddr4_control_ip U_ddr4_control_ip
(
    //// test IP REG////
    .pcie_link_up           (pcie_link_up              ),
    .s_axil_test_aclk       (clk50m                    ),
    .s_axil_test_aresetn    (sys_rst_n                 ),
    .s_axil_test_awaddr     (s_axi_dynamic_ip1_awaddr  ),
    .s_axil_test_awprot     (s_axi_dynamic_ip1_awprot  ),
    .s_axil_test_awvalid    (s_axi_dynamic_ip1_awvalid ),
    .s_axil_test_awready    (s_axi_dynamic_ip1_awready ),
    .s_axil_test_wdata      (s_axi_dynamic_ip1_wdata   ),
    .s_axil_test_wstrb      (s_axi_dynamic_ip1_wstrb   ),
    .s_axil_test_wvalid     (s_axi_dynamic_ip1_wvalid  ),
    .s_axil_test_wready     (s_axi_dynamic_ip1_wready  ),
    .s_axil_test_bvalid     (s_axi_dynamic_ip1_bvalid  ),
    .s_axil_test_bresp      (s_axi_dynamic_ip1_bresp   ),
    .s_axil_test_bready     (s_axi_dynamic_ip1_bready  ),
    .s_axil_test_araddr     (s_axi_dynamic_ip1_araddr  ),
    .s_axil_test_arprot     (s_axi_dynamic_ip1_arprot  ),
    .s_axil_test_arvalid    (s_axi_dynamic_ip1_arvalid ),
    .s_axil_test_arready    (s_axi_dynamic_ip1_arready ),
    .s_axil_test_rdata      (s_axi_dynamic_ip1_rdata   ),
    .s_axil_test_rresp      (s_axi_dynamic_ip1_rresp   ),
    .s_axil_test_rvalid     (s_axi_dynamic_ip1_rvalid  ),
    .s_axil_test_rready     (s_axi_dynamic_ip1_rready  ),
    ////////////
    .sys_rst                (sys_rst                   ),
     ////DDR4////
    .c0_ddr4_ui_clk         (c0_ddr4_ui_clk            ),
    
    .clk156                 (clk156),

    .c0_ddr4_ui_clk_sync_rst(c0_ddr4_ui_clk_sync_rst   ),
    .c0_init_calib_complete (c0_init_calib_complete    ),
    .test_axi_c0_awid       (c0_test_axi_awid          ),
    .test_axi_c0_awaddr     (c0_test_axi_awaddr        ),
    .test_axi_c0_awlen      (c0_test_axi_awlen         ),
    .test_axi_c0_awsize     (c0_test_axi_awsize        ),
    .test_axi_c0_awburst    (c0_test_axi_awburst       ),
    .test_axi_c0_awlock     (c0_test_axi_awlock        ),
    .test_axi_c0_awcache    (c0_test_axi_awcache       ),
    .test_axi_c0_awprot     (c0_test_axi_awprot        ),
    .test_axi_c0_awvalid    (c0_test_axi_awvalid       ),
    .test_axi_c0_awready    (c0_test_axi_awready       ),
    .test_axi_c0_wdata      (c0_test_axi_wdata         ),
    .test_axi_c0_wstrb      (c0_test_axi_wstrb         ),
    .test_axi_c0_wlast      (c0_test_axi_wlast         ),
    .test_axi_c0_wvalid     (c0_test_axi_wvalid        ),
    .test_axi_c0_wready     (c0_test_axi_wready        ),
    .test_axi_c0_bid        (c0_test_axi_bid           ),
    .test_axi_c0_bresp      (c0_test_axi_bresp         ),
    .test_axi_c0_bvalid     (c0_test_axi_bvalid        ),
    .test_axi_c0_bready     (c0_test_axi_bready        ),
    .test_axi_c0_arid       (c0_test_axi_arid          ),
    .test_axi_c0_araddr     (c0_test_axi_araddr        ),
    .test_axi_c0_arlen      (c0_test_axi_arlen         ),
    .test_axi_c0_arsize     (c0_test_axi_arsize        ),
    .test_axi_c0_arburst    (c0_test_axi_arburst       ),
    .test_axi_c0_arlock     (c0_test_axi_arlock        ),
    .test_axi_c0_arcache    (c0_test_axi_arcache       ),
    .test_axi_c0_arprot     (c0_test_axi_arprot        ),
    .test_axi_c0_arvalid    (c0_test_axi_arvalid       ),
    .test_axi_c0_arready    (c0_test_axi_arready       ),
    .test_axi_c0_rid        (c0_test_axi_rid           ),
    .test_axi_c0_rdata      (c0_test_axi_rdata         ),
    .test_axi_c0_rresp      (c0_test_axi_rresp         ),
    .test_axi_c0_rlast      (c0_test_axi_rlast         ),
    .test_axi_c0_rvalid     (c0_test_axi_rvalid        ),
    .test_axi_c0_rready     (c0_test_axi_rready        ),
    .group0_test_en         (group0_test_en),
    .group0_timeset_done    (group0_timeset_done),
    
    .input_eth0_data        (fifo_dout),  
    .prog_empty             (fifo_prog_empty),
    .Read_eth0_fifo_enable  (fifo_rd_en),
    .empty                  (fifo_empty),
    .rd_data_count          (fifo_rd_data_count),
    .flush                  (flush_i),
    .align_done             (align_done),
    .flush_done             (flush_done),
     
    .tx_data                (tx_data),
    .tx_enable              (tx_enable),
    .output_enable          (output_enable),   

    .c1_ddr4_ui_clk         (c1_ddr4_ui_clk            ),
    .c1_ddr4_ui_clk_sync_rst(c1_ddr4_ui_clk_sync_rst   ),
    .c1_init_calib_complete (c1_init_calib_complete    ),
    .test_axi_c1_awid       (c1_test_axi_awid          ),
    .test_axi_c1_awaddr     (c1_test_axi_awaddr        ),
    .test_axi_c1_awlen      (c1_test_axi_awlen         ),
    .test_axi_c1_awsize     (c1_test_axi_awsize        ),
    .test_axi_c1_awburst    (c1_test_axi_awburst       ),
    .test_axi_c1_awlock     (c1_test_axi_awlock        ),
    .test_axi_c1_awcache    (c1_test_axi_awcache       ),
    .test_axi_c1_awprot     (c1_test_axi_awprot        ),
    .test_axi_c1_awvalid    (c1_test_axi_awvalid       ),
    .test_axi_c1_awready    (c1_test_axi_awready       ),
    .test_axi_c1_wdata      (c1_test_axi_wdata         ),
    .test_axi_c1_wstrb      (c1_test_axi_wstrb         ),
    .test_axi_c1_wlast      (c1_test_axi_wlast         ),
    .test_axi_c1_wvalid     (c1_test_axi_wvalid        ),
    .test_axi_c1_wready     (c1_test_axi_wready        ),
    .test_axi_c1_bid        (c1_test_axi_bid           ),
    .test_axi_c1_bresp      (c1_test_axi_bresp         ),
    .test_axi_c1_bvalid     (c1_test_axi_bvalid        ),
    .test_axi_c1_bready     (c1_test_axi_bready        ),
    .test_axi_c1_arid       (c1_test_axi_arid          ),
    .test_axi_c1_araddr     (c1_test_axi_araddr        ),
    .test_axi_c1_arlen      (c1_test_axi_arlen         ),
    .test_axi_c1_arsize     (c1_test_axi_arsize        ),
    .test_axi_c1_arburst    (c1_test_axi_arburst       ),
    .test_axi_c1_arlock     (c1_test_axi_arlock        ),
    .test_axi_c1_arcache    (c1_test_axi_arcache       ),
    .test_axi_c1_arprot     (c1_test_axi_arprot        ),
    .test_axi_c1_arvalid    (c1_test_axi_arvalid       ),
    .test_axi_c1_arready    (c1_test_axi_arready       ),
    .test_axi_c1_rid        (c1_test_axi_rid           ),
    .test_axi_c1_rdata      (c1_test_axi_rdata         ),
    .test_axi_c1_rresp      (c1_test_axi_rresp         ),
    .test_axi_c1_rlast      (c1_test_axi_rlast         ),
    .test_axi_c1_rvalid     (c1_test_axi_rvalid        ),
    .test_axi_c1_rready     (c1_test_axi_rready        ),
    
    .input_eth0_data_1      (fifo_dout_1),  //dsp  04/25
    .prog_empty_1           (fifo_prog_empty_1),//dsp  04/25
    .Read_eth0_fifo_enable_1(fifo_rd_en_1),//dsp  05/07
    .empty_1                (fifo_empty_1),
    .rd_data_count_1        (fifo_rd_data_count_1),
    .flush_1                (flush_i_1),
    .align_done_1           (align_done_1),
    .flush_done_1           (flush_done_1),
        
    .tx_data_1              (tx_data_1),
    .tx_enable_1            (tx_enable_1),
    .output_enable_1        (output_enable_1),   

    .c2_ddr4_ui_clk         (c2_ddr4_ui_clk            ),
    .c2_ddr4_ui_clk_sync_rst(c2_ddr4_ui_clk_sync_rst   ),
    .c2_init_calib_complete (c2_init_calib_complete    ),
    .test_axi_c2_awid       (c2_test_axi_awid          ),
    .test_axi_c2_awaddr     (c2_test_axi_awaddr        ),
    .test_axi_c2_awlen      (c2_test_axi_awlen         ),
    .test_axi_c2_awsize     (c2_test_axi_awsize        ),
    .test_axi_c2_awburst    (c2_test_axi_awburst       ),
    .test_axi_c2_awlock     (c2_test_axi_awlock        ),
    .test_axi_c2_awcache    (c2_test_axi_awcache       ),
    .test_axi_c2_awprot     (c2_test_axi_awprot        ),
    .test_axi_c2_awvalid    (c2_test_axi_awvalid       ),
    .test_axi_c2_awready    (c2_test_axi_awready       ),
    .test_axi_c2_wdata      (c2_test_axi_wdata         ),
    .test_axi_c2_wstrb      (c2_test_axi_wstrb         ),
    .test_axi_c2_wlast      (c2_test_axi_wlast         ),
    .test_axi_c2_wvalid     (c2_test_axi_wvalid        ),
    .test_axi_c2_wready     (c2_test_axi_wready        ),
    .test_axi_c2_bid        (c2_test_axi_bid           ),
    .test_axi_c2_bresp      (c2_test_axi_bresp         ),
    .test_axi_c2_bvalid     (c2_test_axi_bvalid        ),
    .test_axi_c2_bready     (c2_test_axi_bready        ),
    .test_axi_c2_arid       (c2_test_axi_arid          ),
    .test_axi_c2_araddr     (c2_test_axi_araddr        ),
    .test_axi_c2_arlen      (c2_test_axi_arlen         ),
    .test_axi_c2_arsize     (c2_test_axi_arsize        ),
    .test_axi_c2_arburst    (c2_test_axi_arburst       ),
    .test_axi_c2_arlock     (c2_test_axi_arlock        ),
    .test_axi_c2_arcache    (c2_test_axi_arcache       ),
    .test_axi_c2_arprot     (c2_test_axi_arprot        ),
    .test_axi_c2_arvalid    (c2_test_axi_arvalid       ),
    .test_axi_c2_arready    (c2_test_axi_arready       ),
    .test_axi_c2_rid        (c2_test_axi_rid           ),
    .test_axi_c2_rdata      (c2_test_axi_rdata         ),
    .test_axi_c2_rresp      (c2_test_axi_rresp         ),
    .test_axi_c2_rlast      (c2_test_axi_rlast         ),
    .test_axi_c2_rvalid     (c2_test_axi_rvalid        ),
    .test_axi_c2_rready     (c2_test_axi_rready        ),

    .c3_ddr4_ui_clk         (c3_ddr4_ui_clk            ),
    .c3_ddr4_ui_clk_sync_rst(c3_ddr4_ui_clk_sync_rst   ),
    .c3_init_calib_complete (c3_init_calib_complete    ),
    .test_axi_c3_awid       (c3_test_axi_awid          ),
    .test_axi_c3_awaddr     (c3_test_axi_awaddr        ),
    .test_axi_c3_awlen      (c3_test_axi_awlen         ),
    .test_axi_c3_awsize     (c3_test_axi_awsize        ),
    .test_axi_c3_awburst    (c3_test_axi_awburst       ),
    .test_axi_c3_awlock     (c3_test_axi_awlock        ),
    .test_axi_c3_awcache    (c3_test_axi_awcache       ),
    .test_axi_c3_awprot     (c3_test_axi_awprot        ),
    .test_axi_c3_awvalid    (c3_test_axi_awvalid       ),
    .test_axi_c3_awready    (c3_test_axi_awready       ),
    .test_axi_c3_wdata      (c3_test_axi_wdata         ),
    .test_axi_c3_wstrb      (c3_test_axi_wstrb         ),
    .test_axi_c3_wlast      (c3_test_axi_wlast         ),
    .test_axi_c3_wvalid     (c3_test_axi_wvalid        ),
    .test_axi_c3_wready     (c3_test_axi_wready        ),
    .test_axi_c3_bid        (c3_test_axi_bid           ),
    .test_axi_c3_bresp      (c3_test_axi_bresp         ),
    .test_axi_c3_bvalid     (c3_test_axi_bvalid        ),
    .test_axi_c3_bready     (c3_test_axi_bready        ),
    .test_axi_c3_arid       (c3_test_axi_arid          ),
    .test_axi_c3_araddr     (c3_test_axi_araddr        ),
    .test_axi_c3_arlen      (c3_test_axi_arlen         ),
    .test_axi_c3_arsize     (c3_test_axi_arsize        ),
    .test_axi_c3_arburst    (c3_test_axi_arburst       ),
    .test_axi_c3_arlock     (c3_test_axi_arlock        ),
    .test_axi_c3_arcache    (c3_test_axi_arcache       ),
    .test_axi_c3_arprot     (c3_test_axi_arprot        ),
    .test_axi_c3_arvalid    (c3_test_axi_arvalid       ),
    .test_axi_c3_arready    (c3_test_axi_arready       ),
    .test_axi_c3_rid        (c3_test_axi_rid           ),
    .test_axi_c3_rdata      (c3_test_axi_rdata         ),
    .test_axi_c3_rresp      (c3_test_axi_rresp         ),
    .test_axi_c3_rlast      (c3_test_axi_rlast         ),
    .test_axi_c3_rvalid     (c3_test_axi_rvalid        ),
    .test_axi_c3_rready     (c3_test_axi_rready        )
);




   
 

    ////ETH////  
	//wire              clk156                      ;    
    wire              coreclk_out                 ;     
    wire              qpll0outclk_out             ;     
    wire              qpll0outrefclk_out          ;     
    wire              qpll0lock_out               ;     
    wire              areset_datapathclk_out      ;     
    wire              areset_coreclk_out          ;     
    wire              txusrclk_out                ;     
    wire              gttxreset_out               ;     
    wire              gtrxreset_out               ;     
    wire              txuserrdy_out               ;     
    wire              rxrecclk_out                ;     
    wire              reset_counter_done_out      ; 

    wire    [14:0]    tgbaser_c0_cfg0             ;
    wire    [31:0]    tgbaser_c0_cfg1             ;
    wire    [25:0]    tgbaser_c0_cfg2             ;
    wire    [14:0]    tgbaser_c1_cfg0             ;
    wire    [31:0]    tgbaser_c1_cfg1             ;
    wire    [25:0]    tgbaser_c1_cfg2             ;
                                                  
    wire    [2:0]     tgbaser_status              ;
    wire    [31:0]    tgbaser_c0_status0          ;
    wire    [5:0]     tgbaser_c0_status1          ;
    wire    [31:0]    tgbaser_c1_status0          ;
    wire    [5:0]     tgbaser_c1_status1          ;    
    
   

    wire   [7:0]      c0_core_status              ;     
    wire              c0_resetdone_out            ;     
    wire              c0_tx_disable               ;     
                                                        
    wire              c0_pma_loopback             ;     
    wire              c0_pma_reset                ;     
    wire              c0_global_tx_disable        ;     
    wire              c0_pcs_loopback             ;     
    wire              c0_pcs_reset                ;     
    wire  [57:0]      c0_test_patt_a_b            ;     
    wire              c0_data_patt_sel            ;     
    wire              c0_test_patt_sel            ;     
    wire              c0_rx_test_patt_en          ;     
    wire              c0_tx_test_patt_en          ;     
    wire              c0_prbs31_tx_en             ;     
    wire              c0_prbs31_rx_en             ;     
    wire              c0_set_pma_link_status      ;     
    wire              c0_set_pcs_link_status      ;     
    wire              c0_clear_pcs_status2        ;     
    wire              c0_clear_test_patt_err_count;     
                                                        
    
    wire              c0_rx_sig_det               ;     
    wire              c0_pcs_rx_link_status       ;     
    wire              c0_pcs_hiber                ;     
    wire              c0_teng_pcs_rx_link_status  ;     
    wire   [7:0]      c0_pcs_err_block_count      ;     
    wire   [5:0]      c0_pcs_ber_count            ;     
    wire              c0_pcs_rx_hiber_lh          ;     
    wire              c0_pcs_rx_locked_ll         ;     
    wire   [5:0]      c0_pcs_test_patt_err_count  ;     
    wire              c0_pma_link_status          ; 
    wire              c0_pcs_rx_locked            ;
   

   
                                                        
    wire   [7:0]      c1_core_status              ;     
    wire              c1_resetdone_out            ;     
    wire              c1_tx_disable               ;     
                                                        
    wire              c1_pma_loopback             ;     
    wire              c1_pma_reset                ;     
    wire              c1_global_tx_disable        ;     
    wire              c1_pcs_loopback             ;     
    wire              c1_pcs_reset                ;     
    wire  [57:0]      c1_test_patt_a_b            ;     
    wire              c1_data_patt_sel            ;     
    wire              c1_test_patt_sel            ;     
    wire              c1_rx_test_patt_en          ;     
    wire              c1_tx_test_patt_en          ;     
    wire              c1_prbs31_tx_en             ;     
    wire              c1_prbs31_rx_en             ;     
    wire              c1_set_pma_link_status      ;     
    wire              c1_set_pcs_link_status      ;     
    wire              c1_clear_pcs_status2        ;     
    wire              c1_clear_test_patt_err_count;     
                                                        
    wire              c1_rx_sig_det               ;     
    wire              c1_pcs_rx_link_status       ;     
    wire              c1_pcs_hiber                ;     
    wire              c1_teng_pcs_rx_link_status  ;     
    wire   [7:0]      c1_pcs_err_block_count      ;     
    wire   [5:0]      c1_pcs_ber_count            ;     
    wire              c1_pcs_rx_hiber_lh          ;     
    wire              c1_pcs_rx_locked_ll         ;     
    wire   [5:0]      c1_pcs_test_patt_err_count  ; 
    wire              c1_pma_link_status          ;     
    wire              c1_pcs_rx_locked            ; 

    wire              ETH0_GEN_EN;  
    wire    [63:0]              BASE_TIME;
   
    
    wire    [63 : 0]  c0_xgmii_txd_d                ;
    wire    [7 : 0]   c0_xgmii_txc_d                ;
    wire    [63 : 0]  c0_xgmii_rxd                ;
    wire    [7 : 0]   c0_xgmii_rxc                ;
                                                  
    wire     [63 : 0]  c1_xgmii_txd_d                ;
    wire    [7 : 0]   c1_xgmii_txc_d                ;
    wire    [63 : 0]  c1_xgmii_rxd                ;
    wire    [7 : 0]   c1_xgmii_rxc                ;
    
    wire    [511:0]   IncEnb156m                  ;
    wire    [3:0]     stat_inc_d_p0_xrx           ;
    wire    [3:0]     stat_inc_d_p1_xrx           ;
    wire    [3:0]     stat_inc_d_p0_xtx           ;
    wire    [3:0]     stat_inc_d_p1_xtx           ;
    wire    [15:0]    ch0_wlen_rx                 ;
    wire    [15:0]    ch0_wlen_tx                 ;
    wire    [15:0]    ch1_wlen_rx                 ;
    wire    [15:0]    ch1_wlen_tx                 ;
wire	   rst_serdes0;	
wire	   rst_serdes1;	

   wire [31:0] pps_rate;
   wire [31:0] byte_rate;
   
   wire [31:0] pps_rate_1;
   wire [31:0] byte_rate_1;

/***********************************************/

/*****************Ethernet**********************/

assign tgbaser_status[0]        = qpll0lock_out               ;    
assign tgbaser_status[1]        = txuserrdy_out               ;    
assign tgbaser_status[2]        = reset_counter_done_out      ;    

assign tgbaser_c0_status0[7:0]  = c0_core_status              ;    
assign tgbaser_c0_status0[8]    = c0_resetdone_out            ;    
assign tgbaser_c0_status0[9]    = c0_tx_disable               ;    
assign tgbaser_c0_status0[10]   = c0_pma_link_status          ;    
assign tgbaser_c0_status0[11]   = c0_rx_sig_det               ;    
assign tgbaser_c0_status0[12]   = c0_pcs_rx_link_status       ;    
assign tgbaser_c0_status0[13]   = c0_pcs_rx_locked            ;    
assign tgbaser_c0_status0[14]   = c0_pcs_hiber                ;    
assign tgbaser_c0_status0[15]   = c0_teng_pcs_rx_link_status  ;    
assign tgbaser_c0_status0[23:16]= c0_pcs_err_block_count      ;    
assign tgbaser_c0_status0[29:24]= c0_pcs_ber_count            ;    
assign tgbaser_c0_status0[30]   = c0_pcs_rx_hiber_lh          ;    
assign tgbaser_c0_status0[31]   = c0_pcs_rx_locked_ll         ;    
assign tgbaser_c0_status1[5:0]  = c0_pcs_test_patt_err_count  ;    

assign tgbaser_c1_status0[7:0]  = c1_core_status              ;    
assign tgbaser_c1_status0[8]    = c1_resetdone_out            ;    
assign tgbaser_c1_status0[9]    = c1_tx_disable               ;    
assign tgbaser_c1_status0[10]   = c1_pma_link_status          ;    
assign tgbaser_c1_status0[11]   = c1_rx_sig_det               ;    
assign tgbaser_c1_status0[12]   = c1_pcs_rx_link_status       ;    
assign tgbaser_c1_status0[13]   = c1_pcs_rx_locked            ;    
assign tgbaser_c1_status0[14]   = c1_pcs_hiber                ;    
assign tgbaser_c1_status0[15]   = c1_teng_pcs_rx_link_status  ;    
assign tgbaser_c1_status0[23:16]= c1_pcs_err_block_count      ;    
assign tgbaser_c1_status0[29:24]= c1_pcs_ber_count            ;    
assign tgbaser_c1_status0[30]   = c1_pcs_rx_hiber_lh          ;    
assign tgbaser_c1_status0[31]   = c1_pcs_rx_locked_ll         ;    
assign tgbaser_c1_status1[5:0]  = c1_pcs_test_patt_err_count  ;    


assign c0_pma_loopback              = tgbaser_c0_cfg0[0];     
assign c0_pma_reset                 = tgbaser_c0_cfg0[1];     
assign c0_global_tx_disable         = tgbaser_c0_cfg0[2];     
assign c0_pcs_loopback              = tgbaser_c0_cfg0[3];     
assign c0_pcs_reset                 = tgbaser_c0_cfg0[4];     
assign c0_data_patt_sel             = tgbaser_c0_cfg0[5];     
assign c0_test_patt_sel             = tgbaser_c0_cfg0[6];     
assign c0_rx_test_patt_en           = tgbaser_c0_cfg0[7];     
assign c0_tx_test_patt_en           = tgbaser_c0_cfg0[8];     
assign c0_prbs31_tx_en              = tgbaser_c0_cfg0[9];     
assign c0_prbs31_rx_en              = tgbaser_c0_cfg0[10];    
assign c0_set_pma_link_status       = tgbaser_c0_cfg0[11];    
assign c0_set_pcs_link_status       = tgbaser_c0_cfg0[12];    
assign c0_clear_pcs_status2         = tgbaser_c0_cfg0[13];    
assign c0_clear_test_patt_err_count = tgbaser_c0_cfg0[14];                                       
assign c0_test_patt_a_b             = {tgbaser_c0_cfg2[25:0],tgbaser_c0_cfg1[31:0]};              

assign c1_pma_loopback              = tgbaser_c1_cfg0[0];     
assign c1_pma_reset                 = tgbaser_c1_cfg0[1];     
assign c1_global_tx_disable         = tgbaser_c1_cfg0[2];     
assign c1_pcs_loopback              = tgbaser_c1_cfg0[3];     
assign c1_pcs_reset                 = tgbaser_c1_cfg0[4];     
assign c1_data_patt_sel             = tgbaser_c1_cfg0[5];     
assign c1_test_patt_sel             = tgbaser_c1_cfg0[6];     
assign c1_rx_test_patt_en           = tgbaser_c1_cfg0[7];     
assign c1_tx_test_patt_en           = tgbaser_c1_cfg0[8];     
assign c1_prbs31_tx_en              = tgbaser_c1_cfg0[9];     
assign c1_prbs31_rx_en              = tgbaser_c1_cfg0[10];    
assign c1_set_pma_link_status       = tgbaser_c1_cfg0[11];    
assign c1_set_pcs_link_status       = tgbaser_c1_cfg0[12];    
assign c1_clear_pcs_status2         = tgbaser_c1_cfg0[13];    
assign c1_clear_test_patt_err_count = tgbaser_c1_cfg0[14];                                       
assign c1_test_patt_a_b             = {tgbaser_c1_cfg2[25:0],tgbaser_c1_cfg1[31:0]};               

assign  ETH0_LINK = ({c0_resetdone_out,c0_rx_sig_det,c0_pcs_rx_locked,c0_teng_pcs_rx_link_status,c0_pma_link_status} == 5'b11110);
assign  ETH1_LINK = ({c1_resetdone_out,c1_rx_sig_det,c1_pcs_rx_locked,c1_teng_pcs_rx_link_status,c1_pma_link_status} == 5'b11110);
assign  link0 =~ ETH0_LINK;
assign  link1 =~ ETH1_LINK; 
          

    ten_gig_eth_pcs_pma_0_support  U_tgbaser(
    .refclk_p                       (fiber0_refclk_p                ),    
    .refclk_n                       (fiber0_refclk_n                ),    
    .dclk                           (clk50m                         ),    
    .coreclk_out                    (coreclk_out                    ),    
    .reset                          (sys_rst                        ),    
    .sim_speedup_control            (1'b0                           ),    
    .qpll0outclk_out                (qpll0outclk_out                ),    
    .qpll0outrefclk_out             (qpll0outrefclk_out             ),    
    .qpll0lock_out                  (qpll0lock_out                  ),    
    .areset_datapathclk_out         (areset_datapathclk_out         ),    
    .areset_coreclk_out             (areset_coreclk_out             ),    
    .txusrclk_out                   (txusrclk_out                   ),    
    .txusrclk2_out                  (clk156                         ),    
    .gttxreset_out                  (gttxreset_out                  ),    
    .gtrxreset_out                  (gtrxreset_out                  ),    
    .txuserrdy_out                  (txuserrdy_out                  ),    
    .rxrecclk_out                   (rxrecclk_out                   ),    
    .reset_counter_done_out         (reset_counter_done_out         ),    
                                                                          
    .c0_xgmii_txd                   (xgmii_txd                  ),    
    .c0_xgmii_txc                   (xgmii_txc                  ),    
    .c0_xgmii_rxd                   (c0_xgmii_rxd                   ),    
    .c0_xgmii_rxc                   (c0_xgmii_rxc                   ),    
    .c0_txp                         (fiber_tsc0_tdp                 ),    
    .c0_txn                         (fiber_tsc0_tdn                 ),    
    .c0_rxp                         (fiber_tsc0_rdp                 ),    
    .c0_rxn                         (fiber_tsc0_rdn                 ),    
                                                                          
    .c0_core_status                 (c0_core_status                 ),    
    .c0_resetdone_out               (c0_resetdone_out               ),    
    .c0_signal_detect               (~los0                          ),    
    .c0_tx_fault                    (1'b0                           ),    
    .c0_pma_pmd_type                (3'b101                         ),    
    .c0_tx_disable                  (c0_tx_disable                  ),    
                                                                          
    .c0_pma_loopback                (c0_pma_loopback                ),    
    .c0_pma_reset                   (c0_pma_reset                   ),    
    .c0_global_tx_disable           (c0_global_tx_disable           ),    
    .c0_pcs_loopback                (c0_pcs_loopback                ),    
    .c0_pcs_reset                   (c0_pcs_reset                   ),    
    .c0_test_patt_a_b               (c0_test_patt_a_b               ),    
    .c0_data_patt_sel               (c0_data_patt_sel               ),    
    .c0_test_patt_sel               (c0_test_patt_sel               ),    
    .c0_rx_test_patt_en             (c0_rx_test_patt_en             ),    
    .c0_tx_test_patt_en             (c0_tx_test_patt_en             ),    
    .c0_prbs31_tx_en                (c0_prbs31_tx_en                ),    
    .c0_prbs31_rx_en                (c0_prbs31_rx_en                ),    
    .c0_set_pma_link_status         (c0_set_pma_link_status         ),    
    .c0_set_pcs_link_status         (c0_set_pcs_link_status         ),    
    .c0_clear_pcs_status2           (c0_clear_pcs_status2           ),    
    .c0_clear_test_patt_err_count   (c0_clear_test_patt_err_count   ),    
                                                                          
    .c0_pma_link_status             (c0_pma_link_status             ),    
    .c0_rx_sig_det                  (c0_rx_sig_det                  ),    
    .c0_pcs_rx_link_status          (c0_pcs_rx_link_status          ),    
    .c0_pcs_rx_locked               (c0_pcs_rx_locked               ),    
    .c0_pcs_hiber                   (c0_pcs_hiber                   ),    
    .c0_teng_pcs_rx_link_status     (c0_teng_pcs_rx_link_status     ),    
    .c0_pcs_err_block_count         (c0_pcs_err_block_count         ),    
    .c0_pcs_ber_count               (c0_pcs_ber_count               ),    
    .c0_pcs_rx_hiber_lh             (c0_pcs_rx_hiber_lh             ),    
    .c0_pcs_rx_locked_ll            (c0_pcs_rx_locked_ll            ),    
    .c0_pcs_test_patt_err_count     (c0_pcs_test_patt_err_count     ),    
                                                                          
    .c1_xgmii_txd                   (xgmii_txd_1                ),    
    .c1_xgmii_txc                   (xgmii_txc_1                 ),    
    .c1_xgmii_rxd                   (c1_xgmii_rxd                   ),    
    .c1_xgmii_rxc                   (c1_xgmii_rxc                   ),    
    .c1_txp                         (fiber_tsc1_tdp                 ),    
    .c1_txn                         (fiber_tsc1_tdn                 ),    
    .c1_rxp                         (fiber_tsc1_rdp                 ),    
    .c1_rxn                         (fiber_tsc1_rdn                 ),    
                                                                          
    .c1_core_status                 (c1_core_status                 ),    
    .c1_resetdone_out               (c1_resetdone_out               ),    
    .c1_signal_detect               (~los1                          ),    
    .c1_tx_fault                    (1'b0                           ),    
    .c1_pma_pmd_type                (3'b101                         ),    
    .c1_tx_disable                  (c1_tx_disable                  ),    
                                                                          
    .c1_pma_loopback                (c1_pma_loopback                ),    
    .c1_pma_reset                   (c1_pma_reset                   ),    
    .c1_global_tx_disable           (c1_global_tx_disable           ),    
    .c1_pcs_loopback                (c1_pcs_loopback                ),    
    .c1_pcs_reset                   (c1_pcs_reset                   ),    
    .c1_test_patt_a_b               (c1_test_patt_a_b               ),    
    .c1_data_patt_sel               (c1_data_patt_sel               ),    
    .c1_test_patt_sel               (c1_test_patt_sel               ),    
    .c1_rx_test_patt_en             (c1_rx_test_patt_en             ),    
    .c1_tx_test_patt_en             (c1_tx_test_patt_en             ),    
    .c1_prbs31_tx_en                (c1_prbs31_tx_en                ),    
    .c1_prbs31_rx_en                (c1_prbs31_rx_en                ),    
    .c1_set_pma_link_status         (c1_set_pma_link_status         ),    
    .c1_set_pcs_link_status         (c1_set_pcs_link_status         ),    
    .c1_clear_pcs_status2           (c1_clear_pcs_status2           ),    
    .c1_clear_test_patt_err_count   (c1_clear_test_patt_err_count   ),    
                                                                          
    .c1_pma_link_status             (c1_pma_link_status             ),    
    .c1_rx_sig_det                  (c1_rx_sig_det                  ),    
    .c1_pcs_rx_link_status          (c1_pcs_rx_link_status          ),    
    .c1_pcs_rx_locked               (c1_pcs_rx_locked               ),    
    .c1_pcs_hiber                   (c1_pcs_hiber                   ),    
    .c1_teng_pcs_rx_link_status     (c1_teng_pcs_rx_link_status     ),    
    .c1_pcs_err_block_count         (c1_pcs_err_block_count         ),    
    .c1_pcs_ber_count               (c1_pcs_ber_count               ),    
    .c1_pcs_rx_hiber_lh             (c1_pcs_rx_hiber_lh             ),    
    .c1_pcs_rx_locked_ll            (c1_pcs_rx_locked_ll            ),    
    .c1_pcs_test_patt_err_count     (c1_pcs_test_patt_err_count     )     
                        );
                        

eth_control_ip U_eth_control_ip_0
(   
    //// test IP REG////
    .pcie_link_up           (pcie_link_up              ),
    .s_axil_test_aclk       (clk50m                    ), // changed clock according to AXI Interconnect port clock  
    .s_axil_test_aresetn    (sys_rst_n              ),                           
    .s_axil_test_awaddr     (s_axi_dynamic_ip2_awaddr  ),
    .s_axil_test_awprot     (s_axi_dynamic_ip2_awprot  ),
    .s_axil_test_awvalid    (s_axi_dynamic_ip2_awvalid ),
    .s_axil_test_awready    (s_axi_dynamic_ip2_awready ),                           
    .s_axil_test_wdata      (s_axi_dynamic_ip2_wdata   ),
    .s_axil_test_wstrb      (s_axi_dynamic_ip2_wstrb   ),
    .s_axil_test_wvalid     (s_axi_dynamic_ip2_wvalid  ),
    .s_axil_test_wready     (s_axi_dynamic_ip2_wready  ),                           
    .s_axil_test_bvalid     (s_axi_dynamic_ip2_bvalid  ),
    .s_axil_test_bresp      (s_axi_dynamic_ip2_bresp   ),
    .s_axil_test_bready     (s_axi_dynamic_ip2_bready  ),                            
    .s_axil_test_araddr     (s_axi_dynamic_ip2_araddr  ),
    .s_axil_test_arprot     (s_axi_dynamic_ip2_arprot  ),
    .s_axil_test_arvalid    (s_axi_dynamic_ip2_arvalid ),
    .s_axil_test_arready    (s_axi_dynamic_ip2_arready ),                             
    .s_axil_test_rdata      (s_axi_dynamic_ip2_rdata   ),
    .s_axil_test_rresp      (s_axi_dynamic_ip2_rresp   ),
    .s_axil_test_rvalid     (s_axi_dynamic_ip2_rvalid  ),
    .s_axil_test_rready     (s_axi_dynamic_ip2_rready  ),
    ////////////
    .sys_rst                (sys_rst                   ),   

     ////ETH////
    .clk156                 (clk156                    ), 
    .c0_fiber_IncEnb         (           ),
    .c1_fiber_IncEnb         (           ),

    .ETH0_RxEN              (ETH0_RxEN                 ),
    .ETH0_TxEN              (ETH0_TxEN                 ),
    .ETH0_LOOP              (ETH0_LOOP                 ),
    .ETH0_LINK              (ETH0_LINK                 ),
    .ETH0_GEN_EN            (ETH0_GEN_EN),
                                                    
    .ETH1_RxEN              (                 ),
    .ETH1_TxEN              (                 ),
    .ETH1_LOOP              (                 ),
    .ETH1_LINK              (                 ),  
    .BASE_TIME              (BASE_TIME), 
    .c0_xgmii_txd_d         (c0_xgmii_txd_d            ),    
    .c0_xgmii_txc_d         (c0_xgmii_txc_d            ),    
    .c0_xgmii_rxd           (c0_xgmii_rxd              ),    
    .c0_xgmii_rxc           (c0_xgmii_rxc              ),
    .c1_xgmii_txd_d         (            ),    
    .c1_xgmii_txc_d         (            ),    
    .c1_xgmii_rxd           (              ),    
    .c1_xgmii_rxc           (              ), 
    .ch0_wlen_rx            ( ch0_wlen_rx      ),
    .ch1_wlen_rx            (       ),
    .ch0_wlen_tx            ( ch0_wlen_tx      ),
    .ch1_wlen_tx            (       ),   
    .stat_inc_d_p0_xrx      (       ),
    .stat_inc_d_p1_xrx      (       ),
    .stat_inc_d_p0_xtx      (       ),
    .stat_inc_d_p1_xtx      (       ),
    .tgbaser_c0_cfg0        (tgbaser_c0_cfg0           ),
    .tgbaser_c0_cfg1        (tgbaser_c0_cfg1           ),
    .tgbaser_c0_cfg2        (tgbaser_c0_cfg2           ),
    .tgbaser_c1_cfg0        (           ),
    .tgbaser_c1_cfg1        (           ),
    .tgbaser_c1_cfg2        (           ),                          
    .tgbaser_status         (tgbaser_status            ),
    .tgbaser_c0_status0     (tgbaser_c0_status0        ),
    .tgbaser_c0_status1     (tgbaser_c0_status1        ),
    .tgbaser_c1_status0     (        ),
    .tgbaser_c1_status1     (        ),
    .ACT0                   (act0                      ),         
    .ACT1                   (	                        )  ,
    
    .byte_rate   (byte_rate),
    .pps_rate    (pps_rate),
    
    .ch0_wenb_clk (ch0_wenb_clk),
    .ch0_wdat_clk (ch0_wdat_clk),
    .ch0_wsop_clk (ch0_wsop_clk),
    .ch0_weop_clk (ch0_weop_clk)     
);




eth_control_ip U_eth_control_ip_1
(   
    //// test IP REG////
    .pcie_link_up           (pcie_link_up              ),
    .s_axil_test_aclk       (clk50m                    ), // changed clock according to AXI Interconnect port clock  
    .s_axil_test_aresetn    (sys_rst_n              ),                           
    .s_axil_test_awaddr     (s_axi_dynamic_ip3_awaddr  ),
    .s_axil_test_awprot     (s_axi_dynamic_ip3_awprot  ),
    .s_axil_test_awvalid    (s_axi_dynamic_ip3_awvalid ),
    .s_axil_test_awready    (s_axi_dynamic_ip3_awready ),                           
    .s_axil_test_wdata      (s_axi_dynamic_ip3_wdata   ),
    .s_axil_test_wstrb      (s_axi_dynamic_ip3_wstrb   ),
    .s_axil_test_wvalid     (s_axi_dynamic_ip3_wvalid  ),
    .s_axil_test_wready     (s_axi_dynamic_ip3_wready  ),                           
    .s_axil_test_bvalid     (s_axi_dynamic_ip3_bvalid  ),
    .s_axil_test_bresp      (s_axi_dynamic_ip3_bresp   ),
    .s_axil_test_bready     (s_axi_dynamic_ip3_bready  ),                            
    .s_axil_test_araddr     (s_axi_dynamic_ip3_araddr  ),
    .s_axil_test_arprot     (s_axi_dynamic_ip3_arprot  ),
    .s_axil_test_arvalid    (s_axi_dynamic_ip3_arvalid ),
    .s_axil_test_arready    (s_axi_dynamic_ip3_arready ),                             
    .s_axil_test_rdata      (s_axi_dynamic_ip3_rdata   ),
    .s_axil_test_rresp      (s_axi_dynamic_ip3_rresp   ),
    .s_axil_test_rvalid     (s_axi_dynamic_ip3_rvalid  ),
    .s_axil_test_rready     (s_axi_dynamic_ip3_rready  ),
    ////////////
    .sys_rst                (sys_rst                   ),   

    ////ETH////
    .clk156                 ( clk156                   ), 
    .c0_fiber_IncEnb        (          ),     
    .c1_fiber_IncEnb        (                          ),

    .ETH0_RxEN              (ETH1_RxEN                 ),
    .ETH0_TxEN              (ETH1_TxEN                 ),
    .ETH0_LOOP              (ETH1_LOOP                 ),
    .ETH0_LINK              (ETH1_LINK                 ),
                                                    
    .ETH1_RxEN              (                 ),
    .ETH1_TxEN              (                 ),
    .ETH1_LOOP              (                 ),
    .ETH1_LINK              (                 ),   
    .BASE_TIME          (      ),
    .c0_xgmii_txd_d         (c1_xgmii_txd_d            ),    
    .c0_xgmii_txc_d         (c1_xgmii_txc_d            ),    
    .c0_xgmii_rxd           (c1_xgmii_rxd              ),    
    .c0_xgmii_rxc           (c1_xgmii_rxc              ),
    .c1_xgmii_txd_d         (            ),    
    .c1_xgmii_txc_d         (            ),    
    .c1_xgmii_rxd           (            ),    
    .c1_xgmii_rxc           (            ), 
    .ch0_wlen_rx            ( ch1_wlen_rx      ),
    .ch1_wlen_rx            (       ),
    .ch0_wlen_tx            ( ch1_wlen_tx     ),
    .ch1_wlen_tx            (       ),   
    .stat_inc_d_p0_xrx      (       ),
    .stat_inc_d_p1_xrx      (       ),
    .stat_inc_d_p0_xtx      (       ),
    .stat_inc_d_p1_xtx      (       ),
    .tgbaser_c0_cfg0        (tgbaser_c1_cfg0      ),
    .tgbaser_c0_cfg1        (tgbaser_c1_cfg1      ),
    .tgbaser_c0_cfg2        (tgbaser_c1_cfg2      ),
    .tgbaser_c1_cfg0        (      ),
    .tgbaser_c1_cfg1        (      ),
    .tgbaser_c1_cfg2        (      ),                          
    .tgbaser_status         (      ),
    .tgbaser_c0_status0     (tgbaser_c1_status0       ),
    .tgbaser_c0_status1     (tgbaser_c1_status1       ),
    .tgbaser_c1_status0     (     ),
    .tgbaser_c1_status1     (     ),
    .ACT0                   (act1      ),         
    .ACT1                   (                      ),
    .byte_rate   (byte_rate_1),
    .pps_rate   (pps_rate_1),
    
    .ch0_wenb_clk (ch0_wenb_clk_1),
    .ch0_wdat_clk (ch0_wdat_clk_1),
    .ch0_wsop_clk (ch0_wsop_clk_1),
    .ch0_weop_clk (ch0_weop_clk_1)       
);


 interconnect_user_wrapper u_interconnect_user_reg
   (
    .ACLK               (clk50m                   ),
    .ARESETN            (sys_rst_n                ),
    
    .M00_ACLK           (clk50m                   ),
    .M00_ARESETN        (sys_rst_n                ),
    .M00_AXI_araddr     (s_axi_dynamic_ip0_araddr ),
    .M00_AXI_arprot     (s_axi_dynamic_ip0_arprot ),
    .M00_AXI_arready    (s_axi_dynamic_ip0_arready),
    .M00_AXI_arvalid    (s_axi_dynamic_ip0_arvalid),
    .M00_AXI_awaddr     (s_axi_dynamic_ip0_awaddr ),
    .M00_AXI_awprot     (s_axi_dynamic_ip0_awprot ),
    .M00_AXI_awready    (s_axi_dynamic_ip0_awready),
    .M00_AXI_awvalid    (s_axi_dynamic_ip0_awvalid),
    .M00_AXI_bready     (s_axi_dynamic_ip0_bready ),
    .M00_AXI_bresp      (s_axi_dynamic_ip0_bresp  ),
    .M00_AXI_bvalid     (s_axi_dynamic_ip0_bvalid ),
    .M00_AXI_rdata      (s_axi_dynamic_ip0_rdata  ),
    .M00_AXI_rready     (s_axi_dynamic_ip0_rready ),
    .M00_AXI_rresp      (s_axi_dynamic_ip0_rresp  ),
    .M00_AXI_rvalid     (s_axi_dynamic_ip0_rvalid ),
    .M00_AXI_wdata      (s_axi_dynamic_ip0_wdata  ),
    .M00_AXI_wready     (s_axi_dynamic_ip0_wready ),
    .M00_AXI_wstrb      (s_axi_dynamic_ip0_wstrb  ),
    .M00_AXI_wvalid     (s_axi_dynamic_ip0_wvalid ),
    
    .M01_ACLK           (clk50m                   ),
    .M01_ARESETN        (sys_rst_n                ),
    .M01_AXI_araddr     (s_axi_dynamic_ip1_araddr ),
    .M01_AXI_arprot     (s_axi_dynamic_ip1_arprot ),
    .M01_AXI_arready    (s_axi_dynamic_ip1_arready),
    .M01_AXI_arvalid    (s_axi_dynamic_ip1_arvalid),
    .M01_AXI_awaddr     (s_axi_dynamic_ip1_awaddr ),
    .M01_AXI_awprot     (s_axi_dynamic_ip1_awprot ),
    .M01_AXI_awready    (s_axi_dynamic_ip1_awready),
    .M01_AXI_awvalid    (s_axi_dynamic_ip1_awvalid),
    .M01_AXI_bready     (s_axi_dynamic_ip1_bready ),
    .M01_AXI_bresp      (s_axi_dynamic_ip1_bresp  ),
    .M01_AXI_bvalid     (s_axi_dynamic_ip1_bvalid ),
    .M01_AXI_rdata      (s_axi_dynamic_ip1_rdata  ),
    .M01_AXI_rready     (s_axi_dynamic_ip1_rready ),
    .M01_AXI_rresp      (s_axi_dynamic_ip1_rresp  ),
    .M01_AXI_rvalid     (s_axi_dynamic_ip1_rvalid ),
    .M01_AXI_wdata      (s_axi_dynamic_ip1_wdata  ),
    .M01_AXI_wready     (s_axi_dynamic_ip1_wready ),
    .M01_AXI_wstrb      (s_axi_dynamic_ip1_wstrb  ),
    .M01_AXI_wvalid     (s_axi_dynamic_ip1_wvalid ),
    
    .M02_ACLK           (clk50m                   ),
    .M02_ARESETN        (sys_rst_n                ),
    .M02_AXI_araddr     (s_axi_dynamic_ip2_araddr ),
    .M02_AXI_arprot     (s_axi_dynamic_ip2_arprot ),
    .M02_AXI_arready    (s_axi_dynamic_ip2_arready),
    .M02_AXI_arvalid    (s_axi_dynamic_ip2_arvalid),
    .M02_AXI_awaddr     (s_axi_dynamic_ip2_awaddr ),
    .M02_AXI_awprot     (s_axi_dynamic_ip2_awprot ),
    .M02_AXI_awready    (s_axi_dynamic_ip2_awready),
    .M02_AXI_awvalid    (s_axi_dynamic_ip2_awvalid),
    .M02_AXI_bready     (s_axi_dynamic_ip2_bready ),
    .M02_AXI_bresp      (s_axi_dynamic_ip2_bresp  ),
    .M02_AXI_bvalid     (s_axi_dynamic_ip2_bvalid ),
    .M02_AXI_rdata      (s_axi_dynamic_ip2_rdata  ),
    .M02_AXI_rready     (s_axi_dynamic_ip2_rready ),
    .M02_AXI_rresp      (s_axi_dynamic_ip2_rresp  ),
    .M02_AXI_rvalid     (s_axi_dynamic_ip2_rvalid ),
    .M02_AXI_wdata      (s_axi_dynamic_ip2_wdata  ),
    .M02_AXI_wready     (s_axi_dynamic_ip2_wready ),
    .M02_AXI_wstrb      (s_axi_dynamic_ip2_wstrb  ),
    .M02_AXI_wvalid     (s_axi_dynamic_ip2_wvalid ),
    
    .M03_ACLK           (clk50m                   ),
    .M03_ARESETN        (sys_rst_n                ),
    .M03_AXI_araddr     (s_axi_dynamic_ip3_araddr ),
    .M03_AXI_arprot     (s_axi_dynamic_ip3_arprot ),
    .M03_AXI_arready    (s_axi_dynamic_ip3_arready),
    .M03_AXI_arvalid    (s_axi_dynamic_ip3_arvalid),
    .M03_AXI_awaddr     (s_axi_dynamic_ip3_awaddr ),
    .M03_AXI_awprot     (s_axi_dynamic_ip3_awprot ),
    .M03_AXI_awready    (s_axi_dynamic_ip3_awready),
    .M03_AXI_awvalid    (s_axi_dynamic_ip3_awvalid),
    .M03_AXI_bready     (s_axi_dynamic_ip3_bready ),
    .M03_AXI_bresp      (s_axi_dynamic_ip3_bresp  ),
    .M03_AXI_bvalid     (s_axi_dynamic_ip3_bvalid ),
    .M03_AXI_rdata      (s_axi_dynamic_ip3_rdata  ),
    .M03_AXI_rready     (s_axi_dynamic_ip3_rready ),
    .M03_AXI_rresp      (s_axi_dynamic_ip3_rresp  ),
    .M03_AXI_rvalid     (s_axi_dynamic_ip3_rvalid ),
    .M03_AXI_wdata      (s_axi_dynamic_ip3_wdata  ),
    .M03_AXI_wready     (s_axi_dynamic_ip3_wready ),
    .M03_AXI_wstrb      (s_axi_dynamic_ip3_wstrb  ),
    .M03_AXI_wvalid     (s_axi_dynamic_ip3_wvalid ),
    
    .M04_ACLK           (clk50m                   ),
    .M04_ARESETN        (sys_rst_n                ),
    .M04_AXI_araddr     (s_axi_dynamic_ip4_araddr ),
    .M04_AXI_arprot     (s_axi_dynamic_ip4_arprot ),
    .M04_AXI_arready    (s_axi_dynamic_ip4_arready),
    .M04_AXI_arvalid    (s_axi_dynamic_ip4_arvalid),
    .M04_AXI_awaddr     (s_axi_dynamic_ip4_awaddr ),
    .M04_AXI_awprot     (s_axi_dynamic_ip4_awprot ),
    .M04_AXI_awready    (s_axi_dynamic_ip4_awready),
    .M04_AXI_awvalid    (s_axi_dynamic_ip4_awvalid),
    .M04_AXI_bready     (s_axi_dynamic_ip4_bready ),
    .M04_AXI_bresp      (s_axi_dynamic_ip4_bresp  ),
    .M04_AXI_bvalid     (s_axi_dynamic_ip4_bvalid ),
    .M04_AXI_rdata      (s_axi_dynamic_ip4_rdata  ),
    .M04_AXI_rready     (s_axi_dynamic_ip4_rready ),
    .M04_AXI_rresp      (s_axi_dynamic_ip4_rresp  ),
    .M04_AXI_rvalid     (s_axi_dynamic_ip4_rvalid ),
    .M04_AXI_wdata      (s_axi_dynamic_ip4_wdata  ),
    .M04_AXI_wready     (s_axi_dynamic_ip4_wready ),
    .M04_AXI_wstrb      (s_axi_dynamic_ip4_wstrb  ),
    .M04_AXI_wvalid     (s_axi_dynamic_ip4_wvalid ),
    
    .M05_ACLK           (clk50m                   ),
    .M05_ARESETN        (sys_rst_n                ),
    .M05_AXI_araddr     (s_axi_dynamic_ip5_araddr ),
    .M05_AXI_arprot     (s_axi_dynamic_ip5_arprot ),
    .M05_AXI_arready    (s_axi_dynamic_ip5_arready),
    .M05_AXI_arvalid    (s_axi_dynamic_ip5_arvalid),
    .M05_AXI_awaddr     (s_axi_dynamic_ip5_awaddr ),
    .M05_AXI_awprot     (s_axi_dynamic_ip5_awprot ),
    .M05_AXI_awready    (s_axi_dynamic_ip5_awready),
    .M05_AXI_awvalid    (s_axi_dynamic_ip5_awvalid),
    .M05_AXI_bready     (s_axi_dynamic_ip5_bready ),
    .M05_AXI_bresp      (s_axi_dynamic_ip5_bresp  ),
    .M05_AXI_bvalid     (s_axi_dynamic_ip5_bvalid ),
    .M05_AXI_rdata      (s_axi_dynamic_ip5_rdata  ),
    .M05_AXI_rready     (s_axi_dynamic_ip5_rready ),
    .M05_AXI_rresp      (s_axi_dynamic_ip5_rresp  ),
    .M05_AXI_rvalid     (s_axi_dynamic_ip5_rvalid ),
    .M05_AXI_wdata      (s_axi_dynamic_ip5_wdata  ),
    .M05_AXI_wready     (s_axi_dynamic_ip5_wready ),
    .M05_AXI_wstrb      (s_axi_dynamic_ip5_wstrb  ),
    .M05_AXI_wvalid     (s_axi_dynamic_ip5_wvalid ),
    
    .M06_ACLK           (clk50m                   ),
    .M06_ARESETN        (sys_rst_n                ),
    .M06_AXI_araddr     (s_axi_dynamic_ip6_araddr ),
    .M06_AXI_arprot     (s_axi_dynamic_ip6_arprot ),
    .M06_AXI_arready    (s_axi_dynamic_ip6_arready),
    .M06_AXI_arvalid    (s_axi_dynamic_ip6_arvalid),
    .M06_AXI_awaddr     (s_axi_dynamic_ip6_awaddr ),
    .M06_AXI_awprot     (s_axi_dynamic_ip6_awprot ),
    .M06_AXI_awready    (s_axi_dynamic_ip6_awready),
    .M06_AXI_awvalid    (s_axi_dynamic_ip6_awvalid),
    .M06_AXI_bready     (s_axi_dynamic_ip6_bready ),
    .M06_AXI_bresp      (s_axi_dynamic_ip6_bresp  ),
    .M06_AXI_bvalid     (s_axi_dynamic_ip6_bvalid ),
    .M06_AXI_rdata      (s_axi_dynamic_ip6_rdata  ),
    .M06_AXI_rready     (s_axi_dynamic_ip6_rready ),
    .M06_AXI_rresp      (s_axi_dynamic_ip6_rresp  ),
    .M06_AXI_rvalid     (s_axi_dynamic_ip6_rvalid ),
    .M06_AXI_wdata      (s_axi_dynamic_ip6_wdata  ),
    .M06_AXI_wready     (s_axi_dynamic_ip6_wready ),
    .M06_AXI_wstrb      (s_axi_dynamic_ip6_wstrb  ),
    .M06_AXI_wvalid     (s_axi_dynamic_ip6_wvalid ),
    
    .M07_ACLK           (clk50m                   ),
    .M07_ARESETN        (sys_rst_n                ),
    .M07_AXI_araddr     (s_axi_dynamic_ip7_araddr ),
    .M07_AXI_arprot     (s_axi_dynamic_ip7_arprot ),
    .M07_AXI_arready    (s_axi_dynamic_ip7_arready),
    .M07_AXI_arvalid    (s_axi_dynamic_ip7_arvalid),
    .M07_AXI_awaddr     (s_axi_dynamic_ip7_awaddr ),
    .M07_AXI_awprot     (s_axi_dynamic_ip7_awprot ),
    .M07_AXI_awready    (s_axi_dynamic_ip7_awready),
    .M07_AXI_awvalid    (s_axi_dynamic_ip7_awvalid),
    .M07_AXI_bready     (s_axi_dynamic_ip7_bready ),
    .M07_AXI_bresp      (s_axi_dynamic_ip7_bresp  ),
    .M07_AXI_bvalid     (s_axi_dynamic_ip7_bvalid ),
    .M07_AXI_rdata      (s_axi_dynamic_ip7_rdata  ),
    .M07_AXI_rready     (s_axi_dynamic_ip7_rready ),
    .M07_AXI_rresp      (s_axi_dynamic_ip7_rresp  ),
    .M07_AXI_rvalid     (s_axi_dynamic_ip7_rvalid ),
    .M07_AXI_wdata      (s_axi_dynamic_ip7_wdata  ),
    .M07_AXI_wready     (s_axi_dynamic_ip7_wready ),
    .M07_AXI_wstrb      (s_axi_dynamic_ip7_wstrb  ),
    .M07_AXI_wvalid     (s_axi_dynamic_ip7_wvalid ),
    
    .M08_ACLK           (clk50m                   ),
    .M08_ARESETN        (sys_rst_n                ),
    .M08_AXI_araddr     (s_axi_dynamic_ip8_araddr ),
    .M08_AXI_arprot     (s_axi_dynamic_ip8_arprot ),
    .M08_AXI_arready    (s_axi_dynamic_ip8_arready),
    .M08_AXI_arvalid    (s_axi_dynamic_ip8_arvalid),
    .M08_AXI_awaddr     (s_axi_dynamic_ip8_awaddr ),
    .M08_AXI_awprot     (s_axi_dynamic_ip8_awprot ),
    .M08_AXI_awready    (s_axi_dynamic_ip8_awready),
    .M08_AXI_awvalid    (s_axi_dynamic_ip8_awvalid),
    .M08_AXI_bready     (s_axi_dynamic_ip8_bready ),
    .M08_AXI_bresp      (s_axi_dynamic_ip8_bresp  ),
    .M08_AXI_bvalid     (s_axi_dynamic_ip8_bvalid ),
    .M08_AXI_rdata      (s_axi_dynamic_ip8_rdata  ),
    .M08_AXI_rready     (s_axi_dynamic_ip8_rready ),
    .M08_AXI_rresp      (s_axi_dynamic_ip8_rresp  ),
    .M08_AXI_rvalid     (s_axi_dynamic_ip8_rvalid ),
    .M08_AXI_wdata      (s_axi_dynamic_ip8_wdata  ),
    .M08_AXI_wready     (s_axi_dynamic_ip8_wready ),
    .M08_AXI_wstrb      (s_axi_dynamic_ip8_wstrb  ),
    .M08_AXI_wvalid     (s_axi_dynamic_ip8_wvalid ),
    
    .M09_ACLK           (clk50m                   ),
    .M09_ARESETN        (sys_rst_n                ),
    .M09_AXI_araddr     (s_axi_dynamic_ip9_araddr ),
    .M09_AXI_arprot     (s_axi_dynamic_ip9_arprot ),
    .M09_AXI_arready    (s_axi_dynamic_ip9_arready),
    .M09_AXI_arvalid    (s_axi_dynamic_ip9_arvalid),
    .M09_AXI_awaddr     (s_axi_dynamic_ip9_awaddr ),
    .M09_AXI_awprot     (s_axi_dynamic_ip9_awprot ),
    .M09_AXI_awready    (s_axi_dynamic_ip9_awready),
    .M09_AXI_awvalid    (s_axi_dynamic_ip9_awvalid),
    .M09_AXI_bready     (s_axi_dynamic_ip9_bready ),
    .M09_AXI_bresp      (s_axi_dynamic_ip9_bresp  ),
    .M09_AXI_bvalid     (s_axi_dynamic_ip9_bvalid ),
    .M09_AXI_rdata      (s_axi_dynamic_ip9_rdata  ),
    .M09_AXI_rready     (s_axi_dynamic_ip9_rready ),
    .M09_AXI_rresp      (s_axi_dynamic_ip9_rresp  ),
    .M09_AXI_rvalid     (s_axi_dynamic_ip9_rvalid ),
    .M09_AXI_wdata      (s_axi_dynamic_ip9_wdata  ),
    .M09_AXI_wready     (s_axi_dynamic_ip9_wready ),
    .M09_AXI_wstrb      (s_axi_dynamic_ip9_wstrb  ),
    .M09_AXI_wvalid     (s_axi_dynamic_ip9_wvalid ),
    
    .S00_ACLK           (clk50m                   ),
    .S00_ARESETN        (sys_rst_n                ),
    .S00_AXI_araddr     (s_axil_dynamic_araddr     ),
    .S00_AXI_arprot     (s_axil_dynamic_arprot     ),
    .S00_AXI_arready    (s_axil_dynamic_arready    ),
    .S00_AXI_arvalid    (s_axil_dynamic_arvalid    ),
    .S00_AXI_awaddr     (s_axil_dynamic_awaddr     ),
    .S00_AXI_awprot     (s_axil_dynamic_awprot     ),
    .S00_AXI_awready    (s_axil_dynamic_awready    ),
    .S00_AXI_awvalid    (s_axil_dynamic_awvalid    ),
    .S00_AXI_bready     (s_axil_dynamic_bready     ),
    .S00_AXI_bresp      (s_axil_dynamic_bresp      ),
    .S00_AXI_bvalid     (s_axil_dynamic_bvalid     ),
    .S00_AXI_rdata      (s_axil_dynamic_rdata      ),
    .S00_AXI_rready     (s_axil_dynamic_rready     ),
    .S00_AXI_rresp      (s_axil_dynamic_rresp      ),
    .S00_AXI_rvalid     (s_axil_dynamic_rvalid     ),
    .S00_AXI_wdata      (s_axil_dynamic_wdata      ),
    .S00_AXI_wready     (s_axil_dynamic_wready     ),
    .S00_AXI_wstrb      (s_axil_dynamic_wstrb      ),
    .S00_AXI_wvalid     (s_axil_dynamic_wvalid     ) 
    );
    
            
//-----------------------------dsp
reg [63:0]    count_clock;
wire [63:0]    clkwdat;

assign clkwdat[63:0] = count_clock;



always @ (posedge clk156 or posedge sys_rst)
begin
    if(sys_rst)
    begin
    count_clock[63:0] <= 0;
    end
    else if(group0_timeset_done)
    begin
        count_clock[63:0] <= 0;
    end
    else if(count_clock[63:0] == {8{8'hff}})
        count_clock[63:0] <= 0;
    else 
        count_clock[63:0] <= count_clock[63:0] + 1'b1;
end	

dsp_rx_top U0_dsp_rx_top
(
    .clk156(clk156),
    .clk250m(c0_ddr4_ui_clk),
    .rst(sys_rst),

    .ch0_wdat_loop(ch0_wdat_clk),
    .ch0_wenb_loop(ch0_wenb_clk),
    .ch0_wsop_loop(ch0_wsop_clk),
    .ch0_weop_loop(ch0_weop_clk),
    .ch0_wlen_tx(ch0_wlen_rx),
    .clkwdat(clkwdat),
    .BASE_TIME(BASE_TIME),
    .group0_test_en(group0_test_en),
    .flush_i(flush_i),
    .flush_done(flush_done),
    .align_done(align_done),
    
    .active_i(1'b1),         
    .fifo_dout(fifo_dout),
    .fifo_wr_en(fifo_wr_en),
    .fifo_rd_en(fifo_rd_en),
    .fifo_empty(fifo_empty),
    .fifo_prog_empty(fifo_prog_empty),
    .fifo_rd_data_count(fifo_rd_data_count)
);

dsp_rx_top U1_dsp_rx_top
(
    .clk156(clk156),
    .clk250m(c1_ddr4_ui_clk),
    .rst(sys_rst),

    .ch0_wdat_loop(ch0_wdat_clk_1),
    .ch0_wenb_loop(ch0_wenb_clk_1),
    .ch0_wsop_loop(ch0_wsop_clk_1),
    .ch0_weop_loop(ch0_weop_clk_1),
    .ch0_wlen_tx(ch1_wlen_rx),
    .clkwdat(clkwdat),
    .BASE_TIME(BASE_TIME),
    .group0_test_en(group0_test_en),
    .flush_i(flush_i_1),
    .flush_done(flush_done_1),
    .align_done(align_done_1),
    
    .active_i(1'b1),         
    .fifo_dout(fifo_dout_1),
    .fifo_wr_en(fifo_wr_en_1),
    .fifo_rd_en(fifo_rd_en_1),
    .fifo_empty(fifo_empty_1),
    .fifo_prog_empty(fifo_prog_empty_1),
    .fifo_rd_data_count(fifo_rd_data_count_1)
);
           
dsp_tx_top  U0_dsp_tx_top
(
    .rst(sys_rst)   ,     
    .clk250(c0_ddr4_ui_clk),
    .clk156(clk156),
    .tx_data(tx_data),
    .tx_enable(tx_enable),
    .prog_full_r(output_enable),
    .active_i(group0_test_en),
    .xgmii_txd(xgmii_txd          ),
    .xgmii_txc(xgmii_txc          ),
    .byte_rate(byte_rate),
    .pps_rate(pps_rate)
);

dsp_tx_top  U1_dsp_tx_top
(
    .rst(sys_rst)   ,     
    .clk250(c1_ddr4_ui_clk),
    .clk156(clk156),
    .tx_data(tx_data_1),
    .tx_enable(tx_enable_1),
    .prog_full_r(output_enable_1),
    .active_i(group0_test_en),
    .xgmii_txd (xgmii_txd_1          ),
    .xgmii_txc (xgmii_txc_1          ),
    .byte_rate    (byte_rate_1),
    .pps_rate     (pps_rate_1)
);

 endmodule

