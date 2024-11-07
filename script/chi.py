filename = "chi_module.v"

def generate_chi_module(w):
    lines = []
    lines.append(f"module chi(input [1599:0] S_in, output [1599:0] S_out);\n")
    lines.append("   wire [63:0] A      [4:0][4:0];\n")
    lines.append("   wire [63:0] A_out  [4:0][4:0];\n\n")

    for z in range(64):
        for y in range(5):
            for x in range(5):
                index = 64 * (5 * y + x) + z
                line = f"   assign A[{x}][{y}][{z}]    = S_in[{index}];\n"
                lines.append(line)

    # Generate the assignments for the chi transformation
    for x in range(5):
        for y in range(5):
            for z in range(w):
                x1 = (x + 1) % 5
                x2 = (x + 2) % 5
                # Apply the chi transformation as per the provided formula
                line = f"   assign A_out[{x}][{y}][{z}] = A[{x}][{y}][{z}] ^ ((A[{x1}][{y}][{z}] ^ 1'b1) & A[{x2}][{y}][{z}]);\n"
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

# Specify the width (w) of the z dimension, e.g., w = 64
w = 64

try:
    with open(filename, "w") as file:
        file.writelines(generate_chi_module(w))
    print(f"Verilog code for the chi module has been successfully generated in '{filename}'")
except IOError as e:
    print(f"An error occurred while writing the file: {e}")
