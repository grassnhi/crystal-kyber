module sub(
    input clk,
    input rst,
    input [1:0] mode,
    input[11:0] in1,
    input[11:0] in2,
    output reg [11:0] res
);
`define  NORMAL 2'd0
`define  DIV_2 2'd1
wire [12:0] diff;
reg [12:0] reduce_diff;
assign diff = in1 - in2;
reg [1:0] mode_reg[0:1];
always @(posedge clk or posedge rst) begin
    if(rst) reduce_diff <= 0;
    else begin
        if(diff[12] == 1) begin
            reduce_diff <= diff[11:0] + 12'd3329; 
        end
        else begin
            reduce_diff <= diff;
        end
        if(mode_reg[1] == 2'd1)begin
            if(reduce_diff[0] == 1) res <= reduce_diff[11:1] + 12'd1665;
            else res <= reduce_diff[11:1];
        end
        else res <= reduce_diff[11:0];
    end
end
always@(posedge clk or posedge rst)begin
    if(rst)begin
        mode_reg[0] <= 0;
        mode_reg[1] <= 0;
    end
    else begin
        mode_reg[0] <= mode;
        mode_reg[1] <= mode_reg[0];
    end
end
endmodule