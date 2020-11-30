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
