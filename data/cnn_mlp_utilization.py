"""
Script for generating graphs
of CNN & MLP HDL synthesis results
for crossbar size of 256
and datatype size of 8 bits
"""
import numpy as np
import matplotlib.pyplot as plt

categories = ["MLP-S", "MLP-M", "MLP-L", "CNN-1", "CNN-2"]
luts = [1091, 1943, 3089, 838, 3807]
regs = [150, 210, 244, 2022, 4264]
mux7 = [211, 436, 693, 129, 520]
mux8 = [98, 3, 301, 49, 189]

plt.bar(categories, luts, width=0.6, color="royalblue")
plt.xlabel('Neural network', fontsize=12)
plt.ylabel('LUTs', fontsize=14)
plt.title('LUT utilization for different neural networks')
plt.xticks(fontsize=12)
plt.yticks(fontsize=14)
plt.savefig("plots/cnn_mlp_utilization_luts.svg", format="svg")
# Display the plot
plt.close()

plt.bar(categories, regs, width=0.6, color="darkred")
plt.xlabel('Neural network', fontsize=12)
plt.ylabel('Registers', fontsize=14)
plt.title('Register utilization for different neural networks')
plt.xticks(fontsize=12)
plt.yticks(fontsize=14)
plt.savefig("plots/cnn_mlp_utilization_regs.svg", format="svg")
# Display the plot
plt.close()

plt.bar(categories, mux7, width=0.6, color="teal")
plt.xlabel('Neural network', fontsize=12)
plt.ylabel('F7 Muxes', fontsize=14)
plt.title('F7 Mux utilization for different neural networks')
plt.xticks(fontsize=12)
plt.yticks(fontsize=14)
plt.savefig("plots/cnn_mlp_utilization_mux7.svg", format="svg")
# Display the plot
plt.close()

plt.bar(categories, mux8, width=0.6, color="skyblue")
plt.xlabel('Neural network', fontsize=12)
plt.ylabel('F8 Muxes', fontsize=14)
plt.title('F8 Mux utilization for different neural networks')
plt.xticks(fontsize=12)
plt.yticks(fontsize=14)
plt.savefig("plots/cnn_mlp_utilization_mux8.svg", format="svg")
# Display the plot
plt.close()