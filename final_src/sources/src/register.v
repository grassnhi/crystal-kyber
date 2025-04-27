`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2025 11:53:07 PM
// Design Name: 
// Module Name: reg
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

module cs_register(
    // BRAM
    input wire clk,
    input wire rst,
    input wire en,
    input wire [12:0]  addr,
    input wire [3:0]  we,
    input wire [31:0] wrdata,
    output reg [31:0] rddata,

    //stastus + debug signal
    input wire [1:0] current_state, 
    input wire [8:0] cnt,
    input wire [31:0] pk_out_reg,
    input wire [31:0] sk_out_reg,
    input wire [31:0] c_out_reg,
    input wire [31:0] m_out_reg,
    
    input wire [31:0] last_data,
    input wire [15:0] we_kb_br,
    input wire kb_br_en,
    input wire [31:0] rddata_reg,
    input wire [31:0] addr_br_kb_reg,
    input wire [31:0] addr_kb_br_reg,
    
    //control signal
    output wire start_pulse,
    output wire restart_pulse,
    output wire rst_pulse,
    output reg [1:0] mode
    );
    
    parameter IDLE = 2'b00;
    parameter READ = 2'b01;
    parameter PROCESS = 2'b10;
    parameter WRITE = 2'b11;
    
    // internal regs
    // wr/rd reg
    reg [31:0] start_reg;
    reg [31:0] restart_reg; 
    reg [31:0] mode_reg; 
    reg [31:0] all0_reg; 
    reg [31:0] all1_reg; 
    // rd only reg
    reg [31:0] status_reg; 
    reg [31:0] finish_reg; 
    reg [31:0] debug_reg; 
    reg [31:0] rst_reg; 
    reg [31:0] last_data_reg;
    reg [31:0] we_kb_br_reg;
    reg [31:0] kb_br_en_reg;
    reg [3:0] status;
    
    wire finish;
    
    assign finish = (current_state == IDLE);

    always @(*) begin 
        // wr/rd reg
        mode = mode_reg[1:0]; 
        // rd only reg 
        finish_reg = {31'd0, finish};
        status_reg = {28'd0, status};
        
        last_data_reg = last_data;
        we_kb_br_reg = {16'd0, we_kb_br};
        kb_br_en_reg = {31'd0, kb_br_en};
        all0_reg = 32'b0;
        all1_reg = 32'hFFFF_FFFF;
    end 

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            start_reg <= 0;
            restart_reg <= 0;
            mode_reg <= 0;
            debug_reg <= 0;
            rddata <= 0;
            rst_reg <= 0;
        end 
        else if (we & en) begin 
            case(addr)
                13'd0: rst_reg <= wrdata; 
                13'd1: start_reg <= wrdata;
                13'd2: restart_reg <= wrdata; 
                13'd3: mode_reg <= wrdata; 
                default: debug_reg  <= wrdata;
            endcase
        end
        else if ((!we) & en) begin 
            case(addr)
                13'd0: rddata <= rst_reg;
                13'd1: rddata <= start_reg; 
                13'd2: rddata <= restart_reg; 
                13'd3: rddata <= mode_reg; 
                13'd4: rddata <= finish_reg;
                13'd5: rddata <= status_reg;
                13'd6: rddata <= cnt;
                13'd7: rddata <= all0_reg;
                13'd8: rddata <= all1_reg;
                13'd9: rddata <= pk_out_reg;
                13'd10: rddata <= sk_out_reg;
                13'd11: rddata <= c_out_reg;
                13'd12: rddata <= m_out_reg;
                13'd13: rddata <= last_data_reg;
                13'd14: rddata <= we_kb_br_reg;
                13'd15: rddata <= kb_br_en_reg;
                13'd16: rddata <= rddata_reg;
                13'd17: rddata <= addr_br_kb_reg;
                13'd18: rddata <= addr_kb_br_reg;
                default:  rddata <= 32'd123321;
            endcase
        end 
    end 

    always@(posedge clk or posedge rst) begin
        if (rst) begin
            status <= 4'b0;  
        end else begin
            if (start_pulse) begin
                status <= 4'b0; 
            end else begin
                case(current_state)
                    IDLE: begin
                        status[3] <= 1'b1; 
                    end
                    READ: begin
                        status[0] <= 1'b1; 
                    end
                    PROCESS: begin
                        status[1] <= 1'b1;  
                    end
                    WRITE: begin
                        status[2] <= 1'b1;
                    end
                    default: begin
                        status <= 4'b0;
                    end
                endcase
            end
        end
    end
    
    mini_fsm fsm_start (
        .clk(clk),
        .rst(rst),
        .reg_in(start_reg[0]),
        .start_pulse(start_pulse)
    );
    
    mini_fsm fsm_restart (
        .clk(clk),
        .rst(rst),
        .reg_in(restart_reg[0]),
        .start_pulse(restart_pulse)
    );
    
    fsm_rst fsm_rst (
        .clk(clk),
        .rst(rst),
        .reg_in(rst_reg[0]),
        .rst_pulse(rst_pulse)
    );
    
endmodule