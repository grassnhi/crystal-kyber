`include "reduce.v"

module mult(
    output [11:0] res,
    input [11:0] in1,
    input [11:0]in2,
    input clk,
    input rst
);
    reg [11:0] reg1;
    reg [11:0] reg2;
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            reg1 <= 0;
            reg2 <= 0;
        end
        else
        begin
            reg1 <= in1;
            reg2 <= in2;
        end
    end
    wire [23:0]product;
    assign product = reg1*reg2;
    K_2REG_reduce mod(res, product, clk, rst);
endmodule