# cocotb setup
MODULE = test_harness
TOPLEVEL = multi_project_harness
VERILOG_SOURCES = top.v seven_segment_seconds.v

include $(shell cocotb-config --makefiles)/Makefile.sim

gtkwave:
	gtkwave harness.vcd harness.gtkw

formal:
	sby -f properties.sby
