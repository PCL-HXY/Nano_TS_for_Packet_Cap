// ***************************************************************************************
//
// Copyright(c) 2000, Semptian Technologies Ltd., All right reserved
//
// Filename        :    xgmii_rx_pp.v
// Projectname     :    semp905a
// Author          :    zhangjun
// Email           :    zhangjun@semptian.com
// Date            :    Oct 22nd, 2009
// Version         :    1.0
// Company         :    Semptian Technologies Ltd.
//
// Description     :                                             
//
// Modification History
// Date            By            Revision        Change Description
// ---------------------------------------------------------------------------------------
// 2009/10/22      zhangjun      1.0             Original
// 2011/07/18      zhiwanjiang   1.1             
// ***************************************************************************************
// DEFINE
//  
//                                                  
// ***************************************************************************************
//
// Module       :    xgmii_rx_pp
// Called by    :    
//
// ***************************************************************************************
//
// ***************************************************************************************
//
// ***************************************************************************************
// CVS version comment
//
// $LOG$
//
// ***************************************************************************************

`include "define.v"

module  xgmii_rx_pp (
                    rxaui_clk       ,
                    reset           ,
                    time_1s      ,
                    byte_rate       ,
                    pps_rate        ,
                    
                    xgmii_rxc       ,
                    xgmii_rxd       ,
                    
                    opktwdat        ,
                    opktwenb        ,
                    opktwsop        ,
                    opktweop        ,
                    opktwlen        ,
                    stat_inc        ,
                    stat_inc_d5        
                );

input   wire                rxaui_clk       ;
input   wire                reset           ;
input   wire                time_1s      ;

(*mark_debug = "true"*)input   wire    [7:0]       xgmii_rxc       ;
(*mark_debug = "true"*)input   wire    [63:0]      xgmii_rxd       ;
output  reg     [31:0]      byte_rate       ;
output  reg     [27:0]      pps_rate        ;


output  reg     [63:0]      opktwdat        ;
(*mark_debug = "true"*)output  reg                 opktwenb        ;
(*mark_debug = "true"*)output  reg                 opktwsop        ;
(*mark_debug = "true"*)output  reg                 opktweop        ;
output  reg     [15:0]      opktwlen        ;
output  reg     [5:0]       stat_inc        ;
output  reg    [3:0]        stat_inc_d5     ;

/**********************************************************/
reg     [63:0]      opktwdat_t        ;
reg                 opktwenb_t        ;
reg                 opktwsop_t        ;
reg                 opktweop_t        ;
reg     [14:0]      opktwlen_t        ;
reg                 crc_err_t         ;

(*mark_debug = "true"*)wire                Rxdv            ;
wire    [63:0]      Rxd             ;
(*mark_debug = "true"*)wire                RxSof           ;
(*mark_debug = "true"*)wire                RxEof           ;
wire    [2:0]       RxMod           ;


xgmii_rx_ifc_pp   U_xgmii_rx_ifc_pp(
                    .Reset          (reset              ),
                    .Clk            (rxaui_clk          ),
                    
                    .xgmii_rxd      (xgmii_rxd          ),
                    .xgmii_rxc      (xgmii_rxc          ),
                    
                    .Rxdv           (Rxdv               ),
                    .Rxd            (Rxd                ),
                    .RxSof          (RxSof              ),
                    .RxEof          (RxEof              ),
                    .RxMod          (RxMod              ),
                    .RxErr          (                   )
                    );
                    

/*******************************************************************\
*                                                                   *
*                     Instance Preamble Cut Module                  *
*                                                                   *
\*******************************************************************/
(*mark_debug = "true"*)wire                    PreRxdv;
wire    [63:0]          PreRxd;
(*mark_debug = "true"*)wire                    PreRxSof;
(*mark_debug = "true"*)wire                    PreRxEof;
wire    [2:0]           PreRxMod;
wire                    PreErr;

pre_cut  U_pre_cut  (
                .Reset                      (reset              ),
                .Clk                        (rxaui_clk          ),

                .Rxdv                       (Rxdv               ),
                .Rxd                        (Rxd                ),
                .RxSof                      (RxSof              ),
                .RxEof                      (RxEof              ),
                .RxMod                      (RxMod              ),

                .PreRxdv                    (PreRxdv            ),
                .PreRxd                     (PreRxd             ),
                .PreRxSof                   (PreRxSof           ),
                .PreRxEof                   (PreRxEof           ),
                .PreRxMod                   (PreRxMod           ),
                .PreErr                     (PreErr             )
                  );

//assign PreRxdv  = Rxdv  ;
//assign PreRxd   = Rxd   ;
//assign PreRxSof = RxSof ;
//assign PreRxEof = RxEof ;
//assign PreRxMod = RxMod ;
//assign PreErr   = 1'b0  ;

/*******************************************************************\
*                                                                   *
*                     Instance CRC Check Module                     *
*                                                                   *
\*******************************************************************/
//wire                    CrcRxdv;
//wire    [63:0]          CrcRxd;
//wire                    CrcRxSof;
//wire                    CrcRxEof;
//wire    [2:0]           CrcRxMod;

(*mark_debug = "true"*)wire                     rxsop       ;
(*mark_debug = "true"*)wire                    rxeop       ;
(*mark_debug = "true"*)wire                     rxdv        ;
wire    [63:0]          rxd         ;
wire    [2:0]           rxmod       ;
wire    [1:0]           CrcRxErr;

wire                crc_rxsop       ;
wire                crc_rxeop       ;
wire                crc_rxdv        ;
wire    [63:0]      crc_rxd         ;
wire    [2:0]       crc_rxmod       ;
wire    [1:0]       crc_err         ;

crc_check  U_crc_check  (
                .Reset                      (reset              ),
                .Clk                        (rxaui_clk          ),

                .PreRxdv                    (PreRxdv            ),
                .PreRxd                     (PreRxd             ),
                .PreRxSof                   (PreRxSof           ),
                .PreRxEof                   (PreRxEof           ),
                .PreRxMod                   (PreRxMod           ),
                .PreErr                     (PreErr             ),

                .CrcRxdv                    (crc_rxdv           ),
                .CrcRxd                     (crc_rxd            ),
                .CrcRxSof                   (crc_rxsop          ),
                .CrcRxEof                   (crc_rxeop          ),
                .CrcRxMod                   (crc_rxmod          ),
                .CrcRxErr                   (crc_err            )
                  );

//assign crc_rxdv   = PreRxdv  ;
//assign crc_rxd    = PreRxd   ;
//assign crc_rxsop  = PreRxSof ;
//assign crc_rxeop  = PreRxEof ;
//assign crc_rxmod  = PreRxMod ;
//assign CrcRxErr   = PreErr   ;

/**********************************************************/
reg     RxdvL1 ,RxdvL2 ;
reg     RxSofL1,RxSofL2;
//dsp
/*
always@( posedge rxaui_clk )
begin
    RxdvL1    <=  Rxdv   ;
    RxdvL2    <=  RxdvL1 ;
    rxdv      <=  RxdvL2 ;
    
    RxSofL1   <=  RxSof   ;
    RxSofL2   <=  RxSofL1 ;
    rxsop     <=  RxSofL2 ;
end
*/
assign rxeop    = crc_rxeop ;
assign rxmod    = crc_rxmod ;
assign rxd      = crc_rxd ;
assign CrcRxErr = crc_err ;

//dsp
assign rxsop    = crc_rxsop ;
assign rxdv      = crc_rxdv ;

/**********************************************************/
//
//     change mod to length
//
/**********************************************************/
parameter      CUT_CYC = 12'h4e3 ; // 2048 byte 


parameter                   ST_IDLE = 1'b0;   //Idle, waiting for data
parameter                   ST_RECV = 1'b1;   //Receiving data
reg     [11:0]               pktcnt;
reg                         cur_state;
reg                         max_ch;
reg     len_err ;

always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        cur_state <=ST_IDLE;
    else
        if( rxdv )
            if( cur_state==ST_IDLE )
                begin
                if( rxsop )
                    cur_state  <=ST_RECV;
                else
                    cur_state  <=ST_IDLE;
                end
                //a special status include:sop and eop asserted at same cycle
                //FSM will keep ST_IDLE
            else
                begin
                if( rxeop || max_ch )
                    cur_state  <=ST_IDLE;
                else
                    cur_state  <=ST_RECV;
                end
        else ;//(rxdv==1'b0), Keep cur_state unchanged
end

//Clear at beginning and Assert at the cycle before the last
always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        pktcnt <=12'b0;
    else
        if( rxdv && rxsop && (cur_state==ST_IDLE) )
            pktcnt <=12'b1;
        else if( rxdv && (cur_state==ST_RECV) )
            pktcnt <=pktcnt+1'b1;
        else ;
end

always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        max_ch <=1'b0;
    else
        if( rxdv && rxsop && (!cur_state) )
            max_ch <=1'b0;
        else if( rxdv && (pktcnt==CUT_CYC) )
            max_ch <=1'b1;
        else ;
end

always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        opktwsop_t <=1'b0;
    else
        opktwsop_t <=rxdv && rxsop && (cur_state==ST_IDLE);
end


always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        opktweop_t <=1'b0;
    else if ( rxsop == 1'b1 && cur_state==ST_IDLE )
        //for min packet(<64B)
        opktweop_t <=rxdv && rxeop ;
    else 
        if ( max_ch == 1'b1 )
            // for max packet(>1536B)
            opktweop_t <=( cur_state==ST_RECV );
        else
            //for normal packet (65~1536)
            opktweop_t <=rxdv && rxeop && (cur_state==ST_RECV) ;
end

always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        opktwenb_t <=1'b0;
    else
        if( rxdv )
            opktwenb_t <=((cur_state==ST_IDLE)&(rxsop==1'b1)) | (cur_state==ST_RECV);
        else
            opktwenb_t <=1'b0;
end

always@(posedge rxaui_clk )
begin     
    opktwdat_t <= rxd    ;
    crc_err_t  <= CrcRxErr[0] || CrcRxErr[1] ;
end

always@(posedge rxaui_clk)
begin
    if(rxdv&&rxeop)
        if(rxmod==3'b0)
            opktwlen_t <= {(pktcnt+1),3'b0};
        else
            opktwlen_t <= {pktcnt,3'b0} + rxmod;
    else 
         opktwlen_t <=  {(pktcnt+1),3'b0};
end

reg     len_err_t ;

always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        len_err_t <=1'b0;
    else if ( max_ch == 1'b1 )
        // for max packet(>1536B)
        len_err_t <=( cur_state==ST_RECV );
    else
        len_err_t <=1'b0;
end
     
//assign   opktwlen_t =  (opktweop_t && opktwenb_t)? (rxmod==3'b0)?{pktcnt,3'b0}:({(pktcnt-1),3'b0} + rxmod))({(pktcnt-1),3'b0} + rxmod) : {pktcnt,3'b0} ; 

/********************************************/

always@(posedge rxaui_clk)
begin
    opktwdat <= opktwdat_t    ;
    opktwenb <= opktwenb_t    ;
    opktwsop <= opktwsop_t    ;
    opktweop <= opktweop_t    ;
    opktwlen <= {( crc_err_t ||len_err_t ),opktwlen_t} ;
end

/********************************************/

always@(posedge rxaui_clk)
begin
    if ( rxeop && pktcnt[11] == 1'b1 && pktcnt[10:0] != 8'h0 )
        len_err <= 1'b1 ;
    else
        len_err <= 1'b0 ;
end

/********************************************/

//assign stat_inc[0] = Rxdv && RxSof ;
//assign stat_inc[1] = Rxdv && RxEof ;
//assign stat_inc[2] = PreRxdv && PreRxEof ;
//assign stat_inc[3] = rxdv && rxeop && CrcRxErr[0] ;
//assign stat_inc[4] = rxdv && rxeop && CrcRxErr[1] ;
//assign stat_inc[5] = rxdv ;
//
//assign stat_inc_d5 = rxeop ? {(rxmod == 3'b0),rxmod} : 4'h8 ;

always@(posedge rxaui_clk)
begin
    stat_inc[0] <= Rxdv && RxSof ;
    stat_inc[1] <= Rxdv && RxEof ;
    stat_inc[2] <= rxdv && rxeop && CrcRxErr[0] ;
    stat_inc[3] <= rxdv && rxeop && CrcRxErr[1] ;
    stat_inc[4] <= len_err_t ;
    stat_inc[5] <= crc_rxdv ;
end

always@(posedge rxaui_clk)
begin
    if ( rxeop == 1'b1 )
        stat_inc_d5 <= {(rxmod == 3'b0),rxmod} ;
    else
        stat_inc_d5 <= 4'h8 ;
end

/*******************************************************************/

reg     [31:0]      byte_rate_cnt ;

always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        byte_rate_cnt <= 32'h0 ;
    else if ( time_1s == 1'b1 )
        byte_rate_cnt <= 32'h0 ;
    else  begin
        if ( PreRxdv == 1'b1 )
            begin
                if(PreRxEof)
                    byte_rate_cnt<=(PreRxMod==0)?byte_rate_cnt+ 32'h8:byte_rate_cnt+PreRxMod;
                else
                    byte_rate_cnt <= byte_rate_cnt + 32'h8 ;
            end
        else
          byte_rate_cnt <= byte_rate_cnt;
      end
end

always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        byte_rate <= 32'h0 ;
    else if ( time_1s == 1'b1 )
        byte_rate <= byte_rate_cnt ;
    else ;
end

/*******************************************************************/

reg     [27:0]      pps_rate_cnt ;

always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        pps_rate_cnt <= 28'h0 ;
    else if ( time_1s == 1'b1 )
        pps_rate_cnt <= 28'h0 ;
    else 
        if ( Rxdv && RxSof )
            pps_rate_cnt <= pps_rate_cnt + 1'b1 ;
        else
            pps_rate_cnt <= pps_rate_cnt;
end

always@( posedge rxaui_clk or posedge reset )
begin
    if( reset == 1'b1 )
        pps_rate <= 28'h0 ;
    else if ( time_1s == 1'b1 )
        pps_rate <= pps_rate_cnt ;
    else ;
end

endmodule

