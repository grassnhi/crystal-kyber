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
    reg [23:0] dsp_reg[0:3];
    integer i;
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
    always @(posedge clk or posedge rst)begin
        if(rst)begin
            for(i = 0; i < 4; i++)begin
                dsp_reg[i] <= 0;
            end
        end
        else begin
            dsp_reg[0] <= product;
            for(i = 1; i < 3; i++)begin
                dsp_reg[i] <= dsp_reg[i-1];
            end
        end
        
    end
    reduce mod(clk, rst, dsp_reg[2], res);
endmodule