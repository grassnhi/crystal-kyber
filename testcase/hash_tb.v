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
    // wire [WIDTH-1:0] S_out;
    // wire [WIDTH-1:0] S_rho_pi;
    wire [WIDTH-1:0] S_theta;
    wire [WIDTH-1:0] S_rho;
    wire [WIDTH-1:0] S_pi;
//    wire [WIDTH-1:0] S_rho_pi;
    wire [WIDTH-1:0] S_chi;
    wire [WIDTH-1:0] S_iota;
    wire [WIDTH-1:0] S_rnd;
//    wire [WIDTH-1:0] S_chii;
//    wire [WIDTH-1:0] S_iotaa;
    
    
    // Instantiate the Unit Under Test (UUT)
   theta_step theta (
       .S_in(S_in),
       .S_out(S_theta)
   );
   
   rho_step rho (
       .S_in(S_in),
       .S_out(S_rho)
   );
   
   pi_step pi (
       .S_in(S_in),
       .S_out(S_pi)
   );
   
//   rho_pi_step rho_pi (
//       .S_in(S_in),
//       .S_out(S_rho_pi)
//   );
    
   chi_step chi (
       .S_in(S_in),
       .S_out(S_chi)
   );
   
   iota_step iota (
       .S_in(S_in),
       .round_index(5'b00000),
       .S_out(S_iota)
   );
   
    round_step rnd (
        .S_in(S_in),
        .round_index(5'b00000),
        .S_out(S_rnd)
    );
    
    // Task to apply test case and display results
    task run_test(input [WIDTH-1:0] test_input);
        begin
            S_in = test_input;
            #10; // Wait for output to stabilize
            $display("S_in  = %h", S_in);
            $display("S_theta = %h", S_theta);
            $display("S_pi = %h", S_rho);
            $display("S_pi = %h", S_pi);
            $display("S_chi = %h", S_chi);
            $display("S_iota = %h", S_iota);
            $display("S_rnd_integrate = %h", S_rnd);
            $display("------------------------");
        end
    endtask
    
    task cmp(input [WIDTH-1:0] test_input);
        begin
            S_in = test_input;
            #10; // Wait for output to stabilize
            $display("S_in  = %h", S_in);
            $display("S_iota  = %h", S_iota);
            $display("S_rnd  = %h", S_rnd);
//            $display("S_pi = %h", S_rho_pi);
//            $display("S_pi = %h", S_rho);
//            $display("S_pi = %h", S_pi);
            if (S_rnd != S_iota)
                $display("fail");
            else
                $display("pass");
            
//            $display("S_theta = %h", S_theta);
            
//            $display("S_chi = %h", S_chi);
//            $display("S_iota = %h", S_iota);
//            $display("S_rnd = %h", S_rnd);
            $display("------------------------");
        end
    endtask
    
    initial begin
        // Test Cases
        $display("Running compare test cases...");
        
        // Test Case 1: All bits set to 1
        run_test(1600'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
//        cmp(1600'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        
        // Test Case 2: All bits set to 0
        run_test(1600'h00000000000000000000000000000000000000000000000000000000000000000000000000000000);
//        cmp(1600'h00000000000000000000000000000000000000000000000000000000000000000000000000000000);
        
        // Test Case 3: Alternating blocks of 1s and 0s
        run_test(1600'hFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000);
//        cmp(1600'hFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000);
        
        // Test Case 4: Non-uniform values (hex pattern)
        run_test(1600'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF);
//        cmp(1600'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF);
        
        // Test Case 5: Reverse pattern of Test Case 4
        run_test(1600'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210);
//        cmp(1600'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210);
        
        // Terminate simulation
        $display("All test cases completed.");
        $finish;
    end
endmodule

// `timescale 1ns / 1ps

// module Keccak_tb;

//   // 1600-bit wide inputs and expected outputs for transformations
//   reg [1599:0] in;
//   reg [1599:0] expected_out;
//   wire [1599:0] out;

//   // DUT instance (assuming a module called Keccak with transformations as parameters)
//   // Here, "mode" selects the transformation function (0=Theta, 1=Rho, etc.)
//   reg [2:0] mode; // 3-bit mode to select transformation
//   Keccak uut (
//     .in(in),
//     .mode(mode),
//     .out(out)
//   );

//   // Testcase variables
//   integer i;
//   reg [1599:0] test_cases [0:4]; // 5 test cases
//   reg [1599:0] expected_outputs [0:4]; // expected outputs for each transformation

//   initial begin
//     // Initialize the test cases
//     // Test values are chosen randomly here; replace them with actual expected values.
//     test_cases[0] = 1600'hA7D3C4B5D2F3E1A8D9BCA4F8E3D1C7B2A1E3F8C2D9A4B3F6D1E2C4B5D6E3F1C2A3B4C5D6E7F8;
//     test_cases[1] = 1600'h1B2C3D4A5F6E7D8A9B0C1D2E3F4A5B6C7D8E9F0A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8;
//     test_cases[2] = 1600'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
//     test_cases[3] = 1600'h000000000000000000000000000000000000000000000000000000000000000000000000000000;
//     test_cases[4] = 1600'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;

//     // Expected outputs for each transformation mode on each test case
//     // Replace with actual values after computing them or from known vectors
//     expected_outputs[0] = 1600'hEXPECTED_VALUE_THETA;
//     expected_outputs[1] = 1600'hEXPECTED_VALUE_RHO;
//     expected_outputs[2] = 1600'hEXPECTED_VALUE_PI;
//     expected_outputs[3] = 1600'hEXPECTED_VALUE_CHI;
//     expected_outputs[4] = 1600'hEXPECTED_VALUE_IOTA;

//     // Iterate through each transformation
//     for (i = 0; i < 5; i = i + 1) begin
//       mode = i; // Set mode (0=Theta, 1=Rho, etc.)
//       in = test_cases[i];
//       expected_out = expected_outputs[i];
      
//       // Wait for the result
//       #10; // Adjust delay according to your design's propagation delay
      
//       // Check the output
//       if (out !== expected_out) begin
//         $display("Test case %0d for mode %0d FAILED. Expected: %h, Got: %h", i, mode, expected_out, out);
//       end else begin
//         $display("Test case %0d for mode %0d PASSED.", i, mode);
//       end
//     end
//     $finish;
//   end

// endmodule
