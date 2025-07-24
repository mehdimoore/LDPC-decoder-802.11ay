import sys
sys.path.insert(0,'../../../Reference_Design')
from Calculate_LLRs import Calculate_Llrs
from Generate_HG_Matrix import Generate_G
import matplotlib.pyplot as plt
import matlab.engine
mtlb = matlab.engine.start_matlab()
mtlb.addpath(r'/home/WLAN_implementation/Matlab/LDPC_Decoder_MATLAB/ad_V3/class', nargout=0)

import numpy as np
from fxpmath import Fxp
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles
from bitstring import BitArray, BitStream, BitString, Bits

def Convert_Str2Arr(a):
    b = np.array((), dtype=int)
    for ix in a:
        b = np.append(b, int(ix))
    return (b)

#np.random.seed(10)
NUM_COL_MAX = 16
WIDTH_LLR   = 8
Z           = 42
NUM_INOUT   = 16 # number of in/out to chkn_single
n_iter      = 14
min_val  = -(2**(WIDTH_LLR-1))
max_val  = 2**(WIDTH_LLR-1)-1
ldpc_obj = mtlb.LDPC_Decoder(min_val, max_val)
code_rate = 0
mod_order = 2 #2,4,16, 64
mtlb.Set_Rate(ldpc_obj,code_rate, nargout=0)
len_cw  = 672
if (code_rate == 0):
    len_dw = 336
    G = Generate_G('1/2')
    code_info = {"code_rate":"1/2", "G":G}
elif (code_rate == 1):
    len_dw = 420
    G = Generate_G('5/8')
    code_info = {"code_rate":"5/8", "G":G}

ne = 0
out_cnt = 0

def Read_Output(ValidOut, in_dut_data_word, data_word_all):
    if (ValidOut == 1):
        tmp = Convert_Str2Arr(in_dut_data_word)
        tmp = np.flip(tmp)
        return_word = np.append(data_word_all , tmp)
    else:
        return_word = data_word_all
    return return_word

@cocotb.coroutine
def do_reset(self,n):
    self.reset <= 1
    yield ClockCycles(self.clk,n+1)
    self.reset <= 0

@cocotb.test()
def tb(dut):
    cocotb.fork(Clock(dut.clk, 10).start())
    yield do_reset(dut,1)
    yield ClockCycles(dut.clk, 2)
    n_trial = 150
    i_compare = 0
    dut_data_word = np.array((), dtype=int)
    dut_data_word_all = np.empty((n_trial, len_dw), dtype=int)
    ref_data_word_all = np.empty((n_trial, len_dw), dtype=int)
    dut.iterMax <= n_iter
    dut.rate    <= code_rate
    for i_run in range(n_trial):
        print("i_run =  {i_run_holder}".format(i_run_holder = i_run))
        ReadyOut = dut.ReadyOut
        while (ReadyOut == 0):
            dut_data_word = Read_Output(dut.ValidOut, dut.DataWord.value, dut_data_word)
            if (dut_data_word.size == len_dw):
                dut_data_word_all[i_compare][0:] = dut_data_word
                dut_data_word = np.array((), dtype=int)
                i_compare += 1
            yield ClockCycles(dut.clk, 1)
        else:
            llrs, ref_data_word, code_word = Calculate_Llrs(code_info, 4, 10)
            ref_data_word_all[i_run][0:] = ref_data_word
            llrs = np.reshape(llrs,(16,42))
            llr_new_matlab = mtlb.Decode_Top(ldpc_obj, matlab.double(llrs.tolist()), n_iter) # run reference model
            for i_col in range(NUM_COL_MAX):
                # first feed input (i.e., first column)
                in_sig_bin = BinaryValue(n_bits = Z * WIDTH_LLR, bigEndian=False)
                for ix in range(Z):
                    idx2 = ((ix+1) * WIDTH_LLR)-1
                    idx1 = ix * WIDTH_LLR

                    tmp_val = Fxp(llrs[i_col][ix], dtype='s7.1')
                    in_sig_bin[idx2:idx1] =  tmp_val.bin()

                dut.llrIn    <= in_sig_bin    
                dut.validIn  <= 1
                dut.llrInCnt <= int(i_col)
                if (i_col == NUM_COL_MAX-1):
                    dut.llrInLast <= 1
                else:
                    dut.llrInLast <= 0
                
                dut_data_word = Read_Output(dut.ValidOut, dut.DataWord.value, dut_data_word)
                if (dut_data_word.size == len_dw):
                    dut_data_word_all[i_compare][0:] = dut_data_word
                    dut_data_word = np.array((), dtype=int)
                    i_compare += 1
                yield ClockCycles(dut.clk, 1)
                dut.validIn   <= 0
                dut.llrInLast <= 0
                ValidOut = dut.ValidOut.value

    cnt_final = 0
    while (cnt_final<1000):
        cnt_final += 1
        dut_data_word = Read_Output(dut.ValidOut, dut.DataWord.value, dut_data_word)
        if (dut_data_word.size == len_dw):
            dut_data_word_all[i_compare][0:] = dut_data_word
            dut_data_word = np.array((), dtype=int)
            i_compare += 1
        yield ClockCycles(dut.clk, 1)
    
    # some tail clocks
    yield ClockCycles(dut.clk, 1500)
    if np.array_equal(ref_data_word_all, dut_data_word_all): 
        print(dut_data_word_all)
        print(" --------------------")
        print(" ------- PASS -------")
        print(" --------------------")
    else:
        #print(ref_data_word_all[0][0:42])
        #print(dut_data_word_all[0][0:42])
        print(" --------------------")
        print(" ------- FAIL -------")
        print(" --------------------")
