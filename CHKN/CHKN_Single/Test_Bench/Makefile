SHELL=bash
CWD=$(shell pwd)
TOPLEVEL_LANG=verilog
SIM=verilator#modelsim

VERILOG_SOURCES =$(CWD)/../../../LDPC_Params/LDPC_Params.sv
VERILOG_SOURCES +=$(CWD)/../RTL/CHKN_Single.sv
VERILOG_SOURCES +=$(CWD)/../../Find_Min1Min2_16x2/RTL/Find_Min1Min2_16x2.sv
VERILOG_SOURCES +=$(CWD)/../../../Add_Saturate/RTL/Add_Saturate.sv


#####
TOPLEVEL=CHKN_Single
MODULE=CHKN_Single_TB
CUSTOM_SIM_DEPS=$(CWD)/Makefile

include $(shell cocotb-config --makefiles)/Makefile.sim

# list all required Python files here
sim: $(MODULE).py

