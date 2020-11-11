# multi project harness

This is a proposal for handling multiple projects in the user project area of the [Caravel harness](https://github.com/efabless/caravel)

clone with --recursive to get the demo project [seven segment seconds](https://github.com/mattvenn/seven-segment-seconds)

![multi project harness diagram](docs/multi-project-harness.png)

# Unknowns/Assumptions

* 10 inputs and 10 outputs.
* how to do clock? will there be a dedicated clock from SoC?
* haven't tested the manual macro placement yet as it is currently broken with openlane rc4
* how to put the final macro into the user project area of Caravel.

# Process

* each design must have at max 10 inputs and outputs
* each design is hardened (turned into a GDS2 layout)
* designs and this harness are aggregated into 1 macro following this pattern: https://github.com/efabless/openlane/tree/master/designs/manual_macro_placement_test
* the whole thing is put inside the Caravel user space

# TODO

change input reset[3:0] for a wishbone peripheral that can hold each device in reset given commands from the Caravel SoC.

# Demo

run a simulation of activating one design and then the next:

    make sim
    make gtkwave

prove outputs go to 10'bz when reset:

    make formal
