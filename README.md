# multi project harness

This is a proposal for handling multiple projects in the user project area of the [caravel harness](https://github.com/efabless/caravel)

clone with --recursive to get the demo project [seven segment seconds]https://github.com/mattvenn/seven-segment-seconds)

# Makefile

run a simulation of activating one design and then the next:

    make sim
    make gtkwave

prove outputs go to 10'bz when reset:

    make formal

