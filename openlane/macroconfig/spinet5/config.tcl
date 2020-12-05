# User config
set ::env(DESIGN_NAME) spinet5

# Change if needed
set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/spinet/rtl/spinet.v"

set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5


set ::env(FP_CORE_UTIL) 25
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

# Fill this
# 50mhz
set ::env(CLOCK_PERIOD) "20"
set ::env(CLOCK_PORT) "clk"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

