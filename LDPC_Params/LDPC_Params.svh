`ifndef __LDPC_DECODER_COMMON_PARAMS__
`define __LDPC_DECODER_COMMON_PARAMS__

parameter Z                     = 42;
parameter WIDTH_ITERATION       = 5;
parameter WIDTH_RATE            = 5;
parameter WIDTH_LLR             = 8;
parameter NUM_LAYERS            = 8;
parameter NUM_COLS              = 16;
parameter NUM_CHKN_LLRS_INOUT   = 16;
parameter WIDTH_STATE_FSM_ENG   = 5;

// ======== Calculated parameters ======== //
parameter WIDTH_CHKN_IDX        = $clog2(NUM_CHKN_LLRS_INOUT);
parameter WIDTH_LAYER           = $clog2(NUM_LAYERS);  //TODO
parameter WIDTH_LAYER_CNT       = $clog2(NUM_LAYERS) + 1;
parameter WIDTH_Z               = $clog2(Z);
parameter WIDTH_ROW_WEIGHT      = $clog2(NUM_COLS);



enum logic [WIDTH_RATE-1:0]{
rate_1_2 = 0,
rate_3_4,
rate_5_8,
rate_13_16
} rate;

`endif
