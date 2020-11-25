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
    
# Current results for submodules

All the DRC errors reported are of the type

* All nwells must contain metal-connected N+ taps (nwell.4)
* Min area of metal1 holes > 0.14um^2 (met1.7)

Additionally freqcnt has LVS errors that don't seem real. All these pins exist in the design and in the extracted spice file.
An issue has been opened here: https://github.com/RTimothyEdwards/netgen/issues/7

    col_drvs[2]                                |(no matching pin)                          
    col_drvs[5]                                |(no matching pin)                          
    seg_drvs[2]                                |(no matching pin)                          
    col_drvs[3]                                |(no matching pin)                          
    col_drvs[0]                                |(no matching pin)                          
    col_drvs[1]                                |(no matching pin)      

## ws2812

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                   13
            antenna_violations :                    4
              lvs_total_errors :                    0
## spinet6

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                   40
            antenna_violations :                    1
              lvs_total_errors :                    0
## 7seg

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                    6
            antenna_violations :                    0
              lvs_total_errors :                    0
## vgaclock

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                   10
            antenna_violations :                    0
              lvs_total_errors :                    0


## freqcnt

        tritonRoute_violations :                    0
              Short_violations :                    0
             MetSpc_violations :                    0
            OffGrid_violations :                    0
            MinHole_violations :                    0
              Other_violations :                    0
              Magic_violations :                 4146
            antenna_violations :                   24
              lvs_total_errors :                    6

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
