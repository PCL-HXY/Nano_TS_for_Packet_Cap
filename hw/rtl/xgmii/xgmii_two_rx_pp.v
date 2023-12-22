// ***************************************************************************************
//
// Copyright(c) 2003, Semptian Technologies Ltd., All right reserved
//
// Filename        :    xgmii_four_rx_pp.v
// Projectname     :    semppp
// Author          :    zhangjun
// Email           :    zhangjun@semptian.com
// Date            :    Aug 22nd, 2011
// Version         :    1.0
// Company         :    Semptian Technologies Ltd.
//
// Description     :    xgmii        
//
// Modification History
// Date            By            Revision        Change Description
// ---------------------------------------------------------------------------------------
// 2011/08/22      zhangjun      1.0             Original
//
// ***************************************************************************************
// DEFINE
//  
//                                                  
// ***************************************************************************************
`include "define.v"

module  xgmii_two_rx_pp(
                        clk             ,
                        reset           ,
                        byte_rate_ch0   ,
                        byte_rate_ch1   ,
                        pps_rate_ch0    ,
                        pps_rate_ch1    ,
                        
                        xgmii0_rxd      ,   
                        xgmii0_rxc      ,   
                        ch0_wdat        ,   
                        ch0_wenb        ,   
                        ch0_wsop        ,   
                        ch0_weop        ,   
                        ch0_wlen        ,   
                        
                        xgmii1_rxd      ,   
                        xgmii1_rxc      ,    
                        ch1_wdat        ,   
                        ch1_wenb        ,   
                        ch1_wsop        ,   
                        ch1_weop        ,   
                        ch1_wlen        ,
                        
                        stat_inc        ,
                        stat_inc_d_p0   ,
                        stat_inc_d_p1   
                        );

input   wire                    clk             ;
input   wire                    reset           ;
output  wire    [31:0]          byte_rate_ch0   ;
output  wire    [31:0]          byte_rate_ch1   ;
output  wire    [27:0]          pps_rate_ch0    ;
output  wire    [27:0]          pps_rate_ch1    ;

input   wire    [63:0]          xgmii0_rxd      ;   
input   wire    [7:0]           xgmii0_rxc      ;    
output  wire    [63:0]          ch0_wdat        ;   
output  wire                    ch0_wenb        ;   
output  wire                    ch0_wsop        ;   
output  wire                    ch0_weop        ;   
output  wire    [15:0]          ch0_wlen        ;

input   wire    [63:0]          xgmii1_rxd      ;   
input   wire    [7:0]           xgmii1_rxc      ;    
output  wire    [63:0]          ch1_wdat        ;   
output  wire                    ch1_wenb        ;   
output  wire                    ch1_wsop        ;   
output  wire                    ch1_weop        ;   
output  wire    [15:0]          ch1_wlen        ; 

output  wire    [15:0]          stat_inc        ;
output  wire    [3:0]           stat_inc_d_p0   ;
output  wire    [3:0]           stat_inc_d_p1   ;
/*****************************************/
wire    [5:0]       stat_inc_p0 ;
wire    [5:0]       stat_inc_p1 ;
reg     [31:0]      time_cnt    ;
reg                 time_1s  ;

assign stat_inc[11:0] = {stat_inc_p1,stat_inc_p0};
assign stat_inc[12]   = ch0_weop && ( ch0_wlen[15]==1'b0 ) ;
assign stat_inc[13]   = ch1_weop && ( ch1_wlen[15]==1'b0 ) ;
assign stat_inc[14]   = ch0_weop && ( ch0_wlen[15]==1'b0 ) ;
assign stat_inc[15]   = ch1_weop && ( ch1_wlen[15]==1'b0 ) ;

xgmii_rx_pp     U0_xgmii_rx_pp(
                    .rxaui_clk      (clk            ),
                    .reset          (reset          ),
                    .time_1s     (time_1s     ),
                    .byte_rate      (byte_rate_ch0  ),
                    .pps_rate       (pps_rate_ch0   ),
                                    
                    .xgmii_rxc      (xgmii0_rxc     ),
                    .xgmii_rxd      (xgmii0_rxd     ),
                                    
                    .opktwdat       (ch0_wdat       ),
                    .opktwenb       (ch0_wenb       ),
                    .opktwsop       (ch0_wsop       ),
                    .opktweop       (ch0_weop       ),
                    .opktwlen       (ch0_wlen       ),
                    .stat_inc       (stat_inc_p0    ),
                    .stat_inc_d5    (stat_inc_d_p0  )
                    );

xgmii_rx_pp     U1_xgmii_rx_pp(
                    .rxaui_clk      (clk            ),
                    .reset          (reset          ),
                    .time_1s     (time_1s     ),
                                    
                    .xgmii_rxc      (xgmii1_rxc     ),
                    .xgmii_rxd      (xgmii1_rxd     ),
                    .byte_rate      (byte_rate_ch1  ),
                    .pps_rate       (pps_rate_ch1   ),
                                    
                    .opktwdat       (ch1_wdat       ),
                    .opktwenb       (ch1_wenb       ),
                    .opktwsop       (ch1_wsop       ),
                    .opktweop       (ch1_weop       ),
                    .opktwlen       (ch1_wlen       ),
                    .stat_inc       (stat_inc_p1    ),
                    .stat_inc_d5    (stat_inc_d_p1  )
                    );

/*****************************************/

parameter TIME_PARA = 32'd156249999 ;

always@( posedge clk or posedge reset )
begin
    if( reset == 1'b1 )
        time_cnt <= 32'h0 ;
    else if( time_1s == 1'b1 )
        time_cnt <= 32'h0 ;
    else 
        time_cnt <= time_cnt + 1'b1 ;
end

always@( posedge clk or posedge reset )
begin
    if( reset == 1'b1 )
        time_1s <= 1'b0 ;
    else if( time_cnt == TIME_PARA )
        time_1s <= 1'b1 ;
    else 
        time_1s <= 1'b0 ;
end

endmodule