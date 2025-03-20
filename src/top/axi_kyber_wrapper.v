`timescale 1ns / 1ps
`include "top.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2025 08:10:56 PM
// Design Name: 
// Module Name: axi_kyber_wrapper
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


module axi_kyber_wrapper(
    // AXI interface - Inputs
    input wire         s_axi_aclk,
    input wire         s_axi_aresetn,
    input wire [16:0]  s_axi_araddr,     // 17-bit Address
    input wire [1:0]   s_axi_arburst,
    input wire [3:0]   s_axi_arcache,
    input wire [7:0]   s_axi_arlen,
    input wire         s_axi_arlock,
    input wire [2:0]   s_axi_arprot,
    input wire [2:0]   s_axi_arsize,
    input wire         s_axi_arvalid,
    input wire [16:0]  s_axi_awaddr,     // 17-bit Address
    input wire [1:0]   s_axi_awburst,
    input wire [3:0]   s_axi_awcache,
    input wire [7:0]   s_axi_awlen,
    input wire         s_axi_awlock,
    input wire [2:0]   s_axi_awprot,
    input wire [2:0]   s_axi_awsize,
    input wire         s_axi_awvalid,
    input wire         s_axi_bready,
    input wire [127:0] s_axi_wdata,      // 128-bit Data
    input wire [15:0]  s_axi_wstrb,      // 16-bit Write strobe (for 128-bit data)
    input wire         s_axi_wlast,
    input wire         s_axi_wvalid,
    input wire         s_axi_rready,

    // AXI interface - Outputs
    output wire        s_axi_arready,
    output wire        s_axi_awready,
    output wire [1:0]  s_axi_bresp,
    output wire        s_axi_bvalid,
    output wire [127:0]s_axi_rdata,      // 128-bit Data
    output wire        s_axi_rlast,
    output wire [1:0]  s_axi_rresp,
    output wire        s_axi_rvalid,
    output wire        s_axi_wready
);

    // FSM States
    parameter IDLE = 3'b000;
    parameter READ = 3'b001;
    parameter PROCESS = 3'b010;
    parameter WRITE = 3'b011;
    parameter DONE = 3'b100;

    // Bit 17 => 1 = bram, 0 = register
    parameter ram_pkin_offset = 8'd0;
    parameter ram_m_in_offset = 8'd50;
    parameter ram_coin_offset = 8'd52;
    parameter ram_skin_offset = 8'd54;
    parameter ram_c_in_offset = 8'd102;

    parameter ram_pkout_offset = 8'd128;
    parameter ram_skout_offset = 8'd178;
    parameter ram_c_out_offset = 8'd226;
    parameter ram_m_out_offset = 8'd228;

    parameter reg_strart_offset = 8'd0;
    parameter reg_finish_offset = 8'd1;
    parameter reg_mode_offset = 8'd2;

    wire ram_select;
    wire reg_select;

    reg [2:0] current_state, next_state;

    // Registers for control logic (start, finish, mode, etc.)
    reg [127:0] start_reg;
    wire [127:0] finish_reg;
    reg [127:0] mode_reg;
    
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
    wire finish;   
    
    wire bram_clk_a;
    wire bram_rst_a;
    wire bram_en_a;
    wire [15:0] bram_we_a;

    wire [16:0] bram_addr_a;
    wire [127:0] bram_wrdata_a;
    reg [127:0] bram_rddata_a;
    reg [127:0] reg_rddata_a;
    wire [127:0] bram_rddata;
    
    reg [7:0] kyber_bram_addr;
    reg [127:0] kyber_bram_wrdata;
    wire [127:0] kyber_bram_rddata;

    reg kyber_bram_enb;
    reg kyber_bram_web;
  
    reg read_done, write_done;
    reg [6:0] cnt;
    
    // AXI-BRAM Controller Instance
    axi_ctrl_wrapper axi_ctrl_wrapper_i (
        // AXI
        .s_axi_aclk_0(s_axi_aclk),
        .s_axi_araddr_0(s_axi_araddr),
        .s_axi_arburst_0(s_axi_arburst),
        .s_axi_arcache_0(s_axi_arcache),
        .s_axi_aresetn_0(s_axi_aresetn),
        .s_axi_arlen_0(s_axi_arlen),
        .s_axi_arlock_0(s_axi_arlock),
        .s_axi_arprot_0(s_axi_arprot),
        .s_axi_arready_0(s_axi_arready),
        .s_axi_arsize_0(s_axi_arsize),
        .s_axi_arvalid_0(s_axi_arvalid),
        .s_axi_awaddr_0(s_axi_awaddr),
        .s_axi_awburst_0(s_axi_awburst),
        .s_axi_awcache_0(s_axi_awcache),
        .s_axi_awlen_0(s_axi_awlen),
        .s_axi_awlock_0(s_axi_awlock),
        .s_axi_awprot_0(s_axi_awprot),
        .s_axi_awready_0(s_axi_awready),
        .s_axi_awsize_0(s_axi_awsize),
        .s_axi_awvalid_0(s_axi_awvalid),
        .s_axi_bready_0(s_axi_bready),
        .s_axi_bresp_0(s_axi_bresp),
        .s_axi_bvalid_0(s_axi_bvalid),
        .s_axi_rdata_0(s_axi_rdata),
        .s_axi_rlast_0(s_axi_rlast),
        .s_axi_rready_0(s_axi_rready),
        .s_axi_rresp_0(s_axi_rresp),
        .s_axi_rvalid_0(s_axi_rvalid),
        .s_axi_wdata_0(s_axi_wdata),
        .s_axi_wlast_0(s_axi_wlast),
        .s_axi_wready_0(s_axi_wready),
        .s_axi_wstrb_0(s_axi_wstrb),
        .s_axi_wvalid_0(s_axi_wvalid),
        // AXI - BRAM
        .bram_addr_a_0(bram_addr_a),
        .bram_clk_a_0(bram_clk_a),
        .bram_en_a_0(bram_en_a),
        .bram_rddata_a_0(bram_rddata_a),
        .bram_rst_a_0(bram_rst_a),
        .bram_we_a_0(bram_we_a),
        .bram_wrdata_a_0(bram_wrdata_a)
    );

    assign ram_select = bram_addr_a[16] & bram_en_a;
    assign reg_select = ~bram_addr_a[16] & bram_en_a;
      
  
    kyber_bram_wrapper bram_inst (
        // BRAM - AXI
        .addra_0(bram_addr_a[7:0]),
        .clka_0(bram_clk_a),
        .dina_0(bram_wrdata_a),
        .douta_0(bram_rddata),
        .ena_0(ram_select),
        .wea_0(&bram_we_a),
        // Kyber
        .addrb_0(kyber_bram_addr),
        .clkb_0(bram_clk_a),
        .dinb_0(kyber_bram_wrdata),
        .doutb_0(kyber_bram_rddata),
        .enb_0(kyber_bram_enb),
        .web_0(kyber_bram_web)
    );

    // AXI WRITE REG
    always @(posedge bram_clk_a or posedge bram_rst_a) begin
        if(bram_rst_a) begin
            start_reg <= 128'b0;
            mode_reg <= 128'b0;
        end else if (reg_select & bram_we_a) begin 
            case (bram_addr_a[2:0])
                3'd0: begin 
                    start_reg <= s_axi_wdata;
                    mode_reg <= mode_reg;
                end
                3'd2: begin
                    mode_reg <= s_axi_wdata;
                    start_reg <= start_reg;
                end                    
                default: begin
                    mode_reg <= s_axi_wdata;
                    start_reg <= start_reg;                
                end
            endcase // need 1 cycle to write
        end else if (current_state != IDLE) begin
            start_reg <= 128'b0;
            mode_reg <= mode_reg;
        end
    end
    
    // AXI READ REG
    always @(posedge bram_clk_a or posedge bram_rst_a) begin
        if(bram_rst_a) begin
            reg_rddata_a <= 128'b0;
        end else begin
            if (reg_select & bram_we_a) begin 
                case (bram_addr_a[1:0]) 
                    2'd0: reg_rddata_a <= start_reg;             // Read `start_reg`
                    2'd1: reg_rddata_a <= finish_reg;            // Read `finish_reg`
                    2'd2: reg_rddata_a <= mode_reg;              // Read `mode_reg`
                    default: reg_rddata_a <= 128'b0;
                endcase
            end else reg_rddata_a <= 128'b0;
        end
    end

    always @(posedge bram_clk_a or posedge bram_rst_a) begin
        if (bram_rst_a) begin
            bram_rddata_a <= 128'b0;
        end else begin
            if (reg_select) begin 
                bram_rddata_a <= reg_rddata_a;
            end else bram_rddata_a <= bram_rddata;
        end
    end
    
    // FSM Logic
    always @(posedge bram_clk_a or posedge bram_rst_a) begin
        if (bram_rst_a) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (start_reg[0]) 
                    next_state = READ;
                else 
                    next_state = IDLE;
            end
            READ: begin
                if ((mode_reg[1:0] == 0) || read_done) 
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
   
    
    always @(posedge bram_clk_a or posedge bram_rst_a) begin
        if(bram_rst_a) begin
            cnt <= 0;
        end else begin
            if(current_state == IDLE || current_state == PROCESS)
                cnt <= cnt + 7'd1;
            else cnt <= 0;
        end
    end
    
    always @(posedge bram_clk_a or posedge bram_rst_a) begin
        if (bram_rst_a) begin
            kyber_bram_addr <= 0;
            kyber_bram_enb <= 0;
            kyber_bram_web <= 0;
            read_done <= 0;
            write_done <= 0;
            m_in <= 0;
            c_in <= 0;
            sk_in <= 0;
            pk_in <= 0;
        end else begin
            m_in <= m_in;
            c_in <= c_in;
            sk_in <= sk_in;
            pk_in <= pk_in;
            case (current_state)
                READ: begin
                    if (mode_reg[1:0] == 1 && start_reg[1] == 1) begin
                        kyber_bram_addr <= ram_pkin_offset + cnt;
                        kyber_bram_enb <= 1'b1;
                        kyber_bram_web <= 1'b0;
                        pk_in[128*cnt +: 128] <= kyber_bram_rddata;
                        if(cnt == 7'd50) begin
                            sk_in[128*(cnt-7'd50) +: 128] = kyber_bram_rddata;
                        end else if(cnt == 7'd52) begin
                            c_in[128*(cnt-7'd52) +: 128] <= kyber_bram_rddata;
                        end
                        read_done <= (cnt == 7'd54);
                    end if (mode_reg[1:0] == 1 && start_reg[1] == 0) begin
                        kyber_bram_addr <= ram_m_in_offset + cnt;
                        kyber_bram_enb <= 1'b1;
                        kyber_bram_web <= 1'b0;
                        m_in[128*cnt +: 128] = kyber_bram_rddata;
                        read_done <= (cnt == 7'd2);
                    end else if (mode_reg[1:0] == 2) begin
                        kyber_bram_addr <= ram_skin_offset + cnt;
                        kyber_bram_enb <= 1'b1;
                        kyber_bram_web <= 1'b0;
                        sk_in[128*cnt +: 128] <= kyber_bram_rddata;
                        if(cnt == 7'd48) begin
                            c_in[128*(cnt-7'd48) +: 128] = kyber_bram_rddata;
                        end
                        read_done <= (cnt == 7'd50);
                    end
                end
                WRITE: begin
                    if (mode_reg[1:0] == 0) begin
                        kyber_bram_addr <= ram_pkout_offset + cnt;
                        kyber_bram_enb <= 1'b1;
                        kyber_bram_web <= 1'b1;
                        kyber_bram_wrdata <= pk_out[128*cnt +: 128];
                        if(cnt == 7'd50) begin
                            kyber_bram_wrdata <= sk_out[128*(cnt-7'd50) +: 128];
                        end
                        read_done <= (cnt == 7'd98);
                    end else if (mode_reg[1:0] == 1) begin
                        kyber_bram_addr <= ram_c_out_offset + cnt;
                        kyber_bram_enb <= 1'b1;
                        kyber_bram_web <= 1'b1;
                        kyber_bram_wrdata <= c_out[128*cnt +: 128];
                        read_done <= (cnt == 7'd2);
                    end else if (mode_reg[1:0] == 2) begin
                        kyber_bram_addr <= ram_m_out_offset + cnt;
                        kyber_bram_enb <= 1'b1;
                        kyber_bram_web <= 1'b1;
                        kyber_bram_wrdata <= m_out[128*cnt +: 128];
                        read_done <= (cnt == 7'd2);
                    end
                end
                default: begin
                    kyber_bram_addr <= 0;
                    kyber_bram_enb <= 0;
                    kyber_bram_web <= 0;
                    read_done <= 0;
                    write_done <= 0;
                end
            endcase
        end
    end

    top u_kyber (
        .clk         (bram_clk_a),
        .rst         (bram_rst_a),
        .start       (start_kyber),
        .mode        (mode_reg[1:0]),
        .random_coin (random_coin),
        .m_in        (m_in),
        .pk_in       (pk_in),
        .sk_in       (sk_in),
        .c_in        (c_in),
        .m_out       (m_out),
        .pk_out      (pk_out),
        .sk_out      (sk_out),
        .c_out       (c_out),
        .finish      (finish_kyber)
    );

    assign finish_reg = {127'h0, finish};

endmodule