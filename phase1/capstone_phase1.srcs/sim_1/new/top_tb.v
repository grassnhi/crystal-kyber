`timescale 1ns/100ps
`include "../../sources_1/imports/phase1/top/top.v"
module top_tb;
reg clk;
reg rst;
reg start;
reg [1:0] mode;
reg [255:0] random_coin;
reg [255:0] m_in;
reg [6399:0]pk_in;// 12*256*2 + 256
reg [6143:0]sk_in;// 12*256*2
reg [6143:0]c_in; // 10*256*2 + 4*256

wire [255:0] m_out;
wire [6399:0]pk_out;// 12*256*2 + 256
wire [6143:0]sk_out;// 12*256*2
wire [6143:0]c_out; // 10*256*2 + 4*256

reg [255:0] m_tmp;
reg [6399:0]pk_tmp;// 12*256*2 + 256
reg [6143:0]sk_tmp;// 12*256*2
reg [6143:0]c_tmp; // 10*256*2 + 4*256

wire finish;

top kyber(
    clk,
    rst,
    start,
    mode,
    random_coin,
    m_in,
    pk_in,// 12*256*2 + 256
    sk_in,// 12*256*2
    c_in, // 10*256*2 + 4*256
    m_out,
    pk_out,// 12*256*2 + 256
    sk_out,// 12*256*2
    c_out, // 10*256*2 + 4*256
    finish
);

always #5 clk = ~clk;

initial begin
    clk = 1'b0;
    rst = 0;
    start = 0;
    mode = 0;
    random_coin = 0;
    m_in = 0;
    pk_in = 0;
    sk_in = 0;
    c_in = 0;
    #10
    rst = 1;
    #10 rst = 0;
    $display("------------------------------------KeyGen------------------------------------");
    mode = 0; // KeyGen
    random_coin = 1;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    pk_tmp = pk_out;
    sk_tmp = sk_out;
    $display("pk : %h", pk_tmp);
    $display("sk : %h", sk_tmp);

    $display("------------------------------------Enc------------------------------------");
    mode = 1; // Enc
    m_in = 15;
    pk_in = pk_tmp;
    random_coin = 2;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    c_tmp = c_out;
    $display("m_in  : %h", m_in);
    $display("c  : %h", c_tmp);
    
    $display("------------------------------------Dec------------------------------------");
    mode = 2; // Dec
    c_in = c_tmp;
    sk_in = sk_tmp;
    random_coin = 3;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    m_tmp = m_out;
    $display("m  : %h", m_tmp);
    if (m_tmp == m_in)
        $display("Pass");
    else
        $display("Fail");
    #10 
    
    $display("------------------------------------Enc------------------------------------");
    mode = 1; // Enc
    m_in = 256'h123456789abcdef123456789abcdef12;
    pk_in = pk_tmp;
    random_coin = 256'h112233445566778899aabbccddeeffaa;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    c_tmp = c_out;
    $display("m_in  : %h", m_in);
    $display("c  : %h", c_tmp);
    
    $display("------------------------------------Dec------------------------------------");
    mode = 2; // Dec
    c_in = c_tmp;
    sk_in = sk_tmp;
    random_coin = 3;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    m_tmp = m_out;
    $display("m  : %h", m_tmp);
    if (m_tmp == m_in)
        $display("Pass");
    else
        $display("Fail");
    #10 

    $display("------------------------------------KeyGen------------------------------------");
    mode = 0; // KeyGen
    random_coin = 256'h123456789abcdef123456789abcdef12;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    pk_tmp = pk_out;
    sk_tmp = sk_out;
    $display("pk : %h", pk_tmp);
    $display("sk : %h", sk_tmp);

    $display("------------------------------------Enc------------------------------------");
    mode = 1; // Enc
    m_in = 256'h11111111111111111111111111111111;
    pk_in = pk_tmp;
    random_coin = 256'h99887766554433221100aabbccddeeff;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    c_tmp = c_out;
    $display("m_in  : %h", m_in);
    $display("c  : %h", c_tmp);
    
    $display("------------------------------------Dec------------------------------------");
    mode = 2; // Dec
    c_in = c_tmp;
    sk_in = sk_tmp;
    random_coin = 256'h12345678223456783234567842345678;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    m_tmp = m_out;
    $display("m  : %h", m_tmp);
    if (m_tmp == m_in)
        $display("Pass");
    else
        $display("Fail");

    $display("------------------------------------KeyGen------------------------------------");
    mode = 0; // KeyGen
    random_coin = 256'h123456789abcdef123ad6789abcdef12;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    pk_tmp = pk_out;
    sk_tmp = sk_out;
    $display("pk : %h", pk_tmp);
    $display("sk : %h", sk_tmp);

    $display("------------------------------------Enc------------------------------------");
    mode = 1; // Enc
    m_in = 256'h1111111111111111111111111ab11111;
    pk_in = pk_tmp;
    random_coin = 256'h99887766554433221100aabbccddeeff;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    c_tmp = c_out;
    $display("m_in  : %h", m_in);
    $display("c  : %h", c_tmp);
    
    $display("------------------------------------Dec------------------------------------");
    mode = 2; // Dec
    c_in = c_tmp;
    sk_in = sk_tmp;
    random_coin = 256'hab345678223456783234567842345678;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    m_tmp = m_out;
    $display("m  : %h", m_tmp);
    if (m_tmp == m_in)
        $display("Pass");
    else
        $display("Fail");
    
    // Test Case 1: Key Generation
    $display("------------------------------------KeyGen------------------------------------");
    mode = 0; // KeyGen
    random_coin = 256'hdeadbeef1234567890abcdef98765432;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    pk_tmp = pk_out;
    sk_tmp = sk_out;
    $display("pk : %h", pk_tmp);
    $display("sk : %h", sk_tmp);

    // Test Case 2: Encryption
    $display("------------------------------------Enc------------------------------------");
    mode = 1; // Enc
    m_in = 256'habcdefabcdefabcdefabcdefabcdefabcd;
    pk_in = pk_tmp;
    random_coin = 256'h1234567890abcdef1234567890abcdef;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    c_tmp = c_out;
    $display("m_in  : %h", m_in);
    $display("c  : %h", c_tmp);

    // Test Case 3: Decryption
    $display("------------------------------------Dec------------------------------------");
    mode = 2; // Dec
    c_in = c_tmp;
    sk_in = sk_tmp;
    random_coin = 256'hdeadbeefabcdef0123456789abcdef01;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    m_tmp = m_out;
    $display("m  : %h", m_tmp);
    if (m_tmp == m_in)
        $display("Pass");
    else
        $display("Fail");

    // Test Case 4: Encryption with Different Inputs
    $display("------------------------------------Enc------------------------------------");
    mode = 1; // Enc
    m_in = 256'hfedcba9876543210abcdefabcdef1234;
    pk_in = pk_tmp;
    random_coin = 256'h9876543210abcdef1234567890abcdef;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    c_tmp = c_out;
    $display("m_in  : %h", m_in);
    $display("c  : %h", c_tmp);

    // Test Case 5: Decryption with New Inputs
    $display("------------------------------------Dec------------------------------------");
    mode = 2; // Dec
    c_in = c_tmp;
    sk_in = sk_tmp;
    random_coin = 256'habcdef1234567890abcdef1234567890;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    m_tmp = m_out;
    $display("m  : %h", m_tmp);
    if (m_tmp == m_in)
        $display("Pass");
    else
        $display("Fail");

    // Test Case 6: Key Generation with New Random Coin
    $display("------------------------------------KeyGen------------------------------------");
    mode = 0; // KeyGen
    random_coin = 256'h112233445566778899aabbccddeeffaa;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    pk_tmp = pk_out;
    sk_tmp = sk_out;
    $display("pk : %h", pk_tmp);
    $display("sk : %h", sk_tmp);

    // Test Case 7: Encryption with New Data
    $display("------------------------------------Enc------------------------------------");
    mode = 1; // Enc
    m_in = 256'habcdef1234567890abcdefabcdef12345678;
    pk_in = pk_tmp;
    random_coin = 256'h9876543210abcdef1234567890abcdef;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    c_tmp = c_out;
    $display("m_in  : %h", m_in);
    $display("c  : %h", c_tmp);

    // Test Case 8: Decryption with Updated Values
    $display("------------------------------------Dec------------------------------------");
    mode = 2; // Dec
    c_in = c_tmp;
    sk_in = sk_tmp;
    random_coin = 256'hfeedface12345678abcdefabcdefabcd;
    start = 1;
    #10 start = 0; #10
    while(~finish) begin
        #10;
    end
    #10
    m_tmp = m_out;
    $display("m  : %h", m_tmp);
    if (m_tmp == m_in)
        $display("Pass");
    else
        $display("Fail");
        
    #10 
    $display("END");
    $finish;
end

endmodule