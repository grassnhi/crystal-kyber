`include "add_sub.v"
module addsub_tb();
reg clk;
reg rst;
reg add_flag;
reg load_a;
reg load_b, start;
reg [95:0] ram_rdata;
reg [7:0] ram_raddr;
wire ram_wen;
reg [7:0] in_addr_offset_A, in_addr_offset_B;
wire [95:0] ram_wdata;
wire [7:0] ram_in_addr, ram_out_addr;
addsub addsub_ut(
    .clk(clk),
    .rst(rst),
    .start(start),
    .add_flag(add_flag),
    .in_addr_offset_A(in_addr_offset_A),
    .in_addr_offset_B(in_addr_offset_B),
    .in_data(ram_rdata),
    .out_data(ram_wdata),
    .w_en(ram_wen),
    .in_addr(ram_in_addr),
    .out_addr(ram_out_addr)
);
initial begin
    $dumpfile("addsub_tb.vcd");
    $dumpvars(0, addsub_ut);
    rst = 1;
    start = 0;
    load_a = 1;
    load_b = 0;
    add_flag = 0;
    ram_raddr = 0;
    ram_rdata = 0;
    #2 
    rst = 0;
    start = 1;
    in_addr_offset_A = 32;
    in_addr_offset_B = 64;
    add_flag = 1;
    load_a = 1;
    load_b = 0;
    ram_raddr = 0;
    ram_rdata = {12'd225, 12'd224, 12'd97, 12'd96, 12'd161, 12'd160, 12'd33, 12'd32};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 0; 
    ram_rdata = {12'd209, 12'd208, 12'd81, 12'd80, 12'd145, 12'd144, 12'd17, 12'd16};
    #2
    start = 0;
    load_a = 1;
    load_b = 0;
    ram_raddr = 1; 
    ram_rdata = {12'd241, 12'd240, 12'd113, 12'd112, 12'd177, 12'd176, 12'd49, 12'd48};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 1; 
    ram_rdata = {12'd201, 12'd200, 12'd73, 12'd72, 12'd137, 12'd136, 12'd9, 12'd8};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 2; 
    ram_rdata = {12'd233, 12'd232, 12'd105, 12'd104, 12'd169, 12'd168, 12'd41, 12'd40};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 2; 
    ram_rdata = {12'd217, 12'd216, 12'd89, 12'd88, 12'd153, 12'd152, 12'd25, 12'd24};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 3; 
    ram_rdata = {12'd249, 12'd248, 12'd121, 12'd120, 12'd185, 12'd184, 12'd57, 12'd56};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 3; 
    ram_rdata = {12'd197, 12'd196, 12'd69, 12'd68, 12'd133, 12'd132, 12'd5, 12'd4};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 4; 
    ram_rdata = {12'd229, 12'd228, 12'd101, 12'd100, 12'd165, 12'd164, 12'd37, 12'd36};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 4; 
    ram_rdata = {12'd213, 12'd212, 12'd85, 12'd84, 12'd149, 12'd148, 12'd21, 12'd20};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 5; 
    ram_rdata = {12'd245, 12'd244, 12'd117, 12'd116, 12'd181, 12'd180, 12'd53, 12'd52};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 5; 
    ram_rdata = {12'd205, 12'd204, 12'd77, 12'd76, 12'd141, 12'd140, 12'd13, 12'd12};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 6; 
    ram_rdata = {12'd237, 12'd236, 12'd109, 12'd108, 12'd173, 12'd172, 12'd45, 12'd44};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 6; 
    ram_rdata = {12'd221, 12'd220, 12'd93, 12'd92, 12'd157, 12'd156, 12'd29, 12'd28};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 7; 
    ram_rdata = {12'd253, 12'd252, 12'd125, 12'd124, 12'd189, 12'd188, 12'd61, 12'd60};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 7; 
    ram_rdata = {12'd195, 12'd194, 12'd67, 12'd66, 12'd131, 12'd130, 12'd3, 12'd2};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 8; 
    ram_rdata = {12'd227, 12'd226, 12'd99, 12'd98, 12'd163, 12'd162, 12'd35, 12'd34};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 8; 
    ram_rdata = {12'd211, 12'd210, 12'd83, 12'd82, 12'd147, 12'd146, 12'd19, 12'd18};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 9; 
    ram_rdata = {12'd243, 12'd242, 12'd115, 12'd114, 12'd179, 12'd178, 12'd51, 12'd50};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 9; 
    ram_rdata = {12'd203, 12'd202, 12'd75, 12'd74, 12'd139, 12'd138, 12'd11, 12'd10};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 10; 
    ram_rdata = {12'd235, 12'd234, 12'd107, 12'd106, 12'd171, 12'd170, 12'd43, 12'd42};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 10; 
    ram_rdata = {12'd219, 12'd218, 12'd91, 12'd90, 12'd155, 12'd154, 12'd27, 12'd26};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 11; 
    ram_rdata = {12'd251, 12'd250, 12'd123, 12'd122, 12'd187, 12'd186, 12'd59, 12'd58};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 11; 
    ram_rdata = {12'd199, 12'd198, 12'd71, 12'd70, 12'd135, 12'd134, 12'd7, 12'd6};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 12; 
    ram_rdata = {12'd231, 12'd230, 12'd103, 12'd102, 12'd167, 12'd166, 12'd39, 12'd38};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 12; 
    ram_rdata = {12'd215, 12'd214, 12'd87, 12'd86, 12'd151, 12'd150, 12'd23, 12'd22};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 13; 
    ram_rdata = {12'd247, 12'd246, 12'd119, 12'd118, 12'd183, 12'd182, 12'd55, 12'd54};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 13; 
    ram_rdata = {12'd207, 12'd206, 12'd79, 12'd78, 12'd143, 12'd142, 12'd15, 12'd14};
    #2
    load_a = 1;
    load_b = 0;
    ram_raddr = 14; 
    ram_rdata = {12'd239, 12'd238, 12'd111, 12'd110, 12'd175, 12'd174, 12'd47, 12'd46};
    #2
    load_a = 0;
    load_b = 1;
    ram_raddr = 14; 
    ram_rdata = {12'd223, 12'd222, 12'd95, 12'd94, 12'd159, 12'd158, 12'd31, 12'd30};
    #20 $finish;
end
initial begin
    clk = 1;
    forever begin
        #1 clk = ~clk;
    end
end
endmodule