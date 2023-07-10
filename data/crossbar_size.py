import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Sample data
variables = ['128', '256', '512']
categories = ['MLP-S', 'MLP-M', 'MLP-L']
luts = [[10496, 27768, 43706], [1091, 1943, 3089], [622, 951, 1364]]
regs = [[139, 214, 265], [150, 210, 244], [139, 196, 217]]
pow = [[0.144, 0.203, 0.248], [0.110, 0.115, 0.121], [0.108, 0.111, 0.113]]

### LUT COUNT
fig, ax = plt.subplots()
ax.set_xlabel('Network model')
ax.set_ylabel('LUT count')
ax.set_title('LUT count for different crossbar sizes and networks')

bar_width = 0.2
x = np.arange(len(categories))

colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466'] 
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), luts[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig('plots/crossbar_luts.svg', format='svg')
plt.show()

### REGISTER COUNT
fig, ax = plt.subplots()
ax.set_xlabel('Network model')
ax.set_ylabel('Register count')
ax.set_title('Register count for different crossbar sizes and networks')

bar_width = 0.2
x = np.arange(len(categories))

colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466'] 
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), regs[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig('plots/crossbar_regs.svg', format='svg')
plt.show()

### POWER
fig, ax = plt.subplots()
ax.set_xlabel('Network model')
ax.set_ylabel('Power (W)')
ax.set_title('Power for different crossbar sizes and networks')

bar_width = 0.2
x = np.arange(len(categories))

colors = ['#f6b65f', '#0f83a2', '#9a4a54', '#9dd466'] 
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), pow[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig('plots/crossbar_pow.svg', format='svg')
plt.show()

### MUX COUNT
data = {'A': {'pos': 289794, 'neg': 515063},
        'B': {'pos': 174790, 'neg': 292551},
        'C': {'pos': 375574, 'neg': 586616},
        'D': {'pos': 14932, 'neg': 8661}}
df = pd.DataFrame(data)
df = df.T
df ['sum'] = df.sum(axis=1)
df.sort_values('sum', ascending=False)[['neg','pos']].plot.bar() 