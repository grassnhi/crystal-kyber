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
`include "../../../sources_1/imports/phase1/Hash/Theta.v"
`include "../../../sources_1/imports/phase1/Hash/Rho.v"
`include "../../../sources_1/imports/phase1/Hash/Pi.v"
`include "../../../sources_1/imports/phase1/Hash/Chi.v"
`include "../../../sources_1/imports/phase1/Hash/Rnd.v"
`include "../../../sources_1/imports/phase1/Hash/KECCAK_p.v"

module hash_tb;
    // Parameters
    parameter WIDTH = 1600;
    
    // Inputs
    // reg [WIDTH-1:0] S_in;
    // reg [7:0] ir;

    // Outputs
    // reg [WIDTH-1:0] S_out;
//   wire [WIDTH-1:0] S_theta;
//   wire [WIDTH-1:0] S_rho;
//   wire [WIDTH-1:0] S_pi;
//   wire [WIDTH-1:0] S_rho_integrate;
//   wire [WIDTH-1:0] S_pi_integrate;
//    wire [WIDTH-1:0] S_chi;
//   wire [WIDTH-1:0] S_chi_integrate;
//   wire [WIDTH-1:0] S_rnd;
//   wire [WIDTH-1:0] S_rnd_integrate;
    
    // Inputs
    reg [0:WIDTH-1] S_in;
    reg [7:0] ir;
    
    // Outputs
//     reg [WIDTH-1:0] S_out;
    wire [0:WIDTH-1] S_theta;
   wire [0:WIDTH-1] S_rho;
   wire [0:WIDTH-1] S_pi;
   wire [0:WIDTH-1] S_rho_integrate;
   wire [0:WIDTH-1] S_pi_integrate;
   wire [0:WIDTH-1] S_chi;
   wire [0:WIDTH-1] S_chi_integrate;
   wire [0:WIDTH-1] S_rnd;
   wire [0:WIDTH-1] S_rnd_integrate;
    
    // Instantiate the Unit Under Test (UUT)
   Theta theta (
       .S(S_in),
       .S_out(S_theta)
   );
   Rho rho (
       .S(S_in),
       .S_out(S_rho)
   );
   Rho rho_integrate (
       .S(S_theta),
       .S_out(S_rho_integrate)
   );
   Pi pi (
       .S(S_in),
       .S_out(S_pi)
   );
   Pi pi_integrate (
       .S(S_rho_integrate),
       .S_out(S_pi_integrate)
   );  
   Chi chi (
       .S(S_in),
       .S_out(S_chi)
   );
   Chi chi_integrate (
       .S(S_pi_integrate),
       .S_out(S_chi_integrate)
   );
   Rnd rnd (
       .S(S_in),
       .ir(ir),
       .S_out(S_rnd)
   );
   Rnd rnd_integrate (
       .S(S_chi_integrate),
       .ir(ir),
       .S_out(S_rnd_integrate)
   );
    
    // Task to apply test case and display results
    task run_test(input [0:WIDTH-1] test_input);
        begin
//            S_in = test_input;
//            #10;
//            $display("S_in  = %h", S_in);
//            $display("S_theta = %h", S_theta);
//           $display("S_rho = %h", S_rho);
//           $display("S_pi = %h", S_pi);
//           $display("S_chi = %h", S_chi);
//           $display("S_rnd = %h", S_rnd);
//            $display("S_rnd_integrate = %h", S_rnd_integrate);
//            $display("------------------------");
            S_in = test_input;
            $display("S_in  = %h", S_in);
            for (ir = 0; ir < 24; ir = ir + 1) begin
                #10; // Wait for output to stabilize
                $display("ir = %d", ir);
                $display("S_rnd = %h", S_rnd);
                $display("S_rnd_integrate = %h", S_rnd_integrate);
                $display("-----------");    
            end
            $display("S_theta = %h", S_theta);
           $display("S_rho = %h", S_rho);
           $display("S_pi = %h", S_pi);
           $display("S_chi = %h", S_chi);
            $display("------------------------");
        end
    endtask
    
    initial begin
        // Test Cases
        $display("Running index Theta test cases...");
        
         // Test Case 1: All bits set to 1
         run_test(1600'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5);
        
         // Test Case 2: All bits set to 0
         run_test(1600'h0000000000000000000000000000000000000000000000000000000000000000000000000000000D);
        
         // Test Case 3: Alternating blocks of 1s and 0s
         run_test(1600'hFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF0000000D);
        
         // Test Case 4: Non-uniform values (hex pattern)
         run_test(1600'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDE5);
        
        
         // Test Case 5: Reverse pattern of Test Case 4
         run_test(1600'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543215);

    
        // Terminate simulation
        $display("All test cases completed.");
        $finish;
    end
endmodule