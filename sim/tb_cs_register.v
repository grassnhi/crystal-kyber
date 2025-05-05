`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 08:53:58 PM
// Design Name: 
// Module Name: tb_cs_register
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

module tb_cs_register;

    // Inputs
    reg clk = 0;
    reg rst;
    reg en;
    reg [11:0] addr;
    reg [3:0] we;
    reg [31:0] wrdata;

    // Outputs
    wire [31:0] rddata;
    wire start_pulse;
    wire restart_pulse;
    wire [1:0] mode;

    // Internal control signals
    reg [1:0] current_state;
    reg [9:0] cnt;
    reg [31:0] rddata_reg;
    reg [31:0] wrdata_reg;
    reg [31:0] pk_out_reg;
    reg [31:0] sk_out_reg;
    reg [31:0] c_out_reg;
    reg [31:0] m_out_reg;
    
    integer i;
    // Clock generator
    always #5 clk = ~clk;

    // Instantiate the DUT
    cs_register uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .addr(addr),
        .we(we),
        .wrdata(wrdata),
        .rddata(rddata),
        .current_state(current_state),
        .cnt(cnt),
        .rddata_reg(rddata_reg),
        .wrdata_reg(wrdata_reg),
        .pk_out_reg(pk_out_reg),
        .sk_out_reg(sk_out_reg),
        .c_out_reg(c_out_reg),
        .m_out_reg(m_out_reg),
        .start_pulse(start_pulse),
        .restart_pulse(restart_pulse),
        .mode(mode)
    );

    initial begin
        // Init inputs
        rst = 1;
        en = 0;
        we = 0;
        addr = 0;
        wrdata = 0;

        current_state = 2'b10;  // PROCESS
        cnt = 9'd55;
        rddata_reg = 32'h1111_2222;
        wrdata_reg = 32'h2222_3333;
        pk_out_reg = 32'h3333_2222;
        sk_out_reg = 32'h7777_8888;
        c_out_reg  = 32'h5555_7777;
        m_out_reg  = 32'h9ABC_DEF0;

        #10 rst = 0;

        // WRITE TEST
        en = 1; we = 4'hF;

        // Write to start_reg (addr = 0)
        addr = 11'd0;
        wrdata = 32'h1;
        #10;

        // Write to restart_reg (addr = 1)
        addr = 11'd1;
        wrdata = 32'h1;
        #10;

        // Write to mode_reg (addr = 2)
        addr = 11'd2;
        wrdata = 32'h2;
        #10;
        
        current_state = 0;
        #10 current_state = 1;
        #10 current_state = 2;
        #10 current_state = 3;
        #10 current_state = 0;
        #10;

        // Write to undefined addr (addr = 3)
        addr = 11'd3;
        wrdata = 32'hDEAD_BEEF;
        #10;

        // READ TEST
        we = 0;
        for ( i = 0; i <= 14; i= i+1) begin
            addr = i;
            #10;
            $display("Read addr[%0d] => rddata = 0x%032x", i, rddata);
        end

        // Read undefined address (not 0~13)
        addr = 11'd100;
        #10;
        $display("Read addr[default] => rddata = 0x%032x", rddata);

        #20;
        $finish;
    end
endmodule
