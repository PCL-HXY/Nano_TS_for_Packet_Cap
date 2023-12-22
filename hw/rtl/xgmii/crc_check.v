// ***************************************************************************************
//
// Copyright(c) 2007, Semptian Technologies Co., Ltd, All right reserved
//
// Filename        :    crc_check.v
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
// Module       :    crc_check
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

module  crc_check  (
                Reset                       ,
                Clk                         ,

                PreRxdv                     ,
                PreRxd                      ,
                PreRxSof                    ,
                PreRxEof                    ,
                PreRxMod                    ,
                PreErr                      ,

                CrcRxdv                     ,
                CrcRxd                      ,
                CrcRxSof                    ,
                CrcRxEof                    ,
                CrcRxMod                    ,
                CrcRxErr
                  );

parameter CRC_INIT = 32'hffffffff;

input   wire            Reset               ;
input   wire            Clk                 ;  

input   wire            PreRxdv             ;
input   wire  [63:0]    PreRxd              ;
input   wire            PreRxSof            ;
input   wire            PreRxEof            ;
input   wire  [2:0]     PreRxMod            ;
input   wire            PreErr              ;

output  reg             CrcRxdv             ;
output  reg   [63:0]    CrcRxd              ;
output  reg             CrcRxSof            ;
output  reg             CrcRxEof            ;
output  reg   [2:0]     CrcRxMod            ;
output  wire  [1:0]     CrcRxErr            ;

/**********************************************************************/
/********************************************************************\
*                                                                    *
*                  Instance CRC Module And Check The CRC             *
*                                                                    *
\********************************************************************/
// *******************************************************************
// 1.crcwidth 0 flag 1 byte,and 7 flag 8 bytes              
// 2.crc result out two clock after CrcTxdv deasserted

wire    [2:0]           CrcMode;
wire    [2:0]           CrcWidth;

wire    [31:0]          CrcOut;
reg                     CrcErr;
reg                     PreRxEofL1;
reg                     CrcOutValid;

assign CrcMode = PreRxMod - 3'h1;
assign CrcWidth = (PreRxEof == 1'b1) ? CrcMode : 3'h7 ;

always@(posedge Clk or posedge Reset)
begin
    if(Reset == 1'b1)
        begin
            PreRxEofL1 <= 1'b0;
            CrcOutValid <= 1'b0;
        end
    else
        begin
            PreRxEofL1 <= PreRxEof;
            CrcOutValid <= PreRxEofL1;
        end
end

always@( * )
begin
    if((CrcOutValid == 1'b1) && (CrcOut != 32'h1cdf4421))
        CrcErr = 1'b1;
    else
        CrcErr = 1'b0;
end

V5_CRC  #(
        .CRC_INIT( CRC_INIT )
         ) U_V5_CRC(
                .Reset              (Reset              ),
	            .CRCOUT             (CrcOut             ),
	            .CRCCLK             (Clk                ),
	            .CRCDATAVALID       (PreRxdv            ),
	            .CRCDATAWIDTH       (CrcWidth           ),
	            .CRCIN              (PreRxd             ),
	            .CRCRESET           (PreRxSof           )
);

/********************************************************************\
*                                                                    *
*                       Creat THe Output                             *
*                                                                    *
\********************************************************************/
reg             CrcRxdvL1   ;          
reg   [63:0]    CrcRxdL1    ;          
reg             CrcRxSofL1  ;          
reg             CrcRxEofL1  ;          
reg   [2:0]     CrcRxModL1  ;          


reg                     PreErrRc;

assign CrcRxErr = {PreErrRc,CrcErr};

always@(posedge Clk or posedge Reset)
begin
    if(Reset == 1'b1)
        begin
            CrcRxdvL1   <= 1'b0;
            CrcRxdL1    <= 64'h0;
            CrcRxSofL1  <= 1'b0;
            CrcRxEofL1  <= 1'b0;
            CrcRxModL1  <= 3'h0;
        end
    else
        begin
            CrcRxdvL1   <= PreRxdv;
            CrcRxdL1    <= PreRxd;
            CrcRxSofL1  <= PreRxSof;
            CrcRxEofL1  <= PreRxEof;
            CrcRxModL1  <= PreRxMod;
        end
end

always@(posedge Clk or posedge Reset)
begin
    if(Reset == 1'b1)
        begin
            CrcRxdv  <= 1'b0;
            CrcRxd   <= 64'h0;
            CrcRxSof <= 1'b0;
            CrcRxEof <= 1'b0;
            CrcRxMod <= 3'h0;
        end
    else
        begin
            CrcRxdv  <= CrcRxdvL1  ; 
            CrcRxd   <= CrcRxdL1   ;
            CrcRxSof <= CrcRxSofL1 ;
            CrcRxEof <= CrcRxEofL1 ;
            CrcRxMod <= CrcRxModL1 ;
        end
end

always@(posedge Clk or posedge Reset)
begin
    if(Reset == 1'b1)
        PreErrRc <= 1'b0;
    else
        if(PreRxSof == 1'b1)
            PreErrRc <= PreErr;
        else
            PreErrRc <= PreErrRc;
end

endmodule