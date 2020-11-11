`default_nettype none
module multi_project_harness (
    input wire clk,
    input wire [3:0] reset,
    input wire [9:0] gpio_in,
    output wire [9:0] gpio_out
    );

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile ("harness.vcd");
            $dumpvars (0, multi_project_harness);
            #1;
        end
    `endif
    
    wire [9:0] gpio_out0,  gpio_out1;
    wire [9:0] gpio_in0,   gpio_in1;

    // outputs  up gpios for inputs and outputs
    assign gpio_out = reset == 4'b1110 ? gpio_out0 :
                               4'b1101 ? gpio_out1 :
                                         10'bz;

    // inputs can be split between all modules
    assign gpio_in0 = reset == 4'b1110 ? gpio_in : 10'bz;
    assign gpio_in1 = reset == 4'b1101 ? gpio_in : 10'bz;
    
    // instantiate all the modules
    `ifndef FORMAL
    seven_segment_seconds inst_0 (.clk(gpio_in0[0]), .reset(reset[0]), .led_out(gpio_out0[6:0]));
    seven_segment_seconds inst_1 (.clk(gpio_in1[1]), .reset(reset[1]), .led_out(gpio_out1[6:0]));
    `endif

    // sanity check
    `ifdef FORMAL
        always @(*) begin
            if(&reset)
                assert(gpio_out == 10'bz);
        end
    `endif

endmodule
