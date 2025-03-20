import math
for i in range(0,64):
   factor = math.pow(17, 2*i+1) % 3329
   if(factor == 3276):
    print(f"data[{i}] <= 12'{hex(int(factor))};")