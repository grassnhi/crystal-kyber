`timescale 1ns / 1ps
 `include "add.v"
 `include "sub.v"
 `include "mult.v"

module butterfly_core(
    input clk,
    input rst,
    input [11:0] in_1,
    input [11:0] in_2,
    input [11:0] coef,
    input [1:0] mode,
    output [11:0] out_1,
    output [11:0] out_2
    );

/*
mode 0: NTT & mul_stage_2 (mul reduce -> add sub, total 5 delay)
mode 1: INVNTT (add sub -> mul reduce, total 5 delay)
mode 2: Point Wise Multiply (4 delay)
*/
`define NTT 2'd0
`define INTT 2'd1
`define MULT 2'd2
`define ADDSUB 2'd3

// mult & reduce
wire [11:0] mult_in_1;
wire [11:0] mult_in_2;
wire [11:0] mult_coef_in;
wire [11:0] mult_out_1;
wire [11:0] mult_out_2;
reg [11:0] mult_in_1_reg [0:3]; // use for timing output (delay 4 circles)
integer i;
mult multiply (
    .clk(clk),
    .rst(rst),
    .in1(mult_in_2),
    .in2(mult_coef_in),
    .res(mult_out_2)
);
always @(posedge clk or posedge rst) begin
    if (rst)begin
        for(i = 0; i < 4; i = i+1)begin
            mult_in_1_reg[i] <= 0;
        end
    end
    else begin
        mult_in_1_reg[0] <= mult_in_1;
        for(i = 1; i < 4; i = i+1)begin
            mult_in_1_reg[i] <= mult_in_1_reg[i-1];
        end
    end

end
assign mult_out_1 = mult_in_1_reg[3];

// add & sub
wire [11:0] addsub_in_1;
wire [11:0] addsub_in_2;
wire [11:0] addsub_out_1;
wire [11:0] addsub_out_2;
reg [11:0]  addsub_in_1_reg;
reg [11:0]  addsub_in_2_reg;
add addition (
    .mode(mode),
    .in1(addsub_in_1_reg),
    .in2(addsub_in_2_reg),
    .res(addsub_out_1)
);
sub subtraction (
    .mode(mode),
    .in1(addsub_in_1_reg),
    .in2(addsub_in_2_reg),
    .res(addsub_out_2)
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        addsub_in_1_reg <= 0;
        addsub_in_2_reg <= 0;
    end
    else begin
        addsub_in_1_reg <= addsub_in_1;
        addsub_in_2_reg <= addsub_in_2;
    end
end

// input select multiplexers
reg [11:0] mult_coef_in_reg;
always @(posedge clk or posedge rst) begin
    if(rst) mult_coef_in_reg <= 0;
    else mult_coef_in_reg <= coef;
end
assign mult_in_1 = mode == `INTT || mode == `ADDSUB? addsub_out_1 : in_1;
assign mult_in_2 = mode == `INTT || mode == `ADDSUB? addsub_out_2 : in_2;
assign mult_coef_in = mode == `INTT || mode == `ADDSUB? mult_coef_in_reg : coef;
assign addsub_in_1 = mode == `INTT || mode == `ADDSUB? in_1 : mult_out_1;
assign addsub_in_2 = mode == `INTT || mode == `ADDSUB? in_2 : mult_out_2;

// output select multiplexers
assign out_1 = mode == `NTT || mode == `ADDSUB? addsub_out_1 : mult_out_1;
assign out_2 = mode == `NTT || mode == `ADDSUB? addsub_out_2 : mult_out_2;

endmodule