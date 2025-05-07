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
// Description: FSM that generates a start pulse for 10 cycles on 0->1 input transition
// 
//////////////////////////////////////////////////////////////////////////////////

module fsm_rst(
    input wire clk,           // Clock input
    input wire rst,           // Active-high reset
    input wire reg_in,        // 1-bit input signal
    output reg rst_pulse    // Output start pulse
);

    // State encoding
    localparam IDLE   = 2'b00,
               PULSE  = 2'b01;

    // Registers
    reg [1:0] state, next_state;
    reg reg0_prev;              // Previous value of reg_in
    reg [3:0] pulse_counter;    // 4-bit counter for 10 cycles

    // State and sampling logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            reg0_prev <= 1'b0;
            pulse_counter <= 4'd0;
        end else begin
            state <= next_state;
            reg0_prev <= reg_in;

            // Increment or reset pulse_counter
            if (state == PULSE)
                pulse_counter <= pulse_counter + 1;
            else
                pulse_counter <= 4'd0;
        end
    end

    // Next state and output logic
    always @(*) begin
        // Defaults
        rst_pulse = 1'b0;
        next_state = state;

        case (state)
            IDLE: begin
                if (reg_in && !reg0_prev) begin  // 0 -> 1 edge
                    next_state = PULSE;
                end
            end

            PULSE: begin
                rst_pulse = 1'b1;
                if (pulse_counter == 4'd9) begin // 10 cycles (0 to 9)
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule