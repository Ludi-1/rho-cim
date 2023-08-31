"""
Main script to instantiate configurations
"""

from mlp_conf import MLP_conf


def main():
    mlp_conf = MLP_conf(
        fpga_clk_freq=1,
        cim_clk_freq=1,
        inputs=100,
        neurons=[1, 2, 3, 4, 5],
        start_times=[0, 1, 3],
    )
    mlp_conf.start()


if __name__ == "__main__":
    main()
