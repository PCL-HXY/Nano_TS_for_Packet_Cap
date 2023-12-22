`timescale 1ns / 1ps
module dsp_tx_top(
  input  wire                  rst         ,                                                     
  input  wire                  clk156      ,
  input  wire                  clk250,
  input  wire[511:0]  tx_data,
  input  wire tx_enable,
  output wire[63:0]  xgmii_txd,
  output wire[7:0]   xgmii_txc  

    );
  wire wr_en_r;
  reg rd_en_r;
  wire full_r,empty_r,prog_empty_r,prog_full_r;
  wire [63:0] dout_r;
  wire [15:0] cnt;
  wire [15:0] len;
  wire [15:0] wlen_tx;
  
  assign len = wlen_tx +{(wlen_tx[2:0] != 3'b100),3'b000} + 'h4;//dsp crc add
        
  reg [2:0] FIFO_state;
  reg [3:0] wait_cnt;
  reg [15:0] idle_cnt;
    
  parameter START = 3'b001,
            WAIT = 3'b010,
            DLY  = 3'b011;
            
  always@( posedge clk156 or posedge rst  )           
  begin
    if(rst)
    begin 
      FIFO_state <= START;
      rd_en_r <= 1'b0;
    end
    else
    begin
      case(FIFO_state)
      START:
        if(~empty_r)
        begin
          FIFO_state <= WAIT;
          rd_en_r <= 1'b1;
        end
      WAIT:
        if((cnt == len>>3)&&(cnt != 0))
        begin 
          FIFO_state <= DLY;
          rd_en_r <= 1'b0;
        end
      DLY:
        begin
        if(idle_cnt == 16'h1)
          FIFO_state <= START;
        else
          FIFO_state <= DLY;
        end
      endcase
    end
  end 
          
  always@( posedge clk156 or posedge rst  )
  begin
  if ( rst == 1'b1 )
      idle_cnt <= 16'b0 ;
  else if ( FIFO_state == DLY ) 
      idle_cnt <= idle_cnt + 1'b1 ;
  else
      idle_cnt <= 16'b0 ;
  end

  fifo_generator_tx  fifo_generator_tx
  (
      .rst(rst),
      .full(full_r),
      .din(tx_data),
      .wr_en(tx_enable),
      .empty(empty_r),
      .dout(dout_r),
      .rd_en(rd_en_r),
      .wr_clk(clk250),
      .rd_clk(clk156),
      .prog_full(prog_full_r)                   
  );      
    
  wire [63:0] fifo_data_din;
  wire fifo_data_wr_en;
  wire fifo_data_rd_en;
  wire fifo_data_full,fifo_data_empty;
  wire [63:0] fifo_data_dout;
    
  dsp_replay_div dsp_replay_div_inst(
    .clk(clk156),
    .rst(rst),
    .tx_data(dout_r),
    .tx_enable(rd_en_r),
    
    .active_i(1'b1),
    .fifo_data_wr_en_o(fifo_data_wr_en),
    .fifo_data_din_o(fifo_data_din),
    .wlen_tx_o(wlen_tx),
    .cnt(cnt)
  );                      
  
  
  xgmii_tx_pp_mac test_tx(
    .Reset           (rst          ),
    .Clk             (clk156      ),

    .data_in (fifo_data_din)          ,
    .tx_len  (wlen_tx)                ,
    .data_valid  (fifo_data_wr_en)    ,

    .xgmii_txd       (xgmii_txd          ),
    .xgmii_txc       (xgmii_txc          )
  ); 
                        
endmodule
