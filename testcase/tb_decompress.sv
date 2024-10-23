`timescale 1ns / 1ps

`define N_OF_TEST 1030

module tb_decompress;

    // Testbench signals
    reg clk;
    reg rst_n;
    
    reg [0:0] in_val_1;     // Input for D=1 (compressed value)
    reg [3:0] in_val_4;     // Input for D=4 (compressed value)
    reg [9:0] in_val_10;    // Input for D=10 (compressed value)

    wire [11:0] out_val_1;   // Output for D=1 (decompressed value)
    wire [11:0] out_val_4;   // Output for D=4 (decompressed value)
    wire [11:0] out_val_10;  // Output for D=10 (decompressed value)

    // Expected value arrays
    reg [11:0] expected_vals_1 [0:1];   // Only 2 values for D=1
    reg [11:0] expected_vals_4 [0:15];  // 16 values for D=4
    reg [11:0] expected_vals_10 [0:1023];  // 1024 values for D=10

    // Instantiate the decompress module for D=1
    decompress #(.D(1)) dut_D1 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(in_val_1),
        .out_val(out_val_1)
    );

    // Instantiate the decompress module for D=4
    decompress #(.D(4)) dut_D4 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(in_val_4),
        .out_val(out_val_4)
    );

    // Instantiate the decompress module for D=10
    decompress #(.D(10)) dut_D10 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(in_val_10),
        .out_val(out_val_10)
    );

    // Clock generation: 10ns clock period (100MHz)
    always #5 clk = ~clk;

    // Reset task
    task RESETn;
        begin
            rst_n = 0;
            repeat(2) c1;
            rst_n = 1;
        end
    endtask

    // Clock
    task automatic c1;
        begin
            @(posedge clk);
            #0.1;
        end
    endtask

    // Apply inputs
    task APPLY_INPUT_D1(input [0:0] test_val);
        begin
            in_val_1    = test_val;
        end
    endtask

    task APPLY_INPUT_D4(input [3:0] test_val);
        begin
            in_val_4    = test_val;
        end
    endtask

    task APPLY_INPUT_D10(input [9:0] test_val);
        begin
            in_val_10   = test_val;
        end
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        clk         = 0;
        rst_n       = 0;
        in_val_1    = 0;
        in_val_4    = 0;
        in_val_10   = 0;

        // Reset the DUT
        RESETn();
        c1;
    end

    initial begin
        integer i;
        
        repeat(3) c1;
        
        for (i = 0; i < `N_OF_TEST; i = i + 1) begin
                APPLY_INPUT_D1(i);
                APPLY_INPUT_D4(i);
                APPLY_INPUT_D10(i);
    
                $display("%d", out_val_10);
            c1;
        end
    end

    // End simulation
    initial begin
        #50000;
        $finish;
    end
endmodule
