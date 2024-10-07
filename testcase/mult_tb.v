`include "mult.v"
`timescale 1ns/1ns
module mult_tb;
wire [11:0]out;
reg clk;
reg rst;
reg [11:0]in1;
reg [11:0]in2;
mult mult_ut(out, in1, in2, clk, rst);
initial begin
    $dumpfile("mult_tb.vcd");
    $dumpvars(0, mult_tb);
    rst = 1;
    #5
    rst = 0;
    in1 = 10;
    in2 = 300;
    #20
    in1 = 3300;
    in2 = 3290;
    #20
    in1 = 3000;
    in2 = 3111;
    #20
    in1 = 200;
    in2 = 10;
    #5
    rst = 1;
    #20
    $finish;
end
initial begin
    clk = 0;
    forever begin
        #2 clk = ~clk;
    end
end
endmodule