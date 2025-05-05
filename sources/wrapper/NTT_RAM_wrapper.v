//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Wed Apr 23 10:12:02 2025
//Host        : Choconary running 64-bit major release  (build 9200)
//Command     : generate_target NTT_RAM_wrapper.bd
//Design      : NTT_RAM_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module NTT_RAM_wrapper
   (addra_0,
    addrb_0,
    clka_0,
    clkb_0,
    dina_0,
    doutb_0,
    ena_0,
    enb_0,
    wea_0);
  input [4:0]addra_0;
  input [4:0]addrb_0;
  input clka_0;
  input clkb_0;
  input [95:0]dina_0;
  output [95:0]doutb_0;
  input ena_0;
  input enb_0;
  input [0:0]wea_0;

  wire [4:0]addra_0;
  wire [4:0]addrb_0;
  wire clka_0;
  wire clkb_0;
  wire [95:0]dina_0;
  wire [95:0]doutb_0;
  wire ena_0;
  wire enb_0;
  wire [0:0]wea_0;

  NTT_RAM NTT_RAM_i
       (.addra_0(addra_0),
        .addrb_0(addrb_0),
        .clka_0(clka_0),
        .clkb_0(clkb_0),
        .dina_0(dina_0),
        .doutb_0(doutb_0),
        .ena_0(ena_0),
        .enb_0(enb_0),
        .wea_0(wea_0));
endmodule
