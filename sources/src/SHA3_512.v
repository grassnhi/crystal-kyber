
module SHA3_512(input [0:256-1] M,
                input active, //Let stage go to ABSORB_PROCESS 
                input clk, rst,
                output reg finish,
                output reg [0:512-1] Z);

parameter d_SIZE = 512,
          c_SIZE = 1024,
          r_SIZE = 576, //r=b-c
          M_SIZE = 256;
parameter j = 316;//j=r_SIZE - (M_SIZE+2+2)

wire [0:(M_SIZE+2)-1] N;
wire [0:((M_SIZE+2)+1+j+1)-1] P;
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

assign N ={M,2'b01}; //N=M||01
assign nr = 5'd24;   //nr=24

assign P = {N,1'b1,{j{1'b0}},1'b1}; //pad10*1(r,len(N))

parameter n = 1;//n=len(P)/r = (256+2+1+316+1)/576 = 1
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
        Z_temp <= {r_SIZE*3{1'b0}};

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
            // Z_temp[counter_r_r_SIZE +:r_SIZE] <= str_temp2[r_SIZE-1:0];
        end
        else begin
            Z_temp[counter_r_r_SIZE +:r_SIZE] <= Z_temp[counter_r_r_SIZE +:r_SIZE];
        end
    end

end

always@(current_state or active or counter_f or cnt or counter_r)begin
	//next stage
	case(current_state)
		IDLE:               next_state = (active)? ABSORB_PROCESS:IDLE;
		ABSORB_PROCESS:     next_state = (counter_f== 5'd25) ? ABSORB_UPDATE:ABSORB_PROCESS;//S=f(S^(Pi||c(0)))
		ABSORB_UPDATE:      next_state = (cnt == n) ? SQUEEZ_INITIALIZE:ABSORB_PROCESS; //counter is from 0 to n-1
        SQUEEZ_INITIALIZE:  next_state = (counter_r >= d_SIZE)?FINALIZE:SQUEEZ_PROCESS;//determine if d<=|Z|
        SQUEEZ_PROCESS:     next_state = (counter_f == 5'd25) ?SQUEEZ_UPDATE:SQUEEZ_PROCESS;//S=f(S)
        SQUEEZ_UPDATE:      next_state = SQUEEZ_CHECK;
        SQUEEZ_CHECK:       next_state = (counter_r >= d_SIZE)?FINALIZE:SQUEEZ_PROCESS;//determine if d<=|Z|
        FINALIZE:           next_state = IDLE;//output
		default:            next_state = IDLE;
	endcase	
end

always@(current_state or counter or str_temp2)begin
    case(current_state)
		IDLE: begin
            Z = Z_temp[0:d_SIZE-1];
            load = 1'b0;
            finish = 1'b0;
            str = 1600'd0;
        end    
		ABSORB_PROCESS: begin
            Z = Z_temp[0:d_SIZE-1];
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
            finish = 1'b0;
            Z = Z_temp[0:d_SIZE-1];
            load = 1'b1;//load=1
            str = str_temp2;
        end
        SQUEEZ_INITIALIZE: begin
            Z = Z_temp[0:d_SIZE-1];
            load = 1'b0;
            finish = 1'b0;
            str = str_temp2;
        end
        SQUEEZ_PROCESS: begin
            Z = Z_temp[0:d_SIZE-1];
            load = 1'b1;//load=1
            str = str_temp2;
            finish = 1'b0;
        end
        SQUEEZ_UPDATE: begin
            Z = Z_temp[0:d_SIZE-1];
            load = 1'b1;//load=1
            str = str_temp2;
            finish = 1'b0;
        end
        SQUEEZ_CHECK: begin
            Z = Z_temp[0:d_SIZE-1];
            load = 1'b0;
            str = str_temp2;
            finish = 1'b0;
        end
        FINALIZE: begin
            Z = Z_temp[0:d_SIZE-1]; //Z=Trunc_d(Z)
            load = 1'b0;
            finish = 1'b1;
            str = str_temp2;
        end
        // default: begin
        // end
		default: begin
            Z = {d_SIZE{1'd0}};
            load = 1'b0;
            finish = 1'b0;
            str = str_temp2;
        end
    endcase
end

endmodule