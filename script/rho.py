# Python script to generate Verilog code for the Keccak ρ (Rho) step
# Output to "rho_step.v"

filename = "rho_step.v"

def generate_rho_step():
    lines = []
    lines.append("module rho_step(input [1599:0] S_in, output [1599:0] S_out);\n")
    lines.append("   wire [63:0] A      [4:0][4:0];\n")
    lines.append("   wire [63:0] A_out  [4:0][4:0];\n")
    lines.append("   wire [63:0] A_prime  [4:0][4:0];\n\n")
    w = 64  # Lane width in Keccak-1600

    for z in range(64):
        for y in range(5):
            for x in range(5):
                index = 64 * (5 * y + x) + z
                line = f"   assign A[{x}][{y}][{z}]    = S_in[{index}];\n"
                lines.append(line)

    # Step 1: Copy A[0][0][z] directly to A'[0][0][z]
    lines.append("    // Step 1: Copy A[0][0][z] to A_out[0][0][z]\n")
    for z in range(w):
        line = f"    assign A_out[0][0][{z}] = A[0][0][{z}];\n"
        lines.append(line)

    # Step 2: Perform transformations for the other lanes based on the (x, y) positions
    x, y = 1, 0
    lines.append("\n    // Step 2: Transformations for other lanes\n")
    for t in range(24):
        shift_amount = ((t + 1) * (t + 2)) // 2
        for z in range(64):
            z_shifted = (z - shift_amount) % 64
            line = f"    assign A_out[{x}][{y}][{z}] = A[{x}][{y}][{z_shifted}];\n"
            lines.append(line)
        
        # Update (x, y) as per (x, y) = (y, (2 * x + 3 * y) % 5)
        x, y = y, (2 * x + 3 * y) % 5

    # Generate the assignments for the pi transformation
    for x in range(5):
        for y in range(5):
            for z in range(w):
                new_x = (x + 3 * y) % 5
                line = f"   assign A_prime[{x}][{y}][{z}] = A_out[{new_x}][{x}][{z}];\n"
                lines.append(line)

    lines.append("\n")
    for z in range(64):
        for y in range(5):
            for x in range(5):
                index = 64 * (5 * y + x) + z
                line = f"    assign S_out[{index}]  = A_prime[{x}][{y}][{z}];\n"
                lines.append(line)

    lines.append("endmodule\n")
    return lines

# Write the Verilog code to the file with UTF-8 encoding
with open(filename, "w", encoding="utf-8") as file:
    file.writelines(generate_rho_step())

print(f"Verilog code for ρ (Rho) step has been generated in '{filename}'")
