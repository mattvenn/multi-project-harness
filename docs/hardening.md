# Hardening the user_project_wrapper

The strategy is:

* harden each submodule with a config like [this one for ws2812](../openlane/macroconfig/config.tcl)
    * the key config is `set ::env(DESIGN_IS_CORE) 0` which makes sure that metal5 is not used for routing

* copy all the gds and lef files to caravel/openlane/user_project_wrapper/macros/
    * this is done with [reports.py --copy files](../reports.py)
    * use this [config](../openlane/config/config.tcl)

* As this was originally done in mpw-one-a tag of tools, need to copy the resulting gds and lef file to the caravel mpw-one-b
    * then run make to build caravel
    
## ws2812 : DESIGN=ws2812 RUN_DATE=03-02_10-14

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    0
            antenna_violations :                    1
              lvs_total_errors :                    0

width x height 275 um

## vga_clock : DESIGN=vga_clock RUN_DATE=04-02_10-59

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    0
            antenna_violations :                    0
              lvs_total_errors :                    0

width x height 233 um

## seven_segment_seconds : DESIGN=seven_segment_seconds RUN_DATE=03-02_10-29

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    0
            antenna_violations :                    0
              lvs_total_errors :                    0

width x height 153 um

## spinet5 : DESIGN=spinet5 RUN_DATE=03-02_10-30

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    0
            antenna_violations :                    0
              lvs_total_errors :                    0

width x height 338 um

## asic_freq : DESIGN=asic_freq RUN_DATE=03-02_10-31

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    0
            antenna_violations :                    2
              lvs_total_errors :                    0

width x height 394 um

## watch_hhmm : DESIGN=watch_hhmm RUN_DATE=03-02_10-51

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    0
            antenna_violations :                    0
              lvs_total_errors :                    0

width x height 161 um

## challenge : DESIGN=challenge RUN_DATE=03-02_10-32

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    0
            antenna_violations :                    0
              lvs_total_errors :                    0

width x height 167 um

## MM2hdmi : DESIGN=MM2hdmi RUN_DATE=03-02_10-34

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    0
            antenna_violations :                    0
              lvs_total_errors :                    0

width x height 141 um

## multi_project_harness : DESIGN=multi_project_harness RUN_DATE=04-02_10-09

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    0
            antenna_violations :                    6
              lvs_total_errors :                    0

width x height 774 um

