# multi project harness

This is a proposal for handling multiple projects in the user project area of the [Caravel harness](https://github.com/efabless/caravel)

clone with --recursive to get the demo project [seven segment seconds](https://github.com/mattvenn/seven-segment-seconds)

You will also need cocotb and iverilog installed.

    sudo apt-get install iverilog
    pip3 install cocotb

![multi project harness diagram](docs/multi-project-harness.png)

![multi project gds](docs/multi-project-gds.png)

# Process

* each design must have at max 10 inputs and outputs
* each design is hardened (turned into a GDS2 layout)
* designs and this harness are aggregated into 1 macro following this pattern: https://github.com/efabless/openlane/tree/master/designs/manual_macro_placement_test
* the whole thing is put inside the Caravel user space
* Caravel SoC programmed with firmware that sets the GPIOs half input and half output and holds all designs in reset
* A button allows different designs to be un-reset
* LEDs show which design is currently active

# TODO

* change input reset[3:0] for a wishbone peripheral that can hold each device in reset given commands from the Caravel SoC.
* add LED display
* add button
* SoC can read the button presses

# Unknowns/Assumptions

* 10 inputs and 10 outputs.
* how to do clock? will there be a dedicated clock from SoC?
* haven't tested the manual macro placement yet as it is currently broken with openlane rc4
* how to put the final macro into the user project area of Caravel.
* could IOs be multiplexed in a way that doesn't mean they have to be divided into inputs and outputs before hand? 


# Demo

run a simulation of activating one design and then the next:

    make sim
    make gtkwave

prove outputs go to 10'bz when reset:

    make formal

# Example config

* Working [config.tcl](example/config.tcl)
* Slightly adapted [top.v](top.v) by adding blackboxed modules: [src/top.v](example/src/top.v)
