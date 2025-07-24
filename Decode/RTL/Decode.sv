`timescale 1ns/10ps
`include "../../LDPC_Params/LDPC_Params.svh"
module Decode(
        input  logic                          clk,
        input  logic                          reset,
        input  logic [WIDTH_RATE-1:0]         rate,
        input  logic [WIDTH_ITERATION-1 : 0]  iterMax,
        input  logic [Z*WIDTH_LLR-1:0]        llrIn,
        input  logic                          llrInLast,
        input  logic [WIDTH_ROW_WEIGHT-1 : 0] llrInCnt,
        input  logic                          validIn,
        output logic [Z-1:0]                  DataWord,
        output logic signed [7:0]             OutCount,
        output logic                          ValidOut,
        output logic                          ReadyOut
    );

    logic signed [WIDTH_LLR-1:0] llr_in  [NUM_COLS ][Z];
    logic signed [WIDTH_LLR-1:0] llr_new [NUM_COLS ][Z];
    logic signed [WIDTH_LLR-1:0] eta_sum [NUM_COLS ][Z];
    always@(posedge clk) begin
        for (integer i_z = 0; i_z < Z; i_z = i_z+1) begin
            if (validIn) begin
                llr_in[llrInCnt][i_z]  <= llrIn[((1+i_z)*WIDTH_LLR)-1 -: WIDTH_LLR ];
            end
        end
    end
    //------------------------------------------------------
    //------------------ Instantiate Init ------------------
    //------------------------------------------------------
    logic [WIDTH_LAYER-1:0]                          NumLayers_w;
    logic [NUM_COLS * WIDTH_ROW_WEIGHT-1:0]          RowWeight_w;
    logic [WIDTH_Z*NUM_LAYERS*NUM_COLS-1:0]          IdxRot_w;
    logic [2*NUM_LAYERS*NUM_COLS-1:0]                  FirstInCol_w;
    Init UUT_Init(
             .clk       (clk),
             .reset     (reset),
             .rate      (rate),
             .NumLayers (NumLayers_w),
             .RowWeight (RowWeight_w),  // is this required?
             .IdxRot    (IdxRot_w),
             .FirstInCol(FirstInCol_w)
         );

    logic [WIDTH_ROW_WEIGHT-1:0]        col_no[0:NUM_LAYERS-1] [0:NUM_COLS-1];
    logic [WIDTH_Z-1:0]                 idx_rot[0:NUM_LAYERS-1] [0:NUM_COLS-1];
    logic signed [1:0]                  first_in_col[0:NUM_LAYERS-1][0:NUM_COLS-1];
    logic [NUM_CHKN_LLRS_INOUT - 1 : 0] active_cols;
    for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
        for (genvar i_l = 0; i_l < NUM_LAYERS; i_l = i_l + 1) begin
            //assign idx_rot      [i_l][i_col] = IdxRot_w [(i_l*NUM_COLS +  i_col +1)*WIDTH_Z-1 -: WIDTH_Z];
            assign first_in_col [i_l][i_col] = FirstInCol_w [((i_l*NUM_COLS +  i_col +1)*2)-1 -: 2];
        end
    end

    logic [WIDTH_LAYER-1 : 0]     curr_layer;  //TODO: is this used?
    for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
        assign active_cols[i_col] = first_in_col [curr_layer][i_col] >= 0;
    end

    //------------------------------------------------------
    //--------------------- FSM Engine ---------------------
    //------------------------------------------------------
    logic [WIDTH_ITERATION-1 : 0] curr_iter;   //TODO: is this used?
    logic copy_llr_in_2_llr_new;
    logic chk_n_input_valid, var_n_input_valid;

    FSM_Engine UUT_FSM (
                   .clk              (clk),
                   .reset            (reset),
                   .llrInLast        (llrInLast),
                   .validIn          (validIn),
                   .rate             (rate),
                   .syndrome         (1'b1),  //TODO
                   .iterMax          (iterMax),
                   .CurrLayer        (curr_layer),
                   .CurrIter         (curr_iter),
                   .CopyLLRIn2LLRNew (copy_llr_in_2_llr_new),
                   .ChkNInputValid   (chk_n_input_valid),
                   .VarNInputValid   (var_n_input_valid)
               );

    logic [NUM_CHKN_LLRS_INOUT*WIDTH_LLR -1 : 0] llr_in_chk_n [0:Z-1];
    logic [NUM_CHKN_LLRS_INOUT*WIDTH_LLR -1 : 0] eta_sum_in_chk_n [0:Z-1];
    logic [NUM_CHKN_LLRS_INOUT*WIDTH_LLR -1 : 0] eta_sum_out_chk_n [0:Z-1];
    logic                                        chk_n_output_valid [0:Z-1];
    for (genvar i_z = 0; i_z < Z; i_z = i_z + 1) begin: genCHKN
        CHKN_Single UUT_CHKN (
                        .clk        (clk),
                        .reset      (reset),
                        .iLayer     (curr_layer),
                        .validIn    (chk_n_input_valid),
                        .currIter   (curr_iter),
                        .activeCols (active_cols),
                        .llrNew     (llr_in_chk_n[i_z]),     //llr_in_tmp
                        .etaSumIn   (eta_sum_in_chk_n[i_z]), //eta_sum_in_tmp
                        .EtaSumOut  (eta_sum_out_chk_n[i_z]), //eta_sum_out_tmp
                        .ValidOut   (chk_n_output_valid[i_z])
                    );
    end

    logic [WIDTH_LLR-1:0] llr_in_tmp      [0:NUM_COLS-1][0:Z-1];
    logic [WIDTH_LLR-1:0] eta_sum_in_tmp  [0:NUM_COLS-1][0:Z-1];
    logic [WIDTH_LLR-1:0] eta_sum_out_tmp [0:NUM_COLS-1][0:Z-1];
    for (genvar i_z = 0; i_z < Z; i_z = i_z + 1) begin // pack/unpack for/for
        for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
            assign llr_in_chk_n [i_z][((i_col + 1)*WIDTH_LLR)-1 : i_col*WIDTH_LLR ]   = llr_in_tmp [i_col][i_z];
            assign eta_sum_in_chk_n [i_z][((i_col+1)*WIDTH_LLR)-1 : i_col*WIDTH_LLR ] = eta_sum_in_tmp  [i_col][i_z];
            assign eta_sum_out_tmp  [i_col][i_z]                                      = eta_sum_out_chk_n [i_z][((i_col+1)*WIDTH_LLR)-1 : i_col*WIDTH_LLR ];
        end
    end

    //------------------------------------------------------
    //--------- get llr_new_tmp and eta_sum_new ------------
    //------------------------------------------------------
    /*
    logic [WIDTH_Z-1:0]          idx_rot_tmp [0:NUM_COLS-1];
    for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
      assign idx_rot_tmp[i_col] = idx_rot[curr_layer][i_col];
    end

    logic [WIDTH_Z-1:0] i_z_rot[0:NUM_COLS-1][0:Z-1];
    for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
      for (genvar i_z = 0; i_z < Z; i_z = i_z + 1) begin
        assign i_z_rot[i_col][i_z] = modAdd_Z(idx_rot_tmp[i_col],i_z[WIDTH_Z-1:0]);
      end
    end

      for (genvar i_z = 0; i_z < Z; i_z = i_z + 1) begin
          for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
              always@(posedge clk) begin
                  if (chk_n_input_valid) begin
                      llr_in_tmp [i_col][i_z] = llr_new[i_col][i_z_rot[i_col][i_z]];
                  end
              end
          end
      end */
    `include "../RTL/INCLUDE_LLR_IN_TMP.sv"

    /* for (genvar i_z = 0; i_z < Z; i_z = i_z + 1) begin
        for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
            always@(posedge clk) begin
                if (chk_n_output_valid[i_z] & active_cols[i_col]) begin
                    eta_sum [i_col] [i_z_rot[i_col][i_z]] <= eta_sum_out_tmp [i_col][i_z];
                end
            end
        end
    end */
    `include "../RTL/INCLUDE_ETA_SUM.sv"


    logic [NUM_COLS-1:0] eta_sum_tmp_write_flg;
    logic [NUM_COLS-1:0] eta_sum_tmp_write_zero_flg;
    for (genvar i_col = 0; i_col<NUM_COLS; i_col = i_col+1)begin
        assign eta_sum_tmp_write_zero_flg[i_col] = (chk_n_input_valid ) & ((first_in_col[curr_layer][i_col] == 1 || first_in_col[curr_layer][i_col] == -1));
        assign eta_sum_tmp_write_flg[i_col] = (chk_n_input_valid ) & (first_in_col[curr_layer][i_col] == 0);
    end
    /*
        for (genvar i_z = 0; i_z < Z; i_z = i_z + 1) begin
            for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
                always@(posedge clk) begin
                    if(eta_sum_tmp_write_zero_flg[i_col]) begin
                        eta_sum_in_tmp [i_col][i_z] = 0;
                    end else if (eta_sum_tmp_write_flg[i_col])begin
                        eta_sum_in_tmp [i_col][i_z] = eta_sum[i_col][i_z_rot[i_col][i_z]];
                    end
                end
            end
        end */
    `include "../RTL/INCLUDE_ETA_SUM_TMP.sv"

    //------------------------------------------------------
    //------------------- update llr_new -------------------
    //------------------------------------------------------
    logic [WIDTH_LLR-1:0] tmp_mux_out [0:NUM_COLS-1][0:Z-1];
    for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
        for (genvar i_z = 0; i_z < Z; i_z = i_z + 1) begin
            always_latch begin
                if(copy_llr_in_2_llr_new) begin
                    tmp_mux_out[i_col][i_z] = {WIDTH_LLR {1'b0}};
                end else if (var_n_input_valid) begin
                    tmp_mux_out[i_col][i_z] = eta_sum[i_col][i_z];
                end
            end
        end
    end
    for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
        for (genvar i_z = 0; i_z < Z; i_z = i_z + 1) begin
            Add_Saturate_Clk #(.N(WIDTH_LLR)
                              ) UUT_Add_Saturate(
                                 .clk(clk),
                                 .a(llr_in[i_col][i_z]),
                                 .b(tmp_mux_out[i_col][i_z]),
                                 .c(llr_new[i_col][i_z]));
        end
    end

    //------------------------------------------------------
    //---------------------- ReadyOut ----------------------
    //------------------------------------------------------
    always@(negedge clk)begin
        if (reset | out_state_flg ) begin
            ReadyOut <= 1'b1;
        end else if (llrInLast) begin
            ReadyOut <= 1'b0;
        end 
    end


    //------------------------------------------------------
    //-------------------- Hard Decoding -------------------
    //------------------------------------------------------
    logic out_state_flg;
    always @(posedge clk)begin
        if (reset)begin
            OutCount        <= -1;
            out_state_flg   <= 1'b0;
            ValidOut        <= 1'b0;
        end else if (curr_iter == iterMax + 1'b1 & out_state_flg == 1'b0) begin
            for (integer idx = 0; idx<Z; idx++)begin
                DataWord[0]      <= (llr_new[0][idx] > 0) ? 1'b0:1'b1;
            end
            //ValidOut        <= 1'b1;
            out_state_flg   <= 1'b1;
            OutCount        <= 0;
        end else if (out_state_flg == 1'b1 && OutCount<8) begin
            for (integer idx = 0; idx<Z; idx++)begin
                /* verilator lint_off WIDTH */
                DataWord[idx]      <= (llr_new[OutCount][idx] > 0) ? 1'b0:1'b1;
            end
            ValidOut      <= 1'b1;
            OutCount      <= OutCount + 1'b1;
        end else if (out_state_flg == 1'b1 && OutCount==8) begin
            ValidOut        <= 1'b0;
            out_state_flg   <= 1'b0;
            OutCount        <= -1;
        end
    end

endmodule
