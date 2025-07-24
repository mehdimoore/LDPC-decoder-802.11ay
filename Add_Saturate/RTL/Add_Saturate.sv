/////////////////////////////////////
/////////////////////////////////////
module Add_Saturate_Comb #(parameter N = 8)
  (
    input  logic signed [N-1:0]a,
    input  logic signed [N-1:0]b,
    output logic signed [N-1:0]c
  );

  wire signed [N:0] c_tmp;
  assign c_tmp = {a[N-1],a} + {b[N-1], b};
  always@*begin
    case (c_tmp[N:N-1])
      2'b01  : c = {1'b0, {(N-1){1'b1}}}; //in_max;
      2'b10  : c = {1'b1, {(N-1){1'b0}}}; //in_min;
      default: c = c_tmp[N-1:0];
    endcase
  end
endmodule




module Add_Saturate_Clk #(parameter N = 8)
  (
    input  logic               clk,
    input  logic signed [N-1:0]a,
    input  logic signed [N-1:0]b,
    output logic signed [N-1:0]c
  );

  wire signed [N:0] c_tmp;
  assign c_tmp = {a[N-1],a} + {b[N-1], b};
  always@ (posedge clk) begin
    case (c_tmp[N:N-1])
      2'b01  : c = {1'b0, {(N-1){1'b1}}}; //in_max;
      2'b10  : c = {1'b1, {(N-1){1'b0}}}; //in_min;
      default: c = c_tmp[N-1:0];
    endcase
  end
endmodule