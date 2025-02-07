`timescale 1ns / 1ps

module tb_axi_kyber;

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
    axi_kyber uut (
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
        
//        write_burst(17'd65536, 8'd24, 3'b100, 2'b01); // Len = 24 (25 transfers), Size = 16 bytes, INCR
//        write_burst(17'd32768, 8'd23, 3'b100, 2'b01);  
//        write_burst(17'd16384, 8'd23, 3'b100, 2'b01);
//        write_burst(17'd32800, 8'd22, 3'b100, 2'b01);
        
//        read_burst(17'd65536, 8'd24, 3'b100, 2'b01); // Len = 24 (25 transfers), Size = 16 bytes, INCR
//        read_burst(17'd32768, 8'd23, 3'b100, 2'b01);  
//        read_burst(17'd16384, 8'd23, 3'b100, 2'b01);
//        read_burst(17'd22222, 8'd33, 3'b100, 2'b01);
        
        $display("------------------------------------KeyGen------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000000); // Write to mode_reg
        write_axi(17'd3, 128'h00000000_00000000_00000000_00000001); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000); // Write to mode_reg
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        // $display("pk : %h", pk_out);
        // $display("sk : %h", sk_out);
//        $display("%t", $time);
        read_pk(17'd65536, 8'd49, 3'b100, 2'b01);
//        $display("%t", $time);
        read_sk(17'd32768, 8'd47, 3'b100, 2'b01);
//        $display("%t", $time);
        
        $display("------------------------------------Enc------------------------------------");
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000001); // Write to mode_reg
        write_axi(17'd3, 128'h00000000_00000000_00000000_00000002); 
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd5, 128'h00000000_00000000_00000000_0000000f);
        write_axi(17'd6, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
        
        // repeat(80) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        $display("m_in  : 000000000000000000000000000000000000000000000000000000000000000f");
        // $display("c : %h", c_out);
        
        read_c(17'd16384, 8'd47, 3'b100, 2'b01);
        
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
        write_axi(17'd2, 128'h00000000_00000000_00000000_00000001); // Write to mode_reg
        write_axi(17'd3, 128'h11223344_55667788_99aabbcc_ddeeffaa); // Write to start_reg
        write_axi(17'd4, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd5, 128'h12345678_9abcdef1_23456789_abcdef12);
        write_axi(17'd6, 128'h00000000_00000000_00000000_00000000);
        write_axi(17'd0, 128'h00000000_00000000_00000000_00000001);
      
        // repeat(120) @(posedge s_axi_aclk);
        
        read_axi(17'd1, rdata);
        while (rdata != 128'h00000000_00000000_00000000_00000001) begin
            #10;
            read_axi(17'd1, rdata);
        end
        
        $display("m_in  : 00000000000000000000000000000000123456789abcdef123456789abcdef12");
        // $display("c : %h", c_out);
        
        read_c(17'd16384, 8'd47, 3'b100, 2'b01);
        
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
        
        m_tmp = 256'h123456789abcdef123456789abcdef12;;
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
                s_axi_wdata = {16{(i + 1)}};
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
