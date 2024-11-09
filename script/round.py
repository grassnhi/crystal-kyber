# Python script to generate Verilog code for the Keccak θ step
# Output to "theta_step.v"

filename = "kcck_round.v"

def generate_theta_step():
    lines = []
    lines.append("module kcck_round(\n")
    lines.append("    input [1599:0] S_in,        // Input: 5x5 state matrix (1600 bits)\n")
    lines.append("    input wire [4:0] round_index,          // Input: round index (0-23)\n")
    lines.append("    output [1599:0] S_out     // Output: modified 5x5 state matrix\n")
    lines.append(");\n\n")
    # Define C and D as 2D wire arrays
    lines.append("    // Intermediate arrays\n")
    lines.append("   wire [63:0] C          [4:0];\n")
    lines.append("   wire [63:0] D          [4:0];\n")
    lines.append("   wire [63:0] A          [4:0][4:0];\n")
    lines.append("   wire [63:0] A_theta    [4:0][4:0];\n")
    lines.append("   wire [63:0] A_rho      [4:0][4:0];\n")
    lines.append("   wire [63:0] A_pi       [4:0][4:0];\n")
    lines.append("   wire [63:0] A_chi      [4:0][4:0];\n")
    lines.append("   reg  [63:0] A_iota     [4:0][4:0];\n\n")
    
    lines.append("    // Flatten S_in into 3D array\n")
    for z in range(64):
        for y in range(5):
            for x in range(5):
                index = 64 * (5 * y + x) + z
                line = f"   assign A[{x}][{y}][{z}]    = S_in[{index}];\n"
                lines.append(line)
    
################################ THETA ################################
    lines.append("//--------------------------- THETA ---------------------------\n")
    # Generate C[x][z] = A[x][0][z] ^ A[x][1][z] ^ A[x][2][z] ^ A[x][3][z] ^ A[x][4][z]
    lines.append("    // Step 1: Compute C[x][z]\n")
    for x in range(5):
        for z in range(64):
            line = f"    assign C[{x}][{z}]     = A[{x}][0][{z}] ^ A[{x}][1][{z}] ^ A[{x}][2][{z}] ^ A[{x}][3][{z}] ^ A[{x}][4][{z}];\n"
            lines.append(line)

    # Generate D[x][z] = C[(x - 1) % 5][z] ^ C[(x + 1) % 5][(z - 1) % 64]
    lines.append("\n    // Step 2: Compute D[x][z]\n")
    for x in range(5):
        for z in range(64):
            prev_x = (x - 1) % 5
            next_x = (x + 1) % 5
            prev_z = (z - 1) % 64 if (z - 1) >= 0 else 63  # Wrap-around for negative indices
            line = f"    assign D[{x}][{z}]     = C[{prev_x}][{z}] ^ C[{next_x}][{prev_z}];\n"
            lines.append(line)

    # Generate A'[x][y][z] = A[x][y][z] ^ D[x][z]
    lines.append("\n    // Step 3: Compute A_theta[x][y][z] = A[x][y][z] ^ D[x][z]\n")
    for x in range(5):
        for y in range(5):
            for z in range(64):
                line = f"    assign A_theta[{x}][{y}][{z}]  = A[{x}][{y}][{z}] ^ D[{x}][{z}];\n"
                lines.append(line)

################################ RHO ################################
    lines.append("//--------------------------- RHO ---------------------------\n")
    # Step 1: Copy A[0][0][z] directly to A'[0][0][z]
    lines.append("    // Step 1: Copy A[0][0][z] to A_rho[0][0][z]\n")
    for z in range(64):
        line = f"    assign A_rho[0][0][{z}]    = A[0][0][{z}];\n"
        lines.append(line)

    # Step 2: Perform transformations for the other lanes based on the (x, y) positions
    x, y = 1, 0
    lines.append("\n    // Step 2: Transformations for other lanes\n")
    for t in range(24):
        shift_amount = ((t + 1) * (t + 2)) // 2
        for z in range(64):
            z_shifted = (z - shift_amount) % 64
            line = f"    assign A_rho[{x}][{y}][{z}]    = A[{x}][{y}][{z_shifted}];\n"
            lines.append(line)
        
        # Update (x, y) as per (x, y) = (y, (2 * x + 3 * y) % 5)
        x, y = y, (2 * x + 3 * y) % 5

################################ PI ################################
    # Generate the assignments for the pi transformation
    lines.append("//--------------------------- PI ---------------------------\n")
    for x in range(5):
        for y in range(5):
            for z in range(64):
                new_x = (x + 3 * y) % 5
                line = f"   assign A_pi[{x}][{y}][{z}]  = A_rho[{new_x}][{x}][{z}];\n"
                lines.append(line)    

################################ CHI ################################
    # Generate the assignments for the chi transformation
    lines.append("//--------------------------- CHI ---------------------------\n")
    for x in range(5):
        for y in range(5):
            for z in range(64):
                x1 = (x + 1) % 5
                x2 = (x + 2) % 5
                # Apply the chi transformation as per the provided formula
                line = f"   assign A_chi[{x}][{y}][{z}]     = A[{x}][{y}][{z}] ^ ((~A[{x1}][{y}][{z}]) & A[{x2}][{y}][{z}]);\n"
                # line = f"   assign A_chi[{x}][{y}][{z}]     = A[{x}][{y}][{z}] ^ ((A[{x1}][{y}][{z}] ^ 1'b1) & A[{x2}][{y}][{z}]);\n"
                lines.append(line)

################################ IOTA ################################
    lines.append("//--------------------------- IOTA ---------------------------\n")
    # Define round constants
    lines.append("\n    // Define round constants\n")
    lines.append("    reg [63:0] RC;\n")
    
    lines.append("    always @(*) begin\n")
    lines.append("        case (round_index)\n")
    rc_values = [
        "64'h0000000000000001", "64'h0000000000008082", "64'h800000000000808A", "64'h8000000080008000",
        "64'h000000000000808B", "64'h0000000080000001", "64'h8000000080008081", "64'h8000000000008009",
        "64'h000000000000008A", "64'h0000000000000088", "64'h0000000080008009", "64'h000000008000000A",
        "64'h000000008000808B", "64'h800000000000008B", "64'h8000000000008089", "64'h8000000000008003",
        "64'h8000000000008002", "64'h8000000000000080", "64'h000000000000800A", "64'h800000008000000A",
        "64'h8000000080008081", "64'h8000000000008080", "64'h0000000080000001", "64'h8000000080008008"
    ]
    for i, rc in enumerate(rc_values):
        lines.append(f"            5'd{i}: RC   = {rc};\n")
    lines.append("            default: RC = 64'h0;\n")
    lines.append("        endcase\n")
    lines.append("    end\n\n")

    # Apply Iota step with XOR on A_iota[0][0] and round constant RC
    lines.append("    // Apply Iota step\n")
    lines.append("    always @(*) begin\n")
    for y in range(5):
        for x in range(5):
            lines.append(f"        A_iota[{x}][{y}] = A[{x}][{y}];\n")
    lines.append("        A_iota[0][0]  = A[0][0] ^ RC;  // XOR RC with A[0][0]\n")
    lines.append("    end\n\n")

    lines.append("    // Deflatten 3D array into S_out\n")
    for z in range(64):
        for y in range(5):
            for x in range(5):
                index = 64 * (5 * y + x) + z
                line = f"    assign S_out[{index}]  = A_iota[{x}][{y}][{z}];\n"
                lines.append(line)

    lines.append("endmodule\n")
    return lines

# Write the Verilog code to the file with UTF-8 encoding
with open(filename, "w", encoding="utf-8") as file:
    file.writelines(generate_theta_step())

print(f"Verilog code for round has been generated in '{filename}'")
