
`timescale 1 ns / 1ps

module dsp_rx
(
  // clock and resets
  input wire          clk,
  input wire          rst,

  input wire[63:0]           ch0_wdat_loop,
  input wire                 ch0_wenb_loop,
  input wire                 ch0_wsop_loop,
  input wire                 ch0_weop_loop,
  input wire [15:0]          ch0_wlen_tx,
  
  input wire [63:0]        clkwdat,
  input wire [63:0]         BASE_TIME,
  // activation signals
  input wire          active_i,

  // fifo signals for meta-data fifo
  output reg [79:0]   fifo_meta_din_o,
  output reg          fifo_meta_wr_en_o,
  input wire          fifo_meta_full_i,

  // fifo signals for data fifo
  output reg [63:0]   fifo_data_din_o,
  output reg          fifo_data_wr_en_o,
  input wire          fifo_data_full_i,

  // packet counter output
  output reg [31:0]   pkt_cnt_o
);
  // states of FSM writing data
  parameter FSM_DATA_RST    = 3'b000,
            FSM_DATA_IDLE   = 3'b001,
            FSM_DATA      = 3'b010,
            FSM_DATA_ERR    = 3'b100;

  reg [2:0]   state_fsm_data, nxt_state_fsm_data;
  reg         meta_wr, nxt_meta_wr;
  reg [63:0]  meta_timestamp, nxt_meta_timestamp, ts_temp;
  reg [15:0]  meta_len, nxt_meta_len;
  reg         nxt_fifo_data_wr_en;
  reg [31:0]  nxt_pkt_cnt;

   reg                 nxt_fifo_data_wr_en_dly;
   
   
  // FSM writing packet data to FIFO
  always @(posedge clk) begin
    if (rst) begin
      state_fsm_data <= FSM_DATA_RST;
    end else begin
      state_fsm_data <= nxt_state_fsm_data;
    end

    meta_wr <= nxt_meta_wr;
    meta_timestamp <= nxt_meta_timestamp;
    meta_len <= nxt_meta_len;
    fifo_data_wr_en_o <= nxt_fifo_data_wr_en;//0402dsp
    fifo_data_din_o <= ch0_wdat_loop;
    pkt_cnt_o <= nxt_pkt_cnt;
  end
  /* 
  always @(posedge clk) begin
    nxt_fifo_data_wr_en_dly <= nxt_fifo_data_wr_en;
    end
*/
  // FSM writing packet data to FIFO
  always @(*) begin
    nxt_state_fsm_data = state_fsm_data;
    nxt_meta_wr = 1'b0;
    nxt_meta_timestamp = meta_timestamp;
    nxt_meta_len = meta_len;
    nxt_fifo_data_wr_en = 1'b0;
    nxt_pkt_cnt = pkt_cnt_o;
    ts_temp = 0;

    case (state_fsm_data)

      FSM_DATA_RST: begin
        // reset packet counter
        nxt_pkt_cnt = 32'b0;
        nxt_state_fsm_data = FSM_DATA_IDLE;
      end

      FSM_DATA_IDLE: begin
        if (active_i) begin
          // module has been activated
          nxt_state_fsm_data = FSM_DATA;
        end
      end

      FSM_DATA: begin
        if (~active_i & ~ch0_wenb_loop) begin
          nxt_state_fsm_data = FSM_DATA_IDLE;
          
        end else begin
          if (ch0_wenb_loop) begin // & ch0_wsop_loop)
              nxt_fifo_data_wr_en = 1'b1;
              
              if (fifo_data_full_i) begin
                // FIFO is full -> go to error state_fsm_data
                nxt_state_fsm_data = FSM_DATA_ERR;
              end
            end

            if (ch0_weop_loop) begin
              // this is the last word -> trigger writing of meta data
              nxt_meta_wr = 1'b1;
              // set meta data
              ts_temp = clkwdat * 819;
              nxt_meta_timestamp[63:0] = (ts_temp>>7) + BASE_TIME;
              // set meta data
              nxt_meta_len[15:0] = ch0_wlen_tx;
              // increment packet counter
              nxt_pkt_cnt = pkt_cnt_o + 1;
            end 
            else begin
             nxt_meta_wr = 1'b0;
             nxt_meta_timestamp = nxt_meta_timestamp;
             nxt_meta_len = nxt_meta_len;
            end
          end
        end

      FSM_DATA_ERR: begin
        // stuck here until reset
      end

    endcase
  end
   


  // states of FSM writing meta info
  parameter FSM_META_ACTIVE = 1'b0,
            FSM_META_ERR    = 1'b1;

  reg         state_fsm_meta, nxt_state_fsm_meta;
  reg         nxt_fifo_meta_wr_en;
  reg [79:0]  nxt_fifo_meta_din;

  // FSM writing meta data to FIFO
  always @(posedge clk) begin
    if (rst) begin
      state_fsm_meta <= FSM_META_ACTIVE;
    end else begin
      state_fsm_meta <= nxt_state_fsm_meta;
    end

    fifo_meta_wr_en_o <= nxt_fifo_meta_wr_en;
    fifo_meta_din_o <= nxt_fifo_meta_din;
  end

  // FSM writing meta data to FIFO
  always @(*) begin
    nxt_state_fsm_meta = state_fsm_meta;
    nxt_fifo_meta_wr_en = 1'b0;
    nxt_fifo_meta_din = fifo_meta_din_o;

    case (state_fsm_meta)

      FSM_META_ACTIVE: begin
        if (meta_wr) begin
          // assmeble meta data and write to FIFO
          nxt_fifo_meta_wr_en = 1'b1;
          nxt_fifo_meta_din[63:0] = meta_timestamp;
          nxt_fifo_meta_din[79:64] = meta_len;

          if (fifo_meta_full_i) begin
            // fifo is full -> go to error state
            nxt_state_fsm_meta = FSM_META_ERR;
          end
        end
      end

      FSM_META_ERR: begin
        // stuck here until reset
      end

    endcase
  end

endmodule
