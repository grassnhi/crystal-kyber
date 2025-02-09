`include "add_sub_core.v"

module addsub(
    input clk,
    input rst,
    input start,
    input add_flag,
    input [7:0] in_addr_offset_A,
    input [7:0] in_addr_offset_B,
    input [95:0] in_data,
    output [95:0] out_data,
    output w_en,
    output [7:0] in_addr,
    output [7:0] out_addr
);
reg [11:0] buf_a[0:7];
reg [11:0] buf_b[0:7];
reg state, temp_state;
reg [6:0] r_addr, temp_r_addr;
wire [11:0] buf_out[0:7];
parameter IDLE = 1'b0;
parameter RUN = 1'b1;
assign out_data = {buf_out[7], buf_out[6], buf_out[5], buf_out[4], 
                   buf_out[3], buf_out[2], buf_out[1], buf_out[0]};
always @(posedge clk or posedge rst)begin
    if(rst)begin
        r_addr <= 0;
        state <= 0;
    end
    else begin
        r_addr <= temp_r_addr;
        state <= temp_state;
    end
    if(temp_r_addr[0])begin
        buf_a[0] <= in_data[11:0];
        buf_a[1] <= in_data[23:12];
        buf_a[2] <= in_data[35:24];
        buf_a[3] <= in_data[47:36];
        buf_a[4] <= in_data[59:48];
        buf_a[5] <= in_data[71:60];
        buf_a[6] <= in_data[83:72];
        buf_a[7] <= in_data[95:84];
    end
    else begin
        buf_b[0] <= in_data[11:0];
        buf_b[1] <= in_data[23:12];
        buf_b[2] <= in_data[35:24];
        buf_b[3] <= in_data[47:36];
        buf_b[4] <= in_data[59:48];
        buf_b[5] <= in_data[71:60];
        buf_b[6] <= in_data[83:72];
        buf_b[7] <= in_data[95:84];
    end
end
assign w_en = r_addr > 1 ? (~r_addr[0]):0;
assign out_addr = r_addr[6:1] + in_addr_offset_A - 1;
assign in_addr = (r_addr[0]? in_addr_offset_B : in_addr_offset_A) + r_addr[5:1];
always @(*)begin
    if(state == 0)begin
        if(start)begin
            temp_state = 1;
            temp_r_addr = r_addr + 1;
        end
        else begin
            temp_state = state;
            temp_r_addr = 0;
        end        
    end
    else begin
        if(r_addr == 64)begin
            temp_state = 0;
        end
        temp_r_addr = r_addr + 1;
    end
end
addsub_core ADDSUB0(
    .add_flag(add_flag),
    .in_data_1(buf_a[0]),
    .in_data_2(buf_b[0]),
    .out_data(buf_out[0])
);
addsub_core ADDSUB1(
    .add_flag(add_flag),
    .in_data_1(buf_a[1]),
    .in_data_2(buf_b[1]),
    .out_data(buf_out[1])
);
addsub_core ADDSUB2(
    .add_flag(add_flag),
    .in_data_1(buf_a[2]),
    .in_data_2(buf_b[2]),
    .out_data(buf_out[2])
);
addsub_core ADDSUB3(
    .add_flag(add_flag),
    .in_data_1(buf_a[3]),
    .in_data_2(buf_b[3]),
    .out_data(buf_out[3])
);
addsub_core ADDSUB4(
    .add_flag(add_flag),
    .in_data_1(buf_a[4]),
    .in_data_2(buf_b[4]),
    .out_data(buf_out[4])
);
addsub_core ADDSUB5(
    .add_flag(add_flag),
    .in_data_1(buf_a[5]),
    .in_data_2(buf_b[5]),
    .out_data(buf_out[5])
);
addsub_core ADDSUB6(
    .add_flag(add_flag),
    .in_data_1(buf_a[6]),
    .in_data_2(buf_b[6]),
    .out_data(buf_out[6])
);
addsub_core ADDSUB7(
    .add_flag(add_flag),
    .in_data_1(buf_a[7]),
    .in_data_2(buf_b[7]),
    .out_data(buf_out[7])
);
endmodule