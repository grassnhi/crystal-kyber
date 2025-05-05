`timescale 1us/1us
`include "butterfly_core.v"

module bu_tb;
reg clk;
reg rst;
reg [1:0] mode; // 0:NTT, 1:INVNTT, 2:MULT, 3:ADDSUB
reg [11:0] in_1;
reg [11:0] in_2;
reg [11:0] coef;
wire [11:0] out_1;
wire [11:0] out_2;
butterfly_core BU(
    .clk(clk),
    .rst(rst),
    .in_1(in_1),
    .in_2(in_2),
    .coef(coef),
    .mode(mode),
    .out_1(out_1),
    .out_2(out_2)
    );
initial begin
    $dumpfile("bu_tb.vcd");
    $dumpvars(0, BU);
    #0
    rst = 1;
    mode = 0; // 0:NTT, 1:INVNTT, 2:MULT, 3:ADDSUB
    #10
    rst = 0;
    mode = 0;
    in_1 = 12'd123;
    in_2 = 12'd345;
    coef = 12'd50;
    #2
    in_1 = 12'd0;
    in_2 = 12'd345;
    coef = 12'd50;
    #2
    in_1 = 12'd50;
    in_2 = 12'd3328;
    coef = 12'd2;
    #8
    mode = 1;
    in_2 = 12'd728;
    in_1 = 12'd2847;
    coef = 12'd3279;
    #2
    in_2 = 12'd605;
    in_1 = 12'd2724;
    coef = 12'd3279;
    #2
    in_2 = 12'd48;
    in_1 = 12'd52;
    coef = 12'd3327;
    #8
    mode = 2;
    in_2 = 12'd728;
    in_1 = 12'd2847;
    coef = 12'd3279;
    #2
    in_2 = 12'd605;
    in_1 = 12'd2724;
    coef = 12'd3279;
    #2
    in_2 = 12'd48;
    in_1 = 12'd52;
    coef = 12'd3327;
    #20 $finish;
end
initial begin
    clk = 1;
    forever begin
        #1 clk = ~clk;
    end
end
endmodule