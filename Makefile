# cocotb setup
MODULE = test_harness
TOPLEVEL = multi_project_harness
PROJ_0_SOURCES = seven-segment-seconds/seven_segment_seconds.v
PROJ_1_SOURCES = ws2812/ws2812.v
PROJ_2_SOURCES = vga-clock/rtl/button_pulse.v vga-clock/rtl/digit.v vga-clock/rtl/VgaSyncGen.v vga-clock/rtl/fontROM.v vga-clock/rtl/vga_clock.v
PROJ_3_SOURCES = spinet/rtl/spinet.v
PROJ_4_SOURCES = asicfreq/asic_freq.v
PROJ_5_SOURCES = asicfreq/asic_freq.v
PROJ_6_SOURCES = ASIC_watch/submodules/count10m.v ASIC_watch/submodules/count24h.v ASIC_watch/submodules/count60m.v ASIC_watch/submodules/count60s.v ASIC_watch/submodules/crystal2hz.v ASIC_watch/submodules/segment7.v ASIC_watch/hdl/watch_hhmm.v

VERILOG_SOURCES = multi_project_harness.v $(PROJ_0_SOURCES) $(PROJ_1_SOURCES) $(PROJ_2_SOURCES) $(PROJ_3_SOURCES) $(PROJ_4_SOURCES) $(PROJ_6_SOURCES)

include $(shell cocotb-config --makefiles)/Makefile.sim

gtkwave:
	# how to avoid doing this? because subproject also uses cocotb
	mv seven_segment_seconds.vcd harness.vcd
	gtkwave harness.vcd harness.gtkw

formal:
	sby -f properties.sby

clean::
	rm -rf *vcd properties
