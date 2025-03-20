`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2025 03:53:53 PM
// Design Name: 
// Module Name: auto_ram
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

module auto_ram #(
    parameter DATA_WIDTH = 6400,
    parameter CHUNK_WIDTH = 128
) (
    input wire clk,
    input wire ena_0,
    input wire enb_0,
    input wire wea_0,
    input wire web_0,
    input wire [5:0] addra_0,
    input wire [DATA_WIDTH-1:0] dinb_0,
    input wire [127:0] dina_0,
    output wire [DATA_WIDTH-1:0] doutb_0,
    output wire [127:0] douta_0,
    output wire r_done,
    output wire w_done
);

    localparam TOTAL_CHUNKS = DATA_WIDTH / CHUNK_WIDTH;

    reg [$clog2(TOTAL_CHUNKS):0] write_counter;
    reg [$clog2(TOTAL_CHUNKS):0] read_counter;
    reg [CHUNK_WIDTH-1:0] wr_data;
    wire [CHUNK_WIDTH-1:0] read_chunk;
    reg [5:0] address_b;
    wire [5:0] address_r;
    wire [5:0] address_w;
    
    assign address_r = read_counter;
    assign address_w = write_counter;

    reg [DATA_WIDTH-1:0] doutb_buffer;

    always @(posedge clk) begin
        if (!enb_0) begin
            read_counter <= 0;
            address_b <= 0;
            doutb_buffer <= 0;
            write_counter <= 0;
            wr_data <= 0;
            doutb_buffer <= 0;
        end else begin
            if (!web_0) begin
                if (read_counter <= TOTAL_CHUNKS + 1) begin
                    doutb_buffer[(address_r-2) * CHUNK_WIDTH +: CHUNK_WIDTH] <= read_chunk;
                    address_b <= address_r;
                    read_counter <= read_counter + 1;
                end
            end 
            if (web_0) begin
                if (write_counter < TOTAL_CHUNKS) begin
                    wr_data <= dinb_0[write_counter * CHUNK_WIDTH +: CHUNK_WIDTH];
                    address_b <= address_w;
                    write_counter <= write_counter + 1;
                end
            end
        end
    end

    assign doutb_0 = doutb_buffer;
    assign r_done = (read_counter == TOTAL_CHUNKS + 2);
    assign w_done = (write_counter == TOTAL_CHUNKS);

    two_port_ram_128_wrapper two_port_ram_128_wrapper_i (
        .addra_0(addra_0),
        .addrb_0(address_b),
        .clka_0(clk),
        .clkb_0(clk),
        .dina_0(dina_0),
        .dinb_0(wr_data),
        .douta_0(douta_0),
        .doutb_0(read_chunk),
        .ena_0(ena_0),
        .enb_0(enb_0),
        .wea_0(wea_0),
        .web_0(web_0)
    );

endmodule