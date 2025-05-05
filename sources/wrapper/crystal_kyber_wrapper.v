//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Sat Apr 26 15:13:44 2025
//Host        : Choconary running 64-bit major release  (build 9200)
//Command     : generate_target crystal_kyber_wrapper.bd
//Design      : crystal_kyber_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module crystal_kyber_wrapper
   (BRAM_PORTA_0_addr,
    BRAM_PORTA_0_clk,
    BRAM_PORTA_0_din,
    BRAM_PORTA_0_dout,
    BRAM_PORTA_0_en,
    BRAM_PORTA_0_rst,
    BRAM_PORTA_0_we,
    BRAM_PORTA_1_addr,
    BRAM_PORTA_1_clk,
    BRAM_PORTA_1_din,
    BRAM_PORTA_1_dout,
    BRAM_PORTA_1_en,
    BRAM_PORTA_1_rst,
    BRAM_PORTA_1_we,
    BRAM_PORTA_2_addr,
    BRAM_PORTA_2_clk,
    BRAM_PORTA_2_din,
    BRAM_PORTA_2_dout,
    BRAM_PORTA_2_en,
    BRAM_PORTA_2_rst,
    BRAM_PORTA_2_we);
  output [14:0]BRAM_PORTA_0_addr;
  output BRAM_PORTA_0_clk;
  output [31:0]BRAM_PORTA_0_din;
  input [31:0]BRAM_PORTA_0_dout;
  output BRAM_PORTA_0_en;
  output BRAM_PORTA_0_rst;
  output [3:0]BRAM_PORTA_0_we;
  output [14:0]BRAM_PORTA_1_addr;
  output BRAM_PORTA_1_clk;
  output [31:0]BRAM_PORTA_1_din;
  input [31:0]BRAM_PORTA_1_dout;
  output BRAM_PORTA_1_en;
  output BRAM_PORTA_1_rst;
  output [3:0]BRAM_PORTA_1_we;
  output [12:0]BRAM_PORTA_2_addr;
  output BRAM_PORTA_2_clk;
  output [31:0]BRAM_PORTA_2_din;
  input [31:0]BRAM_PORTA_2_dout;
  output BRAM_PORTA_2_en;
  output BRAM_PORTA_2_rst;
  output [3:0]BRAM_PORTA_2_we;

  wire [14:0]BRAM_PORTA_0_addr;
  wire BRAM_PORTA_0_clk;
  wire [31:0]BRAM_PORTA_0_din;
  wire [31:0]BRAM_PORTA_0_dout;
  wire BRAM_PORTA_0_en;
  wire BRAM_PORTA_0_rst;
  wire [3:0]BRAM_PORTA_0_we;
  wire [14:0]BRAM_PORTA_1_addr;
  wire BRAM_PORTA_1_clk;
  wire [31:0]BRAM_PORTA_1_din;
  wire [31:0]BRAM_PORTA_1_dout;
  wire BRAM_PORTA_1_en;
  wire BRAM_PORTA_1_rst;
  wire [3:0]BRAM_PORTA_1_we;
  wire [12:0]BRAM_PORTA_2_addr;
  wire BRAM_PORTA_2_clk;
  wire [31:0]BRAM_PORTA_2_din;
  wire [31:0]BRAM_PORTA_2_dout;
  wire BRAM_PORTA_2_en;
  wire BRAM_PORTA_2_rst;
  wire [3:0]BRAM_PORTA_2_we;

  crystal_kyber crystal_kyber_i
       (.BRAM_PORTA_0_addr(BRAM_PORTA_0_addr),
        .BRAM_PORTA_0_clk(BRAM_PORTA_0_clk),
        .BRAM_PORTA_0_din(BRAM_PORTA_0_din),
        .BRAM_PORTA_0_dout(BRAM_PORTA_0_dout),
        .BRAM_PORTA_0_en(BRAM_PORTA_0_en),
        .BRAM_PORTA_0_rst(BRAM_PORTA_0_rst),
        .BRAM_PORTA_0_we(BRAM_PORTA_0_we),
        .BRAM_PORTA_1_addr(BRAM_PORTA_1_addr),
        .BRAM_PORTA_1_clk(BRAM_PORTA_1_clk),
        .BRAM_PORTA_1_din(BRAM_PORTA_1_din),
        .BRAM_PORTA_1_dout(BRAM_PORTA_1_dout),
        .BRAM_PORTA_1_en(BRAM_PORTA_1_en),
        .BRAM_PORTA_1_rst(BRAM_PORTA_1_rst),
        .BRAM_PORTA_1_we(BRAM_PORTA_1_we),
        .BRAM_PORTA_2_addr(BRAM_PORTA_2_addr),
        .BRAM_PORTA_2_clk(BRAM_PORTA_2_clk),
        .BRAM_PORTA_2_din(BRAM_PORTA_2_din),
        .BRAM_PORTA_2_dout(BRAM_PORTA_2_dout),
        .BRAM_PORTA_2_en(BRAM_PORTA_2_en),
        .BRAM_PORTA_2_rst(BRAM_PORTA_2_rst),
        .BRAM_PORTA_2_we(BRAM_PORTA_2_we));
endmodule
