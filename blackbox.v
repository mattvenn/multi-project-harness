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
module spinet6 (
	input clk,
	input rst,
	output [6:0] txready,
	output [6:0] rxready,
	input [6:0] MOSI, SCK, SS,
	output [6:0] MISO);
endmodule
