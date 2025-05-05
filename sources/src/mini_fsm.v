`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 02:17:51 AM
// Design Name: 
// Module Name: mini_fsm
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


module mini_fsm(
    input wire clk,          // Clock input
    input wire rst,      // Active-low reset
    input wire reg_in, // 8-bit input register (configurable width)
    output reg start_pulse   // Output start pulse
);

    // State encoding
    localparam IDLE      = 2'b00,
               PULSE1    = 2'b01,
//               PULSE2    = 2'b10,
               PULSE3    = 2'b11;

    // Registers
    reg [1:0] state, next_state;
    reg reg0_prev;  // Previous value of reg[0]

    // Synchronous logic - State register and reg[0] sampling
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            reg0_prev <= 1'b0;
        end
        else begin
            state <= next_state;
            reg0_prev <= reg_in;  // Store previous value of reg[0]
        end
    end

    // Next state and output logic
    always @(*) begin
        // Default outputs
        start_pulse = 1'b0;
        next_state = state;

        case (state)
            IDLE: begin
                if (reg_in && !reg0_prev) begin  // Detect 0->1 transition
                    next_state = PULSE1;
                end
            end
            
            PULSE1: begin
                start_pulse = 1'b1;
                next_state = PULSE3;
            end
            
//            PULSE2: begin
//                start_pulse = 1'b1;
//                next_state = PULSE3;
//            end
            
            PULSE3: begin
                start_pulse = 1'b1;
                next_state = IDLE;
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
