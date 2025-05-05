`timescale 1ns / 1ps

module fsm_rst_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg reg_in;
    wire rst_pulse;

    // Instantiate the DUT
    fsm_rst dut (
        .clk(clk),
        .rst(rst),
        .reg_in(reg_in),
        .rst_pulse(rst_pulse)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Task to apply reset
    task apply_reset;
    begin
        rst = 1;
        #20;
        rst = 0;
    end
    endtask

    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        rst = 0;
        reg_in = 0;

        // Apply reset
        apply_reset;

        // Wait a few cycles, then trigger 0->1 edge on reg_in
        #20;
        reg_in = 1;  // Trigger 0 -> 1 transition
        #10;
        reg_in = 1;  // Maintain high to avoid repeated triggering
        #200;        // Wait for more than 10 cycles to see pulse end
        
        #20;
        reg_in = 0;  // Trigger 0 -> 1 transition
        #10;
        reg_in = 1;  // Maintain high to avoid repeated triggering
        #200;        // Wait for more than 10 cycles to see pulse end

        // End simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        $display("Time\tclk\trst\treg_in\trst_pulse");
        $monitor("%4t\t%b\t%b\t%b\t%b", $time, clk, rst, reg_in, rst_pulse);
    end

endmodule
