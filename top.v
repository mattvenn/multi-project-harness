`default_nettype none
`define MPRJ_IO_PADS 36 // TODO
module multi_project_harness #(
    parameter address_active = 32'h00FF00FF,  // TODO
    parameter address_ws2812 = 32'h00FF00FA,  // TODO
    parameter num_projects   = 4
) (
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,             // clock
    input wb_rst_i,             // reset
    input wbs_stb_i,            // strobe - valid data
    input wbs_cyc_i,            // cycle - high when during a request
    input wbs_we_i,             // write enable
    input [3:0] wbs_sel_i,      // which byte to read/write
    input [31:0] wbs_dat_i,     // data in
    input [31:0] wbs_adr_i,     // address
    output wbs_ack_o,           // ack
    output [31:0] wbs_dat_o,    // data out

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oen,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb
    );

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile ("harness.vcd");
            $dumpvars (0, multi_project_harness);
            #1;
        end
    `endif

    // make all the possible connecting wires
    wire [`MPRJ_IO_PADS-1:0] project_io_in  [num_projects-1:0];
    wire [`MPRJ_IO_PADS-1:0] project_io_out [num_projects-1:0];

    // mux project outputs
    assign io_out = active_project == 0 ? project_io_out[0] :
                    active_project == 1 ? project_io_out[1] :
                    active_project == 2 ? project_io_out[2] :
                    active_project == 3 ? project_io_out[3] :
                                          `MPRJ_IO_PADS'b0;

    // each project sets own oeb
    assign io_oeb = active_project == 0 ? project_io_out[0] :
                    active_project == 1 ? project_io_out[1] :
                    active_project == 2 ? project_io_out[2] :
                    active_project == 3 ? project_io_out[3] :
                                          `MPRJ_IO_PADS'b0;

    // inputs get set to z if not selected
    assign project_io_in[0] = active_project == 0 ? io_in : `MPRJ_IO_PADS'bz;
    assign project_io_in[1] = active_project == 1 ? io_in : `MPRJ_IO_PADS'bz;
    assign project_io_in[2] = active_project == 2 ? io_in : `MPRJ_IO_PADS'bz;
    assign project_io_in[3] = active_project == 3 ? io_in : `MPRJ_IO_PADS'bz;


    // instantiate all the modules
    // none of then care about output enable so leave that to the cpu
    seven_segment_seconds proj_0 (.clk(project_io_in[0][0]), .reset(project_io_in[0][1]), .led_out(project_io_out[0][8:2]));
    // ws2812 needs led_num, rgb, write connected to wb
    ws2812                proj_1 (.clk(project_io_in[1][0]), .reset(project_io_in[1][1]), .led_num(wbs_dat_i[31:24]), .rgb_data(wbs_dat_i[23:0]), .write(ws2812_write), .data(project_io_out[1][32]));
    vga_clock             proj_2 (.clk(project_io_in[2][0]), .reset_n(!project_io_in[2][1]), .adj_hrs(project_io_in[2][2]), .adj_min(project_io_in[2][3]), .adj_sec(project_io_in[2][4]), .hsync(project_io_out[2][5]), .vsync(project_io_out[2][6]), .rrggbb(project_io_out[2][12:7]));
	wire [13:0] p3in, p3out;
	assign p3in = project_io_in[3][13:0];
	assign project_io_out[3][13:0] = p3out;
	spinet #(.N(2), .WIDTH(16), .ABITS(3)) proj_3 (
		.clk(p3in[0]),
		.rst(p3in[1]),
		.MOSI(p3in[3:2]),
		.SCK(p3in[5:4]),
		.SS(p3in[7:6]),
		.MISO(p3out[9:8]),
		.txready(p3out[11:10]),
		.rxready(p3out[13:12]));
    
    reg [7:0] active_project = 0; // which design is active

    // wishbone signals
    wire valid;
    wire [3:0] wstrb;
    reg [31:0] wbs_data_out;
    reg wbs_ack;
    assign wbs_ack_o = wbs_ack;
    assign wbs_dat_o = wbs_data_out;
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};

    // extra ws2812 setup
    wire ws2812_write = valid & wstrb & (wbs_adr_i == address_ws2812);

    always @(posedge wb_clk_i) begin
        // reset
        wbs_ack <= 0;

        if(wb_rst_i) begin
            active_project <= 0;
            wbs_data_out <= 0;
            wbs_ack <= 0;
        end
        // writes
        if(valid & wstrb) begin
            case(wbs_adr_i)
                address_active: begin
                    if (wstrb[0]) active_project[7:0]   <= wbs_dat_i[7:0];
                    wbs_ack <= 1;
                end
                address_ws2812: begin
                    wbs_ack <= 1;
                end

            endcase 
        end else
        // reads - allow to see which is currently selected
        if(valid & wstrb == 4'b0) begin
            case(wbs_adr_i)
                address_active: begin
                    wbs_data_out[7:0]   <= active_project[7:0];
                    wbs_ack <= 1;
                end

            endcase 
        end
    end


endmodule
