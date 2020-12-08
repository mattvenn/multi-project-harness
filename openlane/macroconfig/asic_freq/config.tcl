# User config
set ::env(DESIGN_NAME) asic_freq

# Change if needed
set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/asicfreq/asic_freq.v"

set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5

set ::env(FP_CORE_UTIL) 29
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+9) / 100.0 ]

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10
set ::env(DIODE_INSERTION_STRATEGY) 3

# Fill this
# 50Mhz
set ::env(CLOCK_PERIOD) "20"
set ::env(CLOCK_PORT) "clk"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

