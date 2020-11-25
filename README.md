# Multi Project Harness

This is a proposal for handling multiple projects in the user project area of the [Caravel harness](https://github.com/efabless/caravel)

clone with --recursive to get the demo project [seven segment seconds](https://github.com/mattvenn/seven-segment-seconds)

You will also need cocotb and iverilog installed.

    install iverilog from source git://github.com/steveicarus/iverilog.git
    pip3 install cocotb

![multi project harness diagram](docs/multi-project-harness.png)

![multi project gds](docs/multi-project-gds.png)

# Process of adding a new design

## Context 1: add to multi-project-harness

* add design as a submodule
* add a test to the test_harness.py

## Context 2: Caravel

* clone caravel and add this repo as a submodule in caravel/verilog/rtl
* add firmware and test in caravel/verilog/dv/caravel/user_proj_example
* run the test and check your design is selected and generating expected signals. Best if the testbench actually checks something basic.
* see https://github.com/mattvenn/caravel/tree/multi-project/verilog/dv/caravel/user_proj_example/seven-segment-counter for an example

## Context 3: OpenLane

Each design is hardened (turned into a GDS2 layout) and then aggrated into the top module. See here for more [info](docs/hardening.md)

# Simulation / Verification

run a simulation of activating one design and then the next:

    make sim
    make gtkwave

run a formal proof that the mux is correct

    make formal
