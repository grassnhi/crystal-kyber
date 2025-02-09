module sub(
    input[11:0] in1,
    input[11:0] in2,
    input[1:0] mode,
    output[11:0] res
);
`define  NORMAL 2'd0
`define  DIV_2 2'd1
wire [12:0] diff;
wire [11:0] reduce_diff;
assign diff = in1 - in2;
assign reduce_diff = diff[12] == 1 ? diff + 13'd3329 : diff;
assign res = mode == `DIV_2 ?  (reduce_diff[0] ? reduce_diff[11:1] + 12'd1665 : reduce_diff[11:1]): reduce_diff;
endmodule