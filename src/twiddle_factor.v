`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2024 10:51:24 AM
// Design Name: 
// Module Name: twiddle_factor
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


module twiddle_factor(
    input clk,
    input [6:0] addr,
    output [23:0] dout
    );
    
(* rom_style = "block" *) reg [11:0] data [0:127];

assign dout = {data[addr + 1], data[addr]};

always (@posedge clk) begin
    data[0] <= 12'h001;
    data[1] <= 12'h6c1;
    data[2] <= 12'ha14;
    data[3] <= 12'hcd9;
    data[4] <= 12'ha52;
    data[5] <= 12'h276;
    data[6] <= 12'h769;
    data[7] <= 12'h350;
    data[8] <= 12'h426;
    data[9] <= 12'h77f;
    data[10] <= 12'h0c1;
    data[11] <= 12'h31d;
    data[12] <= 12'hae2;
    data[13] <= 12'hcbc;
    data[14] <= 12'h239;
    data[15] <= 12'h6d2;
    data[16] <= 12'h128;
    data[17] <= 12'h98f;
    data[18] <= 12'h53b;
    data[19] <= 12'h5c4;
    data[20] <= 12'hbe6;
    data[21] <= 12'h038;
    data[22] <= 12'h8c0;
    data[23] <= 12'h535;
    data[24] <= 12'h592;
    data[25] <= 12'h82e;
    data[26] <= 12'h217;
    data[27] <= 12'hb42;
    data[28] <= 12'h959;
    data[29] <= 12'hb3f;
    data[30] <= 12'h7b6;
    data[31] <= 12'h335;
    data[32] <= 12'h121;
    data[33] <= 12'h14b;
    data[34] <= 12'hcb5;
    data[35] <= 12'h6dc;
    data[36] <= 12'h4ad;
    data[37] <= 12'h900;
    data[38] <= 12'h8e5;
    data[39] <= 12'h807;
    data[40] <= 12'h28a;
    data[41] <= 12'h7b9;
    data[42] <= 12'h9d1;
    data[43] <= 12'h278;
    data[44] <= 12'hb31;
    data[45] <= 12'h021;
    data[46] <= 12'h528;
    data[47] <= 12'h77b;
    data[48] <= 12'h90f;
    data[49] <= 12'h59b;
    data[50] <= 12'h327;
    data[51] <= 12'h1c4;
    data[52] <= 12'h59e;
    data[53] <= 12'hb34;
    data[54] <= 12'h5fe;
    data[55] <= 12'h962;
    data[56] <= 12'ha57;
    data[57] <= 12'ha39;
    data[58] <= 12'h5c9;
    data[59] <= 12'h288;
    data[60] <= 12'h9aa;
    data[61] <= 12'hc26;
    data[62] <= 12'h4cb;
    data[63] <= 12'h38e;
    data[64] <= 12'h011;
    data[65] <= 12'hac9;
    data[66] <= 12'h247;
    data[67] <= 12'ha59;
    data[68] <= 12'h665;
    data[69] <= 12'h2d3;
    data[70] <= 12'h8f0;
    data[71] <= 12'h44c;
    data[72] <= 12'h581;
    data[73] <= 12'ha66;
    data[74] <= 12'hcd1;
    data[75] <= 12'h0e9;
    data[76] <= 12'h2f4;
    data[77] <= 12'h86c;
    data[78] <= 12'hbc7;
    data[79] <= 12'hbea;
    data[80] <= 12'h6a7;
    data[81] <= 12'h673;
    data[82] <= 12'hae5;
    data[83] <= 12'h6fd;
    data[84] <= 12'h737;
    data[85] <= 12'h3b8;
    data[86] <= 12'h5b5;
    data[87] <= 12'ha7f;
    data[88] <= 12'h3ab;
    data[89] <= 12'h904;
    data[90] <= 12'h985;
    data[91] <= 12'h954;
    data[92] <= 12'h2dd;
    data[93] <= 12'h921;
    data[94] <= 12'h10c;
    data[95] <= 12'h281;
    data[96] <= 12'h630;
    data[97] <= 12'h8fa;
    data[98] <= 12'h7f5;
    data[99] <= 12'hc94;
    data[100] <= 12'h177;
    data[101] <= 12'h9f5;
    data[102] <= 12'h82a;
    data[103] <= 12'h66d;
    data[104] <= 12'h427;
    data[105] <= 12'h13f;
    data[106] <= 12'had5;
    data[107] <= 12'h2f5;
    data[108] <= 12'h833;
    data[109] <= 12'h231;
    data[110] <= 12'h9a2;
    data[111] <= 12'ha22;
    data[112] <= 12'haf4;
    data[113] <= 12'h444;
    data[114] <= 12'h193;
    data[115] <= 12'h402;
    data[116] <= 12'h477;
    data[117] <= 12'h866;
    data[118] <= 12'had7;
    data[119] <= 12'h376;
    data[120] <= 12'h6ba;
    data[121] <= 12'h4bc;
    data[122] <= 12'h752;
    data[123] <= 12'h405;
    data[124] <= 12'h83e;
    data[125] <= 12'hb77;
    data[126] <= 12'h375;
    data[127] <= 12'h86a;
end

endmodule