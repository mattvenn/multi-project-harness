# cocotb setup
MODULE = test_harness
TOPLEVEL = multi_project_harness
PROJ_0_SOURCES = seven-segment-seconds/seven_segment_seconds.v 
PROJ_1_SOURCES = ws2812/ws2812.v
PROJ_2_SOURCES = vga-clock/rtl/button_pulse.v vga-clock/rtl/digit.v vga-clock/rtl/VgaSyncGen.v vga-clock/rtl/fontROM.v vga-clock/rtl/vga_clock.v
VERILOG_SOURCES = multi_project_harness.v $(PROJ_0_SOURCES) $(PROJ_1_SOURCES) $(PROJ_2_SOURCES)

include $(shell cocotb-config --makefiles)/Makefile.sim

gtkwave:
	# how to avoid doing this? because subproject also uses cocotb
	mv seven_segment_seconds.vcd harness.vcd
	gtkwave harness.vcd harness.gtkw

formal:
	sby -f properties.sby

clean::
	rm -rf *vcd properties
