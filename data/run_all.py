import subprocess

# Run the other script
subprocess.run(["python", "crossbar_size.py"])
subprocess.run(["python", "1layer.py"])
subprocess.run(["python", "datatype_size.py"])
subprocess.run(["python", "input_neuron_compare.py"])