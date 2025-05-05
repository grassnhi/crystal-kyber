`timescale 1ns / 1ps

module top_test_tb;

    // Declare inputs as reg, outputs as wire
    reg         BRAM_PORTA_0_clk;
    reg  [9:0]  BRAM_PORTA_0_addr;
    reg  [31:0] BRAM_PORTA_0_din;
    wire [31:0] BRAM_PORTA_0_dout;
    reg         BRAM_PORTA_0_en;
    reg         BRAM_PORTA_0_rst;
    reg  [3:0]  BRAM_PORTA_0_we;

    // Unused BRAM1 and BRAM2 signals
    reg  [9:0]  BRAM_PORTA_1_addr = 0;
    reg         BRAM_PORTA_1_clk = 0;
    reg  [31:0] BRAM_PORTA_1_din = 0;
    wire [31:0] BRAM_PORTA_1_dout;
    reg         BRAM_PORTA_1_en = 0;
    reg         BRAM_PORTA_1_rst = 0;
    reg  [3:0]  BRAM_PORTA_1_we = 0;

    reg  [12:0]  BRAM_PORTA_2_addr = 0;
    reg         BRAM_PORTA_2_clk = 0;
    reg  [31:0] BRAM_PORTA_2_din = 0;
    wire [31:0] BRAM_PORTA_2_dout;
    reg         BRAM_PORTA_2_en = 0;
    reg         BRAM_PORTA_2_rst = 0;
    reg  [3:0]  BRAM_PORTA_2_we = 0;

    // Instantiate the DUT
    top_test dut (
        .BRAM_PORTA_0_addr(BRAM_PORTA_0_addr),
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
        .BRAM_PORTA_2_we(BRAM_PORTA_2_we)
    );

    // Clock generation
    initial BRAM_PORTA_0_clk = 0;
    always #5 BRAM_PORTA_0_clk = ~BRAM_PORTA_0_clk; 
    initial BRAM_PORTA_1_clk = 0;
    always #5 BRAM_PORTA_1_clk = ~BRAM_PORTA_1_clk; 
    initial BRAM_PORTA_2_clk = 0;
    always #5 BRAM_PORTA_2_clk = ~BRAM_PORTA_2_clk; 
    // Stimulus
    initial begin
        BRAM_PORTA_0_rst = 1;
        BRAM_PORTA_0_en  = 0;
        BRAM_PORTA_0_we  = 0;
        BRAM_PORTA_0_addr = 0;
        BRAM_PORTA_0_din  = 0;
        
        BRAM_PORTA_1_rst = 1;
        BRAM_PORTA_1_en  = 0;
        BRAM_PORTA_1_we  = 0;
        BRAM_PORTA_1_addr = 0;
        BRAM_PORTA_1_din  = 0;
        
        BRAM_PORTA_2_rst = 1;
        BRAM_PORTA_2_en  = 0;
        BRAM_PORTA_2_we  = 0;
        BRAM_PORTA_2_addr = 0;
        BRAM_PORTA_2_din  = 0;

        #5000;

        // Deassert reset
        BRAM_PORTA_0_rst = 0;
        BRAM_PORTA_1_rst = 0;
        BRAM_PORTA_2_rst = 0;
        // Write to BRAM0: address 1 => 1, address 2 => 2, ..., up to 10 (example)
        repeat (1024) begin
            @(posedge BRAM_PORTA_1_clk) #0.2;
            BRAM_PORTA_1_en   = 1;
            BRAM_PORTA_1_we   = 4'b1111; // enable all byte lanes
            BRAM_PORTA_1_din  = BRAM_PORTA_1_addr;
            BRAM_PORTA_1_addr = BRAM_PORTA_1_addr + 1;
        end

        @(posedge BRAM_PORTA_1_clk) #0.2;
        BRAM_PORTA_1_we = 0;

        #100;
        
        // Unused register address
        BRAM_PORTA_2_addr = 11'h3F;
        BRAM_PORTA_2_din = 32'hADBEEF;
        BRAM_PORTA_2_we = 4'hF;
        BRAM_PORTA_2_en = 1;
        #10;
        
        $display("Mode 0:");
        
        // Mode then start
        @(posedge BRAM_PORTA_1_clk) #0.2;
        BRAM_PORTA_2_addr = 11'b11;
        BRAM_PORTA_2_din = 32'b0;
        #10;
        BRAM_PORTA_2_addr = 11'b1;
        BRAM_PORTA_2_din = 32'b0;
        #10
        BRAM_PORTA_2_addr = 11'b1;
        BRAM_PORTA_2_din = 32'b01;
        #10;
        BRAM_PORTA_2_we = 4'h0;
        #10;
        // Wait finish
        BRAM_PORTA_2_we = 4'h0;
        BRAM_PORTA_2_addr = 11'b100;
        #50;
        while(BRAM_PORTA_2_dout != 1) begin
            #10;
        end
        BRAM_PORTA_2_en = 0;
        #200;
        
        $display("Mode 1:");
        
        BRAM_PORTA_2_we = 4'hF;
        BRAM_PORTA_2_en = 1;
        #10;
        // Mode then start
        BRAM_PORTA_2_addr = 11'b11;
        BRAM_PORTA_2_din = 32'b01;
        #10;
        BRAM_PORTA_2_addr = 11'b1;
        BRAM_PORTA_2_din = 32'b0;
        #10
        BRAM_PORTA_2_addr = 11'b1;
        BRAM_PORTA_2_din = 32'b01;
        #10;
        BRAM_PORTA_2_we = 4'h0;
        #10;
        // Wait finish
        BRAM_PORTA_2_we = 4'h0;
        BRAM_PORTA_2_addr = 11'b100;
        #50;
        while(BRAM_PORTA_2_dout != 1) begin
            #10;
        end
        BRAM_PORTA_2_en = 0;
        #200;
        
        $display("Mode 2:");
        
        BRAM_PORTA_2_we = 4'hF;
        BRAM_PORTA_2_en = 1;
        #10;
        // Mode then start
        BRAM_PORTA_2_addr = 11'b11;
        BRAM_PORTA_2_din = 32'b10;
        #10;
        BRAM_PORTA_2_addr = 11'b1;
        BRAM_PORTA_2_din = 32'b0;
        #10
        BRAM_PORTA_2_addr = 11'b1;
        BRAM_PORTA_2_din = 32'b01;
        #10;
        BRAM_PORTA_2_we = 4'h0;
        #10;
        // Wait finish
        BRAM_PORTA_2_we = 4'h0;
        BRAM_PORTA_2_addr = 11'b100;
        #50;
        while(BRAM_PORTA_2_dout != 1) begin
            #10;
        end
        BRAM_PORTA_2_en = 0;
        #200;
        repeat (1024) begin
            @(posedge BRAM_PORTA_0_clk);
            BRAM_PORTA_0_en   = 1;
            BRAM_PORTA_0_addr = BRAM_PORTA_0_addr + 1;
        end
        $display("END");
        $finish;
    end

endmodule
