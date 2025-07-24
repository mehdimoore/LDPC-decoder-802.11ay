SHELL=bash
CWD=$(shell pwd)
TOPLEVEL_LANG=verilog
SIM=verilator
EXTRA_ARGS += --trace --trace-max-array 100000 #--trace-structs --trace-threads 10

VERILOG_SOURCES =$(CWD)/../RTL/Find_Min1Min2_16x2.sv ../../../LDPC_Params/LDPC_Params.svh

#####
TOPLEVEL=Find_Min1Min2_16x2
MODULE=Find_Min1Min2_TB
CUSTOM_SIM_DEPS=$(CWD)/Makefile

include $(shell cocotb-config --makefiles)/Makefile.sim

# list all required Python files here
sim: $(MODULE).py

