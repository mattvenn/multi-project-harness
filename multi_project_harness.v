`default_nettype none
//`include "defines.v"
`define MPRJ_IO_PADS 38
module multi_project_harness #(
    // address_active: write to this memory address to select the project
    parameter address_active = 32'h30000000,
    // each project gets 0x100 bytes memory space
    parameter address_ws2812 = 32'h30000100,
    parameter address_7seg   = 32'h30000200,
    // h30000300 reserved for proj_3: spinet
    parameter address_freq   = 32'h30000400,
    parameter num_projects   = 5
) (
    inout wire vdda1,   // User area 1 3.3V supply
    inout wire vdda2,   // User area 2 3.3V supply
    inout wire vssa1,   // User area 1 analog ground
    inout wire vssa2,   // User area 2 analog ground
    inout wire vccd1,   // User area 1 1.8V supply
    inout wire vccd2,   // User area 2 1.8v supply
    inout wire vssd1,   // User area 1 digital ground
    inout wire vssd2,   // User area 2 digital ground

    // Wishbone Slave ports (WB MI A)
    input wire wb_clk_i,             // clock
    input wire wb_rst_i,             // reset
    input wire wbs_stb_i,            // strobe - valid data
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

    // IOs
    input  wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb
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

    reg [7:0] active_project; // which design is active

    // mux project outputs
    assign io_out = active_project == 0 ? project_io_out[0] :
                    active_project == 1 ? project_io_out[1] :
                    active_project == 2 ? project_io_out[2] :
                    active_project == 3 ? project_io_out[3] :
                    active_project == 4 ? project_io_out[4] :
                                          `MPRJ_IO_PADS'b0;

    // each project sets own oeb
    assign io_oeb = active_project == 0 ? `MPRJ_IO_PADS'b1 : // all on
                    active_project == 1 ? `MPRJ_IO_PADS'b1 :
                    active_project == 2 ? `MPRJ_IO_PADS'b1 :
                    active_project == 3 ? `MPRJ_IO_PADS'b1 :
                    active_project == 4 ? `MPRJ_IO_PADS'b1 :
                                          `MPRJ_IO_PADS'b0;

    // inputs get set to z if not selected
    assign project_io_in[0] = active_project == 0 ? io_in : `MPRJ_IO_PADS'bz;
    assign project_io_in[1] = active_project == 1 ? io_in : `MPRJ_IO_PADS'bz;
    assign project_io_in[2] = active_project == 2 ? io_in : `MPRJ_IO_PADS'bz;
    assign project_io_in[3] = active_project == 3 ? io_in : `MPRJ_IO_PADS'bz;
    assign project_io_in[4] = active_project == 4 ? io_in : `MPRJ_IO_PADS'bz;


    // instantiate all the modules

    // project 0
    `ifndef FORMAL
    seven_segment_seconds proj_0 (.clk(project_io_in[0][0]), .reset(project_io_in[0][1] | la_data_in[0]), .led_out(project_io_out[0][8:2]), .compare_in(wbs_dat_i[23:0]), .update_compare(seven_seg_update));
    `endif

    // project 1
    // ws2812 needs led_num, rgb, write connected to wb
    wire ws2812_write = valid & wstrb & (wbs_adr_i == address_ws2812);
    wire seven_seg_update = valid & wstrb & (wbs_adr_i == address_7seg);
    `ifndef FORMAL
    ws2812                proj_1 (.clk(project_io_in[1][0]), .reset(project_io_in[1][1] | la_data_in[0]), .led_num(wbs_dat_i[31:24]), .rgb_data(wbs_dat_i[23:0]), .write(ws2812_write), .data(project_io_out[1][2]));
    `endif

    // project 2
    `ifndef FORMAL
    vga_clock             proj_2 (.clk(project_io_in[2][0]), .reset_n((!project_io_in[2][1]) | la_data_in[0]), .adj_hrs(project_io_in[2][2]), .adj_min(project_io_in[2][3]), .adj_sec(project_io_in[2][4]), .hsync(project_io_out[2][5]), .vsync(project_io_out[2][6]), .rrggbb(project_io_out[2][12:7]));
    `endif

    // project 3
    wire [13:0] p3in, p3out;
    assign p3in = project_io_in[3][13:0];
    assign project_io_out[3][13:0] = p3out;
    `ifndef FORMAL
    spinet #(.N(2), .WIDTH(16), .ABITS(3)) proj_3 (
        .clk(p3in[0]),
        .rst(p3in[1]),
        .MOSI(p3in[3:2]),
        .SCK(p3in[5:4]),
        .SS(p3in[7:6]),
        .MISO(p3out[9:8]),
        .txready(p3out[11:10]),
        .rxready(p3out[13:12]));
    `endif

    // project 4
    wire [31:0] freq_cnt_cont;
    `ifndef FORMAL
    freq_cnt proj_4(  // TODO change instance name from `top` to `freq_cnt`
        .clk(project_io_in[4][0]),
        .rst(project_io_in[4][1] | la_data_in[0]),

        // register write interface (ignores < 32 bit writes, no read!):
        // 32'h30000300 = writes UART clock divider, reads cont. counter value
        // 32'h30000304 = Frequency counter update period [sys_clks]
        .addr(wbs_adr_i[5:2]),
        .value(wbs_dat_i),
        .strobe(valid & (&wstrb) & ((wbs_adr_i >> 8) == (address_freq >> 8))),

        // signal under test
        .samplee(project_io_in[4][2]),
        // continuous counter output to wishbone
        .oc(freq_cnt_cont),
        // UART output to pin
        .tx(project_io_out[4][0])
    );
    `endif

    // wishbone MUX signals
    wire valid;
    wire [3:0] wstrb;
    reg [31:0] wbs_data_out;
    reg wbs_ack;
    assign wbs_ack_o = wbs_ack;
    assign wbs_dat_o = wbs_data_out;
    assign valid = wbs_cyc_i && wbs_stb_i;
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};

    always @(posedge wb_clk_i) begin
        wbs_ack <= 0;

        // reset
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
                address_7seg: begin
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

                address_freq: begin
                    wbs_data_out <= freq_cnt_cont;
                    wbs_ack <= 1;
                end
            endcase
        end
    end

    `ifdef FORMAL
        integer i;
        always @(*) begin
            if(active_project > 0 && active_project < num_projects)
                assert(io_oeb == `MPRJ_IO_PADS'b1);
            for(i = 0; i < num_projects; i ++) begin
                if(active_project == i)
                    assert(io_out == project_io_out[i]);
                if(active_project == i)
                    assert(io_in == project_io_in[i]);
            end
        end
    `endif

endmodule
`default_nettype wire
