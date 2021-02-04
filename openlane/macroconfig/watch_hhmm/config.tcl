# User config
set ::env(DESIGN_NAME) watch_hhmm

# Change if needed
set ::env(VERILOG_FILES) "\
    $::env(DESIGN_DIR)/ASIC_watch/hdl/watch_hhmm.v \
    $::env(DESIGN_DIR)/ASIC_watch/submodules/count10m.v \
    $::env(DESIGN_DIR)/ASIC_watch/submodules/count24h.v \
    $::env(DESIGN_DIR)/ASIC_watch/submodules/count60m.v \
    $::env(DESIGN_DIR)/ASIC_watch/submodules/count60s.v \
    $::env(DESIGN_DIR)/ASIC_watch/submodules/crystal2hz.v \
    $::env(DESIGN_DIR)/ASIC_watch/submodules/segment7.v"


set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5

# Fill this
# 500khz
#set ::env(CLOCK_PERIOD) "2000"
#set ::env(CLOCK_NET) "clk_crystal_i"
#set ::env(CLOCK_PORT) "sysclk_i"

# turn off CTS till I work out how to do it
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(CLOCK_PORT) ""

set ::env(FP_CORE_UTIL) 22
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+7) / 100.0 ]

set ::env(DIODE_INSERTION_STRATEGY) 1

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

