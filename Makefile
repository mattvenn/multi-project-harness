# cocotb setup
MODULE = test_harness
TOPLEVEL = multi_project_harness
VERILOG_SOURCES = top.v seven-segment-seconds/seven_segment_seconds.v

include $(shell cocotb-config --makefiles)/Makefile.sim

gtkwave:
	# how to avoid doing this? because subproject also uses cocotb
	mv seven_segment_seconds.vcd harness.vcd
	gtkwave harness.vcd harness.gtkw

formal:
	sby -f properties.sby

clean::
	rm -rf *vcd properties
