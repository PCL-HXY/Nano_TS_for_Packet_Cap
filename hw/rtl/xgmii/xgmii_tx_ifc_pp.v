// ***************************************************************************************
//
// Copyright(c) 2007, Semptian Technologies Ltd., All right reserved
//
// Filename        :    xgmii_tx_ifc_pp.v
// Author          :    Eric
// Email           :    Eric@semptian.com
// Company         :    Semptian Technologies Ltd.
//
// Description     :    mii64 timing to xgmii timing
//
// ***************************************************************************************
// DEFINE
`include "define.v"

module xgmii_tx_ifc_pp(

input                       Reset    	,
input                   	Clk			,

output reg [63:0]           xgmii_txd   ,
output reg [7:0]            xgmii_txc   ,

input                       Txdv        ,
input   [63:0]              Txd         ,
input                       TxSof       ,
input                       TxEof       ,
input   [2:0]               TxMod
    );


/************************************************************************/
//
// signals
//
/************************************************************************/
wire    [7:0]               B0, B1, B2, B3, B4, B5, B6, B7;

reg                         OneMore;
reg                         TwoMore;

wire                        tx_start;
wire                        tx_end;
reg                         IFG_en; //min IFG is 4 for higig, 5 for IEEE stardard 802.3 clause 46
reg                         CHAR_T_en; //send CHAR_T to lane0 at next cycle if mod=0

reg     [63:0]              xgmii_txd_t   ;
reg     [7:0]               xgmii_txc_t   ;

/************************************************************************/
//
// FSM
//
/************************************************************************/
//
parameter                   ST_IDLE = 1'b0;   //Idle, waiting for data
parameter                   ST_RECV = 1'b1;   //Receiving data
reg                         ChState;


assign B7 = Txd[7:0];
assign B6 = Txd[15:8];
assign B5 = Txd[23:16];
assign B4 = Txd[31:24];
assign B3 = Txd[39:32];
assign B2 = Txd[47:40];
assign B1 = Txd[55:48];
assign B0 = Txd[63:56];

//tiny packets are ignored
assign tx_start = Txdv & TxSof & (TxEof==1'b0) & (IFG_en==1'b0);

assign tx_end = TxEof;

always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        ChState <=ST_IDLE;
    else
        if( ChState==ST_IDLE )
            begin
            if( tx_start )
                ChState  <=ST_RECV;
            else
                ChState  <=ST_IDLE;
            end
        else
            begin
            if( tx_end )
                ChState  <=ST_IDLE;
            else
                ChState  <=ST_RECV;
            end
end

//add 1 idle cycle to meet minIFG=4
always@( posedge Clk )
begin
    if( Reset == 1'b1 )
        begin
        IFG_en <=1'b0;
        CHAR_T_en <=1'b0;
        end
    else
        begin
        IFG_en <=(ChState==ST_RECV) & Txdv & TxEof & ((TxMod==3'h5)|(TxMod==3'h6)|(TxMod==3'h7)|(TxMod==3'h0));
        CHAR_T_en <=(ChState==ST_RECV) & Txdv & TxEof & (TxMod==3'h0);
        end
end

/************************************************************************/
//
// packet data fifo write control
//
/************************************************************************/
always@( posedge Clk )
begin
        if( ChState==ST_IDLE )
            if( tx_start )
                begin
                xgmii_txc_t <=8'h01;
                xgmii_txd_t <={B7, B6, B5, B4, B3, B2, B1, `XGMII_CHAR_S}; //the 1st byte is replaced by CHAR_S
                end
            else if( IFG_en )
                begin
                xgmii_txc_t <=8'hff;
                xgmii_txd_t <=CHAR_T_en ? {{7{`XGMII_CHAR_I}}, `XGMII_CHAR_T} : {8{`XGMII_CHAR_I}};
                end
            else
                begin
                xgmii_txc_t <=8'hff;
                xgmii_txd_t <={8{`XGMII_CHAR_I}};
                end
        else //( ChState==ST_RECV )
            if( tx_end==1'b0 )
                begin
                xgmii_txc_t <=8'h00;
                xgmii_txd_t <={B7, B6, B5, B4, B3, B2, B1, B0};
                end
            else
                case( TxMod )
                    3'h1:
                        begin
                        xgmii_txc_t <=8'hfe;
                        xgmii_txd_t <={{6{`XGMII_CHAR_I}}, `XGMII_CHAR_T, B0};
                        end
                    3'h2:
                        begin
                        xgmii_txc_t <=8'hfc;
                        xgmii_txd_t <={{5{`XGMII_CHAR_I}}, `XGMII_CHAR_T, B1, B0};
                        end
                    3'h3:
                        begin
                        xgmii_txc_t <=8'hf8;
                        xgmii_txd_t <={{4{`XGMII_CHAR_I}}, `XGMII_CHAR_T, B2, B1, B0};
                        end
                    3'h4:
                        begin
                        xgmii_txc_t <=8'hf0;
                        xgmii_txd_t <={{3{`XGMII_CHAR_I}}, `XGMII_CHAR_T, B3, B2, B1, B0};
                        end
                    3'h5:
                        begin
                        xgmii_txc_t <=8'he0;
                        xgmii_txd_t <={{2{`XGMII_CHAR_I}}, `XGMII_CHAR_T, B4, B3, B2, B1, B0};
                        end
                    3'h6:
                        begin
                        xgmii_txc_t <=8'hc0;
                        xgmii_txd_t <={{1{`XGMII_CHAR_I}}, `XGMII_CHAR_T, B5, B4, B3, B2, B1, B0};
                        end
                    3'h7:
                        begin
                        xgmii_txc_t <=8'h80;
                        xgmii_txd_t <={`XGMII_CHAR_T, B6, B5, B4, B3, B2, B1, B0};
                        end
                    default:
                        begin
                        xgmii_txc_t <=8'h00;
                        xgmii_txd_t <={B7, B6, B5, B4, B3, B2, B1, B0};
                        end
                endcase 
end

always@( posedge Clk )
begin
    xgmii_txd  <= # `UDLY xgmii_txd_t ;
    xgmii_txc  <= # `UDLY xgmii_txc_t ;
end

endmodule