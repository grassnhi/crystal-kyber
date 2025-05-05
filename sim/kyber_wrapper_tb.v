`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 11:43:18 AM
// Design Name: 
// Module Name: kyber_wrapper_tb
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

module kyber_wrapper_tb;
    reg [11:0] reg_addr;
    reg reg_clk;
    reg reg_en;
    wire [31:0] reg_rddata;
    reg reg_rst;
    reg [3:0] reg_we;
    reg [31:0] reg_wrdata;

    wire [7:0] addr_br_kb;
    wire en_br_kb;
    wire [15:0] we_br_kb;
    wire [127:0] wrdata_br_kb;
    reg [127:0] rddata_br_kb;
    
    wire [7:0] addr_kb_br;
    wire en_kb_br;
    wire [15:0] we_kb_br;
    wire [127:0] wrdata_kb_br;
    reg [127:0] rddata_kb_br;
    
    reg [127:0] reg_mem [0:511]; // Register memory model, initialized to zero
    reg [127:0] bram_mem [0:600]; // BRAM memory model, initialized to zero
    
    reg [6399:0] pk_in;
    reg [6143:0] sk_in;
    reg [6143:0] c_in;
    reg [511:0] m_r;
    integer i;
    
    kyber_wrapper uut (
        .reg_addr(reg_addr),
        .reg_clk(reg_clk),
        .reg_en(reg_en),
        .reg_rddata(reg_rddata),
        .reg_rst(reg_rst),
        .reg_we(reg_we),
        .reg_wrdata(reg_wrdata),
        .addr_br_kb(addr_br_kb),
        .en_br_kb(en_br_kb),
        .rddata_br_kb(rddata_br_kb),
        .we_br_kb(we_br_kb),
        .wrdata_br_kb(wrdata_br_kb),
        .addr_kb_br(addr_kb_br),
        .en_kb_br(en_kb_br),
        .rddata_kb_br(rddata_kb_br),
        .we_kb_br(we_kb_br),
        .wrdata_kb_br(wrdata_kb_br)
    );

    
    always #5 reg_clk = ~reg_clk; // Clock generation
    
    initial begin
        // Initialize memories to zero
        for (i = 0; i < 512; i = i + 1) begin
            reg_mem[i] = 32'd0;
            bram_mem[i] = 32'd0;
            pk_in = 6400'h12a224a52c887d48b9514a9614d6531196becd7c7a07ab493e79e80e08445006681906785f897a1703dc445451bca3e0cfe8a141e1d62b913c85e7914c808fcd487bbd305b103a1d155bda93b88cadf2314d138f7c53b69224fc3b79118622559f87503d9c2476d46314f31a1a9ce923c5c1ba42423fb3907996d18f70e43a756e2bfc9c7b74629b111fc98891ad28f76cbb207e73e6ba43d72a6133b69b53a05a6c04a505a28b913a193e4214cb299c4c1c85fb00f6dac5e20aa505a96c527534aa774518fb8a125a36eca908396797e5079496c317216f557b5abed2ff1f20d190609717c04c826c3d0f61843f6c573b831d57e20b2ca26bb8110d4521b4c741fc695a7e8d1142b4d28d93f34540fb7a0218119cec3e62d4f9adc19206aceea814f17825b1a0135731a61f0395514dec9a87dbfe4915ba0db76b4ad03ca131c61819a8b2a1e6871a65aa3c0c4cfc5abe7ce2bb1b1c81f2d777c7fe46d3e10ed6423cc672af104e7e2599cd359c43b137b4566235fb311b966d4d214278c1b757c5db8a528d0b381bb6ecf238847f845a8f05369f38159aabc45a5f5820300b1d6865bc29050e6cf279737c0b5c5befb4b94c9fcc6055e8e14a51219102ac1ca757bbba7290f2b3752c3eb666ada33bed05f11049ac0e53d2161f9b28944ba93b1bf9a3fafc52b0a9cf67bb4a6104932c048b6bf100cc01c7c69cc1e6ecbe150d8fc69922f0480a14de173b29639a1e9fe19631c7d06624b556426f4eda1aa092fa605ba780b95301419b6dfb69614ae25c783c2b53ed89386d1b96244d18d57a4c187766153d57e950a5b2a0b3b62c197c995c728c52d089294ca020758184755935467e4434a6160531938407b9e18b26a78017aa14f332ba17508fbbcc9ff0a5954bbd9a33a728b47d27a04447c8256609a75c21d4c963de8625f141288a9ad2861500439acc6f13cbf8b5882015d63c78634e4854855297a85ed7b920e2c15c24a55003406c98ad9a7a7904396ebf092a7961783ab1c29439772eb7033549d06311f01fc3e115fa5a00ca4970accca4d9c643fa0842266f130520b34b82c0e90df4028697cf492f6e504e8beb8d5059d20617b577774d1414342f3f5f20;
            sk_in = 6144'h96346acc1ba1b0085399d7ec5978e73ed15c70c040c024f3aacafd01a33167a96b1ddc8968a8b055682727f6eacbc3f672719dc3b73a6f96a676b8e8985715cfa85ea8701556f5cac33230583b1a92cbfdbbacd62bf0d3859bc932a8b86e788a0258ac80a148c2d3dd56b32eb116223ccbc09341fb702a7d96527c19083fa2dafd68a2a105c4008fc8e55f5a3b030261928944746636aefa9765f059af33f36aa20f8c3ccda8060b0151b6cf4c68bc3452cd303f7d7b7781f0617304eea5802b813adcce450b30b820965c0a8a3ab9884c9fb738b6385b03799c1fa202753d61e1c1b08c3d41392a100b54b3cb9a9a7821e8b25e120d1f3541b739871fe424b7a4ddb3977f42f774bb7b5802c6a31788111959730d918fa177e17203627629123bc03a7b527956e53b8f786c42035fc1417626c9058159dd5b77dc7f6ca7c172562e6a6ec2e2d1a1e665ac22ca6502b31e873c94d01b3ba8e4a0a782ced36e96fbbb5958a1ab4a2b00531690ac0d213552ac971b06f0f57d27092b96a042a26a3b27472742b39327b7cdf25952120166e17f2d80cf09ec01565cf2cae4cd9354e0a7031eb4e283ab07994fd86b514638845b91a777e9341815cbdb17828030adb23347dcce15618e213378b202032457e93aa4cc8afc8aa2668537964820f4b347bccec412baa6190e47078bcc985b2b67573bb21ea628cc5daaff7cdc0fb0ca5c143a81c079663b8c2f5f16fc6d712cbc168dbe025a9234fd35a324a3d4258f999a41986233c153b8a3bd84d4db1b757831b8242ae9ebb1282d4d3bca7246b2457bd009018258e598b8c44a9b385f4856549364a385b2667178354f9a555712db3183ef0a797402f1fe1161ef167c0619dbd0aa12960dfc9da8c46572a4828b34ad5434ce8435a7c8c7eb1cb9835858b299cc087516bf9078ee5aa4e4bea4c932d387afe9e03081a80d055a6ae627cb01eccf9cc685e0a979764ebe547b10a1134037377902b479c10bcb999c4993f6ce537b6982520bf41d37e516700614c9c78e17c1b80e619723896038e89429f3227adb589c708d2c90c39f154d550b1b;
            m_r = 512'hb11bc95746c38e92f249428e35b833ab3031bae51f742958a8513399732c6fb6_a4449c1f6511c07619ada306a1498a233a419aa003a305d726a90328209e18da;
            c_in = 6144'h80ded410d1a394f693742d91cffe0a878448ba56693fb55aebd0128beb4d5d84d941f59765b0249a019c4275477e743af680a6e60019c65b37fe61048776c32571b1e2be8d82dd9042977f7acb268fbf5d1d245ede781e7c1b45b99d1080f7f539a6d32398cd3867d5e35a57dd9ff97d222124499dbfa7e8c93643484ce23aab26d23ca5a903a533071f81524725d7c76022e11521997f1e9e8532673010c67fe3fcb6aa7d397fd675174ee1ddf6d85a0f9d4e92aa8d90154dae8a7c431318a15b056479a8d9e1463afa6abe7a0959a738df90b0ac8c71908a7eb9e1a3cfdf5b1b25849a18dab2e1a3c54c66dacd0248f5c487f0f44ad61715d44b84fd8d943ba1e91c84557fd6e9aa14ecbbc8c96be9df426580a10ad4491fdcc40136be36b467d140eaae5ec1486de909e4b12461294077c3f77c3704e980fa68a6781aa5bb873fcc24d6654140577c3cd6aec104e5f073df9ec017f45e951f1d704f0c5fcd3466301b3c1e7813a158339beef496dc01b830fc2561fdb5f98a06a06647bc51478e94ebe404bc70fd696c5ef2545c40204e2b168dad055de87bba82e929ec96f2ded61b24d138e7c694aafadce91e06abcfd72efb5f4d7644a0b2a8dd66d0edb5544509f6eb03446eae4ea0fdf9277737fb102e38720ef13d880f758f6c765cde2e6d10b8f6f846f5f0ed0ce1216feca58ee74643b101f685ccb07ee56c9e52f08603e9899bc05c5b343faa917c193183c469c7a4465709b3a69729f25a4de3a2793237182792b243b747ae1e35d9a8fd0a5a9c8a45efd951cf1ea539a1ae02a4c2e25357f7383b92a1da1f6022ba809983e593d74ec5252632688f623fe52a3eefacbe34dedf1ef0d1fc50c83f0ba077e5cc35a4dc17818cb018290e1a2da18abc9155f83fdf77841a2c34e9fb911dd576d3a6433c0f05c3332132efc67f93cf607cf070de79c96abb789faccd0e9c29689ceff1f75681ed8e999853134045862278fb0e391f02542f60f17e3c8ce7ab8e818336fc15d8abbabcc9003ebacea8e184cad7e1a89f95c60a5fb4c8621f8db88c4d73d4b1917144671701b928e9;
            if(i < 50) begin
                bram_mem[i] = pk_in[i*128 +: 128];
            end 
            if( i >= 50 && i < 54) begin
                bram_mem[i] = m_r[(i-50)*128 +: 128];
            end
            if( i >= 54 && i < 102) begin
                bram_mem[i] = sk_in[(i-54)*128 +: 128];
            end
            if( i >= 102 && i < 150) begin
                bram_mem[i] = c_in[(i-102)*128 +: 128];
            end
        end
        
        // Initialize signals
        reg_clk = 0;
        reg_rst = 1;
        reg_en = 0;
        reg_we = 4'd0;
        reg_wrdata = 32'd0;
        
        #1000 reg_rst = 0;
        
        // Unused register address
        reg_addr = 11'h3F;
        reg_wrdata = 32'hADBEEF;
        reg_we = 4'hF;
        reg_en = 1;
        #10;
        
        $display("Mode 0:");
        
        // Mode then start
        reg_addr = 11'b11;
        reg_wrdata = 32'b0;
        #10;
        reg_addr = 11'b1;
        reg_wrdata = 32'b0;
        #10
        reg_addr = 11'b1;
        reg_wrdata = 32'b01;
        #10;
        reg_we = 4'h0;
        #10;
        // Wait finish
        reg_we = 4'h0;
        reg_addr = 11'b100;
        #50;
        while(reg_rddata != 1) begin
            #10;
        end
        reg_en = 0;
        #200;
        
        $display("Mode 1:");
        
        reg_we = 4'hF;
        reg_en = 1;
        #10;
        // Mode then start
        reg_addr = 11'b11;
        reg_wrdata = 32'b01;
        #10;
        reg_addr = 11'b1;
        reg_wrdata = 32'b0;
        #10
        reg_addr = 11'b1;
        reg_wrdata = 32'b01;
        #10;
        reg_we = 4'h0;
        #10;
        // Wait finish
        reg_we = 4'h0;
        reg_addr = 11'b100;
        #50;
        while(reg_rddata != 1) begin
            #10;
        end
        reg_en = 0;
        #200;
        
        $display("Mode 2:");
        
        reg_we = 4'hF;
        reg_en = 1;
        #10;
        // Mode then start
        reg_addr = 11'b11;
        reg_wrdata = 32'b10;
        #10;
        reg_addr = 11'b1;
        reg_wrdata = 32'b0;
        #10
        reg_addr = 11'b1;
        reg_wrdata = 32'b01;
        #10;
        reg_we = 4'h0;
        #10;
        // Wait finish
        reg_we = 4'h0;
        reg_addr = 11'b100;
        #50;
        while(reg_rddata != 1) begin
            #10;
        end
        reg_en = 0;
        #200;
                
        $display("END");
        $stop;
    end
    
    always @(posedge reg_clk) begin
        if (en_br_kb) begin
            if (we_br_kb == 16'h0) begin
//                bram_mem[addr_kb_br] <= wrdata_kb_br;
//            end else begin
                rddata_br_kb <= bram_mem[addr_br_kb];
            end
        end
    end
    
//    always @(posedge reg_clk) begin
//        if (reg_en) begin
//            if (reg_we != 16'h0000) begin
//                reg_mem[reg_addr] <= reg_rddata;
//            end else begin
//                reg_wrdata <= reg_mem[reg_addr];
//            end
//        end
//    end
    
    always @(posedge reg_clk) begin
        if(en_kb_br & (we_kb_br == 16'hFFFF)) begin
            $display("Time: %t | reg_wrdata: %h | wrdata_bram: %h", $time, reg_wrdata, wrdata_kb_br);
        end
    end 
    
    initial begin
        $dumpfile("kyber_wrapper.vcd");       // VCD output file
        $dumpvars(0, kyber_wrapper_tb); // Dump everything in this testbench
    end
    
endmodule