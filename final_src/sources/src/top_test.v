module top_test(
    // BRAM 0 Port A
    input  [9:0] BRAM_PORTA_0_addr,
    input        BRAM_PORTA_0_clk,
    input  [31:0] BRAM_PORTA_0_din,
    output [31:0] BRAM_PORTA_0_dout,
    input        BRAM_PORTA_0_en,
    input        BRAM_PORTA_0_rst,
    input  [3:0] BRAM_PORTA_0_we,

    // BRAM 1 Port A
    input  [9:0] BRAM_PORTA_1_addr,
    input        BRAM_PORTA_1_clk,
    input  [31:0] BRAM_PORTA_1_din,
    output [31:0] BRAM_PORTA_1_dout,
    input        BRAM_PORTA_1_en,
    input        BRAM_PORTA_1_rst,
    input  [3:0] BRAM_PORTA_1_we,

    // BRAM 2 Port A
    input  [12:0] BRAM_PORTA_2_addr,
    input        BRAM_PORTA_2_clk,
    input  [31:0] BRAM_PORTA_2_din,
    output [31:0] BRAM_PORTA_2_dout,
    input        BRAM_PORTA_2_en,
    input        BRAM_PORTA_2_rst,
    input  [3:0] BRAM_PORTA_2_we
);

// Internal wires for BRAM 0 and 1 Port B
wire [7:0] addrb_0;
wire       clkb_0;
wire       enb_0;
wire [15:0] web_0;
wire [127:0] dinb_0;
wire [127:0] doutb_0;

wire [7:0] addrb_1;
wire       clkb_1;
wire       enb_1;
wire [15:0] web_1;
wire [127:0] dinb_1;
wire [127:0] doutb_1;

// Instance 0
blk_mem_gen_0 blk_mem_gen_0_inst_0 (
    .clka(BRAM_PORTA_0_clk),
    .ena(BRAM_PORTA_0_en),
    .wea(BRAM_PORTA_0_we),
    .addra(BRAM_PORTA_0_addr),
    .dina(BRAM_PORTA_0_din),
    .douta(BRAM_PORTA_0_dout),

    .clkb(BRAM_PORTA_2_clk),    // Port B
    .enb(enb_0),
    .web(web_0),
    .addrb(addrb_0),
    .dinb(dinb_0),
    .doutb(doutb_0)
);

// Instance 1
blk_mem_gen_0 blk_mem_gen_0_inst_1 (
    .clka(BRAM_PORTA_1_clk),
    .ena(BRAM_PORTA_1_en),
    .wea(BRAM_PORTA_1_we),
    .addra(BRAM_PORTA_1_addr),
    .dina(BRAM_PORTA_1_din),
    .douta(BRAM_PORTA_1_dout),

    .clkb(BRAM_PORTA_2_clk),    // Port B
    .enb(enb_1),
    .web(web_1),
    .addrb(addrb_1),
    .dinb(dinb_1),
    .doutb(doutb_1)
);

// Instance 2: kyber_wrapper
kyber_wrapper kyber(
    .reg_addr(BRAM_PORTA_2_addr),
    .reg_clk(BRAM_PORTA_2_clk),
    .reg_en(BRAM_PORTA_2_en),
    .reg_rddata(BRAM_PORTA_2_dout),
    .reg_rst(BRAM_PORTA_2_rst),
    .reg_we(BRAM_PORTA_2_we),
    .reg_wrdata(BRAM_PORTA_2_din),

    .addr_br_kb(addrb_1),
    .en_br_kb(enb_1),
    .rddata_br_kb(doutb_1),
    .we_br_kb(web_1),
    .wrdata_br_kb(dinb_1),

    .addr_kb_br(addrb_0),
    .en_kb_br(enb_0),
    .rddata_kb_br(doutb_0),
    .we_kb_br(web_0),
    .wrdata_kb_br(dinb_0)
);

endmodule