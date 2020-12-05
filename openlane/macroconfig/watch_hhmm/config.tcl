# User config
set ::env(DESIGN_NAME) watch_hhmm

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5

# Fill this
# 500khz
set ::env(CLOCK_PERIOD) "2000"
set ::env(CLOCK_PORT) "clk_i"

set ::env(PL_TARGET_DENSITY) 0.35
set ::env(FP_CORE_UTIL) 30

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

