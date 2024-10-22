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

    wire [9:0] out_val_10;  // Output for D=10
    wire [3:0] out_val_4;   // Output for D=4
    wire out_val_1;         // Output for D=1

    reg [9:0] expected_vals [0:`N_OF_TEST-1];

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
    
    integer error_count = 0;
    
    task ERROR_COUNT;
        begin
            if (error_count == 0) begin
                $display("ALL TESTS PASSED!");
            end else begin
                $display("%d TESTS FAILED!", error_count);
            end
        end
    endtask

    task read_expected_vals_from_file(input string filename);
        integer file, i, code;
        reg [100*8:1] line;
        reg [9:0] temp_val;
        
        file = $fopen(filename, "r");
        if (file == 0) begin
            $display("ERROR: Failed to open file: %s", filename);
            $finish;
        end

        // Read each line of the file and store it in the expected_vals array
        for (i = 0; i < `N_OF_TEST; i = i + 1) begin
            code = $fgets(line, file);  // Read a line from the file
            $fgets(line, file);
            if (code == 0) begin
                $display("ERROR: Not enough values in the file, expected %d values", `N_OF_TEST);
                ERROR_COUNT;
                $finish;
            end
            code = $sscanf(line, "%d", temp_val);  // Convert the line to an integer
            expected_vals[i] = temp_val;
        end

        $fclose(file);
    endtask
    
    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        in_val = 0;

        // Reset the DUT
        RESETn();

        c1;
    end

    initial begin
	    integer i;
	   
        repeat(3) c1;

        read_expected_vals_from_file("expected_vals.txt");

        for ( i = 0; i < 4099; i = i + 1) begin
            //RANDOM_TEST(); 
	       APPLY_INPUT(i);

	       if (out_val_10 !== expected_vals[i]) begin
                $display("ERROR: Mismatch at input %d: Expected %d, got %d", i, expected_vals[i], out_val_10);
                error_count = error_count + 1;
            end

            c1;
        end
    end

    // Simulation finish
    initial begin
        #50000;
        ERROR_COUNT;
        $finish;
    end

    // Dump the waveform
    initial begin
        $fsdbDumpfile("tb.fsdb");
    	$fsdbDumpvars(0, tb_compress); // Dump all signals in the tb_compress module
   	    $fsdbDumpvars(1, tb_compress.dut_D10); // Dump all signals in dut_D10
   	    $fsdbDumpvars(1, tb_compress.dut_D4);   // Dump all signals in dut_D4
    	$fsdbDumpvars(1, tb_compress.dut_D1);   // Dump all signals in dut_D1
    end
endmodule


