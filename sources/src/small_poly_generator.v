
module small_poly_generator(input [0:264-1] M, //256+8 (s||b)
                            input [8:0] ram_w_start_offset,
                            input [1:0] n_num, //1 => n1; 2 => n2
                            input clk,rst, active,
                            output reg enw, finish,
                            output reg [8:0] waddr,
                            output reg [95:0] dout);

wire [1536-1:0] b;
wire enable;
wire [11:0] a_temp1,b_temp1 ,a_temp2,b_temp2 ,a_temp3,b_temp3;
wire [11:0] a_temp4,b_temp4 ,a_temp5,b_temp5,a_temp6,b_temp6;
wire [11:0] a_temp7,b_temp7 ,a_temp8,b_temp8;
wire [10:0] index_a,index_b;
reg [1:0] current_state,next_state;
reg [7:0]counter_i;
reg [7:0] counter;

parameter IDLE      = 2'b00,
          PROCESS   = 2'b01,
          COMPLETE  = 2'b10;

// parameter IDLE      = 1'b0,
//           PROCESS   = 1'b1;

SHAKE_256 PRF(.M(M),.active(active),.n_num(n_num),.clk(clk),.rst(rst),.finish(enable),.Z(b));

//when i=0 => f0
assign index_a = (n_num == 2'd1) ? (({3'd0,counter_i})<<2) + (({3'd0,counter_i})<<1) : ({3'd0,counter_i})<<2; //2*i*n1=2*i*3; 2*i*n2=2*i*2
assign a_temp1 = (n_num == 2'd1) ? {2'd0,b[index_a]} + {2'd0,b[index_a+11'd1]} + {2'd0,b[index_a+11'd2]} : {2'd0,b[index_a]} + {2'd0,b[index_a+11'd1]};
assign index_b = (n_num == 2'd1) ? (({3'd0,counter_i})<<2) + (({3'd0,counter_i})<<1) + 11'd3 : (({3'd0,counter_i})<<2) + 11'd2; //2*i*n1+n1=2*i*3+3; //2*i*n2+n2=2*i*2+2
assign b_temp1 = (n_num == 2'd1) ? {2'd0,b[index_b]} + {2'd0,b[index_b+11'd1]} + {2'd0,b[index_b+11'd2]} : {2'd0,b[index_b]} + {2'd0,b[index_b+11'd1]};

//when i=0 => f1,index+6*1;  f1,index+4*1
assign a_temp2 = (n_num == 2'd1) ? {2'd0,b[index_a+11'd6]} + {2'd0,b[index_a+11'd7]} + {2'd0,b[index_a+11'd8]} : {2'd0,b[index_a+11'd4]} + {2'd0,b[index_a+11'd5]};
assign b_temp2 = (n_num == 2'd1) ? {2'd0,b[index_b+11'd6]} + {2'd0,b[index_b+11'd7]} + {2'd0,b[index_b+11'd8]} : {2'd0,b[index_b+11'd4]} + {2'd0,b[index_b+11'd5]};

//when i=0 => f64,index+6*64; f64,index+4*64
assign a_temp3 = (n_num == 2'd1) ? {2'd0,b[index_a+11'd384]} + {2'd0,b[index_a+11'd385]} + {2'd0,b[index_a+11'd386]} : {2'd0,b[index_a+11'd256]} + {2'd0,b[index_a+11'd257]};
assign b_temp3 = (n_num == 2'd1) ? {2'd0,b[index_b+11'd384]} + {2'd0,b[index_b+11'd385]} + {2'd0,b[index_b+11'd386]} : {2'd0,b[index_b+11'd256]} + {2'd0,b[index_b+11'd257]};

//when i=0 => f65,index+6*65; f65,index+4*65
assign a_temp4 = (n_num == 2'd1) ? {2'd0,b[index_a+11'd390]} + {2'd0,b[index_a+11'd391]} + {2'd0,b[index_a+11'd392]} : {2'd0,b[index_a+11'd260]} + {2'd0,b[index_a+11'd261]};
assign b_temp4 = (n_num == 2'd1) ? {2'd0,b[index_b+11'd390]} + {2'd0,b[index_b+11'd391]} + {2'd0,b[index_b+11'd392]} : {2'd0,b[index_b+11'd260]} + {2'd0,b[index_b+11'd261]};

//when i=0 => f128,index+6*128; f128,index+4*128
assign a_temp5 = (n_num == 2'd1) ? {2'd0,b[index_a+11'd768]} + {2'd0,b[index_a+11'd769]} + {2'd0,b[index_a+11'd770]} : {2'd0,b[index_a+11'd512]} + {2'd0,b[index_a+11'd513]};
assign b_temp5 = (n_num == 2'd1) ? {2'd0,b[index_b+11'd768]} + {2'd0,b[index_b+11'd769]} + {2'd0,b[index_b+11'd770]} : {2'd0,b[index_b+11'd512]} + {2'd0,b[index_b+11'd513]};

//when i=0 => f129,index+6*129; f129,index+4*129
assign a_temp6 = (n_num == 2'd1) ? {2'd0,b[index_a+11'd774]} + {2'd0,b[index_a+11'd775]} + {2'd0,b[index_a+11'd776]} : {2'd0,b[index_a+11'd516]} + {2'd0,b[index_a+11'd517]};
assign b_temp6 = (n_num == 2'd1) ? {2'd0,b[index_b+11'd774]} + {2'd0,b[index_b+11'd775]} + {2'd0,b[index_b+11'd776]} : {2'd0,b[index_b+11'd516]} + {2'd0,b[index_b+11'd517]};

//when i=0 => f192,index+6*192; f192,index+4*192
assign a_temp7 = (n_num == 2'd1) ? {2'd0,b[index_a+11'd1152]} + {2'd0,b[index_a+11'd1153]} + {2'd0,b[index_a+11'd1154]} : {2'd0,b[index_a+11'd768]} + {2'd0,b[index_a+11'd769]};
assign b_temp7 = (n_num == 2'd1) ? {2'd0,b[index_b+11'd1152]} + {2'd0,b[index_b+11'd1153]} + {2'd0,b[index_b+11'd1154]} : {2'd0,b[index_b+11'd768]} + {2'd0,b[index_b+11'd769]};

//when i=0 => f193,index+6*193; f193,index+4*193
assign a_temp8 = (n_num == 2'd1) ? {2'd0,b[index_a+11'd1158]} + {2'd0,b[index_a+11'd1159]} + {2'd0,b[index_a+11'd1160]} : {2'd0,b[index_a+11'd772]} + {2'd0,b[index_a+11'd773]};
assign b_temp8 = (n_num == 2'd1) ? {2'd0,b[index_b+11'd1158]} + {2'd0,b[index_b+11'd1159]} + {2'd0,b[index_b+11'd1160]} : {2'd0,b[index_b+11'd772]} + {2'd0,b[index_b+11'd773]};

// Sequential block: handles state and counter updates
always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= IDLE;
        counter_i     <= 8'd0;
        counter       <= 8'd0;
    end else begin
        current_state <= next_state;
        if ((next_state == PROCESS) && (current_state != IDLE)) begin
            counter_i <= counter_i + 8'd2; // i = i + 2
            counter   <= counter + 8'd1;   // cnt = cnt + 1
        end
        else begin
            counter_i <= counter_i;
            counter <= counter;
        end
    end
end

// Combinational block: determines the next state
always @(*) begin
    case (current_state)
        IDLE: begin
            next_state = (enable) ? PROCESS : IDLE;
            enw = 1'b0;
            finish = 1'b0;
            waddr = 8'd0;
            dout = 96'd0;
        end

        PROCESS: begin
            next_state = (counter < 8'd31) ? PROCESS : COMPLETE;
            //next clk write 8 coeff         
            enw = 1'b1;
            finish = 1'b0;
            waddr = ram_w_start_offset + counter;
            //addr 0 => coeff: 193 192 65 64 129 128 1 0
            //d=a-b
            dout[0 +:12]= (a_temp1 < b_temp1)? 12'd3329+a_temp1-b_temp1 :a_temp1-b_temp1;
            dout[12 +:12]= (a_temp2 < b_temp2)? 12'd3329+a_temp2-b_temp2 :a_temp2-b_temp2;
            dout[24 +:12]= (a_temp5 < b_temp5)? 12'd3329+a_temp5-b_temp5 :a_temp5-b_temp5;
            dout[36 +:12]= (a_temp6 < b_temp6)? 12'd3329+a_temp6-b_temp6 :a_temp6-b_temp6;
            dout[48 +:12]= (a_temp3 < b_temp3)? 12'd3329+a_temp3-b_temp3 :a_temp3-b_temp3;
            dout[60 +:12]= (a_temp4 < b_temp4)? 12'd3329+a_temp4-b_temp4 :a_temp4-b_temp4;
            dout[72 +:12]= (a_temp7 < b_temp7)? 12'd3329+a_temp7-b_temp7 :a_temp7-b_temp7;
            dout[84 +:12]= (a_temp8 < b_temp8)? 12'd3329+a_temp8-b_temp8 :a_temp8-b_temp8;
        end

        COMPLETE: begin
            next_state = IDLE;
            enw = 1'b0;
            finish = 1'b1;
            waddr = 8'd0;
            dout = 96'd0;
        end
        default: begin
            next_state = IDLE;
            enw = 1'b0;
            finish = 1'b0;
            waddr = 8'd0;
            dout = 96'd0;
        end
    endcase
end

endmodule