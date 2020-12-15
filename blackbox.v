(* blackbox *)
module seven_segment_seconds (
	input wire clk,
    input wire reset,
    input wire [23:0] compare_in,
    input wire update_compare,
	output wire [6:0] led_out);
endmodule

(* blackbox *)
module ws2812                (
    input wire [23:0] rgb_data,
    input wire [7:0] led_num,
    input wire write,
    input wire reset,
    input wire clk,  //12MHz

    output reg data);
endmodule

(* blackbox *)
module vga_clock            (
    input wire clk, 
    input wire reset_n,
    input wire adj_hrs,
    input wire adj_min,
    input wire adj_sec,
    output wire hsync,
    output wire vsync,
    output wire [5:0] rrggbb);
endmodule

(* blackbox *)
module asic_freq(
    input wire clk,
    input wire rst,
    input wire [3:0] addr,
    input [31:0] value,
    input strobe,
    input samplee,
    output [31:0] o,
    output [31:0] oc,
    output tx,
    output [8:0] col_drvs,
    output [7:0] seg_drvs);
endmodule


(* blackbox *)
module spinet5 (
	input clk,
	input rst,
	input [37:0] io_in,
	output [37:0] io_out);
endmodule

(* blackbox *)
module watch_hhmm (
    //input wire clk_system_i, //  10 MHz
    input wire sysclk_i, // 32.768 KHz shared with SoC
    input wire smode_i, // safe mode
    input wire sclk_i,// safe clock GPIO 32.768 KHz
    input wire rstn_i, // active low
    input wire dvalid_i, // Data from wishbone is valid
    input wire [11:0] cfg_i, // initial values for counters
    output wire [6:0] segment_hxxx,
    output wire [6:0] segment_xhxx,
    output wire [6:0] segment_xxmx,
    output wire [6:0] segment_xxxm
);
endmodule

(* blackbox *)
module challenge(
    input uart,
    input clk_10,
    output led_green,
    output led_red
);
endmodule

(* blackbox *)
module MM2hdmi(
  input         clock,
  input         reset,
  input  [15:0] io_data,
  input         io_newData,
  output [7:0]  io_red,
  output        io_vSync,
  output        io_hSync
);
endmodule

(* blackbox *)
module multi_project_harness #(
    // address_active: write to this memory address to select the project
    parameter address_active = 32'h30000000,
    parameter address_oeb0   = 32'h30000004,
    parameter address_oeb1   = 32'h30000008,
    // each project gets 0x100 bytes memory space
    parameter address_ws2812 = 32'h30000100,
    parameter address_7seg   = 32'h30000200,
    // h30000300 reserved for proj_3: spinet
    parameter address_freq   = 32'h30000400,
    parameter address_watch   = 32'h30000500,
    parameter num_projects   = 8 )
    (
    // Wishbone Slave ports (WB MI A)
    input wire wb_clk_i,             // clock
    input wire wb_rst_i,             // reset
    input wire wbs_stb_i,            // strobe - wb_valid data
    input wire wbs_cyc_i,            // cycle - high when during a request
    input wire wbs_we_i,             // write enable
    input wire [3:0] wbs_sel_i,      // which byte to read/write
    input wire [31:0] wbs_dat_i,     // data in
    input wire [31:0] wbs_adr_i,     // address
    output wire wbs_ack_o,           // ack
    output wire [31:0] wbs_dat_o,    // data out

    // Logic Analyzer Signals
    input  wire [127:0] la_data_in,
    output wire [127:0] la_data_out,
    input  wire [127:0] la_oen,

    // IOs - avoid using 0-7 as they are dual purpose and maybe connected to other things
    input  wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb, // active low!

    // then we need all the separate projects ios here
    // proj 0
    output wire proj0_wb_update,
    output wire proj0_clk,
    output wire proj0_reset,
    output wire  [`MPRJ_IO_PADS-1:0] proj0_io_in,
    input wire [`MPRJ_IO_PADS-1:0] proj0_io_out,

    // proj 1
    output wire proj1_wb_update,
    output wire proj1_clk,
    output wire proj1_reset,
    output wire  [`MPRJ_IO_PADS-1:0] proj1_io_in,
    input wire [`MPRJ_IO_PADS-1:0] proj1_io_out,

    // proj 2
    output wire proj2_clk,
    output wire proj2_reset,
    output wire  [`MPRJ_IO_PADS-1:0] proj2_io_in,
    input wire [`MPRJ_IO_PADS-1:0] proj2_io_out,

    // proj 3
    output wire proj3_clk,
    output wire proj3_reset,
    output wire  [`MPRJ_IO_PADS-1:0] proj3_io_in,
    input wire [`MPRJ_IO_PADS-1:0] proj3_io_out,

    // proj 4
    output wire proj4_clk,
    output wire proj4_reset,
    input wire [31:0] proj4_cnt,
    input wire [31:0] proj4_cnt_cont,
    output wire proj4_wb_update,
    output wire  [`MPRJ_IO_PADS-1:0] proj4_io_in,
    input wire [`MPRJ_IO_PADS-1:0] proj4_io_out,

    // proj 5
    output wire proj5_wb_update,
    output wire proj5_clk,
    output wire proj5_reset,
    output wire  [`MPRJ_IO_PADS-1:0] proj5_io_in,
    input wire [`MPRJ_IO_PADS-1:0] proj5_io_out,

    // proj 6
    output wire proj6_clk,
    output wire  [`MPRJ_IO_PADS-1:0] proj6_io_in,
    input wire [`MPRJ_IO_PADS-1:0] proj6_io_out,
    
    // proj 7
    output wire proj7_reset,
    output wire  [`MPRJ_IO_PADS-1:0] proj7_io_in,
    input wire [`MPRJ_IO_PADS-1:0] proj7_io_out

    );
    endmodule
