`include "../../LDPC_Params/LDPC_Params.svh"
module Init (
    input  logic                                    clk,
    input  logic                                    reset,
    input  logic [WIDTH_RATE-1:0]                   rate,
    output logic [WIDTH_LAYER-1:0]                  NumLayers,
    output logic [NUM_COLS * WIDTH_ROW_WEIGHT-1:0]  RowWeight,  // is this required?
    output logic [WIDTH_Z*NUM_LAYERS*NUM_COLS-1:0]  IdxRot,
    output logic [2*NUM_LAYERS*NUM_COLS-1:0]        FirstInCol
  );
  enum logic [WIDTH_RATE-1:0]{
         rate_1_2 = 0,
         rate_3_4,
         rate_5_8,
         rate_13_16
       } rate_enum;

  logic [WIDTH_LAYER_CNT-1:0]  num_layers;
  logic [WIDTH_ROW_WEIGHT-1:0] row_weight[0:NUM_COLS -1];
  logic [WIDTH_Z-1:0]          idx_rot[0:NUM_LAYERS-1] [0:NUM_COLS-1];
  logic signed [1:0]           first_in_col[0:NUM_LAYERS-1] [0:NUM_COLS-1];
  //
  logic [WIDTH_LAYER_CNT-1:0]  num_layers_12;
  logic [WIDTH_ROW_WEIGHT-1:0] row_weight_12[0:NUM_COLS -1];
  logic signed [WIDTH_Z-1:0]          idx_rot_12[0:NUM_LAYERS-1] [0:NUM_COLS-1];
  logic signed [1:0]                  first_in_col_12[0:NUM_LAYERS-1] [0:NUM_COLS-1];


  // assign outputs
  for (genvar i_col = 0; i_col < NUM_COLS; i_col = i_col + 1) begin
    assign RowWeight[(i_col+1) * WIDTH_ROW_WEIGHT - 1 -: WIDTH_ROW_WEIGHT] = row_weight[i_col];
    for (genvar i_l = 0; i_l < NUM_LAYERS; i_l = i_l + 1) begin
      assign IdxRot [(i_l*NUM_COLS +  i_col +1)*WIDTH_Z-1 -: WIDTH_Z] = idx_rot [i_l][i_col];
      assign FirstInCol [((i_l*NUM_COLS +  i_col +1)*2)-1 -: 2]       = first_in_col [i_l][i_col];
    end
  end

  always@(posedge clk) begin
    case(rate)
      default: begin
        num_layers <= num_layers_12;
        for (integer i_col = 0; i_col < NUM_COLS; i_col = i_col+1) begin
          row_weight [i_col]            <= row_weight_12[i_col];
          for (integer i_l = 0; i_l < NUM_LAYERS; i_l = i_l+1) begin
            idx_rot      [i_l][i_col] <= idx_rot_12      [i_l][i_col];
            first_in_col [i_l][i_col] <= first_in_col_12 [i_l][i_col];
          end
        end
      end
    endcase
  end
  // ---------------------------------- rate = '1/2' --------------------------------------- //
  assign num_layers_12 = 8;

  //layer 0
  assign row_weight_12[0] = 5;
  assign idx_rot_12      [0][0] = 40;
  assign idx_rot_12      [0][1] = -1;
  assign idx_rot_12      [0][2] = 38;
  assign idx_rot_12      [0][3] = -1;
  assign idx_rot_12      [0][4] = 13;
  assign idx_rot_12      [0][5] = -1;
  assign idx_rot_12      [0][6] = 5;
  assign idx_rot_12      [0][7] = -1;
  assign idx_rot_12      [0][8] = 18;
  assign idx_rot_12      [0][9] = -1;
  assign idx_rot_12      [0][10] = -1;
  assign idx_rot_12      [0][11] = -1;
  assign idx_rot_12      [0][12] = -1;
  assign idx_rot_12      [0][13] = -1;
  assign idx_rot_12      [0][14] = -1;
  assign idx_rot_12      [0][15] = -1;
  assign first_in_col_12 [0][0] = 1;
  assign first_in_col_12 [0][1] = -1;
  assign first_in_col_12 [0][2] = 1;
  assign first_in_col_12 [0][3] = -1;
  assign first_in_col_12 [0][4] = 1;
  assign first_in_col_12 [0][5] = -1;
  assign first_in_col_12 [0][6] = 1;
  assign first_in_col_12 [0][7] = -1;
  assign first_in_col_12 [0][8] = 1;
  assign first_in_col_12 [0][9] = -1;
  assign first_in_col_12 [0][10] = -1;
  assign first_in_col_12 [0][11] = -1;
  assign first_in_col_12 [0][12] = -1;
  assign first_in_col_12 [0][13] = -1;
  assign first_in_col_12 [0][14] = -1;
  assign first_in_col_12 [0][15] = -1;

  //layer 1
  assign row_weight_12[1] = 6;
  assign idx_rot_12      [1][0] = 34;
  assign idx_rot_12      [1][1] = -1;
  assign idx_rot_12      [1][2] = 35;
  assign idx_rot_12      [1][3] = -1;
  assign idx_rot_12      [1][4] = 27;
  assign idx_rot_12      [1][5] = -1;
  assign idx_rot_12      [1][6] = -1;
  assign idx_rot_12      [1][7] = 30;
  assign idx_rot_12      [1][8] = 2;
  assign idx_rot_12      [1][9] = 1;
  assign idx_rot_12      [1][10] = -1;
  assign idx_rot_12      [1][11] = -1;
  assign idx_rot_12      [1][12] = -1;
  assign idx_rot_12      [1][13] = -1;
  assign idx_rot_12      [1][14] = -1;
  assign idx_rot_12      [1][15] = -1;
  assign first_in_col_12 [1][0] = 0;
  assign first_in_col_12 [1][1] = -1;
  assign first_in_col_12 [1][2] = 0;
  assign first_in_col_12 [1][3] = -1;
  assign first_in_col_12 [1][4] = 0;
  assign first_in_col_12 [1][5] = -1;
  assign first_in_col_12 [1][6] = -1;
  assign first_in_col_12 [1][7] = 1;
  assign first_in_col_12 [1][8] = 0;
  assign first_in_col_12 [1][9] = 1;
  assign first_in_col_12 [1][10] = -1;
  assign first_in_col_12 [1][11] = -1;
  assign first_in_col_12 [1][12] = -1;
  assign first_in_col_12 [1][13] = -1;
  assign first_in_col_12 [1][14] = -1;
  assign first_in_col_12 [1][15] = -1;

  //layer 2
  assign row_weight_12[2] = 6;
  assign idx_rot_12      [2][0] = -1;
  assign idx_rot_12      [2][1] = 36;
  assign idx_rot_12      [2][2] = -1;
  assign idx_rot_12      [2][3] = 31;
  assign idx_rot_12      [2][4] = -1;
  assign idx_rot_12      [2][5] = 7;
  assign idx_rot_12      [2][6] = -1;
  assign idx_rot_12      [2][7] = 34;
  assign idx_rot_12      [2][8] = -1;
  assign idx_rot_12      [2][9] = 10;
  assign idx_rot_12      [2][10] = 41;
  assign idx_rot_12      [2][11] = -1;
  assign idx_rot_12      [2][12] = -1;
  assign idx_rot_12      [2][13] = -1;
  assign idx_rot_12      [2][14] = -1;
  assign idx_rot_12      [2][15] = -1;
  assign first_in_col_12 [2][0] = -1;
  assign first_in_col_12 [2][1] = 1;
  assign first_in_col_12 [2][2] = -1;
  assign first_in_col_12 [2][3] = 1;
  assign first_in_col_12 [2][4] = -1;
  assign first_in_col_12 [2][5] = 1;
  assign first_in_col_12 [2][6] = -1;
  assign first_in_col_12 [2][7] = 0;
  assign first_in_col_12 [2][8] = -1;
  assign first_in_col_12 [2][9] = 0;
  assign first_in_col_12 [2][10] = 1;
  assign first_in_col_12 [2][11] = -1;
  assign first_in_col_12 [2][12] = -1;
  assign first_in_col_12 [2][13] = -1;
  assign first_in_col_12 [2][14] = -1;
  assign first_in_col_12 [2][15] = -1;

  //layer 3
  assign row_weight_12[3] = 6;
  assign idx_rot_12      [3][0] = -1;
  assign idx_rot_12      [3][1] = 27;
  assign idx_rot_12      [3][2] = -1;
  assign idx_rot_12      [3][3] = 18;
  assign idx_rot_12      [3][4] = -1;
  assign idx_rot_12      [3][5] = 12;
  assign idx_rot_12      [3][6] = 20;
  assign idx_rot_12      [3][7] = -1;
  assign idx_rot_12      [3][8] = -1;
  assign idx_rot_12      [3][9] = -1;
  assign idx_rot_12      [3][10] = 15;
  assign idx_rot_12      [3][11] = 6;
  assign idx_rot_12      [3][12] = -1;
  assign idx_rot_12      [3][13] = -1;
  assign idx_rot_12      [3][14] = -1;
  assign idx_rot_12      [3][15] = -1;
  assign first_in_col_12 [3][0] = -1;
  assign first_in_col_12 [3][1] = 0;
  assign first_in_col_12 [3][2] = -1;
  assign first_in_col_12 [3][3] = 0;
  assign first_in_col_12 [3][4] = -1;
  assign first_in_col_12 [3][5] = 0;
  assign first_in_col_12 [3][6] = 0;
  assign first_in_col_12 [3][7] = -1;
  assign first_in_col_12 [3][8] = -1;
  assign first_in_col_12 [3][9] = -1;
  assign first_in_col_12 [3][10] = 0;
  assign first_in_col_12 [3][11] = 1;
  assign first_in_col_12 [3][12] = -1;
  assign first_in_col_12 [3][13] = -1;
  assign first_in_col_12 [3][14] = -1;
  assign first_in_col_12 [3][15] = -1;

  //layer 4
  assign row_weight_12[4] = 7;
  assign idx_rot_12      [4][0] = 35;
  assign idx_rot_12      [4][1] = -1;
  assign idx_rot_12      [4][2] = 41;
  assign idx_rot_12      [4][3] = -1;
  assign idx_rot_12      [4][4] = 40;
  assign idx_rot_12      [4][5] = -1;
  assign idx_rot_12      [4][6] = 39;
  assign idx_rot_12      [4][7] = -1;
  assign idx_rot_12      [4][8] = 28;
  assign idx_rot_12      [4][9] = -1;
  assign idx_rot_12      [4][10] = -1;
  assign idx_rot_12      [4][11] = 3;
  assign idx_rot_12      [4][12] = 28;
  assign idx_rot_12      [4][13] = -1;
  assign idx_rot_12      [4][14] = -1;
  assign idx_rot_12      [4][15] = -1;
  assign first_in_col_12 [4][0] = 0;
  assign first_in_col_12 [4][1] = -1;
  assign first_in_col_12 [4][2] = 0;
  assign first_in_col_12 [4][3] = -1;
  assign first_in_col_12 [4][4] = 0;
  assign first_in_col_12 [4][5] = -1;
  assign first_in_col_12 [4][6] = 0;
  assign first_in_col_12 [4][7] = -1;
  assign first_in_col_12 [4][8] = 0;
  assign first_in_col_12 [4][9] = -1;
  assign first_in_col_12 [4][10] = -1;
  assign first_in_col_12 [4][11] = 0;
  assign first_in_col_12 [4][12] = 1;
  assign first_in_col_12 [4][13] = -1;
  assign first_in_col_12 [4][14] = -1;
  assign first_in_col_12 [4][15] = -1;

  //layer 5
  assign row_weight_12[5] = 7;
  assign idx_rot_12      [5][0] = 29;
  assign idx_rot_12      [5][1] = -1;
  assign idx_rot_12      [5][2] = 0;
  assign idx_rot_12      [5][3] = -1;
  assign idx_rot_12      [5][4] = -1;
  assign idx_rot_12      [5][5] = 22;
  assign idx_rot_12      [5][6] = -1;
  assign idx_rot_12      [5][7] = 4;
  assign idx_rot_12      [5][8] = -1;
  assign idx_rot_12      [5][9] = 28;
  assign idx_rot_12      [5][10] = -1;
  assign idx_rot_12      [5][11] = 27;
  assign idx_rot_12      [5][12] = -1;
  assign idx_rot_12      [5][13] = 23;
  assign idx_rot_12      [5][14] = -1;
  assign idx_rot_12      [5][15] = -1;
  assign first_in_col_12 [5][0] = 0;
  assign first_in_col_12 [5][1] = -1;
  assign first_in_col_12 [5][2] = 0;
  assign first_in_col_12 [5][3] = -1;
  assign first_in_col_12 [5][4] = -1;
  assign first_in_col_12 [5][5] = 0;
  assign first_in_col_12 [5][6] = -1;
  assign first_in_col_12 [5][7] = 0;
  assign first_in_col_12 [5][8] = -1;
  assign first_in_col_12 [5][9] = 0;
  assign first_in_col_12 [5][10] = -1;
  assign first_in_col_12 [5][11] = 0;
  assign first_in_col_12 [5][12] = -1;
  assign first_in_col_12 [5][13] = 1;
  assign first_in_col_12 [5][14] = -1;
  assign first_in_col_12 [5][15] = -1;

  //layer 6
  assign row_weight_12[6] = 7;
  assign idx_rot_12      [6][0] = -1;
  assign idx_rot_12      [6][1] = 31;
  assign idx_rot_12      [6][2] = -1;
  assign idx_rot_12      [6][3] = 23;
  assign idx_rot_12      [6][4] = -1;
  assign idx_rot_12      [6][5] = 21;
  assign idx_rot_12      [6][6] = -1;
  assign idx_rot_12      [6][7] = 20;
  assign idx_rot_12      [6][8] = -1;
  assign idx_rot_12      [6][9] = -1;
  assign idx_rot_12      [6][10] = 12;
  assign idx_rot_12      [6][11] = -1;
  assign idx_rot_12      [6][12] = -1;
  assign idx_rot_12      [6][13] = 0;
  assign idx_rot_12      [6][14] = 13;
  assign idx_rot_12      [6][15] = -1;
  assign first_in_col_12 [6][0] = -1;
  assign first_in_col_12 [6][1] = 0;
  assign first_in_col_12 [6][2] = -1;
  assign first_in_col_12 [6][3] = 0;
  assign first_in_col_12 [6][4] = -1;
  assign first_in_col_12 [6][5] = 0;
  assign first_in_col_12 [6][6] = -1;
  assign first_in_col_12 [6][7] = 0;
  assign first_in_col_12 [6][8] = -1;
  assign first_in_col_12 [6][9] = -1;
  assign first_in_col_12 [6][10] = 0;
  assign first_in_col_12 [6][11] = -1;
  assign first_in_col_12 [6][12] = -1;
  assign first_in_col_12 [6][13] = 0;
  assign first_in_col_12 [6][14] = 1;
  assign first_in_col_12 [6][15] = -1;

  //layer 7
  assign row_weight_12[7] = 8;
  assign idx_rot_12      [7][0] = -1;
  assign idx_rot_12      [7][1] = 22;
  assign idx_rot_12      [7][2] = -1;
  assign idx_rot_12      [7][3] = 34;
  assign idx_rot_12      [7][4] = 31;
  assign idx_rot_12      [7][5] = -1;
  assign idx_rot_12      [7][6] = 14;
  assign idx_rot_12      [7][7] = -1;
  assign idx_rot_12      [7][8] = 4;
  assign idx_rot_12      [7][9] = -1;
  assign idx_rot_12      [7][10] = -1;
  assign idx_rot_12      [7][11] = -1;
  assign idx_rot_12      [7][12] = 13;
  assign idx_rot_12      [7][13] = -1;
  assign idx_rot_12      [7][14] = 22;
  assign idx_rot_12      [7][15] = 24;
  assign first_in_col_12 [7][0] = -1;
  assign first_in_col_12 [7][1] = 0;
  assign first_in_col_12 [7][2] = -1;
  assign first_in_col_12 [7][3] = 0;
  assign first_in_col_12 [7][4] = 0;
  assign first_in_col_12 [7][5] = -1;
  assign first_in_col_12 [7][6] = 0;
  assign first_in_col_12 [7][7] = -1;
  assign first_in_col_12 [7][8] = 0;
  assign first_in_col_12 [7][9] = -1;
  assign first_in_col_12 [7][10] = -1;
  assign first_in_col_12 [7][11] = -1;
  assign first_in_col_12 [7][12] = 0;
  assign first_in_col_12 [7][13] = -1;
  assign first_in_col_12 [7][14] = 0;
  assign first_in_col_12 [7][15] = 1;

endmodule