// ***************************************************************************************
//
// Copyright(c) 2007, Semptian Technologies Ltd., All right reserved
//
// Filename        :    xgmii_rx_ifc_pp.v
// Author          :    Eric
// Email           :    Eric@semptian.com
// Company         :    Semptian Technologies Ltd.
//
// Description     :    xgmii timing to mii64 timing
//
// ***************************************************************************************
// DEFINE
`include "define.v"

module xgmii_rx_ifc_pp(

input                       Reset    	,
input                   	Clk			,

input   [63:0]              xgmii_rxd   ,
input   [7:0]               xgmii_rxc   ,

output reg                  Rxdv        ,
output reg [63:0]           Rxd         ,
output reg                  RxSof       ,
output reg                  RxEof       ,
output reg [2:0]            RxMod       ,
output                      RxErr
    );

/************************************************************************/
//
// FSM
//
/************************************************************************/
//
// 1. Packets on XGMII are delimited by CHAR_S & CHAR_T
// 2. About CHAR_S
//    (1) MUST be on lane 0 or lane 4
//    (2) min IFG should be observed
//
parameter                   ST_IDLE = 1'b0;   //Idle, waiting for data
parameter                   ST_RECV = 1'b1;   //Receiving data

reg                         ChState;

wire    [7:0]               B0, B1, B2, B3, B4, B5, B6, B7;
wire                        even_column_start;
wire                        odd_column_start;

//CHAR_T can be present at any lane
wire    [7:0]               lane_term;
wire                        even_column_term;
wire                        odd_column_term;

reg                         IFG_en; //min IFG is 4 for higig, 5 for IEEE stardard 802.3 clause 46

reg                         RxSof_detect;
reg                         RxEof_detect;

assign B0 = xgmii_rxd[7:0];
assign B1 = xgmii_rxd[15:8];
assign B2 = xgmii_rxd[23:16];
assign B3 = xgmii_rxd[31:24];
assign B4 = xgmii_rxd[39:32];
assign B5 = xgmii_rxd[47:40];
assign B6 = xgmii_rxd[55:48];
assign B7 = xgmii_rxd[63:56];

//
// CHAR_S must be at either Lane 0 or Lane 4
//
// tiny packets are ignored
// CHAR_S before meeting min IFG is ignored
assign even_column_start = (xgmii_rxc==8'h01) && (B0==`XGMII_CHAR_S) && (IFG_en==1'b0);
// 4 control characters on lane 0-3 can meet min IFG requirement.
assign  odd_column_start = (xgmii_rxc==8'h1f) && (B4==`XGMII_CHAR_S);

//eof detection
/*   
assign lane_term[0] = xgmii_rxc[0] & (B0==`XGMII_CHAR_T);
assign lane_term[1] = xgmii_rxc[1] & (B1==`XGMII_CHAR_T);
assign lane_term[2] = xgmii_rxc[2] & (B2==`XGMII_CHAR_T);
assign lane_term[3] = xgmii_rxc[3] & (B3==`XGMII_CHAR_T);
assign lane_term[4] = xgmii_rxc[4] & (B4==`XGMII_CHAR_T);
assign lane_term[5] = xgmii_rxc[5] & (B5==`XGMII_CHAR_T);
assign lane_term[6] = xgmii_rxc[6] & (B6==`XGMII_CHAR_T);
assign lane_term[7] = xgmii_rxc[7] & (B7==`XGMII_CHAR_T);
*/
assign lane_term[0] = xgmii_rxc[0];
assign lane_term[1] = xgmii_rxc[1];
assign lane_term[2] = xgmii_rxc[2];
assign lane_term[3] = xgmii_rxc[3];
assign lane_term[4] = xgmii_rxc[4];
assign lane_term[5] = xgmii_rxc[5];
assign lane_term[6] = xgmii_rxc[6];
assign lane_term[7] = xgmii_rxc[7]; 

assign even_column_term  = |lane_term[3:0];
assign  odd_column_term  = |lane_term[7:4];


always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        ChState <=ST_IDLE;
    else
        if( ChState==ST_IDLE )
            begin
            if( even_column_start || odd_column_start )
                ChState  <=ST_RECV;
            else
                ChState  <=ST_IDLE;
            end
        else
            begin
            if( ((even_column_term==1'b0)&&(odd_column_term==1'b0)) || 
                (lane_term[0] && odd_column_start) ) //back-to-back tranfer with 4-byte min IFG
                ChState  <=ST_RECV;
            else
                ChState  <=ST_IDLE;
            end
end

always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        IFG_en <=1'b0;
    else
        IFG_en <=(ChState==ST_RECV) & (lane_term[4:0]==5'b0) & (lane_term[5] | lane_term[6] | lane_term[7]);
end

/************************************************************************/
//
// packet data fifo write control
//
/************************************************************************/
reg                         even_aligned; //CHAR_S at lane 0

reg     [63:0]              xgmii_rxd_r;
wire    [7:0]               B0_r, B1_r, B2_r, B3_r, B4_r, B5_r, B6_r, B7_r;

assign B0_r = xgmii_rxd_r[7:0];
assign B1_r = xgmii_rxd_r[15:8];
assign B2_r = xgmii_rxd_r[23:16];
assign B3_r = xgmii_rxd_r[31:24];
assign B4_r = xgmii_rxd_r[39:32];
assign B5_r = xgmii_rxd_r[47:40];
assign B6_r = xgmii_rxd_r[55:48];
assign B7_r = xgmii_rxd_r[63:56];

always@( posedge Clk )
begin
    xgmii_rxd_r <=xgmii_rxd;
end

always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        even_aligned <=1'b0;
    else
        if( ChState==ST_IDLE )
            even_aligned <=even_column_start;
        else if( lane_term[0] && odd_column_start )//back-to-back tranfer situation
            even_aligned <=1'b0;
        else ;
end


always@( posedge Clk )
begin
    Rxd <=even_aligned ? {B0_r, B1_r, B2_r, B3_r, B4_r, B5_r, B6_r, B7_r} : {B4_r, B5_r, B6_r, B7_r, B0, B1, B2, B3};
end

always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        RxSof_detect <=1'b0;
    else
        if( ChState==ST_IDLE )
            RxSof_detect <=(even_column_start || odd_column_start);
        else
            RxSof_detect <=lane_term[0] && odd_column_start;
end

// do not assert for single cycle packets
always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        RxSof <=1'b0;
    else
        RxSof <=RxSof_detect & ((even_aligned & (lane_term[0]==1'b0)) | ((even_aligned==1'b0) & (lane_term[4:0]==5'b0)));
end

always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        begin
        RxEof_detect <=1'b0;
        RxEof <=1'b0;
        end
    else
        begin
        if( ChState==ST_RECV )
            if( even_aligned )
                RxEof_detect <=(|lane_term[7:1]) & (lane_term[0]==1'b0);
            else
                RxEof_detect <=(|lane_term[7:5]) & (lane_term[4:0]==5'h0);
        else
            RxEof_detect <=1'b0;

        if( RxEof_detect )
            RxEof <=1'b1;
        else if( ChState==ST_RECV )
            if( even_aligned )
                RxEof <=lane_term[0];
            else
                RxEof <=|lane_term[4:0];
        else
            RxEof <=1'b0;
        end
end

always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        Rxdv <=1'b0;
    else
        if( RxEof_detect )
            Rxdv <=1'b1;
        else if( ChState==ST_RECV )
            if( even_aligned )
                Rxdv <=((RxSof_detect&lane_term[0])==1'b0);
            else
                Rxdv <=((RxSof_detect&(|lane_term[4:0]))==1'b0);
        else
            Rxdv <=1'b0;
end

assign RxErr = 1'b0;

reg     [2:0]               RxMod_tmp;
always@*
begin
    if( even_aligned )
        casex( lane_term )
            8'bxxxx_xxx1: RxMod_tmp = 3'h0;
            8'bxxxx_xx10: RxMod_tmp = 3'h1;
            8'bxxxx_x100: RxMod_tmp = 3'h2;
            8'bxxxx_1000: RxMod_tmp = 3'h3;
            8'bxxx1_0000: RxMod_tmp = 3'h4;
            8'bxx10_0000: RxMod_tmp = 3'h5;
            8'bx100_0000: RxMod_tmp = 3'h6;
            default:      RxMod_tmp = 3'h7;
        endcase    
    else
        casex( lane_term )
            8'bxxxx_xxx1: RxMod_tmp = 3'h4;
            8'bxxxx_xx10: RxMod_tmp = 3'h5;
            8'bxxxx_x100: RxMod_tmp = 3'h6;
            8'bxxxx_1000: RxMod_tmp = 3'h7;
            8'bxxx1_0000: RxMod_tmp = 3'h0;
            8'bxx10_0000: RxMod_tmp = 3'h1;
            8'bx100_0000: RxMod_tmp = 3'h2;
            default:      RxMod_tmp = 3'h3;
        endcase    
end

always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        RxMod <=3'b0;
    else
        if( (ChState==ST_RECV) && (even_column_term || odd_column_term) )
            RxMod <=RxMod_tmp;
        else ;
end


endmodule