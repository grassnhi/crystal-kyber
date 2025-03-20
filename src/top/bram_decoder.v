`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2025 07:55:20 PM
// Design Name: 
// Module Name: bram_decoder
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


module bram_decoder (
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

    reg [2:0] current_state, next_state;

    // Registers for control logic (start, finish, mode, etc.)
    reg [127:0] start_reg;
    wire [127:0] finish_reg;
    reg [127:0] mode_reg;
    reg [255:0] random_coin;
    reg [255:0] m_in;
    wire [6399:0] pk_in;
    wire [6143:0] sk_in;
    wire [6143:0] c_in;
    wire [6399:0] pk_out;
    wire [6143:0] sk_out;
    wire [6143:0] c_out;
    wire [255:0] m_out;
    
    // BRAM control signals
    wire enb_pk, enb_sk, enb_c;
    wire web_pk, web_sk, web_c;
    wire reb_pk, reb_sk, reb_c;

    // Read/Write done signals
    wire w_done_pk, r_done_pk;
    wire w_done_sk, r_done_sk;
    wire w_done_c, r_done_c;

    // Pulse generation signals
    reg r_done_pk_d, r_done_sk_d, r_done_c_d;
    wire r_done_pk_pulse, r_done_sk_pulse, r_done_c_pulse;

    // Start Kyber signal
    wire start_kyber;
    wire finish;
    wire finish_kyber;
    
    // Address decoding signals
    wire [16:0] bram_addr;
    wire [15:0] bram_we;
    wire bram_en, bram_clk, bram_rst;
    wire pk_bram_enable, sk_bram_enable, c_bram_enable;
    reg pk_bram_read, sk_bram_read, c_bram_read;
    wire [127:0] bram_rddata_pk, bram_rddata_sk, bram_rddata_c;
    wire [127:0] bram_wrdata;
    reg [127:0] bram_rddata;

    wire reg_addr;

    assign reg_addr = (s_axi_awaddr[16:3] == 14'b0);
    
    // Address decode logic
    assign pk_bram_enable = bram_addr[16] && bram_en; // Enable pk_bram
    assign sk_bram_enable = bram_addr[15] && bram_en; // Enable sk_bram
    assign c_bram_enable  = bram_addr[14] && bram_en; // Enable c_bram


    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            start_reg <= 128'b0;
            // finish_reg <= 128'b0;
            mode_reg <= 128'b0;
            random_coin[0] <= 128'b0;
            random_coin[1] <= 128'b0;
            m_in <= 256'b0;
        end else if (s_axi_wvalid && reg_addr) begin // chạy được đi gòi check sau ha
            case (s_axi_awaddr[2:0])
                3'd0: start_reg <= s_axi_wdata;
                // 3'd1: finish_reg <= s_axi_wdata;
                3'd2: mode_reg <= s_axi_wdata;
                3'd3: random_coin[127:0] <= s_axi_wdata;
                3'd4: random_coin[255:128] <= s_axi_wdata;
                3'd5: m_in[127:0] <= s_axi_wdata;
                3'd6: m_in[255:128] <= s_axi_wdata;
                default: ;
            endcase // need 1 cycle to write
        end else if (current_state != IDLE)
            start_reg <= 128'b0;
    end
    
    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            pk_bram_read <= 0;
            sk_bram_read <= 0;
            c_bram_read <= 0;
        end 
        else begin
            pk_bram_read <= pk_bram_enable;
            sk_bram_read <= sk_bram_enable;
            c_bram_read <= c_bram_enable;
        end
    end

    always @(*) begin // này chắc cũng cần debug quá, sắp Tết hong biết code
        if (pk_bram_read)
            bram_rddata = bram_rddata_pk;
        else if (sk_bram_read)
            bram_rddata = bram_rddata_sk;
        else if (c_bram_read)
            bram_rddata = bram_rddata_c;
        else if (s_axi_araddr[16:3] == 14'b0) begin // chạy được đi gòi check sau ha
            case (s_axi_araddr[2:0]) // Use read address (s_axi_araddr) for selecting read data
                3'd0: bram_rddata = start_reg;             // Read `start_reg`
                3'd1: bram_rddata = finish_reg;            // Read `finish_reg`
                3'd2: bram_rddata = mode_reg;              // Read `mode_reg`
                3'd3: bram_rddata = random_coin[127:0];    // Read lower 128 bits of `random_coin`
                3'd4: bram_rddata = random_coin[255:128];  // Read upper 128 bits of `random_coin`
                3'd5: bram_rddata = m_out[127:0];           // Read lower 128 bits of `m_in`
                3'd6: bram_rddata = m_out[255:128];         // Read upper 128 bits of `m_in`
                default: bram_rddata = 128'b0;
            endcase
        end else bram_rddata = 128'b0;
    end

    // FSM Logic
    always @(posedge bram_clk or posedge bram_rst) begin
        if (bram_rst) begin
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
                if ((mode_reg[1:0] == 0) || (mode_reg[1:0] == 1 && r_done_pk) || (mode_reg[1:0] == 2 && r_done_sk && r_done_c)) 
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
                if ((mode_reg[1:0] == 0 && w_done_pk) || (mode_reg[1:0] == 1 && w_done_c) || (mode_reg[1:0] == 2))
                    next_state = IDLE;
                else 
                    next_state = WRITE;
            end
            default: next_state = IDLE;
        endcase
    end

//    // Control logic based on FSM state
    assign web_pk = (current_state == WRITE && mode_reg[1:0] == 0);
    assign web_sk = (current_state == WRITE && mode_reg[1:0] == 0);
    assign web_c  = (current_state == WRITE && mode_reg[1:0] == 1);
    assign reb_pk = ((current_state == READ || current_state == PROCESS) && mode_reg[1:0] == 1);
    assign reb_sk = ((current_state == READ || current_state == PROCESS) && mode_reg[1:0] == 2);
    assign reb_c  = ((current_state == READ || current_state == PROCESS) && mode_reg[1:0] == 2);

    // Enable signals for BRAMs
    assign enb_pk = web_pk || reb_pk;
    assign enb_sk = web_sk || reb_sk;
    assign enb_c  = web_c || reb_c;

    // Generate pulses for read done signals
    assign r_done_pk_pulse = r_done_pk && !r_done_pk_d;
    assign r_done_sk_pulse = r_done_sk && !r_done_sk_d;
    assign r_done_c_pulse  = r_done_c && !r_done_c_d;

    assign start_kyber = (start_reg[0] && (mode_reg[1:0] == 0)) || (r_done_pk_pulse && mode_reg[1:0] == 1)|| (r_done_sk_pulse && r_done_c_pulse && mode_reg[1:0] == 2);
    assign finish = (current_state == IDLE);
    always @(posedge bram_clk or posedge bram_rst) begin
        if (bram_rst) begin
            r_done_pk_d <= 1'b0;
            r_done_sk_d <= 1'b0;
            r_done_c_d  <= 1'b0;
        end else begin
            r_done_pk_d <= r_done_pk;
            r_done_sk_d <= r_done_sk;
            r_done_c_d  <= r_done_c;
        end
    end
   
    // AXI-BRAM Controller Instance
    axi_bram_ctrl_128_wrapper u_axi_bram_ctrl_128_wrapper (
        .bram_addr_a_0(bram_addr),
        .bram_clk_a_0(bram_clk),
        .bram_en_a_0(bram_en),
        .bram_rddata_a_0(bram_rddata), //in
        .bram_rst_a_0(bram_rst),
        .bram_we_a_0(bram_we),
        .bram_wrdata_a_0(bram_wrdata),

        // AXI Interface
        .s_axi_aclk_0(s_axi_aclk),
        .s_axi_aresetn_0(s_axi_aresetn),
        .s_axi_araddr_0(s_axi_araddr),
        .s_axi_arburst_0(s_axi_arburst),
        .s_axi_arcache_0(s_axi_arcache),
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
        .s_axi_wvalid_0(s_axi_wvalid)
    );


    // BRAM Instance for pk_bram
    auto_ram #(
        .DATA_WIDTH(6400), 
        .CHUNK_WIDTH(128) 
    ) u_pk_bram (
        .clk(bram_clk),
        .ena_0(pk_bram_enable),
        .wea_0(&bram_we),
        .addra_0(bram_addr[9:4]),
        .dina_0(bram_wrdata),
        .douta_0(bram_rddata_pk),
        .enb_0(enb_pk),
        .web_0(web_pk),
        .dinb_0(pk_out),
        .doutb_0(pk_in),
        .r_done(r_done_pk),
        .w_done(w_done_pk)
    );

    // BRAM Instance for sk_bram
    auto_ram #(
        .DATA_WIDTH(6144), 
        .CHUNK_WIDTH(128) 
    ) u_sk_bram (
        .clk(bram_clk),
        .ena_0(sk_bram_enable),
        .wea_0(&bram_we),
        .addra_0(bram_addr[9:4]),
        .dina_0(bram_wrdata),
        .douta_0(bram_rddata_sk),
        .enb_0(enb_sk),
        .web_0(web_sk),
        .dinb_0(sk_out),
        .doutb_0(sk_in),
        .r_done(r_done_sk),
        .w_done(w_done_sk)
    );

    // BRAM Instance for c_bram
    auto_ram #(
        .DATA_WIDTH(6144), 
        .CHUNK_WIDTH(128) 
    ) u_c_bram (
        .clk(bram_clk),
        .ena_0(c_bram_enable),
        .wea_0(&bram_we),
        .addra_0(bram_addr[9:4]),
        .dina_0(bram_wrdata),
        .douta_0(bram_rddata_c),
        .enb_0(enb_c),
        .web_0(web_c),
        .dinb_0(c_out),
        .doutb_0(c_in),
        .r_done(r_done_c),
        .w_done(w_done_c)
    );

    top u_kyber (
        .clk         (bram_clk),
        .rst         (bram_rst),
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

