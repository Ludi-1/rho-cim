import numpy as np
import matplotlib.pyplot as plt

# Sample data
variables = ['int2', 'int4', 'int8', 'int16']
categories = ['MLP-S', 'MLP-M', 'MLP-L']
luts = [[376, 582, 792], [474, 684, 792], [622, 951, 1364], [1173, 1724, 2850]]
regs = [[139, 194, 205], [139, 193, 205], [139, 196, 217], [156, 217, 244]]
power = [[0.106, 0.108, 0.110], [0.107, 0.109, 0.111], [0.108, 0.111, 0.113], [0.112, 0.116, 0.121]]

### LUTS
fig, ax = plt.subplots(figsize=(9, 8.5))
ax.set_xlabel('Network model')
ax.set_ylabel('LUT count')
ax.set_title('LUT count for different datatype sizes')

bar_width = 0.2
x = np.arange(len(categories))
colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466']  # Set your desired colors here

for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), luts[i], width=bar_width, label=var, color=colors[i])

ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()

plt.savefig('plots/datatype_luts.svg', format='svg')
plt.show()

### REGS
fig, ax = plt.subplots(figsize=(9, 8.5))
ax.set_xlabel('Network model')
ax.set_ylabel('Register count')
ax.set_title('Register count for different datatype sizes')

bar_width = 0.2
x = np.arange(len(categories))
colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466']  # Set your desired colors here

for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), regs[i], width=bar_width, label=var, color=colors[i])

ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()

plt.savefig('plots/datatype_regs.svg', format='svg')
plt.show()

### POWER
fig, ax = plt.subplots(figsize=(9, 8.5))
ax.set_xlabel('Network model')
ax.set_ylabel('Register count')
ax.set_title('Power for different datatype sizes')

bar_width = 0.2
x = np.arange(len(categories))
colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466']  # Set your desired colors here

for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), power[i], width=bar_width, label=var, color=colors[i])

ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()

plt.savefig('plots/datatype_pow.svg', format='svg')
plt.show()