module controller (
    input clk,
    input rst,
    input start,
    input restart,
    input change_signal,
    input [1:0] mode, // 0:KeyGen, 1:Enc, 2:Dec
    output [4:0] state,
    output reg finish,
    input pause,
    input [4:0] pause_state,
    output ntt_start,
    output reg [1:0] ntt_mode,
    output ntt_is_add_or_sub,
    output reg [8:0] ntt_ram_r_start_offset_A,
    output reg [8:0] ntt_ram_r_start_offset_B,
    output reg [8:0] ntt_ram_w_start_offset,

    output reg G_active,
    output reg G_rst,

    output CBD_rst, 
    output reg CBD_active,
    output reg [1:0] CBD_num, //1 => n1; 2 => n2
    output reg [8:0] CBD_ram_w_start_offset,
    output reg [7:0] CBD_diff,
    
    output A_gen_rst, 
    output reg A_gen_active,
    output reg [8:0] A_gen_ram_w_start_offset,
    output reg [15:0] A_gen_diff,
    
    output coder_active,
    output reg coder_load_input_Enc,
    output reg coder_load_input_Dec,
    output reg [3:0] coder_mode, 

    output CBD_in_sel, // 0:from G, 1:from random coin
    output rho_sel // 0:from G, 1:from pk
);


reg [1:0] A_gen_state;
reg [2:0] CBD_state;
reg [4:0] ntt_state;
reg [4:0] global_state;
// mode define
parameter KeyGen = 2'd0;
parameter Enc = 2'd1;
parameter Dec = 2'd2;
// A_gen_state define
parameter A_gen_st_A00 = 2'd0;
parameter A_gen_st_A01 = 2'd1;
parameter A_gen_st_A10 = 2'd2;
parameter A_gen_st_A11 = 2'd3;

// CBD_state define
parameter CBD_st_s0 = 3'd0;
parameter CBD_st_s1 = 3'd1;
parameter CBD_st_e0 = 3'd2;
parameter CBD_st_e1 = 3'd3; 
parameter CBD_st_e2 = 3'd4;


parameter NTT_st_NTT_r0        = 5'd00; //Keygen|Enc|Dec|
parameter NTT_st_NTT_r1        = 5'd01; //Keygen|Enc|Dec|
parameter NTT_st_MUL_A00_r0    = 5'd02; //Keygen|Enc|Dec|
parameter NTT_st_MUL_A10_r1    = 5'd03; //Keygen|Enc|Dec|
parameter NTT_st_ADD_u0        = 5'd04; //Keygen|Enc|Dec|
parameter NTT_st_INVNTT_u0     = 5'd05; //______|Enc|Dec|
parameter NTT_st_ADD_e0        = 5'd06; //Keygen|Enc|___|
parameter NTT_st_MUL_A01_r0    = 5'd07; //Keygen|Enc|___|
parameter NTT_st_MUL_A11_r1    = 5'd08; //Keygen|Enc|___|
parameter NTT_st_ADD_u1        = 5'd09; //______|Enc|___|
parameter NTT_st_INVNTT_u1     = 5'd10; //______|Enc|___|
parameter NTT_st_ADD_e1        = 5'd11; //Keygen|Enc|___|
parameter NTT_st_MUL_t0_r0     = 5'd12; //______|Enc|___|
parameter NTT_st_MUL_t1_r1     = 5'd13; //______|Enc|___|
parameter NTT_st_ADD_v         = 5'd14; //______|Enc|___|
parameter NTT_st_INVNTT_v      = 5'd15; //______|Enc|___|
parameter NTT_st_ADD_e2        = 5'd16; //______|Enc|___|
parameter NTT_st_ADD_m         = 5'd17; //______|Enc|___|
parameter NTT_st_NTT_e0        = 5'd18; //Keygen|___|___|
parameter NTT_st_NTT_e1        = 5'd19; //Keygen|___|___|
parameter NTT_st_SUB_v_su      = 5'd20; //______|___|Dec|
parameter NTT_st_NTT_s0        = 5'd21; //______|___|Dec|
parameter NTT_st_NTT_s1        = 5'd22; //______|___|Dec|

// ram offset define
parameter ram_0_offset = 9'd0;
parameter ram_1_offset = 9'd32;
parameter ram_2_offset = 9'd64;
parameter ram_3_offset = 9'd96;
parameter ram_4_offset = 9'd128;
parameter ram_5_offset = 9'd160;
parameter ram_6_offset = 9'd192;
parameter ram_7_offset = 9'd224;
parameter ram_8_offset = 9'd256;
parameter ram_9_offset = 9'd288;
parameter ram_10_offset = 9'd320;
parameter ram_11_offset = 9'd352;

// coder mode define
parameter coder_mode_KeyGen_encode_sk = 4'd1;
parameter coder_mode_KeyGen_encode_pk = 4'd2;
parameter coder_mode_Enc_decode_pk = 4'd3;
parameter coder_mode_Enc_decode_m = 4'd4;
parameter coder_mode_Enc_encode_c = 4'd5;
parameter coder_mode_Dec_decode_sk = 4'd6;
parameter coder_mode_Dec_decode_c = 4'd7;
parameter coder_mode_Dec_encode_m = 4'd8;

// ram_w_sel define
parameter ram_w_from_coder = 2'd0;
parameter ram_w_from_ntt = 2'd1;
parameter ram_w_from_A_gen = 2'd2;
parameter ram_w_from_CBD = 2'd3;
// cycle_cnt logic
reg[1:0] stage;
reg [4:0] temp_global_state;
reg restart_mode;
reg temp_restart_mode;
reg [1:0]temp_stage;
parameter START = 2'b0;
parameter PROCESS = 2'b1;
parameter FINISH = 2'd2; 
reg prev_change_signal;
reg change_signal_rising;
wire change_state;
assign change_state = change_signal | ((coder_load_input_Dec | coder_load_input_Enc)&(global_state == 0));
assign state = global_state;
reg load_signal;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        stage <= START;
        global_state <= 8'd0;
        prev_change_signal <= 0;
        coder_load_input_Enc <= 0;
        coder_load_input_Dec <= 0;
        restart_mode <= 0;
        change_signal_rising <= 0;
    end
    else begin
        change_signal_rising <= change_state & ~prev_change_signal;
        prev_change_signal <= change_state;
        global_state <= temp_global_state;
        restart_mode <= temp_restart_mode;
        stage <= temp_stage;
        coder_load_input_Enc = mode == Enc ? load_signal : 0;
        coder_load_input_Dec = mode == Dec ? load_signal : 0;
    end
end
always @(*) begin
    case (stage)
        START : begin
            finish = 0;
            if(start)begin
                temp_global_state = 0;
                temp_stage = PROCESS;
                load_signal = 1;
                temp_restart_mode = 0;
            end
            else begin
                if(restart && mode == 1)begin
                    load_signal = 1;
                    temp_restart_mode = 1;
                    temp_global_state = 28;
                    temp_stage = PROCESS;
                end
                else begin
                    load_signal = 0;
                    temp_restart_mode = 0;
                    temp_global_state = 0;
                    temp_stage = START;
                end
            end
        end 
        PROCESS : begin
            finish = 0;
            load_signal = 0;
            temp_restart_mode = restart_mode;
            if(change_signal_rising)begin
                temp_global_state = global_state + 1;
            end
            else begin
                temp_global_state = global_state;
            end
            if(pause)begin
                temp_stage = (global_state == pause_state) ? FINISH : PROCESS;
            end
            else begin
            case(mode)
                KeyGen:   temp_stage = (global_state == 5'd23) ? FINISH : PROCESS;
                Enc:      temp_stage = (global_state == 5'd31) ? FINISH : PROCESS;
                Dec:      temp_stage = (global_state == 5'd11)  ? FINISH : PROCESS;
                default:  temp_stage = START;
            endcase
            end
        end
        FINISH: begin
            temp_restart_mode = 0;
            load_signal = 0;
            finish = 1;
            temp_stage = START;
            temp_global_state = 0;
        end
        default: begin
            temp_restart_mode = restart_mode;
            load_signal = 0;
            finish = 0;
            temp_stage = START;
            temp_global_state = 0;
        end
    endcase
end
reg ntt_trigger;
reg A_gen_trigger;
reg CBD_trigger;
reg coder_trigger;
reg pre_ntt_trigger;
reg pre_A_gen_trigger;
reg pre_CBD_trigger;
reg pre_coder_trigger;
reg CBD_active_buffer;
assign ntt_start = ntt_trigger ^ pre_ntt_trigger;
assign A_gen_rst = A_gen_trigger ^ pre_A_gen_trigger;
assign CBD_rst = CBD_trigger ^ pre_CBD_trigger;
assign coder_active = coder_trigger ^ pre_coder_trigger;
always @(posedge clk)begin
    G_active <= G_rst;
    G_rst = mode == KeyGen ? start : 0;
end
always @(posedge clk or posedge rst) begin
    if(rst) begin
        A_gen_state <= 0;
        A_gen_trigger <= 0;
        pre_A_gen_trigger <= 0;
        CBD_state <= 0;
        CBD_trigger <= 0;
        pre_CBD_trigger <= 0;
        A_gen_active <= 0;
        CBD_active <= 0;
        CBD_active_buffer <= 0;
    end
    else begin
    A_gen_active <= A_gen_rst;
    CBD_active_buffer <= CBD_rst;
    CBD_active <= CBD_active_buffer;
    if(global_state[4] == 1 || mode[1] == 1) begin
        A_gen_state <= 0;
        A_gen_trigger <= 0;
        pre_A_gen_trigger <= 0;
        CBD_state <= 0;
        CBD_trigger <= 0;
        pre_CBD_trigger <= 0;
    end
    else begin
        pre_A_gen_trigger <= A_gen_trigger;
        pre_CBD_trigger <= CBD_trigger;
        case(global_state[3:0])
            4'd1: begin
                A_gen_state <= A_gen_st_A00;
                A_gen_trigger <= 1;
                CBD_state <= CBD_st_s0;
                CBD_trigger <= 1;
            end
            4'd2: begin
                A_gen_state <= A_gen_state;
                A_gen_trigger <= A_gen_trigger;
                CBD_state <= CBD_st_s1;
                CBD_trigger <= 0;
            end
            4'd3: begin
                A_gen_state <= A_gen_st_A01;
                A_gen_trigger <= 0;
                CBD_state <= CBD_state;
                CBD_trigger <= CBD_trigger;
            end
            4'd4: begin
                A_gen_state <= A_gen_state;
                A_gen_trigger <= A_gen_trigger;
                if(mode[0] == 0)begin
                    CBD_state <= CBD_st_e0;
                    CBD_trigger <= 1;
                end
                else begin
                    CBD_state <= CBD_state;
                    CBD_trigger <= CBD_trigger;
                end
            end
            4'd5: begin
                A_gen_state <= A_gen_st_A10;
                A_gen_trigger <= 1;
                if(mode[0] == 0)begin
                    CBD_state <= CBD_state;
                    CBD_trigger <= CBD_trigger;
                end
                else begin
                    CBD_state <= CBD_st_e0;
                    CBD_trigger <= 1;
                end
            end
            4'd6: begin
                A_gen_state <= A_gen_state;
                A_gen_trigger <= A_gen_trigger;
                CBD_state <= CBD_st_e1;
                CBD_trigger <= 0;
            end
            4'd7: begin
                A_gen_state <= A_gen_st_A11;
                A_gen_trigger <= 0;
                CBD_state <= CBD_state;
                CBD_trigger <= CBD_trigger;
            end
            4'd14: begin
                A_gen_state <= A_gen_state;
                A_gen_trigger <= A_gen_trigger;
                CBD_state <= CBD_st_e2;
                if(mode[0] == 1) CBD_trigger <= 1; 
                else CBD_trigger <= 0;
            end
            default: begin
                A_gen_state <= A_gen_state;
                A_gen_trigger <= A_gen_trigger;
                CBD_state <= CBD_state;
                CBD_trigger <= CBD_trigger;
            end
        endcase
    end
    end
end
always @(posedge clk or posedge rst) begin
    if(rst) begin
        ntt_state <= 0;
        ntt_trigger <= 0;
        pre_ntt_trigger <= 0;
    end
    else begin
        pre_ntt_trigger <= global_state == 0 ? 0 : ntt_trigger;
        case(global_state)
        5'd0: begin
            ntt_state <= ntt_state;
            ntt_trigger <= 0;
        end
        5'd2: begin
            if(mode[1] == 0)begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
            else begin //Dec
                ntt_state <= NTT_st_NTT_s0;
                ntt_trigger <= 1;
            end
        end
        5'd3: begin
            if(mode[1] == 0)begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
            else begin//Dec
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
        end
        5'd4: begin
            if(mode[1] == 0)begin
                ntt_state <= NTT_st_NTT_r0;
                ntt_trigger <= 1;
            end
            else begin//Dec
                ntt_state <= NTT_st_NTT_s1;
                ntt_trigger <= 0;
            end
        end
        5'd5: begin
            if(mode[1] == 0)begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
            else begin//Dec
                ntt_state <= NTT_st_MUL_A00_r0;
                ntt_trigger <= 1;
            end
        end
        5'd6: begin
            if(mode[1] == 0)begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
            else begin//Dec
                ntt_state <= NTT_st_MUL_A10_r1;
                ntt_trigger <= 0;
            end
        end
        5'd7: begin
            if(mode[1] == 0)begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
            else begin//Dec
                ntt_state <= NTT_st_ADD_u0;
                ntt_trigger <= 1;
            end
        end
        5'd8: begin
            if(mode[1] == 0)begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
            else begin
                ntt_state <= NTT_st_INVNTT_u0;
                ntt_trigger <= 0;
            end
        end
        5'd9: begin
            if(mode[1] == 0)begin
                ntt_state <= NTT_st_NTT_r1;
                ntt_trigger <= 0;
            end
            else begin
                ntt_state <= NTT_st_SUB_v_su;
                ntt_trigger <= 1;
            end
        end
        5'd11: begin
            if(mode[1] == 0) begin
                ntt_state <= NTT_st_MUL_A00_r0;
                ntt_trigger <= 1;
            end
            else begin
                ntt_state <= NTT_st_ADD_e0;
                ntt_trigger <= 1;
            end
        end
        5'd12: begin
            ntt_state <= NTT_st_MUL_A10_r1;
            ntt_trigger <= 0;
        end
        5'd13: begin
            ntt_state <= NTT_st_ADD_u0;
            ntt_trigger <= 1;
        end
        5'd14: begin
            if(mode[0] == 0)
            begin
                ntt_state <= NTT_st_MUL_A01_r0;
                ntt_trigger <= 0;
            end
            else
            begin
                ntt_state <= NTT_st_INVNTT_u0;
                ntt_trigger <= 0;
            end
        end
        5'd15: begin
            if(mode[0] == 0)begin
                ntt_state <= NTT_st_MUL_A11_r1;
                ntt_trigger <= 1;
            end
            else begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
        end
        5'd16: begin
            if(mode[0] == 0)begin
                ntt_state <= NTT_st_ADD_u1;
                ntt_trigger <= 0;
            end
            else begin
                ntt_state <= NTT_st_ADD_e0;
                ntt_trigger <= 1;
            end
        end
        5'd17: begin
            if(mode[0] == 0)begin
                ntt_state <= NTT_st_NTT_e0;
                ntt_trigger <= 1;
            end
            else begin
                ntt_state <= NTT_st_MUL_A01_r0;
                ntt_trigger <= 0;
            end
        end
        5'd18: begin
        if(mode[0] == 0)begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
        end
        else begin
                ntt_state <= NTT_st_MUL_A11_r1;
                ntt_trigger <= 1;
        end 
        end
        5'd19: begin
        if(mode[0] == 0)begin
                ntt_state <= NTT_st_NTT_e1;
                ntt_trigger <= 0;
        end
        else begin
                ntt_state <= NTT_st_ADD_u1;
                ntt_trigger <= 0;
        end 
        end
        5'd20: begin
        if(mode[0] == 0)begin
                ntt_state <= NTT_st_ADD_e0;
                ntt_trigger <= 1;
        end
        else begin
                ntt_state <= NTT_st_INVNTT_u1;
                ntt_trigger <= 1;
        end
        end
        5'd21: begin
            if(mode[0] == 0)begin
                ntt_state <= NTT_st_ADD_e1;
                ntt_trigger <= 0;
            end
            else begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
        end
        5'd22: begin
            if(mode[0] == 0)begin
                ntt_state <= NTT_st_ADD_e1;
                ntt_trigger <= ntt_trigger;
            end
            else begin
                ntt_state <= NTT_st_ADD_e1;
                ntt_trigger <= 0;
            end
        end
        5'd23: begin
            if(mode[0] == 0)begin
                ntt_state <= ntt_state;
                ntt_trigger <= ntt_trigger;
            end
            else begin
                ntt_state <= NTT_st_MUL_t0_r0;
                ntt_trigger <= 1;
            end
        end
        5'd24: begin
            ntt_state <= NTT_st_MUL_t1_r1;
            ntt_trigger <= 0;
        end
        5'd25: begin
            ntt_state <= NTT_st_ADD_v;
            ntt_trigger <= 1;
        end
        5'd26: begin
            ntt_state <= NTT_st_INVNTT_v;
            ntt_trigger <= 0;
        end
        5'd27: begin
            ntt_state <= NTT_st_ADD_e2;
            ntt_trigger <= 1;
        end
        5'd29: begin
            ntt_state <= NTT_st_ADD_m;
             if(restart_mode)begin
                ntt_trigger <= 1;
            end
            else begin
                ntt_trigger <= 0;
            end
        end
        default begin
            ntt_state <= ntt_state;
            ntt_trigger <= ntt_trigger;
        end
        endcase
    end
end
always @(posedge clk or posedge rst) begin
    if(rst)begin
        coder_trigger <= 0;
        pre_coder_trigger <= 0;
        coder_mode <= 0;
    end
    else begin
        pre_coder_trigger <= global_state == 0 ? 0 : coder_trigger;
        case(global_state)
        5'd0: begin
            coder_trigger <= 0;
            coder_mode <= coder_mode;
        end
        5'd1: begin
            if(mode[1] == 1)begin
                coder_mode <= coder_mode_Dec_decode_c;
                coder_trigger <= 1;
            end
            else begin
                coder_mode <= coder_mode;
                coder_trigger <= coder_trigger;
            end
        end
        5'd2: begin
            if(mode[1] == 1)begin
                coder_mode <= coder_mode_Dec_decode_sk;
                coder_trigger <= 0;
            end
            else begin
                coder_mode <= coder_mode;
                coder_trigger <= coder_trigger;
            end
        end
        5'd10: begin
            if(mode[1] == 1)begin
                coder_mode <= coder_mode_Dec_encode_m;
                coder_trigger <= 1;
            end
            else begin
                coder_mode <= coder_mode;
                coder_trigger <= coder_trigger;
            end
        end
        5'd17: begin
            if(mode[0] == 0)begin
                coder_trigger <= 1;
                coder_mode <= coder_mode_KeyGen_encode_sk;    
            end
            else begin
                coder_trigger <= coder_trigger;
                coder_mode <= coder_mode;
            end
        end
        5'd20: begin
            if(mode[0] == 0)begin
                coder_trigger <= coder_trigger;
                coder_mode <= coder_mode;
            end
            else begin
                coder_trigger <= 1;
                coder_mode <= coder_mode_Enc_decode_pk;
            end
        end
        5'd22: begin
            if(mode[0] == 0)begin
                coder_mode <= coder_mode_KeyGen_encode_pk;
                coder_trigger <= 0;
            end
            else begin
                coder_trigger <= coder_trigger;
                coder_mode <= coder_mode;
            end
        end   
        5'd28: begin
            if(restart_mode)begin
                coder_trigger <= 1;
            end
            else begin
                coder_trigger <= 0;
            end
            coder_mode <= coder_mode_Enc_decode_m;
        end  
        5'd30: begin
             if(restart_mode)begin
                coder_trigger <= 0;
            end
            else begin
                coder_trigger <= 1;
            end
            coder_mode <= coder_mode_Enc_encode_c;
        end
        default: begin
            coder_trigger <= coder_trigger;
            coder_mode <= coder_mode;
        end
        endcase
    end
    
end
assign ntt_is_add_or_sub = ntt_state == NTT_st_SUB_v_su;
always @(*) begin
    case(ntt_state)
    NTT_st_NTT_r0: begin
        ntt_mode = 2'd0;
        ntt_ram_r_start_offset_A = ram_4_offset;
        ntt_ram_r_start_offset_B = ram_4_offset;
        ntt_ram_w_start_offset = ram_4_offset;
    end
    NTT_st_NTT_r1: begin
        ntt_mode = 2'd0;
        ntt_ram_r_start_offset_A = ram_5_offset;
        ntt_ram_r_start_offset_B = ram_5_offset;
        ntt_ram_w_start_offset = ram_5_offset;
    end
    NTT_st_MUL_A00_r0: begin
        ntt_mode = 2'd2;
        ntt_ram_r_start_offset_A = ram_0_offset;
        ntt_ram_r_start_offset_B = ram_4_offset;
        ntt_ram_w_start_offset = ram_0_offset;
    end
    NTT_st_MUL_A10_r1: begin
        ntt_mode = 2'd2;
        ntt_ram_r_start_offset_A = ram_1_offset;
        ntt_ram_r_start_offset_B = ram_5_offset;
        ntt_ram_w_start_offset = ram_1_offset;
    end
    NTT_st_ADD_u0: begin
        ntt_mode = 2'd3;
        ntt_ram_r_start_offset_A = ram_0_offset;
        ntt_ram_r_start_offset_B = ram_1_offset;
        ntt_ram_w_start_offset = ram_0_offset;
    end
    NTT_st_INVNTT_u0: begin
        ntt_mode = 2'd1;
        ntt_ram_r_start_offset_A = ram_0_offset;
        ntt_ram_r_start_offset_B = ram_0_offset;
        ntt_ram_w_start_offset = ram_0_offset;
    end
    NTT_st_ADD_e0: begin
        ntt_mode = 2'd3;
        ntt_ram_r_start_offset_A = ram_0_offset;
        ntt_ram_r_start_offset_B = ram_6_offset;
        ntt_ram_w_start_offset = ram_6_offset;
    end
    NTT_st_MUL_A01_r0: begin
        ntt_mode = 2'd2;
        ntt_ram_r_start_offset_A = ram_2_offset;
        ntt_ram_r_start_offset_B = ram_4_offset;
        ntt_ram_w_start_offset = ram_2_offset;
    end
    NTT_st_MUL_A11_r1: begin
        ntt_mode = 2'd2;
        ntt_ram_r_start_offset_A = ram_3_offset;
        ntt_ram_r_start_offset_B = ram_5_offset;
        ntt_ram_w_start_offset = ram_3_offset;
    end
    NTT_st_ADD_u1: begin
        ntt_mode = 2'd3;
        ntt_ram_r_start_offset_A = ram_2_offset;
        ntt_ram_r_start_offset_B = ram_3_offset;
        ntt_ram_w_start_offset = ram_3_offset;
    end
    NTT_st_INVNTT_u1: begin
        ntt_mode = 2'd1;
        ntt_ram_r_start_offset_A = ram_3_offset;
        ntt_ram_r_start_offset_B = ram_3_offset;
        ntt_ram_w_start_offset = ram_3_offset;
    end
    NTT_st_ADD_e1: begin
        ntt_mode = 2'd3;
        ntt_ram_r_start_offset_A = ram_3_offset;
        ntt_ram_r_start_offset_B = ram_7_offset;
        ntt_ram_w_start_offset = ram_7_offset;
    end
    NTT_st_MUL_t0_r0: begin
        ntt_mode = 2'd2;
        ntt_ram_r_start_offset_A = ram_9_offset;
        ntt_ram_r_start_offset_B = ram_4_offset;
        ntt_ram_w_start_offset = ram_4_offset;
    end
    NTT_st_MUL_t1_r1: begin
        ntt_mode = 2'd2;
        ntt_ram_r_start_offset_A = ram_10_offset;
        ntt_ram_r_start_offset_B = ram_5_offset;
        ntt_ram_w_start_offset = ram_5_offset;
    end
    NTT_st_ADD_v: begin
        ntt_mode = 2'd3;
        ntt_ram_r_start_offset_A = ram_4_offset;
        ntt_ram_r_start_offset_B = ram_5_offset;
        ntt_ram_w_start_offset = ram_4_offset;
    end
    NTT_st_INVNTT_v: begin
        ntt_mode = 2'd1;
        ntt_ram_r_start_offset_A = ram_4_offset;
        ntt_ram_r_start_offset_B = ram_4_offset;
        ntt_ram_w_start_offset = ram_4_offset;
    end
    NTT_st_ADD_e2: begin
        ntt_mode = 2'd3;
        ntt_ram_r_start_offset_A = ram_4_offset;
        ntt_ram_r_start_offset_B = ram_8_offset;
        ntt_ram_w_start_offset = ram_8_offset;
    end
    NTT_st_NTT_e0:begin
        ntt_mode = 2'd0;
        ntt_ram_r_start_offset_A = ram_6_offset;
        ntt_ram_r_start_offset_B = ram_6_offset;
        ntt_ram_w_start_offset = ram_6_offset;
    end
    NTT_st_NTT_e1:begin
        ntt_mode = 2'd0;
        ntt_ram_r_start_offset_A = ram_7_offset;
        ntt_ram_r_start_offset_B = ram_7_offset;
        ntt_ram_w_start_offset = ram_7_offset;
    end
    NTT_st_ADD_m: begin
        ntt_mode = 2'd3;
        ntt_ram_r_start_offset_A = ram_8_offset;
        ntt_ram_r_start_offset_B = ram_11_offset;
        ntt_ram_w_start_offset = ram_11_offset;
    end
    NTT_st_SUB_v_su: begin
        ntt_mode = 2'd3;
        ntt_ram_r_start_offset_A = ram_2_offset;
        ntt_ram_r_start_offset_B = ram_0_offset;
        ntt_ram_w_start_offset = ram_0_offset;
    end
    NTT_st_NTT_s0: begin
        ntt_mode = 2'd0;
        ntt_ram_r_start_offset_A = ram_0_offset;
        ntt_ram_r_start_offset_B = ram_0_offset;
        ntt_ram_w_start_offset = ram_0_offset;
    end
    NTT_st_NTT_s1: begin
        ntt_mode = 2'd0;
        ntt_ram_r_start_offset_A = ram_1_offset;
        ntt_ram_r_start_offset_B = ram_1_offset;
        ntt_ram_w_start_offset = ram_1_offset;
    end
    default: begin
        ntt_mode = 2'd0;
        ntt_ram_r_start_offset_A = ram_0_offset;
        ntt_ram_r_start_offset_B = ram_0_offset;
        ntt_ram_w_start_offset = ram_0_offset;
    end
    endcase
end
always @(*) begin
    case(CBD_state)       
    CBD_st_s0 : begin
        CBD_ram_w_start_offset = ram_4_offset;
        CBD_diff = 8'd0;
        CBD_num = 2'd1;
    end
    CBD_st_s1 : begin
        CBD_ram_w_start_offset = ram_5_offset;
        CBD_diff = 8'd1;
        CBD_num = 2'd1;            
    end
    CBD_st_e0 : begin
        CBD_ram_w_start_offset = ram_6_offset;
        CBD_diff = 8'd2;
        if(mode[0] == 0) CBD_num = 2'd1;
        else CBD_num = 2'd2;
    end
    CBD_st_e1 : begin
        CBD_ram_w_start_offset = ram_7_offset;
        CBD_diff = 8'd3;
        if(mode[0] == 0) CBD_num = 2'd1;
        else CBD_num = 2'd2;
    end
    CBD_st_e2 : begin
        CBD_ram_w_start_offset = ram_8_offset;
        CBD_diff = 8'd4;
        if(mode[0] == 0) CBD_num = 2'd1;
        else CBD_num = 2'd2;
    end
    default: begin
        CBD_ram_w_start_offset = 8'd0;
        CBD_diff = 8'd0;
        if(mode[0] == 0) CBD_num = 2'd1;
        else CBD_num = 2'd2;
    end
    endcase
end

always @(*) begin
    case(A_gen_state)
    A_gen_st_A00: begin
        A_gen_ram_w_start_offset = ram_0_offset;
        A_gen_diff = { 8'd0, 8'd0 };
    end
    A_gen_st_A01: begin
        A_gen_ram_w_start_offset = ram_1_offset;
        if(mode[0] == 0)begin
            A_gen_diff = { 8'd0, 8'd1 }; 
        end
        else begin
            A_gen_diff = { 8'd1, 8'd0 };
        end
    end
    A_gen_st_A10: begin
        A_gen_ram_w_start_offset = ram_2_offset;
        if(mode[0] == 0)begin
            A_gen_diff = { 8'd1, 8'd0 }; 
        end
        else begin
            A_gen_diff = { 8'd0, 8'd1 };
        end
    end
    A_gen_st_A11: begin
        A_gen_ram_w_start_offset = ram_3_offset;
        A_gen_diff = { 8'd1, 8'd1 };
    end
    endcase
end

// multiplexer sel logic
assign CBD_in_sel = mode != KeyGen;
assign rho_sel = mode != KeyGen;
   
endmodule