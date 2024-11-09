`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2024 03:08:45 PM
// Design Name: 
// Module Name: keccakp
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


module KECCAK_p(
    input [1599:0] S_in,       // Input data
    input start,               // Start pulse, high for 1 cycle
    input clk, rst,            // Clock and asynchronous reset
    output reg [1599:0] S_out, // Output data after rounds are completed
    output reg done            // Signal to indicate completion of rounds
);

    reg [4:0] counter;          
    reg [1599:0] A;            
    reg started;               
    wire [1599:0] A_out;       
    wire [4:0] counter_next;   
    wire enable;               
    wire finish;            

    // Instantiate Rnd module
    kcck_round rnd (.S_in(A), .round_index(counter), .S_out(A_out));

    // Control signal for enabling rounds
    assign enable = (counter != 5'd24) && started;
    assign counter_next = counter + 5'd1;
    assign finish = (counter == 5'd24) && started;

    // Synchronous process for state `A`, counter, and start flag
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            counter <= 5'd0;
            A <= 1600'd0;
            S_out <= 1600'd0;
            started <= 1'b0;
            done <= 1'b0;
        end else begin
            if (start) begin
                counter <= 5'd0;
                A <= S_in;
                started <= 1'b1;  
                done <= 1'b0;
            end 

            if (enable) begin
                counter <= counter_next;
                A <= A_out;
            end

            if (finish) begin
                S_out <= A_out;
                started <= 1'b0; 
                done <= 1'b1;    
            end
        end
    end
endmodule

