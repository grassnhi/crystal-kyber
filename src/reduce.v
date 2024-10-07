`include "sub.v"
module K_2REG_reduce(
    output [11:0]res,
    input [23:0] in,
    input clk,
    input rst
);
    reg [15:0]Cl1;
    reg [15:0]Ch1;
    reg [15:0]Cl2;
    reg [15:0]Ch2;
    wire [23:0]C1;
    wire [23:0]C2;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            Cl1 <= 0;
            Ch1 <= 0;
        end
        else 
        begin
            Cl1 <= {8'b0, in[7:0]}*13;
            Ch1 <= in[23:8];
        end
    end 
    assign C1 = Cl1 - Ch1;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            Cl2 <= 0;
            Ch2 <= 0; 
        end
        else
        begin
            Cl2 <= {8'b0, C1[7:0]}*13;
            Ch2 <= C1[23:8]; 
        end
    end
    assign C2 = Cl2 - Ch2;
    assign res = C2[12] ? C2[11:0]+3329 : (C2[11:0]>=3329 ? C2[11:0] - 3329 : C2[11:0]);
endmodule