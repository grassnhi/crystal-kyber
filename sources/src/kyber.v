
module kyber(
    input clk,
    input rst,
    input start,
    input restart,
    input [1:0] mode,
    input [255:0] random_coin,

    input [255:0] m_in,
    input [6399:0]pk_in,// 12*256*2 + 256
    input [6143:0]sk_in,// 12*256*2
    input [6143:0]c_in, // 10*256*2 + 4*256
    
    input pause,
    input [4:0] pause_state,
    input [8:0] bram_addr,
    output [95:0] kyber_bram,
    
    output [4:0] state,
    output [255:0] m_out,
    output [6399:0]pk_out,// 12*256*2 + 256
    output [6143:0]sk_out,// 12*256*2
    output [6143:0]c_out, // 10*256*2 + 4*256
    
    output finish
);

//controller
wire ntt_start, ntt_is_add_or_sub;
wire [1:0] ntt_mode;
wire [8:0]  ntt_ram_r_start_offset_A, ntt_ram_r_start_offset_B, ntt_ram_w_start_offset;

wire G_active, G_rst;

wire CBD_rst, CBD_active;
wire [1:0] CBD_num;
wire [8:0] CBD_ram_w_start_offset;
wire [7:0] CBD_diff;

wire A_gen_rst, A_gen_active;
wire [8:0] A_gen_ram_w_start_offset;
wire [15:0] A_gen_diff;

wire coder_active, coder_load_input_Enc, coder_load_input_Dec;
wire [3:0] coder_mode;

wire CBD_in_sel, rho_sel;

//G
wire [255:0] G_rho, G_sigma;
wire G_finish;
//A_gen
wire A_wen;
wire [8:0] A_waddr;
wire [95:0] A_wdata;
reg [255:0] rho_temp;
wire A_finish;
//CBD
wire CBD_wen;
wire [8:0] CBD_waddr;
wire [95:0] CBD_wdata; 
reg [255:0] CBD_input;
wire CBD_finish;
//ntt
wire ntt_wen;
wire [8:0] ntt_raddr, ntt_waddr;
wire [95:0] ntt_wdata;
reg [95:0] ntt_rdata;
wire ntt_ren;
wire ntt_finish;
//coder
wire [255:0] rho_from_pk;
wire coder_wen;
wire [8:0] coder_raddr, coder_waddr;
wire [95:0] coder_wdata; 
reg [95:0] coder_rdata;
wire coder_finish;
//ram
reg [8:0] ram_addr_1, ram_addr_2;
reg [95:0] ram_wdata_1, ram_wdata_2;
wire [95:0] ram_rdata_2, ram_rdata_1;
reg ram_wen_1, ram_wen_2;
wire change_mode;
assign change_mode = coder_finish | ntt_finish | A_finish | CBD_finish | G_finish;
controller control(
    .clk(clk),
    .rst(rst),
    .start(start),
    .restart(restart),
    .mode(mode),
    .change_signal(change_mode),
    .state(state),
    .finish(finish),
    
    .pause(pause),
    .pause_state(pause_state),
    
    .ntt_start(ntt_start),
    .ntt_mode(ntt_mode),
    .ntt_is_add_or_sub(ntt_is_add_or_sub),
    .ntt_ram_r_start_offset_A(ntt_ram_r_start_offset_A),
    .ntt_ram_r_start_offset_B(ntt_ram_r_start_offset_B),
    .ntt_ram_w_start_offset(ntt_ram_w_start_offset),

    .G_active(G_active),
    .G_rst(G_rst),

    .CBD_rst(CBD_rst),
    .CBD_active(CBD_active),
    .CBD_num(CBD_num),
    .CBD_ram_w_start_offset(CBD_ram_w_start_offset),
    .CBD_diff(CBD_diff),

    .A_gen_rst(A_gen_rst),
    .A_gen_active(A_gen_active),
    .A_gen_ram_w_start_offset(A_gen_ram_w_start_offset),
    .A_gen_diff(A_gen_diff),

    .coder_active(coder_active),
    .coder_load_input_Enc(coder_load_input_Enc),
    .coder_load_input_Dec(coder_load_input_Dec),
    .coder_mode(coder_mode),

    .CBD_in_sel(CBD_in_sel),
    .rho_sel(rho_sel)
);

SHA3_512 G( .M(random_coin),
            .active(G_active),
            .finish(G_finish),
            .clk(clk),.rst(G_rst),
            .Z({G_rho,G_sigma}));


A_generator A_gen(  .M({rho_temp,A_gen_diff}),
                    .ram_w_start_offset(A_gen_ram_w_start_offset), 
                    .clk(clk),.rst(A_gen_rst), .active(A_gen_active),
                    .enw(A_wen),
                    .finish(A_finish),
                    .waddr(A_waddr),
                    .dout(A_wdata));

                    
small_poly_generator CBD(   .M({CBD_input,CBD_diff}), 
                            .ram_w_start_offset(CBD_ram_w_start_offset),
                            .n_num(CBD_num), 
                            .clk(clk),.rst(CBD_rst), .active(CBD_active),
                            .enw(CBD_wen),
                            .finish(CBD_finish),
                            .waddr(CBD_waddr),
                            .dout(CBD_wdata)); 


ntt_processor ntt(
    .clk(clk),
    .rst(rst),
    .start(ntt_start),
    .mode(ntt_mode),
    .add_or_sub(ntt_is_add_or_sub),
    .r_start_offset_A(ntt_ram_r_start_offset_A),
    .r_start_offset_B(ntt_ram_r_start_offset_B),
    .w_data_addr_offset(ntt_ram_w_start_offset),
    .r_data(ntt_rdata),
    .w_data(ntt_wdata),
    .w_data_addr(ntt_waddr),
    .r_data_addr(ntt_raddr),
    .w_data_en(ntt_wen),
    .ntt_ren(ntt_ren),
    .finish(ntt_finish)
);

coder code(
    .clk(clk),
    .rst(rst),
    .active(coder_active),
    .load_input_Enc(coder_load_input_Enc),
    .load_input_Dec(coder_load_input_Dec),
    .mode(coder_mode), 
   
    .pk_in(pk_in), 
    .m_in(m_in), 
    .sk_in(sk_in),
    .c_in(c_in), 
    
    .pk_out(pk_out), 
    .m_out(m_out), 
    .sk_out(sk_out), 
    .c_out(c_out), 

    .rho_from_G(G_rho),
    .rho_from_pk(rho_from_pk),
    .ram_wen(coder_wen),
    .ram_raddr(coder_raddr),
    .ram_waddr(coder_waddr), 
    .ram_rdata(coder_rdata),
    .ram_wdata(coder_wdata),
    .last_cycle(coder_finish)
);
RAM_WRAPPER_wrapper RAM_WRAPPER
   (.addra_0(ram_addr_1),
    .addrb_0(ram_addr_2),
    .clka_0(clk),
    .clkb_0(clk),
    .dina_0(ram_wdata_1),
    .dinb_0(ram_wdata_2),
    .douta_0(ram_rdata_1),
    .doutb_0(ram_rdata_2),
    .ena_0(1),
    .enb_0(1),
    .wea_0(ram_wen_1),
    .web_0(ram_wen_2));

always@(*)begin
    case(rho_sel)
        1'b0:begin
            rho_temp = G_rho;
        end
        1'b1:begin
            rho_temp = rho_from_pk;
        end
    endcase

    case(CBD_in_sel)
        1'b0:begin
            CBD_input = G_sigma;
        end
        1'b1:begin
            CBD_input = random_coin;
        end
    endcase
end
assign kyber_bram = pause ? ram_rdata_1 : 0;
always @(*) begin
    if(CBD_wen)begin
        ram_addr_1 = CBD_waddr;
        ram_wen_1 = CBD_wen;
        ram_wdata_1 = CBD_wdata;
    end
    else begin
        if(ntt_wen)begin
            ram_addr_1 = ntt_waddr;
            ram_wen_1 = ntt_wen;
            ram_wdata_1 = ntt_wdata;
        end
        else begin
            if(pause)begin
                ram_addr_1 = bram_addr;
                ram_wen_1 = 0;
                ram_wdata_1 = ntt_wdata;
            end
            else begin
                ram_addr_1 = ntt_raddr;
                ram_wen_1 = 0;
                ram_wdata_1 = ntt_wdata;
            end
            
        end
    end
    coder_rdata = ram_rdata_2;
    if(A_wen)begin
        ram_addr_2 = A_waddr;
        ram_wen_2 = A_wen;
        ram_wdata_2 = A_wdata;
        ntt_rdata = ram_rdata_1;
    end
    else begin
        if(coder_wen)begin
            ram_addr_2 = coder_waddr;
            ram_wen_2 = coder_wen;
            ram_wdata_2 = coder_wdata;
            ntt_rdata = ram_rdata_1;
        end
        else begin
            if(ntt_ren)begin
                ntt_rdata = ram_rdata_2;
                ram_addr_2 = ntt_raddr;
            end
            else begin
                ntt_rdata = ram_rdata_1;
                ram_addr_2 = coder_raddr;
            end
            ram_wen_2 = coder_wen;
            ram_wdata_2 = coder_wdata;
        end
    end
end
endmodule