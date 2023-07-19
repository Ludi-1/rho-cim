import numpy as np
import matplotlib.pyplot as plt

categories = ['1', '2', '3', '10', '20', '50', '100', '200']
variables = ['Inputs', 'Neurons']

luts = [[235, 385, 526, 1542, 2941, 7202, 13887, 33345], [235, 255, 249, 358, 454, 620, 1036, 1763]]
regs = [[41, 43, 48, 81, 93, 259, 149, 319], [41, 43, 45, 49, 51, 58, 66, 64]]
power = [[0.104, 0.105, 0.107, 0.112, 0.120, 0.148, 0.169, 0.232], [0.104, 0.104, 0.104, 0.104, 0.105, 0.105, 0.106, 0.110]]

### LUTS
fig, ax = plt.subplots(figsize=(4.5, 4.25))
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

### REGS
fig, ax = plt.subplots(figsize=(4.5, 4.25))
ax.set_xlabel('Tile count')
ax.set_ylabel('Register count')
ax.set_title('Register count for different datatype sizes')

bar_width = 0.2
x = np.arange(len(categories))
colors = ['#f6b65f', '#0f83a2']  # Set your desired colors here

for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), regs[i], width=bar_width, label=var, color=colors[i])

ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()

plt.savefig('plots/input_vs_neurons_regs.svg', format='svg')
plt.show()

### POWER
fig, ax = plt.subplots(figsize=(4.5, 4.25))
ax.set_xlabel('Tile count')
ax.set_ylabel('Power')
ax.set_title('Power for different datatype sizes')

bar_width = 0.2
x = np.arange(len(categories))
colors = ['#f6b65f', '#0f83a2']  # Set your desired colors here

for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), power[i], width=bar_width, label=var, color=colors[i])

ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()

plt.savefig('plots/input_vs_neurons_power.svg', format='svg')
plt.show()