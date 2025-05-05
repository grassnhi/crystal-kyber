`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2025 01:23:42 PM
// Design Name: 
// Module Name: test_kyber
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


module test_kyber(
    input clk,
    input rst,
    input start,
    input [1:0] mode,
    input [255:0] random_coin,

    input [255:0] m_in,
    input [6399:0]pk_in,// 12*256*2 + 256
    input [6143:0]sk_in,// 12*256*2
    input [6143:0]c_in, // 10*256*2 + 4*256

    output reg [255:0] m_out,
    output reg [6399:0]pk_out,// 12*256*2 + 256
    output reg [6143:0]sk_out,// 12*256*2
    output reg [6143:0]c_out, // 10*256*2 + 4*256

    output reg finish
);
    
    localparam IDLE = 1'b0;
    localparam COMP = 1'b1;

    reg state, next_state;
    integer i;

    // FSM state register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM next-state logic
    always @(*) begin
        case (state)
            IDLE: next_state = (start ? COMP : IDLE);
            COMP: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output and data handling
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            m_out <= 0;
            pk_out <= 0;
            sk_out <= 0;
            c_out <= 0;
            finish <= 0;
        end else begin
            finish <= 0; // default

            case (state)
                COMP: begin
                    finish <= 1;

                    case (mode)
                        2'b00: begin
                            for (i = 0; i < 25; i = i + 1)
                                pk_out[i*256 +: 256] <= random_coin;
                            for (i = 0; i < 24; i = i + 1)
                                sk_out[i*256 +: 256] <= random_coin;
                            c_out <= c_in;
                            m_out <= m_in;
                        end
                        2'b01: begin
                            for (i = 0; i < 24; i = i + 1)
                                c_out[i*256 +: 256] <= m_in;
                            m_out <= m_in;
                            pk_out <= pk_in;
                            sk_out <= sk_in;
                        end
                        2'b10: begin
                            m_out <= c_in[6143 -: 256];
                            pk_out <= pk_in;
                            sk_out <= sk_in;
                            c_out <= c_in;
                        end
                        default: ; // do nothing
                    endcase
                end
            endcase
        end
    end

endmodule