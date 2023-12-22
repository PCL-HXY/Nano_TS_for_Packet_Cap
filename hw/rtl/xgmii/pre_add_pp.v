// ***************************************************************************************
//
// Copyright(c) 2007, Semptian Technologies Co., Ltd, All right reserved
//
// Filename        :    pre_add_pp.v
// Projectname     :    sempsec7
// Author          :    zhouyihua
// Email           :    zhouyihua@semptian.com
// Date            :    May 17th, 2010
// Version         :    1.0
// Company         :    Semptian Technologies Ltd.
//
// Description     :    add the preamble into the package
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
// Module       :    pre_add_pp
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

module  pre_add_pp  (
                Reset                       ,
                Clk                         ,

                PreTxdv                     ,
                PreTxd                      ,
                PreTxSof                    ,
                PreTxEof                    ,
                PreTxMod                    ,

                Txdv                        ,
                Txd                         ,
                TxSof                       ,
                TxEof                       ,
                TxMod
                  );
input   wire            Reset               ;
input   wire            Clk                 ;  

input   wire            PreTxdv             ;
input   wire  [63:0]    PreTxd              ;
input   wire            PreTxSof            ;
input   wire            PreTxEof            ;
input   wire  [2:0]     PreTxMod            ;

output  wire            Txdv                ;
output  wire  [63:0]    Txd                 ;
output  wire            TxSof               ;
output  wire            TxEof               ;
output  wire  [2:0]     TxMod               ;

/**********************************************************************/
/*******************************************************************\
*                                                                   *
*              Delay The Input For One Clock                        *
*                                                                   *
\*******************************************************************/    
reg                     PreTxdvL1;
reg     [63:0]          PreTxdL1;
reg                     PreTxEofL1;
reg     [2:0]           PreTxModL1;

always@(posedge Clk)
begin
    PreTxdvL1 <=  PreTxdv;
end

always@(posedge Clk)
begin
    PreTxdL1 <=  PreTxd;
end

always@(posedge Clk)
begin
    PreTxEofL1 <=  PreTxEof;
end

always@(posedge Clk)
begin
    PreTxModL1 <=  PreTxMod;
end

/*******************************************************************\
*                                                                   *
*                        Creat the Output                           *
*                                                                   *
\*******************************************************************/
assign Txdv = PreTxdvL1 | PreTxSof;
assign TxSof = PreTxSof;
assign TxEof = PreTxEofL1;
assign TxMod = PreTxModL1;

assign Txd[63:0] = (TxSof == 1'b1) ? {{8{8'h55}},8'hd5} : PreTxdL1[63:0] ;

endmodule