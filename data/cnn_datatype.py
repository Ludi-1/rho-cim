"""
Script for generating graphs
of the CNN HDL synthesis results for CNN-1 and CNN-2
for each datatype size and layer
"""
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Sample data CNN-1
variables = ["int2", "int4", "int8"]
categories = ["5x5,5", "2x2 Pool", "FC(720)", "FC(70)", "FC(10)"]

luts = [[76, 33, 225, 289, 107], [89, 33, 225, 289, 85], [114, 33, 225, 289, 85]]
regs = [[282, 33, 112, 777, 118], [515, 33, 112, 777, 118], [982, 33, 112, 777, 118]]

### LUT COUNT
fig, ax = plt.subplots()
ax.set_xlabel("Layer")
ax.set_ylabel("LUT count")
ax.set_title("LUT count for different crossbar sizes in CNN-1")

bar_width = 0.2
x = np.arange(len(categories))

colors = ["#f6b65f", "#0f83a2", "#9a4a54", "#9dd466"]
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), luts[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig("plots/cnn_1_datatype_luts.svg", format="svg")
plt.show()

### REGISTER COUNT
fig, ax = plt.subplots()
ax.set_xlabel("Layer")
ax.set_ylabel("Register count")
ax.set_title("Register count for different crossbar sizes in CNN-1")

bar_width = 0.2
x = np.arange(len(categories))

colors = ["#f6b65f", "#0f83a2", "#9a4a54", "#9dd466"]
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), regs[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig("plots/cnn_1_datatype_regs.svg", format="svg")
plt.show()

# Sample data CNN-2
variables = ["int2", "int4", "int8"]
categories = ["7x7,10", "2x2 Pool", "FC(1210)", "FC(1210)", "FC(10)"]

luts = [[102, 65, 338, 525, 455], [134, 65, 163, 1282, 1273], [114, 33, 225, 289, 85]]
regs = [
    [406, 63, 163, 1282, 1273],
    [755, 63, 163, 1282, 1273],
    [1454, 63, 163, 1282, 1273],
]

### LUT COUNT
fig, ax = plt.subplots()
ax.set_xlabel("Layer")
ax.set_ylabel("LUT count")
ax.set_title("LUT count for different crossbar sizes in CNN-2")

bar_width = 0.2
x = np.arange(len(categories))

colors = ["#f6b65f", "#0f83a2", "#9a4a54", "#9dd466"]
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), luts[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig("plots/cnn_2_datatype_luts.svg", format="svg")
plt.show()

### REGISTER COUNT
fig, ax = plt.subplots()
ax.set_xlabel("Layer")
ax.set_ylabel("Register count")
ax.set_title("Register count for different crossbar sizes in CNN-2")

bar_width = 0.2
x = np.arange(len(categories))

colors = ["#f6b65f", "#0f83a2", "#9a4a54", "#9dd466"]
for i, var in enumerate(variables):
    ax.bar(x + (i * bar_width), regs[i], width=bar_width, label=var, color=colors[i])
ax.set_xticks(x + (bar_width * (len(variables) - 1) / 2))
ax.set_xticklabels(categories)
ax.legend()
plt.savefig("plots/cnn_2_datatype_regs.svg", format="svg")
plt.show()
