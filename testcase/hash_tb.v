`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2024 02:13:55 PM
// Design Name: 
// Module Name: theta_step_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for theta_step module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module hash_tb;
    // Parameters
    parameter WIDTH = 1600;
    
    // Inputs
    reg [WIDTH-1:0] S_in;
    
    // Outputs
    wire [WIDTH-1:0] S_out;
    wire [WIDTH-1:0] S_rho_pi;
//    wire [WIDTH-1:0] S_chii;
//    wire [WIDTH-1:0] S_iotaa;
    
    
    // Instantiate the Unit Under Test (UUT)
//    theta_step uut (
//        .S_in(S_in),
//        .S_out(S_out)
////    );
//    rho_step uuut (
//        .S_in(S_in),
//        .S_out(S_out)
//    );
    
//    chi_module uuuut (
//        .S_in(S_in),
//        .S_out(S_chii)
//    );
//    iota_step uuuuut (
//        .S_in(S_in),
//        .round_index(5'b00000),
//        .S_out(S_iotaa)
//    );
    kcck_round uut (
        .S_in(S_in),
        .round_index(5'b00000),
        .S_out(S_out)
    );
    
    // Task to apply test case and display results
    task run_test(input [WIDTH-1:0] test_input);
        begin
            S_in = test_input;
            #10; // Wait for output to stabilize
            $display("S_in  = %h", S_in);
            $display("S_out = %h", S_out);
            $display("------------------------");
        end
    endtask
    
    initial begin
        // Test Cases
        $display("Running theta_step test cases...");
        
        // Test Case 1: All bits set to 1
        run_test(1600'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        
        // Test Case 2: All bits set to 0
        run_test(1600'h00000000000000000000000000000000000000000000000000000000000000000000000000000000);
        
        // Test Case 3: Alternating blocks of 1s and 0s
        run_test(1600'hFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000);
        
        // Test Case 4: Non-uniform values (hex pattern)
        run_test(1600'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF);
        
        // Test Case 5: Reverse pattern of Test Case 4
        run_test(1600'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210);
        
        // Terminate simulation
        $display("All test cases completed.");
        $stop;
    end
endmodule
