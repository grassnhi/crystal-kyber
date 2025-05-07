 `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2025 11:39:16 AM
// Module Name: top
//////////////////////////////////////////////////////////////////////////////////

module top();

// BRAM 0 Port A
wire [14:0] addra_0;
wire        clka_0;
wire [31:0] dina_0;
wire [31:0] douta_0;
wire        ena_0;
wire        rsta_0;
wire [3:0]  wea_0;

// BRAM 1 Port A
wire [14:0] addra_1;
wire        clka_1;
wire [31:0] dina_1;
wire [31:0] douta_1;
wire        ena_1;
wire        rsta_1;
wire [3:0]  wea_1;

// BRAM 2 Port A
wire [12:0] addra_2;
wire        clka_2;
wire [31:0] dina_2;
wire [31:0] douta_2;
wire        ena_2;
wire        rsta_2;
wire [3:0]  wea_2;

// BRAM 0 Port B (connected to kyber)
wire [7:0] addrb_0;
wire        enb_0;
wire [15:0] web_0;
wire [127:0] dinb_0;
wire [127:0] doutb_0;

// BRAM 1 Port B (connected to kyber)
wire [7:0] addrb_1;
wire        enb_1;
wire [15:0]  web_1;
wire [127:0] dinb_1;
wire [127:0] doutb_1;

// Instantiate top-level module
crystal_kyber_wrapper crystal_kyber_inst (
    .BRAM_PORTA_0_addr(addra_0),
    .BRAM_PORTA_0_clk(clka_0),
    .BRAM_PORTA_0_din(dina_0),
    .BRAM_PORTA_0_dout(douta_0),
    .BRAM_PORTA_0_en(ena_0),
    .BRAM_PORTA_0_rst(rsta_0),
    .BRAM_PORTA_0_we(wea_0),

    .BRAM_PORTA_1_addr(addra_1),
    .BRAM_PORTA_1_clk(clka_1),
    .BRAM_PORTA_1_din(dina_1),
    .BRAM_PORTA_1_dout(douta_1),
    .BRAM_PORTA_1_en(ena_1),
    .BRAM_PORTA_1_rst(rsta_1),
    .BRAM_PORTA_1_we(wea_1),

    .BRAM_PORTA_2_addr(addra_2),
    .BRAM_PORTA_2_clk(clka_2),
    .BRAM_PORTA_2_din(dina_2),
    .BRAM_PORTA_2_dout(douta_2),
    .BRAM_PORTA_2_en(ena_2),
    .BRAM_PORTA_2_rst(rsta_2),
    .BRAM_PORTA_2_we(wea_2)
);

// Instance 0
blk_mem_gen_0 blk_mem_gen_0_inst_0 (
    .clka(clka_0),
    .ena(ena_0),
    .wea(wea_0),
    .addra(addra_0[11:2]),
    .dina(dina_0),
    .douta(douta_0),

    .clkb(clka_2),    // Port B
    .enb(enb_0),
    .web(web_0),
    .addrb(addrb_0),
    .dinb(dinb_0),
    .doutb(doutb_0)
);

// Instance 1
blk_mem_gen_0 blk_mem_gen_0_inst_1 (
    .clka(clka_1),
    .ena(ena_1),
    .wea(wea_1),
    .addra(addra_1[11:2]),
    .dina(dina_1),
    .douta(douta_1),

    .clkb(clka_2),    // Port B
    .enb(enb_1),
    .web(web_1),
    .addrb(addrb_1),
    .dinb(dinb_1),
    .doutb(doutb_1)
);

// Instance 2: kyber_wrapper
kyber_wrapper kyber(
    .reg_addr(addra_2[12:2]),
    .reg_clk(clka_2),
    .reg_en(ena_2),
    .reg_rddata(douta_2),
    .reg_rst(rsta_2),
    .reg_we(wea_2),
    .reg_wrdata(dina_2),

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
