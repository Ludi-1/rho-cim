from modules import *

def main():
    fpga_clk_freq = 1 # 1 Hz
    ctrl1 = mlp_ctrl.MLP_Control(name="ctrl1", next_module = None, clk_freq = fpga_clk_freq, size = 3)
    ibuf1 = mlp_ibuf.MLP_Input_Buffer(name="ibuf1", next_module = ctrl1, clk_freq = fpga_clk_freq, size = 5)
    start_times = [0, 1, 2, 3]
    agent1 = agent.Agent(first_module = ibuf1, clk_freq=fpga_clk_freq, start_times=start_times)

    agent1.start()

if __name__ == "__main__":
    main()