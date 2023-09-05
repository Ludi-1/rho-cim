# IGNORE: Trying to get subcategories working in pyplot for MUX graphs

import matplotlib.pyplot as plt
import numpy as np

# Data
data = {
    "MLP-S": {
        "128": {"MUX7": 10, "MUX8": 20},
        "256": {"MUX7": 10, "MUX8": 20},
        "512": {"MUX7": 10, "MUX8": 20},
    },
    "MLP-M": {
        "128": {"MUX7": 10, "MUX8": 20},
        "256": {"MUX7": 10, "MUX8": 20},
        "512": {"MUX7": 10, "MUX8": 20},
    },
    "MLP-L": {
        "128": {"MUX7": 10, "MUX8": 20},
        "256": {"MUX7": 10, "MUX8": 20},
        "512": {"MUX7": 10, "MUX8": 20},
    },
}

# Extract the categories, subcategories, and values from the data
categories = list(data.keys())
subcategories = list(data[categories[0]]["128"].keys())

# Set the width of each bar
bar_width = 0.2

# Set the positions of the bars on the x-axis
r = np.arange(len(categories))
r128 = [x - bar_width for x in r]
r256 = r
r512 = [x + bar_width for x in r]

# Create the bar plots
plt.bar(
    r128,
    [data[cat]["128"]["MUX7"] for cat in categories],
    color="b",
    width=bar_width,
    edgecolor="black",
    label="128 MUX7",
)
plt.bar(
    r128,
    [data[cat]["128"]["MUX8"] for cat in categories],
    bottom=[data[cat]["128"]["MUX7"] for cat in categories],
    color="g",
    width=bar_width,
    edgecolor="black",
    label="128 MUX8",
)

plt.bar(
    r256,
    [data[cat]["256"]["MUX7"] for cat in categories],
    color="r",
    width=bar_width,
    edgecolor="black",
    label="256 MUX7",
)
plt.bar(
    r256,
    [data[cat]["256"]["MUX8"] for cat in categories],
    bottom=[data[cat]["256"]["MUX7"] for cat in categories],
    color="c",
    width=bar_width,
    edgecolor="black",
    label="256 MUX8",
)

plt.bar(
    r512,
    [data[cat]["512"]["MUX7"] for cat in categories],
    color="m",
    width=bar_width,
    edgecolor="black",
    label="512 MUX7",
)
plt.bar(
    r512,
    [data[cat]["512"]["MUX8"] for cat in categories],
    bottom=[data[cat]["512"]["MUX7"] for cat in categories],
    color="y",
    width=bar_width,
    edgecolor="black",
    label="512 MUX8",
)

# Add x-axis ticks and labels
plt.xlabel("Models")
plt.ylabel("Values")
plt.xticks(r, categories)

# Add a legend
plt.legend()

# Show the plot
plt.show()
