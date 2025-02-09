module addr_gen(
    input clk,
    input rst,
    input [1:0]mode,
    input [7:0]clk_counter,
    output [6:0]coef_addr,
    output [4:0]r_addr,
    output reg [4:0]w_addr
);
`define NTT 2'd0
`define INTT 2'd1
`define MULT 2'd2
`define ADDSUB 2'd3
//coef address
reg [6:0] coef_addr_reg;
wire [7:0] clk_counter_reg;
assign clk_counter_reg = clk_counter + 2;
always@(*) begin
    case (mode)
        `NTT:begin
           if(clk_counter[7:5] == 3'd6)begin
                coef_addr_reg = 7'd64 + (clk_counter[4:0] << 1);
            end
            else begin
                coef_addr_reg = $unsigned(1 << clk_counter[7:5]) + (clk_counter[4:0] >> $unsigned(3'd5 - clk_counter[7:5]));
            end
        end
        `INTT:begin
            case(clk_counter[7:5])
            3'd0: coef_addr_reg = 7'd126 - {clk_counter[4:0], 1'b0};
            3'b1: coef_addr_reg = 7'b0111111 - clk_counter[4:0];
            3'd2: coef_addr_reg = 7'b0011111 - {clk_counter[4:2], 1'b0} - clk_counter[0];
            3'd3: coef_addr_reg = 7'b0001111 - {clk_counter[4:3], 1'b0} - clk_counter[0];
            3'd4: coef_addr_reg = 7'b0000111 - {clk_counter[4], 1'b0} - clk_counter[0];
            3'd5: coef_addr_reg = 7'b0000011 - clk_counter[0];
            default: coef_addr_reg = 7'b0000001;
            endcase
        end
        `MULT:begin
            if(clk_counter[7:1] >= 65) coef_addr_reg = 0;
            else begin
                coef_addr_reg = 8'd62 + {clk_counter_reg[7:2],1'b0}; 
            end
        end
        default:begin
            coef_addr_reg = 0;
        end 
    endcase
end
assign coef_addr = coef_addr_reg[6:0];
//read data address
reg [4:0] left_bits_raddr;
reg [4:0] right_bits_raddr;
wire [5:0] r_addr_wire;
reg [4:0] w_addr_regs[0:5];
reg [2:0] shift_bit;
always@(*) begin
    if (mode == `NTT) shift_bit = 3'd4 - clk_counter[7:5];
    else shift_bit = clk_counter[7:5] - 1;
    if(shift_bit > 3'b100)begin
        left_bits_raddr = 0;
        right_bits_raddr = clk_counter[4:0];
    end
    else begin
        left_bits_raddr = {clk_counter[4:1] >> shift_bit, clk_counter[0]} << shift_bit;
        right_bits_raddr = clk_counter[4:1] & ((1 << shift_bit) - 1);
    end
end
assign r_addr_wire = left_bits_raddr + right_bits_raddr;
assign r_addr = r_addr_wire[4:0];
//write data address
always@(posedge clk or posedge rst)begin
    if(rst) begin
        w_addr_regs[0] <= 0;
        w_addr_regs[1] <= 0;
        w_addr_regs[2] <= 0;
        w_addr_regs[3] <= 0;
        w_addr_regs[4] <= 0;
        w_addr_regs[5] <= 0;
    end
    begin
        w_addr_regs[0] <= r_addr_wire[4:0];
        w_addr_regs[1] <= w_addr_regs[0];
        w_addr_regs[2] <= w_addr_regs[1];
        w_addr_regs[3] <= w_addr_regs[2];
        w_addr_regs[4] <= w_addr_regs[3];
        w_addr_regs[5] <= w_addr_regs[4];
    end
end
always@(*)begin
    case(mode)
    `NTT, `INTT: w_addr = w_addr_regs[5];
    `MULT: w_addr = clk_counter[7:2] - 3;
    `ADDSUB: w_addr = clk_counter[7:1] - 2;
    endcase
end
//assign w_addr = mode == `MULT? clk_counter[7:2] - 3 : w_addr_regs[5];
endmodule