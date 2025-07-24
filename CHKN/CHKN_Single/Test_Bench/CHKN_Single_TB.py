#import pudb
import matlab.engine
mtlb = matlab.engine.start_matlab()
mtlb.addpath(r'/home/WLAN_implementation/Matlab/LDPC_Decoder_MATLAB/ad_V3/class', nargout=0)

import numpy
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles
from bitstring import BitArray, BitStream, BitString, Bits

#numpy.random.seed(10)

@cocotb.coroutine
def do_reset(self, n):
    self.reset <= 1
    yield ClockCycles(self.clk, n+1)
    self.reset <= 0


@cocotb.test()
def tb(dut):
    cocotb.fork(Clock(dut.clk, 10).start())
    dut.validIn   <= 0
    yield do_reset(dut, 20)
    yield ClockCycles(dut.clk, 2)

    ne = 0
    WIDTH_LLR = 8
    NUM_INOUT = 16
    CHKN_Single_obj = mtlb.CHKN_Single(-(2**(WIDTH_LLR-1)),  2**(WIDTH_LLR-1)-1)
    for i_run in range(10):
        print("--------------------------- Run {X} ---------------------------".format(X = i_run))
        for i_iter in range(15):   #15
            dut.currIter <= i_iter + 1
            for i_layer in range(8):   #8
                dut.iLayer <= i_layer
                llr_new_in = BinaryValue(n_bits=WIDTH_LLR*NUM_INOUT, bigEndian=False)
                llr_new = numpy.random.randint(-128, 128, NUM_INOUT)
                
                eta_sum_in = BinaryValue(n_bits=WIDTH_LLR*NUM_INOUT, bigEndian=False)
                eta_sum= numpy.random.randint(-128+1, 128-1, NUM_INOUT)

                active_cols_in = BinaryValue(n_bits=NUM_INOUT, bigEndian=False)
                active_cols    = []
                #print(active_cols)
                for ix in range(NUM_INOUT):
                    idx1 = ((ix+1)*WIDTH_LLR)-1
                    idx2 = (ix*WIDTH_LLR)

                    tmp_val               = Bits(int = llr_new[ix], length = WIDTH_LLR)
                    llr_new_in[idx1:idx2] =  tmp_val.bin

                    tmp_val               = Bits(int = eta_sum[ix], length = WIDTH_LLR)
                    eta_sum_in[idx1:idx2] =  tmp_val.bin

                    if (numpy.random.choice([True, False])):
                        active_cols_in[ix] = 1
                        active_cols.append(1)
                    else:
                        active_cols_in[ix] = 0
                        active_cols.append(0)

                #print(active_cols_in.binstr)
                dut.activeCols <= active_cols_in
                dut.llrNew     <= llr_new_in
                dut.etaSumIn   <= eta_sum_in
                dut.validIn    <= 1
                yield ClockCycles(dut.clk, 1)  ###
                dut.validIn    <= 0
                while (dut.ValidOut == 0):
                    yield ClockCycles(dut.clk, 1)
                
                eta_sum_out = [None] * NUM_INOUT
                for ix in range(NUM_INOUT):
                    idx1 = ((ix+1)*WIDTH_LLR)-1
                    idx2 = (ix*WIDTH_LLR)
                    tmp_val = dut.EtaSumOut.value[idx2:idx1]
                    eta_sum_out[NUM_INOUT-ix-1] = tmp_val.signed_integer
                
                yield ClockCycles(dut.clk, 50)
                # reference
                eta_sum_ref, min1_ref, min2_ref = mtlb.CHKN_Core(CHKN_Single_obj, matlab.double(active_cols), matlab.double(llr_new.tolist()), matlab.double(eta_sum.tolist()), (i_layer+1), (i_iter+1), nargout=3)
                
                #print("eta_sum_dut        = {x}".format(x = eta_sum_out))
                #print("eta_sum_out_mtlab = {x}".format(x = eta_sum_ref[0:]))
                
                # compare 
                dif = numpy.array(eta_sum_ref[0:]) - numpy.array(eta_sum_out)
                if (numpy.any(dif)):  # if any of dif is non-zero
                    ne = ne+1

    if (ne == 0):
        print(" --------------------")
        print(" ------- PASS -------")
        print(" --------------------")
    else:
        print(" ------------------------------------------------")
        print(" ------- FAIL -------ne = {lne}".format(lne=ne))
        print(" ------------------------------------------------")
