`ifndef KECCAK_P
`define KECCAK_P
module KECCAK_p(input [0:1599] S,
                input [4:0] nr,
                input load, //Let stage go to INITIALIZE
                input clk, rst,
                output reg [0:1599] S_out);

reg [4:0] ir;
reg [1:0] current_state, next_state;
reg [0:1599] A;
reg [0:1599] A_temp;
wire [0:1599] A_out;

parameter IDLE          = 2'b00, 
          INITIALIZE    = 2'b01,
          PROCESS       = 2'b10,
          FINALIZE      = 2'b11;

Rnd rnd(.S(A_temp),.ir(ir-5'd1),.S_out(A_out));

always@(posedge clk or posedge rst)begin
        if(rst)begin
                current_state <= IDLE;
                ir <= 5'd1; //set to 1
                A_temp <= 1600'd0;
        end
        else begin
                current_state <= next_state;
                //next_state = PROCESS，A => A_temp
                A_temp <= (next_state ==PROCESS)? A:A_temp;
                
                //PROCESS => a Rnd ; In FINALIZE => ir=24 => ir not change
                if((current_state == PROCESS) && (ir != 5'd24))begin
                        ir <= ir+5'd1;
                end
                else if(next_state == IDLE)begin
                        ir <= 5'd1;
                end
                else begin
                        ir <= ir;
                end
        end
end

always@(current_state or nr or ir or load)begin
	//next state
	case(current_state)
		IDLE:           next_state = (load)? INITIALIZE:IDLE;
		INITIALIZE:     next_state = PROCESS;
		PROCESS:        next_state = (ir >= nr) ? FINALIZE:PROCESS; //nr=24
                FINALIZE:       next_state = IDLE;
		default:        next_state = IDLE;
	endcase	
end

always@(*)begin
        //state output
	case(current_state)
		IDLE: begin
                        S_out = A_out;     
                        A=A_temp;                      
                end
                //string to A
		INITIALIZE:  begin
                        S_out = A_out;
                        A=S;
                end
                //a round Rnd of total 24 rounds(cycles)
		PROCESS: begin
                        S_out = A_out;                         
                        A=A_out;     
                end
                //output final value
                FINALIZE: begin
                        S_out = A_out;
                        A=A_out;
                end
		default:  begin
                        S_out = 1600'd0;
                        A=1600'd0;
                end
        endcase
end


endmodule

`endif