// ***************************************************************************************
//
// Copyright(c) 2007, Semptian Technologies Co., Ltd, All right reserved
//
// Filename        :    crc_add_pp.v
// Projectname     :    sempsec7
// Author          :    zhouyihua
// Email           :    zhouyihua@semptian.com
// Date            :    May 17th, 2010
// Version         :    1.0
// Company         :    Semptian Technologies Ltd.
//
// Description     :    add the crc-32 into the package
//
// Modification History
// Date            By            Revision        Change Description
// ---------------------------------------------------------------------------------------
// 2010/05/17      zhouyihua      1.0             Original
//
// ***************************************************************************************
// DEFINE
//                                                 
// ***************************************************************************************
//
// Module       :    crc_add_pp
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

module  crc_add_pp  (
                Reset                       ,
                Clk                         ,

                CrcTxdv                     ,
                CrcTxd                      ,
                CrcTxSof                    ,
                CrcTxEof                    ,
                CrcTxMod                    ,

                PreTxdv                     ,
                PreTxd                      ,
                PreTxSof                    ,
                PreTxEof                    ,
                PreTxMod
                  );

parameter CRC_INIT = 32'hffffffff;

input   wire            Reset               ;
input   wire            Clk                 ;  

input   wire            CrcTxdv             ;
input   wire  [63:0]    CrcTxd              ;
input   wire            CrcTxSof            ;
input   wire            CrcTxEof            ;
input   wire  [2:0]     CrcTxMod            ;

output  wire            PreTxdv             ;
output  reg   [63:0]    PreTxd              ;
output  wire            PreTxSof            ;
output  wire            PreTxEof            ;
output  reg   [2:0]     PreTxMod            ;

/**********************************************************************/
/********************************************************************\
*                                                                    *
*                    INSTANCE CRC MODULE                             *
*                                                                    *
\********************************************************************/
// *******************************************************************
// 1.crcwidth 0 flag 1 byte,and 7 flag 8 bytes              
// 2.crc result out two clock after CrcTxdv deasserted

wire    [2:0]           CrcMode;
wire    [2:0]           CrcWidth;

wire    [31:0]          CrcOut;

assign CrcMode = CrcTxMod - 3'h1;
assign CrcWidth = (CrcTxEof == 1'b1) ? CrcMode : 3'h7 ;

V5_CRC  #(
        .CRC_INIT( CRC_INIT )
         ) U_V5_CRC(
                .Reset              (Reset              ),
	            .CRCOUT             (CrcOut             ),
	            .CRCCLK             (Clk                ),
	            .CRCDATAVALID       (CrcTxdv            ),
	            .CRCDATAWIDTH       (CrcWidth           ),
	            .CRCIN              (CrcTxd             ),
	            .CRCRESET           (CrcTxSof           )
);

/********************************************************************\
*                                                                    *
*                 Add The Crc32 In The Package                       *
*                                                                    *
\********************************************************************/
// *******************************************************************
// 1.the minimum gap between two CrcTxEof is two clock,so TxModeRc
//   can occur in two clock,and TxModeRcL1 covers two clocks when
//   PreTxEof is created.
// 2.the package output two clocks after package input


reg     [31:0]          CrcOutRc;

reg                     CrcTxdvL1;
reg                     CrcTxdvL2;

reg     [63:0]          CrcTxdL1;
reg     [63:0]          CrcTxdL2;

reg                     CrcSofL1;
reg                     CrcSofL2;

reg                     CrcEofL1;
reg                     CrcEofL2;
reg                     CrcEofL3;

reg     [2:0]           TxModeRc;
reg     [2:0]           TxModeRcL1;

always@(posedge Clk)
begin
    CrcOutRc <= CrcOut;
end

always@(posedge Clk)
begin
    CrcTxdvL1 <= CrcTxdv;
    CrcTxdvL2 <= CrcTxdvL1;
end

always@(posedge Clk)
begin
    CrcTxdL1 <= CrcTxd;
    CrcTxdL2 <= CrcTxdL1;
end

always@(posedge Clk)
begin
    CrcSofL1 <= CrcTxSof;
    CrcSofL2 <= CrcSofL1;
end

always@(posedge Clk)
begin
    CrcEofL1 <= CrcTxEof;
    CrcEofL2 <= CrcEofL1;
    CrcEofL3 <= CrcEofL2;
end

always@(posedge Clk or posedge Reset)
begin
    if(Reset == 1'b1)
        TxModeRc <= 3'h0;
    else
        if(CrcTxEof == 1'b1)
            TxModeRc <= CrcTxMod;
        else
            TxModeRc <= TxModeRc;
end

always@(posedge Clk)
begin
    TxModeRcL1 <= TxModeRc;
end

assign PreTxdv  = CrcTxdvL2 | PreTxEof;
assign PreTxSof = CrcSofL2;
assign PreTxEof = ((TxModeRcL1 < 3'h5) && (TxModeRcL1 > 3'h0)) ? CrcEofL2 : CrcEofL3 ;

always @(*)
begin
    case(TxModeRcL1)
        3'h1:   PreTxMod <= 3'h5;
        3'h2:   PreTxMod <= 3'h6;
        3'h3:   PreTxMod <= 3'h7;
        3'h4:   PreTxMod <= 3'h0;
        3'h5:   PreTxMod <= 3'h1;
        3'h6:   PreTxMod <= 3'h2;
        3'h7:   PreTxMod <= 3'h3;
        default: PreTxMod <= 3'h4;
    endcase
end

always @(*)
begin
    if(PreTxEof == 1'b1)
        case(TxModeRcL1)
            3'h1:   PreTxd <=  {CrcTxdL2[63:56],CrcOut[31:0],24'h0};
            3'h2:   PreTxd <=  {CrcTxdL2[63:48],CrcOut[31:0],16'h0};
            3'h3:   PreTxd <=  {CrcTxdL2[63:40],CrcOut[31:0],8'h0};
            3'h4:   PreTxd <=  {CrcTxdL2[63:32],CrcOut[31:0]};
            3'h5:   PreTxd <=  {CrcOutRc[7:0],56'h0};
            3'h6:   PreTxd <=  {CrcOutRc[15:0],48'h0};
            3'h7:   PreTxd <=  {CrcOutRc[24:0],40'h0};
            default: PreTxd <= {CrcOutRc[31:0],32'h0};
        endcase
    else if(CrcEofL2 == 1'b1)
        case(TxModeRcL1)
            4'h5:   PreTxd <=  {CrcTxdL2[63:24],CrcOut[31:8]};
            4'h6:   PreTxd <=  {CrcTxdL2[63:16],CrcOut[31:16]};
            4'h7:   PreTxd <=  {CrcTxdL2[63:8],CrcOut[31:24]};
            default: PreTxd <= CrcTxdL2;
        endcase
    else
        PreTxd <=  CrcTxdL2;
end

endmodule