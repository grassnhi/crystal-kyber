`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 02:22:37 AM
// Design Name: 
// Module Name: tb_mini_fsm
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


module tb_mini_fsm;
    reg clk;
    reg rst;
    reg [7:0] reg_in;
    wire start_pulse;

    mini_fsm uut (
        .clk(clk),
        .rst(rst),
        .reg_in(reg_in),
        .start_pulse(start_pulse)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        clk = 0;
        rst = 1;
        reg_in = 8'b0;

        #20 rst = 0;         // Release reset
        #20 reg_in[0] = 1;       // Create 0->1 transition
        #10 reg_in[0] = 0;       // Return to 0
        #10 reg_in[0] = 1;       // Another transition
        
        #10 reg_in[0] = 0;       // Return to 0
        #40 reg_in[0] = 1; 
        #50 $finish;
    end
endmodule
