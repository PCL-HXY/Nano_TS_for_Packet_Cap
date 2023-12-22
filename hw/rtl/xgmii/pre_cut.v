// ***************************************************************************************
//
// Copyright(c) 2007, Semptian Technologies Co., Ltd, All right reserved
//
// Filename        :    pre_cut.v
// Projectname     :    sempsec7
// Author          :    zhouyihua
// Email           :    zhouyihua@semptian.com
// Date            :    May 17th, 2010
// Version         :    1.0
// Company         :    Semptian Technologies Ltd.
//
// Description     :    cut the preamble code from the package
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
// Module       :    pre_cut
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

module  pre_cut  (
                Reset                       ,
                Clk                         ,

                Rxdv                        ,
                Rxd                         ,
                RxSof                       ,
                RxEof                       ,
                RxMod                       ,

                PreRxdv                     ,
                PreRxd                      ,
                PreRxSof                    ,
                PreRxEof                    ,
                PreRxMod                    ,
                PreErr
                  );

parameter PRE_NUM = 64'hfb555555555555d5;

input   wire            Reset               ;
input   wire            Clk                 ;

input   wire            Rxdv                ;
input   wire  [63:0]    Rxd                 ;
input   wire            RxSof               ;
input   wire            RxEof               ;
input   wire  [2:0]     RxMod               ;

output  reg             PreRxdv             ;
output  reg   [63:0]    PreRxd              ;
output  reg             PreRxSof            ;
output  reg             PreRxEof            ;
output  reg   [2:0]     PreRxMod            ;
output  reg             PreErr              ;

/**********************************************************************/
/*******************************************************************\
*                                                                   *
*                        Creat the Output                           *
*                                                                   *
\*******************************************************************/
reg                     RxSofL1;
reg                     ErrTest;

//assign PreRxdv = (~RxSof) & Rxdv;
//assign PreRxd  = Rxd;
//assign PreRxSof = RxSofL1 & Rxdv;
//assign PreRxEof = (~RxSof) & RxEof;
//assign PreRxMod = RxMod;

always@(posedge Clk)
begin
    PreRxdv  <= (~RxSof) & Rxdv;
    PreRxd   <= Rxd;
    PreRxSof <= RxSofL1 & Rxdv;
    PreRxEof <= (~RxSof) & RxEof;
    PreRxMod <= RxMod;
    PreErr   <= RxSofL1 & ErrTest;
end

always@(posedge Clk or posedge Reset)
begin
    if(Reset == 1'b1)
        RxSofL1 <= 1'b0;
    else
        RxSofL1 <= RxSof;
end

/*******************************************************************\
*                                                                   *
*                        Cheak The Preamble                         *
*                                                                   *
\*******************************************************************/


//assign PreErr = PreRxSof & ErrTest;

always@(posedge Clk or posedge Reset)
begin
    if(Reset == 1'b1)
        ErrTest <= 1'b0;
    else
        if(RxSof == 1'b1)
            if(Rxd != PRE_NUM)
                ErrTest <= 1'b1;
            else
                ErrTest <= 1'b0;
        else
            ErrTest <= 1'b0;
end

endmodule