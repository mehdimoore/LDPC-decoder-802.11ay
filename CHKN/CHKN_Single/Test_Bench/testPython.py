import numpy
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles
from bitstring import BitArray, BitStream, BitString, Bits

active_cols_in = BinaryValue(n_bits=16, bigEndian=True)
for ix in range(16):
    print(ix)
    if (True): #numpy.random.choice([True, False])):
        active_cols_in[ix] = '1'
        print(active_cols_in.binstr)
    else:
        active_cols_in[ix] = 0
        active_cols.append(0)