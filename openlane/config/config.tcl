# User config
set ::env(DESIGN_NAME) multi_project_harness

# make the project harness include blackbox.v
set ::env(SYNTH_DEFINES) "BLACKBOX" 
# NO_PROJ0 NO_PROJ1 NO_PROJ2 NO_PROJ3 NO_PROJ4 NO_PROJ5 NO_PROJ6"


# Change if needed
set ::env(VERILOG_FILES) $::env(DESIGN_DIR)/mpw-multi-project-harness/multi_project_harness.v

set ::env(DESIGN_IS_CORE) 1

# Fill this
# 50Mhz
set ::env(CLOCK_PERIOD) "20" 
set ::env(CLOCK_PORT) "wb_clk_i"

set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_SKIP_INITIAL_PLACEMENT) 1
set ::env(DIODE_INSERTION_STRATEGY) 0

# macro stuff
set ::env(MACRO_PLACEMENT_CFG) $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/macro_placement.cfg
set ::env(EXTRA_LEFS) [glob $::env(DESIGN_DIR)/macros/lef/*.lef]
set ::env(EXTRA_GDS_FILES) [glob $::env(DESIGN_DIR)/macros/gds/*.gds]
set ::env(FP_HORIZONTAL_HALO) 10
set ::env(FP_VERTICAL_HALO) 10

# was having lvs issues with cells in the extreme left and right not getting a vertical power line because the pitch was too wide
set ::env(FP_PDN_VPITCH) 75

# CORE_UTIL not used if FP_SIZING is absolute
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1200 1500"
set ::env(PL_TARGET_DENSITY) 0.8

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

