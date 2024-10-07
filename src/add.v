module add(
    output[11:0] res,
    input[11:0] in1,
    input[11:0] in2,
    input[1:0] mode
);
wire [12:0] sum;
wire [11:0] reduce_sum;
assign sum = in1 + in2;
assign reduce_sum = sum >= 3329 ? sum - 12'd3329 : sum;
assign res = mode == 2'd1 ? (reduce_sum[0] ? reduce_sum[11:1] + 12'd1665 : reduce_sum[11:1]): reduce_sum;
endmodule