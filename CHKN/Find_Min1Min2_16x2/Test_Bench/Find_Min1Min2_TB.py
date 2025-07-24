import numpy
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


@cocotb.test()
def tb(dut):
    cocotb.fork(Clock(dut.clk, 10).start())
    # yield do_reset(dut,2)
    yield ClockCycles(dut.clk, 2)
    ne = 0
    in_sig_bin = BinaryValue(bits=16 * 8, bigEndian=False)
    for i_run in range(2):
        in_sigs = numpy.random.randint(0, 255, 16)
        for i_in in range(16):
            in_sig_bin[(i_in+1)*8-1:i_in*8] = int(in_sigs[15-i_in])

        dut.inSig = in_sig_bin
        yield ClockCycles(dut.clk, 1)
        dut_min_sig1 = dut.MinSig1
        dut_min_sig2 = dut.MinSig2

        # reference model
        in_sigs_sort = numpy.sort(in_sigs)
        idx_sort = numpy.argsort(in_sigs)
        ref_min_sig1 = in_sigs_sort[0]
        ref_min_sig2 = in_sigs_sort[1]
        idx_min1 = idx_sort[0]

        # compare
        if((ref_min_sig1 != dut_min_sig1) | (ref_min_sig2 != dut_min_sig2)):
            print(int(dut_min_sig1))
            print(int(ref_min_sig1))
            print(int(dut_min_sig2))
            print(int(ref_min_sig2))
            ne = ne+1

        if (idx_min1 != dut.IdxMinSig1):
            if(in_sigs[int(dut.IdxMinSig1)] != in_sigs[idx_min1]):
                ne = ne+1
                print(idx_min1)
                print(dut.IdxMinSig1.value.integer)
                print(in_sigs)
                print(idx_sort)

    if (ne == 0):
        print(" --------------------")
        print(" ------- PASS -------")
        print(" --------------------")
    else:
        print(" ------------------------------------------------")
        print(" ------- FAIL -------ne = {lne}".format(lne=ne))
        print(" ------------------------------------------------")
