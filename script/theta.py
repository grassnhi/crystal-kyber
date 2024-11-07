# Python script to generate Verilog code for the Keccak θ step
# Output to "theta_step.v"

filename = "theta_step.v"

def generate_theta_step():
    lines = []
    lines.append("module theta_step(input [1599:0] S_in, output [1599:0] S_out);\n")
    # Define C and D as 2D wire arrays
    lines.append("    // Intermediate arrays for θ step\n")
    lines.append("   wire [63:0] C      [4:0];\n")
    lines.append("   wire [63:0] D      [4:0];\n")
    lines.append("   wire [63:0] A      [4:0][4:0];\n")
    lines.append("   wire [63:0] A_out  [4:0][4:0];\n\n")
    
    for z in range(64):
        for y in range(5):
            for x in range(5):
                index = 64 * (5 * y + x) + z
                line = f"   assign A[{x}][{y}][{z}]    = S_in[{index}];\n"
                lines.append(line)
    

    # Generate C[x][z] = A[x][0][z] ^ A[x][1][z] ^ A[x][2][z] ^ A[x][3][z] ^ A[x][4][z]
    lines.append("    // Step 1: Compute C[x][z]\n")
    for x in range(5):
        for z in range(64):
            line = f"    assign C[{x}][{z}] = A[{x}][0][{z}] ^ A[{x}][1][{z}] ^ A[{x}][2][{z}] ^ A[{x}][3][{z}] ^ A[{x}][4][{z}];\n"
            lines.append(line)

    # Generate D[x][z] = C[(x - 1) % 5][z] ^ C[(x + 1) % 5][(z - 1) % 64]
    lines.append("\n    // Step 2: Compute D[x][z]\n")
    for x in range(5):
        for z in range(64):
            prev_x = (x - 1) % 5
            next_x = (x + 1) % 5
            prev_z = (z - 1) % 64 if (z - 1) >= 0 else 63  # Wrap-around for negative indices
            line = f"    assign D[{x}][{z}] = C[{prev_x}][{z}] ^ C[{next_x}][{prev_z}];\n"
            lines.append(line)

    # Generate A'[x][y][z] = A[x][y][z] ^ D[x][z]
    lines.append("\n    // Step 3: Compute A_out[x][y][z] = A[x][y][z] ^ D[x][z]\n")
    for x in range(5):
        for y in range(5):
            for z in range(64):
                line = f"    assign A_out[{x}][{y}][{z}] = A[{x}][{y}][{z}] ^ D[{x}][{z}];\n"
                lines.append(line)

    lines.append("\n")
    for z in range(64):
        for y in range(5):
            for x in range(5):
                index = 64 * (5 * y + x) + z
                line = f"    assign S_out[{index}]  = A_out[{x}][{y}][{z}];\n"
                lines.append(line)

    lines.append("endmodule\n")
    return lines

# Write the Verilog code to the file with UTF-8 encoding
with open(filename, "w", encoding="utf-8") as file:
    file.writelines(generate_theta_step())

print(f"Verilog code for θ step has been generated in '{filename}'")
