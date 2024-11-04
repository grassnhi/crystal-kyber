filename = "iota_module.v"

def generate_iota_module():
    lines = []
    lines.append("module iota_step(\n")
    lines.append("    input [1599:0] S_in,        // Input: 5x5 state matrix (1600 bits)\n")
    lines.append("    input wire [4:0] round_index,          // Input: round index (0-23)\n")
    lines.append("    output [1599:0] S_out     // Output: modified 5x5 state matrix\n")
    lines.append(");\n\n")

    lines.append("   wire [63:0] A      [4:0][4:0];\n")
    lines.append("   reg  [63:0] A_out  [4:0][4:0];\n\n")

    # Mapping S_in to A[x][y][z]
    for y in range(5):
        for x in range(5):
            for z in range(64):
                index = 64 * (5 * y + x) + z
                line = f"   assign A[{x}][{y}][{z}] = S_in[{index}];\n"
                lines.append(line)

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
        lines.append(f"            5'd{i}: RC = {rc};\n")
    lines.append("            default: RC = 64'h0;\n")
    lines.append("        endcase\n")
    lines.append("    end\n\n")

    # Apply Iota step with XOR on A_out[0][0] and round constant RC
    lines.append("    // Apply Iota step\n")
    lines.append("    always @(*) begin\n")
    for y in range(5):
        for x in range(5):
            lines.append(f"        A_out[{x}][{y}] = A[{x}][{y}];\n")
    lines.append("        A_out[0][0] = A[0][0] ^ RC;  // XOR RC with A[0][0]\n")
    lines.append("    end\n\n")

    # Mapping A_out[x][y][z] to S_out
    for y in range(5):
        for x in range(5):
            for z in range(64):
                index = 64 * (5 * y + x) + z
                line = f"    assign S_out[{index}] = A_out[{x}][{y}][{z}];\n"
                lines.append(line)
                
    lines.append("endmodule\n")

    return lines

# Generate the iota module and write to a file
try:
    with open(filename, "w") as file:
        file.writelines(generate_iota_module())
    print(f"Verilog code for the iota module has been successfully generated in '{filename}'")
except IOError as e:
    print(f"An error occurred while writing the file: {e}")
