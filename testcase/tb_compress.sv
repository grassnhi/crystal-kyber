`timescale 1ns / 1ps

`define MAX_INPUT 12'd4095
`define MIN_INPUT 12'd0
`define N_OF_TEST 5000


module tb_compress;
    parameter Q = 3329;  

    // Testbench signals
    reg clk;
    reg rst_n;

    reg [11:0] in_val;  

    wire [9:0] out_val_10;          // Output for D=10
    wire [3:0] out_val_4;           // Output for D=4
    wire        out_val_1;         // Output for D=1

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

    // Wait for one clock cycle
    task automatic c1;
        begin
            @(posedge clk);
            #0.1;
        end
    endtask

    // Instantiate the compress module for D=10
    compress #(.D(10), .Q(Q)) dut_D10 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(in_val),
        .out_val(out_val_10)
    );

    // Instantiate the compress module for D=4
    compress #(.D(4), .Q(Q)) dut_D4 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(in_val),
        .out_val(out_val_4)
    );

    // Instantiate the compress module for D=1
    compress #(.D(1), .Q(Q)) dut_D1 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(in_val),
        .out_val(out_val_1)

    );

    // Randomly select which instance to test (D=10, 4, or 1)
    task RANDOM_TEST();
        begin
	        APPLY_INPUT($urandom_range(`MIN_INPUT, `MAX_INPUT));
        end
    endtask

    // Apply inputs
    task APPLY_INPUT(input [11:0] test_val);
        begin
            in_val = test_val;
        end
    endtask


    
    // Test sequence
    initial begin
        // Initialize signals
        clk     = 0;
        rst_n   = 0;
        in_val  = 0;

        // Reset the DUT
        RESETn();

        c1;
    end

    initial begin
	    integer i;
	   
        repeat(3) c1;

        for ( i = 0; i < 4099; i = i + 1) begin
            //RANDOM_TEST(); 
	        APPLY_INPUT(i);

            $display("%d", out_val_10);
            c1;
        end
    end

    // Simulation finish
    initial begin
        #50000;
        $finish;
    end
endmodule


