`timescale 1ns / 1ps

module dsp_replay_div(
  input  wire                  rst         ,                                                     
  input  wire                  clk,
  input  wire[63:0]  tx_data,
  input  wire tx_enable,
  input  wire active_i,
  output reg fifo_data_wr_en_o,
  output reg[63:0] fifo_data_din_o,
  output reg[15:0] wlen_tx_o,
  output reg[15:0] cnt
    );
 // states of FSM writing data
  parameter FSM_DATA_RST    = 3'b000,
            FSM_DATA_IDLE   = 3'b001,
            FSM_DATA      = 3'b010,
            FSM_DATA_WAIT    = 3'b100;

  reg [2:0]   state_fsm_data, nxt_state_fsm_data;
  reg [15:0]  nxt_wlen_tx;
  reg         nxt_fifo_data_wr_en;
  reg [63:0]  nxt_fifo_data_din;
  wire fifo_data_full_i;
 
 
always @(posedge clk) begin
if(tx_enable)
begin
if(tx_data[63:16] == 48'hfb5555555555)
  begin
  cnt <= 1'b1;
  end
  else
  cnt <= cnt + 1'b1;
  end
  end
     
wire tx_data_sop;
assign tx_data_sop = (tx_enable && (tx_data[63:16]==48'hfb5555555555)) ? 1 : 0;  
  
reg tx_data_eop;   
always @(posedge clk) begin
if(tx_enable)
begin
if((((wlen_tx_o + 4) -(cnt <<< 3)) > 0) && (((wlen_tx_o + 4) -(cnt <<< 3))<= 8))
  begin
  tx_data_eop <= 1'b1;
  end
  else
  tx_data_eop <= 1'b0;
  end
  end
  
reg tx_data_wenb_temp;   
reg tx_data_wenb;   
always @(posedge clk) begin
if(tx_enable)
begin
if(tx_enable && (tx_data[63:16]==48'hfb5555555555))
begin
tx_data_wenb <= 1'b1;
wlen_tx_o <= tx_data[15:0];
end
else if(tx_data_eop)
tx_data_wenb <= 1'b0;
else
tx_data_wenb <= tx_data_wenb;
end
end
//assign tx_data_wenb =tx_data_sop | tx_data_wenb_temp;
 
   
  // FSM writing packet data to FIFO
  always @(posedge clk) begin
    if (rst) begin
      state_fsm_data <= FSM_DATA_RST;
    end else begin
      state_fsm_data <= nxt_state_fsm_data;
    end

 //   wlen_tx_o <= nxt_wlen_tx;
    fifo_data_wr_en_o <= nxt_fifo_data_wr_en;
    fifo_data_din_o <=nxt_fifo_data_din;

  end

  // FSM writing packet data to FIFO
  always @(*) begin
    nxt_state_fsm_data = state_fsm_data;
    nxt_fifo_data_wr_en = 1'b0;

    case (state_fsm_data)

      FSM_DATA_RST: begin
        // reset packet counter
        nxt_state_fsm_data = FSM_DATA_IDLE;
      end

      FSM_DATA_IDLE: begin
        if (active_i) begin
          // module has been activated
          nxt_state_fsm_data = FSM_DATA;
        end
      end

      FSM_DATA: begin
        if (~active_i & ~tx_enable) begin
          nxt_state_fsm_data = FSM_DATA_IDLE;      
        end 
        else begin
          if (tx_data_wenb)begin
              nxt_fifo_data_wr_en = 1'b1;
              nxt_fifo_data_din[63:0] = tx_data[63:0];
          //    nxt_wlen_tx = tx_data[15:0];
              if (fifo_data_full_i) begin
                // FIFO is full -> go to error state_fsm_data
                nxt_state_fsm_data = FSM_DATA_WAIT;
              end
            end
          end
        end
     
      FSM_DATA_WAIT: begin
        if(~fifo_data_full_i)
        nxt_state_fsm_data = FSM_DATA;
        
      end

    endcase
  end
  
    
endmodule
