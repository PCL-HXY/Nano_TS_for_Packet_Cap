
`timescale 1 ns / 1ps

module fifo_wrapper
(
  // clock and resets
  input wire          clk,
//input wire          rstn,
  input wire          rst,  //dsp   high-reset
  
//input wire          rst_sw,  //dsp 

  // FIFO input
  input wire [63:0]   din_i,
  input wire          wr_en_i,
  output wire         full_o,

  // FIFO output
  output wire [511:0] dout_o,
  input wire          rd_en_i,
  output wire         empty_o,
  output wire         prog_empty_o,
  output wire [10:0]  rd_data_count_o,

  // start & status signals
  input wire align_i,  //triger signal; 50ms  no  input  data
  output wire align_done_o,
  input wire group0_test_en
);

  // FSM states
  localparam  RST           = 2'b00,
              PASS_THROUGH  = 2'b01,
              ALIGN         = 2'b10;

  reg [1:0] state, nxt_state;

  // number of 64 bit words that have been written to the FIFO (modulo 8)
  reg [2:0] fifo_wr_word_cntr, nxt_fifo_wr_word_cntr;

  // output status
  reg align_done, nxt_align_done;
  assign align_done_o = align_done;

  // FIFO input data
  wire [63:0] fifo_din;


  // if in PASS_THROUGH state, write input data to the FIFO. Otherwise write
  // padding data, where all bits are set to 1.
  assign fifo_din = state == PASS_THROUGH ? din_i : 64'hFFFFFFFFFFFFFFFF;

  // FIFO write enable signal. If in PASS_THROUGH state, write input data to the
  // FIFO whenever it becomes available. If in ALIGN state, only write padding
  // data to the FIFO if 512 bit alignment has not been reached yet
  wire fifo_wr_en;
  wire wr_en;
  assign fifo_wr_en = state == PASS_THROUGH ? wr_en_i :
    (state == ALIGN) & (fifo_wr_word_cntr != 0);
  assign wr_en = fifo_wr_en & group0_test_en;
  // FSM
  always @(posedge clk) begin
  //  if (~rstn | rst_sw) 
      if (rst ) //dsp 06/28
    begin
      state <= RST;
    end else begin
      state <= nxt_state;
    end

    fifo_wr_word_cntr <= nxt_fifo_wr_word_cntr;
    align_done <= nxt_align_done;
  end

  // FSM
  always @(*) begin

    nxt_state = state;
    nxt_fifo_wr_word_cntr = fifo_wr_word_cntr;
    nxt_align_done = 1'b0;

    case (state)

      RST: begin
        // initially we go to the PASS_THROUGH state. no data has been written
        // yet.
        nxt_state = PASS_THROUGH;
        nxt_fifo_wr_word_cntr = 3'b0;
      end

      PASS_THROUGH: begin
        // in this state input data is written to the FIFO.
        if (align_i) begin
          // alignment triggered
          nxt_state = ALIGN;
        end

        if (wr_en_i) begin
          // data is being written. increment the FIFO write word counter.
          // Wrap around if 8x 64 bit words have been written
          nxt_fifo_wr_word_cntr
            = (fifo_wr_word_cntr == 7) ? 3'b0 : fifo_wr_word_cntr + 3'b1;
        end
      end

      ALIGN: begin
        // in this state padding data is written to the FIFO if necessary
        if (fifo_wr_word_cntr == 0) begin
          // 512 bit alignment has been reached -> we are done
          nxt_state = PASS_THROUGH;
          nxt_align_done = 1'b1;
        end else begin
          //increment the FIFO write word counter. Wrap around if 8x 64 bit
          // words have been written
          nxt_fifo_wr_word_cntr
            = (fifo_wr_word_cntr == 7) ? 3'b0 : fifo_wr_word_cntr + 3'b1;
        end
      end

    endcase
  end

  // FIFO instance
    dsp_rx_merge_fifo dsp_rx_merge_fifo_inst (
    .clk(clk),
    .srst(rst),
    .din(fifo_din),
    .wr_en(wr_en),
    .rd_en(rd_en_i),
    .dout(dout_o),
    .full(full_o),
    .empty(empty_o),
    .rd_data_count(rd_data_count_o),
    .prog_empty(prog_empty_o)
  );

endmodule
