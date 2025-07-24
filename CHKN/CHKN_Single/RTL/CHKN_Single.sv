`include "../../../LDPC_Params/LDPC_Params.svh"
module CHKN_Single (
        input  logic                                        clk,
        input  logic                                        reset,
        input  logic [WIDTH_LAYER-1 : 0]                    iLayer,
        input  logic                                        validIn,
        input  logic [WIDTH_ITERATION - 1 : 0]              currIter,
        input  logic [NUM_CHKN_LLRS_INOUT - 1 : 0]          activeCols,
        input  logic [NUM_CHKN_LLRS_INOUT*WIDTH_LLR -1 : 0] llrNew,
        input  logic [NUM_CHKN_LLRS_INOUT*WIDTH_LLR -1 : 0] etaSumIn,
        output logic [NUM_CHKN_LLRS_INOUT*WIDTH_LLR -1 : 0] EtaSumOut,
        output logic                                        ValidOut
    );

    logic valid_out_find_min1_min2;
    //assign ValidOut = valid_out_find_min1_min2;
    always @ (posedge clk) begin
        ValidOut <= valid_out_find_min1_min2;
    end
    
    localparam signed [WIDTH_LLR-1 : 0] max_val = { 1'b0, {(WIDTH_LLR-1){1'b1}}}; //-2**(WIDTH_LLR-1);
    logic [WIDTH_LLR-1:0] llr_new [0:NUM_CHKN_LLRS_INOUT-1];
    logic [WIDTH_LLR-1:0] eta_sum_in [0:NUM_CHKN_LLRS_INOUT-1];
    logic [WIDTH_LLR-1:0] eta_sum_out [0:NUM_CHKN_LLRS_INOUT-1];
    for (genvar ix = 0; ix < NUM_CHKN_LLRS_INOUT; ix = ix + 1) begin
        assign llr_new[ix]    = (activeCols[ix] == 1'b0)? max_val : llrNew [((1+ix)*WIDTH_LLR)-1 -: WIDTH_LLR ];
        assign eta_sum_in[ix] = etaSumIn [((1+ix)*WIDTH_LLR)-1  -: WIDTH_LLR ];
        assign EtaSumOut [((1+ix)*WIDTH_LLR)-1 : ix*WIDTH_LLR ] = eta_sum_out[ix];
    end

    logic [WIDTH_LLR-1:0] min1_mem [0:NUM_LAYERS-1];
    logic [WIDTH_LLR-1:0] min2_mem [0:NUM_LAYERS-1];
    logic [WIDTH_LLR-1:0] min1_read, min2_read, min1_write, min2_write;
    always@(posedge clk) begin
        if (validIn) begin
            min1_read        <= min1_mem[iLayer];
            min2_read        <= min2_mem[iLayer];
        end else if (valid_out_find_min1_min2) begin
            min1_mem[iLayer] <= min1_write;
            min2_mem[iLayer] <= min2_write;
        end
    end

    logic [WIDTH_CHKN_IDX-1:0] min1_idx_mem [0:NUM_LAYERS-1];
    logic [WIDTH_CHKN_IDX-1:0] min1_idx_read;
    logic [WIDTH_CHKN_IDX-1:0] min1_idx_write;
    logic [NUM_COLS-1:0] llr_sgn_mem [0:NUM_LAYERS-1];
    logic [NUM_COLS-1:0] llr_sgn_read;
    logic [NUM_COLS-1:0] llr_sgn_write;
    always@(posedge clk) begin
        if (validIn)begin
            min1_idx_read        <= min1_idx_mem[iLayer];
            llr_sgn_read         <= llr_sgn_mem[iLayer];
        end else if (valid_out_find_min1_min2) begin
            min1_idx_mem[iLayer] <= min1_idx_write;
            llr_sgn_mem[iLayer]  <= llr_sgn_write;
        end
    end

    logic signed [WIDTH_LLR-1:0] eta_sum_read [0:NUM_CHKN_LLRS_INOUT-1];
    for (genvar ix = 0; ix < NUM_CHKN_LLRS_INOUT; ix = ix + 1) begin
        always_comb begin
            if(currIter == 1 | activeCols[ix] == 1'b0)begin
                eta_sum_read[ix] = { (WIDTH_LLR){1'b0} };
            end else if (llr_sgn_read[ix] == 1'b1)begin
                if (ix[WIDTH_CHKN_IDX-1:0] == min1_idx_read)
                    eta_sum_read[ix] = min2_read;
                else
                    eta_sum_read[ix] = min1_read;
            end else begin
                if (ix[WIDTH_CHKN_IDX-1:0] == min1_idx_read)
                    eta_sum_read[ix] = -min2_read;
                else
                    eta_sum_read[ix] = -min1_read;
            end
        end
    end

    logic signed [WIDTH_LLR*NUM_CHKN_LLRS_INOUT-1:0] c_add_sat;
    for (genvar ix = 0; ix < NUM_CHKN_LLRS_INOUT; ix = ix + 1) begin
        Add_Saturate_Comb #(.N(WIDTH_LLR)
                           )UUT_Add_Saturate1(
                              .a(llr_new[ix]),  // what goes here?
                              .b(eta_sum_read[ix]), // etasum_tmp can be negated to skip second negating
                              .c(c_add_sat [((NUM_CHKN_LLRS_INOUT-ix)*WIDTH_LLR)-1 : (NUM_CHKN_LLRS_INOUT-ix-1)*WIDTH_LLR ])
                          );
    end

    Find_Min1Min2_16x2 UUT_Find_Min1Min2(
                           .clk(clk),
                           .inSig(c_add_sat),
                           .validIn(validIn),
                           .outSigSgn(llr_sgn_write),
                           .MinSig1(min1_write),
                           .MinSig2(min2_write),
                           .IdxMinSig1(min1_idx_write),
                           .ValidOut(valid_out_find_min1_min2)
                       );

    logic [WIDTH_LLR-1:0] eta_sum_tmp [0:NUM_CHKN_LLRS_INOUT-1];
    always_comb begin
        for (integer ix = 0; ix < NUM_CHKN_LLRS_INOUT; ix = ix + 1) begin
            if(activeCols[ix] == 1'b0)begin
                eta_sum_tmp[ix] = {WIDTH_LLR {1'b0}};
            end else if (llr_sgn_write[ix] == 1'b1)begin
                if (ix[WIDTH_CHKN_IDX-1:0] == min1_idx_write)
                    eta_sum_tmp[ix] = -min2_write;
                else
                    eta_sum_tmp[ix] = -min1_write;
            end else begin
                if (ix[WIDTH_CHKN_IDX-1:0] == min1_idx_write)
                    eta_sum_tmp[ix] = min2_write;
                else
                    eta_sum_tmp[ix] = min1_write;
            end
        end
    end

    for (genvar ix = 0; ix < NUM_CHKN_LLRS_INOUT; ix = ix + 1) begin
        Add_Saturate_Comb #(.N(WIDTH_LLR)
                           )UUT_Add_Saturate2(
                              .a(eta_sum_in [ix]),
                              .b(eta_sum_tmp   [ix]),
                              .c(eta_sum_out   [ix])
                          );
    end

    /*
    `ifdef ICARUS_SIM0
        initial begin
            $dumpfile("dump.vcd");
            $dumpvars(10,CHKN_Single);
            for (integer ix = 0; ix < NUM_CHKN_LLRS_INOUT; ix = ix + 1) begin
                $dumpvars(0, llr_new[ix]);
                $dumpvars(0, eta_sum_in[ix]);
                $dumpvars(0, eta_sum_read[ix]);
                $dumpvars(0, UUT_Find_Min1Min2.in_sig[ix]);
            end
            for (integer ix = 0; ix < NUM_LAYERS ; ix = ix + 1) begin
                $dumpvars(0, min1_mem[ix]);
                $dumpvars(0, min2_mem[ix]);
            end
        end
    `endif
    */

endmodule
