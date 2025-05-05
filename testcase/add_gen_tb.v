`include "addr_gen.v"

module bu_tb;
reg clk;
reg rst;
reg [1:0] mode; // 0:NTT, 1:INVNTT, 2:MULT, 3:ADDSUB
reg [7:0]clk_cnt;
wire [6:0]coef_addr;
wire [4:0]r_addr;
wire [4:0]w_addr;
addr_gen ADDR(
    .clk(clk),
    .mode(mode),
    .clk_counter(clk_cnt),
    .coef_addr(coef_addr),
    .r_addr(r_addr),
    .w_addr(w_addr)
    );
initial begin
    $dumpfile("addr_tb.vcd");
    $dumpvars(0, ADDR);
    #0
    rst = 1;
    mode = 1; // 0:NTT, 1:INVNTT, 2:MULT
    #1
    rst = 0;
    #456 
    $finish;
end
initial begin
    clk = 1;
    clk_cnt = 0;
    forever begin
        #1 
        clk = ~clk;
        if (clk) clk_cnt = clk_cnt + 1;
        if(clk_cnt[7:5] >= 7 || rst == 1) clk_cnt = 0;
    end
end
endmodule