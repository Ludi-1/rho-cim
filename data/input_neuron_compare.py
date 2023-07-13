import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# # Data inputs
# variables = ['1', '2', '3', '10', '20', '50', '100', '200']
# luts = [235, 385, 526, 1542, 2941, 7202, 13887, 33345]  # Values for each variable
# regs = [41, 43, 48, 81, 93, 259, 149, 319]
# power = [0.104, 0.105, 0.107, 0.112, 0.120, 0.148, 0.169, 0.232]

# # Data neurons
# variables = ['1', '2', '3', '10', '20', '50', '100', '200', '500']
# luts = [235, 255, 249, 358, 454, 620, 1036, 1763, 4014]  # Values for each variable
# regs = [41, 43, 45, 49, 51, 58, 66, 64, 66]
# power = [0.104, 0.104, 0.104, 0.104, 0.105, 0.105, 0.106, 0.110, 0.114]

variables = ['1', '2', '3', '10', '20', '50', '100', '200']
categories = ['Inputs', 'Neurons']
luts = [[235, 235], [385, 255], [526, 249], [1542, 358], [2941, 454], [7202, 620], [13887, 1036], [33345, 1763]]

### LUTS
fig, ax = plt.subplots(figsize=(9, 8.5))
ax.set_xlabel('Tile count')
ax.set_ylabel('LUT count')
ax.set_title('LUT count for different datatype sizes')

bar_width = 0.2
x = np.arange(len(categories))
colors = ['#f6b65f', '#0f83a2']  # Set your desired colors here

for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), luts[i], width=bar_width, label=var, color=colors[i])

ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()

plt.savefig('plots/input_vs_neurons_luts.svg', format='svg')
plt.show()