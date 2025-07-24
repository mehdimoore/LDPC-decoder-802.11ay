module Find_Min1Min2_16x2#(
    parameter WIDTH_LLR            = 8,
    parameter NUM_CHKN_LLRS_INOUT  = 16,   // number of input LLRs to Find_Min1Min2
    // ======== Calculated parameters ======== //
    parameter WIDTH_CHKN_IDX  = $clog2(NUM_CHKN_LLRS_INOUT)
  )(
    input  logic                                  clk,
    input  logic [(NUM_CHKN_LLRS_INOUT*WIDTH_LLR)-1:0] inSig,
    input  logic                                  validIn,
    output logic [NUM_CHKN_LLRS_INOUT-1 : 0]           outSigSgn,
    output logic [WIDTH_LLR-1:0]                  MinSig1,
    output logic [WIDTH_LLR-1:0]                  MinSig2,
    output logic [WIDTH_CHKN_IDX-1:0]             IdxMinSig1,
    output logic                                  ValidOut
  );

  logic signed [WIDTH_LLR-1:0] in_sig [0 : (NUM_CHKN_LLRS_INOUT-1)];
  genvar idx;
  for (idx = 0; idx<NUM_CHKN_LLRS_INOUT; idx = idx+1) begin
    assign in_sig[idx] = inSig[((NUM_CHKN_LLRS_INOUT-idx)*WIDTH_LLR)-1 : (NUM_CHKN_LLRS_INOUT-idx-1)*WIDTH_LLR];
  end

  // ******************************************************************
  // ***************** sign and abs value calculation *****************
  // ******************************************************************
  logic [NUM_CHKN_LLRS_INOUT-1 : 0] in_sig_sgn;
  logic [WIDTH_LLR-1:0]  in_sig_abs [0:NUM_CHKN_LLRS_INOUT-1];

  integer idx1;
  always@* begin
    for (idx1 = 0; idx1<NUM_CHKN_LLRS_INOUT; idx1 = idx1+1)begin
      if (in_sig[idx1]<0)begin
        in_sig_sgn[idx1] = 1'b1;
        in_sig_abs[idx1] = -in_sig[idx1];
      end else begin
        in_sig_sgn[idx1] = 1'b0;
        in_sig_abs[idx1] = in_sig[idx1];
      end
    end
  end
  logic  sgn_all;
  assign sgn_all  = ^in_sig_sgn;

  integer idx2;
  logic   [NUM_CHKN_LLRS_INOUT-1 : 0] L_out_sgn;
  always_comb begin
    for (idx2 = 0; idx2<NUM_CHKN_LLRS_INOUT; idx2 = idx2+1)begin
      outSigSgn[idx2] = in_sig_sgn[idx2] ^ sgn_all;  //assign output port
    end
  end

  // ***************** Find min1/min2 *****************
  // **************************************************
  // **************************************************
  //  layer 0
  logic [WIDTH_LLR-1:0] min1_layer0 [0:4];
  logic [WIDTH_LLR-1:0] min2_layer0 [0:4];
  logic [WIDTH_CHKN_IDX-1:0]         idx_min1_layer0 [0:3];
  logic [WIDTH_CHKN_IDX-1:0]         idx_min2_layer0 [0:3];
  Min1Min2_4x2 #(.WIDTH_LLR(WIDTH_LLR)) UUT00_Min1Min2 (
                 .inSig1     ( in_sig_abs[0]),
                 .idxIn1     ( 4'd0              ),
                 .inSig2     ( in_sig_abs[1]),
                 .idxIn2     ( 4'd1              ),
                 .inSig3     ( in_sig_abs[2]),
                 .idxIn3     ( 4'd2              ),
                 .inSig4     ( in_sig_abs[3]),
                 .idxIn4     ( 4'd3              ),
                 .MinSig1    ( min1_layer0[0]    ),
                 .IdxMinSig1 ( idx_min1_layer0[0]),
                 .MinSig2    ( min2_layer0[0]    ),
                 .IdxMinSig2 ( idx_min2_layer0[0])
               );

  Min1Min2_4x2 #(.WIDTH_LLR(WIDTH_LLR)) UUT01_Min1Min2 (
                 .inSig1     ( in_sig_abs[4]),
                 .idxIn1     ( 4'd4              ),
                 .inSig2     ( in_sig_abs[5]),
                 .idxIn2     ( 4'd5              ),
                 .inSig3     ( in_sig_abs[6]),
                 .idxIn3     ( 4'd6              ),
                 .inSig4     ( in_sig_abs[7]),
                 .idxIn4     ( 4'd7              ),
                 .MinSig1    ( min1_layer0[1]    ),
                 .IdxMinSig1 ( idx_min1_layer0[1]),
                 .MinSig2    ( min2_layer0[1]    ),
                 .IdxMinSig2 ( idx_min2_layer0[1])
               );

  Min1Min2_4x2 #(.WIDTH_LLR(WIDTH_LLR)) UUT02_Min1Min2 (
                 .inSig1     ( in_sig_abs[8]),
                 .idxIn1     ( 4'd8              ),
                 .inSig2     ( in_sig_abs[9]),
                 .idxIn2     ( 4'd9              ),
                 .inSig3     ( in_sig_abs[10]),
                 .idxIn3     ( 4'd10             ),
                 .inSig4     ( in_sig_abs[11]),
                 .idxIn4     ( 4'd11             ),
                 .MinSig1    ( min1_layer0[2]    ),
                 .IdxMinSig1 ( idx_min1_layer0[2]),
                 .MinSig2    ( min2_layer0[2]    ),
                 .IdxMinSig2 ( idx_min2_layer0[2])
               );

  Min1Min2_4x2 #(.WIDTH_LLR(WIDTH_LLR)) UUT03_Min1Min2 (
                 .inSig1     ( in_sig_abs[12]),
                 .idxIn1     ( 4'd12             ),
                 .inSig2     ( in_sig_abs[13]),
                 .idxIn2     ( 4'd13             ),
                 .inSig3     ( in_sig_abs[14]),
                 .idxIn3     ( 4'd14             ),
                 .inSig4     ( in_sig_abs[15]),
                 .idxIn4     ( 4'd15             ),
                 .MinSig1    ( min1_layer0[3]    ),
                 .IdxMinSig1 ( idx_min1_layer0[3]),
                 .MinSig2    ( min2_layer0[3]    ),
                 .IdxMinSig2 ( idx_min2_layer0[3])
               );

  //  layer 1
  logic [WIDTH_LLR-1:0] min1_layer1 [0:1];
  logic [WIDTH_LLR-1:0] min2_layer1 [0:1];
  logic [WIDTH_CHKN_IDX-1:0]         idx_min1_layer1 [0:1];
  logic [WIDTH_CHKN_IDX-1:0]         idx_min2_layer1 [0:1];
  Min1Min2_4x2 #(.WIDTH_LLR(WIDTH_LLR)) UUT10_Min1Min2  (
                 .inSig1     ( min1_layer0[0]     ),
                 .idxIn1     ( idx_min1_layer0[0] ),
                 .inSig2     ( min1_layer0[1]     ),
                 .idxIn2     ( idx_min1_layer0[1] ),
                 .inSig3     ( min1_layer0[2]     ),
                 .idxIn3     ( idx_min1_layer0[2] ),
                 .inSig4     ( min1_layer0[3]     ),
                 .idxIn4     ( idx_min1_layer0[3] ),
                 .MinSig1    ( min1_layer1[0]     ),
                 .IdxMinSig1 ( idx_min1_layer1[0] ),
                 .MinSig2    ( min2_layer1[0]     ),
                 .IdxMinSig2 ( idx_min2_layer1[0] )
               );

  Min1Min2_4x2 #(.WIDTH_LLR(WIDTH_LLR)) UUT11_Min1Min2  (
                 .inSig1     ( min2_layer0[0]     ),
                 .idxIn1     ( idx_min2_layer0[0] ),
                 .inSig2     ( min2_layer0[1]     ),
                 .idxIn2     ( idx_min2_layer0[1] ),
                 .inSig3     ( min2_layer0[2]     ),
                 .idxIn3     ( idx_min2_layer0[2] ),
                 .inSig4     ( min2_layer0[3]     ),
                 .idxIn4     ( idx_min2_layer0[3]     ),
                 .MinSig1    ( min1_layer1[1]     ),
                 .IdxMinSig1 ( idx_min1_layer1[1] ),
                 .MinSig2    ( min2_layer1[1]     ),
                 .IdxMinSig2 ( idx_min2_layer1[1] )
               );


  // layer 2/final
  logic [WIDTH_LLR-1:0]              min_sig1, min_sig2;
  logic [WIDTH_CHKN_IDX-1:0]       idx_min_sig1;
  Min1Min2_4x2 #(.WIDTH_LLR(WIDTH_LLR)) UUT20_Min1Min2  (
                 .inSig1     ( min1_layer1[0]     ),
                 .idxIn1     ( idx_min1_layer1[0] ),
                 .inSig2     ( min2_layer1[0]     ),
                 .idxIn2     ( idx_min2_layer1[0] ),
                 .inSig3     ( min1_layer1[1]     ),
                 .idxIn3     ( idx_min1_layer1[1] ),
                 .inSig4     ( min2_layer1[1]     ),
                 .idxIn4     ( idx_min2_layer1[1] ),
                 .MinSig1    ( min_sig1          ),
                 .IdxMinSig1 (idx_min_sig1),
                 .MinSig2    ( min_sig2          ),
                 .IdxMinSig2 ()
               );

  assign MinSig1    = min_sig1;
  assign MinSig2    = min_sig2;
  assign IdxMinSig1 = idx_min_sig1;

  logic[2:0] cnt;
  logic      cnt_flg;
  always@(posedge clk) begin
    ValidOut <= validIn;
  end
endmodule


module Min1Min2_4x2#(
    parameter WIDTH_LLR    = 8,
    parameter WIDTH_IDX  = 4
  )(
    input  logic [WIDTH_LLR-1 : 0] inSig1,
    input  logic [WIDTH_IDX-1 : 0] idxIn1,
    input  logic [WIDTH_LLR-1 : 0] inSig2,
    input  logic [WIDTH_IDX-1 : 0] idxIn2,
    input  logic [WIDTH_LLR-1 : 0] inSig3,
    input  logic [WIDTH_IDX-1 : 0] idxIn3,
    input  logic [WIDTH_LLR-1 : 0] inSig4,
    input  logic [WIDTH_IDX-1 : 0] idxIn4,
    // ouput
    output logic [WIDTH_LLR-1 : 0] MinSig1,
    output logic [WIDTH_IDX-1 : 0] IdxMinSig1,
    output logic [WIDTH_LLR-1 : 0] MinSig2,
    output logic [WIDTH_IDX-1 : 0] IdxMinSig2
  );

  logic [WIDTH_LLR-1:0] min1_layer11, min2_layer11, min1_layer12, min2_layer12;
  logic [WIDTH_IDX-1:0] idx_min1_layer11, idx_min2_layer11, idx_min1_layer12, idx_min2_layer12;

  //layer 1
  Min1Min2_2x1 #(
                 .WIDTH_LLR(WIDTH_LLR),
                 .WIDTH_IDX(WIDTH_IDX)
               )UUT12(
                 .inSig1(inSig1),
                 .idxIn1(idxIn1),
                 .inSig2(inSig2),
                 .idxIn2(idxIn2),
                 // ouput
                 .MinSig1(min1_layer11),
                 .IdxMin1(idx_min1_layer11),
                 .MinSig2(min2_layer11),
                 .IdxMin2(idx_min2_layer11)
               );

  Min1Min2_2x1 #(
                 .WIDTH_LLR(WIDTH_LLR),
                 .WIDTH_IDX(WIDTH_IDX)
               )UUT34(
                 .inSig1(inSig3),
                 .idxIn1(idxIn3),
                 .inSig2(inSig4),
                 .idxIn2(idxIn4),
                 // ouput
                 .MinSig1(min1_layer12),
                 .IdxMin1(idx_min1_layer12),
                 .MinSig2(min2_layer12),
                 .IdxMin2(idx_min2_layer12)
               );

  always @* begin
    if (min1_layer11 <= min1_layer12)begin
      MinSig1    = min1_layer11;
      IdxMinSig1 = idx_min1_layer11;
      if (min1_layer12 < min2_layer11 )begin
        MinSig2    = min1_layer12;
        IdxMinSig2 = idx_min1_layer12;
      end else begin
        MinSig2    = min2_layer11;
        IdxMinSig2 = idx_min2_layer11;
      end
    end else begin //(min1_layer12 < min1_layer11)
      MinSig1    = min1_layer12;
      IdxMinSig1 = idx_min1_layer12;
      if (min1_layer11 <= min2_layer12 )begin
        MinSig2    = min1_layer11;
        IdxMinSig2 = idx_min1_layer11;
      end else begin
        MinSig2    = min2_layer12;
        IdxMinSig2 = idx_min2_layer12;
      end
    end
  end

endmodule

module Min1Min2_2x1#(
    parameter WIDTH_LLR  = 8,
    parameter WIDTH_IDX  = 4
  )(
    input  logic [WIDTH_LLR-1 : 0] inSig1,
    input  logic [WIDTH_IDX-1 : 0] idxIn1,
    input  logic [WIDTH_LLR-1 : 0] inSig2,
    input  logic [WIDTH_IDX-1 : 0] idxIn2,
    // ouput
    output logic [WIDTH_LLR-1 : 0] MinSig1,
    output logic [WIDTH_IDX-1 : 0] IdxMin1,
    output logic [WIDTH_LLR-1 : 0] MinSig2,
    output logic [WIDTH_IDX-1 : 0] IdxMin2
  );

  always @* begin
    if (inSig1 <= inSig2) begin
      MinSig1       = inSig1;
      MinSig2       = inSig2;
      IdxMin1       = idxIn1;
      IdxMin2       = idxIn2;
    end else begin
      MinSig1       = inSig2;
      MinSig2       = inSig1;
      IdxMin1       = idxIn2;
      IdxMin2       = idxIn1;
    end
  end

endmodule
