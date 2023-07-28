import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Sample data CNN-1
variables = ['128', '256', '512']
categories = ['5x5,5', '2x2 Pool', 'FC(720)', 'FC(70)', 'FC(10)']

#luts = [[110, 111, 114], [33, 34, 33], [2762, 299, 225], [306, 294, 289], [79, 92, 85]]
#regs = [[818, 980, 265], [33, 33, 244], [150, 116, 112], [778, 777, 777], [114, 116, 118]]

luts = [[110, 33, 2762, 306, 79], [111, 34, 299, 294, 92], [114, 33, 225, 289, 85]]
regs = [[818, 33, 150, 778, 114], [980, 33, 116, 777, 116], [982, 33, 112, 777, 118]]

### LUT COUNT
fig, ax = plt.subplots()
ax.set_xlabel('Layer')
ax.set_ylabel('LUT count')
ax.set_title('LUT count for different crossbar sizes in CNN-1')

bar_width = 0.2
x = np.arange(len(categories))

colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466'] 
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), luts[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig('plots/cnn_1_crossbar_luts.svg', format='svg')
plt.show()

### REGISTER COUNT
fig, ax = plt.subplots()
ax.set_xlabel('Layer')
ax.set_ylabel('Register count')
ax.set_title('Register count for different crossbar sizes in CNN-1')

bar_width = 0.2
x = np.arange(len(categories))

colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466'] 
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), regs[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig('plots/cnn_1_datatype_regs.svg', format='svg')
plt.show()

# Sample data CNN-2
variables = ['128', '256', '512']
categories = ['7x7,10', '2x2 Pool', 'FC(1210)', 'FC(1210)', 'FC(10)']

#luts = [[110, 111, 114], [33, 34, 33], [2762, 299, 225], [306, 294, 289], [79, 92, 85]]
#regs = [[818, 980, 265], [33, 33, 244], [150, 116, 112], [778, 777, 777], [114, 116, 118]]

luts = [[175, 65, 63764, 3982, 511], [111, 34, 299, 294, 92], [114, 33, 225, 289, 85]]
regs = [[1430, 63, 198, 1288, 1276], [1452, 63, 187, 1289, 1273], [1454, 63, 163, 1282, 1273]]

### LUT COUNT
fig, ax = plt.subplots()
ax.set_xlabel('Layer')
ax.set_ylabel('LUT count')
ax.set_title('LUT count for different crossbar sizes in CNN-2')

bar_width = 0.2
x = np.arange(len(categories))

colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466'] 
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), luts[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig('plots/cnn_2_crossbarluts.svg', format='svg')
plt.show()

### REGISTER COUNT
fig, ax = plt.subplots()
ax.set_xlabel('Layer')
ax.set_ylabel('Register count')
ax.set_title('Register count for different crossbar sizes in CNN-2')

bar_width = 0.2
x = np.arange(len(categories))

colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466'] 
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), regs[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig('plots/cnn_2_datatype_regs.svg', format='svg')
plt.show()