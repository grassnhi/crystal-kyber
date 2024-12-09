module rom(
    input clk,
    input rst,
    input [95:0] wdata,
    input [4:0] wdata_addr,
    input [4:0] rdata_addr,
    output [95:0] rdata
);
reg [95:0]ROM[0:31];
integer i;
always@(posedge clk or posedge rst)begin
    if(rst) begin
        for(i=0; i<32; i=i+1) ROM[i] <= 0;
    end
    else begin
        ROM[wdata_addr] <= wdata;    
    end
end
assign rdata = ROM[rdata_addr];
endmodule