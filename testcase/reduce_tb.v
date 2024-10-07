`timescale 1ns/1ns
module reduce_tb;
wire [11:0]out;
reg clk;
reg rst;
reg [11:0]in1;
reg [11:0]in2;
initial begin
    $dumpfile("reduce_tb.vcd");
    $dumpvars(0, reduce_tb);
    #5
    in1 = 10 - 20;
    #20
    in2 = 30 - in1;
    #20
    in2 = 30+in1;
    #20
    $finish;
end
endmodule