`timescale 1 ns / 1ps

module dsp_rx_fifo_merge
(
  // clock and resets
  input wire          clk,
  input wire          rst,

  // meta data input fifo
  input wire [79:0]   fifo_meta_dout_i,
  input wire          fifo_meta_empty_i,
  output wire         fifo_meta_rd_en_o,

  // data input fifo
  input wire [63:0]   fifo_data_dout_i,
  input wire          fifo_data_empty_i,
  output wire         fifo_data_rd_en_o,

  // output fifo
  output wire [63:0]  fifo_din_o,
  output wire         fifo_wr_en_o,
  input wire          fifo_full_i
);

  // extract packet capture length from meta data
  wire [15:0] meta_len_capture;
  assign meta_len_capture = fifo_meta_dout_i[79:64];

  // number of 64 bit words we need to read from data fifo
  reg [12:0] data_word_cnt_sig;
  //reg [63:0] fifo_din_temp;
  // process calculates the number of data words that need to be read from the
  // data input fifo for the current packet
  always @(*) begin
    if ((meta_len_capture & 11'h7) == 0) begin
      // meta_len_capture is a multiple of 8
      data_word_cnt_sig = meta_len_capture >> 3;
    end else begin
      // meta_len_capture is not a multiple of 8 bytes -> round up
      data_word_cnt_sig = (meta_len_capture >> 3) + 11'b1;
    end
  end

  // FSM states
  parameter META = 2'b00,
                  DATA = 2'b01,
                  WAIT = 2'b10;

  reg [1:0]       state, nxt_state;
  reg [12:0]     data_word_cnt, nxt_data_word_cnt;
  reg [12:0]     data_word_cntr, nxt_data_word_cntr;

  // FSM
  always @(posedge clk) begin
    if (rst) begin
      state <= META;
    end else begin
      state <= nxt_state;
    end

    data_word_cnt <= nxt_data_word_cnt;
    data_word_cntr <= nxt_data_word_cntr;
  end

  // FSM
  always @(*) begin
    nxt_state = state;
    nxt_data_word_cnt = data_word_cnt;
    nxt_data_word_cntr = data_word_cntr;

    case (state)
      META: begin
        if (~fifo_full_i & ~fifo_meta_empty_i) begin
          // there is data to be read from the meta input FIFO and the output
          // FIFO is not full. Initialize the number of data words that need to
          // be read from the data FIFO
          nxt_data_word_cnt = data_word_cnt_sig ;//dsp len 0402 -1'h1
          nxt_data_word_cntr = 13'b0;

          if (data_word_cnt_sig > 0) begin
            // we are going to read at least one data word from the data fifo
            nxt_state = DATA;
          end
        end
      end

      DATA: begin
        if (~fifo_full_i & ~fifo_data_empty_i) begin
          // the output FIFO is not full and there is data to be read from the
          // data input FIFO

          // increment counter
          nxt_data_word_cntr = data_word_cntr + 1;

          if ((data_word_cntr + 1) == data_word_cnt) begin
            // all data words have been read
            nxt_state = WAIT;
          end
        end
      end

     WAIT:begin
     if(~fifo_data_rd_en_o)
     nxt_state = META;
     end

    endcase
  end

  wire [63:0] fifo_din_temp;
  reg  [63:0] fifo_din_dly;
  reg  fifo_wr_en_dly;
  reg  fifo_wr_en_o_dly;
  wire fifo_wr_en_temp;

  always @(posedge clk) begin
  fifo_din_dly <= fifo_din_temp;
  fifo_wr_en_dly <= fifo_wr_en_temp;
  fifo_wr_en_o_dly <= fifo_wr_en_o;
  end
 
  assign fifo_din_o = (fifo_meta_rd_en_o) ? {8'hfb,{5{8'h55}},(fifo_meta_dout_i[79:64]-4'h4)}:
                      fifo_din_dly;  //dsp len 2byte fb5555555555len
  assign fifo_wr_en_o = fifo_wr_en_temp || fifo_wr_en_dly;
  assign fifo_din_temp = (state == META) ? fifo_meta_dout_i[63:0] :
                        fifo_data_dout_i;
                        
  assign fifo_wr_en_temp = ~fifo_full_i &
                          (((state == META) & ~fifo_meta_empty_i) ||
                           ((state == DATA) & ~fifo_data_empty_i));

  // assign input FIFOs output signals
  assign fifo_meta_rd_en_o
    = ~fifo_full_i & (state == META) & ~fifo_meta_empty_i;
  assign fifo_data_rd_en_o
    = ~fifo_full_i & (state == DATA) & ~fifo_data_empty_i;

endmodule
