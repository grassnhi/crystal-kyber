module addsub_core(
    input add_flag,
    input [11:0] in_data_1,
    input [11:0] in_data_2,
    output [11:0] out_data
);
wire [12:0]result;
assign result = add_flag ? in_data_1 + in_data_2 : in_data_1 - in_data_2;
assign out_data = add_flag ? (result >= 12'd3329 ? result - 12'd3329 : result)
                                 : (result[12]?result + 12'd3329: result);
endmodule