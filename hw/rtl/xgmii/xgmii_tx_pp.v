// ***************************************************************************************
//
// Copyright(c) 2003, Semptian Technologies Ltd., All right reserved
//
// Filename        :    xgmii_tx_pp.v
// Projectname     :    semppp
// Author          :    zhangjun
// Email           :    zhangjun@semptian.com
// Date            :    Aug 19th, 2011
// Version         :    1.0
// Company         :    Semptian Technologies Ltd.
//
// Description     :    xgmii        
//
// Modification History
// Date            By            Revision        Change Description
// ---------------------------------------------------------------------------------------
// 2011/08/19      zhangjun      1.0             Original
//
// ***************************************************************************************
// DEFINE
//  
//                                                  
// ***************************************************************************************
`include "define.v"

module  xgmii_tx_pp(
                Reset                       ,
                Clk                         ,

                GEN_EN                      ,
				TX_OVER						,
                GEN_NUM                     ,
                VAL_LEN                     ,
                IDLE_LEN                    ,
                
                LEN_MODE                    ,
                DIP_MODE                    ,
                SIP_MODE                    ,
                DMAC_MODE                   ,
                SMAC_MODE                   ,
                DP_MODE                     ,
                SP_MODE                     ,
                DIP                         ,
                DMAC                        ,
                DP                          ,
                SP                          ,
              
                local_ip                    ,
                local_mac                   ,
                
                xgmii_txd                   ,
                xgmii_txc                   ,
                
                stat_inc                    ,
                stat_inc_d          
                  );

input   wire            Reset               ;
input   wire            Clk                 ;

input   wire            GEN_EN              ;
output  reg             TX_OVER             ;

input   wire  [63:0]    GEN_NUM             ;
input   wire  [31:0]    VAL_LEN             ;
input   wire  [31:0]    IDLE_LEN            ;
                        
input   wire  [1:0]     LEN_MODE            ;
input   wire  [1:0]     DIP_MODE            ;
input   wire  [1:0]     SIP_MODE            ;
input   wire  [1:0]     DMAC_MODE           ;
input   wire  [1:0]     SMAC_MODE           ;
input   wire  [1:0]     DP_MODE             ;
input   wire  [1:0]     SP_MODE             ;

input   wire  [31:0]    DIP                 ;
input   wire  [47:0]    DMAC                ;

input   wire  [15:0]    DP                  ;
input   wire  [15:0]    SP                  ;

input   wire  [31:  0]  local_ip            ;
input   wire  [47:  0]  local_mac           ;

output  wire  [63:0]    xgmii_txd           ; 
output  wire  [7:0]     xgmii_txc           ;

output  wire  [3:0]     stat_inc            ;
output  wire  [3:0]     stat_inc_d          ;

/*********************************************************/

reg            CrcTxdv             ;
reg  [63:0]    CrcTxd              ;
reg            CrcTxSof            ;
reg            CrcTxEof            ;
reg  [2:0]     CrcTxMod            ;

reg  [63:0]    gen_cnt             ;
reg  [10:0]     val_cnt             ;
reg  [15:0]    idle_cnt            ;
reg  			TX_OVER_R		   ; 
reg  [511:0]	TX_OVER_WIDE		;   



//???
reg  [31:0]     len_rnd             ;
reg  [31:0]     dip_rnd             ;
reg  [31:0]     sip_rnd             ;
reg  [47:0]     dmac_rnd            ;
reg  [47:0]     smac_rnd            ;
reg  [15:0]     dp_rnd              ;
reg  [15:0]     sp_rnd              ;
   

//????
reg  [31:0]     len_inc             ;
reg  [31:0]     dip_inc             ;
reg  [31:0]     sip_inc             ;
reg  [47:0]     dmac_inc            ;
reg  [47:0]     smac_inc            ;
reg  [15:0]     dp_inc              ;
reg  [15:0]     sp_inc              ;

//???
reg  [31:0]     len_rsv             ;
reg  [31:0]     dip_rsv             ;
reg  [31:0]     sip_rsv             ;
reg  [47:0]     dmac_rsv            ;
reg  [47:0]     smac_rsv            ;
reg  [15:0]     dp_rsv              ;
reg  [15:0]     sp_rsv              ;

reg  [31:0]     len                 ;
reg             GEN_EN_DLY1         ;
reg             GEN_EN_DLY2         ;
wire [19:0]     chksum              ;
wire [19:0]          HC_tmp0,HC_tmp1;
//Ethernet II
reg     [47:0]    dmac       =48'hffff_ffffffff      ;
reg     [47:0]    smac       =48'h0000_00000000      ;
wire    [15:0]    frame_type =16'h0800               ;
wire    [3:0]     pro_type   =4'h4                   ;
wire    [3:0]     hl         =4'h5                   ;
wire    [7:0]     tos        =8'h00                  ;   
reg     [15:0]    tl                                 ;
wire    [15:0]    id         =16'h0000               ;
wire    [2:0]     flag       =3'h2                   ;
wire    [12:0]    foset      =13'h00                 ;
wire    [7:0]     ttl                                ;
wire    [7:0]     protl      =8'h06                  ;
wire    [15:0]    hcsum                              ;
reg     [31:0]    sip        =32'h00000000           ;
reg     [31:0]    dip        =32'hffffffff           ; 
reg     [15:0]    sp         =16'h00                 ;
reg     [15:0]    dp         =16'h00                 ;
reg     [63:0]    iP_data    =64'h01234567_89abcdef  ;                            

reg    [47:0]       data1;
reg    [47:0]       data2;
reg    [47:0]       data3;
reg    [31:0]       data4;
reg    [10:0]       data5;
reg    [15:0]       data6;
reg    [15:0]       data7;
reg    [7:0 ]       data8 = 8'h55;

wire    [47:0]       data1_tmp;
wire    [47:0]       data2_tmp;
wire    [31:0]       data3_tmp;
wire    [31:0]       data4_tmp;
wire    [10:0]       data5_tmp;
wire    [15:0]       data6_tmp;
wire    [15:0]       data7_tmp;
wire    [15:0]       data8_tmp;

assign  data1_tmp=~data1_tmp;
assign  data2_tmp=~data2_tmp;
assign  data3_tmp=~data3_tmp;
assign  data4_tmp=~data4_tmp;
assign  data5_tmp=~data5_tmp;
assign  data6_tmp=~data6_tmp;
assign  data7_tmp=~data7_tmp;
assign  data8_tmp=~data8_tmp;


assign hcsum    =(~(chksum[15:0]+chksum[19:16]));
assign chksum   =0;   //HC_tmp0+HC_tmp1;
assign HC_tmp0  = {frame_type,hl,tos} + tl + id + {flag,foset} + {ttl,protl} ;
assign HC_tmp1  = sip[31:16] + sip[15:0] + dip[31:16] + dip[15:0] ;
assign ttl=data8;
parameter   IDLE    = 6'b000001 ,
            SOP     = 6'b000010 ,
            VAL     = 6'b000100 ,
            EOP     = 6'b001000 ,
            DLY1    = 6'b010000 ,
            DLY2    = 6'b100000 ;
            
reg     [5:0]           cur_state ;
always @ (posedge Clk )begin
 data1<=data1_tmp;
 data2<=data2_tmp;
 data3<=data3_tmp;
 data4<=data4_tmp;
 data5<=data5_tmp;
 data6<=data6_tmp;
 data7<=data7_tmp;
 //data8<=data8_tmp;
 TX_OVER_WIDE<={TX_OVER_WIDE[510:0],TX_OVER_R};
 TX_OVER<=&TX_OVER_WIDE;

end
always @ (posedge Clk )begin
    GEN_EN_DLY1<= GEN_EN; 
    GEN_EN_DLY2<=  GEN_EN_DLY1;     
end
always@( posedge Clk or posedge Reset  )
begin
    if ( Reset == 1'b1 )
        begin
        cur_state   <= IDLE ;
            
        CrcTxdv     <= 1'b0 ;
        CrcTxd      <= 64'b0 ;
        CrcTxSof    <= 1'b0 ;
        CrcTxEof    <= 1'b0 ;
        CrcTxMod    <= 3'h0 ;
		
		TX_OVER_R	<= 1'b1 ;
        end
    else
    case ( cur_state )
         IDLE :
            if( ((gen_cnt < GEN_NUM)||(GEN_NUM==0)) && GEN_EN_DLY2 == 1'b1 )
                begin
                cur_state    <= SOP ;
            
                CrcTxdv     <= 1'b1 ;
                CrcTxd      <= {dmac[47:0],smac[47:32]};//64'h00112233_44550012 ;
                CrcTxSof    <= 1'b1 ;
                CrcTxEof    <= 1'b0 ;
				
				TX_OVER_R	<= 1'b0 ;
               /* 
                  if ( MOD_CNT == 1'b1 )
                    CrcTxMod    <= CrcTxMod + 1'b1 ;
                else
                    CrcTxMod    <= 3'h0 ;
                     */
                end
              
            else
                begin
                cur_state    <= IDLE ;
				
                CrcTxdv     <= 1'b0 ;
                CrcTxd      <= 1'b0 ;
                CrcTxSof    <= 1'b0 ;
                CrcTxEof    <= 1'b0 ;
				
				TX_OVER_R	<= 1'b1 ;
                end
        SOP :
            begin
            cur_state    <= VAL ;
            CrcTxMod    <= len[2:0];
            CrcTxdv     <= 1'b1 ;
            CrcTxSof    <= 1'b0 ;
            CrcTxEof    <= 1'b0 ;            
            CrcTxd      <= {smac[31:0],frame_type[15:0],pro_type[3:0],hl[3:0],tos[7:0]};//64'h3456789a_08004500 ;
            end
        VAL :
            if( val_cnt == len_rsv>>>3 )
                begin
                cur_state    <= EOP ;
            
                CrcTxdv     <= 1'b1 ;
                CrcTxd      <= iP_data[63:0];//{{4{val_cnt}},gen_cnt} ;
                CrcTxSof    <= 1'b0 ;
                CrcTxEof    <= 1'b1 ;
                end
            else
                begin
                cur_state    <= VAL ;
            
                CrcTxdv     <= 1'b1 ;
                CrcTxSof    <= 1'b0 ;
                CrcTxEof    <= 1'b0 ;
                case ( val_cnt )
                    8'h0    : CrcTxd      <= {tl[15:0],id[15:0],flag[2:0],foset[12:0],ttl[7:0],protl[7:0]};//64'h004D480F_40007F06 ;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            0007F06 ;
                    8'h1    : CrcTxd      <= {hcsum[15:0],sip[31:0],dip[31:16]};//{16'h138B,gen_cnt[31:0],16'hC0A8} ;
                    8'h2    : CrcTxd      <= {dip[15:0],sp,dp,iP_data[15:0]};//{32'h0a0a0100,gen_cnt[15:0],16'hDFB7} ;
                    8'h3    : CrcTxd      <= iP_data[63:0];//64'h1F93A9B3_1ED45018 ;
                    8'h4    : CrcTxd      <= iP_data[63:0];//64'h1BEFBA85_00001703 ;
                    default : CrcTxd      <= iP_data[63:0];//{{4{val_cnt}},gen_cnt}; 
                endcase
                end
        EOP :
            begin
            cur_state    <= DLY1 ;
            
            CrcTxdv     <= 1'b0 ;
            CrcTxSof    <= 1'b0 ;
            CrcTxEof    <= 1'b0 ;
            end
        DLY1 :
            if ( idle_cnt == IDLE_LEN ) 
                begin
                cur_state    <= IDLE ;
                
                CrcTxdv     <= 1'b0 ;
                CrcTxSof    <= 1'b0 ;
                CrcTxEof    <= 1'b0 ;
                end
            else
                begin
                cur_state    <= DLY1 ;
                
                CrcTxdv     <= 1'b0 ;
                CrcTxSof    <= 1'b0 ;
                CrcTxEof    <= 1'b0 ;
                end
    endcase     
end

always@( posedge Clk or posedge Reset  )
begin
    if ( Reset == 1'b1 )
        gen_cnt <= 64'b0 ;
    else if (GEN_EN_DLY2== 1'b1 )
        if ( gen_cnt == GEN_NUM ) 
            gen_cnt <= gen_cnt ;
        else if ( cur_state == EOP )
            gen_cnt <= gen_cnt + 1'b1 ;
        else ;
    else
        gen_cnt <= 64'b0 ;
end

always@( posedge Clk or posedge Reset  )
begin
    if ( Reset == 1'b1 )
        val_cnt <= 11'd0 ;
    else if ( cur_state == VAL ) 
        val_cnt <= val_cnt + 1'd1 ;
    else if ( cur_state == EOP ) 
        val_cnt <= 11'd0 ;
    else ;
end

always@( posedge Clk or posedge Reset  )
begin
    if ( Reset == 1'b1 )
        idle_cnt <= 16'b0 ;
    else if ( cur_state == DLY1 ) 
        idle_cnt <= idle_cnt + 1'b1 ;
    else
        idle_cnt <= 16'b0 ;
end

/*******************************************************************\
*                                                                   *
*                     ?????                                      *
*                                                                   *
\*******************************************************************/
always @ ( posedge Clk )begin
   iP_data<=iP_data+1;
end
always @ ( posedge Clk )begin
    if ( Reset == 1'b1 )begin
        len     <= len_rsv-20-{(len_rsv[2:0]==3'b100),3'b000} ;
        dip     <= dip_rsv ;
        sip     <= sip_rsv ;
        dmac    <= dmac_rsv;
        smac    <= smac_rsv;  
        sp      <= sp_rsv  ;
        dp      <= dp_rsv  ;
    end
    else begin
        if(GEN_EN==1'b1 && cur_state==IDLE )begin
            case (LEN_MODE)
            2'b00: begin len<= len_rsv-20-{(len_rsv[2:0]==3'b100),3'b000}; tl<=len_rsv[15:0]-18;end
            2'b01: begin len<= len_inc-20-{(len_inc[2:0]==3'b100),3'b000}; tl<=len_inc[15:0]-18;end
            2'b10: begin len<= len_rnd-20-{(len_rnd[2:0]==3'b100),3'b000}; tl<=len_rnd[15:0]-18;end
            default:begin len<= len_rsv-20-{(len_rsv[2:0]==3'b100),3'b000};tl<=len_rsv[15:0]-18;end
            endcase 
            
            case (DIP_MODE)
            2'b00:  dip<= dip_rsv;
            2'b01:  dip<= dip_inc;
            2'b10:  dip<= dip_rnd;
            default:dip<= dip_rsv;
            endcase  
            
            case (SIP_MODE)
            2'b00:  sip<= sip_rsv;
            2'b01:  sip<= sip_inc;
            2'b10:  sip<= sip_rnd;
            default:sip<= sip_rsv;
            endcase  
            
            case (DMAC_MODE)
            2'b00:  dmac<= dmac_rsv;
            2'b01:  dmac<= dmac_inc;
            2'b10:  dmac<= dmac_rnd;
            default:dmac<= dmac_rsv;
            endcase  
            
            case (SMAC_MODE)
            2'b00:  smac<= smac_rsv;
            2'b01:  smac<= smac_inc;
            2'b10:  smac<= smac_rnd;
            default:smac<= smac_rsv;
            endcase

            case (DP_MODE)
            2'b00:  dp<= dp_rsv;
            2'b01:  dp<= dp_inc;
            2'b10:  dp<= dp_rnd;
            default:dp<= dp_rsv;
            endcase  
            
            case (SP_MODE)
            2'b00:  sp<= sp_rsv;
            2'b01:  sp<= sp_inc;
            2'b10:  sp<= sp_rnd;
            default:sp<= sp_rsv;
            endcase 
            
        end
        else begin
          len     <= len ;
          dip     <= dip ;
          sip     <= sip ;
          dmac    <= dmac;
          smac    <= smac; 
          dp      <= dp ;
          sp      <= sp ;
        end
    end
end 
//???//
always@( posedge Clk  )begin
    if({21'd0,data5[10:0]}<63)begin
        len_rnd<={21'd0,data5[4:0],6'b000000}+32'd64;
    end
    else begin
        len_rnd <= {21'd0,data5[10:0]}+32'd1; 
    end 
    dip_rnd <= data3; 
    sip_rnd <= data4; 
    dmac_rnd<= data1; 
    smac_rnd<= data2; 
    dp_rnd  <= data6; 
    sp_rnd  <= data7;
end  


//????//
always@( posedge Clk  or posedge Reset)begin
    if ( Reset == 1'b1 )begin
        len_inc <= 32'd64;   
        dip_inc <= 32'h00;  
        sip_inc <= 32'h00;   
        dmac_inc<= 48'h00; 
        smac_inc<= 48'h00; 
        dp_inc  <= 16'h00;  
        sp_inc  <= 16'h00; 
    end
    else begin
        //len
        if(cur_state == SOP && LEN_MODE==2'b01)begin
            if(len_inc==32'd2048)begin
                len_inc<= 32'd64; 
            end
            else begin
                len_inc <= len_inc+32'd1;
            end
        end
        else begin
            if(GEN_EN_DLY2 == 1'b1)
             len_inc <= len_inc;   
            else
             len_inc <= 32'd64;
        end
        
        //dip
        if(cur_state == SOP && DIP_MODE==2'b01)begin
            dip_inc <= dip_inc+32'd1;
        end
        else begin
            if(GEN_EN_DLY2 == 1'b1)
             dip_inc <= dip_inc;   
            else
             dip_inc <= 32'd0;
        end
        
        //sip
        if(cur_state == SOP && SIP_MODE==2'b01)begin
            sip_inc <= sip_inc+32'd1;
        end
        else begin
             if(GEN_EN_DLY2 == 1'b1)
             sip_inc <= sip_inc;   
            else
             sip_inc <= 32'd0;
        end
        
        //dmac
        if(cur_state == SOP && DMAC_MODE==2'b01)begin
            dmac_inc <= dmac_inc+48'd1;
        end
        else begin
             if(GEN_EN_DLY2 == 1'b1)
             dmac_inc <= dmac_inc;   
             else
             dmac_inc <= 48'd0;            
        end
        
        //smac
        if(cur_state == SOP && SMAC_MODE==2'b01)begin
            smac_inc <= smac_inc+48'd1;
        end
        else begin
             if(GEN_EN_DLY2 == 1'b1)
             smac_inc <= smac_inc;   
             else
             smac_inc <= 48'd0;            
        end
        
        //dp
        if(cur_state == SOP && DIP_MODE==2'b01)begin
            dp_inc <= dp_inc+16'd1;
        end
        else begin
            if(GEN_EN_DLY2 == 1'b1)
             dp_inc <= dp_inc;   
            else
             dp_inc <= 16'd0;
        end
        
        //sp
        if(cur_state == SOP && SIP_MODE==2'b01)begin
            sp_inc <= sp_inc+16'd1;
        end
        else begin
             if(GEN_EN_DLY2 == 1'b1)
             sp_inc <= sp_inc;   
            else
             sp_inc <= 16'd0;
        end
        
    end
end 

//???//
always@( posedge Clk )begin
  len_rsv <= VAL_LEN     ;             
  dip_rsv <= DIP         ;             
  sip_rsv <= local_ip    ;             
  dmac_rsv<= DMAC        ;             
  smac_rsv<= local_mac   ;   
  dp_rsv  <= DP          ;             
  sp_rsv  <= SP          ;    
end
 /*****************************************************************/ 
 
/*******************************************************************\
*                                                                   *
*                     Instance CRC Add Module                       *
*                                                                   *
\*******************************************************************/
wire                    PreTxdv;
wire    [63:0]          PreTxd;
wire                    PreTxSof;
wire                    PreTxEof;
wire    [2:0]           PreTxMod;

crc_add_pp  U_crc_add_pp  (
                .Reset                      (Reset              ),
                .Clk                        (Clk                ),

                .CrcTxdv                    (CrcTxdv            ),
                .CrcTxd                     (CrcTxd             ),
                .CrcTxSof                   (CrcTxSof           ),
                .CrcTxEof                   (CrcTxEof           ),
                .CrcTxMod                   (CrcTxMod           ),

                .PreTxdv                    (PreTxdv            ),
                .PreTxd                     (PreTxd             ),
                .PreTxSof                   (PreTxSof           ),
                .PreTxEof                   (PreTxEof           ),
                .PreTxMod                   (PreTxMod           )
                  );

/*******************************************************************\
*                                                                   *
*                     Instance Preamble Add Module                  *
*                                                                   *
\*******************************************************************/
wire                    Txdv;
wire    [63:0]          Txd;
wire                    TxSof;
wire                    TxEof;
wire    [2:0]           TxMod;  

//assign PreTxdv  = CrcTxdv  ;
//assign PreTxd   = CrcTxd   ;
//assign PreTxSof = CrcTxSof ;
//assign PreTxEof = CrcTxEof ;
//assign PreTxMod = CrcTxMod ;

pre_add_pp  U_pre_add_pp  (
                .Reset                      (Reset              ),
                .Clk                        (Clk                ),

                .PreTxdv                    (PreTxdv            ),
                .PreTxd                     (PreTxd             ),
                .PreTxSof                   (PreTxSof           ),
                .PreTxEof                   (PreTxEof           ),
                .PreTxMod                   (PreTxMod           ),

                .Txdv                       (Txdv               ),
                .Txd                        (Txd                ),
                .TxSof                      (TxSof              ),
                .TxEof                      (TxEof              ),
                .TxMod                      (TxMod              )
                  );

/*******************************************************************\
*                                                                   *
*                Instance Xgmii Interface Module                    *
*                                                                   *
\*******************************************************************/
xgmii_tx_ifc_pp  U_xgmii_tx_ifc_pp (
                .Reset                      (Reset              ),
                .Clk                        (Clk                ),

                .xgmii_txd                  (xgmii_txd          ),
                .xgmii_txc                  (xgmii_txc          ),

                .Txdv                       (Txdv               ),
                .Txd                        (Txd                ),
                .TxSof                      (TxSof              ),
                .TxEof                      (TxEof              ),
                .TxMod                      (TxMod              )
                  );

/*****************************************************************/




/*****************************************************************/

/*******************************************************************\
*                                                                   *
*                Instance prbs Module                    *
*                                                                   *
\*******************************************************************/

/*****************************************************************/
assign stat_inc[0] = PreTxdv && PreTxSof ;
assign stat_inc[1] = PreTxdv && PreTxEof ;
assign stat_inc[2] = PreTxdv  ;
assign stat_inc[3] = 1'b0 ;

assign stat_inc_d = PreTxEof ? {(PreTxMod == 3'b0),PreTxMod} : 4'h8 ;

endmodule