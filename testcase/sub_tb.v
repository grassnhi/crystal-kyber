`include "sub.v"
`timescale 1ns/1ns

module sub_tb;
wire [11:0]out;
reg clk;
reg [1:0] mode;
reg [11:0]in1;
reg [11:0]in2;
sub sub_ut(out, in1, in2, mode);
initial begin
    $dumpfile("sub_tb.vcd");
    $dumpvars(0, sub_tb);
    #10
    in1 = 10;
    in2 = 300;
    mode = 1;
    #10
    in1 = 3300;
    in2 = 29;
    mode = 1;
    #10
    in1 = 56;
    in2 = 9;
    mode = 0;
    #10
    $finish;
end
initial begin
    clk = 0;
    forever begin
        #1 clk = ~clk;
    end
end
endmodule