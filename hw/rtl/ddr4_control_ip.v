
`include "define.v"
module ddr4_control_ip(
     input  wire           pcie_link_up         ,
     input  wire           s_axil_test_aclk      ,  
     input  wire           s_axil_test_aresetn   ,
                                  
     input  wire [31 : 0]  s_axil_test_awaddr    ,
     input  wire [2 : 0]   s_axil_test_awprot    ,
     input  wire           s_axil_test_awvalid   ,
     output wire           s_axil_test_awready   ,
                                  
     input  wire [31 : 0]  s_axil_test_wdata     ,
     input  wire [3 : 0]   s_axil_test_wstrb     ,
     input  wire           s_axil_test_wvalid    ,
     output wire           s_axil_test_wready    ,
                                  
     output wire           s_axil_test_bvalid    ,
     output wire [1 : 0]   s_axil_test_bresp     ,
     input  wire           s_axil_test_bready    ,
                                  
     input  wire [31 : 0]  s_axil_test_araddr    ,
     input  wire [2 : 0]   s_axil_test_arprot    ,
     input  wire           s_axil_test_arvalid   ,
     output wire           s_axil_test_arready   ,
                                  
     output wire [31 : 0]  s_axil_test_rdata     ,
     output wire [1 : 0]   s_axil_test_rresp     ,
     output wire           s_axil_test_rvalid    ,
     input  wire           s_axil_test_rready    ,
     
     input  wire          sys_rst                ,
     //DDR4//
     input  wire            c0_ddr4_ui_clk           ,     
     
     input wire clk156,  
       
     input  wire            c0_ddr4_ui_clk_sync_rst  ,
     input  wire            c0_init_calib_complete   ,
     output  wire[3 : 0]    test_axi_c0_awid         ,      
     output  wire[63 : 0]   test_axi_c0_awaddr       ,
     output  wire[7 : 0]    test_axi_c0_awlen        ,
     output  wire[2 : 0]    test_axi_c0_awsize       ,
     output  wire[1 : 0]    test_axi_c0_awburst      ,
     output  wire           test_axi_c0_awlock       ,
     output  wire[3 : 0]    test_axi_c0_awcache      ,
     output  wire[2 : 0]    test_axi_c0_awprot       ,
     output  wire           test_axi_c0_awvalid      ,
     input  wire            test_axi_c0_awready      ,
     output  wire[511 : 0]  test_axi_c0_wdata        ,
     output  wire[63 : 0]   test_axi_c0_wstrb        ,
     output  wire           test_axi_c0_wlast        ,
     output  wire           test_axi_c0_wvalid       ,
     input   wire           test_axi_c0_wready       ,
     input   wire[3 : 0]    test_axi_c0_bid          ,
     input   wire[1 : 0]    test_axi_c0_bresp        ,
     input   wire           test_axi_c0_bvalid       ,
     output  wire           test_axi_c0_bready       ,
     output  wire[3 : 0]    test_axi_c0_arid         ,
     output  wire[63 : 0]   test_axi_c0_araddr       ,
     output  wire[7 : 0]    test_axi_c0_arlen        ,
     output  wire[2 : 0]    test_axi_c0_arsize       ,
     output  wire[1 : 0]    test_axi_c0_arburst      ,
     output  wire           test_axi_c0_arlock       ,
     output  wire[3 : 0]    test_axi_c0_arcache      ,
     output  wire[2 : 0]    test_axi_c0_arprot       ,
     output  wire           test_axi_c0_arvalid      ,
     input   wire           test_axi_c0_arready      ,
     input   wire[3 : 0]    test_axi_c0_rid          ,
     input   wire[511 : 0]  test_axi_c0_rdata        ,
     input   wire[1 : 0]    test_axi_c0_rresp        ,
     input   wire           test_axi_c0_rlast        ,
     input   wire           test_axi_c0_rvalid       ,
     output  wire           test_axi_c0_rready       ,
     output wire       group0_test_en,
     output wire       group0_timeset_done,
     
     input wire[511:0] input_eth0_data,
     output wire  Read_eth0_fifo_enable,
     input wire ch0_wenb_loop,
     input wire empty,
     input wire prog_empty,
     input wire [10:0] rd_data_count,
     input wire flush,
     input wire align_done,
     output wire flush_done,
     
     output wire[511:0]  tx_data,
     output wire  tx_enable,
     input wire output_enable,
     
     input  wire            c1_ddr4_ui_clk           ,       
     input  wire            c1_ddr4_ui_clk_sync_rst  ,
     input  wire            c1_init_calib_complete   ,
     output  wire[3 : 0]    test_axi_c1_awid         ,      
     output  wire[63 : 0]   test_axi_c1_awaddr       ,
     output  wire[7 : 0]    test_axi_c1_awlen        ,
     output  wire[2 : 0]    test_axi_c1_awsize       ,
     output  wire[1 : 0]    test_axi_c1_awburst      ,
     output  wire           test_axi_c1_awlock       ,
     output  wire[3 : 0]    test_axi_c1_awcache      ,
     output  wire[2 : 0]    test_axi_c1_awprot       ,
     output  wire           test_axi_c1_awvalid      ,
     input  wire            test_axi_c1_awready      ,
     output  wire[511 : 0]  test_axi_c1_wdata        ,
     output  wire[63 : 0]   test_axi_c1_wstrb        ,
     output  wire           test_axi_c1_wlast        ,
     output  wire           test_axi_c1_wvalid       ,
     input   wire           test_axi_c1_wready       ,
     input   wire[3 : 0]    test_axi_c1_bid          ,
     input   wire[1 : 0]    test_axi_c1_bresp        ,
     input   wire           test_axi_c1_bvalid       ,
     output  wire           test_axi_c1_bready       ,
     output  wire[3 : 0]    test_axi_c1_arid         ,
     output  wire[63 : 0]   test_axi_c1_araddr       ,
     output  wire[7 : 0]    test_axi_c1_arlen        ,
     output  wire[2 : 0]    test_axi_c1_arsize       ,
     output  wire[1 : 0]    test_axi_c1_arburst      ,
     output  wire           test_axi_c1_arlock       ,
     output  wire[3 : 0]    test_axi_c1_arcache      ,
     output  wire[2 : 0]    test_axi_c1_arprot       ,
     output  wire           test_axi_c1_arvalid      ,
     input   wire           test_axi_c1_arready      ,
     input   wire[3 : 0]    test_axi_c1_rid          ,
     input   wire[511 : 0]  test_axi_c1_rdata        ,
     input   wire[1 : 0]    test_axi_c1_rresp        ,
     input   wire           test_axi_c1_rlast        ,
     input   wire           test_axi_c1_rvalid       ,
     output  wire           test_axi_c1_rready       ,
     
          input wire[511:0] input_eth0_data_1,
          output wire  Read_eth0_fifo_enable_1,
          input wire ch0_wenb_loop_1,
          input wire empty_1,
          input wire prog_empty_1,
          input wire [10:0] rd_data_count_1,
          input wire flush_1,
          input wire align_done_1,
          output wire flush_done_1,
       
         output wire[511:0]  tx_data_1,
          output wire  tx_enable_1,
          input wire output_enable_1,
     
     input  wire            c2_ddr4_ui_clk           ,       
     input  wire            c2_ddr4_ui_clk_sync_rst  ,
     input  wire            c2_init_calib_complete   ,
     output  wire[3 : 0]    test_axi_c2_awid         ,      
     output  wire[63 : 0]   test_axi_c2_awaddr       ,
     output  wire[7 : 0]    test_axi_c2_awlen        ,
     output  wire[2 : 0]    test_axi_c2_awsize       ,
     output  wire[1 : 0]    test_axi_c2_awburst      ,
     output  wire           test_axi_c2_awlock       ,
     output  wire[3 : 0]    test_axi_c2_awcache      ,
     output  wire[2 : 0]    test_axi_c2_awprot       ,
     output  wire           test_axi_c2_awvalid      ,
     input  wire            test_axi_c2_awready      ,
     output  wire[511 : 0]  test_axi_c2_wdata        ,
     output  wire[63 : 0]   test_axi_c2_wstrb        ,
     output  wire           test_axi_c2_wlast        ,
     output  wire           test_axi_c2_wvalid       ,
     input   wire           test_axi_c2_wready       ,
     input   wire[3 : 0]    test_axi_c2_bid          ,
     input   wire[1 : 0]    test_axi_c2_bresp        ,
     input   wire           test_axi_c2_bvalid       ,
     output  wire           test_axi_c2_bready       ,
     output  wire[3 : 0]    test_axi_c2_arid         ,
     output  wire[63 : 0]   test_axi_c2_araddr       ,
     output  wire[7 : 0]    test_axi_c2_arlen        ,
     output  wire[2 : 0]    test_axi_c2_arsize       ,
     output  wire[1 : 0]    test_axi_c2_arburst      ,
     output  wire           test_axi_c2_arlock       ,
     output  wire[3 : 0]    test_axi_c2_arcache      ,
     output  wire[2 : 0]    test_axi_c2_arprot       ,
     output  wire           test_axi_c2_arvalid      ,
     input   wire           test_axi_c2_arready      ,
     input   wire[3 : 0]    test_axi_c2_rid          ,
     input   wire[511 : 0]  test_axi_c2_rdata        ,
     input   wire[1 : 0]    test_axi_c2_rresp        ,
     input   wire           test_axi_c2_rlast        ,
     input   wire           test_axi_c2_rvalid       ,
     output  wire           test_axi_c2_rready       ,
     
     input  wire            c3_ddr4_ui_clk           ,       
     input  wire            c3_ddr4_ui_clk_sync_rst  ,
     input  wire            c3_init_calib_complete   ,
     output  wire[3 : 0]    test_axi_c3_awid         ,      
     output  wire[63 : 0]   test_axi_c3_awaddr       ,
     output  wire[7 : 0]    test_axi_c3_awlen        ,
     output  wire[2 : 0]    test_axi_c3_awsize       ,
     output  wire[1 : 0]    test_axi_c3_awburst      ,
     output  wire           test_axi_c3_awlock       ,
     output  wire[3 : 0]    test_axi_c3_awcache      ,
     output  wire[2 : 0]    test_axi_c3_awprot       ,
     output  wire           test_axi_c3_awvalid      ,
     input  wire            test_axi_c3_awready      ,
     output  wire[511 : 0]  test_axi_c3_wdata        ,
     output  wire[63 : 0]   test_axi_c3_wstrb        ,
     output  wire           test_axi_c3_wlast        ,
     output  wire           test_axi_c3_wvalid       ,
     input   wire           test_axi_c3_wready       ,
     input   wire[3 : 0]    test_axi_c3_bid          ,
     input   wire[1 : 0]    test_axi_c3_bresp        ,
     input   wire           test_axi_c3_bvalid       ,
     output  wire           test_axi_c3_bready       ,
     output  wire[3 : 0]    test_axi_c3_arid         ,
     output  wire[63 : 0]   test_axi_c3_araddr       ,
     output  wire[7 : 0]    test_axi_c3_arlen        ,
     output  wire[2 : 0]    test_axi_c3_arsize       ,
     output  wire[1 : 0]    test_axi_c3_arburst      ,
     output  wire           test_axi_c3_arlock       ,
     output  wire[3 : 0]    test_axi_c3_arcache      ,
     output  wire[2 : 0]    test_axi_c3_arprot       ,
     output  wire           test_axi_c3_arvalid      ,
     input   wire           test_axi_c3_arready      ,
     input   wire[3 : 0]    test_axi_c3_rid          ,
     input   wire[511 : 0]  test_axi_c3_rdata        ,
     input   wire[1 : 0]    test_axi_c3_rresp        ,
     input   wire           test_axi_c3_rlast        ,
     input   wire           test_axi_c3_rvalid       ,
     output  wire           test_axi_c3_rready       
 );    
wire                   sirsel                     ;
wire [31:0]            siraddr                    ;
wire                   sirread                    ;
wire [31:0]            sirwdat                    ;
wire [31:0]            sirrdat                    ;
wire                   sirdack                    ;  
 
 ////DDR4////
// wire                        group0_test_en      ;        
 wire                          group0_dma_done;
 wire [1:0]                  group0_mode         ;           
 wire [7:0]                  group0_times        ;          
 wire                        group0_test_done    ;      
 wire                        group0_test_flag    ;      
 wire [8:0]                  group0_err          ;
 wire    [31:0]              group0_wr_ms        ;
 reg    [31:0]              group0_rd_ms        ;
 wire    [31:0]              group0_test_cnt     ;
 wire  [31:0]              group0_ctrl_addr_wr;
                          
 wire                        group1_test_en      ;        
 wire [1:0]                  group1_mode         ;           
 wire [7:0]                  group1_times        ;          
 wire                        group1_test_done    ;      
 wire                        group1_test_flag    ;      
 wire  [8:0]                 group1_err          ;
 wire    [31:0]              group1_wr_ms        ;
 reg     [31:0]              group1_rd_ms        ;
 wire    [31:0]              group1_test_cnt     ;
 wire  [31:0]              group1_ctrl_addr_wr;
 
 wire                        group2_test_en      ;        
 wire [1:0]                  group2_mode         ;           
 wire [7:0]                  group2_times        ;          
 wire                        group2_test_done    ;      
 wire                        group2_test_flag    ;      
 wire [8:0]                  group2_err          ;
 wire    [31:0]              group2_wr_ms        ;
 wire    [31:0]              group2_rd_ms        ;
 wire    [31:0]              group2_test_cnt     ;
                          
 wire                        group3_test_en      ;        
 wire [1:0]                  group3_mode         ;           
 wire [7:0]                  group3_times        ;          
 wire                        group3_test_done    ;      
 wire                        group3_test_flag    ;      
 wire  [8:0]                 group3_err          ;
 wire    [31:0]              group3_wr_ms        ;
 wire    [31:0]              group3_rd_ms        ;
 wire    [31:0]              group3_test_cnt     ;
  assign test_axi_c0_awaddr[63:33]=31'h0;
  assign test_axi_c1_awaddr[63:33]=31'h1;
  assign test_axi_c2_awaddr[63:33]=31'h2;
  assign test_axi_c3_awaddr[63:33]=31'h3;
  
  assign test_axi_c0_araddr[63:33]=31'h0; 
  assign test_axi_c1_araddr[63:33]=31'h1;
  assign test_axi_c2_araddr[63:33]=31'h2; 
  assign test_axi_c3_araddr[63:33]=31'h3;
  
  reg [31:0] axi_awaddr_c0;
  reg [31:0] axi_awaddr_c1;
 always @(posedge sys_rst or posedge s_axil_test_aclk)
  begin
     if(sys_rst || !group0_test_en)
     begin
         group0_rd_ms <= 32'h0;
         group1_rd_ms <= 32'h0;
         axi_awaddr_c0 <= 32'h0;
         axi_awaddr_c1 <= 32'h0;
         end
     else
     begin
         axi_awaddr_c0 <= {5'b0,test_axi_c0_awaddr[32:6]};
         group0_rd_ms <= axi_awaddr_c0;
         axi_awaddr_c1 <= {5'b0,test_axi_c1_awaddr[32:6]};
         group1_rd_ms <= axi_awaddr_c1;
         end
  end   
  
  mem_wr_rd U0_mem_wr_rd(
    .rst                (c0_ddr4_ui_clk_sync_rst ),
    .clk                (c0_ddr4_ui_clk          ),   
   //  .clk                (clk156          ),      
   
    .m_axi_awid         (test_axi_c0_awid        ),
    .m_axi_awaddr       (test_axi_c0_awaddr[32:0]),
    .m_axi_awlen        (test_axi_c0_awlen       ),
    .m_axi_awsize       (test_axi_c0_awsize      ),
    .m_axi_awburst      (test_axi_c0_awburst     ),
    .m_axi_awlock       (test_axi_c0_awlock      ),
    .m_axi_awcache      (test_axi_c0_awcache     ),
    .m_axi_awprot       (test_axi_c0_awprot      ),
    .m_axi_awvalid      (test_axi_c0_awvalid     ),
    .m_axi_awready      (test_axi_c0_awready     ),
    .m_axi_wdata        (test_axi_c0_wdata       ),
    .m_axi_wstrb        (test_axi_c0_wstrb       ),
    .m_axi_wlast        (test_axi_c0_wlast       ),
    .m_axi_wvalid       (test_axi_c0_wvalid      ),
    .m_axi_wready       (test_axi_c0_wready      ),
    .m_axi_bid          (test_axi_c0_bid         ),
    .m_axi_bresp        (test_axi_c0_bresp       ),
    .m_axi_bvalid       (test_axi_c0_bvalid      ),
    .m_axi_bready       (test_axi_c0_bready      ),
    
    .m_axi_arid         (test_axi_c0_arid        ),
    .m_axi_araddr       (test_axi_c0_araddr[32:0]),
    .m_axi_arlen        (test_axi_c0_arlen       ),
    .m_axi_arsize       (test_axi_c0_arsize      ),
    .m_axi_arburst      (test_axi_c0_arburst     ),
    .m_axi_arlock       (test_axi_c0_arlock      ),
    .m_axi_arcache      (test_axi_c0_arcache     ),
    .m_axi_arprot       (test_axi_c0_arprot      ),
    .m_axi_arvalid      (test_axi_c0_arvalid     ),
    .m_axi_arready      (test_axi_c0_arready     ),
    .m_axi_rid          (test_axi_c0_rid         ),
    .m_axi_rdata        (test_axi_c0_rdata       ),
    .m_axi_rresp        (test_axi_c0_rresp       ),
    .m_axi_rlast        (test_axi_c0_rlast       ),
    .m_axi_rvalid       (test_axi_c0_rvalid      ),
    .m_axi_rready       (test_axi_c0_rready      ),         
    .fifo_dout_i         (input_eth0_data),
    .fifo_empty_i       (empty),
    .fifo_rd_data_count_i(rd_data_count),
    .fifo_prog_empty_i     (prog_empty),   
    .fifo_rd_en_o       (Read_eth0_fifo_enable),
    .mem_range_i (64'hffffffff),
    .addr_wr_o(),
    .active_i (group0_test_en),
    .flush_i (flush),
    .align_done_i(align_done),
    .flush_done_o(flush_done),
 //tx dsp   
    .fifo_din(tx_data),
    .fifo_wr_en(tx_enable),
    .fifo_prog_full(output_enable),
    
    .ctrl_addr_wr(group0_ctrl_addr_wr),
     
    .test_cnt           (group0_test_cnt ), //ctrl_addr_rd
    
    .wr_ms              (    )
);

 mem_wr_rd  U1_mem_wr_rd(
    .rst                (c1_ddr4_ui_clk_sync_rst ),
     .clk                (c1_ddr4_ui_clk          ),   
  //   .clk                (clk156          ),      
   
    .m_axi_awid         (test_axi_c1_awid        ),
    .m_axi_awaddr       (test_axi_c1_awaddr[32:0]),
    .m_axi_awlen        (test_axi_c1_awlen       ),
    .m_axi_awsize       (test_axi_c1_awsize      ),
    .m_axi_awburst      (test_axi_c1_awburst     ),
    .m_axi_awlock       (test_axi_c1_awlock      ),
    .m_axi_awcache      (test_axi_c1_awcache     ),
    .m_axi_awprot       (test_axi_c1_awprot      ),
    .m_axi_awvalid      (test_axi_c1_awvalid     ),
    .m_axi_awready      (test_axi_c1_awready     ),
    .m_axi_wdata        (test_axi_c1_wdata       ),
    .m_axi_wstrb        (test_axi_c1_wstrb       ),
    .m_axi_wlast        (test_axi_c1_wlast       ),
    .m_axi_wvalid       (test_axi_c1_wvalid      ),
    .m_axi_wready       (test_axi_c1_wready      ),
    .m_axi_bid          (test_axi_c1_bid         ),
    .m_axi_bresp        (test_axi_c1_bresp       ),
    .m_axi_bvalid       (test_axi_c1_bvalid      ),
    .m_axi_bready       (test_axi_c1_bready      ),
    .m_axi_arid         (test_axi_c1_arid        ),
    .m_axi_araddr       (test_axi_c1_araddr[32:0]),
    .m_axi_arlen        (test_axi_c1_arlen       ),
    .m_axi_arsize       (test_axi_c1_arsize      ),
    .m_axi_arburst      (test_axi_c1_arburst     ),
    .m_axi_arlock       (test_axi_c1_arlock      ),
    .m_axi_arcache      (test_axi_c1_arcache     ),
    .m_axi_arprot       (test_axi_c1_arprot      ),
    .m_axi_arvalid      (test_axi_c1_arvalid     ),
    .m_axi_arready      (test_axi_c1_arready     ),
    .m_axi_rid          (test_axi_c1_rid         ),
    .m_axi_rdata        (test_axi_c1_rdata       ),
    .m_axi_rresp        (test_axi_c1_rresp       ),
    .m_axi_rlast        (test_axi_c1_rlast       ),
    .m_axi_rvalid       (test_axi_c1_rvalid      ),
    .m_axi_rready       (test_axi_c1_rready      ),            
   /* .init_calib_complete(c1_init_calib_complete  ),
    .test_en            (group0_test_en  ),      
    .mode               (group0_mode     ),         
    .times              (group0_times    ),*/
    .fifo_dout_i         (input_eth0_data_1),
    .fifo_empty_i       (empty_1),
    .fifo_rd_data_count_i(rd_data_count_1),
    .fifo_prog_empty_i     (prog_empty_1),   
    .fifo_rd_en_o       (Read_eth0_fifo_enable_1),
    .mem_range_i (64'hffffffff),
    .addr_wr_o(),
    .active_i (group0_test_en),
    .flush_i (flush_1),
    .align_done_i(align_done_1),
    .flush_done_o(flush_done_1),
    .wr_ms              (group1_wr_ms    ),
    
     //tx dsp   
       .fifo_din(tx_data_1),
       .fifo_wr_en(tx_enable_1),
       .fifo_prog_full(output_enable_1),
       
       .ctrl_addr_wr(group1_ctrl_addr_wr),
        
       .test_cnt           (group1_test_cnt ) //ctrl_addr_rd

);

ddr4_test U2_ddr4_test(
    .rst                (c2_ddr4_ui_clk_sync_rst ),
    .clk                (c2_ddr4_ui_clk          ),      
    .m_axi_awid         (test_axi_c2_awid        ),
    .m_axi_awaddr       (test_axi_c2_awaddr[32:0] ),
    .m_axi_awlen        (test_axi_c2_awlen       ),
    .m_axi_awsize       (test_axi_c2_awsize      ),
    .m_axi_awburst      (test_axi_c2_awburst     ),
    .m_axi_awlock       (test_axi_c2_awlock      ),
    .m_axi_awcache      (test_axi_c2_awcache     ),
    .m_axi_awprot       (test_axi_c2_awprot      ),
    .m_axi_awvalid      (test_axi_c2_awvalid     ),
    .m_axi_awready      (test_axi_c2_awready     ),
    .m_axi_wdata        (test_axi_c2_wdata       ),
    .m_axi_wstrb        (test_axi_c2_wstrb       ),
    .m_axi_wlast        (test_axi_c2_wlast       ),
    .m_axi_wvalid       (test_axi_c2_wvalid      ),
    .m_axi_wready       (test_axi_c2_wready      ),
    .m_axi_bid          (test_axi_c2_bid         ),
    .m_axi_bresp        (test_axi_c2_bresp       ),
    .m_axi_bvalid       (test_axi_c2_bvalid      ),
    .m_axi_bready       (test_axi_c2_bready      ),
    .m_axi_arid         (test_axi_c2_arid        ),
    .m_axi_araddr       (test_axi_c2_araddr[32:0]),
    .m_axi_arlen        (test_axi_c2_arlen       ),
    .m_axi_arsize       (test_axi_c2_arsize      ),
    .m_axi_arburst      (test_axi_c2_arburst     ),
    .m_axi_arlock       (test_axi_c2_arlock      ),
    .m_axi_arcache      (test_axi_c2_arcache     ),
    .m_axi_arprot       (test_axi_c2_arprot      ),
    .m_axi_arvalid      (test_axi_c2_arvalid     ),
    .m_axi_arready      (test_axi_c2_arready     ),
    .m_axi_rid          (test_axi_c2_rid         ),
    .m_axi_rdata        (test_axi_c2_rdata       ),
    .m_axi_rresp        (test_axi_c2_rresp       ),
    .m_axi_rlast        (test_axi_c2_rlast       ),
    .m_axi_rvalid       (test_axi_c2_rvalid      ),
    .m_axi_rready       (test_axi_c2_rready      ),            
    .init_calib_complete(c2_init_calib_complete  ),
    .test_en            (group2_test_en  ),      
    .mode               (group2_mode     ),         
    .times              (group2_times    ),        
    .test_done          (group2_test_done),    
    .test_flag          (group2_test_flag),    
    .err                (group2_err      ),
    .wr_ms              (group2_wr_ms    ),
    .rd_ms              (group2_rd_ms    ),
    .test_cnt           (group2_test_cnt ) 
);
  ddr4_test U3_ddr4_test(
    .rst                (c3_ddr4_ui_clk_sync_rst ),
    .clk                (c3_ddr4_ui_clk          ),      
    .m_axi_awid         (test_axi_c3_awid        ),
    .m_axi_awaddr       (test_axi_c3_awaddr[32:0]),
    .m_axi_awlen        (test_axi_c3_awlen       ),
    .m_axi_awsize       (test_axi_c3_awsize      ),
    .m_axi_awburst      (test_axi_c3_awburst     ),
    .m_axi_awlock       (test_axi_c3_awlock      ),
    .m_axi_awcache      (test_axi_c3_awcache     ),
    .m_axi_awprot       (test_axi_c3_awprot      ),
    .m_axi_awvalid      (test_axi_c3_awvalid     ),
    .m_axi_awready      (test_axi_c3_awready     ),
    .m_axi_wdata        (test_axi_c3_wdata       ),
    .m_axi_wstrb        (test_axi_c3_wstrb       ),
    .m_axi_wlast        (test_axi_c3_wlast       ),
    .m_axi_wvalid       (test_axi_c3_wvalid      ),
    .m_axi_wready       (test_axi_c3_wready      ),
    .m_axi_bid          (test_axi_c3_bid         ),
    .m_axi_bresp        (test_axi_c3_bresp       ),
    .m_axi_bvalid       (test_axi_c3_bvalid      ),
    .m_axi_bready       (test_axi_c3_bready      ),
    .m_axi_arid         (test_axi_c3_arid        ),
    .m_axi_araddr       (test_axi_c3_araddr[32:0]),
    .m_axi_arlen        (test_axi_c3_arlen       ),
    .m_axi_arsize       (test_axi_c3_arsize      ),
    .m_axi_arburst      (test_axi_c3_arburst     ),
    .m_axi_arlock       (test_axi_c3_arlock      ),
    .m_axi_arcache      (test_axi_c3_arcache     ),
    .m_axi_arprot       (test_axi_c3_arprot      ),
    .m_axi_arvalid      (test_axi_c3_arvalid     ),
    .m_axi_arready      (test_axi_c3_arready     ),
    .m_axi_rid          (test_axi_c3_rid         ),
    .m_axi_rdata        (test_axi_c3_rdata       ),
    .m_axi_rresp        (test_axi_c3_rresp       ),
    .m_axi_rlast        (test_axi_c3_rlast       ),
    .m_axi_rvalid       (test_axi_c3_rvalid      ),
    .m_axi_rready       (test_axi_c3_rready      ),            
    .init_calib_complete(c3_init_calib_complete  ),
    .test_en            (group3_test_en  ),      
    .mode               (group3_mode     ),         
    .times              (group3_times    ),        
    .test_done          (group3_test_done),    
    .test_flag          (group3_test_flag),    
    .err                (group3_err      ),
    .wr_ms              (group3_wr_ms    ),
    .rd_ms              (group3_rd_ms    ),
    .test_cnt           (group3_test_cnt ) 
);
csr_pro U_csr_pro (                                                                                      
        .rst                (~s_axil_test_aresetn),                                                               
        .clk                (s_axil_test_aclk    ),                                                             
        .pcie_link_up       (pcie_link_up        ),                                                               
                                                                        
        .m_axil_awaddr      (s_axil_test_awaddr  ),                                                           
        .m_axil_awvalid     (s_axil_test_awvalid ),                                                           
        .m_axil_awready     (s_axil_test_awready ),                                                           
                                                                                    
        .m_axil_wdata       (s_axil_test_wdata   ),                                                           
        .m_axil_wstrb       (s_axil_test_wstrb   ),                                                           
        .m_axil_wvalid      (s_axil_test_wvalid  ),                                                           
        .m_axil_wready      (s_axil_test_wready  ),                                                           
                                                     
        .m_axil_bvalid      (s_axil_test_bvalid  ),                                                           
        .m_axil_bresp       (s_axil_test_bresp   ),                                                           
        .m_axil_bready      (s_axil_test_bready  ),                                                           
                                                                                                 
        .m_axil_araddr      (s_axil_test_araddr  ),                                                           
        .m_axil_arvalid     (s_axil_test_arvalid ),                                                           
        .m_axil_arready     (s_axil_test_arready ),                                                           
                                                     
        .m_axil_rdata       (s_axil_test_rdata   ),                                                           
        .m_axil_rresp       (s_axil_test_rresp   ),                                                           
        .m_axil_rvalid      (s_axil_test_rvalid  ),                                                           
        .m_axil_rready      (s_axil_test_rready  ),                                                           
                                                                                                  
        .sir_sel            (sirsel             ),                                                               
        .sir_addr           (siraddr            ),                                                               
        .sir_read           (sirread            ),                                                               
        .sir_wdat           (sirwdat            ),                                                               
        .sir_rdat           (sirrdat            ),                                                               
        .sir_dack           (sirdack            )
);

csr17  U_csr17(
        .Clk                (s_axil_test_aclk   ),
        .Rst                ( sys_rst           ),
                                                
        .SirAddr            (siraddr[19:0]      ),
        .SirRead            (sirread            ),
        .SirWdat            (sirwdat            ),
                                                
        .SirSel             (sirsel             ),
        .SirDack            (sirdack            ),
        .SirRdat            (sirrdat            ),
     
        .group0_test_en     (group0_test_en  ),
        .group0_dma_done(group0_dma_done),
        .group0_timeset_done(group0_timeset_done),      
        .group0_mode        (group0_mode     ),
        .group0_times       (group0_times    ),
        .group0_test_done   (group0_test_done),
        .group0_test_flag   (group0_test_flag),
        .group0_err         (group0_err      ),
        .group0_wr_ms       (group0_wr_ms    ),
        .group0_rd_ms       (group0_rd_ms    ),
        .group0_test_cnt    (group0_test_cnt ),
        .group0_ctrl_addr_wr(group0_ctrl_addr_wr),
                            
        .group1_test_en     (group1_test_en  ),   
        .group1_mode        (group1_mode     ),
        .group1_times       (group1_times    ),
        .group1_test_done   (group1_test_done),
        .group1_test_flag   (group1_test_flag),
        .group1_err         (group1_err      ),
        .group1_wr_ms       (group1_wr_ms    ),
        .group1_rd_ms       (group1_rd_ms    ),
        .group1_test_cnt    (group1_test_cnt ),
        .group1_ctrl_addr_wr(group1_ctrl_addr_wr),

        .group2_test_en     (group2_test_en  ),      
        .group2_mode        (group2_mode     ),
        .group2_times       (group2_times    ),
        .group2_test_done   (group2_test_done),
        .group2_test_flag   (group2_test_flag),
        .group2_err         (group2_err      ),
        .group2_wr_ms       (group2_wr_ms    ),
        .group2_rd_ms       (group2_rd_ms    ),
        .group2_test_cnt    (group2_test_cnt ),
                            
        .group3_test_en     (group3_test_en  ),   
        .group3_mode        (group3_mode     ),
        .group3_times       (group3_times    ),
        .group3_test_done   (group3_test_done),
        .group3_test_flag   (group3_test_flag),
        .group3_err         (group3_err      ),
        .group3_wr_ms       (group3_wr_ms    ),
        .group3_rd_ms       (group3_rd_ms    ),
        .group3_test_cnt    (group3_test_cnt )         
                ); 
endmodule                