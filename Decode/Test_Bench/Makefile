SHELL=bash
CWD=$(shell pwd)
TOPLEVEL_LANG=verilog
SIM=verilator
#EXTRA_ARGS += --trace --trace-max-array 100000 #--trace-structs --trace-threads 10

VERILOG_SOURCES  =$(CWD)/../RTL/Decode.sv
VERILOG_SOURCES +=$(CWD)/../RTL/FSM_Engine.sv
VERILOG_SOURCES +=$(CWD)/../RTL/Init.sv
VERILOG_SOURCES +=$(CWD)/../../CHKN/CHKN_Single/RTL/CHKN_Single.sv
VERILOG_SOURCES +=$(CWD)/../../Add_Saturate/RTL/Add_Saturate.sv
VERILOG_SOURCES +=$(CWD)/../../CHKN/Find_Min1Min2_16x2/RTL/Find_Min1Min2_16x2.sv

#####
TOPLEVEL=Decode
MODULE=Decode_TB
CUSTOM_SIM_DEPS=$(CWD)/Makefile

include $(shell cocotb-config --makefiles)/Makefile.sim

# list all required Python files here
sim: $(MODULE).py

