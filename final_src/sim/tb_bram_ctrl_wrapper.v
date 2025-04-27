`timescale 1ns / 1ps

module bram_ctrl_wrapper_tb;

  // AXI signals
  reg         s_axi_aclk_0 = 0;
  reg         s_axi_aresetn_0 = 0;
  reg [16:0]  s_axi_awaddr_0;
  reg [2:0]   s_axi_awsize_0;
  reg [1:0]   s_axi_awburst_0;
  reg [7:0]   s_axi_awlen_0;
  reg         s_axi_awvalid_0;
  reg [3:0]   s_axi_awcache_0;
  reg [2:0]   s_axi_awprot_0;
  reg         s_axi_awlock_0;
  wire        s_axi_awready_0;

  reg [127:0] s_axi_wdata_0;
  reg [15:0]  s_axi_wstrb_0;
  reg         s_axi_wlast_0;
  reg         s_axi_wvalid_0;
  wire        s_axi_wready_0;

  wire [1:0]  s_axi_bresp_0;
  reg         s_axi_bready_0;
  wire        s_axi_bvalid_0;

  reg [16:0]  s_axi_araddr_0;
  reg [2:0]   s_axi_arsize_0;
  reg [1:0]   s_axi_arburst_0;
  reg [7:0]   s_axi_arlen_0;
  reg         s_axi_arvalid_0;
  reg [3:0]   s_axi_arcache_0;
  reg [2:0]   s_axi_arprot_0;
  reg         s_axi_arlock_0;
  wire        s_axi_arready_0;

  wire [127:0] s_axi_rdata_0;
  wire         s_axi_rlast_0;
  reg          s_axi_rready_0;
  wire [1:0]   s_axi_rresp_0;
  wire         s_axi_rvalid_0;

  // BRAM interface
  reg [7:0]   addrb_0;
  reg         clkb_0;
  reg [127:0] dinb_0;
  reg         enb_0;
  reg [15:0]  web_0;
  wire [127:0] doutb_0;

  // Clock generation
  always #5 s_axi_aclk_0 = ~s_axi_aclk_0;

  // Instantiate DUT
  bram_ctrl_wrapper dut (
    .s_axi_aclk_0(s_axi_aclk_0),
    .s_axi_araddr_0(s_axi_araddr_0),
    .s_axi_arburst_0(s_axi_arburst_0),
    .s_axi_arcache_0(s_axi_arcache_0),
    .s_axi_aresetn_0(s_axi_aresetn_0),
    .s_axi_arlen_0(s_axi_arlen_0),
    .s_axi_arlock_0(s_axi_arlock_0),
    .s_axi_arprot_0(s_axi_arprot_0),
    .s_axi_arready_0(s_axi_arready_0),
    .s_axi_arsize_0(s_axi_arsize_0),
    .s_axi_arvalid_0(s_axi_arvalid_0),
    .s_axi_awaddr_0(s_axi_awaddr_0),
    .s_axi_awburst_0(s_axi_awburst_0),
    .s_axi_awcache_0(s_axi_awcache_0),
    .s_axi_awlen_0(s_axi_awlen_0),
    .s_axi_awlock_0(s_axi_awlock_0),
    .s_axi_awprot_0(s_axi_awprot_0),
    .s_axi_awready_0(s_axi_awready_0),
    .s_axi_awsize_0(s_axi_awsize_0),
    .s_axi_awvalid_0(s_axi_awvalid_0),
    .s_axi_bready_0(s_axi_bready_0),
    .s_axi_bresp_0(s_axi_bresp_0),
    .s_axi_bvalid_0(s_axi_bvalid_0),
    .s_axi_rdata_0(s_axi_rdata_0),
    .s_axi_rlast_0(s_axi_rlast_0),
    .s_axi_rready_0(s_axi_rready_0),
    .s_axi_rresp_0(s_axi_rresp_0),
    .s_axi_rvalid_0(s_axi_rvalid_0),
    .s_axi_wdata_0(s_axi_wdata_0),
    .s_axi_wlast_0(s_axi_wlast_0),
    .s_axi_wready_0(s_axi_wready_0),
    .s_axi_wstrb_0(s_axi_wstrb_0),
    .s_axi_wvalid_0(s_axi_wvalid_0),
    .addrb_0          (addrb_0),
    .clkb_0           (clkb_0),
    .dinb_0           (dinb_0),
    .enb_0            (enb_0),
    .web_0            (web_0),
    .doutb_0          (doutb_0)
  );

  // Tasks
  task axi_write(input [16:0] addr, input [2:0] size, input [127:0] data, input [15:0] strb);
    begin
      @(posedge s_axi_aclk_0) #1;
      s_axi_awaddr_0  <= addr;
      s_axi_awsize_0  <= size;
      s_axi_awburst_0 <= 2'b01;
      s_axi_awlen_0   <= 8'd0;
      s_axi_awvalid_0 <= 1;

      s_axi_wdata_0   <= data;
      s_axi_wstrb_0   <= strb;
      s_axi_wvalid_0  <= 1;
      s_axi_wlast_0   <= 1;

      wait (s_axi_awready_0);
      @(posedge s_axi_aclk_0) #1;
      s_axi_awvalid_0 <= 0;
      s_axi_wvalid_0  <= 0;
      s_axi_wlast_0   <= 0;

      s_axi_bready_0  <= 1;
      wait (s_axi_bvalid_0);
      @(posedge s_axi_aclk_0) #1;
      s_axi_bready_0  <= 0;
    end
  endtask

  task axi_read(input [16:0] addr, input [2:0] size);
    begin
    @(posedge s_axi_aclk_0) #1;
      s_axi_araddr_0  <= addr;
      s_axi_arsize_0  <= size;
      s_axi_arburst_0 <= 2'b01;
      s_axi_arlen_0   <= 8'd0;
      s_axi_arvalid_0 <= 1;

      wait (s_axi_arready_0);
      @(posedge s_axi_aclk_0) #1;
      s_axi_arvalid_0 <= 0;

      s_axi_rready_0  <= 1;
      wait (s_axi_rvalid_0 && s_axi_rlast_0);
      @(posedge s_axi_aclk_0);
      $display("Read [0x%05h] = 0x%032x", addr, s_axi_rdata_0);
      #1 s_axi_rready_0  <= 0;
    end
  endtask

  // Test sequence
  initial begin
    clkb_0 = s_axi_aclk_0;
    $display("AXI BRAM Testbench - 32-bit and 128-bit transfers");
    s_axi_awvalid_0 = 0;
    s_axi_wvalid_0 = 0;
    s_axi_bready_0 = 0;
    s_axi_arvalid_0 = 0;
    s_axi_rready_0 = 0;
    s_axi_aresetn_0 = 0;
    s_axi_arcache_0 = 0;
    s_axi_arprot_0 = 0;
    s_axi_awcache_0 = 0;
    s_axi_awprot_0 = 0;
    s_axi_awlock_0 = 0;
    s_axi_arlock_0 = 0;
    addrb_0 = 0;
    dinb_0 = 0;
    enb_0 = 0;
    web_0 = 0;
    

    #100;
    s_axi_aresetn_0 = 1;

    // 32-bit WRITE at 0x0004
    axi_write(17'h0004, 3'b010, 128'h12000000_00340000_00005600_DEADBEEF, 16'h000F);
    axi_read (17'h0004, 3'b010);  // 4 bytes
    axi_write(17'h0004, 3'b010, 128'h12000000_00340000_00005600_DEADBEEF, 16'h00F0);
    axi_read (17'h0004, 3'b010);
    axi_write(17'h0004, 3'b010, 128'h12000000_00340000_00005600_DEADBEEF, 16'h0F00);
    axi_read (17'h0004, 3'b010);
    axi_write(17'h0004, 3'b010, 128'h12000000_00340000_00005600_DEADBEEF, 16'hF000);
    axi_read (17'h0004, 3'b100);

    // 128-bit WRITE at 0x0010
    axi_write(17'h0011, 3'b100, 128'h01234567_89ABCDEF_13579BDF_FEDCBA98, 16'hFFFF);
    axi_read (17'h0011, 3'b100);  // 16 bytes

    #100;
    
    $display("Direct BRAM Testbench");

    enb_0  = 0;
    web_0  = 16'h0000;
    dinb_0 = 128'h0;
    addrb_0 = 8'h00;

    #20;

    // 128-bit write to BRAM address 0x10
    @(posedge s_axi_aclk_0) #1;
    enb_0  = 1;
    addrb_0 = 8'd15;
    dinb_0 = 128'hCAFEBABEDEADBEEF1234567890ABCDEF;
    web_0  = 16'hFFFF; // enable all bytes

    @(posedge s_axi_aclk_0) #1; // do the write
    enb_0 = 0;
    web_0 = 0;

    #20;

    // Read back from BRAM address 0x10
    @(posedge s_axi_aclk_0) #1;
    enb_0 = 1;
    addrb_0 = 8'd15;
    web_0 = 0; // no write

    @(posedge s_axi_aclk_0) #1;
    $display("Read BRAM[0x%02h] = 0x%032x", addrb_0, doutb_0);

    enb_0 = 0;

    #20;
   
    $finish;
  end

endmodule
