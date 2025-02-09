module add(
    input clk,
    input rst,
    input [1:0] mode,
    input  [11:0] in1,
    input  [11:0] in2,
    output reg [11:0] res
);

wire [12:0] sum;
assign sum = in1 + in2;  // Direct addition, no need for reg
reg [12:0] reduce_sum;
reg [1:0] mode_reg[0:2];
// Reduce sum conditional
always@(posedge clk or posedge rst)begin
    if(rst) reduce_sum <= 0;
    else begin
        if(sum < 13'd3329)begin
            reduce_sum <= sum;
        end
        else begin
            reduce_sum <= sum[11:0] - 12'd3329;
        end
        if(mode_reg[1] == 2'd1)begin
            if(reduce_sum[0] == 1) res <= reduce_sum[11:1] + 12'd1665;
            else res <= reduce_sum[11:1];
        end
        else res <= reduce_sum[11:0];
    end
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        mode_reg[0] <= 0;
        mode_reg[1] <= 0;
        mode_reg[2] <= 0;
    end
    else begin
        mode_reg[0] <= mode;
        mode_reg[1] <= mode_reg[0];
    end
end
endmodule
