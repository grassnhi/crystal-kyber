`include "addr_gen.v"
`include "butterfly.v"
`include "twiddle_factor.v"
`include "ntt_rom.v"

module ntt_processor (
    input clk,
    input rst,
    input start,
    input [1:0] mode,
    input add_or_sub,
    input [7:0]r_start_offset_A,
    input [7:0]r_start_offset_B,
    input [7:0]w_data_addr_offset,
    input [95:0] r_data,
    output [95:0] w_data,
    output [7:0] w_data_addr,
    output [7:0] r_data_addr,
    output reg w_data_en
);
`define NTT 2'd0
`define INTT 2'd1
`define MULT 2'd2
`define ADDSUB 2'd3
reg [2:0] ntt_stage;
reg ntt_type;
reg in_buf_pre_load, in_buf_load;
wire [23:0]coef_reg;
wire [95:0] but_result;
reg [7:0] clk_counter;
reg [7:0] ntt_counter;
reg [95:0] in_data_reg;
butterfly BU(
    .clk(clk),
    .rst(rst),
    .mode(mode), // mode : NTT(0) , INTT(1), PWM(2), ADDSUB(3)
    .stage(ntt_stage),
    .in_buf_pre_load(in_buf_pre_load),
    .in_buf_load(in_buf_load),
    .type(ntt_type),
    .in_data(in_data_reg),
    .in_coef(coef_reg),
    .out_data(but_result)
    );
//address generator
wire [6:0] coef_addr;
wire [4:0] r_addr, w_addr;
wire [4:0] r_addr_wire;
reg [7:0] w_addr_reg, r_addr_reg;

addr_gen AG(
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .clk_counter(ntt_counter),
    .coef_addr(coef_addr),
    .r_addr(r_addr),
    .w_addr(w_addr)
);
assign r_data_addr = r_addr_reg;
assign w_data_addr = w_addr_reg;
twiddle_factor FACTOR(
    .addr(coef_addr),
    .dout(coef_reg)
    );

wire [95:0] ROM_r_data;
rom ROM(
    .clk(clk),
    .rst(rst),
    .wdata(but_result),
    .wdata_addr(w_addr),
    .rdata_addr(r_addr_wire),
    .rdata(ROM_r_data)
);

reg [1:0]stage, temp_stage;
parameter START = 0;
parameter PROCESSING = 1;
parameter FINISH = 2;
always @(posedge clk or posedge rst)begin
    if(rst)begin
        ntt_counter <= 0;  
        stage <= START;
    end
    else begin
        ntt_counter <= clk_counter;
        stage <= temp_stage;
    end
end
//finite stage machine
always @(*) begin
    case(mode)
    `NTT, `INTT: begin
        ntt_stage = ntt_counter[7:5];
        ntt_type = ntt_counter[0];
        in_buf_pre_load = 0;
        in_buf_load = 0;
    end
    `MULT: begin
        ntt_stage = {1'b0, ntt_counter[1:0]};
        in_buf_pre_load = ntt_counter[1:0] == 2'b0;
        in_buf_load = ntt_counter[1:0] == 2'b1;
        ntt_type = mode == ntt_counter[0];
    end
    `ADDSUB: begin
        ntt_stage = {2'b0, ntt_counter[0]};
        in_buf_pre_load = ntt_counter[0] == 0;
        in_buf_load = ntt_counter[0] == 1;
        ntt_type = add_or_sub;
    end
    endcase
end
always @(*)begin
    case (stage)
        START:begin
            if(start)begin
                temp_stage = PROCESSING;
                in_data_reg = r_data;
                clk_counter = ntt_counter + 1;
            end
            else begin
                temp_stage = START;
                in_data_reg = 0;
                clk_counter = 0;
            end
            w_data_en = 0;
            w_addr_reg = w_data_addr_offset;
            r_addr_reg = r_start_offset_A;
        end
        PROCESSING: begin
            clk_counter = ntt_counter + 1;
            case(mode)
            `NTT, `INVNTT: begin
                temp_stage = ntt_counter == 8'd228 ? FINISH : PROCESSING;
                w_data_en = ntt_counter > 8'd197;
                w_addr_reg = w_data_addr_offset + w_addr;
                if(ntt_counter[7:5] == 3'b0)begin
                    in_data_reg = r_data;
                end
                else begin
                    in_data_reg = ROM_r_data;
                end
                r_addr_reg = ntt_counter[7:5] == 0? r_start_offset_A + r_addr : 0;
            end
            `MULT: begin
                temp_stage = ntt_counter == 8'd138 ? FINISH : PROCESSING;
                w_data_en = ntt_counter > 8'd107;
                in_data_reg = r_data;
                w_addr_reg = w_data_addr_offset + (ntt_counter - 8'd108);
                if (ntt_counter[0] == 0)begin
                    r_addr_reg = r_start_offset_A + ntt_counter[7:2];
                end
                else begin
                    r_addr_reg = r_start_offset_B + ntt_counter[7:2];
                end
            end
            `ADDSUB:begin
                temp_stage = ntt_counter == 8'd66 ? FINISH : PROCESSING;
                w_data_en = ntt_counter > 8'd35;
                in_data_reg = r_data;
                w_addr_reg = w_data_addr_offset + (ntt_counter - 8'd36);
                if (ntt_counter[0] == 0)begin
                    r_addr_reg = r_start_offset_A + ntt_counter[7:1];
                end
                else begin
                    r_addr_reg = r_start_offset_B + ntt_counter[7:1];
                end
            end
            endcase
        end
        FINISH: begin
            w_data_en = 1;
            in_data_reg = 0;
            w_addr_reg = w_data_addr_offset + w_addr;
            r_addr_reg = 0;
            clk_counter = 8'd0;
            temp_stage = START;
        end
        default:begin
            temp_stage = START;
            r_addr_reg = 0;
            in_data_reg = 0;
            clk_counter = 8'd0;
            w_data_en = 0;
            w_addr_reg = 0;
        end
    endcase
end
assign r_addr_wire = mode == `MULT | mode == `ADDSUB? w_addr_reg : r_addr;
assign w_data = mode == `MULT | mode == `ADDSUB? (stage == FINISH ? but_result : ROM_r_data) : but_result;
endmodule