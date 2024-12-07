def reverse_bits(n):
    # Ensure n is treated as an 8-bit number by masking with 0xFF
    n = n & 0xFF
    
    # Initialize the reversed number
    reversed_num = 0
    
    # Iterate over each bit position
    for i in range(8):
        # Shift the reversed_num left by 1 to make space
        reversed_num <<= 1
        # Add the least significant bit of n to reversed_num
        reversed_num |= (n & 1)
        # Shift n right by 1 to process the next bit
        n >>= 1
    
    return reversed_num

# Testing the function
idx = 1
for i in range(0,128,4):
    reversed_num_1 = reverse_bits(i)
    reversed_num_3 = reverse_bits(i+1)
    reversed_num_5 = reverse_bits(i+2)
    reversed_num_7 = reverse_bits(i+3)
    reversed_num_2 = reverse_bits(i+128)
    reversed_num_4 = reverse_bits(i+129)
    reversed_num_6 = reverse_bits(i+130)
    reversed_num_8 = reverse_bits(i+131)
    #print(f"#{idx} ram_rdata = {{12'd{reversed_num_8}, 12'd{reversed_num_7}, 12'd{reversed_num_6}, 12'd{reversed_num_5}, 12'd{reversed_num_4}, 12'd{reversed_num_3}, 12'd{reversed_num_2}, 12'd{reversed_num_1}}}")
    #idx += 2
    #print(hex(reversed_num_8))
for i in range(0,256,2):
    reversed_num_1 = reverse_bits(i)
    reversed_num_3 = reverse_bits(i+1)
    print(f"{reversed_num_1}, {reversed_num_3}")
