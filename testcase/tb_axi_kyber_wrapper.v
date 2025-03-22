`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2025 10:02:43 AM
// Design Name: 
// Module Name: tb_axi_kyber_wrapper
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


module tb_axi_kyber_wrapper;
    reg         s_axi_aclk;
    reg         s_axi_aresetn;
    reg [16:0]  s_axi_araddr;     // 17-bit Address
    reg [1:0]   s_axi_arburst;
    reg [3:0]   s_axi_arcache;
    reg [7:0]   s_axi_arlen;
    reg         s_axi_arlock;
    reg [2:0]   s_axi_arprot;
    reg [2:0]   s_axi_arsize;
    reg         s_axi_arvalid;
    reg [16:0]  s_axi_awaddr;     // 17-bit Address
    reg [1:0]   s_axi_awburst;
    reg [3:0]   s_axi_awcache;
    reg [7:0]   s_axi_awlen;
    reg         s_axi_awlock;
    reg [2:0]   s_axi_awprot;
    reg [2:0]   s_axi_awsize;
    reg         s_axi_awvalid;
    reg         s_axi_bready;
    reg [127:0] s_axi_wdata;      // 128-bit Data
    reg [15:0]  s_axi_wstrb;      // 16-bit Write strobe (for 128-bit data)
    reg         s_axi_wlast;
    reg         s_axi_wvalid;
    reg         s_axi_rready;

    // AXI interface - Outputs
    wire        s_axi_arready;
    wire        s_axi_awready;
    wire [1:0]  s_axi_bresp;
    wire        s_axi_bvalid;
    wire [127:0]s_axi_rdata;      // 128-bit Data
    wire        s_axi_rlast;
    wire [1:0]  s_axi_rresp;
    wire        s_axi_rvalid;
    wire        s_axi_wready;
    
    wire [6399:0] pk_out;
    wire [6143:0] sk_out;
    wire [6143:0] c_out;
    wire [255:0] m_out;
    
    reg [127:0] rdata;
    reg [127:0] rdata1;
    reg [127:0] rdata2;

    reg [255:0] m_tmp;
    
    integer i;

    // Instantiate the Unit Under Test (UUT)
    axi_kyber_wrapper uut (
        .s_axi_aclk(s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arcache(s_axi_arcache),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arlock(s_axi_arlock),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awcache(s_axi_awcache),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awlock(s_axi_awlock),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_rready(s_axi_rready),

        .s_axi_arready(s_axi_arready),
        .s_axi_awready(s_axi_awready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wready(s_axi_wready)
    );

    // Clock generation
    initial begin
        s_axi_aclk = 0;
        forever #5 s_axi_aclk = ~s_axi_aclk; // 100 MHz clock
    end

    // Task to apply reset
    task apply_reset;
    begin
        s_axi_aresetn = 0;
        #20;
        s_axi_aresetn = 1;
    end
    endtask

    // Task to perform a write transaction
    task write_axi;
        input [16:0] addr;
        input [127:0] data;
    begin
        s_axi_awaddr = addr;
        s_axi_awlen   = 8'b0000;    // Single transfer (burst length = 1)
        s_axi_awsize  = 3'b100;     
        s_axi_awburst = 2'b00;      // Burst type = Fixed (no increment)
        s_axi_awvalid = 1;
        
        wait (s_axi_awready) 
        @(negedge s_axi_aclk);
        s_axi_awvalid = 0;
        
        s_axi_wdata = data;
        s_axi_wvalid = 1;
        s_axi_wlast = 1;
        wait (s_axi_wready) 
        @(negedge s_axi_aclk);
        s_axi_wvalid = 0;
        s_axi_wlast = 0;
    end
    endtask

    // Task to perform a read transaction
    task read_axi;
        input [16:0] addr;
        output [127:0] data_out;
    begin
        @(negedge s_axi_aclk);
        s_axi_araddr = addr;
        s_axi_arlen   = 8'b0000;    // Single transfer (burst length = 1)
        s_axi_arsize  = 3'b100;     
        s_axi_arburst = 2'b00;      // Burst type = Fixed (no increment)
        s_axi_arvalid = 1;
        @(posedge s_axi_aclk);
        wait (s_axi_arready) @(negedge s_axi_aclk);
        s_axi_arvalid = 0;
        @(posedge s_axi_aclk);
        wait (s_axi_rvalid) @(negedge s_axi_aclk);
        data_out = s_axi_rdata;
    end
    endtask

    // Test sequence
    initial begin
        // Initialize Inputs
        s_axi_aclk = 0;
        s_axi_aresetn = 0;
        s_axi_araddr = 32'b0;
        s_axi_arburst = 2'b0;
        s_axi_arcache = 4'b0;
        s_axi_arlen = 8'b0;
        s_axi_arlock = 2'b0;
        s_axi_arprot = 3'b0;
        s_axi_arsize = 3'b0;
        s_axi_arvalid = 0;
        s_axi_awaddr = 32'b0;
        s_axi_awburst = 2'b0;
        s_axi_awcache = 4'b0;
        s_axi_awlen = 8'b0;
        s_axi_awlock = 2'b0;
        s_axi_awprot = 3'b0;
        s_axi_awsize = 3'b0;
        s_axi_awvalid = 0;
        s_axi_bready = 0;
        s_axi_wdata = 32'b0;
        s_axi_wstrb = 16'hFFFF;
        s_axi_wlast = 0;
        s_axi_wvalid = 0;
        s_axi_rready = 1;
        s_axi_bready = 1;

        // Apply reset
        apply_reset;
        
        // write_burst(17'd65536, 8'd24, 3'b100, 2'b01); // Len = 24 (25 transfers), Size = 16 bytes, INCR
        // write_burst(17'd32768, 8'd23, 3'b100, 2'b01);  
        // write_burst(17'd16384, 8'd23, 3'b100, 2'b01);
        // write_burst(17'd32800, 8'd22, 3'b100, 2'b01);
        
        // read_burst(17'd65536, 8'd24, 3'b100, 2'b01); // Len = 24 (25 transfers), Size = 16 bytes, INCR
        // read_burst(17'd32768, 8'd23, 3'b100, 2'b01);  
        // read_burst(17'd16384, 8'd23, 3'b100, 2'b01);
        // read_burst(17'd22222, 8'd33, 3'b100, 2'b01);
        
        $display("------------------------------------KeyGen------------------------------------");
        write_burst(17'd65536, 8'd49, 3'b100, 2'b01, 6400'h12a224a52c887d48b9514a9614d6531196becd7c7a07ab493e79e80e08445006681906785f897a1703dc445451bca3e0cfe8a141e1d62b913c85e7914c808fcd487bbd305b103a1d155bda93b88cadf2314d138f7c53b69224fc3b79118622559f87503d9c2476d46314f31a1a9ce923c5c1ba42423fb3907996d18f70e43a756e2bfc9c7b74629b111fc98891ad28f76cbb207e73e6ba43d72a6133b69b53a05a6c04a505a28b913a193e4214cb299c4c1c85fb00f6dac5e20aa505a96c527534aa774518fb8a125a36eca908396797e5079496c317216f557b5abed2ff1f20d190609717c04c826c3d0f61843f6c573b831d57e20b2ca26bb8110d4521b4c741fc695a7e8d1142b4d28d93f34540fb7a0218119cec3e62d4f9adc19206aceea814f17825b1a0135731a61f0395514dec9a87dbfe4915ba0db76b4ad03ca131c61819a8b2a1e6871a65aa3c0c4cfc5abe7ce2bb1b1c81f2d777c7fe46d3e10ed6423cc672af104e7e2599cd359c43b137b4566235fb311b966d4d214278c1b757c5db8a528d0b381bb6ecf238847f845a8f05369f38159aabc45a5f5820300b1d6865bc29050e6cf279737c0b5c5befb4b94c9fcc6055e8e14a51219102ac1ca757bbba7290f2b3752c3eb666ada33bed05f11049ac0e53d2161f9b28944ba93b1bf9a3fafc52b0a9cf67bb4a6104932c048b6bf100cc01c7c69cc1e6ecbe150d8fc69922f0480a14de173b29639a1e9fe19631c7d06624b556426f4eda1aa092fa605ba780b95301419b6dfb69614ae25c783c2b53ed89386d1b96244d18d57a4c187766153d57e950a5b2a0b3b62c197c995c728c52d089294ca020758184755935467e4434a6160531938407b9e18b26a78017aa14f332ba17508fbbcc9ff0a5954bbd9a33a728b47d27a04447c8256609a75c21d4c963de8625f141288a9ad2861500439acc6f13cbf8b5882015d63c78634e4854855297a85ed7b920e2c15c24a55003406c98ad9a7a7904396ebf092a7961783ab1c29439772eb7033549d06311f01fc3e115fa5a00ca4970accca4d9c643fa0842266f130520b34b82c0e90df4028697cf492f6e504e8beb8d5059d20617b577774d1414342f3f5f20);
        write_burst(17'd66336, 8'd3, 3'b100, 2'b01, 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_0000000f_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000002);
        write_burst(17'd66400, 8'd47, 3'b100, 2'b01, 6400'h96346acc1ba1b0085399d7ec5978e73ed15c70c040c024f3aacafd01a33167a96b1ddc8968a8b055682727f6eacbc3f672719dc3b73a6f96a676b8e8985715cfa85ea8701556f5cac33230583b1a92cbfdbbacd62bf0d3859bc932a8b86e788a0258ac80a148c2d3dd56b32eb116223ccbc09341fb702a7d96527c19083fa2dafd68a2a105c4008fc8e55f5a3b030261928944746636aefa9765f059af33f36aa20f8c3ccda8060b0151b6cf4c68bc3452cd303f7d7b7781f0617304eea5802b813adcce450b30b820965c0a8a3ab9884c9fb738b6385b03799c1fa202753d61e1c1b08c3d41392a100b54b3cb9a9a7821e8b25e120d1f3541b739871fe424b7a4ddb3977f42f774bb7b5802c6a31788111959730d918fa177e17203627629123bc03a7b527956e53b8f786c42035fc1417626c9058159dd5b77dc7f6ca7c172562e6a6ec2e2d1a1e665ac22ca6502b31e873c94d01b3ba8e4a0a782ced36e96fbbb5958a1ab4a2b00531690ac0d213552ac971b06f0f57d27092b96a042a26a3b27472742b39327b7cdf25952120166e17f2d80cf09ec01565cf2cae4cd9354e0a7031eb4e283ab07994fd86b514638845b91a777e9341815cbdb17828030adb23347dcce15618e213378b202032457e93aa4cc8afc8aa2668537964820f4b347bccec412baa6190e47078bcc985b2b67573bb21ea628cc5daaff7cdc0fb0ca5c143a81c079663b8c2f5f16fc6d712cbc168dbe025a9234fd35a324a3d4258f999a41986233c153b8a3bd84d4db1b757831b8242ae9ebb1282d4d3bca7246b2457bd009018258e598b8c44a9b385f4856549364a385b2667178354f9a555712db3183ef0a797402f1fe1161ef167c0619dbd0aa12960dfc9da8c46572a4828b34ad5434ce8435a7c8c7eb1cb9835858b299cc087516bf9078ee5aa4e4bea4c932d387afe9e03081a80d055a6ae627cb01eccf9cc685e0a979764ebe547b10a1134037377902b479c10bcb999c4993f6ce537b6982520bf41d37e516700614c9c78e17c1b80e619723896038e89429f3227adb589c708d2c90c39f154d550b1b); 

        
        $display("------------------------------------Enc------------------------------------");
        write_axi(17'd32, 128'h00000000_00000000_00000000_00000001); // Write to mode_reg
//        write_axi(17'd3, 128'h00000000_00000000_00000000_00000002); 
//        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
//        write_axi(17'd5, 128'h00000000_00000000_00000000_0000000f);
//        write_axi(17'd6, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000003);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd16, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd16, rdata);
            $display("rdata: %h", rdata);
        end
        
        $display("m_in  : 000000000000000000000000000000000000000000000000000000000000000f");
        // $display("c : %h", c_out);
        
        read_c(17'd69152, 8'd47, 3'b100, 2'b01);
        
        $display("------------------------------------Dec------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000002); // Write to mode_reg
        write_axi(17'd3, 128'h00000000_00000000_00000000_00000003); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end

        m_tmp = 256'h000000000000000000000000000000000000000000000000000000000000000f;
        // $display("m : %h", m_out);
        
        read_axi(17'd5, rdata1);
        read_axi(17'd6, rdata2);
        $display("m  : %h%h", rdata2, rdata1);
        if (m_tmp == {rdata2, rdata1})
            $display("Pass");
        else
            $display("Fail");
        
        $display("------------------------------------Enc------------------------------------");
        write_burst(17'd16384, 8'd47, 3'b100, 2'b01, 6400'h26f530160e87d5c43ee72831ac1a2476eea53cfba788b2be0002a846669e8de41a5e094dbfe7600e62b4800cfd7fa03dcacd54c04565a35748ee6eb825c697a6e774c5f6898149b0d71e823504555ef91e076e8853fba6e0af1f53362ebe85acd43397f74e184214aac13d7515a9d453acee1ec2d6d0e69e6c4156f7299b120decf8ea746d531638447ed171296b449edade8dd49bbd2a704a14a354783a10f3f11f32a48c312d7865501494415fd0929a2eaeece7ee1fadfbf20cf7f25108117de68f157407657f47b6f5cb4765843481f0957f6bd65ed85063c1469b30a7716ed1be65d512c66e20f92ceafe4b75c4dc3dc8174cf885627a5ae7f8bbb429a726a912e8bc2fc596bfe30995a02ae493c0163b2afe4be58be85ec6ee443069c411fd2683eed5fad6c6e3ac4a65d3b34bccf7270c782944cc6174b61fd01fdcdae0eae9aa5eb1355ad431cf05f9eb334d274eefaf57b11f2efdb28c02065a0b15190be71d9c65f52a7abc6ec82bd854f912c0c14171a16b58d1a4719b82db76512ea05c419e61a1942155f717216eba0e88bef663c554c3086f59cc8f709a780ff41386035f72bc442cd07f0973fd350d8578a116de53aaaed3977eecf5104800d107fdbe218591f6119c4c01bc8700bf50dad871f972555ae4290ec7eeba2c199b8c285aa88b9f977340d0c5aa88afb1ddf269d68f7ccb751c768033b0c3bfe523c97d4f995335e184fa1939ea685b0edbc6f632f99634cbe46f7c774723a7879ec8ae5366ed6cb6d94b2df9763d18f1fb5191b750cc8a8117bf18dc0630c77571ef5043678ff752d5b545e2d4f70691721c2066aba5ad963ef1d5db9d4ea16eb483206d56519191522aa65a485841d38fb4fb1eba200a7b8407a4e10c1ebe50361deec949f09b465db7dbf95ed420ff3a4fe42ee8a76dc63ed6ad4195c5ba28f9b6b51335b592b7b25b294f040073014673cc613987888907df4250f249108e314fade45095ce4280c4b39d05da650ebf69373bea2c323ae22f9b9a605a42c000033f3dfa7380a06be38f17d54d43bb41540fcc994015e3f49e1d471d094ee9);
        $display("m_in  : 00000000000000000000000000000000123456789abcdef123456789abcdef12");
        $display("c  : 26f530160e87d5c43ee72831ac1a2476eea53cfba788b2be0002a846669e8de41a5e094dbfe7600e62b4800cfd7fa03dcacd54c04565a35748ee6eb825c697a6e774c5f6898149b0d71e823504555ef91e076e8853fba6e0af1f53362ebe85acd43397f74e184214aac13d7515a9d453acee1ec2d6d0e69e6c4156f7299b120decf8ea746d531638447ed171296b449edade8dd49bbd2a704a14a354783a10f3f11f32a48c312d7865501494415fd0929a2eaeece7ee1fadfbf20cf7f25108117de68f157407657f47b6f5cb4765843481f0957f6bd65ed85063c1469b30a7716ed1be65d512c66e20f92ceafe4b75c4dc3dc8174cf885627a5ae7f8bbb429a726a912e8bc2fc596bfe30995a02ae493c0163b2afe4be58be85ec6ee443069c411fd2683eed5fad6c6e3ac4a65d3b34bccf7270c782944cc6174b61fd01fdcdae0eae9aa5eb1355ad431cf05f9eb334d274eefaf57b11f2efdb28c02065a0b15190be71d9c65f52a7abc6ec82bd854f912c0c14171a16b58d1a4719b82db76512ea05c419e61a1942155f717216eba0e88bef663c554c3086f59cc8f709a780ff41386035f72bc442cd07f0973fd350d8578a116de53aaaed3977eecf5104800d107fdbe218591f6119c4c01bc8700bf50dad871f972555ae4290ec7eeba2c199b8c285aa88b9f977340d0c5aa88afb1ddf269d68f7ccb751c768033b0c3bfe523c97d4f995335e184fa1939ea685b0edbc6f632f99634cbe46f7c774723a7879ec8ae5366ed6cb6d94b2df9763d18f1fb5191b750cc8a8117bf18dc0630c77571ef5043678ff752d5b545e2d4f70691721c2066aba5ad963ef1d5db9d4ea16eb483206d56519191522aa65a485841d38fb4fb1eba200a7b8407a4e10c1ebe50361deec949f09b465db7dbf95ed420ff3a4fe42ee8a76dc63ed6ad4195c5ba28f9b6b51335b592b7b25b294f040073014673cc613987888907df4250f249108e314fade45095ce4280c4b39d05da650ebf69373bea2c323ae22f9b9a605a42c000033f3dfa7380a06be38f17d54d43bb41540fcc994015e3f49e1d471d094ee9");

        $display("------------------------------------Dec------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000002); // Write to mode_reg
        write_axi(17'd3, 128'h00000000_00000000_00000000_00000003); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        m_tmp = 256'h123456789abcdef123456789abcdef12;
        // $display("m : %h", m_out);
        
        read_axi(17'd5, rdata1);
        read_axi(17'd6, rdata2);
        $display("m  : %h%h", rdata2, rdata1);
        if (m_tmp == {rdata2, rdata1})
            $display("Pass");
        else
            $display("Fail");
               
        $display("------------------------------------KeyGen------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000000); // Write to mode_reg
        write_axi(17'd3, 128'h12345678_9abcdef1_23456789_abcdef12); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        // $display("pk : %h", pk_out);
        // $display("sk : %h", sk_out);
        
        read_pk(17'd65536, 8'd49, 3'b100, 2'b01);
        read_sk(17'd32768, 8'd47, 3'b100, 2'b01);
                
        $display("------------------------------------Enc------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000001); // Write to mode_reg
        write_axi(17'd3, 128'h99887766_55443322_1100aabb_ccddeeff); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd5, 128'h11111111_11111111_11111111_11111111);
        write_axi(17'd6, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        $display("m_in  : 0000000000000000000000000000000011111111111111111111111111111111");
        // $display("c : %h", c_out);
        
        read_c(17'd16384, 8'd47, 3'b100, 2'b01);
        
        $display("------------------------------------Dec------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000002); // Write to mode_reg
        write_axi(17'd3, 128'h12345678_22345678_32345678_42345678); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        m_tmp = 256'h11111111111111111111111111111111;
        // $display("m : %h", m_out);
        
        read_axi(17'd5, rdata1);
        read_axi(17'd6, rdata2);
        $display("m  : %h%h", rdata2, rdata1);
        if (m_tmp == {rdata2, rdata1})
            $display("Pass");
        else
            $display("Fail");

        $display("------------------------------------KeyGen------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000000); // Write to mode_reg
        write_axi(17'd3, 128'h12345678_9abcdef1_23ad6789_abcdef12); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        // $display("pk : %h", pk_out);
        // $display("sk : %h", sk_out);
        
        read_pk(17'd65536, 8'd49, 3'b100, 2'b01);
        read_sk(17'd32768, 8'd47, 3'b100, 2'b01);
                
        $display("------------------------------------Enc------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000001); // Write to mode_reg
        write_axi(17'd3, 128'h99887766_55443322_1100aabb_ccddeeff); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd5, 128'h11111111_11111111_11111111_1ab11111);
        write_axi(17'd6, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        $display("m_in  : 000000000000000000000000000000001111111111111111111111111ab11111");
        // $display("c : %h", c_out);
        
        read_c(17'd16384, 8'd47, 3'b100, 2'b01);
        
        $display("------------------------------------Dec------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000002); // Write to mode_reg
        write_axi(17'd3, 128'hab345678_22345678_32345678_42345678); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        m_tmp = 256'h1111111111111111111111111ab11111;
        // $display("m : %h", m_out);
        
        read_axi(17'd5, rdata1);
        read_axi(17'd6, rdata2);
        $display("m  : %h%h", rdata2, rdata1);
        if (m_tmp == {rdata2, rdata1})
            $display("Pass");
        else
            $display("Fail");

        $display("------------------------------------KeyGen------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000000); // Write to mode_reg
        write_axi(17'd3, 128'hdeadbeef_12345678_90abcdef_98765432); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        // $display("pk : %h", pk_out);
        // $display("sk : %h", sk_out);
        
        read_pk(17'd65536, 8'd49, 3'b100, 2'b01);
        read_sk(17'd32768, 8'd47, 3'b100, 2'b01);
                
        $display("------------------------------------Enc------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000001); // Write to mode_reg
        write_axi(17'd3, 128'h12345678_90abcdef_12345678_90abcdef); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd5, 128'hcdefabcd_efabcdef_abcdefab_cdefabcd);
        write_axi(17'd6, 128'h00000000_00000000_00000000_000000ab);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        $display("m_in  : 000000000000000000000000000000abcdefabcdefabcdefabcdefabcdefabcd");
        // $display("c : %h", c_out);
        
        read_c(17'd16384, 8'd47, 3'b100, 2'b01);
        
        $display("------------------------------------Dec------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000002); // Write to mode_reg
        write_axi(17'd3, 128'hdeadbeef_abcdef01_23456789_abcdef01); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        m_tmp = 256'habcdefabcdefabcdefabcdefabcdefabcd;
        // $display("m : %h", m_out);
        
        read_axi(17'd5, rdata1);
        read_axi(17'd6, rdata2);
        $display("m  : %h%h", rdata2, rdata1);
        if (m_tmp == {rdata2, rdata1})
            $display("Pass");
        else
            $display("Fail");

        $display("------------------------------------Enc------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000001); // Write to mode_reg
        write_axi(17'd3, 128'h98765432_10abcdef_12345678_90abcdef); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd5, 128'hfedcba98_7654321_0abcdefab_cdef1234);
        write_axi(17'd6, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        $display("m_in  : 00000000000000000000000000000000fedcba9876543210abcdefabcdef1234");
        // $display("c : %h", c_out);
        
        read_c(17'd16384, 8'd47, 3'b100, 2'b01);
        
        $display("------------------------------------Dec------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000002); // Write to mode_reg
        write_axi(17'd3, 128'habcdef12_34567890_abcdef12_34567890); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        m_tmp = 256'hfedcba9876543210abcdefabcdef1234;
        // $display("m : %h", m_out);
        
        read_axi(17'd5, rdata1);
        read_axi(17'd6, rdata2);
        $display("m  : %h%h", rdata2, rdata1);
        if (m_tmp == {rdata2, rdata1})
            $display("Pass");
        else
            $display("Fail");

        $display("------------------------------------KeyGen------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000000); // Write to mode_reg
        write_axi(17'd3, 128'h11223344_55667788_99aabbcc_ddeeffaa); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        // $display("pk : %h", pk_out);
        // $display("sk : %h", sk_out);
        
        read_pk(17'd65536, 8'd49, 3'b100, 2'b01);
        read_sk(17'd32768, 8'd47, 3'b100, 2'b01);
                
        $display("------------------------------------Enc------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000001); // Write to mode_reg
        write_axi(17'd3, 128'h98765432_10abcdef_12345678_90abcdef); 
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd5, 128'hef123456_7890abc_defabcdef_12345678);
        write_axi(17'd6, 128'h00000000_00000000_00000000_0000abcd);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        $display("m_in  : 0000000000000000000000000000abcdef1234567890abcdefabcdef12345678");
        // $display("c : %h", c_out);
        
        read_c(17'd16384, 8'd47, 3'b100, 2'b01);
        
        $display("------------------------------------Dec------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000002); // Write to mode_reg
        write_axi(17'd3, 128'hfeedface_12345678_abcdefab_cdefabcd); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        m_tmp = 256'habcdef1234567890abcdefabcdef12345678;
        // $display("m : %h", m_out);
        
        read_axi(17'd5, rdata1);
        read_axi(17'd6, rdata2);
        $display("m  : %h%h", rdata2, rdata1);
        if (m_tmp == {rdata2, rdata1})
            $display("Pass");
        else
            $display("Fail");
        
        $display("END");
        #100;
        $stop;
    end
    
    task write_burst;
        input [16:0] start_addr;
        input [7:0] burst_len;
        input [2:0] burst_size;
        input [1:0] burst_type;
        input [6399:0] data_input; // 6400-bit input data
        integer i;
        begin
            @(negedge s_axi_aclk);
            s_axi_awvalid = 1;
            s_axi_awaddr = start_addr;
            s_axi_awlen = burst_len;
            s_axi_awsize = burst_size;
            s_axi_awburst = burst_type;

            wait(s_axi_awready); 
            @(negedge s_axi_aclk);
            s_axi_awvalid = 0;

            for (i = 0; i < (burst_len + 1); i = i + 1) begin
                s_axi_wdata = data_input[i * 128 +: 128]; // Send 128-bit chunks
                s_axi_wvalid = 1;
                s_axi_wlast = (i == burst_len);

                wait (s_axi_wready) @(negedge s_axi_aclk);
                s_axi_wvalid = 0;
            end      
                    
            s_axi_wlast = 0;

            @(posedge s_axi_aclk);
            wait (s_axi_bvalid) @(negedge s_axi_aclk);
            if (s_axi_bresp === 2'b00) begin
                $display("Write Burst Transaction Successful");
            end else begin
                $display("Write Burst Transaction Failed");
            end
        end
    endtask


    task read_burst;
        input [16:0] start_addr;
        input [7:0] burst_len;
        input [2:0] burst_size;
        input [1:0] burst_type;
        integer i;
        reg [127:0] temp_data; 
        reg [6399:0] burst_data;
        begin
            // $display("Starting Read Burst Transaction");
            s_axi_arvalid = 1;
            s_axi_araddr = start_addr;
            s_axi_arlen  = burst_len;
            s_axi_arsize = burst_size;
            s_axi_arburst = burst_type;

            @(posedge s_axi_aclk);
            wait (s_axi_arready) @(negedge s_axi_aclk);
            s_axi_arvalid = 0;

            for (i = 0; i < (burst_len + 1); i = i + 1) begin
                @(posedge s_axi_aclk);
                wait (s_axi_rvalid) @(negedge s_axi_aclk);
//                $display("m  [%0d]: %h", i, s_axi_rdata);
            end
            $display("rb : %h", burst_data);
            // $display("Read Burst Transaction Completed");
            @(negedge s_axi_aclk);
        end
    endtask

    task read_pk;
        input [16:0] start_addr;
        input [7:0] burst_len;
        input [2:0] burst_size;
        input [1:0] burst_type;
        integer i;
        reg [127:0] temp_data; 
        reg [6399:0] burst_data;
        begin
            s_axi_arvalid = 1;
            s_axi_araddr = start_addr;
            s_axi_arlen  = burst_len;
            s_axi_arsize = burst_size;
            s_axi_arburst = burst_type;

            @(posedge s_axi_aclk);
            wait (s_axi_arready) @(negedge s_axi_aclk);
            s_axi_arvalid = 0;

            for (i = 0; i < (burst_len + 1); i = i + 1) begin
                @(posedge s_axi_aclk);
                wait (s_axi_rvalid) @(negedge s_axi_aclk);
                temp_data = s_axi_rdata; // Capture single read data
                burst_data = {temp_data, burst_data[6399:128]};
            end
            $display("pk : %h", burst_data);
            @(negedge s_axi_aclk);
        end
    endtask

    task read_sk;
        input [16:0] start_addr;
        input [7:0] burst_len;
        input [2:0] burst_size;
        input [1:0] burst_type;
        integer i;
        reg [127:0] temp_data; 
        reg [6143:0] burst_data;
        begin
            s_axi_arvalid = 1;
            s_axi_araddr = start_addr;
            s_axi_arlen  = burst_len;
            s_axi_arsize = burst_size;
            s_axi_arburst = burst_type;

            @(posedge s_axi_aclk);
            wait (s_axi_arready) @(negedge s_axi_aclk);
            s_axi_arvalid = 0;

            for (i = 0; i < (burst_len + 1); i = i + 1) begin
                @(posedge s_axi_aclk);
                wait (s_axi_rvalid) @(negedge s_axi_aclk);
                temp_data = s_axi_rdata; 
                burst_data = {temp_data, burst_data[6143:128]};
            end
            $display("sk : %h", burst_data);
            @(negedge s_axi_aclk);
        end
    endtask

    task read_c;
        input [16:0] start_addr;
        input [7:0] burst_len;
        input [2:0] burst_size;
        input [1:0] burst_type;
        integer i;
        reg [127:0] temp_data; 
        reg [6143:0] burst_data;
        begin
            s_axi_arvalid = 1;
            s_axi_araddr = start_addr;
            s_axi_arlen  = burst_len;
            s_axi_arsize = burst_size;
            s_axi_arburst = burst_type;

            @(posedge s_axi_aclk);
            wait (s_axi_arready) @(negedge s_axi_aclk);
            s_axi_arvalid = 0;

            for (i = 0; i < (burst_len + 1); i = i + 1) begin
                @(posedge s_axi_aclk);
                wait (s_axi_rvalid) @(negedge s_axi_aclk);
                temp_data = s_axi_rdata; 
                burst_data = {temp_data, burst_data[6143:128]}; 
            end
            $display("c  : %h", burst_data);
            @(negedge s_axi_aclk);
        end
    endtask
endmodule
