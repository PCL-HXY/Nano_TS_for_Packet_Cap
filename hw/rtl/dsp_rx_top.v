`timescale 1 ns / 1ps

module dsp_rx_top (
  // clock and reset
  input wire           clk156,
  input wire           clk250m,
  input wire           rst,

  input wire[63:0]           ch0_wdat_loop,
  input wire                 ch0_wenb_loop,
  input wire                 ch0_wsop_loop,
  input wire                 ch0_weop_loop,
  input wire [15:0]          ch0_wlen_tx,
  
  input wire [63:0]         clkwdat,
  input wire [63:0]         BASE_TIME,
  
  input wire  active_i,
  
  input wire group0_test_en,
  
  output wire[511:0]          fifo_dout,
  output wire fifo_wr_en,
  input  wire fifo_rd_en,
  output wire fifo_empty,
  output wire fifo_prog_empty,
  output wire [10:0] fifo_rd_data_count,
  output wire flush_i,
  input wire flush_done,
  output wire align_done
);

  wire [79:0] fifo_meta_din, fifo_meta_dout;
  wire [63:0] fifo_data_din, fifo_data_dout;
  wire        fifo_meta_wr_en, fifo_meta_rd_en, fifo_meta_full,
                fifo_meta_empty;
  wire        fifo_data_wr_en, fifo_data_rd_en, fifo_data_full,
                fifo_data_empty;

  wire [63:0]   fifo_din;
 // wire [511:0]  fifo_dout;
//  wire [10:0]   fifo_rd_data_count;
  wire          fifo_full;

  wire [31:0]  pkt_cnt_o;
  dsp_rx dsp_rx_inst (
    .clk(clk156),
    .rst(rst),
    .ch0_wdat_loop(ch0_wdat_loop),
    .ch0_wenb_loop(ch0_wenb_loop),
    .ch0_wsop_loop(ch0_wsop_loop),
    .ch0_weop_loop(ch0_weop_loop),
    .ch0_wlen_tx(ch0_wlen_tx),
    
    .clkwdat(clkwdat),
    .BASE_TIME(BASE_TIME),
    
    .active_i(active_i),
    .fifo_meta_din_o(fifo_meta_din),
    .fifo_meta_wr_en_o(fifo_meta_wr_en),
    .fifo_meta_full_i(fifo_meta_full),
    .fifo_data_din_o(fifo_data_din),
    .fifo_data_wr_en_o(fifo_data_wr_en),
    .fifo_data_full_i(fifo_data_full),
    .pkt_cnt_o(pkt_cnt_o)
  );

  dsp_rx_fifo_merge dsp_rx_fifo_merge_inst (
    .clk(clk250m),
    .rst(rst),
    .fifo_meta_dout_i(fifo_meta_dout),
    .fifo_meta_empty_i(fifo_meta_empty),
    .fifo_meta_rd_en_o(fifo_meta_rd_en),
    .fifo_data_dout_i(fifo_data_dout),
    .fifo_data_empty_i(fifo_data_empty),
    .fifo_data_rd_en_o(fifo_data_rd_en),
    .fifo_din_o(fifo_din),
    .fifo_wr_en_o(fifo_wr_en),
    .fifo_full_i(fifo_full)
  );
  

  dsp_rx_meta_fifo dsp_rx_meta_fifo_inst (
    .wr_clk(clk156),
    .rd_clk(clk250m),
    .rst(rst),
    .din(fifo_meta_din),
    .wr_en(fifo_meta_wr_en),
    .rd_en(fifo_meta_rd_en),
    .dout(fifo_meta_dout),
    .full(fifo_meta_full),
    .empty(fifo_meta_empty)
  );

  dsp_rx_data_fifo dsp_rx_data_fifo_inst (
    .wr_clk(clk156),
    .rd_clk(clk250m),
    .rst(rst),
    .din(fifo_data_din),
    .wr_en(fifo_data_wr_en),
    .rd_en(fifo_data_rd_en),
    .dout(fifo_data_dout),
    .full(fifo_data_full),
    .empty(fifo_data_empty)
  );

  
  Fifo_align u_fifo_align(
              .clk(clk250m),
              .rst(rst),
              .opkwenb(fifo_wr_en),
              .flush_i(flush_i),
              .flush_done(flush_done)
              );
              
  fifo_wrapper u_fifo_wrapper(
              .clk(clk250m),
              .rst(rst),
              .din_i(fifo_din),
              .wr_en_i(fifo_wr_en),
              .full_o(fifo_full),
              .dout_o(fifo_dout),
              .rd_en_i(fifo_rd_en),
              .empty_o(fifo_empty),
              .prog_empty_o(fifo_prog_empty),
              .rd_data_count_o(fifo_rd_data_count),
              .align_i(flush_i),
              .align_done_o(align_done),
              .group0_test_en(group0_test_en)
              );

endmodule
