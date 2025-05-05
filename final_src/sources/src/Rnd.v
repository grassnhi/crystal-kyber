
module Rnd(input [0:1599]S,
        input [4:0]ir,
        output [0:1599]S_out);

wire [0:1599] S_out1,S_out2,S_out3,S_out4;
wire A_out[0:4][0:4][0:63];
wire A[0:4][0:4][0:63];
(* rom_style = "block" *) reg [63:0] RC [23:0];

// (* keep_hierarchy = "yes" *) 
Theta theta(.S(S),.S_out(S_out1));
Rho rho(.S(S_out1),.S_out(S_out2));
Pi pi(.S(S_out2),.S_out(S_out3));
Chi chi(.S(S_out3),.S_out(S_out4));

initial begin
        RC[0]  <= 64'h0000000000000001; 
        RC[1]  <= 64'h0000000000008082; 
        RC[2]  <= 64'h800000000000808A; 
        RC[3]  <= 64'h8000000080008000; 
        RC[4]  <= 64'h000000000000808B; 
        RC[5]  <= 64'h0000000080000001; 
        RC[6]  <= 64'h8000000080008081; 
        RC[7]  <= 64'h8000000000008009; 
        RC[8]  <= 64'h000000000000008A; 
        RC[9]  <= 64'h0000000000000088; 
        RC[10] <= 64'h0000000080008009; 
        RC[11] <= 64'h000000008000000A; 
        RC[12] <= 64'h000000008000808B; 
        RC[13] <= 64'h800000000000008B; 
        RC[14] <= 64'h8000000000008089; 
        RC[15] <= 64'h8000000000008003; 
        RC[16] <= 64'h8000000000008002; 
        RC[17] <= 64'h8000000000000080; 
        RC[18] <= 64'h000000000000800A; 
        RC[19] <= 64'h800000008000000A; 
        RC[20] <= 64'h8000000080008081; 
        RC[21] <= 64'h8000000000008080; 
        RC[22] <= 64'h0000000080000001; 
        RC[23] <= 64'h8000000080008008; 
end

//str to state array(A[x][y][z]=S[64*(5*y+x)+z])
generate
    for(genvar zz = 0; zz < 64; zz = zz + 1) begin: str_to_arr
        assign A[0][0][zz] = S_out4[zz];
        assign A[1][0][zz] = S_out4[64 + zz];
        assign A[2][0][zz] = S_out4[128 + zz];
        assign A[3][0][zz] = S_out4[192 + zz];
        assign A[4][0][zz] = S_out4[256 + zz];

        assign A[0][1][zz] = S_out4[320 + zz];
        assign A[1][1][zz] = S_out4[384 + zz];
        assign A[2][1][zz] = S_out4[448 + zz];
        assign A[3][1][zz] = S_out4[512 + zz];
        assign A[4][1][zz] = S_out4[576 + zz];

        assign A[0][2][zz] = S_out4[640 + zz];
        assign A[1][2][zz] = S_out4[704 + zz];
        assign A[2][2][zz] = S_out4[768 + zz];
        assign A[3][2][zz] = S_out4[832 + zz];
        assign A[4][2][zz] = S_out4[896 + zz];

        assign A[0][3][zz] = S_out4[960 + zz];
        assign A[1][3][zz] = S_out4[1024 + zz];
        assign A[2][3][zz] = S_out4[1088 + zz];
        assign A[3][3][zz] = S_out4[1152 + zz];
        assign A[4][3][zz] = S_out4[1216 + zz];

        assign A[0][4][zz] = S_out4[1280 + zz];
        assign A[1][4][zz] = S_out4[1344 + zz];
        assign A[2][4][zz] = S_out4[1408 + zz];
        assign A[3][4][zz] = S_out4[1472 + zz];
        assign A[4][4][zz] = S_out4[1536 + zz];
    end
endgenerate

//A_out[0][0][z1]=A[0][0][z1] ^ RC[z1];
generate
        for(genvar i0=0;i0<64;i0=i0+1)begin: Lane0_0
                assign A_out[0][0][i0]=A[0][0][i0] ^ RC[ir][i0];
        end
endgenerate

//A_out[x][y][z]=A[x][y][z]
generate
        for(genvar i1=0;i1<64;i1=i1+1)begin: otherLane
                assign A_out[1][0][i1]=A[1][0][i1];
                assign A_out[2][0][i1]=A[2][0][i1];
                assign A_out[3][0][i1]=A[3][0][i1];
                assign A_out[4][0][i1]=A[4][0][i1];

                assign A_out[0][1][i1]=A[0][1][i1];
                assign A_out[1][1][i1]=A[1][1][i1];
                assign A_out[2][1][i1]=A[2][1][i1];
                assign A_out[3][1][i1]=A[3][1][i1];
                assign A_out[4][1][i1]=A[4][1][i1];

                assign A_out[0][2][i1]=A[0][2][i1];
                assign A_out[1][2][i1]=A[1][2][i1];
                assign A_out[2][2][i1]=A[2][2][i1];
                assign A_out[3][2][i1]=A[3][2][i1];
                assign A_out[4][2][i1]=A[4][2][i1];

                assign A_out[0][3][i1]=A[0][3][i1];
                assign A_out[1][3][i1]=A[1][3][i1];
                assign A_out[2][3][i1]=A[2][3][i1];
                assign A_out[3][3][i1]=A[3][3][i1];
                assign A_out[4][3][i1]=A[4][3][i1];

                assign A_out[0][4][i1]=A[0][4][i1];
                assign A_out[1][4][i1]=A[1][4][i1];
                assign A_out[2][4][i1]=A[2][4][i1];
                assign A_out[3][4][i1]=A[3][4][i1];
                assign A_out[4][4][i1]=A[4][4][i1];
        end
endgenerate

//Convert state array into str
generate
    for(genvar Z = 0; Z < 64; Z = Z + 1) begin: arr_to_str
        assign S_out[Z] = A_out[0][0][Z]; 
        assign S_out[Z + 64] = A_out[1][0][Z];
        assign S_out[Z + 128] = A_out[2][0][Z];
        assign S_out[Z + 192] = A_out[3][0][Z];
        assign S_out[Z + 256] = A_out[4][0][Z];
        
        assign S_out[Z + 320] = A_out[0][1][Z];       
        assign S_out[Z + 384] = A_out[1][1][Z];
        assign S_out[Z + 448] = A_out[2][1][Z];
        assign S_out[Z + 512] = A_out[3][1][Z];
        assign S_out[Z + 576] = A_out[4][1][Z];
        
        assign S_out[Z + 640] = A_out[0][2][Z];
        assign S_out[Z + 704] = A_out[1][2][Z];
        assign S_out[Z + 768] = A_out[2][2][Z];
        assign S_out[Z + 832] = A_out[3][2][Z];
        assign S_out[Z + 896] = A_out[4][2][Z];
        
        assign S_out[Z + 960] = A_out[0][3][Z];
        assign S_out[Z + 1024] = A_out[1][3][Z];
        assign S_out[Z + 1088] = A_out[2][3][Z];
        assign S_out[Z + 1152] = A_out[3][3][Z];
        assign S_out[Z + 1216] = A_out[4][3][Z];
        
        assign S_out[Z + 1280] = A_out[0][4][Z];
        assign S_out[Z + 1344] = A_out[1][4][Z];
        assign S_out[Z + 1408] = A_out[2][4][Z];
        assign S_out[Z + 1472] = A_out[3][4][Z];
        assign S_out[Z + 1536] = A_out[4][4][Z];
    end
endgenerate

endmodule