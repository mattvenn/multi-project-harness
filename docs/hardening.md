# Hardening the multi project harness

The strategy is:

* harden each submodule with a config like [this one for ws2812](../openlane/macroconfig/config.tcl)
    * the key config is `set ::env(DESIGN_IS_CORE) 0` which makes sure that metal5 is not used for routing

* copy all the gds and lef files to multi_project_harness/macros
    * this is done with [update_macros.sh](../openlane/config/update_macros.sh)

* harden top level macro that includes all the subprojects
    * copy [multi_project_harness.v] to the openlane src/ directory
    * use this [config](../openlane/config/config.tcl)
    * have to modify multi_project_harness.v to add:
        * `include blackbox.v
        * `define MPRJ_IO_PADS 38

* copy this gds and lef file to the caravel user project directory and run the caravel makefile to add the macro
    * don't know how to do this part
    * make in caravel/openlane
    * current is 1800 x 1800 um but mostly empty space
    
# Current results for top level macro 

## with auto placing macros

        tritonRoute_violations :                  180
              Short_violations :                  170
             MetSpc_violations :                   10
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                 1126
            antenna_violations :                  110
              lvs_total_errors :                  102

## with hand placed macros

        tritonRoute_violations :                    3
              Short_violations :                    3
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                  922
            antenna_violations :                  102
              lvs_total_errors :                    3

## slightly wider spaced macros

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                  501
            antenna_violations :                  105
              lvs_total_errors :                    0

Magic violations:

    Metal3 > 3um spacing to unrelated m3 < 0.4um (met3.3d)
    All nwells must contain metal-connected N+ taps (nwell.4)
    Metal1 > 3um spacing to unrelated m1 < 0.28um (met1.3b)
    Metal2 > 3um spacing to unrelated m2 < 0.28um (met2.3b)

# Current results for submodules

## ws2812 : DESIGN=ws2812 RUN_DATE=30-11_11-18

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                   14
            antenna_violations :                    0
              lvs_total_errors :                    0

* All nwells must contain metal-connected N+ taps (nwell.4)

## vga_clock : DESIGN=vga_clock RUN_DATE=27-11_14-37

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                   10
            antenna_violations :                    0
              lvs_total_errors :                    0

* All nwells must contain metal-connected N+ taps (nwell.4)

## seven_segment_seconds : DESIGN=seven_segment_seconds RUN_DATE=27-11_14-39

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    6
            antenna_violations :                    0
              lvs_total_errors :                    0

* All nwells must contain metal-connected N+ taps (nwell.4)

## spinet5 : DESIGN=spinet5 RUN_DATE=30-11_11-37

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                   32
            antenna_violations :                    1
              lvs_total_errors :                    0

* All nwells must contain metal-connected N+ taps (nwell.4)

## asic_freq : DESIGN=asic_freq RUN_DATE=30-11_11-49

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                   48
            antenna_violations :                    2
              lvs_total_errors :                    0

* All nwells must contain metal-connected N+ taps (nwell.4)

## watch_hhmm : DESIGN=watch_hhmm RUN_DATE=27-11_14-41

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    5
            antenna_violations :                    0
              lvs_total_errors :                    0

* All nwells must contain metal-connected N+ taps (nwell.4)

## challenge : DESIGN=challenge RUN_DATE=30-11_10-45

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    7
            antenna_violations :                    0
              lvs_total_errors :                    0

* All nwells must contain metal-connected N+ taps (nwell.4)

