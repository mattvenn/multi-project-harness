# User config
set ::env(DESIGN_NAME) MM2hdmi

# Change if needed
set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/mm2hdmi/verilog/MM2hdmi.v"

set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5

# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clock"

set ::env(FP_CORE_UTIL) 30
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

