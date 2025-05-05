//PRF-n1(n1=3), n2(n2=2)
module SHAKE_256(input [0:264-1] M,
                input active, //Let stage go to ABSORB_PROCESS 
                input [1:0] n_num, //1 => n1; 2 => n2
                input clk, rst,
                output reg finish,
                output reg [0:1536-1] Z);

parameter d_SIZE_1 = 1536,//B^(64n1)=8*64*3
          d_SIZE_2 = 1024,//B^(64n2)=8*64*2  
          c_SIZE = 512,
          r_SIZE = 1088, //r=b-c
          M_SIZE = 264; //256+8 (s||b)
parameter j = 818;//j=r_SIZE - (M_SIZE+4+2)

wire [0:(M_SIZE+4)-1] N;
wire [0:((M_SIZE+4)+1+j+1)-1] P;
wire [4:0] nr;
wire [0:1599] str_out;
wire [2:0] cnt;//counter+1
wire [11:0] counter_r_r_SIZE;//counter_r-r_SIZE
reg [2:0] current_state,next_state;
reg load;
reg [0:1599] str, str_temp, str_temp2;
reg [2:0] counter;  //0~n-1
reg [4:0] counter_f;//count rnds of KECCAK_p
reg [11:0] counter_r;//count times of Z=Z||Trunc_r(S)
reg [0:(r_SIZE*2)-1] Z_temp;// r*2 bits

assign N ={M,4'b1111}; //N=M||1111
assign nr = 5'd24;   //nr=24

assign P = {N,1'b1,{j{1'b0}},1'b1}; //pad10*1(r,len(N))

parameter n = 1;//n=len(P)/r = 1
assign cnt = counter + 3'd1;//counter+1
assign counter_r_r_SIZE = counter_r-r_SIZE;

parameter IDLE              = 3'b000,
          ABSORB_PROCESS    = 3'b001,
          ABSORB_UPDATE     = 3'b010,
          SQUEEZ_INITIALIZE = 3'b011,
          SQUEEZ_PROCESS    = 3'b100,
          SQUEEZ_UPDATE     = 3'b101,
          SQUEEZ_CHECK      = 3'b110,
          FINALIZE          = 3'b111;

KECCAK_p keccak_p( .S(str_temp),
                   .nr(nr),
                   .load(load),
                   .clk(clk), .rst(rst),
                   .S_out(str_out));

always@(posedge clk or posedge rst)begin
        if(rst)begin
            current_state <= IDLE;
            str_temp <= 1600'd0;
            str_temp2 <= 1600'd0;
            counter <= 3'd0;
            counter_f <= 5'd0;
            counter_r <= 12'd0;
            Z_temp <= {r_SIZE*2{1'b0}};

        end
        else begin
            current_state <= next_state;
            //str_temp= S^(Pi||c(0))
            if(next_state == ABSORB_PROCESS)begin
                str_temp <= str^{P[counter+:r_SIZE],{c_SIZE{1'b0}}};
            end
            else if(next_state == SQUEEZ_PROCESS) begin
                str_temp <= str_temp2;
            end
            else begin
                str_temp <= str_temp;
            end
            
            
            //let S equal to str_out after do a S=f(S^(Pi||c(0))) and S=f(S)
            str_temp2 <= (current_state == ABSORB_UPDATE || current_state == SQUEEZ_UPDATE)? str_out:str_temp2;

            counter <= (current_state == ABSORB_UPDATE)? counter+3'd1 : counter;
            counter_r <= (next_state == SQUEEZ_INITIALIZE || next_state==SQUEEZ_CHECK)? counter_r+r_SIZE:counter_r;//+r_SIZE
            
            //counter_f
            if((current_state == ABSORB_PROCESS)||(current_state == SQUEEZ_PROCESS))begin
                counter_f <= counter_f+5'd1;
            end
            else if((next_state == ABSORB_PROCESS) || (next_state==SQUEEZ_PROCESS))begin
                counter_f <= 5'd0;
            end
            else begin
                counter_f <= counter_f;
            end

            //Z=Z||Trunc_r(S)
            if(current_state == SQUEEZ_INITIALIZE || current_state == SQUEEZ_CHECK)begin
                Z_temp[counter_r_r_SIZE +:r_SIZE] <= str_temp2[0:r_SIZE-1];
            end
            else begin
                Z_temp[counter_r_r_SIZE +:r_SIZE] <= Z_temp[counter_r_r_SIZE +:r_SIZE];
            end

            // if (next_state == IDLE) begin
            //     str_temp <= 1600'd0;
            //     str_temp2 <= 1600'd0;
            //     counter <= 3'd0;
            //     counter_f <= 5'd0;
            //     counter_r <= 12'd0;
            //     Z_temp <= {r_SIZE*2{1'b0}};
            // end

        end

end
            


always@(current_state or active or counter_f or cnt or counter_r or n_num)begin
	//next stage
	case(current_state)
		IDLE:               next_state = (active)? ABSORB_PROCESS:IDLE;
		ABSORB_PROCESS:     next_state = (counter_f== 5'd25) ? ABSORB_UPDATE:ABSORB_PROCESS;//S=f(S^(Pi||c(0)))
		ABSORB_UPDATE:      next_state = (cnt == n) ? SQUEEZ_INITIALIZE:ABSORB_PROCESS; //counter is from 0 to n-1
        //determine if d<=|Z|
        SQUEEZ_INITIALIZE:  begin 
            if((n_num == 2'd1) && (counter_r >= d_SIZE_1))begin
                next_state = FINALIZE;
            end
            else if((n_num == 2'd2) && (counter_r >= d_SIZE_2))begin
                next_state = FINALIZE;
            end
            else begin
                next_state = SQUEEZ_PROCESS;
            end
        end
        SQUEEZ_PROCESS:     next_state = (counter_f == 5'd25) ?SQUEEZ_UPDATE:SQUEEZ_PROCESS;//S=f(S)
        SQUEEZ_UPDATE:      next_state = SQUEEZ_CHECK;
        //determine if d<=|Z|
        SQUEEZ_CHECK:       begin 
            if((n_num == 2'd1) && (counter_r >= d_SIZE_1))begin
                next_state = FINALIZE;
            end
            else if((n_num == 2'd2) && (counter_r >= d_SIZE_2))begin
                next_state = FINALIZE;
            end
            else begin
                next_state = SQUEEZ_PROCESS;
            end
        end
        // FINALIZE:           next_state = IDLE;//output
        FINALIZE:           next_state = IDLE;//output
		default:            next_state = IDLE;
	endcase	
end

always@(*)begin
    case(current_state)
		IDLE: begin
                // str_temp = 1600'd0;
                // str_temp2 = 1600'd0;
                // counter = 3'd0;
                // counter_f = 5'd0;
                // counter_r = 12'd0;
                // Z_temp = {r_SIZE*2{1'b0}};
                Z = (n_num == 2'd1)? Z_temp[0:d_SIZE_1-1]: Z_temp[0:d_SIZE_2-1];
                load = 1'b0;
                str = 1600'd0;
                finish = 1'b0;
            end    
		ABSORB_PROCESS: begin
                Z = (n_num == 2'd1)? Z_temp[0:d_SIZE_1-1]: Z_temp[0:d_SIZE_2-1];
                load = 1'b1;//load=1
                finish = 1'b0;
                if(counter==3'd0)begin
                    str = 1600'd0;
                end
                else begin
                    str = str_temp2;
                end
            end
		ABSORB_UPDATE: begin
                Z = (n_num == 2'd1)? Z_temp[0:d_SIZE_1-1]: Z_temp[0:d_SIZE_2-1];
                load = 1'b1;//load=1
                str = str_temp2;
                finish = 1'b0;
            end
        SQUEEZ_INITIALIZE: begin
                Z = (n_num == 2'd1)? Z_temp[0:d_SIZE_1-1]: Z_temp[0:d_SIZE_2-1];
                load = 1'b0;
                str = str_temp2;
                finish = 1'b0;
            end
        SQUEEZ_PROCESS: begin
                Z = (n_num == 2'd1)? Z_temp[0:d_SIZE_1-1]: Z_temp[0:d_SIZE_2-1];
                load = 1'b1;//load=1
                str = str_temp2;
                finish = 1'b0;
            end
        SQUEEZ_UPDATE: begin
                Z = (n_num == 2'd1)? Z_temp[0:d_SIZE_1-1]: Z_temp[0:d_SIZE_2-1];
                load = 1'b1;//load=1
                str = str_temp2;
                finish = 1'b0;
            end
        SQUEEZ_CHECK: begin
                Z = (n_num == 2'd1)? Z_temp[0:d_SIZE_1-1]: Z_temp[0:d_SIZE_2-1];
                load = 1'b0;
                str = str_temp2;
                finish = 1'b0;
            end
        FINALIZE: begin
                //Z=Trunc_d(Z)
                Z = (n_num == 2'd1)? Z_temp[0:d_SIZE_1-1]: Z_temp[0:d_SIZE_2-1];
                load = 1'b0;
                str = str_temp2;
                finish = 1'b1; //finish = 1
            end
        // default: begin  
        // end
		default: begin
                Z = {d_SIZE_1{1'd0}};
                load = 1'b0;
                str = str_temp2;
                finish = 1'b0;
        end
    endcase
end

endmodule