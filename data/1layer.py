# Script for graphs of all 1 layer synthesis results

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Data inputs
variables = ['1', '2', '3', '10', '20', '50', '100', '200']
luts = [235, 385, 526, 1542, 2941, 7202, 13887, 33345]  # Values for each variable
regs = [41, 43, 48, 81, 93, 259, 149, 319]
power = [0.104, 0.105, 0.107, 0.112, 0.120, 0.148, 0.169, 0.232]

### LUTS
fig, ax = plt.subplots()
ax.set_xlabel('Tiles')
ax.set_ylabel('LUT count')
ax.set_title('LUT count for 1 layer, different amount of tiles')

plt.bar(variables, luts, color =(0.2, 0.4, 0.6, 0.6),
        width = 0.4)
plt.savefig('plots/1layer_input_luts.svg', format='svg')
plt.show()

### REGS
fig, ax = plt.subplots()
ax.set_xlabel('Tiles')
ax.set_ylabel('Register count')
ax.set_title('Register count for 1 layer, different amount of tiles')

plt.bar(variables, regs, color =(0.2, 0.4, 0.6, 0.6),
        width = 0.4)
plt.savefig('plots/1layer_input_regs.svg', format='svg')
plt.show()

### POWER
fig, ax = plt.subplots()
ax.set_xlabel('Tiles')
ax.set_ylabel('Power (W)')
ax.set_title('Power for 1 layer, different amount of tiles')

plt.bar(variables, power, color =(0.2, 0.4, 0.6, 0.6),
        width = 0.4)
plt.savefig('plots/1layer_input_pow.svg', format='svg')
plt.show()

# Data neurons
variables = ['1', '2', '3', '10', '20', '50', '100', '200', '500']
luts = [235, 255, 249, 358, 454, 620, 1036, 1763, 4014]  # Values for each variable
regs = [41, 43, 45, 49, 51, 58, 66, 64, 66]
power = [0.104, 0.104, 0.104, 0.104, 0.105, 0.105, 0.106, 0.110, 0.114]

### LUTS
fig, ax = plt.subplots()
ax.set_xlabel('Tiles')
ax.set_ylabel('LUT count')
ax.set_title('LUT count for 1 layer, different amount of tiles')

plt.bar(variables, luts, color =(0.2, 0.4, 0.6, 0.6),
        width = 0.4)
plt.savefig('plots/1layer_neuron_luts.svg', format='svg')
plt.show()

### REGS
fig, ax = plt.subplots()
ax.set_xlabel('Tiles')
ax.set_ylabel('Register count')
ax.set_title('Register count for 1 layer, different amount of tiles')

plt.bar(variables, regs, color =(0.2, 0.4, 0.6, 0.6),
        width = 0.4)
plt.savefig('plots/1layer_neuron_regs.svg', format='svg')
plt.show()

### POWER
fig, ax = plt.subplots()
ax.set_xlabel('Tiles')
ax.set_ylabel('Power (W)')
ax.set_title('Power for 1 layer, different amount of tiles')

plt.bar(variables, power, color =(0.2, 0.4, 0.6, 0.6),
        width = 0.4)
plt.savefig('plots/1layer_neuron_pow.svg', format='svg')
plt.show()