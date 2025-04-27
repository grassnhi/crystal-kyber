module rom(
    input clk,
    input rst,
    input [95:0] wdata,
    input [4:0] wdata_addr,
    input [4:0] rdata_addr,
    output reg [95:0] rdata
);
reg [95:0]ROM[0:31];
integer i;
always@(posedge clk or posedge rst)begin
    if(rst) begin
        for(i=0; i<32; i=i+1) ROM[i] <= 0;
        rdata <= 0;
    end
    else begin
        ROM[wdata_addr] <= wdata;
        if(rdata_addr == wdata_addr) rdata <= wdata;
        else rdata <= ROM[rdata_addr];    
    end
end
endmodule