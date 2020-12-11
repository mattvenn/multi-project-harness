# User config
set ::env(DESIGN_NAME) multi_project_harness

# Change if needed
set ::env(SYNTH_DEFINES) "OPENLANE" 
set ::env(VERILOG_FILES) $::env(DESIGN_DIR)/mpw-multi-project-harness/multi_project_harness.v

set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5

set ::env(PL_RANDOM_GLB_PLACEMENT) 1

# Fill this
# 20Mhz
set ::env(CLOCK_PERIOD) "50" 
set ::env(CLOCK_PORT) "wb_clk_i"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2200 400"
set ::env(PL_TARGET_DENSITY) 0.2


set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

