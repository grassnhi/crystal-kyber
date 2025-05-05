//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Wed Apr 23 10:10:34 2025
//Host        : Choconary running 64-bit major release  (build 9200)
//Command     : generate_target RAM_WRAPPER_wrapper.bd
//Design      : RAM_WRAPPER_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module RAM_WRAPPER_wrapper
   (addra_0,
    addrb_0,
    clka_0,
    clkb_0,
    dina_0,
    dinb_0,
    douta_0,
    doutb_0,
    ena_0,
    enb_0,
    wea_0,
    web_0);
  input [8:0]addra_0;
  input [8:0]addrb_0;
  input clka_0;
  input clkb_0;
  input [95:0]dina_0;
  input [95:0]dinb_0;
  output [95:0]douta_0;
  output [95:0]doutb_0;
  input ena_0;
  input enb_0;
  input [0:0]wea_0;
  input [0:0]web_0;

  wire [8:0]addra_0;
  wire [8:0]addrb_0;
  wire clka_0;
  wire clkb_0;
  wire [95:0]dina_0;
  wire [95:0]dinb_0;
  wire [95:0]douta_0;
  wire [95:0]doutb_0;
  wire ena_0;
  wire enb_0;
  wire [0:0]wea_0;
  wire [0:0]web_0;

  RAM_WRAPPER RAM_WRAPPER_i
       (.addra_0(addra_0),
        .addrb_0(addrb_0),
        .clka_0(clka_0),
        .clkb_0(clkb_0),
        .dina_0(dina_0),
        .dinb_0(dinb_0),
        .douta_0(douta_0),
        .doutb_0(doutb_0),
        .ena_0(ena_0),
        .enb_0(enb_0),
        .wea_0(wea_0),
        .web_0(web_0));
endmodule
