`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2024 11:10:04 AM
// Design Name: 
// Module Name: butterfly_unit_processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "butterfly_core.v"

module butterfly(
    input clk,
    input rst,
    input [1:0] mode, // mode : NTT(0) , INTT(1), PWM(2), ADDSUB(3)
    input [2:0] stage, 
    input in_buf_pre_load,
    input in_buf_load,
    input type,
    input [95:0] in_data,
    input [23:0] in_coef,
    output [95:0] out_data
    );

`define NTT 2'd0
`define INVNTT 2'd1
`define MULT 2'd2
`define ADDSUB 2'd3

integer i;
wire [11:0] in_data_split [7:0];
wire [11:0] in_coef_split [1:0];
reg [11:0] out_data_split [7:0];
wire [11:0] in_coef_split_neg [1:0];

// some registers
reg [11:0] in_buf_a_pre [7:0]; // 12x8 input buffer, used in multiply operation
reg [11:0] in_buf_a [7:0]; // 12x8 input buffer, used in multiply operation
reg [11:0] in_buf_b [7:0]; // 12x8 input buffer, used in multiply operation
reg [11:0] out_buf [7:0]; // 12x8 output buffer
reg [2:0] stage_prop [9:0]; // stage propagation register
reg type_prop [6:0]; // type propagation register

// bu_0
reg [11:0] bu_0_in_1, bu_0_in_2, bu_0_coef;
wire [1:0] bu_0_mode;
wire [11:0] bu_0_out_1, bu_0_out_2;
butterfly_core BU0 (
    .clk(clk),
    .rst(rst),
    .in_1(bu_0_in_1),
    .in_2(bu_0_in_2),
    .coef(bu_0_coef),
    .mode(bu_0_mode),
    .out_1(bu_0_out_1),
    .out_2(bu_0_out_2)
);

// bu_1
reg [11:0] bu_1_in_1, bu_1_in_2, bu_1_coef;
wire [1:0] bu_1_mode;
wire [11:0] bu_1_out_1, bu_1_out_2;
butterfly_core BU1 (
    .clk(clk),
    .rst(rst),
    .in_1(bu_1_in_1),
    .in_2(bu_1_in_2),
    .coef(bu_1_coef),
    .mode(bu_1_mode),
    .out_1(bu_1_out_1),
    .out_2(bu_1_out_2)
);

// bu_2
reg [11:0] bu_2_in_1, bu_2_in_2, bu_2_coef;
wire [1:0] bu_2_mode;
wire [11:0] bu_2_out_1, bu_2_out_2;
butterfly_core BU2 (
    .clk(clk),
    .rst(rst),
    .in_1(bu_2_in_1),
    .in_2(bu_2_in_2),
    .coef(bu_2_coef),
    .mode(bu_2_mode),
    .out_1(bu_2_out_1),
    .out_2(bu_2_out_2)
);

// bu_3
reg [11:0] bu_3_in_1, bu_3_in_2, bu_3_coef;
wire [1:0] bu_3_mode;
wire [11:0] bu_3_out_1, bu_3_out_2;
butterfly_core BU3 (
    .clk(clk),
    .rst(rst),
    .in_1(bu_3_in_1),
    .in_2(bu_3_in_2),
    .coef(bu_3_coef),
    .mode(bu_3_mode),
    .out_1(bu_3_out_1),
    .out_2(bu_3_out_2)
);

//MUL block for poinwise-multiply
wire [11:0] mul_reduce_in_1, mul_reduce_in_2;
wire [11:0] mul_reduce_out;
reg [11:0] mult_a1, mult_b1, mult_a0, mult_b0, mult_coef; 
mult MULT_COEF (
    .clk(clk),
    .rst(rst),
    .in1(mul_reduce_in_1),
    .in2(mul_reduce_in_2),
    .res(mul_reduce_out)
);
assign mul_reduce_in_1 = mult_a1;
assign mul_reduce_in_2 = mult_coef;

// in_data & out_data split assignment
assign in_data_split[0] = in_data[11:00];
assign in_data_split[1] = in_data[23:12];
assign in_data_split[2] = in_data[35:24];
assign in_data_split[3] = in_data[47:36];
assign in_data_split[4] = in_data[59:48];
assign in_data_split[5] = in_data[71:60];
assign in_data_split[6] = in_data[83:72];
assign in_data_split[7] = in_data[95:84];
assign in_coef_split[0] = in_coef[11:00];
assign in_coef_split[1] = in_coef[23:12];
assign in_coef_split_neg[0] = 12'd3329 - in_coef[11:00];
assign in_coef_split_neg[1] = 12'd3329 - in_coef[23:12];
assign out_data = { out_data_split[7], out_data_split[6], out_data_split[5], out_data_split[4],
                    out_data_split[3], out_data_split[2], out_data_split[1], out_data_split[0] };

// BU_inputs
assign bu_0_mode = mode;
assign bu_1_mode = mode;
assign bu_2_mode = mode == `MULT ? 2'd0 : mode;
assign bu_3_mode = mode == `MULT ? 2'd0 : mode;
always @(*) begin
    case(mode)
    `NTT : begin
        bu_0_in_1 = in_data_split[0];
        bu_0_in_2 = in_data_split[2];
        
        bu_1_in_1 = in_data_split[1];
        bu_1_in_2 = in_data_split[3];
        
        bu_2_in_1 = in_data_split[4];
        bu_2_in_2 = in_data_split[6];
        
        bu_3_in_1 = in_data_split[5];
        bu_3_in_2 = in_data_split[7];

        bu_0_coef = in_coef_split[0];
        bu_1_coef = in_coef_split[0];
        bu_2_coef = stage_prop[0] == 3'd6 ? in_coef_split[1] : in_coef_split[0];
        bu_3_coef = stage_prop[0] == 3'd6 ? in_coef_split[1] : in_coef_split[0];
    end
    `INVNTT: begin
        bu_0_in_1 = in_data_split[0];
        bu_0_in_2 = stage_prop[0] == 3'd0 ? in_data_split[2] : in_data_split[4];
        
        bu_1_in_1 = in_data_split[1];
        bu_1_in_2 = stage_prop[0] == 3'd0 ? in_data_split[3] : in_data_split[5];
        
        bu_2_in_1 = stage_prop[0] == 3'd0 ? in_data_split[4] : in_data_split[2];
        bu_2_in_2 = in_data_split[6];
        
        bu_3_in_1 = stage_prop[0] == 3'd0 ? in_data_split[5] : in_data_split[3];
        bu_3_in_2 = in_data_split[7];
        
        bu_0_coef = stage_prop[0] == 3'd0 ? in_coef_split_neg[1] : in_coef_split_neg[0];
        bu_1_coef = stage_prop[0] == 3'd0 ? in_coef_split_neg[1] : in_coef_split_neg[0];
        bu_2_coef = in_coef_split_neg[0];
        bu_3_coef = in_coef_split_neg[0];
    end
    `MULT: begin
        //bu0 -> a0 and a0*b0
        bu_0_in_1 = mult_a0;
        bu_0_in_2 = mult_b0;
        bu_0_coef = mult_a0;
        //bu1 -> b1 and a1*b0
        bu_1_in_1 = mult_b1;
        bu_1_in_2 = mult_b0;
        bu_1_coef = mult_a1;
        //bu2 -> a0*b0+a1*b1*coef
        bu_2_in_1 = bu_0_out_2;
        bu_2_in_2 = mul_reduce_out;
        bu_2_coef = bu_1_out_1;
        //bu3 -> a0*b1 + a1*b0
        bu_3_in_1 = bu_1_out_2;
        bu_3_in_2 = bu_0_out_1;
        bu_3_coef = bu_1_out_1;
    end
    default:begin
        if(stage_prop[0][0] == 0)begin
            bu_0_in_1 = in_buf_a[0];
            bu_0_in_2 = in_buf_b[0];
            bu_1_in_1 = in_buf_a[1];
            bu_1_in_2 = in_buf_b[1];
            bu_2_in_1 = in_buf_a[2];
            bu_2_in_2 = in_buf_b[2];
            bu_3_in_1 = in_buf_a[3];
            bu_3_in_2 = in_buf_b[3];
        end
        else begin
            bu_0_in_1 = in_buf_a[4];
            bu_0_in_2 = in_buf_b[4];
            bu_1_in_1 = in_buf_a[5];
            bu_1_in_2 = in_buf_b[5];
            bu_2_in_1 = in_buf_a[6];
            bu_2_in_2 = in_buf_b[6];
            bu_3_in_1 = in_buf_a[7];
            bu_3_in_2 = in_buf_b[7];
        end
        bu_0_coef = 12'd0;
        bu_1_coef = 12'd0;
        bu_2_coef = 12'd0;
        bu_3_coef = 12'd0;
    end
    endcase
end

// mult_a0 a1 b0 b1 coef
always @(*) begin
    if(mode == `MULT) begin
        case(stage_prop[0][1:0])
        2'd2: begin
            mult_a0 = in_buf_a[0];
            mult_b0 = in_buf_b[0];
            mult_a1 = in_buf_a[1];
            mult_b1 = in_buf_b[1];
            mult_coef = in_coef_split[0];
        end
        2'd3: begin
            mult_a0 = in_buf_a[2];
            mult_b0 = in_buf_b[2];
            mult_a1 = in_buf_a[3];
            mult_b1 = in_buf_b[3];
            mult_coef = in_coef_split_neg[0];
        end
        2'd0: begin
            mult_a0 = in_buf_a[4];
            mult_b0 = in_buf_b[4];
            mult_a1 = in_buf_a[5];
            mult_b1 = in_buf_b[5];
            mult_coef = in_coef_split[1];
        end
        2'd1: begin
            mult_a0 = in_buf_a[6];
            mult_b0 = in_buf_b[6];
            mult_a1 = in_buf_a[7];
            mult_b1 = in_buf_b[7];
            mult_coef = in_coef_split_neg[1];
        end
        endcase 
    end
    else begin
        mult_a1 = 0;
        mult_b1 = 0;
        mult_a0 = 0;
        mult_b0 = 0;
        mult_coef = 0;
    end
end

// stage_prop & type_prop
always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0; i<10; i=i+1) stage_prop[0] <= 0;
        for(i=0; i<7; i=i+1) type_prop[0] <= 0;
    end
    else begin
        stage_prop[0] <= stage;
        type_prop[0] <= type;
        for(i=1; i<7; i=i+1) begin
            stage_prop[i] <= stage_prop[i-1];
            type_prop[i] <= type_prop[i-1];
        end
        for(i=7; i<10; i=i+1) begin
            stage_prop[i] <= stage_prop[i-1];
        end
    end
end

// output buffer
always @(posedge clk) begin
    if(rst) begin
        for(i=0; i<8; i=i+1) out_buf[i] <= 0;
    end
    else begin
        case(mode)
        `NTT: begin
            if(stage_prop[5] == 3'd5) begin
                out_buf[0] <= bu_0_out_1;
                out_buf[1] <= bu_1_out_1;
                out_buf[2] <= bu_2_out_1;
                out_buf[3] <= bu_3_out_1;
                out_buf[4] <= bu_0_out_2;
                out_buf[5] <= bu_1_out_2;
                out_buf[6] <= bu_2_out_2;
                out_buf[7] <= bu_3_out_2;
            end
            else if(stage_prop[5] == 3'd6) begin
                out_buf[0] <= bu_0_out_1;
                out_buf[1] <= bu_1_out_1;
                out_buf[2] <= bu_0_out_2;
                out_buf[3] <= bu_1_out_2;
                out_buf[4] <= bu_2_out_1;
                out_buf[5] <= bu_3_out_1;
                out_buf[6] <= bu_2_out_2;
                out_buf[7] <= bu_3_out_2;
            end
            else begin 
                if(type_prop[5] == 1'b0) begin 
                    out_buf[0] <= bu_0_out_2;
                    out_buf[1] <= bu_1_out_2;
                    out_buf[2] <= bu_2_out_2;
                    out_buf[3] <= bu_3_out_2;
                    out_buf[4] <= bu_0_out_1;
                    out_buf[5] <= bu_1_out_1;
                    out_buf[6] <= bu_2_out_1;
                    out_buf[7] <= bu_3_out_1;
                end
                else begin
                    out_buf[4] <= bu_0_out_2;
                    out_buf[5] <= bu_1_out_2;
                    out_buf[6] <= bu_2_out_2;
                    out_buf[7] <= bu_3_out_2;
                end
            end
        end
        `INVNTT: begin
            if(stage_prop[5] == 3'd0 || stage_prop[5] == 3'd6) begin
                out_buf[0] <= bu_0_out_1;
                out_buf[1] <= bu_1_out_1;
                out_buf[2] <= bu_0_out_2;
                out_buf[3] <= bu_1_out_2;
                out_buf[4] <= bu_2_out_1;
                out_buf[5] <= bu_3_out_1;
                out_buf[6] <= bu_2_out_2;
                out_buf[7] <= bu_3_out_2;
            end
            else begin 
                if(type_prop[5] == 1'b0) begin 
                    out_buf[0] <= bu_2_out_1;
                    out_buf[1] <= bu_3_out_1;
                    out_buf[2] <= bu_2_out_2;
                    out_buf[3] <= bu_3_out_2;
                    out_buf[4] <= bu_0_out_1;
                    out_buf[5] <= bu_1_out_1;
                    out_buf[6] <= bu_0_out_2;
                    out_buf[7] <= bu_1_out_2;
                end
                else begin
                    out_buf[4] <= bu_2_out_1;
                    out_buf[5] <= bu_3_out_1;
                    out_buf[6] <= bu_2_out_2;
                    out_buf[7] <= bu_3_out_2;
                end
            end
        end
        `MULT: begin
            case(stage_prop[9][1:0]) 
            2'd2: begin
                out_buf[0] <= bu_2_out_1;
                out_buf[1] <= bu_3_out_1;
            end
            2'd3: begin
                out_buf[2] <= bu_2_out_1;
                out_buf[3] <= bu_3_out_1;            
            end
            2'd0: begin
                out_buf[4] <= bu_2_out_1;
                out_buf[5] <= bu_3_out_1;            
            end
            2'd1: begin
                out_buf[6] <= bu_2_out_1;
                out_buf[7] <= bu_3_out_1;            
            end
            endcase
        end
        default: begin
             if(type_prop[1]) begin // sub
                if(stage_prop[1] == 3'd1) begin
                    out_buf[4] <= bu_0_out_2;
                    out_buf[5] <= bu_1_out_2;
                    out_buf[6] <= bu_2_out_2;
                    out_buf[7] <= bu_3_out_2;    
                end
                else begin
                    out_buf[0] <= bu_0_out_2;
                    out_buf[1] <= bu_1_out_2;
                    out_buf[2] <= bu_2_out_2;
                    out_buf[3] <= bu_3_out_2;   
                end 
            end
            else begin // add
                if(stage_prop[1] == 3'd1) begin
                    out_buf[4] <= bu_0_out_1;
                    out_buf[5] <= bu_1_out_1;
                    out_buf[6] <= bu_2_out_1;
                    out_buf[7] <= bu_3_out_1;    
                end
                else begin
                    out_buf[0] <= bu_0_out_1;
                    out_buf[1] <= bu_1_out_1;
                    out_buf[2] <= bu_2_out_1;
                    out_buf[3] <= bu_3_out_1;    
                end
            end
        end
        endcase
    end
end

// output data
always @(*) begin
    case(mode)
    `NTT: begin
        if(stage_prop[6] == 3'd5 || stage_prop[6] == 3'd6) begin
            for(i=0; i<8; i=i+1) out_data_split[i] = out_buf[i];
        end
        else begin 
            if(type_prop[6] == 1'b0) begin 
                out_data_split[0] = out_buf[4];
                out_data_split[1] = out_buf[5];
                out_data_split[2] = out_buf[6];
                out_data_split[3] = out_buf[7];
                out_data_split[4] = bu_0_out_1;
                out_data_split[5] = bu_1_out_1;
                out_data_split[6] = bu_2_out_1;
                out_data_split[7] = bu_3_out_1;
            end
            else begin
                for(i=0; i<8; i=i+1) out_data_split[i] = out_buf[i];
            end
        end
    end
    `INVNTT: begin
        if(stage_prop[6] == 3'd0 || stage_prop[6] == 3'd6) begin
            for(i=0; i<8; i=i+1) out_data_split[i] = out_buf[i];
        end
        else begin 
            if(type_prop[6] == 1'b0) begin 
                out_data_split[0] = out_buf[4];
                out_data_split[1] = out_buf[5];
                out_data_split[2] = out_buf[6];
                out_data_split[3] = out_buf[7];
                out_data_split[4] = bu_0_out_1;
                out_data_split[5] = bu_1_out_1;
                out_data_split[6] = bu_0_out_2;
                out_data_split[7] = bu_1_out_2;
            end
            else begin
                for(i=0; i<8; i=i+1) out_data_split[i] = out_buf[i];
            end
        end        
    end
    default: begin // MULT
        for(i=0; i<8; i=i+1) out_data_split[i] = out_buf[i];
    end
    endcase
end
    
// in_buf_control
always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0; i<8; i=i+1) in_buf_a_pre[i] <= 0;
    end
    else begin
        if(in_buf_pre_load) begin
            for(i=0; i<8; i=i+1) in_buf_a_pre[i] <= in_data_split[i];
        end
    end
end
always @(posedge clk) begin
    if(rst) begin
        for(i=0; i<8; i=i+1) in_buf_a[i] <= 0;
        for(i=0; i<8; i=i+1) in_buf_b[i] <= 0;
    end
    else begin
        if(in_buf_load) begin
            for(i=0; i<8; i=i+1) begin
                in_buf_a[i] <= in_buf_a_pre[i];
                in_buf_b[i] <= in_data_split[i];
            end
        end
    end
end

endmodule

