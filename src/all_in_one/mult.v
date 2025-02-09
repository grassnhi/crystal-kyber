`include "reduce.v"

module mult(
    input clk,
    input rst,
    input [11:0] in1,
    input [11:0]in2,
    output [11:0] res
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
    wire [23:0] product;
    assign product = reg1*reg2;
    reg [23:0] product_reg;
    always @(posedge clk)begin
        product_reg <= product;
    end
    reduce mod(clk, rst, product_reg, res);
endmodule