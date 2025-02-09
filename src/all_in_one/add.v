module add(
    input  [11:0] in1,
    input  [11:0] in2,
    input  [1:0]  mode,
    output [11:0] res
);

wire [12:0] sum;
assign sum = in1 + in2;  // Direct addition, no need for reg

// Reduce sum conditionally
wire [12:0] reduce_sum = (sum < 13'd3329) ? sum : {1'b0, sum[11:0]} + 12'd767;

// Mode-based processing
assign res = (mode == 2'd1) ? 
             ((reduce_sum[0]) ? (reduce_sum[11:1] + 12'd1665) : reduce_sum[11:1]) 
             : reduce_sum[11:0];

endmodule
