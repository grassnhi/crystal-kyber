`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 10:42:09 AM
// Design Name: 
// Module Name: kyber_wrapper
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


module kyber_wrapper(
    input wire [12:0]reg_addr,
    input wire reg_clk,
    input wire reg_en,
    output wire [31:0]reg_rddata,
    input wire reg_rst,
    input wire [3:0]reg_we,
    input wire [31:0]reg_wrdata,
    
    output reg [7:0]addr_br_kb,
    output reg en_br_kb,
    input wire [127:0]rddata_br_kb,
    output reg [15:0]we_br_kb,
    output wire [127:0]wrdata_br_kb,
    
    output reg [7:0]addr_kb_br,
    output reg en_kb_br,
    input wire [127:0]rddata_kb_br,
    output reg [15:0]we_kb_br,
    output reg [127:0]wrdata_kb_br
    );
    
    // FSM States
    parameter IDLE = 2'b00;
    parameter READ = 2'b01;
    parameter PROCESS = 2'b10;
    parameter WRITE = 2'b11;

    // Bit 17 => 1 = bram, 0 = register
// Bit 17 => 1 = bram, 0 = register
    parameter ram_pkin_offset = 8'd0;
    parameter ram_m_in_offset = 8'd50;
    parameter ram_coin_offset = 8'd52;
    parameter ram_skin_offset = 8'd54;
    parameter ram_c_in_offset = 8'd102;

    parameter ram_pkout_offset = 8'd0;
    parameter ram_skout_offset = 8'd54;
    parameter ram_m_out_offset = 8'd50;
    parameter ram_c_out_offset = 8'd102;

    parameter reg_strart_offset = 11'd0;
    parameter reg_finish_offset = 11'd1;
    parameter reg_mode_offset = 11'd2;
    
    wire [1:0] mode;
    reg [255:0] random_coin;
    reg [255:0] m_in;
    reg [6399:0] pk_in;
    reg [6143:0] sk_in;
    reg [6143:0] c_in;
    wire [6399:0] pk_out;
    wire [6143:0] sk_out;
    wire [6143:0] c_out;
    wire [255:0] m_out;
       
    wire start_kyber;   
    wire finish_kyber;   
//    wire finish;

    reg [1:0] current_state;
    reg [1:0] next_state;
    reg [7:0] cnt;
    reg read_done; 
    reg write_done;
    
    wire start_pulse;
    wire restart_pulse;
    wire rst_pulse;
    wire rst;
    reg restart;
    
//    wire [31:0]internal_wrdata;
    wire [127:0]internal_rddata;
    
    wire [31:0]rddata_reg;
    wire [31:0]wrdata_reg;
    wire [31:0] pk_out_reg;
    wire [31:0] sk_out_reg;
    wire [31:0] c_out_reg;
    wire [31:0] m_out_reg;
    wire [31:0]addr_br_kb_reg;
    wire [31:0]addr_kb_br_reg;
    assign rddata_reg = rddata_br_kb[0 +: 32];
    assign wrdata_reg = wrdata_kb_br[0 +: 32];
    assign pk_out_reg = pk_out[0 +: 32];
    assign sk_out_reg = sk_out[0 +: 32];
    assign c_out_reg = c_out[0 +: 32];
    assign m_out_reg = m_out;
    assign addr_br_kb_reg = addr_br_kb;
    assign addr_kb_br_reg = addr_kb_br;
    
    assign rst = reg_rst || rst_pulse;
    
//    assign internal_wrdata = wrdata_br_kb;
    assign internal_rddata = rddata_kb_br;
    assign wrdata_br_kb = 128'h0;

    always @(posedge reg_clk or posedge rst) begin
        if (rst) begin
            restart <= 0;
        end else begin
            if (start_pulse) restart <= 0;
            else if (restart_pulse) restart <= 1;
            else if (finish_kyber) restart <= 0;
        end
    end

    // FSM Logic
    always @(posedge reg_clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (start_pulse || restart_pulse) 
                    next_state = READ;
                else 
                    next_state = IDLE;
            end
            READ: begin
                if (read_done) 
                    next_state = PROCESS;
                else 
                    next_state = READ;
            end
            PROCESS: begin
                if (finish_kyber)
                    next_state = WRITE;
                else
                    next_state = PROCESS;
            end
            WRITE: begin
                if (write_done)
                    next_state = IDLE;
                else 
                    next_state = WRITE;
            end
            default: next_state = IDLE;
        endcase
    end
   
    
    always @(posedge reg_clk or posedge rst) begin
        if(rst) begin
            cnt <= 0;
        end else begin
            if(current_state == IDLE || current_state == PROCESS)
                cnt <= 0;
            else cnt <= cnt + 8'd1;
        end
    end
    
    always @(posedge reg_clk or posedge rst) begin
        if (rst) begin
            addr_br_kb <= 0;
            en_br_kb <= 0;
            we_br_kb <= 0;
            addr_kb_br <= 0;
            en_kb_br <= 0;
            we_kb_br <= 0;
            wrdata_kb_br <= 0;
            read_done <= 0;
            write_done <= 0;
            m_in <= 0;
            c_in <= 0;
            sk_in <= 0;
            pk_in <= 0;
            random_coin <= 0;
        end else begin
            read_done <= 0;
            write_done <= 0;
            en_br_kb <= 1'b1;
            en_kb_br <= 1'b1;
            case (current_state)
                READ: begin
                    if (mode == 2'b0) begin
                        addr_br_kb <= ram_coin_offset + cnt;
                        
                        we_br_kb <= 16'b0;
                        random_coin[128*(cnt-2) +: 128] <= rddata_br_kb;
                        read_done <= (cnt == 8'd2);
                    end else if (mode == 2'b1) begin
                        addr_br_kb <= ram_pkin_offset + cnt;
                        // en_bram <= 1'b1;
                        we_br_kb <= 16'b0;
                        pk_in[128*(cnt-2) +: 128] <= rddata_br_kb;
                        m_in[128*(cnt-8'd52) +: 128] <= rddata_br_kb;
                        random_coin[128*(cnt-8'd54) +: 128] <= rddata_br_kb;
                        read_done <= (cnt == 8'd54);
                    end else if (mode == 2'b1 && restart_pulse) begin
                        addr_br_kb <= ram_m_in_offset + cnt;
                        // en_bram <= 1'b1;
                        we_br_kb <= 16'b0;
                        m_in[128*(cnt-2) +: 128] <= rddata_br_kb;
                        read_done <= (cnt == 8'd2);
                    end else if (mode == 2) begin
                        addr_br_kb <= ram_skin_offset + cnt;
                        // en_bram <= 1'b1;
                        we_br_kb <= 16'b0;
                        sk_in[128*(cnt-2) +: 128] <= rddata_br_kb;
                        if(cnt >= 8'd48) begin
                            c_in[128*(cnt-8'd50) +: 128] = rddata_br_kb;
                        end
                        read_done <= (cnt == 8'd96);
                    end
                end
                WRITE: begin
                    if (mode == 2'b0) begin
                        addr_kb_br <= ram_pkout_offset + cnt;
                        // en_bram <= 1'b1;
                        we_kb_br <= 16'hFFFF;
                        wrdata_kb_br <= pk_out[128*cnt +: 128];
                        if(cnt >= 8'd50) begin
                            wrdata_kb_br <= sk_out[128*(cnt-8'd50) +: 128];
                        end
                        write_done <= (cnt == 8'd96);
                    end else if (mode == 2'b1) begin
                        addr_kb_br <= ram_c_out_offset + cnt;
                        // en_bram <= 1'b1;
                        we_kb_br <= 16'hFFFF;
                        wrdata_kb_br <= c_out[128*cnt +: 128];
                        write_done <= (cnt == 8'd46);
                    end else if (mode == 2'b10) begin
                        addr_kb_br <= ram_m_out_offset + cnt;
                        // en_bram <= 1'b1;
                        we_kb_br <= 16'hFFFF;
                        wrdata_kb_br <= m_out[128*cnt +: 128];
                        write_done <= (cnt == 8'd0);
                    end
                end
                default: begin
                    addr_br_kb <= 0;
                    en_br_kb <= 0;
                    we_br_kb <= 0;
                    addr_kb_br <= 0;
                    en_kb_br <= 0;
                    we_kb_br <= 0;
                end
            endcase
        end
    end

    assign start_kyber = read_done;
    
    
    reg [15:0] kb_br_we;
    reg kb_br_en;
    always @(posedge rst or posedge reg_clk)begin
        if(rst)begin
            kb_br_we <= 0;
            kb_br_en <= 0;
        end
        else begin
            if(we_kb_br)begin
                kb_br_we <= we_kb_br;
                kb_br_en <= en_kb_br;
            end
        end
    end
    cs_register u_csa (
        .clk(reg_clk),
        .rst(reg_rst),
        .en(reg_en),
        .addr(reg_addr),
        .we(reg_we),
        .wrdata(reg_wrdata),
        .rddata(reg_rddata),
        .current_state(current_state),
        .cnt(cnt),
        .pk_out_reg(pk_out_reg),
        .sk_out_reg(sk_out_reg),
        .c_out_reg(c_out_reg),
        .m_out_reg(m_out_reg),
        .last_data(wrdata_reg),
        .we_kb_br(kb_br_we),
        .kb_br_en(kb_br_en),
        .rddata_reg(rddata_reg),
        .addr_br_kb_reg(addr_br_kb_reg),
        .addr_kb_br_reg(addr_kb_br_reg),
        .start_pulse(start_pulse),
        .restart_pulse(restart_pulse),
        .rst_pulse(rst_pulse),
        .mode(mode)
    );
    
	kyber u_kyber(
		.clk(clk),
		.rst(rst),
		.start(start),
		.restart(restart),
		.mode(mode),
		.random_coin(random_coin),

		.m_in(m_in),
		.pk_in(pk_in),// 12*256*2 + 256
		.sk_in(sk_in),// 12*256*2
		.c_in(c_in), // 10*256*2 + 4*256

		.m_out(m_out),
		.pk_out(pk_out),// 12*256*2 + 256
		.sk_out(sk_out),// 12*256*2
		.c_out(c_out), // 10*256*2 + 4*256
		.state(state),
		
		.finish(finish)
	);

    
endmodule