`timescale 1ns/1ns
`include "add.v"

module add_tb;
wire [11:0]out;
reg clk;
reg [11:0]in1;
reg [11:0]in2;
reg [1:0] mode;
add add_ut(out, in1, in2, mode);
initial begin
    $dumpfile("add_tb.vcd");
    $dumpvars(0, add_tb);
    #10
    in1 = 10;
    in2 = 301;
    mode = 1;
    #10
    in1 = 3300;
    in2 = 29;
    mode = 1;
    #10
    in1 = 0;
    in2 = 50;
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