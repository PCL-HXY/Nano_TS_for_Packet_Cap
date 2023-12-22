
`include "define.v"
module eth_control_ip(
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
     //eth//
     input  wire            clk156                , 
        output   wire    [63:0]  c0_fiber_IncEnb    ,
     output   wire    [63:0]  c1_fiber_IncEnb    ,
     
     input wire             ETH0_RxEN           ,
     input wire             ETH0_TxEN           ,
     input wire    [1:0]    ETH0_LOOP           ,
     input wire             ETH0_LINK           ,
     output wire            ETH0_GEN_EN           ,
                                    
     input wire             ETH1_RxEN           ,
     input wire             ETH1_TxEN           ,
     input wire    [1:0]    ETH1_LOOP           ,
     input wire             ETH1_LINK           ,
     output reg   [63 : 0] c0_xgmii_txd_d        ,    
     output reg   [7 : 0]  c0_xgmii_txc_d        ,    
     input  wire   [63 : 0] c0_xgmii_rxd          ,    
     input  wire   [7 : 0]  c0_xgmii_rxc          ,

     output reg   [63 : 0] c1_xgmii_txd_d        ,    
     output reg   [7 : 0]  c1_xgmii_txc_d        ,    
     input  wire   [63 : 0] c1_xgmii_rxd          ,    
     input  wire   [7 : 0]  c1_xgmii_rxc          ,
     
     output wire   [15:0]   ch0_wlen_rx           ,
     output wire   [15:0]   ch1_wlen_rx           ,
     output wire   [15:0]   ch0_wlen_tx           ,
     output wire   [15:0]   ch1_wlen_tx           ,
     
     output wire    [3:0]   stat_inc_d_p0_xrx     ,
     output wire    [3:0]   stat_inc_d_p1_xrx     ,
     output wire    [3:0]   stat_inc_d_p0_xtx     ,
     output wire    [3:0]   stat_inc_d_p1_xtx     ,


     output wire    [14:0]  tgbaser_c0_cfg0       ,
     output wire    [31:0]  tgbaser_c0_cfg1       ,
     output wire    [25:0]  tgbaser_c0_cfg2       ,
     output wire    [14:0]  tgbaser_c1_cfg0       ,
     output wire    [31:0]  tgbaser_c1_cfg1       ,
     output wire    [25:0]  tgbaser_c1_cfg2       ,
                                                  
     input  wire    [2:0]   tgbaser_status        ,
     input  wire    [31:0]  tgbaser_c0_status0    ,
     input  wire    [5:0]   tgbaser_c0_status1    ,
     input  wire    [31:0]  tgbaser_c1_status0    ,
     input  wire    [5:0]   tgbaser_c1_status1    ,
     output reg             ACT0                  ,
     output reg             ACT1                  ,
     
     input wire [31:0] pps_rate,
     input wire [31:0] byte_rate, 
     
     output wire    [63:0]  BASE_TIME,//////////hxy
     output wire ch0_wenb_clk,
     output wire[63:0] ch0_wdat_clk,
          
          output wire ch0_wsop_clk,//dsp
          output wire ch0_weop_clk//dsp
     );
wire                   sirsel                     ;
wire [31:0]            siraddr                    ;
wire                   sirread                    ;
wire [31:0]            sirwdat                    ;
wire [31:0]            sirrdat                    ;
wire                   sirdack                    ;

//wire                        ETH0_GEN_EN           ;
wire                        ETH0_TX_OVER          ;
wire    [63:0]              ETH0_GEN_NUM          ;
reg     [511:0]             ETH0_GEN_EN_WIDE      ;
reg                         ETH0_GEN_EN_R         ;
wire    [31:0]              ETH0_VAL_LEN          ;
wire    [31:0]              ETH0_IDLE_LEN         ;
wire    [1:0]               ETH0_LEN_MODE         ;
wire    [1:0]               ETH0_DIP_MODE         ;
wire    [1:0]               ETH0_SIP_MODE         ;
wire    [1:0]               ETH0_DMAC_MODE        ;
wire    [1:0]               ETH0_SMAC_MODE        ;
wire    [1:0]               ETH0_DP_MODE          ;
wire    [1:0]               ETH0_SP_MODE          ;
wire    [31:0]              ETH0_DIP              ;
wire    [47:0]              ETH0_DMAC             ;
wire    [15:0]              ETH0_DP               ;
wire    [15:0]              ETH0_SP               ;
wire                        ETH1_GEN_EN           ;
reg     [511:0]             ETH1_GEN_EN_WIDE      ;
reg                         ETH1_GEN_EN_R         ;
wire                        ETH1_TX_OVER          ;
wire    [63:0]              ETH1_GEN_NUM          ;
wire    [31:0]              ETH1_VAL_LEN          ;
wire    [31:0]              ETH1_IDLE_LEN         ;
wire    [1:0]               ETH1_LEN_MODE         ;
wire    [1:0]               ETH1_DIP_MODE         ;
wire    [1:0]               ETH1_SIP_MODE         ;
wire    [1:0]               ETH1_DMAC_MODE        ;
wire    [1:0]               ETH1_SMAC_MODE        ;
wire    [1:0]               ETH1_DP_MODE          ;
wire    [1:0]               ETH1_SP_MODE          ;
wire    [31:0]              ETH1_DIP              ;
wire    [47:0]              ETH1_DMAC             ;
wire    [15:0]              ETH1_DP               ;
wire    [15:0]              ETH1_SP               ;

wire    [31:0]              local0_ip             ;
wire    [47:0]              local0_mac            ;
wire    [31:0]              local1_ip             ;
wire    [47:0]              local1_mac            ;

wire    [63 : 0]            c0_gen_xgmii_txd      ;
wire    [7 : 0]             c0_gen_xgmii_txc      ;
wire    [63 : 0]            c1_gen_xgmii_txd      ;
wire    [7 : 0]             c1_gen_xgmii_txc      ;


reg     [63 : 0]            c0_xgmii_rxd_d        ;
reg     [7 : 0]             c0_xgmii_rxc_d        ;
                                                  

reg     [63 : 0]            c1_xgmii_rxd_d        ;
reg     [7 : 0]             c1_xgmii_rxc_d        ;

wire                        c0_err_inc            ;
wire                        c1_err_inc            ; 

wire    [31:0]              byte_rate_ch0_rx      ;
wire    [31:0]              byte_rate_ch1_rx      ;
wire    [31:0]              pps_rate_ch0_rx       ;
wire    [31:0]              pps_rate_ch1_rx       ;
                                                  
wire    [31:0]              byte_rate_ch0_tx      ;
wire    [31:0]              byte_rate_ch1_tx      ;
wire    [31:0]              pps_rate_ch0_tx       ;
wire    [31:0]              pps_rate_ch1_tx       ;

wire    [3:0]               c0_stat_inc_xtx       ;
wire    [3:0]               c0_stat_inc_d_xtx     ;
wire    [3:0]               c1_stat_inc_xtx       ;
wire    [3:0]               c1_stat_inc_d_xtx     ;

wire    [15:0]              stat_inc_xrx          ;
wire    [15:0]              stat_inc_xtx          ;

wire                       ch0_wenb               ;
wire                       ch1_wenb               ;
reg    [27:0]              led_cnt = 0            ;

always @( posedge clk156 )
begin
    if ( led_cnt[27] == 1'd1 )
        led_cnt    <= 28'd0;
    else
        led_cnt    <= led_cnt + 28'd1;
end

always @( posedge clk156  )
begin  
 if ( ch0_wenb == 1'b0)
        ACT0<=1'b1;
  else if (ch0_wenb  == 1'b1 )
    ACT0<= led_cnt[26];
  else
        ACT0<= ACT0;    
end 
always @( posedge clk156 )
begin
    if ( ch1_wenb == 1'b0)
        ACT1    <= 1'b1;
    else if (ch1_wenb  == 1'b1 )
        ACT1    <= led_cnt[26];
    else 
        ACT1 <= ACT1;
end 


always @(posedge clk156)begin
if(sys_rst)begin
    ETH0_GEN_EN_WIDE<=0;
    ETH0_GEN_EN_R   <=0;
    ETH1_GEN_EN_WIDE<=0;
    ETH1_GEN_EN_R   <=0; 
end                             
 else begin
    ETH0_GEN_EN_WIDE<={ETH0_GEN_EN_WIDE[510:0],ETH0_GEN_EN}      ;
    ETH0_GEN_EN_R   <=|ETH0_GEN_EN_WIDE                          ;
    ETH1_GEN_EN_WIDE<={ETH1_GEN_EN_WIDE[510:0],ETH1_GEN_EN}      ;
    ETH1_GEN_EN_R   <=|ETH1_GEN_EN_WIDE                          ;
 end
end

always @ ( posedge clk156 or posedge sys_rst )
begin
    if ( sys_rst)
        begin
        c0_xgmii_rxc_d <= 8'hff ;              
        c0_xgmii_rxd_d <= 64'h0707070707070707;
        end
    else if( ETH0_LOOP == 2'b00 || ETH0_LOOP == 2'b10 )//0109dsp
        begin
        c0_xgmii_rxc_d <= c0_xgmii_rxc ;
        c0_xgmii_rxd_d <= c0_xgmii_rxd;
        end
    else
        begin
        c0_xgmii_rxc_d <= 8'hff ;              
        c0_xgmii_rxd_d <= 64'h0707070707070707;
        end
end

always @ ( posedge clk156 or posedge sys_rst )
begin
    if (  sys_rst)
        begin
        c1_xgmii_rxc_d <= 8'hff ;              
        c1_xgmii_rxd_d <= 64'h0707070707070707;
        end
    else if ( ETH1_LOOP == 2'b00 || ETH1_LOOP == 2'b10 )//0109dsp
        begin
        c1_xgmii_rxc_d <= c1_xgmii_rxc ;
        c1_xgmii_rxd_d <= c1_xgmii_rxd;
        end
    else
        begin
        c1_xgmii_rxc_d <= 8'hff ;              
        c1_xgmii_rxd_d <= 64'h0707070707070707;
        end
end

always @ ( posedge clk156 or posedge sys_rst)
begin
    if (  sys_rst )
        begin
        c0_xgmii_txc_d <= 8'hff ;              
        c0_xgmii_txd_d <= 64'h0707070707070707;
        end
    else begin
        if(ETH0_TxEN == 1'b1)begin
            case(ETH0_LOOP)
            2'b01:begin
                c0_xgmii_txc_d <= c0_xgmii_rxc ;
                c0_xgmii_txd_d <= c0_xgmii_rxd;
            end
            2'b10:begin
                c0_xgmii_txc_d <= c0_xgmii_rxc ;
                c0_xgmii_txd_d <= c0_xgmii_rxd;
            end
            default:begin
            c0_xgmii_txc_d <= c0_gen_xgmii_txc ;
            c0_xgmii_txd_d <= c0_gen_xgmii_txd ;
            end
            endcase
        end
        else begin
            c0_xgmii_txc_d <= 8'hff ;              
            c0_xgmii_txd_d <= 64'h0707070707070707;
        end
    end
end

always @ ( posedge clk156 or posedge sys_rst )
begin
    if ( sys_rst )
        begin
        c1_xgmii_txc_d <= 8'hff ;              
        c1_xgmii_txd_d <= 64'h0707070707070707;
        end
    else begin
        if(ETH1_TxEN == 1'b1)begin
            case(ETH1_LOOP)
            2'b01:begin
                c1_xgmii_txc_d <= c1_xgmii_rxc ;
                c1_xgmii_txd_d <= c1_xgmii_rxd;
            end
            2'b10:begin
                c1_xgmii_txc_d <= c1_xgmii_rxc ;
                c1_xgmii_txd_d <= c1_xgmii_rxd;
            end
            default:begin
                c1_xgmii_txc_d <= c1_gen_xgmii_txc ;
                c1_xgmii_txd_d <= c1_gen_xgmii_txd ;
            end
            endcase
        end
        else begin
            c1_xgmii_txc_d <= 8'hff ;              
            c1_xgmii_txd_d <= 64'h0707070707070707;
        end
    end
end

//assign IncEnb156m[15:0]    = {8'h00,c1_err_inc,c1_stat_inc_xtx[2:0],c0_err_inc,c0_stat_inc_xtx[2:0]} ;
//assign IncEnb156m[31:16]   = stat_inc_xrx[15:0];
//assign IncEnb156m[63:32]   = {8'h0,24'd0} ;
//assign IncEnb156m[87:64]   = 0;//4?????????
//assign IncEnb156m[103:88]  = stat_inc_xtx[15:0];
//assign IncEnb156m[511:104] = 0;\


assign c0_fiber_IncEnb={57'd0,c0_err_inc,stat_inc_xrx[2:0],1'b0,c0_stat_inc_xtx[1:0]};
assign c1_fiber_IncEnb={57'd0,c1_err_inc,stat_inc_xrx[8:6],1'b0,c1_stat_inc_xtx[1:0]};


//eth_test u0_eth_test(
// .reset          (sys_rst),
// .clk156m        (clk156            ),
// .ETH_LINK       (ETH0_LINK         ),
// .GEN_EN         (ETH0_GEN_EN_R     ),
// .xgmii_txc      (c0_gen_xgmii_txc  ),
// .xgmii_txd      (c0_gen_xgmii_txd  ),
// .xgmii_rxc      (c0_xgmii_rxc_d    ),
// .xgmii_rxd      (c0_xgmii_rxd_d    ),
// .err_inc        (c0_err_inc        )
//);

//eth_test u1_eth_test(
// .reset          (sys_rst),
// .clk156m        (clk156            ),
// .ETH_LINK       (ETH1_LINK         ),
// .GEN_EN         (ETH1_GEN_EN_R     ),
// .xgmii_txc      (c1_gen_xgmii_txc  ),
// .xgmii_txd      (c1_gen_xgmii_txd  ),
// .xgmii_rxc      (c1_xgmii_rxc_d    ),
// .xgmii_rxd      (c1_xgmii_rxd_d    ),
// .err_inc        (c1_err_inc        )
//);

assign c0_err_inc = 1'b0;
assign c1_err_inc = 1'b0;
/*
//--------------------------------dsp
reg [15:0] ch0_wlen_temp;
reg [63:0] ch0_wdat_temp;
wire [63:0]  ch0_wdat;
wire ch0_weop;
wire ch0_wsop;
//wire ch0_wenb;
parameter SOP=16'hfb55;//hxy0107

always @(posedge clk156)
begin
ch0_weop_clk <= ch0_weop;
ch0_wsop_clk <= ch0_wsop;
ch0_wenb_clk <= ch0_wenb;
end

assign ch0_wdat_clk = ch0_wdat_temp;

always @(posedge clk156)
begin
if(ch0_weop)
begin
ch0_wdat_temp <= {ch0_wdat[63:32],(ch0_wlen_rx - 16'hc),SOP};
end
else
ch0_wdat_temp <= ch0_wdat;
end
//-------------------------------------------------------
*/
xgmii_tx_pp U0_xgmii_tx_pp(
                .Reset                       (sys_rst ),
                .Clk                         (clk156                ),

                .GEN_EN                      (ETH0_GEN_EN      ),
                .TX_OVER                     (ETH0_TX_OVER          ),
                .GEN_NUM                     (ETH0_GEN_NUM                 ),
                .VAL_LEN                     (ETH0_VAL_LEN - 'h18          ),
                .IDLE_LEN                    (ETH0_IDLE_LEN              ),
                .LEN_MODE                    (2'b0                 ),
                .DIP_MODE                    (2'b0          ),
                .SIP_MODE                    (2'b0          ),
                .DMAC_MODE                   (2'b0          ),
                .SMAC_MODE                   (2'b0          ),
                .DP_MODE                     (2'b0                 ),
                .SP_MODE                     (2'b0                 ),

                .DIP                         (32'hc0a8020a              ),
                .DMAC                        (48'h000045000011             ),
                .DP                          (16'b0               ),
                .SP                          (16'b0               ),
                .local_ip                    (32'hc0a8010a             ),
                .local_mac                   (48'h45000001            ),
                .xgmii_txd                   (c0_gen_xgmii_txd      ),
                .xgmii_txc                   (c0_gen_xgmii_txc      ),
                
                .stat_inc                    (c0_stat_inc_xtx       ),
                .stat_inc_d                  (c0_stat_inc_d_xtx     )
                  );
                  
xgmii_tx_pp U1_xgmii_tx_pp(
                .Reset                       (sys_rst  ),
                .Clk                         (clk156                ),
                .GEN_EN                      (ETH1_GEN_EN           ),
                .TX_OVER                     (ETH1_TX_OVER          ),
                .GEN_NUM                     (ETH1_GEN_NUM          ),
                .VAL_LEN                     (ETH1_VAL_LEN          ),
                .IDLE_LEN                    (ETH1_IDLE_LEN         ),
                .LEN_MODE                    (ETH1_LEN_MODE         ),
                .DIP_MODE                    (ETH1_DIP_MODE         ),
                .SIP_MODE                    (ETH1_SIP_MODE         ),
                .DMAC_MODE                   (ETH1_DMAC_MODE        ),
                .SMAC_MODE                   (ETH1_SMAC_MODE        ),
                .DP_MODE                     (ETH1_DP_MODE          ),
                .SP_MODE                     (ETH1_SP_MODE          ),
                .DIP                         (ETH1_DIP              ),
                .DMAC                        (ETH1_DMAC             ),
                .DP                          (ETH1_DP               ),
                .SP                          (ETH1_SP               ),
                .local_ip                    (local1_ip             ),
                .local_mac                   (local1_mac            ),
                .xgmii_txd                   (c1_gen_xgmii_txd      ),
                .xgmii_txc                   (c1_gen_xgmii_txc      ),
                
                .stat_inc                    (c1_stat_inc_xtx       ),
                .stat_inc_d                  (c1_stat_inc_d_xtx     )
                  );

 xgmii_two_rx_pp     U_xgmii_two_rx_pp  (
                    .clk             (clk156          ),
                    .reset           (sys_rst),
                    .byte_rate_ch0   (byte_rate_ch0_rx),
                    .byte_rate_ch1   (byte_rate_ch1_rx),
                    .pps_rate_ch0    (pps_rate_ch0_rx ),
                    .pps_rate_ch1    (pps_rate_ch1_rx ),

                    .xgmii0_rxd      (c0_xgmii_rxd_d    ),   //c0_xgmii_rxd_d
                    .xgmii0_rxc      (c0_xgmii_rxc_d    ),   //c0_xgmii_rxc_d
                    .ch0_wdat        (  ch0_wdat_clk              ),   
                    .ch0_wenb        ( ch0_wenb_clk                 ),   
                    .ch0_wsop        (  ch0_wsop_clk               ),   
                    .ch0_weop        (  ch0_weop_clk               ),   
                    .ch0_wlen        (ch0_wlen_rx     ),   

                    .xgmii1_rxd      (c1_xgmii_rxd    ),   
                    .xgmii1_rxc      (c1_xgmii_rxc    ),    
                    .ch1_wdat        (                ),   
                    .ch1_wenb        (ch1_wenb        ),   
                    .ch1_wsop        (                ),   
                    .ch1_weop        (                ),   
                    .ch1_wlen        (ch1_wlen_rx     ),

                    .stat_inc        (stat_inc_xrx     ),
                    .stat_inc_d_p0   (stat_inc_d_p0_xrx),
                    .stat_inc_d_p1   (stat_inc_d_p1_xrx)
                        );
//tx// for loopback test , pls comment it
/*
xgmii_two_rx_pp     U_xgmii_two_tx_pp  (
                    .clk             (clk156          ),
                    .reset           (sys_rst),
                    .byte_rate_ch0   (byte_rate_ch0_tx),
                    .byte_rate_ch1   (byte_rate_ch1_tx),
                    .pps_rate_ch0    (pps_rate_ch0_tx ),
                    .pps_rate_ch1    (pps_rate_ch1_tx ),

                    .xgmii0_rxd      (c0_xgmii_rxd  ),   
                    .xgmii0_rxc      (c0_xgmii_rxc  ),   
                    .ch0_wdat        (ch0_wdat               ),   
                    .ch0_wenb        (ch0_wenb             ),   
                    .ch0_wsop        (ch0_wsop                ),   
                    .ch0_weop        (ch0_weop                ),   
                    .ch0_wlen        (ch0_wlen_tx     ),   
                                             
                    .xgmii1_rxd      (c1_xgmii_txd_d  ),   
                    .xgmii1_rxc      (c1_xgmii_txc_d  ),    
                    .ch1_wdat        (                ),   
                    .ch1_wenb        (                ),   
                    .ch1_wsop        (                ),   
                    .ch1_weop        (                ),   
                    .ch1_wlen        (ch1_wlen_tx     ),

                    .stat_inc        (stat_inc_xtx     ),
                    .stat_inc_d_p0   (stat_inc_d_p0_xtx),
                    .stat_inc_d_p1   (stat_inc_d_p1_xtx)
                        );
          */              
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


 csr18  U_csr18(
        .Clk                (s_axil_test_aclk             ),
        .Rst                ( sys_rst           ),
                                                
        .SirAddr            (siraddr[19:0]      ),
        .SirRead            (sirread            ),
        .SirWdat            (sirwdat            ),
                                                
        .SirSel             (sirsel             ),
        .SirDack            (sirdack            ),
        .SirRdat            (sirrdat            ),
        
        .local0_ip          (local0_ip          ), 
        .local0_mac         (local0_mac         ),   
        .local1_ip          (local1_ip          ), 
        .local1_mac         (local1_mac         ), 
 //       .byte_rate_ch0_rx   ({5'd0,byte_rate_ch0_rx[31:5]}   ),   // divide 32 in 10G fiber 
 //       .byte_rate_ch1_rx   ({5'd0,byte_rate_ch1_rx[31:5]}   ),   // divide 32 in 10G fiber 
        .byte_rate_ch0_rx   (byte_rate_ch0_rx ),   // divide 32 in 10G fiber 
        .byte_rate_ch1_rx   (byte_rate_ch1_rx ),   // divide 32 in 10G fiber /dsp
        .pps_rate_ch0_rx    (pps_rate_ch0_rx    ), 
        .pps_rate_ch1_rx    (pps_rate_ch1_rx    ), 
                            
        .byte_rate_ch0_tx   ( byte_rate   ),  // divide 32 in 10G fiber 
        .byte_rate_ch1_tx   (  32'b0    ),  // divide 32 in 10G fiber 
   //     .byte_rate_ch0_tx   ({5'd0,byte_rate_ch0_tx[31:5]}   ),  // divide 32 in 10G fiber 
   //     .byte_rate_ch1_tx   ({5'd0,byte_rate_ch1_tx[31:5]}   ),  // divide 32 in 10G fiber 
        .pps_rate_ch0_tx    (  pps_rate     ), 
        .pps_rate_ch1_tx    (  32'b0     ), 
                            
        .tgbaser_c0_cfg0    (tgbaser_c0_cfg0    ), 
        .tgbaser_c0_cfg1    (tgbaser_c0_cfg1    ), 
        .tgbaser_c0_cfg2    (tgbaser_c0_cfg2    ), 
        .tgbaser_c1_cfg0    (tgbaser_c1_cfg0    ), 
        .tgbaser_c1_cfg1    (tgbaser_c1_cfg1    ), 
        .tgbaser_c1_cfg2    (tgbaser_c1_cfg2    ), 
                            
        .tgbaser_status     (tgbaser_status     ), 
        .tgbaser_c0_status0 (tgbaser_c0_status0 ), 
        .tgbaser_c0_status1 (tgbaser_c0_status1 ), 
        .tgbaser_c1_status0 (tgbaser_c1_status0 ), 
        .tgbaser_c1_status1 (tgbaser_c1_status1 ), 
                           
        .ETH0_GEN_EN        (ETH0_GEN_EN        ), 
        .ETH0_TX_OVER       (ETH0_TX_OVER       ), 
        .ETH0_GEN_NUM       (ETH0_GEN_NUM       ), 
        .ETH0_VAL_LEN       (ETH0_VAL_LEN       ), 
        .ETH0_IDLE_LEN      (ETH0_IDLE_LEN      ), 
        .ETH0_LEN_MODE      (ETH0_LEN_MODE      ), 
        .ETH0_DIP_MODE      (ETH0_DIP_MODE      ), 
        .ETH0_SIP_MODE      (ETH0_SIP_MODE      ), 
        .ETH0_DMAC_MODE     (ETH0_DMAC_MODE     ), 
        .ETH0_SMAC_MODE     (ETH0_SMAC_MODE     ), 
        .ETH0_DIP           (ETH0_DIP           ), 
        .ETH0_DMAC          (ETH0_DMAC          ), 
        .ETH0_DP_MODE       (ETH0_DP_MODE       ), 
        .ETH0_SP_MODE       (ETH0_SP_MODE       ), 
        .ETH0_DP            (ETH0_DP            ), 
        .ETH0_SP            (ETH0_SP            ), 
                            
        .ETH1_GEN_EN        (ETH1_GEN_EN        ), 
        .ETH1_TX_OVER       (ETH1_TX_OVER       ), 
        .ETH1_GEN_NUM       (ETH1_GEN_NUM       ), 
        .ETH1_VAL_LEN       (ETH1_VAL_LEN       ), 
        .ETH1_IDLE_LEN      (ETH1_IDLE_LEN      ), 
        .ETH1_LEN_MODE      (ETH1_LEN_MODE      ), 
        .ETH1_DIP_MODE      (ETH1_DIP_MODE      ), 
        .ETH1_SIP_MODE      (ETH1_SIP_MODE      ), 
        .ETH1_DMAC_MODE     (ETH1_DMAC_MODE     ), 
        .ETH1_SMAC_MODE     (ETH1_SMAC_MODE     ), 
        .ETH1_DIP           (ETH1_DIP           ), 
        .ETH1_DMAC          (ETH1_DMAC          ), 
        .ETH1_DP_MODE       (ETH1_DP_MODE       ), 
        .ETH1_SP_MODE       (ETH1_SP_MODE       ), 
        .ETH1_DP            (ETH1_DP            ), 
        .ETH1_SP            (ETH1_SP            ),
        
        .BASE_TIME(BASE_TIME)
                  
                ); 
 
endmodule 