`timescale 1ns / 1ps

module sha3_tb;

// --- Clock generation ---
reg clk;
always begin
    #5 clk = ~clk;  // Toggle clock every 5ns
end

// --- KECCAK_p Testbench ---    
reg [1599:0] S_in;
reg [4:0] nr;              // Number of rounds (5 bits)
reg load;            // Control signal for stage transition (load)
reg rst_KECCAK;                   // Reset signal
wire [1599:0] S_out;
reg [10:0] cnt;

KECCAK_p keccak (
        .S(S_in),
        .nr(nr),
        .load(load),
        .clk(clk),
        .rst(rst_KECCAK),
        .S_out(S_out)
);

// --- A_generator Testbench ---
reg [0:271] M_A;
reg [7:0] ram_w_start_offset_A;
reg rst_A, active_A;
wire enw_A;
wire [7:0] waddr_A;
wire [95:0] dout_A;

A_generator uut_A (
    .M(M_A),
    .ram_w_start_offset(ram_w_start_offset_A),
    .clk(clk),
    .rst(rst_A),
    .active(active_A),
    .enw(enw_A),
    .waddr(waddr_A),
    .dout(dout_A)
);

// --- SHA3_512 Testbench ---
reg [0:255] M_SHA3;
reg active_SHA3, rst_SHA3;
wire [0:511] Z_SHA3;

SHA3_512 uut_SHA3 (
    .M(M_SHA3),
    .active(active_SHA3),
    .clk(clk),
    .rst(rst_SHA3),
    .Z(Z_SHA3)
);

// --- SHAKE_128 Testbench ---
reg [0:271] M_SHAKE_128;
reg active_SHAKE_128, rst_SHAKE_128;
wire finish_SHAKE_128;
wire [0:3071] Z_SHAKE_128;

SHAKE_128 uut_SHAKE_128 (
    .M(M_SHAKE_128),
    .active(active_SHAKE_128),
    .clk(clk),
    .rst(rst_SHAKE_128),
    .finish(finish_SHAKE_128),
    .Z(Z_SHAKE_128)
);

// --- SHAKE_256 Testbench ---
reg [0:263] M_SHAKE_256;
reg active_SHAKE_256, rst_SHAKE_256;
reg [1:0] n_num_SHAKE_256;
wire finish_SHAKE_256;
wire [0:1535] Z_SHAKE_256;

SHAKE_256 uut_SHAKE_256 (
    .M(M_SHAKE_256),
    .n_num(n_num_SHAKE_256),
    .active(active_SHAKE_256),
    .clk(clk),
    .rst(rst_SHAKE_256),
    .finish(finish_SHAKE_256),
    .Z(Z_SHAKE_256)
);

// --- small_poly_generator Testbench ---
reg [0:264-1] M_poly; //256+8 (s||b)
reg [7:0] ram_w_start_offset_poly;
reg [1:0] n_num_poly; //1 => n1; 2 => n2
reg rst_poly, active_poly;
wire enw_poly;
wire [7:0] waddr_poly;
wire [95:0] dout_poly;

small_poly_generator uut_poly (
    .M(M_poly),
    .ram_w_start_offset(ram_w_start_offset_poly),
    .n_num(n_num_poly),
    .clk(clk),
    .rst(rst_poly),
    .active(active_poly),
    .enw(enw_poly),
    .waddr(waddr_poly),
    .dout(dout_poly)
);

// --- Testbench Stimulus ---
initial begin
    // Initialize clocks
    clk = 0;
    // cnt = 11'd1;
    // // --- Test Case 0: KECCAK_p ---
    //  rst_KECCAK = 0;
    //  S_in = 1600'd0; // Initialize state S to zero (can be changed to other test vectors)
    //  nr = 5'd24;  // 24 rounds for Keccak
    //  load = 1'b0;  // Initially, load is 0

    //  // Apply reset
    //  rst_KECCAK = 1; 
    //  #10;
    //  rst_KECCAK = 0;  // Release reset

    //  // Test case 1: Simple state transition with no load
    //  $display("Test case 1: No load transition");
    //  // Wait for some cycles to observe state changes
    //  #500;

    //  // Test case 2: Apply load to move to state s1
    //  $display("Test case 2: Transition to s1 with load = %b", load);
    //  cnt = cnt + 1'd1;
    //  load = 1'b1;  // Move to s1 state
    //  #500;
    
    //  // Test case 3: Cycle through the states by changing 'nr' rounds
    //  $display("Test case 3: Transition through states with nr = %d", nr);
    //  cnt = cnt + 1'd1;
    //  nr = 5'd10; // Set rounds to 10 for faster iteration
    //  load = 1'b1;  // Apply load again
    //  #500;
     
    //  // Test case 4: Full run with all rounds (nr = 24) and monitor S_out
    //  $display("Test case 4: Full run with nr = %d and input state S = %h", nr, S_in);
    //  cnt = cnt + 1'd1;
    //  nr = 5'd24;
    //  load = 1'b0;  // Reset load
    //  S_in = 1600'd1234567890123456789012345678901234567890; // Example input state
    //  #500;
     
    //  // Test case 5: Reset and test again with different input state
    //  $display("Test case 5: Test with a new input state S = %h", S_in);
    //  cnt = cnt + 1'd1;
    //  rst_KECCAK = 1;
    //  load = 1'b1;  // Apply load again 
    //  #10;
    //  load = 1'b0;  // Reset load again
    //  rst_KECCAK = 0;
    //  S_in = 1600'd9876543210987654321098765432109876543210; // Another test input state
    //  #500;
    
    // --- Test Case 1: A_generator ---
//    rst_A = 0;
//    active_A = 0;
//    M_A = 272'h0;
//    #10 rst_A = 1;
//    #10 rst_A = 0;
//    // Test with normal message
//    M_A = 272'h1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
//    active_A = 1;
//    #100 active_A = 0;

    // --- Test Case 2: SHA3_512 ---
//    rst_SHA3 = 0;
//    active_SHA3 = 0;
//    M_SHA3 = 256'h0;
//    #10 rst_SHA3 = 1;
//    rst_SHA3 = 1;
//    #10 rst_SHA3 = 0;
//    M_SHA3 = 256'habcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
//    active_SHA3 = 1;
//    #500 active_SHA3 = 0;
//    --------------------------------------
  active_SHA3 = 0;
  rst_SHA3 = 1;
  #10 rst_SHA3 = 0;
  M_SHA3 = 5'b11001;
  active_SHA3 = 1;
  #500 active_SHA3 = 0;
    

//    // --- Test Case 3: SHAKE_128 ---
//    rst_SHAKE_128 = 0;
//    active_SHAKE_128 = 0;
//    M_SHAKE_128 = 272'h0;
//    #10 rst_SHAKE_128 = 1;
//    #10 rst_SHAKE_128 = 0;
//    M_SHAKE_128 = 272'habcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
//    active_SHAKE_128 = 1;
//    #20 active_SHAKE_128 = 0;
//    --------------------------------------
//    active_SHAKE_128 = 0;
//    rst_SHAKE_128 = 1;
//    #10 rst_SHAKE_128 = 0;
//    M_SHAKE_128 = 272'habcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
//    active_SHAKE_128 = 1;
//    #500 active_SHAKE_128 = 0;
//    // --- Test Case 4: SHAKE_256 ---
//    rst_SHAKE_256 = 0;
//    active_SHAKE_256 = 0;
//    M_SHAKE_256 = 512'h0;
//    #10 rst_SHAKE_256 = 1;
//    #10 rst_SHAKE_256 = 0;
//    M_SHAKE_256 = 512'habcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
//    active_SHAKE_256 = 1;
//    #20 active_SHAKE_256 = 0;
//    --------------------------------------
    // active_SHAKE_256 = 0;
    // rst_SHAKE_256 = 1;
    // #10 rst_SHAKE_256 = 0;
    // M_SHAKE_256 = 264'habcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
    // n_num_SHAKE_256 = 2'd1;
    // active_SHAKE_256 = 1;
//    #500 active_SHAKE_256 = 0;
//    // --- Test Case 5: small_poly_generator ---
//    rst_poly = 0;
//    active_poly = 0;
//    M_poly = 272'h0;
//    #10 rst_poly = 1;
//    #10 rst_poly = 0;
//    M_poly = 272'habcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
//    active_poly = 1;
//    #20 active_poly = 0;

//    // --- Edge Cases ---
//    // Test all-zero inputs for each module
//    // A_generator with zero message
//    M_A = 272'h0;
//    active_A = 1;
//    #20 active_A = 0;

//    // SHA3_512 with all-zero message
//    M_SHA3 = 256'h0;
//    active_SHA3 = 1;
//    #20 active_SHA3 = 0;

//    // SHAKE_128 with all-zero message
//    M_SHAKE_128 = 272'h0;
//    active_SHAKE_128 = 1;
//    #20 active_SHAKE_128 = 0;

//    // SHAKE_256 with all-zero message
//    M_SHAKE_256 = 512'h0;
//    active_SHAKE_256 = 1;
//    #20 active_SHAKE_256 = 0;

//    // small_poly_generator with zero message
//    M_poly = 272'h0;
//    active_poly = 1;
//    #20 active_poly = 0;

    // End the simulation
    #200 $finish;
end

// --- Monitoring ---
initial begin
    // Monitor outputs
//    $monitor("Time = %0t, S_in = %h, load = %b, S_out = %h", $time, S_in, load, S_out);
//    $monitor("Time = %0t, M_A = %h, dout_A = %h, enw_A = %b", $time, M_A, dout_A, enw_A);
    $monitor("Time = %0t, M_SHA3 = %h, Z_SHA3 = %h", $time, M_SHA3, Z_SHA3);
//    $monitor("Time = %0t, M_SHAKE_128 = %h, Z_SHAKE_128 = %h, finish_SHAKE_128 = %b", $time, M_SHAKE_128, Z_SHAKE_128, finish_SHAKE_128);
//    $monitor("Time = %0t, M_SHAKE_256 = %h, Z_SHAKE_256 = %h, finish_SHAKE_256 = %b", $time, M_SHAKE_256, Z_SHAKE_256, finish_SHAKE_256);
//    $monitor("Time = %0t, M_poly = %h, dout_poly = %h", $time, M_poly, dout_poly);
end

endmodule