# User config
set ::env(DESIGN_NAME) ws2812

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5

# 0.4 50  13 4
# 0.3 40  20 0
# 0.4 40  14 2
# 0.3 40  14 0

set ::env(PL_TARGET_DENSITY) 0.3
set ::env(FP_CORE_UTIL) 40

# Fill this
# 20Mhz
set ::env(CLOCK_PERIOD) "50" 
set ::env(CLOCK_PORT) "clk"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

