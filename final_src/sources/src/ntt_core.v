
//`include "butterfly.v"
//`include "twiddle_factor.v"
//`include "ntt_rom.v"

module ntt_processor (
    input clk,
    input rst,
    input start,
    input [1:0] mode,
    input add_or_sub,
    input [8:0]r_start_offset_A,
    input [8:0]r_start_offset_B,
    input [8:0]w_data_addr_offset,
    input [95:0] r_data,
    output reg [95:0] w_data,
    output [8:0] w_data_addr,
    output [8:0] r_data_addr,
    output reg w_data_en,
    output reg ntt_ren,
    output reg finish
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
reg [95:0] in_data_reg, butterfly_res_buf;
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
reg [8:0] w_addr_reg, r_addr_reg;

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
    .clk(clk),
    .addr(coef_addr),
    .dout(coef_reg)
    );

wire [95:0] ROM_r_data;
//rom ROM(
//    .clk(clk),
//    .rst(rst),
//    .wdata(but_result),
//    .wdata_addr(w_addr),
//    .rdata_addr(r_addr_wire),
//    .rdata(ROM_r_data)
//);
NTT_RAM_wrapper ROM
   (.addra_0(w_addr),
    .addrb_0(r_addr_wire),
    .clka_0(clk),
    .clkb_0(clk),
    .dina_0(but_result),
    .doutb_0(ROM_r_data),
    .ena_0(1),
    .enb_0(1),
    .wea_0(1));
reg [1:0]stage, temp_stage;
parameter START = 0;
parameter PROCESSING = 1;
parameter FINISH = 2;
always @(posedge clk or posedge rst)begin
    if(rst)begin
        ntt_counter <= 0;  
        stage <= START;
        butterfly_res_buf <= 0;
    end
    else begin
        ntt_counter <= clk_counter;
        stage <= temp_stage;
        butterfly_res_buf <= but_result;
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
        in_buf_pre_load = ntt_counter[1:0] == 2'b01 && stage == PROCESSING;
        in_buf_load = ntt_counter[1:0] == 2'b10;
        ntt_type = mode == ntt_counter[0];
    end
    `ADDSUB: begin
        ntt_stage = {2'b0, ntt_counter[0]};
        in_buf_pre_load = ntt_counter[0] == 1 && stage == PROCESSING;
        in_buf_load = ntt_counter[0] == 0;
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
                clk_counter = ntt_counter+1;
                ntt_ren = mode == `ADDSUB;
            end
            else begin
                ntt_ren = 0;
                temp_stage = START;
                in_data_reg = 0;
                clk_counter = 0;
                ntt_ren = 0;
            end
            finish = 0;
            w_data_en = 0;
            w_addr_reg = w_data_addr_offset;
            r_addr_reg = r_start_offset_A;
        end
        PROCESSING: begin
            finish = 0;
            clk_counter = ntt_counter + 1;
            case(mode)
            `NTT, `INTT: begin
                temp_stage = ntt_counter == 8'd229 ? FINISH : PROCESSING;
                w_data_en = ntt_counter > 8'd198;
                w_addr_reg = w_data_addr_offset + w_addr;
                ntt_ren = 0;
                if(ntt_counter < 8'd33)begin
                    in_data_reg = r_data;
                end
                else begin
                    in_data_reg = ROM_r_data;
                end
                r_addr_reg = ntt_counter[7:5] == 0? r_start_offset_A + r_addr : 0;
            end
            `MULT: begin
                finish = 0;
                ntt_ren = ntt_counter > 8'd90;
                temp_stage = ntt_counter == 8'd139 ? FINISH : PROCESSING;
                w_data_en = ntt_counter > 8'd108;
                in_data_reg = r_data;
                w_addr_reg = w_data_addr_offset + (ntt_counter - 8'd109);
                if (ntt_counter[0] == 0)begin
                    r_addr_reg = r_start_offset_A + ntt_counter[7:2];
                end
                else begin
                    r_addr_reg = r_start_offset_B + ntt_counter[7:2];
                end
            end
            `ADDSUB:begin
                finish = 0;
                ntt_ren = 1;
                temp_stage = ntt_counter == 8'd67 ? FINISH : PROCESSING;
                w_data_en = ntt_counter > 8'd36;
                in_data_reg = r_data;
                w_addr_reg = w_data_addr_offset + (ntt_counter - 8'd37);
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
            ntt_ren = 1;
            finish = 1;
            w_data_en = 1;
            in_data_reg = 0;
            w_addr_reg = w_data_addr_offset + w_addr;
            r_addr_reg = 0;
            clk_counter = 8'd0;
            temp_stage = START;
        end
        default:begin
            ntt_ren = 0;
            finish = 0;
            temp_stage = START;
            r_addr_reg = 0;
            in_data_reg = 0;
            clk_counter = 8'd0;
            w_data_en = 0;
            w_addr_reg = 0;
        end
    endcase
end
assign r_addr_wire = mode[1] == 1? w_addr_reg+1 : r_addr;
always@(*)begin
    if(mode[1] == 1)begin
        if(stage == FINISH)begin
            w_data = but_result;
        end
        else begin
            if(mode[0] == 1 && temp_stage == FINISH)begin
                w_data = butterfly_res_buf;
            end
            else begin
                w_data = ROM_r_data; 
            end
        end
    end
    else begin
        w_data = but_result;
    end
end
endmodule